#!/usr/bin/python
# Copyright: Meysam Azad
# Apache-2.0 (see LICENSE)

DOCUMENTATION = r"""
module: unattended_upgrades_sources
short_description: Set the per-source APT snapshot option by suite
description:
  - Edits one APT sources file in place, one-line (C(.list)) or deb822
    (C(.sources)) format, setting the snapshot option on entries whose
    suites match. Everything else in the file is left untouched.
  - Fails on a deb822 stanza mixing O(snapshot_no) suites with others,
    since the option applies to the whole stanza.
options:
  path:
    description: Sources file to edit.
    type: path
    required: true
  snapshot_no:
    description: Suites that must never come from a snapshot.
    type: list
    elements: str
    default: []
  snapshot_yes:
    description: Suites to opt in to the snapshot.
    type: list
    elements: str
    default: []
"""

import re

from ansible.module_utils.basic import AnsibleModule

ONE_LINE = re.compile(r"^(\s*deb(?:-src)?\s+)(?:\[([^\]]*)\]\s*)?(\S+\s+)(\S+)(.*)$")
FIELD = re.compile(r"^([A-Za-z0-9-]+):")


class MixedStanza(Exception):
    pass


def wanted(suites, no, yes):
    if suites and suites <= no:
        return "no"
    if suites & no:
        raise MixedStanza(" ".join(sorted(suites)))
    if suites and suites <= yes:
        return "yes"
    return None


def edit_one_line(text, no, yes):
    out = []
    for line in text.splitlines(keepends=True):
        m = ONE_LINE.match(line.rstrip("\n"))
        value = m and wanted({m.group(4)}, no, yes)
        if value:
            opts = [
                o
                for o in (m.group(2) or "").split()
                if not o.lower().startswith("snapshot")
            ]
            opts.append("snapshot=" + value)
            eol = "\n" if line.endswith("\n") else ""
            line = "%s[%s] %s%s%s%s" % (
                m.group(1),
                " ".join(opts),
                m.group(3),
                m.group(4),
                m.group(5),
                eol,
            )
        out.append(line)
    return "".join(out)


def edit_deb822(text, no, yes):
    # Stanzas are separated by blank lines; continuation lines start with
    # whitespace and belong to the field above them.
    stanzas = re.split(r"(\n[ \t]*\n)", text)
    for i in range(0, len(stanzas), 2):
        lines = stanzas[i].split("\n")
        fields = {}
        for n, line in enumerate(lines):
            m = FIELD.match(line)
            if m:
                fields[m.group(1).lower()] = n
        if "suites" not in fields:
            continue
        end = fields["suites"] + 1
        while end < len(lines) and lines[end][:1] in (" ", "\t"):
            end += 1
        suites = set(" ".join(lines[fields["suites"] : end]).split(":", 1)[1].split())
        value = wanted(suites, no, yes)
        if not value:
            continue
        if "snapshot" in fields:
            lines[fields["snapshot"]] = "Snapshot: " + value
        else:
            lines.insert(end, "Snapshot: " + value)
        stanzas[i] = "\n".join(lines)
    return "".join(stanzas)


def main():
    module = AnsibleModule(
        argument_spec=dict(
            path=dict(type="path", required=True),
            snapshot_no=dict(type="list", elements="str", default=[]),
            snapshot_yes=dict(type="list", elements="str", default=[]),
        ),
        supports_check_mode=True,
    )
    path = module.params["path"]
    no, yes = set(module.params["snapshot_no"]), set(module.params["snapshot_yes"])
    with open(path) as f:
        before = f.read()
    try:
        edit = edit_deb822 if path.endswith(".sources") else edit_one_line
        after = edit(before, no, yes)
    except MixedStanza as e:
        module.fail_json(
            msg="%s: a stanza mixes snapshot-exempt suites with others (%s). The Snapshot "
            "option applies to the whole stanza: move %s into a stanza of its own."
            % (path, e, ", ".join(sorted(no)))
        )
    changed = after != before
    if changed and not module.check_mode:
        tmp = module.tmpdir + "/sources"
        with open(tmp, "w") as f:
            f.write(after)
        module.atomic_move(tmp, path)
    module.exit_json(
        changed=changed,
        diff=dict(before=before, after=after, before_header=path, after_header=path),
    )


if __name__ == "__main__":
    main()

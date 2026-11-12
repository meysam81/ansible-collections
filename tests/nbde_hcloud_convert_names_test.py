"""No default of nbde_hcloud_convert is also a name its tasks register or set.

A task result registered under a default's name replaces that default for the
rest of the play: a switch read later would see a result dict, not the caller's
value. Run: python3 tests/nbde_hcloud_convert_names_test.py (needs PyYAML).
"""

import pathlib
import sys
import unittest

import yaml

ROLE = pathlib.Path(__file__).resolve().parent.parent / "roles" / "nbde_hcloud_convert"
SET_FACT = {"set_fact", "ansible.builtin.set_fact"}
SET_FACT_OPTIONS = {"cacheable"}


def tasks(items):
    """Every task, through block, rescue and always."""
    for task in items or []:
        yield task
        for section in ("block", "rescue", "always"):
            yield from tasks(task.get(section))


def assigned_names(path):
    """(name, how) for each register and set_fact key in a tasks file."""
    for task in tasks(yaml.safe_load(path.read_text())):
        if "register" in task:
            yield task["register"], f"register in {path.name}"
        for module in SET_FACT & task.keys():
            for key in (task[module] or {}).keys() - SET_FACT_OPTIONS:
                yield key, f"set_fact in {path.name}"


class Names(unittest.TestCase):
    def test_no_default_is_registered_or_set(self):
        defaults = set(yaml.safe_load((ROLE / "defaults" / "main.yml").read_text()))
        clashes = sorted(
            f"{name} ({how})"
            for path in sorted((ROLE / "tasks").glob("*.yml"))
            for name, how in assigned_names(path)
            if name in defaults
        )
        self.assertEqual(clashes, [], "defaults shadowed by task results")

    def test_the_walk_sees_registers(self):
        # Guards the test itself: a walk that found nothing would always pass.
        names = {
            name
            for path in (ROLE / "tasks").glob("*.yml")
            for name, _ in assigned_names(path)
        }
        self.assertIn("nbde_hcloud_convert_probe", names)
        self.assertIn("nbde_hcloud_convert_state", names)


if __name__ == "__main__":
    sys.exit(unittest.main())

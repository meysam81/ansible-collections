"""Parser checks for roles/unattended_upgrades/library/unattended_upgrades_sources.py.

Run: python3 tests/unattended_upgrades_sources_test.py (needs ansible importable).
"""

import importlib.util
import pathlib

_path = (
    pathlib.Path(__file__).resolve().parent.parent
    / "roles/unattended_upgrades/library/unattended_upgrades_sources.py"
)
_spec = importlib.util.spec_from_file_location("uus", _path)
uus = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(uus)

NO = {"noble-security"}

DEB822 = """\
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

## security
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
"""


def test_deb822_marks_only_security_stanza():
    out = uus.edit_deb822(DEB822, NO, set())
    assert out == DEB822.replace(
        "Suites: noble-security\n", "Suites: noble-security\nSnapshot: no\n"
    )
    assert uus.edit_deb822(out, NO, set()) == out


def test_deb822_overrides_existing_snapshot_value():
    src = "Types: deb\nSnapshot: yes\nSuites: noble-security\n"
    assert (
        uus.edit_deb822(src, NO, set())
        == "Types: deb\nSnapshot: no\nSuites: noble-security\n"
    )


def test_deb822_mixed_stanza_fails():
    try:
        uus.edit_deb822("Suites: noble noble-security\n", NO, set())
    except uus.MixedStanza:
        return
    raise AssertionError("mixed stanza accepted")


def test_one_line_opt_in_and_exempt():
    no, yes = {"jammy-security"}, {"jammy", "jammy-updates"}
    src = (
        "# deb http://archive.ubuntu.com/ubuntu jammy main\n"
        "deb http://archive.ubuntu.com/ubuntu jammy main restricted\n"
        "deb [arch=amd64 snapshot=no] http://archive.ubuntu.com/ubuntu jammy-updates main\n"
        "deb http://security.ubuntu.com/ubuntu jammy-security main # live\n"
        "deb https://download.example.com/linux/ubuntu stable main\n"
    )
    out = uus.edit_one_line(src, no, yes)
    assert out == (
        "# deb http://archive.ubuntu.com/ubuntu jammy main\n"
        "deb [snapshot=yes] http://archive.ubuntu.com/ubuntu jammy main restricted\n"
        "deb [arch=amd64 snapshot=yes] http://archive.ubuntu.com/ubuntu jammy-updates main\n"
        "deb [snapshot=no] http://security.ubuntu.com/ubuntu jammy-security main # live\n"
        "deb https://download.example.com/linux/ubuntu stable main\n"
    )
    assert uus.edit_one_line(out, no, yes) == out


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
    print("ok")

"""Render checks for roles/haproxy_config/templates/haproxy.cfg.j2 log format.

Run: python3 tests/haproxy_config_log_format_test.py
(needs ansible importable; set HAPROXY_BIN to also run `haproxy -c` on each
rendering; set UPDATE_GOLDEN=1 to rewrite tests/golden/).
"""

import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar, trust_as_template

ROOT = pathlib.Path(__file__).resolve().parent.parent
ROLES = ROOT / "roles"
GOLDEN = pathlib.Path(__file__).resolve().parent / "golden"

# Real consumers always set these; the role asserts they are non-empty.
CONSUMER_VARS = {
    "haproxy_backends": [
        {
            "name": "app",
            "servers": [{"name": "s1", "address": "192.0.2.10", "port": 8080}],
        }
    ],
    "haproxy_routes": [{"backend": "app", "match": {"host": "example.com"}}],
    "haproxy_threads": 2,  # default is a fact lookup; no facts outside a play
}


def render(**overrides):
    loader = DataLoader()
    variables = {}
    for role in ("haproxy", "haproxy_config"):
        variables.update(loader.load_from_file(str(ROLES / role / "defaults/main.yml")))
    variables.update(CONSUMER_VARS)
    variables.update(overrides)
    templar = Templar(loader=loader, variables=variables)
    src = (ROLES / "haproxy_config/templates/haproxy.cfg.j2").read_text()
    return templar.template(trust_as_template(src))


def log_format_lines(cfg):
    return [
        ln.strip() for ln in cfg.splitlines() if ln.strip().startswith("log-format")
    ]


def haproxy_check(cfg):
    """Return None when HAPROXY_BIN is unset, else the `haproxy -c` result."""
    binary = os.environ.get("HAPROXY_BIN")
    openssl = shutil.which("openssl")
    if not binary or not openssl:
        return None
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        # Paths the config references do not exist on a build machine: point
        # them at a scratch tree holding a throwaway cert and stub error pages.
        (tmp / "certs").mkdir()
        (tmp / "errors").mkdir()
        for path in re.findall(r"errorfile \d+ (\S+)", cfg):
            (tmp / "errors" / pathlib.Path(path).name).write_text(
                "HTTP/1.0 200 OK\r\n\r\n"
            )
        subprocess.run(
            [
                openssl,
                "req",
                "-x509",
                "-newkey",
                "ec",
                "-pkeyopt",
                "ec_paramgen_curve:prime256v1",
                "-nodes",
                "-subj",
                "/CN=example.com",
                "-days",
                "1",
                "-keyout",
                str(tmp / "certs/a.pem"),
                "-out",
                str(tmp / "certs/a.pem"),
            ],
            check=True,
            capture_output=True,
        )
        text = cfg.replace("/etc/haproxy/", f"{tmp}/")
        text = re.sub(
            r"^\s*(chroot|user|group|stats socket)\b.*\n", "", text, flags=re.M
        )
        (tmp / "cfg").write_text(text)
        return subprocess.run(
            [binary, "-c", "-f", str(tmp / "cfg")], capture_output=True, text=True
        )


class LogFormat(unittest.TestCase):
    def test_default_is_unchanged(self):
        for name, overrides in (
            ("default", {}),
            ("coraza", {"haproxy_coraza_enabled": True}),
        ):
            with self.subTest(name):
                got = render(**overrides)
                path = GOLDEN / f"haproxy_config_{name}.cfg"
                if os.environ.get("UPDATE_GOLDEN"):
                    path.write_text(got.rstrip("\n") + "\n")
                # Goldens end in one newline (end-of-file-fixer); ignore trailing blanks.
                self.assertEqual(path.read_text().rstrip("\n"), got.rstrip("\n"))

    def test_redact_query_drops_query_string(self):
        for coraza in (False, True):
            with self.subTest(coraza=coraza):
                cfg = render(
                    haproxy_log_redact_query=True, haproxy_coraza_enabled=coraza
                )
                (line,) = log_format_lines(cfg)
                self.assertNotIn("%{+Q}r", line)
                self.assertNotIn("%r ", line + " ")
                self.assertNotIn("%HU", line)
                self.assertNotIn("%HQ", line)
                self.assertNotIn("HAPROXY_HTTP_LOG_FMT", line)
                self.assertIn("%{+Q}HM %{+Q}HPO %{+Q}HV", line)
                # Everything else of the stock HTTP format is kept.
                for field in (
                    "%ci:%cp",
                    "[%tr]",
                    "%ft %b/%s",
                    "%TR/%Tw/%Tc/%Tr/%Ta",
                    "%ST %B",
                    "%hr %hs",
                ):
                    self.assertIn(field, line)
                # Suffix (header dump, WAF fields) is exactly the existing one.
                self.assertTrue(
                    line.endswith(
                        'req_hdrs:%{+Q}[var(txn.req_hdrs)] resp_hdrs:%{+Q}[var(txn.resp_hdrs)]"'
                    )
                )
                self.assertEqual(coraza, "waf-hit:" in line)
                # Header redaction rule is untouched.
                self.assertEqual(
                    1,
                    sum(
                        "set-var(txn.req_hdrs)" in ln and "[redacted]" in ln
                        for ln in cfg.splitlines()
                    ),
                )

    def test_default_keeps_stock_format(self):
        (line,) = log_format_lines(render())
        self.assertTrue(
            line.startswith('log-format "${HAPROXY_HTTP_LOG_FMT} req_hdrs:')
        )

    def test_haproxy_accepts_both(self):
        for overrides in ({}, {"haproxy_log_redact_query": True}):
            with self.subTest(overrides):
                res = haproxy_check(render(**overrides))
                if res is None:
                    self.skipTest("HAPROXY_BIN not set")
                self.assertEqual(0, res.returncode, res.stderr)


if __name__ == "__main__":
    sys.exit(unittest.main())

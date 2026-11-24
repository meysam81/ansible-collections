"""Render and run checks for the redis role's managed config.

Run: python3 tests/redis_config_test.py
(needs ansible importable; the end-to-end case also needs `redis-server` and
`redis-cli` on PATH and is skipped without them).
"""

import pathlib
import secrets
import shutil
import socket
import subprocess
import tempfile
import time
import unittest

from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar, trust_as_template

ROLE = pathlib.Path(__file__).resolve().parent.parent / "roles/redis"


def render(**overrides):
    loader = DataLoader()
    variables = loader.load_from_file(str(ROLE / "defaults/main.yml"))
    variables.update(ansible_managed="Ansible managed", **overrides)
    templar = Templar(loader=loader, variables=variables)
    src = (ROLE / "templates/redis-managed.conf.j2").read_text()
    return templar.template(trust_as_template(src))


class Rendering(unittest.TestCase):
    def test_defaults_are_safe(self):
        out = render(redis_requirepass="x")
        self.assertIn("bind 127.0.0.1\n", out)
        self.assertIn("protected-mode yes\n", out)
        self.assertIn("appendonly yes\n", out)
        self.assertIn("maxmemory-policy noeviction\n", out)
        self.assertNotIn("\nmaxmemory ", out)

    def test_optional_settings(self):
        out = render(
            redis_requirepass="x",
            redis_appendonly=False,
            redis_maxmemory="256mb",
            redis_extra_config=["slowlog-max-len 64"],
        )
        self.assertIn("appendonly no\n", out)
        self.assertIn("maxmemory 256mb\n", out)
        self.assertTrue(out.endswith("slowlog-max-len 64\n"))


def free_port():
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


@unittest.skipUnless(
    shutil.which("redis-server") and shutil.which("redis-cli"), "redis not installed"
)
class Boots(unittest.TestCase):
    def test_awkward_password_authenticates(self):
        """Quotes, backslashes and spaces must survive the config quoting."""
        password = f'a "b" \\c d {secrets.token_hex(4)}'
        port = free_port()
        with tempfile.TemporaryDirectory() as tmp:
            conf = pathlib.Path(tmp) / "redis.conf"
            conf.write_text(
                f"dir {tmp}\nlogfile {tmp}/log\n"
                + render(redis_requirepass=password, redis_port=port)
            )
            server = subprocess.Popen(
                ["redis-server", str(conf)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            try:
                for _ in range(50):
                    try:
                        socket.create_connection(("127.0.0.1", port), 0.2).close()
                        break
                    except OSError:
                        time.sleep(0.1)
                cli = ["redis-cli", "-p", str(port), "--no-auth-warning", "--raw"]
                env = {"REDISCLI_AUTH": password, "PATH": shutil.os.environ["PATH"]}
                ok = subprocess.run(
                    [*cli, "config", "get", "appendonly"],
                    env=env,
                    capture_output=True,
                    text=True,
                )
                self.assertEqual(ok.stdout.split(), ["appendonly", "yes"])
                anon = subprocess.run(
                    [*cli, "ping"],
                    capture_output=True,
                    text=True,
                    env=env | {"REDISCLI_AUTH": ""},
                )
                self.assertIn("NOAUTH", anon.stdout)
            finally:
                server.terminate()
                server.wait(5)


if __name__ == "__main__":
    unittest.main()

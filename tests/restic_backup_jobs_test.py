"""Render and run checks for the restic_backup role.

Run: python3 tests/restic_backup_jobs_test.py
(needs ansible importable; the end-to-end cases also need `restic` on PATH and
are skipped without it; set UPDATE_GOLDEN=1 to rewrite tests/golden/).

The goldens hold what the single-repository backup rendered before
`restic_backup_jobs` existed: they pin backward compatibility.
"""

import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar, trust_as_template

ROOT = pathlib.Path(__file__).resolve().parent.parent
ROLE = ROOT / "roles/restic_backup"
GOLDEN = pathlib.Path(__file__).resolve().parent / "golden"

PLAIN = {
    "restic_repo_url": "/srv/repo",
    "restic_password": "pw",
    "restic_paths": ["/etc", "/var/my data"],
}
FULL = {
    "restic_repo_url": "s3:https://s3.example.com/b/p",
    "restic_password": "pw",
    "restic_paths": ["/etc", "/var/my data"],
    "restic_exclude_patterns": ["*.tmp", "a b"],
    "restic_aws_access_key_id": "AK",
    "restic_aws_secret_access_key": "SK",
    "restic_extra_env": ["A=1", "B=2"],
    "restic_metrics_textfile_dir": "/var/lib/tf",
    "restic_keep_daily": 0,
    "restic_keep_yearly": 2,
    "restic_init_if_missing": False,
    "restic_snapshot_tag": "x y",
}


def render(template, job=None, **overrides):
    loader = DataLoader()
    variables = loader.load_from_file(str(ROLE / "defaults/main.yml"))
    variables.update(ansible_managed="Ansible managed", **overrides)
    if job is not None:
        variables["restic_backup_job"] = job
    templar = Templar(loader=loader, variables=variables)
    src = (ROLE / "templates" / template).read_text()
    return templar.template(trust_as_template(src))


def job(**kw):
    base = {
        "name": "app-one",
        "repo_url": "/unused",
        "password": "job-pw",
        "paths": ["/srv/data"],
    }
    base.update(kw)
    return base


class SingleBackupUnchanged(unittest.TestCase):
    def test_renders_as_before_jobs_existed(self):
        files = {
            "script": "restic-backup.sh.j2",
            "service": "restic-backup.service.j2",
            "timer": "restic-backup.timer.j2",
        }
        for case, vars_ in (("plain", PLAIN), ("full", FULL)):
            for ext, template in files.items():
                with self.subTest(case=case, file=ext):
                    got = render(template, **vars_)
                    path = GOLDEN / f"restic_backup_{case}.{ext}"
                    if os.environ.get("UPDATE_GOLDEN"):
                        path.write_text(got)
                    self.assertEqual(path.read_text(), got)
        with self.subTest(file="env"):
            got = render("restic.env.j2", **FULL)
            self.assertEqual((GOLDEN / "restic_backup_full.env").read_text(), got)


class JobUnits(unittest.TestCase):
    def test_service_is_per_job(self):
        out = render(
            "restic-backup.service.j2", job=job(read_write_paths=["/srv/data"])
        )
        self.assertIn("EnvironmentFile=/etc/restic/jobs/app-one.env", out)
        self.assertIn("ExecStart=/usr/local/bin/restic-backup-app-one.sh", out)
        self.assertIn("SyslogIdentifier=restic-backup-app-one", out)
        self.assertIn("ReadWritePaths=/var/cache/restic /srv/data\n", out)
        self.assertNotIn("OnFailure", out)

    def test_on_failure_unit_applies_to_single_and_jobs(self):
        for kw in ({}, {"job": job()}):
            with self.subTest(kw=kw):
                out = render(
                    "restic-backup.service.j2",
                    restic_backup_on_failure_unit="notify@%n.service",
                    **kw,
                )
                self.assertIn("OnFailure=notify@%n.service\n", out)

    def test_timer_falls_back_to_role_schedule(self):
        self.assertIn(
            "OnCalendar=hourly\n",
            render("restic-backup.timer.j2", job=job(on_calendar="hourly")),
        )
        self.assertIn(
            "OnCalendar=*-*-* 03:00:00\n", render("restic-backup.timer.j2", job=job())
        )

    def test_env_file_falls_back_and_overrides(self):
        out = render(
            "restic-job.env.j2",
            job=job(),
            restic_aws_access_key_id="RA",
            restic_aws_secret_access_key="RS",
            restic_extra_env=["X=1"],
        )
        self.assertIn("RESTIC_PASSWORD=job-pw\n", out)
        self.assertIn("AWS_ACCESS_KEY_ID=RA\n", out)
        self.assertIn("X=1\n", out)
        out = render(
            "restic-job.env.j2",
            job=job(
                aws_access_key_id="JA", aws_secret_access_key="JS", extra_env=["Y=2"]
            ),
        )
        self.assertIn("AWS_ACCESS_KEY_ID=JA\n", out)
        self.assertIn("Y=2\n", out)
        self.assertNotIn("X=1", out)


class JobScript(unittest.TestCase):
    def test_retention_falls_back_per_key(self):
        out = render(
            "restic-backup.sh.j2", job=job(keep_daily=3, tag="t"), restic_keep_weekly=5
        )
        self.assertIn("--keep-daily 3", out)
        self.assertIn("--keep-weekly 5", out)
        self.assertIn("--keep-monthly 12", out)
        self.assertNotIn("--keep-yearly", out)
        self.assertIn("--tag t \\\n  --host", out)

    def test_metrics_carry_the_job_label(self):
        out = render("restic-backup.sh.j2", job=job(), restic_metrics_textfile_dir="/m")
        self.assertIn(
            'restic_backup_last_exit_code{job=\\"app-one\\",tag=\\"auto\\"}', out
        )
        self.assertIn('METRICS_FILE="/m/restic_backup_app-one.prom"', out)

    def test_pre_commands_run_before_restic(self):
        out = render(
            "restic-backup.sh.j2", job=job(pre_backup_commands=["echo 'a b'", "false"])
        )
        self.assertLess(out.index("echo '"), out.index("\nrestic backup \\"))
        self.assertLess(out.index("false"), out.index("restic --quiet snapshots"))


@unittest.skipUnless(shutil.which("restic"), "restic not installed")
class JobRuns(unittest.TestCase):
    """Run the rendered script against a local repository."""

    def run_job(self, tmp, **kw):
        tmp = pathlib.Path(tmp)
        data = tmp / "data"
        data.mkdir()
        (data / "f").write_text("x")
        repo = tmp / "repo"
        metrics = tmp / "metrics"
        metrics.mkdir()
        spec = job(repo_url=str(repo), paths=[str(data)], **kw)
        script = tmp / "run.sh"
        script.write_text(
            render(
                "restic-backup.sh.j2",
                job=spec,
                restic_metrics_textfile_dir=str(metrics),
                restic_keep_daily=1,
            )
        )
        env_lines = render(
            "restic-job.env.j2", job=spec, restic_cache_dir=str(tmp / "cache")
        )
        env = dict(os.environ)
        env.update(
            line.split("=", 1)
            for line in env_lines.splitlines()
            if "=" in line and not line.startswith("#")
        )
        proc = subprocess.run(
            ["bash", str(script)], env=env, capture_output=True, text=True
        )
        prom = (metrics / "restic_backup_app-one.prom").read_text()
        return proc, repo, prom

    def test_backup_runs_and_reports_success(self):
        with tempfile.TemporaryDirectory() as tmp:
            proc, repo, prom = self.run_job(
                tmp, pre_backup_commands=[f"touch {tmp}/staged"]
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            self.assertTrue((pathlib.Path(tmp) / "staged").exists())
            self.assertTrue((repo / "config").exists())
            self.assertIn(
                'restic_backup_last_exit_code{job="app-one",tag="auto"} 0', prom
            )
            self.assertIn("restic_backup_last_success_timestamp_seconds{", prom)

    def test_failing_pre_command_fails_the_job_without_backing_up(self):
        with tempfile.TemporaryDirectory() as tmp:
            proc, repo, prom = self.run_job(
                tmp, pre_backup_commands=["exit 7", "touch never"]
            )
            self.assertEqual(proc.returncode, 7)
            self.assertFalse(
                repo.exists(), "restic must not run after a failed pre-backup command"
            )
            self.assertFalse((pathlib.Path(tmp) / "never").exists())
            self.assertIn(
                'restic_backup_last_exit_code{job="app-one",tag="auto"} 7', prom
            )
            self.assertNotIn("last_success_timestamp_seconds{", prom)


if __name__ == "__main__":
    unittest.main()

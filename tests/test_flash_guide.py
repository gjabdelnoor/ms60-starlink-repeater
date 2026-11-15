"""Uses pytest fixtures to test guide control flow with no network or router writes."""
from functools import partial
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess

import pytest

SOURCE = Path(__file__).resolve().parents[1]


@pytest.fixture
def guide(tmp_path, monkeypatch):
    root = tmp_path / 'repo with spaces'
    root.mkdir()
    shutil.copy2(SOURCE / 'flash-ms60.sh', root)
    payload = tmp_path / 'download.fixture'
    payload.write_bytes(b'MS60 GUIDE TEST FIXTURE ONLY')
    manifest = json.loads((SOURCE / 'firmware-manifest.json').read_text())
    manifest.update(source_url='https://example.invalid/MS60.chk', bytes=payload.stat().st_size,
                    sha256=hashlib.sha256(payload.read_bytes()).hexdigest())
    (root / 'firmware-manifest.json').write_text(json.dumps(manifest))
    downloaded = tmp_path / 'downloaded'
    opened = tmp_path / 'opened'
    curl = tmp_path / 'curl'
    curl.write_text('#!/bin/sh\nprintf download > ' + shlex.quote(str(downloaded)) + '\ncp ' + shlex.quote(str(payload)) + ' MS60.chk\n')
    curl.chmod(0o755)
    browser = tmp_path / 'browser'
    browser.write_text('#!/bin/sh\nprintf "%s\\n" "$1" >> ' + shlex.quote(str(opened)) + '\n')
    browser.chmod(0o755)
    monkeypatch.setenv('PATH', str(tmp_path) + os.pathsep + os.environ['PATH'])
    monkeypatch.setenv('BROWSER', shlex.quote(str(browser)) + ' %s')
    run = partial(subprocess.run, ['bash', str(root / 'flash-ms60.sh')], cwd=root,
                  capture_output=True, text=True, timeout=15, env=dict(os.environ))
    return root, payload, downloaded, opened, curl, run


@pytest.mark.parametrize('model', ['MR60', ''])
def test_other_model_exits_before_download_or_browser(guide, model):
    root, payload, downloaded, opened, curl, run = guide
    assert run(input=model + '\n').returncode != 0
    assert not downloaded.exists() and not opened.exists()


@pytest.mark.parametrize('same_size', [False, True])
def test_corrupt_download_stops_before_admin_page(guide, same_size):
    root, payload, downloaded, opened, curl, run = guide
    payload.write_bytes(payload.read_bytes()[::-1] if same_size else b'BAD')
    result = run(input='MS60\n')
    assert result.returncode != 0
    assert ('SHA-256 differs' if same_size else 'size differs') in result.stderr
    assert not opened.exists()


@pytest.mark.parametrize('address', ['', '192.0.2.50'])
def test_guide_opens_operator_pages_in_order(guide, address):
    root, payload, downloaded, opened, curl, run = guide
    result = run(input='MS60\n' + address + '\n\n\n')
    assert result.returncode == 0, result.stderr
    base = 'http://' + (address or '192.168.1.250')
    assert opened.read_text().splitlines() == [base + '/', base + '/UPG_upgrade.htm', 'http://192.168.50.1/']
    assert downloaded.exists()
    assert 'operator' in result.stdout


def test_existing_image_is_reused_without_overwriting(guide):
    root, payload, downloaded, opened, curl, run = guide
    shutil.copy2(payload, root / 'MS60.chk')
    assert run(input='MS60\n\n\n\n').returncode == 0
    assert not downloaded.exists()


def test_invalid_address_stops_before_browser(guide):
    root, payload, downloaded, opened, curl, run = guide
    assert run(input='MS60\nnot-an-ip\n').returncode != 0
    assert not opened.exists()


def test_eof_at_login_pause_does_not_open_upload_page(guide):
    root, payload, downloaded, opened, curl, run = guide
    assert run(input='MS60\n192.0.2.50\n').returncode != 0
    assert opened.read_text().splitlines() == ['http://192.0.2.50/']


def test_download_error_does_not_open_browser(guide):
    root, payload, downloaded, opened, curl, run = guide
    curl.write_text('#!/bin/sh\nexit 22\n')
    assert run(input='MS60\n').returncode == 22
    assert not opened.exists()

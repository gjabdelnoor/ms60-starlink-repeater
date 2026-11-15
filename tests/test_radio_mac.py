"""Uses pytest to check only the template's custom address validation."""
import os
from pathlib import Path
import subprocess

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts' / 'services-start.sh'


@pytest.mark.parametrize('address', [
    'REPLACE_WITH_UNIQUE_LOCAL_UNICAST_MAC',
    'FF:FF:FF:FF:FF:FF',
    '01:00:00:00:00:01',
    '00:00:00:00:00:01',
    '02:00:00:00:00',
    '02:00:00:00:00:GG',
])
def test_invalid_address_stops_before_hardware_commands(tmp_path, address):
    script = tmp_path / 'services-start'
    script.write_text(SCRIPT.read_text().replace('REPLACE_WITH_UNIQUE_LOCAL_UNICAST_MAC', address))
    result = subprocess.run(['sh', str(script)], capture_output=True, text=True)
    assert result.returncode == 1
    assert 'Set RADIO_MAC' in result.stderr
    assert 'not found' not in result.stderr


@pytest.mark.parametrize('address', ['02:00:00:00:60:01', '36:00:00:00:60:02', 'aa:00:00:00:60:03', 'EE:00:00:00:60:04'])
def test_local_unicast_address_is_accepted_without_real_hardware(tmp_path, address):
    executable = tmp_path / 'noop'
    executable.write_text('#!/bin/sh\nexit 0\n')
    executable.chmod(0o755)
    (tmp_path / 'nvram').symlink_to(executable)
    (tmp_path / 'wl').symlink_to(executable)
    (tmp_path / 'logger').symlink_to(executable)
    script = tmp_path / 'services-start'
    script.write_text(SCRIPT.read_text().replace('REPLACE_WITH_UNIQUE_LOCAL_UNICAST_MAC', address))
    env = dict(os.environ, PATH=str(tmp_path) + os.pathsep + os.environ['PATH'])
    result = subprocess.run(['sh', str(script)], capture_output=True, text=True, env=env)
    assert result.returncode == 0

#!/usr/bin/env bash
# Uses curl and Python's hashlib, json, ipaddress, and webbrowser libraries.
# no library: the operator-led stock/SWRT browser workflow needs device-specific prompts.
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$ROOT/firmware-manifest.json"
IMAGE="$PWD/MS60.chk"
command -v python3 >/dev/null || { printf 'Install Python 3 before running this guide.\n' >&2; exit 1; }
command -v curl >/dev/null || { printf 'Install curl before running this guide.\n' >&2; exit 1; }

printf '\nMS60 firmware installation guide\n'
printf 'Read the label on the satellite. This image was tested on NETGEAR MS60 units.\n'
read -r -p 'Type MS60 to select that model, or anything else to exit: ' MODEL
[[ "$MODEL" == MS60 ]] || { printf 'Exited before downloading firmware.\n'; exit 1; }

IMAGE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["source_url"])' "$MANIFEST")"
if [[ -e "$IMAGE" ]]; then
    printf '\nChecking the existing %s\n' "$IMAGE"
else
    printf '\nDownloading the tested MS60 factory image to %s\n' "$IMAGE"
    curl --fail --location --proto '=https' --proto-redir '=https' --output "$IMAGE" "$IMAGE_URL"
fi
python3 - "$MANIFEST" "$IMAGE" <<'PY'
import hashlib
import json
from pathlib import Path
import sys

manifest = json.loads(Path(sys.argv[1]).read_text())
image = Path(sys.argv[2])
if image.stat().st_size != manifest['bytes']:
    raise SystemExit('Image size differs from the tested MS60 image. Stop and check the download.')
if hashlib.sha256(image.read_bytes()).hexdigest() != manifest['sha256']:
    raise SystemExit('Image SHA-256 differs from the tested MS60 image. Stop and check the download.')
print('Verified:', manifest['observed_runtime'])
print('Expected stock upload version:', manifest['stock_uploader_version'])
PY

printf '\nConnect the powered satellite by Ethernet to a reachable setup network.\n'
printf 'Use its assigned DHCP address; the factory fallback is 192.168.1.250.\n'
printf 'Addressing help: %s/docs/installation.md\n' "$ROOT"
read -r -p 'Satellite IPv4 address [192.168.1.250]: ' ADDRESS
ADDRESS="${ADDRESS:-192.168.1.250}"
python3 -c 'import ipaddress,sys; ipaddress.IPv4Address(sys.argv[1])' "$ADDRESS"
BASE="http://$ADDRESS"

printf '\n1. Log in at %s/ in your browser. Factory login: admin / password.\n' "$BASE"
printf 'Keep the browser session: the initial login challenge sets a cookie.\n'
printf 'If reset is needed, hold Reset at least seven seconds until the LED blinks, then let it reboot.\n'
python3 -c 'import sys,webbrowser; sys.exit(not webbrowser.open(sys.argv[1]))' "$BASE/" || printf 'Open the printed address manually.\n'
read -r -p 'Press Enter after you can access the stock MS60 admin page: ' READY

printf '\n2. Open %s/UPG_upgrade.htm and select this exact file:\n%s\n' "$BASE" "$IMAGE"
printf 'The verified image displays as V1.0.6.112_2.0.50 in the stock uploader.\n'
printf 'Confirm the expected older-version prompt after checking that version.\n'
printf 'Leave power connected during writing and reboot; wait for setup Wi-Fi ASUS_55.\n'
printf 'If the page rejects the image, stop and consult docs/installation.md.\n'
python3 -c 'import sys,webbrowser; sys.exit(not webbrowser.open(sys.argv[1]))' "$BASE/UPG_upgrade.htm" || printf 'Open the printed upload page manually.\n'

printf '\n3. After the reboot finishes, use a spare Wi-Fi adapter, phone, or computer to join ASUS_55.\n'
printf 'Check that it receives a 192.168.50.x address. The Ethernet port initially acts as WAN.\n'
read -r -p 'Press Enter after the upload, reboot, and setup-Wi-Fi connection are complete: ' READY
printf '\nOpen http://192.168.50.1/ and finish the SWRT account setup.\n'
printf 'Observed initial SWRT login: admin / admin. Set your own new admin password.\n'
python3 -c 'import sys,webbrowser; sys.exit(not webbrowser.open(sys.argv[1]))' 'http://192.168.50.1/' || printf 'Open the setup address manually.\n'

cat <<'TEXT'

4. Configure the repeater using docs/configuration.md:
   Choose the 2.4 GHz upstream Wi-Fi network and its WPA2-AES passphrase.
   Give both downstream bands the same network name and passphrase.
   Use upstream DHCP for the management address and keep the MS60 DHCP server off.
   For the tested build, the mode values are sw_mode=3, wlc_psta=2, wlc_dpsta=0.
   Before enabling a second unit's 5 GHz radio, check for the duplicate-radio-MAC issue.
   The per-unit startup correction is in scripts/services-start.sh.

5. Verify the running firmware, both network names, and Internet access over the
   satellite's Wi-Fi and Ethernet. Reboot and check the unique radio address again.
   Stop any temporary setup DHCP service before enabling the wireless uplink.
   Remove temporary setup addresses and disable SSH if you enabled it for configuration.

The guide has reached SWRT setup. Upload completion and device state are confirmed
by the operator; the script does not detect or certify a successful flash.
TEXT

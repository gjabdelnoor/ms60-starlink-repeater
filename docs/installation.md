# Installation and recovery

This records two successful installation paths. It is a manual procedure for MS60 owners, with no universal flasher or automatic password recovery.

Run `bash ./flash-ms60.sh` from the repository to follow the download and browser-upload steps interactively. The script verifies the image before opening admin pages. It leaves authentication, the upload action, and confirmation of the completed reboot to the operator. The host addressing and recovery details below still apply.

## Identify the hardware and image

Read the label: **MS60 satellite**, not MR60, MS70, MS80, or another Nighthawk product. A UI identifying the converted unit as `RT-AX56U` is expected for this SWRT build; it does not make an ASUS image interchangeable with an MS60 image.

The exact upstream factory image installed was:

| Property | Observed value |
| --- | --- |
| Source | `https://firmware.swrt.site/firmware/NETGEAR/MS60/MS60.chk` |
| Bytes | `37355598` |
| SHA-256 | `bcb9ac2bdbd6313c1738413aa1cc4caa6a8ddd19c905f327c231d13ab5aa8c15` |
| NETGEAR board ID in image | `U12H414T10_NETGEAR` |
| NETGEAR CHK header size | 58 bytes |
| Version displayed by stock uploader | `V1.0.6.112_2.0.50` |
| Runtime firmware after conversion | `MS60_R5.1.9-g816a96e` |

The filename is a mutable upstream URL. A future download with a different digest is a different artifact and has not been validated by this record. The newer 5.2.9 `.w` image inspected during research was not installed. Do not substitute a raw `.w` file or another model's image into the stock `.chk` upload procedure.

Download from upstream and compare the hash locally:

```sh
curl -fLo MS60.chk https://firmware.swrt.site/firmware/NETGEAR/MS60/MS60.chk
sha256sum MS60.chk
```

On macOS, use `shasum -a 256 MS60.chk` instead of `sha256sum`. Keep the matching NETGEAR stock image and a usable recovery path available before changing firmware.

## Reach the stock satellite

The stock satellite acted as a DHCP client. On our isolated Ethernet connection, it needed an address from a temporary DHCP service restricted to that Ethernet interface and that satellite's hardware address. The admin computer also needed an address on the same subnet. That temporary service was stopped before the repeater uplink was enabled.

A router LAN supplying ordinary DHCP should serve the same addressing purpose, but that variant was not exercised in this deployment. Do not start an extra DHCP server on an existing household LAN.

The stock fallback address documented by NETGEAR is `192.168.1.250`; our satellite's DHCP-assigned address was used instead. Find the actual assigned address rather than assuming the fallback always responds.

If a factory reset is needed, NETGEAR's manual specifies holding the powered satellite's Reset button for at least seven seconds until the LED blinks, then releasing it. Leave power connected while it reboots. A brief period of an unreachable login page is expected during reboot. [NETGEAR MR60/MS60 manual](https://www.downloads.netgear.com/files/GDC/MK62/MK62_UM_EN.pdf).

## Preserve the stock login challenge cookie

Factory credentials are `admin` / `password`. The stock login's initial HTTP 401 response set an `XSRF_TOKEN` cookie. Authentication succeeded after that challenge cookie was carried into the authenticated request. Earlier requests that omitted it incorrectly looked like wrong-password failures.

For a Python client, use Requests' session and cookie handling. Change only `BASE` to the satellite's actual address:

```python
import requests

BASE = "http://192.168.1.250"
session = requests.Session()
session.trust_env = False
challenge = session.get(BASE + "/", stream=True, timeout=5)
challenge.close()
response = session.get(BASE + "/", auth=("admin", "password"), timeout=8)
print(response.status_code)
```

An ordinary browser should preserve this cookie automatically. A reset and a completed reboot were sufficient for the second unit; credential guessing was unnecessary for the successful installation path.

## Upload through the stock admin UI

Two successful starting points were recorded:

| Unit | Stock version immediately before SWRT upload |
| --- | --- |
| A | `V1.1.9.146_2.0.72`, after stock recovery |
| B | `V1.1.7.134_2.0.65`, after an ordinary reset |

1. Log in to the stock interface and open its firmware update page, `UPG_upgrade.htm`.
2. Select the verified MS60 `MS60.chk` factory image.
3. Allow the uploader's image check to finish. The tested image triggered an older-version confirmation because of its NETGEAR version header.
4. Confirm that expected prompt after checking the displayed versions and image identity.
5. Leave power connected through writing and reboot. Wait for the converted firmware's setup Wi-Fi; a dropped Ethernet link during this interval did not mean the installation had failed.

For reproducing the authenticated UI flow, the actual upload form used multipart field `mtenFWUpload` and a dynamically generated action `upgrade_check.cgi?id=...`. The confirmation form used `upgrade.cgi?id=...` with `check_downgrade=1`. Parse the live form and carry its cookies and hidden fields; do not reuse another device's form ID. The binary and CHK headers were not modified.

## Set up the converted firmware over Wi-Fi first

On first SWRT boot, the single physical Ethernet socket behaved as a WAN port. The admin GUI was available through the open setup SSID `ASUS_55` at `192.168.50.1`. The observed initial SWRT admin login was `admin` / `admin`.

Use a spare Wi-Fi adapter, a phone, or a separate computer to join that setup network. This deployment used the Mac mini's Wi-Fi adapter while preserving the primary laptop connection. Check the actual association and assigned address: macOS `networksetup` sometimes returned status zero while its text reported a failed association.

Change the admin password immediately through the normal account setup UI. The running build used its `chpass.cgi` account-change path; writing only `http_passwd` through the settings API did not update this build's login account.

We first staged AP mode to make Ethernet usable for administration: `sw_mode=3`, `wlc_psta=0`, `wlc_dpsta=0`, a temporary static management address, and `dhcp_enable_x=0`. With two converted units nearby, leave the new unit's 5 GHz radio disabled until its radio address has been checked and corrected if necessary. Then apply the [repeater settings](configuration.md).

## Stock recovery case

One unit was recovered over Ethernet with [nmrpflash](https://github.com/jclehner/nmrpflash) 0.9.27 and the matching stock `MS60-V1.1.9.146_2.0.72.chk`. The utility negotiated an address, transferred all 41,812,046 bytes, received completion, and exited zero. The stock version was checked after reboot. SWRT was subsequently installed through the authenticated stock web UI.

In that particular recovery case, the utility was started while Ethernet was down and waited for link return. A sequence of holding Reset for ten seconds while powered, continuing to hold while unplugged for thirty seconds, reconnecting while holding for thirty seconds, then releasing preceded the successful transfer. This is a single observed recovery sequence, not NETGEAR's documented ordinary reset procedure or a requirement established for all MS60 units. Plain power-cycle TFTP attempts had not succeeded.

The nmrpflash controller command was:

```sh
sudo nmrpflash -i ETHERNET_INTERFACE -f MS60-V1.1.9.146_2.0.72.chk -v
```

Replace the interface name with the directly connected Ethernet adapter. The second unit did not require this recovery step. NMRP recovery of the SWRT factory image itself and rollback from the final SWRT configuration to stock were not demonstrated.

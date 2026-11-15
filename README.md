# Extend Starlink Wi-Fi with Nighthawk MS60 satellites

Turn inexpensive used NETGEAR Nighthawk MS60 satellites into wireless extenders for Starlink using SWRT firmware. Keep the same Wi-Fi network name and password, with client-driven roaming between access points.

**Tested on two MS60 satellites with a Starlink Gen 3 router.** Both provided Internet over Wi-Fi and Ethernet; an automatic client roam was observed. The original NETGEAR MR60 router was dead and was not needed for the resulting setup. Testing took place in one household on November 15, 2026.

Used MS60s have appeared around **US $30–$40**, including an adapter-included example at $35.97 before tax. Prices and shipping vary. See the [linked price examples](docs/portability.md#used-hardware-prices).

## Start the flashing guide

Use Bash 3.2 or newer, Python 3, `curl`, and a desktop browser. The script uses Python's standard library; no pip packages or root privileges are required for the guide itself. The stock satellite must have power and a reachable admin address. Have a way to join its setup Wi-Fi after flashing, and read the [installation and recovery notes](docs/installation.md) first.

```sh
git clone https://github.com/gjabdelnoor/ms60-starlink-repeater.git
cd ms60-starlink-repeater
bash ./flash-ms60.sh
```

You can also [download the ZIP](https://github.com/gjabdelnoor/ms60-starlink-repeater/archive/refs/heads/main.zip), extract it, and run the script from that directory.

The guide downloads `MS60.chk` into the current directory, verifies its exact size and SHA-256 against the tested manifest, opens the stock login and firmware upload pages, and pauses for the browser upload and reboot. If that filename already exists, the guide verifies it instead of overwriting it. It then opens SWRT setup and explains the repeater configuration and radio-address check. Browser login keeps credentials local and preserves the stock login challenge cookie.

This is an interactive installation walkthrough. The operator uploads the image in the browser and confirms progress; automated firmware installation, network-interface changes, credential collection, and recovery flashing are outside the script. The new guide's flow is tested with local stand-ins, and the underlying manual procedure is the one used on the two physical MS60s.

## What works

- Wireless uplink on 2.4 GHz, with downstream Wi-Fi on both 2.4 and 5 GHz.
- The upstream network's SSID and WPA2 passphrase on both downstream bands.
- Starlink supplies DHCP addresses; the MS60's DHCP server stays disabled.
- Internet access through an MS60's Wi-Fi and its single Ethernet port.
- Client-driven roaming: a laptop automatically moved from the Starlink AP to the first MS60 and retained its IPv4 address.
- Two converted MS60s operating together, with a persistent correction for a duplicate 5 GHz radio address on the second unit.

The second MS60 was observed using the first MS60 as its wireless parent. Both units do not necessarily connect directly to the Starlink router.

## Compatibility scope

| Item | Evidence |
| --- | --- |
| NETGEAR MS60 | Two physical units tested |
| Starlink Gen 3 / Router 3 | One upstream router tested |
| SWRT `MS60_R5.1.9-g816a96e` | Installed and tested |
| Other upstream WPA2 routers | Plausible from the repeater design; untested |
| Other NETGEAR satellite models or board revisions | Unvalidated; this image is MS60-specific |
| Starlink-managed mesh adoption | Not achieved; mesh service rejected a peer without an accepted STSAFE certificate |
| Seamless calls, 802.11r fast transitions, universal roaming | Not established |

These are wireless repeaters using client-driven roaming. They do not appear as adopted Starlink mesh nodes. [Starlink's Router 3 specifications](https://www.starlink.com/public-files/specification_sheet_standard.pdf) list Starlink mesh compatibility and exclude third-party mesh systems.

## Read in this order

1. [Installation and recovery](docs/installation.md): image identity, stock login, upload, and the single-port setup issue.
2. [Repeater configuration](docs/configuration.md): the actual mode values, radio interfaces, and per-unit settings.
3. [Portability and release scope](docs/portability.md): supported claims, deployment limits, and the public-release decision.
4. [Test record](docs/validation.md): observed results and unmeasured behavior.
5. [Native Starlink mesh findings](docs/native-mesh.md): the device-certificate rejection.

## Files included

- `flash-ms60.sh`: interactive firmware download, verification, and browser-based flashing guide.
- `examples/repeater-settings.json`: settings template with credential placeholders.
- `scripts/services-start.sh`: configurable version of the startup radio-address correction.
- `tests/test_radio_mac.py`: local tests of the script's address validation.
- `tests/test_flash_guide.py`: local checks for the guide's image checks and operator flow.
- `evidence/verified-results.json`: sanitized observations from the two-unit deployment.
- `communications/twitter-draft.txt`: copyable interest-check post.
- `firmware-manifest.json`: upstream image URL, SHA-256, size, and observed identity.

The repository contains original documentation and a small configuration script. Firmware development credit belongs to [SWRT](https://github.com/SWRT-dev/asuswrt-bcm), [paldier](https://blog.paldier.com/mk6x/), and their upstream projects. The installed image was an unmodified upstream download. Firmware binaries, credential exports, device certificates, packet captures, and household identifiers are excluded.

## Project status

This public release contains the field guide, interactive flashing walkthrough, and configuration scripts. Independent reproduction reports are welcome: include the satellite model, stock and SWRT versions, upstream router, and the steps that worked or failed. Keep passwords and device identifiers out of reports.

The hardware procedure was tested on two MS60s; the new Bash walkthrough was tested locally with stand-ins. Upstream currently marks the MS60 firmware family EOL, and the version used here is older than the index's listed 5.2.9 release. [Upstream firmware index](https://blog.paldier.com/categories/firmware/).

This repository's [MIT license](LICENSE) applies to its original material only. See [third-party attribution](THIRD_PARTY.md) for upstream firmware and tool references.

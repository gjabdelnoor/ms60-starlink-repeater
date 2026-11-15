# Nighthawk MS60 wireless repeaters for Starlink

Repurpose used NETGEAR Nighthawk MS60 satellites as wireless extenders for a Starlink Gen 3 router, using upstream SWRT firmware. Two MS60s were converted and tested in one household on November 15, 2026. The original NETGEAR MR60 router was dead and was not needed for the resulting setup.

The practical pitch: inexpensive used MS60 satellites can extend Starlink Wi-Fi with the same network name and password. Used units have appeared around US $30 on eBay; shipping, condition, and power adapters vary. See [price evidence](docs/portability.md#used-hardware-prices).

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

- `examples/repeater-settings.json`: settings template with credential placeholders.
- `scripts/services-start.sh`: configurable version of the startup radio-address correction.
- `tests/test_radio_mac.py`: local tests of the script's address validation.
- `evidence/verified-results.json`: sanitized observations from the two-unit deployment.
- `communications/twitter-draft.txt`: interest-check post; a draft only.
- `firmware-manifest.json`: upstream image URL, SHA-256, size, and observed identity.

The repository contains original documentation and a small configuration script. Firmware development credit belongs to [SWRT](https://github.com/SWRT-dev/asuswrt-bcm), [paldier](https://blog.paldier.com/mk6x/), and their upstream projects. The installed image was an unmodified upstream download. Firmware binaries, credential exports, device certificates, packet captures, and household identifiers are excluded.

## Current release position

Keep the repository private while reviewing the guide. A public guide and script are a reasonable next release after an independent MS60 reproduction. A turnkey installer or generalized firmware release would overstate the current test coverage. Upstream currently marks the MS60 firmware family EOL; the version used here is older than the index's listed 5.2.9 release. [Upstream firmware index](https://blog.paldier.com/categories/firmware/).

This repository's [MIT license](LICENSE) applies to its original material only. See [third-party attribution](THIRD_PARTY.md) for upstream firmware and tool references.

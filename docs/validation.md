# Test record

Observed during the two-unit deployment on November 15, 2026. Unit labels A and B replace household hardware identifiers. The sanitized machine-readable record is [verified-results.json](../evidence/verified-results.json).

| Check | Unit A | Unit B |
| --- | --- | --- |
| Installed runtime identifies MS60 SWRT R5.1.9 | Passed | Passed |
| Wireless uplink connected | Passed | Passed |
| Management address on Starlink LAN | Passed | Passed |
| Repeater DHCP server disabled | Passed | Passed |
| Downstream test SSID joined by Mac Wi-Fi | Passed | Passed |
| IPv4 HTTPS request forced through Mac Wi-Fi returned HTTP 200 | Passed | Passed |
| IPv4 HTTPS request forced through Mac Ethernet returned HTTP 200 | Passed | Passed |
| Final downstream SSIDs match upstream on both bands | Passed | Passed |
| Actual 5 GHz radio address differs between units | Passed as a pair | Passed as a pair |
| Startup correction survives reboot | Not installed on A | Passed on B |
| Final SSID and radio identity survive final reboot | First unit not re-tested here | Passed on B |

The Wi-Fi checks used a unique temporary downstream SSID before switching to the final shared SSID. For B, the Mac's current-network report explicitly matched that test SSID, DHCP returned an address in the Starlink LAN, the gateway was Starlink, and `curl -4 --interface en1` returned HTTP 200. This avoided accidentally counting traffic through another already-working Wi-Fi AP as B's test result.

The Ethernet checks bound curl to Ethernet or its assigned IPv4 address. A successful generic request without interface binding would not establish which network path worked.

The laptop automatically moved from the original Starlink BSSID to A's 5 GHz BSSID while keeping its IPv4 address. No laptop reconnect command was issued for that observed transition. A separate 36-second ping capture received 179 of 180 replies, but it ended before the observed roam; it does not measure handoff loss or timing.

B's parent BSSID was A's 2.4 GHz radio at the final shell inspection. This is a working chained repeater arrangement. The tests do not establish that both MS60s independently connect to the Starlink router.

At the end of setup, the Mac's Wi-Fi was on the shared upstream SSID, temporary static Ethernet aliases and the temporary DHCP service were gone, temporary credential files were deleted, and the SSH service enabled for setup on B was disabled. No recurring SSID watcher was left running.

## Local repository checks

The reusable script is a parameterized template of the working commands. Its newly added validation is checked locally with installed pytest and POSIX shell syntax checks. These tests do not emulate Broadcom radios or establish support for a new hardware model.

```sh
sh -n scripts/services-start.sh
python -m pytest -q
```

No deployment changes are required to create or validate this repository.

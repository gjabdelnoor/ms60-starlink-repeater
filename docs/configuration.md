# Repeater configuration

The tested build exposes Asuswrt-style administration while running on the MS60. Use its repeater wizard where available. The values below record the configuration actually accepted by the running firmware, for reproducibility and troubleshooting.

## Operating mode

| Setting | Tested value | Purpose |
| --- | --- | --- |
| `sw_mode` | `3` | AP-family operating mode used by this implementation |
| `wlc_psta` | `2` | Broadcom pseudo-station repeater mode |
| `wlc_dpsta` | `0` | Single-band uplink path |
| `cfg_master` | `0` | Not an ASUS mesh controller |
| `wlc_band` | `0` | 2.4 GHz uplink |
| `lan_proto` | `dhcp` | Obtain management addressing from the upstream LAN |
| `lan_dnsenable_x` | `1` | Automatic LAN DNS setting |
| `dhcp_enable_x` | `0` | Keep the repeater's DHCP server off |

The runtime wizard's Broadcom/AiMesh-capable branch selected this `sw_mode=3`, `wlc_psta=2` combination. Merely setting `sw_mode=2` was not the path used for the successful installation.

The uplink used WPA2-Personal (`psk2`) with AES. Copy its SSID and passphrase into `wlc_ssid` and `wlc_wpa_psk`. The selected band's downstream virtual interface is `wl0.1`; the other downstream band is `wl1`. Set both downstream SSIDs and passphrases to the upstream values for client-driven roaming. [Settings template](../examples/repeater-settings.json).

WPA3-only networks, enterprise authentication, captive portals, hidden-SSID behavior, and a 5 GHz uplink have not been validated.

## Authenticated settings API

The UI used these normal administration paths:

- `login.cgi`: base64-encoded `username:password` in `login_authorization`, with the returned `asus_token` session cookie preserved.
- `appGet.cgi?hook=...`: selected `nvram_get(NAME)` values and `get_ui_support()` capability data. Some variable names were unavailable through this API even when readable from the authenticated shell.
- `applyapp.cgi`: URL-encoded settings, `action_mode=apply`, and a service action such as `rc_service=reboot`.
- `chpass.cgi`: the account-change route on the tested build; use the normal account UI rather than assuming a settings write changes the account.

Before any write, identify the unit by its own hardware address and firmware version. When multiple repeaters share an SSID, network names alone do not identify which unit is being administered.

The JSON template is an API form-field reference, not a request ready to send: replace its placeholders and submit through an authenticated session as URL-encoded form data. It contains no live credentials. There is no automatic flasher or deployment program in this repository.

## Give every radio a distinct address

Both converted units initially reported the same 5 GHz address, `44:AA:15:00:00:04`. This was a firmware default observed on our units, not a unique identifier belonging to either household device. Their Ethernet and final 2.4 GHz addresses were different.

The second unit's address was changed to a unique locally administered unicast MAC. Relevant identifiers were:

| Identifier | Tested mapping |
| --- | --- |
| 5 GHz physical interface | `eth2` |
| Uplink radio interface | `eth1` |
| 5 GHz firmware variable | `wl1_hwaddr` |
| Underlying 5 GHz variable | `sb/1/macaddr` |

`nvram set` plus `nvram commit` alone did not keep the new radio address through the tested reboot. A startup hook in `/jffs/scripts/services-start` applied the address after services started. It sets the variables, brings the 5 GHz interface down, changes its current address, and brings the interface and BSS back up. The 2.4 GHz uplink is not the interface targeted by this correction.

Use [the script template](../scripts/services-start.sh). Edit `RADIO_MAC` to a distinct locally administered unicast MAC for each corrected unit, such as `02:00:00:00:60:01` for one and `02:00:00:00:60:02` for another. Those are examples, not assigned device identities. Check for conflicts on the intended LAN. The template refuses its unconfigured placeholder and addresses outside the locally administered unicast form.

The reusable template adds address validation and stops on a failed command. Its core `nvram`/`wl` sequence was run on hardware; the parameterized template and its validation were checked locally and were not newly deployed during repository creation.

Enable the firmware's JFFS custom-script support if it is not enabled. On our second unit, `jffs2_scripts` was already `1`. Inspect an existing `services-start` file before installing anything: preserve other owners' startup commands rather than overwriting them. Install the configured script as executable at `/jffs/scripts/services-start` and perform a reboot check. [Asuswrt-Merlin user-script documentation](https://github.com/Asuswrt-Merlin/asuswrt-merlin.ng/wiki/User-scripts).

The `services-start` hook runs at boot. Behavior after manually restarting only the wireless service remains unvalidated; inspect the actual driver address after wireless changes and reboot when needed. There can also be a startup interval before the hook applies the unique address. A cleaner early-boot fix or an upstream firmware correction remains future work.

## Verify the actual driver and network

These commands read the running radio state from an authenticated shell:

```sh
wl -i eth2 cur_etheraddr
wl -i eth2 bssid
wl -i eth2 ssid
wl -i wl0.1 ssid
wl -i eth1 bssid
nvram get lan_ipaddr
nvram get wlc_state
```

Our connected runtime returned `wlc_state=2`, and connectivity tests confirmed that state corresponded to a usable uplink on this build. Check the parent BSSID as well: the second unit selected the first repeater, even though `wlc_ap_mac` had been set to the original Starlink BSSID. That setting did not provide a demonstrated parent lock. Manual direct-join attempts did not establish a persistent direct-Starlink configuration.

After setup, remove temporary admin-computer addresses, stop temporary DHCP services, remove credential files, and disable the SSH access enabled for configuration. The MAC startup hook remains on the satellite. The operating repeaters need power and a usable wireless uplink; the Mac and its Ethernet cable are not their backhaul.

# Portability and public release

## What carries over

| Target | Assessment | What must change |
| --- | --- | --- |
| Another MS60 matching the tested image's board family | Promising; two units worked | Credentials, management address, radio identity, and image/board verification |
| Another Starlink Gen 3 router | Plausible repeat of the tested arrangement | Local SSID, WPA2 key, placement, and connectivity validation |
| Another upstream WPA2 access point | Engineering inference from ordinary repeater operation; untested | Validate association, DHCP bridging, addressing, and roaming |
| Another admin computer | Core method is not Mac-specific | Ethernet/Wi-Fi interface names and OS-specific setup/recovery commands |
| Another Nighthawk model | No image portability established | Separate firmware support, board/flash layout, drivers, and recovery validation |
| A native Starlink-managed mesh node | Not implemented | Accepted device identity and a compatible control-plane implementation |

The firmware image is hardware-specific. The useful portable material is the procedure, the operating-mode settings, the radio-address correction pattern, and the verification method. A newer upstream router alone does not make unrelated Nighthawk hardware compatible.

## Settings that must stay local

The site supplies its own SSID, WPA2 key, admin credentials, actual DHCP-assigned management addresses, per-unit radio addresses, and interface names. A reusable tool should take these from explicit local configuration, not a credential export. This repository uses placeholders and includes no credential discovery or guessing workflow.

A computer with Ethernet and Wi-Fi was enough for the demonstrated setup. The single-port WAN behavior on first custom boot makes an independent route to the setup Wi-Fi useful. The deployment used macOS for the directly attached adapter and Linux for orchestration. Other host operating systems were not tested here; nmrpflash's upstream project documents its own supported hosts.

## Limits relevant to deployment

The installed version was SWRT R5.1.9. The maintainer's current index lists MS60 5.2.9 as EOL and describes EOL updates as bug-driven because upstream ASUS maintenance ended. This project has not validated a newer build, current patch coverage, or a long-term support plan. [Maintainer index](https://blog.paldier.com/categories/firmware/).

Regional radio settings also need review before reproducing this elsewhere. A `wl1_country_code` read on the first converted unit returned `CN`; we did not validate or change regional settings, transmit-power limits, or all channel behavior. The firmware must not be assumed to select an appropriate region automatically.

The second node used the first as its parent. Additional wireless hops share airtime; no throughput, latency, or range benchmark was performed. Parent selection across simultaneous node reboots, recovery from a lost parent, and loop avoidance in a larger deployment remain untested. `wlc_ap_mac` did not reliably lock the parent in the observed setup.

One automatic client roam was observed. There is no measured handoff duration, reverse-direction roam test, phone-call continuity test, or cross-device roaming matrix. Public claims should say that roaming was observed, rather than promising seamless handoffs for every client.

## Used hardware prices

The cost hook is **roughly $30 used MS60 satellites**, not a guaranteed complete kit price. On November 15, 2026, an [eBay MS60 listing](https://www.ebay.com/itm/206252342084) displayed US $21.87 plus $6.95 shipping for the shown destination, totaling $28.82, without a power adapter. The [MS60 market page](https://www.ebay.com/shop/ms60-satellite?_nkw=ms60+satellite) also showed listings near $30 and above. Listings, shipping destinations, condition, and included adapters can change.

An [MS60 listing including a genuine OEM power adapter](https://www.ebay.com/itm/168839545882), inspected on the same date, displayed US $35.97 and free shipping for the shown US destination, before tax. Its seller described the unit as tested, working, and factory-reset. This is a concrete adapter-included example for an approximate $30–$40 used-hardware pitch.

Check the actual model label and power supply. Search results also include MR60 routers and other satellite models; those are not automatically substitutes for an MS60.

## Why publish the guide

There is a concrete reuse opportunity: inexpensive orphaned MS60 satellites can extend a tested Starlink installation without the original MR60. The guide can save other owners the failed password diagnoses, single-port setup confusion, and duplicate radio identity problem encountered here. The small scope makes it easier for another owner to reproduce and report their hardware and firmware versions.

## Public release scope

The public repository provides documentation, an interactive flashing walkthrough, and the original configuration script with upstream attribution. Firmware downloads remain at the maintainer's source. Upstream's repository contains GPL-licensed components; this project has not established redistribution terms for every component in the downloadable firmware image. This repository does not mirror that image or relicense third-party code. [Upstream license](https://raw.githubusercontent.com/SWRT-dev/asuswrt-bcm/master/License).

A turnkey firmware/installer release should wait for an independent same-model reproduction, a clearer revision matrix, a demonstrated rollback path from SWRT, and broader network recovery tests. Those are practical support gaps in the current evidence; the public field guide describes the tested procedure and its limits.

The copyable interest-check post leads with inexpensive Nighthawk MS60 satellites extending Starlink and identifies Gen 3 as the tested router. Share the [public repository](https://github.com/gjabdelnoor/ms60-starlink-repeater) for the guide and scripts. The text in `communications/twitter-draft.txt` is available for the owner to publish; this repository does not post to social media.

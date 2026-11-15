#!/bin/sh
# Uses the firmware's existing nvram and wl utilities. Edit RADIO_MAC per unit.
set -e

RADIO_MAC='REPLACE_WITH_UNIQUE_LOCAL_UNICAST_MAC'
RADIO_IFACE='eth2'

if ! printf '%s\n' "$RADIO_MAC" | grep -Eq '^[[:xdigit:]][26AaEe](:[[:xdigit:]]{2}){5}$'; then
    printf '%s\n' 'Set RADIO_MAC to a unique locally administered unicast MAC before installing.' >&2
    exit 1
fi

nvram set "sb/1/macaddr=$RADIO_MAC"
nvram set "wl1_hwaddr=$RADIO_MAC"
wl -i "$RADIO_IFACE" down
wl -i "$RADIO_IFACE" cur_etheraddr "$RADIO_MAC"
wl -i "$RADIO_IFACE" up
wl -i "$RADIO_IFACE" bss up
logger -t ms60-radio "Applied unique 5 GHz radio MAC $RADIO_MAC"

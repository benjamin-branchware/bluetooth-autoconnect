#!/bin/bash

set -euo pipefail

CONFIG_FILE="${HOME}/.config/bluetooth/autoconnect"

log_message() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - BTAutoconnect: $1"
}

if [ ! -r "$CONFIG_FILE" ]; then
	log_message "Configuration file $CONFIG_FILE not found or not readable. Exiting."
	exit 0
fi

if ! command -v bluetoothctl >/dev/null 2>&1; then
	log_message "bluetoothctl command not found. Please ensure bluex is installed."
	exit 1
fi

log_message "Starting Bluetooth autoconnect script..."

if ! bluetoothctl power on; then
	log_message "Warning: 'bluetoothctl power on' command failed. Adapter might not be available or already on."
fi

sleep 2

line_count=0
connection_attempts=0
while IFS= read -r mac_address || [ -n "$mac_address" ]; do
	line_count=$((line_count + 1))
	mac_address=$(echo "$mac_address" | awk '{$1=$1};1')

	if [ -z "$mac_address" ] || [[ "$mac_address" == \#* ]]; then
		continue
	fi

	log_message "Processing device: $mac_address from line $line_count"

	if bluetoothctl info "$mac_address" | grep -q "Connected: yes"; then
		log_message "Device $mac_address is already connected."
		continue
	fi

	log_message "Attempting to connect to $mac_address..."
	connection_attempts=$((connection_attempts + 1))
	echo "connect $mac_address" | bluetoothctl

	sleep 3

done < "$CONFIG_FILE"

if [ "$connection_attempts" -eq 0 ] && [ "$line_count" -gt 0 ]; then
	log_message "No valid, unconnected devices found to attempt connection."
fi
log_message "Bluetooth autoconnect script finished."
exit 0


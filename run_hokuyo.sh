#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/jazzy/setup.bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
script_path="$script_dir/$(basename -- "${BASH_SOURCE[0]}")"
device="/dev/serial/by-id/usb-Hokuyo_Data_Flex_for_USB_URG-Series_USB_Driver-if00"
launch_file="$script_dir/hokuyo_urg.launch.py"

if ! ros2 pkg prefix urg_node >/dev/null 2>&1; then
  echo "Missing ROS 2 driver package: ros-jazzy-urg-node"
  echo "Install it with: sudo apt update && sudo apt install -y ros-jazzy-urg-node"
  exit 1
fi

if [[ ! -e "$device" ]]; then
  echo "Hokuyo device was not found at: $device"
  echo "Unplug/replug the scanner and check: ls -l /dev/serial/by-id/"
  exit 1
fi

if [[ ! -r "$device" || ! -w "$device" ]]; then
  if [[ "${HOKUYO_DIALOUT_REEXEC:-0}" != "1" ]] &&
     groups "$USER" | tr ' ' '\n' | grep -qx 'dialout' &&
     command -v sg >/dev/null 2>&1; then
    echo "Current shell does not have active dialout permissions; re-running under dialout."
    printf -v reexec_cmd 'exec env HOKUYO_DIALOUT_REEXEC=1 %q' "$script_path"
    exec sg dialout -c "$reexec_cmd"
  fi

  echo "No read/write permission for: $device"
  ls -l "$device"
  echo "Do not run this script with sudo as the normal fix."
  echo "Use one of these options:"
  echo "  1. Permanent: log out and back in so the dialout group takes effect."
  echo "  2. Current terminal only: newgrp dialout"
  echo "  3. Temporary until the next unplug/replug: sudo setfacl -m u:$USER:rw /dev/ttyACM0"
  exit 1
fi

exec ros2 launch "$launch_file"

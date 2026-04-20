# Hokuyo URG ROS 2 Quick Start

Bring up the Hokuyo laser scanner with ROS 2 Jazzy.

The launch publishes `/scan` and a static TF:

```text
unitree_go1/trunk -> unitree_go1/laser
```

## 1. Install

Run once:

```bash
sudo apt update
sudo apt install -y ros-jazzy-urg-node
sudo usermod -aG dialout "$USER"
```

> [!IMPORTANT]
> Log out and back in after adding `dialout`.

If you do not want to log out yet, this is a temporary permission fix:

```bash
sudo setfacl -m u:"$USER":rw /dev/ttyACM0
```

## 2. Launch

Plug in the Hokuyo and run:

```bash
~/hokuyo_bringup/run_hokuyo.sh
```

Leave this terminal open.

The scanner is expected at:

```text
/dev/serial/by-id/usb-Hokuyo_Data_Flex_for_USB_URG-Series_USB_Driver-if00
```

## 3. Check ROS 2

Open another terminal:

```bash
source /opt/ros/jazzy/setup.bash
ros2 topic hz unitree_go1/scan
ros2 topic echo --once unitree_go1/scan
```

The scan message should have:

```text
header.frame_id: unitree_go1/laser
```

## 4. View In RViz

```bash
source /opt/ros/jazzy/setup.bash
rviz2
```

In RViz:

1. Set `Fixed Frame` to `unitree_go1/trunk`.
2. Add a `LaserScan` display.
3. Set the LaserScan topic to `unitree_go1/scan`.

## Notes

> [!WARNING]
> Do not run `run_hokuyo.sh` with `sudo`.

> [!NOTE]
> If permissions fail after unplugging and replugging, run
> `~/hokuyo_bringup/run_hokuyo.sh` again. The script tries to re-run itself
> under `dialout` automatically when your user is already in that group.

Stop the scanner with `Ctrl+C` in the launch terminal.

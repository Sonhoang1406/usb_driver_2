#!/bin/bash
# Script to load the driver

echo "Loading USB Keyboard Remap Driver..."

# Check if driver is already loaded
if lsmod | grep -q usb_kbd_remap; then
    echo "Driver is already loaded. Unloading first..."
    ./unload_driver.sh
fi

# Load the driver
sudo insmod usb_kbd_remap.ko

# Verify loading
if [ $? -eq 0 ]; then
    echo "Driver loaded successfully!"
    dmesg | tail -n 5 | grep usb_kbd_remap
else
    echo "Failed to load driver!"
    exit 1
fi

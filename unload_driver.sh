#!/bin/bash
# Script to unload the driver

echo "Unloading USB Keyboard Remap Driver..."

if lsmod | grep -q usb_kbd_remap; then
    sudo rmmod usb_kbd_remap
    echo "Driver unloaded successfully!"
    dmesg | tail -n 3 | grep usb_kbd_remap
else
    echo "Driver is not currently loaded."
fi

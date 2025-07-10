#!/bin/bash
# Script to build the driver

echo "Building USB Keyboard Remap Driver..."
make clean
make

if [ $? -eq 0 ]; then
    echo "Driver built successfully!"
    ls -lh usb_kbd_remap.ko
else
    echo "Failed to build driver!"
    exit 1
fi

#!/bin/bash
# Script to load the USB keyboard driver for CentOS 6 32-bit

echo "========================================"
echo "USB Keyboard Remap Driver Loader"
echo "Target: CentOS 6 32-bit"
echo "========================================"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run with sudo privileges"
    echo "Usage: sudo ./load_driver.sh"
    exit 1
fi

# Check if driver file exists
if [ ! -f usb_kbd_remap.ko ]; then
    echo "ERROR: Driver file usb_kbd_remap.ko not found!"
    echo "Please build the driver first:"
    echo "  ./build_driver.sh"
    exit 1
fi

echo "Checking system information..."
echo "Kernel version: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Driver file: $(ls -lh usb_kbd_remap.ko | awk '{print $5}')"
echo ""

# Check if driver is already loaded
echo "Checking if driver is already loaded..."
if lsmod | grep -q usb_kbd_remap; then
    echo "Driver is already loaded. Unloading first..."
    ./unload_driver.sh
    sleep 2
fi

# Check for target USB keyboard
echo "Checking for target USB keyboard (VID:0461 PID:4e8e)..."
USB_DEVICE=$(lsusb | grep "0461:4e8e")
if [ -n "$USB_DEVICE" ]; then
    echo "Found target keyboard: $USB_DEVICE"
else
    echo "Warning: Target USB keyboard not found"
    echo "The driver will still load but won't be active until keyboard is connected"
    echo "Expected device: VID:0461 PID:4e8e (HP USB Keyboard)"
fi
echo ""

# Load the driver
echo "Loading USB Keyboard Remap Driver..."
insmod usb_kbd_remap.ko

# Check if loading was successful
if [ $? -eq 0 ]; then
    echo "Driver loading command executed successfully!"
    
    # Verify driver is actually loaded
    sleep 1
    if lsmod | grep -q usb_kbd_remap; then
        echo ""
        echo "========================================"
        echo "Driver loaded successfully!"
        echo "========================================"
        
        # Show driver information
        echo "Driver status:"
        lsmod | grep usb_kbd_remap
        echo ""
        
        # Show recent kernel messages
        echo "Recent kernel messages:"
        dmesg | tail -n 10 | grep usb_kbd_remap
        echo ""
        
        # Show key mappings
        echo "Active key mappings:"
        echo "  A -> H"
        echo "  B -> C"
        echo "  Q -> E"
        echo "  E -> T"
        echo "  T -> U"
        echo "  I -> P"
        echo "  P -> K"
        echo ""
        
        echo "Next steps:"
        echo "1. Test the driver: ./test_driver.sh"
        echo "2. Open a text editor and try typing the mapped keys"
        echo "3. Monitor logs: sudo dmesg -w | grep usb_kbd_remap"
        echo "========================================"
    else
        echo ""
        echo "ERROR: Driver loading failed - not found in module list"
        echo "Check dmesg for error messages:"
        dmesg | tail -n 5
        exit 1
    fi
else
    echo ""
    echo "========================================"
    echo "Driver loading failed!"
    echo "========================================"
    echo "Error code: $?"
    echo ""
    echo "Recent kernel messages:"
    dmesg | tail -n 5
    echo ""
    echo "Common issues and solutions:"
    echo "1. Module version mismatch:"
    echo "   Rebuild driver: ./build_driver.sh"
    echo ""
    echo "2. Missing dependencies:"
    echo "   Check: modinfo usb_kbd_remap.ko"
    echo ""
    echo "3. SELinux blocking module:"
    echo "   Temporarily disable: sudo setenforce 0"
    echo ""
    echo "4. Check dmesg for detailed error messages:"
    echo "   dmesg | grep -i error | tail -n 10"
    echo "========================================"
    exit 1
fi

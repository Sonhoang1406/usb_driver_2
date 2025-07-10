#!/bin/bash
# Script to unload the USB keyboard driver for CentOS 6 32-bit

echo "========================================"
echo "USB Keyboard Remap Driver Unloader"
echo "Target: CentOS 6 32-bit"
echo "========================================"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run with sudo privileges"
    echo "Usage: sudo ./unload_driver.sh"
    exit 1
fi

echo "Checking driver status..."

# Check if driver is loaded
if lsmod | grep -q usb_kbd_remap; then
    echo "Driver is currently loaded"
    
    # Show current driver info
    echo "Current driver status:"
    lsmod | grep usb_kbd_remap
    echo ""
    
    # Unload the driver
    echo "Unloading USB Keyboard Remap Driver..."
    rmmod usb_kbd_remap
    
    # Check if unloading was successful
    if [ $? -eq 0 ]; then
        # Verify driver is actually unloaded
        sleep 1
        if ! lsmod | grep -q usb_kbd_remap; then
            echo ""
            echo "========================================"
            echo "Driver unloaded successfully!"
            echo "========================================"
            
            # Show recent kernel messages
            echo "Recent kernel messages:"
            dmesg | tail -n 5 | grep usb_kbd_remap
            echo ""
            
            echo "Keyboard should now function normally"
            echo "To reload driver: sudo ./load_driver.sh"
            echo "========================================"
        else
            echo ""
            echo "ERROR: Driver unloading failed - still found in module list"
            echo "Driver may still be in use"
            echo ""
            echo "Try to force unload:"
            echo "  sudo rmmod -f usb_kbd_remap"
            echo ""
            echo "Or check what's using the module:"
            echo "  lsof | grep usb_kbd_remap"
            exit 1
        fi
    else
        echo ""
        echo "========================================"
        echo "Driver unloading failed!"
        echo "========================================"
        echo "Error code: $?"
        echo ""
        echo "Recent kernel messages:"
        dmesg | tail -n 5
        echo ""
        echo "Common issues and solutions:"
        echo "1. Module is busy (in use):"
        echo "   Disconnect USB keyboard and try again"
        echo "   Or force unload: sudo rmmod -f usb_kbd_remap"
        echo ""
        echo "2. SELinux restrictions:"
        echo "   Check: sudo sealert -a /var/log/audit/audit.log"
        echo ""
        echo "3. Check processes using the module:"
        echo "   lsof | grep usb_kbd_remap"
        echo "========================================"
        exit 1
    fi
else
    echo "Driver is not currently loaded"
    echo ""
    echo "Current loaded modules related to HID/USB:"
    lsmod | grep -E "(hid|usb)" | head -5
    echo ""
    echo "To load driver: sudo ./load_driver.sh"
fi

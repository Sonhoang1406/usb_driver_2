#!/bin/bash
# Script to build the USB keyboard driver for CentOS 6 32-bit

echo "========================================"
echo "USB Keyboard Remap Driver Builder"
echo "Target: CentOS 6 32-bit"
echo "========================================"

# Check if running on CentOS 6
if [ -f /etc/redhat-release ]; then
    VERSION=$(cat /etc/redhat-release)
    echo "Detected OS: $VERSION"
else
    echo "Warning: Cannot detect CentOS version"
fi

# Check dependencies first
echo "Checking build dependencies..."
make check-deps
if [ $? -ne 0 ]; then
    echo "Dependencies check failed!"
    echo "Please install required packages:"
    echo "  sudo yum groupinstall 'Development Tools'"
    echo "  sudo yum install kernel-devel-\$(uname -r)"
    exit 1
fi

echo "Dependencies satisfied!"
echo ""

# Display build information
echo "Build Information:"
make info
echo ""

# Clean previous build
echo "Cleaning previous build..."
make clean

# Build the driver
echo "Building USB Keyboard Remap Driver..."
make

# Check build result
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build completed successfully!"
    echo "========================================"
    echo "Driver file details:"
    if [ -f usb_kbd_remap.ko ]; then
        ls -lh usb_kbd_remap.ko
        echo ""
        echo "File info:"
        file usb_kbd_remap.ko
        echo ""
        echo "Module info:"
        modinfo usb_kbd_remap.ko 2>/dev/null || echo "Module info not available"
    else
        echo "ERROR: Driver file usb_kbd_remap.ko not found!"
        exit 1
    fi
    echo ""
    echo "Next steps:"
    echo "1. Load the driver: sudo ./load_driver.sh"
    echo "2. Test the driver: ./test_driver.sh"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "Build failed!"
    echo "========================================"
    echo "Common issues and solutions:"
    echo "1. Missing kernel headers:"
    echo "   sudo yum install kernel-devel-\$(uname -r)"
    echo ""
    echo "2. Missing development tools:"
    echo "   sudo yum groupinstall 'Development Tools'"
    echo ""
    echo "3. Wrong architecture (should be 32-bit):"
    echo "   Check: uname -m (should show i686 or i386)"
    echo ""
    echo "4. Check error messages above for specific issues"
    echo "========================================"
    exit 1
fi

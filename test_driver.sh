#!/bin/bash
# Script to test the USB keyboard driver for CentOS 6 32-bit

echo "========================================"
echo "USB Keyboard Remap Driver Tester"
echo "Target: CentOS 6 32-bit"
echo "========================================"

# Function to show current system info
show_system_info() {
    echo "System Information:"
    echo "  OS: $(cat /etc/redhat-release 2>/dev/null || echo 'Unknown')"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Date: $(date)"
    echo ""
}

# Function to check USB keyboard
check_usb_keyboard() {
    echo "USB Keyboard Detection:"
    USB_DEVICE=$(lsusb | grep "0461:4e8e")
    if [ -n "$USB_DEVICE" ]; then
        echo "  ✓ Target keyboard found: $USB_DEVICE"
        return 0
    else
        echo "  ✗ Target USB keyboard NOT found (VID:0461 PID:4e8e)"
        echo "  Available USB devices:"
        lsusb | grep -i keyboard | head -3
        return 1
    fi
}

# Function to check driver status
check_driver_status() {
    echo "Driver Status Check:"
    if lsmod | grep -q usb_kbd_remap; then
        echo "  ✓ Driver is loaded"
        lsmod | grep usb_kbd_remap
        return 0
    else
        echo "  ✗ Driver is NOT loaded"
        return 1
    fi
}

# Function to load driver if needed
load_driver_if_needed() {
    if ! lsmod | grep -q usb_kbd_remap; then
        echo ""
        echo "Driver not loaded. Loading now..."
        sudo ./load_driver.sh
        if [ $? -ne 0 ]; then
            echo "Failed to load driver!"
            return 1
        fi
    fi
    return 0
}

# Function to show key mappings
show_key_mappings() {
    echo "Active Key Mappings:"
    echo "  Original Key → Mapped Key"
    echo "  ─────────────────────────"
    echo "  A           → H"
    echo "  B           → C"
    echo "  Q           → E"
    echo "  E           → T"
    echo "  T           → U"
    echo "  I           → P"
    echo "  P           → K"
    echo "  (Other keys work normally)"
}

# Function to monitor kernel logs
monitor_logs() {
    echo ""
    echo "Recent kernel messages from driver:"
    echo "──────────────────────────────────────"
    dmesg | grep usb_kbd_remap | tail -n 10
    echo "──────────────────────────────────────"
}

# Function to show testing instructions
show_test_instructions() {
    echo ""
    echo "========================================"
    echo "MANUAL TESTING INSTRUCTIONS"
    echo "========================================"
    echo ""
    echo "1. Open a text editor:"
    echo "   - GUI: gedit (if available) or mousepad"
    echo "   - Terminal: nano test_output.txt"
    echo ""
    echo "2. Test each mapped key:"
    echo "   Type 'A' → Should output 'H'"
    echo "   Type 'B' → Should output 'C'"
    echo "   Type 'Q' → Should output 'E'"
    echo "   Type 'E' → Should output 'T'"
    echo "   Type 'T' → Should output 'U'"
    echo "   Type 'I' → Should output 'P'"
    echo "   Type 'P' → Should output 'K'"
    echo ""
    echo "3. Test normal keys:"
    echo "   Type 'X', 'Y', 'Z' → Should output normally"
    echo "   Type numbers 1-9 → Should output normally"
    echo ""
    echo "4. Test combinations:"
    echo "   Try Shift+A, Ctrl+A, etc."
    echo ""
    echo "5. Monitor driver activity:"
    echo "   Open another terminal and run:"
    echo "   sudo dmesg -w | grep usb_kbd_remap"
    echo ""
    echo "========================================"
}

# Function to start log monitoring
start_log_monitoring() {
    echo ""
    echo "Log Monitoring Options:"
    echo "1. View recent logs only"
    echo "2. Start real-time monitoring (Ctrl+C to stop)"
    echo "3. Skip log monitoring"
    echo ""
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            echo ""
            echo "Recent driver logs:"
            dmesg | grep usb_kbd_remap | tail -n 15
            ;;
        2)
            echo ""
            echo "Starting real-time log monitoring..."
            echo "Press Ctrl+C to stop monitoring"
            echo "Try typing the mapped keys now..."
            sleep 2
            dmesg -w | grep usb_kbd_remap
            ;;
        3)
            echo "Skipping log monitoring"
            ;;
        *)
            echo "Invalid choice, skipping log monitoring"
            ;;
    esac
}

# Main testing sequence
main() {
    show_system_info
    check_usb_keyboard
    USB_OK=$?
    
    echo ""
    check_driver_status
    DRIVER_OK=$?
    
    if [ $DRIVER_OK -ne 0 ]; then
        echo ""
        echo "Attempting to load driver..."
        load_driver_if_needed
        if [ $? -ne 0 ]; then
            echo "Cannot continue testing without driver loaded"
            exit 1
        fi
    fi
    
    echo ""
    show_key_mappings
    monitor_logs
    
    if [ $USB_OK -ne 0 ]; then
        echo ""
        echo "WARNING: Target USB keyboard not detected!"
        echo "Driver is loaded but may not be active."
        echo "Please connect the HP USB Keyboard (VID:0461 PID:4e8e)"
        echo ""
    fi
    
    show_test_instructions
    start_log_monitoring
    
    echo ""
    echo "========================================"
    echo "Testing completed!"
    echo ""
    echo "If remapping is not working:"
    echo "1. Check if correct keyboard is connected"
    echo "2. Restart the driver: sudo ./unload_driver.sh && sudo ./load_driver.sh"
    echo "3. Check SELinux: sudo setenforce 0 (temporarily)"
    echo "4. Check kernel logs: dmesg | grep usb_kbd_remap"
    echo "========================================"
}

# Run main function
main

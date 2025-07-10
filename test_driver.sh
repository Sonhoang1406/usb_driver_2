#!/bin/bash
# Script to test the driver

echo "Testing USB Keyboard Remap Driver..."

echo "1. Make sure the driver is loaded:"
./load_driver.sh

echo ""
echo "2. Current keyboard mappings:"
echo "   A -> H"
echo "   B -> C"
echo "   Q -> E"
echo "   E -> T"
echo "   T -> U"
echo "   I -> P"
echo "   P -> K"
echo ""
echo "3. Open a text editor and try typing:"
echo "   - Press 'A' key - it should output 'H'"
echo "   - Press 'B' key - it should output 'C'"
echo "   - Press 'Q' key - it should output 'E'"
echo "   - Press 'E' key - it should output 'T'"
echo "   - Press 'T' key - it should output 'U'"
echo "   - Press 'I' key - it should output 'P'"
echo "   - Press 'P' key - it should output 'K'"
echo "   - Other keys should work normally"
echo ""
echo "4. Check kernel logs for driver activity:"
dmesg | grep usb_kbd_remap | tail -n 10

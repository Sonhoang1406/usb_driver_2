// usb_kbd_remap.c - USB keyboard remapping driver for CentOS 6 32-bit
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/hid.h>
#include <linux/input.h>
#include <linux/slab.h>
#include <linux/version.h>

#define DRIVER_AUTHOR "You <you@example.com>"
#define DRIVER_DESC "USB Keyboard Remap Driver for HP USB Keyboard (CentOS 6 32-bit)"
#define DRIVER_VERSION "1.0-centos6"

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_VERSION(DRIVER_VERSION);
MODULE_LICENSE("GPL");

// Vendor and Product IDs for your specific keyboard
#define VENDOR_ID 0x0461
#define PRODUCT_ID 0x4e8e

// Safe key remapping table - initialized to pass-through by default
static unsigned char remap_table[256] = {0};

// Module parameters for CentOS 6 compatibility
static unsigned int map_from_key = 30;  // KEY_A in CentOS 6
static unsigned int map_to_key = 35;    // KEY_H in CentOS 6
static unsigned int map_from_key2 = 48; // KEY_B
static unsigned int map_to_key2 = 46;   // KEY_C
static unsigned int map_from_key3 = 16; // KEY_Q
static unsigned int map_to_key3 = 18;   // KEY_E
static unsigned int map_from_key4 = 18; // KEY_E
static unsigned int map_to_key4 = 20;   // KEY_T
static unsigned int map_from_key5 = 20; // KEY_T
static unsigned int map_to_key5 = 22;   // KEY_U
static unsigned int map_from_key6 = 23; // KEY_I
static unsigned int map_to_key6 = 25;   // KEY_P
static unsigned int map_from_key7 = 25; // KEY_P
static unsigned int map_to_key7 = 37;   // KEY_K

// CentOS 6 compatible module parameter declarations
module_param(map_from_key, uint, 0444);
MODULE_PARM_DESC(map_from_key, "Key code to remap from (default: KEY_A)");
module_param(map_to_key, uint, 0444);
MODULE_PARM_DESC(map_to_key, "Key code to remap to (default: KEY_H)");
module_param(map_from_key2, uint, 0444);
MODULE_PARM_DESC(map_from_key2, "Second key code to remap from (default: KEY_B)");
module_param(map_to_key2, uint, 0444);
MODULE_PARM_DESC(map_to_key2, "Second key code to remap to (default: KEY_C)");
module_param(map_from_key3, uint, 0444);
MODULE_PARM_DESC(map_from_key3, "Third key code to remap from (default: KEY_Q)");
module_param(map_to_key3, uint, 0444);
MODULE_PARM_DESC(map_to_key3, "Third key code to remap to (default: KEY_E)");
module_param(map_from_key4, uint, 0444);
MODULE_PARM_DESC(map_from_key4, "Fourth key code to remap from (default: KEY_E)");
module_param(map_to_key4, uint, 0444);
MODULE_PARM_DESC(map_to_key4, "Fourth key code to remap to (default: KEY_T)");
module_param(map_from_key5, uint, 0444);
MODULE_PARM_DESC(map_from_key5, "Fifth key code to remap from (default: KEY_T)");
module_param(map_to_key5, uint, 0444);
MODULE_PARM_DESC(map_to_key5, "Fifth key code to remap to (default: KEY_U)");
module_param(map_from_key6, uint, 0444);
MODULE_PARM_DESC(map_from_key6, "Sixth key code to remap from (default: KEY_I)");
module_param(map_to_key6, uint, 0444);
MODULE_PARM_DESC(map_to_key6, "Sixth key code to remap to (default: KEY_P)");
module_param(map_from_key7, uint, 0444);
MODULE_PARM_DESC(map_from_key7, "Seventh key code to remap from (default: KEY_P)");
module_param(map_to_key7, uint, 0444);
MODULE_PARM_DESC(map_to_key7, "Seventh key code to remap to (default: KEY_K)");

// USB HID keyboard scan codes to Linux input codes mapping for CentOS 6
static const unsigned char usb_kbd_keycode[256] = {
    0, 0, 0, 0, 30, 48, 46, 32, 18, 33, 34, 35, 23, 36, 37, 38,   // 0x00-0x0F
    50, 49, 24, 25, 16, 19, 31, 20, 22, 47, 17, 45, 21, 44, 0, 0, // 0x10-0x1F
    58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 87, 88, 0, 0, 0,  // 0x20-0x2F
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,               // 0x30-0x3F
};

// Linux input codes to USB HID keyboard scan codes mapping for CentOS 6
static const unsigned char linux_to_usb[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,                                                 // 0x00-0x0F
    0x14, 0x1a, 0x08, 0x15, 0x17, 0x1c, 0x18, 0x0c, 0x12, 0x13, 0x2f, 0x30, 0x31, 0x28, 0x04, 0x16, // 0x10-0x1F
    0x07, 0x09, 0x0a, 0x0b, 0x0d, 0x0e, 0x0f, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x1e, 0x1f, 0x20, // 0x20-0x2F
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x2d, 0x2e, 0x2a, 0x2b, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, // 0x30-0x3F
    0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, // 0x40-0x4F
    0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, // 0x50-0x5F
};

// Initialize the remap table
static void init_remap_table(void)
{
    int i;

    // Initialize all keys to pass through by default
    for (i = 0; i < 256; i++)
    {
        remap_table[i] = i;
    }

    // Configure specific remappings from module parameters
    if (map_from_key < 256)
        remap_table[map_from_key] = map_to_key;
    if (map_from_key2 < 256)
        remap_table[map_from_key2] = map_to_key2;
    if (map_from_key3 < 256)
        remap_table[map_from_key3] = map_to_key3;
    if (map_from_key4 < 256)
        remap_table[map_from_key4] = map_to_key4;
    if (map_from_key5 < 256)
        remap_table[map_from_key5] = map_to_key5;
    if (map_from_key6 < 256)
        remap_table[map_from_key6] = map_to_key6;
    if (map_from_key7 < 256)
        remap_table[map_from_key7] = map_to_key7;

    printk(KERN_INFO "usb_kbd_remap: Key remapping table initialized for CentOS 6 32-bit\n");
    printk(KERN_INFO "usb_kbd_remap: Remapping %u->%u, %u->%u, %u->%u, %u->%u, %u->%u, %u->%u, %u->%u\n",
           map_from_key, map_to_key, map_from_key2, map_to_key2,
           map_from_key3, map_to_key3, map_from_key4, map_to_key4,
           map_from_key5, map_to_key5, map_from_key6, map_to_key6,
           map_from_key7, map_to_key7);
}

// Input event handler - compatible with CentOS 6
static int kbd_input_event(struct input_dev *dev, unsigned int type,
                           unsigned int code, int value)
{
    if (type == EV_KEY && code < 256 && remap_table[code] != code)
    {
        printk(KERN_DEBUG "usb_kbd_remap: Remapping key %d to %d, value=%d\n",
               code, remap_table[code], value);
        input_event(dev, type, remap_table[code], value);
        input_sync(dev); // Ensure event is processed
        return 1;        // We've handled this event
    }

    // Pass through all other events
    return 0;
}

// HID raw event handler - CentOS 6 compatible
static int kbd_raw_event(struct hid_device *hdev, struct hid_report *report,
                         u8 *data, int size)
{
    // Check for keyboard usage page and key press/release
    if (report->type == HID_INPUT_REPORT && size >= 3)
    {
        int i;
        bool modified = false;

// Debug: print the report (only if debugging enabled)
#ifdef DEBUG
        printk(KERN_DEBUG "usb_kbd_remap: HID report received, size=%d, data=", size);
        for (i = 0; i < size; i++)
        {
            printk(KERN_CONT "%02x ", data[i]);
        }
        printk(KERN_CONT "\n");
#endif

        // Scan for regular keys - bytes 2-7 in standard boot protocol
        for (i = 2; i < 8 && i < size; i++)
        {
            u8 key_code = data[i];

            // Skip if it's 0 (no key) or 1 (error)
            if (key_code > 1)
            {
                // Direct mapping for A to H (0x04 to 0x0B)
                if (key_code == 0x04)
                { // 'A' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping A(0x04) to H(0x0B)\n");
                    data[i] = 0x0B; // 'H' key in USB HID
                    modified = true;
                }
                // Direct mapping for B to C (0x05 to 0x06)
                else if (key_code == 0x05)
                { // 'B' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping B(0x05) to C(0x06)\n");
                    data[i] = 0x06; // 'C' key in USB HID
                    modified = true;
                }
                // Direct mapping for Q to E (0x14 to 0x08)
                else if (key_code == 0x14)
                { // 'Q' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping Q(0x14) to E(0x08)\n");
                    data[i] = 0x08; // 'E' key in USB HID
                    modified = true;
                }
                // Direct mapping for E to T (0x08 to 0x17)
                else if (key_code == 0x08)
                { // 'E' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping E(0x08) to T(0x17)\n");
                    data[i] = 0x17; // 'T' key in USB HID
                    modified = true;
                }
                // Direct mapping for T to U (0x17 to 0x18)
                else if (key_code == 0x17)
                { // 'T' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping T(0x17) to U(0x18)\n");
                    data[i] = 0x18; // 'U' key in USB HID
                    modified = true;
                }
                // Direct mapping for I to P (0x0C to 0x13)
                else if (key_code == 0x0C)
                { // 'I' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping I(0x0C) to P(0x13)\n");
                    data[i] = 0x13; // 'P' key in USB HID
                    modified = true;
                }
                // Direct mapping for P to K (0x13 to 0x0E)
                else if (key_code == 0x13)
                { // 'P' key in USB HID
                    printk(KERN_DEBUG "usb_kbd_remap: Remapping P(0x13) to K(0x0E)\n");
                    data[i] = 0x0E; // 'K' key in USB HID
                    modified = true;
                }
            }
        }

        if (modified)
        {
            printk(KERN_DEBUG "usb_kbd_remap: HID report modified\n");
        }
    }

    return 0; // Continue processing
}

// HID probe function - CentOS 6 compatible
static int kbd_probe(struct hid_device *hdev, const struct hid_device_id *id)
{
    struct hid_input *hidinput;
    struct input_dev *input;
    int ret;

    printk(KERN_INFO "usb_kbd_remap: Probing device %s VID:%04x PID:%04x\n",
           hdev->name ? hdev->name : "Unknown", hdev->vendor, hdev->product);

    // Check if this is our target keyboard
    if (hdev->vendor != VENDOR_ID || hdev->product != PRODUCT_ID)
    {
        printk(KERN_INFO "usb_kbd_remap: Not our target device, skipping\n");
        return -ENODEV; // Let default driver handle it
    }

    ret = hid_parse(hdev);
    if (ret)
    {
        printk(KERN_ERR "usb_kbd_remap: parse failed\n");
        return ret;
    }

    ret = hid_hw_start(hdev, HID_CONNECT_DEFAULT);
    if (ret)
    {
        printk(KERN_ERR "usb_kbd_remap: hw start failed\n");
        return ret;
    }

    // For CentOS 6, we need to iterate through inputs differently
    list_for_each_entry(hidinput, &hdev->inputs, list)
    {
        input = hidinput->input;
        if (input)
        {
            // Replace the event handler for our specific keyboard
            printk(KERN_INFO "usb_kbd_remap: Attaching to input device %s\n",
                   input->name ? input->name : "Unknown");
            input->event = kbd_input_event;
            printk(KERN_INFO "usb_kbd_remap: Event handler attached successfully\n");
        }
    }

    return 0;
}

static void kbd_remove(struct hid_device *hdev)
{
    printk(KERN_INFO "usb_kbd_remap: Removing device %s\n",
           hdev->name ? hdev->name : "Unknown");
    hid_hw_stop(hdev);
    printk(KERN_INFO "usb_kbd_remap: Device removed\n");
}

// CentOS 6 compatible device table
static struct hid_device_id kbd_table[] = {
    {HID_USB_DEVICE(VENDOR_ID, PRODUCT_ID)}, // Only for your specific keyboard
    {}};
MODULE_DEVICE_TABLE(hid, kbd_table);

// CentOS 6 compatible driver structure
static struct hid_driver kbd_driver = {
    .name = "usb_kbd_remap",
    .id_table = kbd_table,
    .probe = kbd_probe,
    .remove = kbd_remove,
    .raw_event = kbd_raw_event,
};

static int __init kbd_init(void)
{
    int ret;

    printk(KERN_INFO "usb_kbd_remap: Initializing driver for CentOS 6 32-bit\n");
    printk(KERN_INFO "usb_kbd_remap: Target device %04x:%04x\n",
           VENDOR_ID, PRODUCT_ID);
    printk(KERN_INFO "usb_kbd_remap: Kernel version: %s\n", UTS_RELEASE);

    // Initialize remapping table
    init_remap_table();

    ret = hid_register_driver(&kbd_driver);
    if (ret)
    {
        printk(KERN_ERR "usb_kbd_remap: Failed to register driver: %d\n", ret);
    }
    else
    {
        printk(KERN_INFO "usb_kbd_remap: Driver registered successfully\n");
    }

    return ret;
}

static void __exit kbd_exit(void)
{
    printk(KERN_INFO "usb_kbd_remap: Unloading driver\n");
    hid_unregister_driver(&kbd_driver);
    printk(KERN_INFO "usb_kbd_remap: Driver unloaded successfully\n");
}

module_init(kbd_init);
module_exit(kbd_exit);

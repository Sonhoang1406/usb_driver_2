# USB Keyboard Remap Driver - CentOS 6 32-bit

## 📋 Mô tả dự án

Driver Linux kernel module để remap phím bàn phím USB HP (VID: 0x0461, PID: 0x4e8e) trên CentOS 6 32-bit. Driver này cho phép thay đổi hành vi của các phím cụ thể mà không cần phần mềm bên ngoài.

## 🔧 Key Mappings hiện tại

| Phím gốc | Phím được map | USB HID Code |
| -------- | ------------- | ------------ |
| **A**    | **H**         | 0x04 → 0x0B  |
| **B**    | **C**         | 0x05 → 0x06  |
| **Q**    | **E**         | 0x14 → 0x08  |
| **E**    | **T**         | 0x08 → 0x17  |
| **T**    | **U**         | 0x17 → 0x18  |
| **I**    | **P**         | 0x0C → 0x13  |
| **P**    | **K**         | 0x13 → 0x0E  |

_Các phím khác hoạt động bình thường_

## 🏗️ Cấu trúc dự án

```
usb_driver_2/
├── usb_kbd_remap.c      # Mã nguồn driver chính (CentOS 6 compatible)
├── Makefile             # Build file với 32-bit flags
├── build_driver.sh      # Script build driver
├── load_driver.sh       # Script load driver (yêu cầu sudo)
├── unload_driver.sh     # Script unload driver (yêu cầu sudo)
├── test_driver.sh       # Script test driver
└── README.md            # Tài liệu này
```

## 🔧 Yêu cầu hệ thống

### 1. Hệ điều hành

- **CentOS 6** (32-bit)
- Kernel 2.6.32-x (compatible)
- Architecture: i386/i686

### 2. Kiểm tra hệ thống hiện tại

```bash
# Kiểm tra OS version
cat /etc/redhat-release
# Kết quả mong đợi: CentOS release 6.x (Final)

# Kiểm tra kernel version
uname -r
# Kết quả mong đợi: 2.6.32-xxx.el6.i686

# Kiểm tra architecture (phải là 32-bit)
uname -m
# Kết quả mong đợi: i686 hoặc i386
```

### 3. Cài đặt dependencies

#### 3.1 Development Tools

```bash
# Cài đặt Development Tools (bắt buộc)
sudo yum groupinstall "Development Tools"

# Kiểm tra GCC
gcc --version
# Kết quả mong đợi: gcc version 4.4.7 hoặc tương thích

# Kiểm tra Make
make --version
# Kết quả mong đợi: GNU Make 3.81 hoặc tương thích
```

#### 3.2 Kernel Headers

```bash
# Cài đặt kernel headers cho kernel hiện tại
sudo yum install kernel-devel-$(uname -r)

# Nếu package không tồn tại, thử:
sudo yum install kernel-devel

# Kiểm tra kernel headers
ls -la /lib/modules/$(uname -r)/build/
# Phải có thư mục này với các file headers
```

#### 3.3 Kiểm tra USB keyboard

```bash
# Kiểm tra thiết bị USB
lsusb

# Tìm bàn phím HP cụ thể
lsusb | grep "0461:4e8e"
# Kết quả mong đợi: Bus xxx Device xxx: ID 0461:4e8e xxx
```

## 🚀 Hướng dẫn sử dụng từng bước

### Bước 1: Chuẩn bị môi trường

```bash
# Di chuyển vào thư mục dự án
cd /path/to/usb_driver_2

# Kiểm tra các file
ls -la

# Cấp quyền thực thi cho scripts
chmod +x *.sh

# Kiểm tra dependencies
make check-deps
```

### Bước 2: Build Driver

```bash
# Build driver (khuyến nghị)
./build_driver.sh

# Hoặc build thủ công
make clean
make

# Build với debug mode (nếu cần troubleshoot)
make debug
```

**Kết quả mong đợi:**

```
========================================
Build completed successfully!
========================================
Driver file details:
-rw-r--r-- 1 user user 15K Oct XX XX:XX usb_kbd_remap.ko

File info:
usb_kbd_remap.ko: ELF 32-bit LSB relocatable, Intel 80386, version 1

Module info:
filename:       usb_kbd_remap.ko
version:        1.0-centos6
description:    USB Keyboard Remap Driver for HP USB Keyboard (CentOS 6 32-bit)
author:         You <you@example.com>
license:        GPL
```

### Bước 3: Load Driver

```bash
# Load driver (yêu cầu sudo)
sudo ./load_driver.sh
```

**Kết quả mong đợi:**

```
========================================
Driver loaded successfully!
========================================
Driver status:
usb_kbd_remap          XXXX  0

Recent kernel messages:
usb_kbd_remap: Initializing driver for CentOS 6 32-bit
usb_kbd_remap: Target device 0461:4e8e
usb_kbd_remap: Key remapping table initialized for CentOS 6 32-bit
usb_kbd_remap: Driver registered successfully
```

### Bước 4: Test Driver

```bash
# Chạy test script
./test_driver.sh
```

**Tính năng của test script:**

- Kiểm tra system info
- Phát hiện USB keyboard
- Kiểm tra driver status
- Hiển thị key mappings
- Hướng dẫn test manual
- Monitoring logs real-time

### Bước 5: Test thực tế

#### 5.1 Test cơ bản

```bash
# Mở text editor
nano test_output.txt

# Hoặc GUI editor (nếu có)
gedit &
```

#### 5.2 Test từng phím

1. **Test A → H**: Bấm `A`, kết quả: `H`
2. **Test B → C**: Bấm `B`, kết quả: `C`
3. **Test Q → E**: Bấm `Q`, kết quả: `E`
4. **Test E → T**: Bấm `E`, kết quả: `T`
5. **Test T → U**: Bấm `T`, kết quả: `U`
6. **Test I → P**: Bấm `I`, kết quả: `P`
7. **Test P → K**: Bấm `P`, kết quả: `K`

#### 5.3 Test phím bình thường

- `X`, `Y`, `Z` → Hoạt động bình thường
- `1`, `2`, `3` → Hoạt động bình thường
- `Shift+A`, `Ctrl+A` → Test tổ hợp phím

#### 5.4 Monitor logs

```bash
# Xem logs realtime
sudo dmesg -w | grep usb_kbd_remap

# Xem logs gần đây
dmesg | grep usb_kbd_remap | tail -n 10
```

## 🔧 Quản lý Driver

### Unload Driver

```bash
# Unload driver
sudo ./unload_driver.sh
```

### Restart Driver

```bash
# Restart driver (unload + load)
sudo ./unload_driver.sh && sudo ./load_driver.sh
```

### Auto-load at boot (optional)

```bash
# Copy driver to modules directory
sudo make install

# Add to modules list
echo "usb_kbd_remap" | sudo tee -a /etc/modules-load.d/usb_kbd_remap.conf

# Rebuild module dependencies
sudo depmod -a
```

## 🐛 Troubleshooting

### 1. Build Errors

#### Error: "No such file or directory" cho kernel headers

```bash
# Cài đặt kernel headers cho version hiện tại
sudo yum install kernel-devel-$(uname -r)

# Nếu không có package cụ thể, cài version mới nhất
sudo yum install kernel-devel

# Update kernel (nếu cần)
sudo yum update kernel
# Sau đó reboot và rebuild driver
```

#### Error: "gcc not found"

```bash
# Cài đặt Development Tools
sudo yum groupinstall "Development Tools"

# Hoặc cài đặt riêng lẻ
sudo yum install gcc make
```

#### Error: Architecture mismatch

```bash
# Kiểm tra architecture
uname -m
# Phải là i686 hoặc i386 cho 32-bit

# Nếu là x86_64, cần chuyển sang CentOS 6 32-bit
```

### 2. Loading Errors

#### Error: "Operation not permitted"

```bash
# Disable SELinux tạm thời
sudo setenforce 0

# Permanent disable (không khuyến nghị)
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

#### Error: "Invalid module format"

```bash
# Module không match kernel version
# Rebuild driver
make clean && make
```

#### Error: "Unknown symbol"

```bash
# Missing dependencies
# Kiểm tra module dependencies
modinfo usb_kbd_remap.ko

# Load required modules trước
modprobe hid
modprobe usbhid
```

### 3. Driver Functionality Issues

#### Remapping không hoạt động

```bash
# 1. Kiểm tra USB keyboard đúng
lsusb | grep "0461:4e8e"

# 2. Kiểm tra driver loaded
lsmod | grep usb_kbd_remap

# 3. Restart driver
sudo ./unload_driver.sh && sudo ./load_driver.sh

# 4. Kiểm tra logs
dmesg | grep usb_kbd_remap

# 5. Test với keyboard khác (nếu có)
```

#### Một số phím không được remap

```bash
# Kiểm tra HID report format
# Enable debug mode
make clean && make debug
sudo ./unload_driver.sh && sudo ./load_driver.sh

# Monitor detailed logs
sudo dmesg -w | grep usb_kbd_remap
```

### 4. System Issues

#### CentOS 6 End of Life

```bash
# Update repositories to vault
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Update system
sudo yum clean all
sudo yum update
```

#### Performance issues

```bash
# Check system resources
free -m
df -h

# Check for conflicts
lsmod | grep -E "(hid|usb|keyboard)"
```

## 📚 Advanced Usage

### Custom Key Mappings

Để thay đổi key mappings, edit file `usb_kbd_remap.c`:

```c
// Tìm section raw_event handler
// Thay đổi các mapping:
if (key_code == 0x04) {  // A key
    data[i] = 0x0B;      // Map to H
}
```

### Debug Mode

```bash
# Build với debug
make debug

# Load và monitor
sudo ./load_driver.sh
sudo dmesg -w | grep usb_kbd_remap
```

### Multiple Keyboards

Driver chỉ hỗ trợ keyboard cụ thể (VID:0461 PID:4e8e). Để hỗ trợ keyboard khác, edit:

```c
#define VENDOR_ID 0x0461    // Thay đổi VID
#define PRODUCT_ID 0x4e8e   // Thay đổi PID
```

## 📋 Useful Commands

### System Information

```bash
# OS info
cat /etc/redhat-release
uname -a

# Hardware info
lscpu
lspci | grep -i usb
lsusb -v

# Module info
lsmod | grep usb
modinfo usb_kbd_remap.ko
```

### Driver Management

```bash
# Manual load/unload
sudo insmod usb_kbd_remap.ko
sudo rmmod usb_kbd_remap

# Check dependencies
modprobe --show-depends usb_kbd_remap.ko

# Force unload
sudo rmmod -f usb_kbd_remap
```

### Monitoring

```bash
# Real-time logs
sudo dmesg -w | grep usb_kbd_remap

# USB events
sudo udevadm monitor --kernel --subsystem-match=usb

# Input events
sudo evtest  # Chọn keyboard device
```

## 🔒 Security Notes

1. **SELinux**: Driver có thể bị SELinux block. Disable tạm thời khi test.
2. **Root privileges**: Scripts cần sudo để load/unload kernel modules.
3. **Kernel modules**: Chỉ load modules từ sources tin cậy.
4. **Backup**: Backup system trước khi cài đặt driver.

## 📞 Support

### Log Collection

Khi cần support, thu thập thông tin sau:

```bash
# System info
uname -a > debug_info.txt
cat /etc/redhat-release >> debug_info.txt
lscpu >> debug_info.txt

# USB info
lsusb -v >> debug_info.txt

# Driver info
lsmod | grep usb >> debug_info.txt
dmesg | grep usb_kbd_remap >> debug_info.txt

# Build info
make info >> debug_info.txt
```

### Common Issues

1. **Build fails**: Kiểm tra kernel-devel package
2. **Load fails**: Kiểm tra SELinux và permissions
3. **No remapping**: Kiểm tra USB device VID:PID
4. **Kernel panic**: Unload driver và kiểm tra logs

## 📈 Version History

- **v1.0-centos6**: Initial CentOS 6 32-bit compatible version
  - Support for kernel 2.6.32
  - 32-bit architecture optimization
  - Enhanced error handling
  - Comprehensive documentation

---

## 🎯 Quick Start Summary

```bash
# 1. Install dependencies
sudo yum groupinstall "Development Tools"
sudo yum install kernel-devel-$(uname -r)

# 2. Build driver
./build_driver.sh

# 3. Load driver
sudo ./load_driver.sh

# 4. Test driver
./test_driver.sh

# 5. Open text editor and test key mappings
nano test.txt
# Type: A B Q E T I P
# Should output: H C E T U P K
```

**🎉 Chúc bạn sử dụng driver thành công trên CentOS 6 32-bit!**

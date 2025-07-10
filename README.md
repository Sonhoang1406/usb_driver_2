# USB Keyboard Remap Driver

## Mô tả
Driver Linux để remap phím bàn phím USB HP (VID: 0x0461, PID: 0x4e8e). Driver này cho phép thay đổi hành vi của các phím cụ thể mà không cần phần mềm bên ngoài.

## Key Mappings hiện tại
- **A** → **H**
- **B** → **C**
- **Q** → **E**
- **E** → **T**
- **T** → **U**
- **I** → **P**
- **P** → **K**

## Yêu cầu hệ thống

### 1. Kiểm tra kernel headers
```bash
# Kiểm tra kernel version
uname -r

# Kiểm tra kernel headers có sẵn không
ls -la /lib/modules/$(uname -r)/build/

# Nếu chưa có, cài đặt kernel headers
sudo dnf install kernel-devel kernel-headers
# hoặc trên Ubuntu/Debian:
# sudo apt-get install linux-headers-$(uname -r)
```

### 2. Kiểm tra tools cần thiết
```bash
# Kiểm tra gcc
gcc --version

# Kiểm tra make
make --version

# Nếu chưa có, cài đặt development tools
sudo dnf groupinstall "Development Tools"
# hoặc trên Ubuntu/Debian:
# sudo apt-get install build-essential
```

### 3. Kiểm tra bàn phím USB
```bash
# Liệt kê các thiết bị USB
lsusb

# Tìm bàn phím HP (ID 0461:4e8e)
lsusb | grep -i "0461:4e8e"
```

## Cấu trúc dự án
```
usb_keyboard_driver/
├── usb_kbd_remap.c      # Mã nguồn driver chính
├── Makefile             # File build
├── build_driver.sh      # Script build driver
├── load_driver.sh       # Script load driver
├── unload_driver.sh     # Script unload driver
├── test_driver.sh       # Script test driver
└── README.md            # Tài liệu này
```

## Hướng dẫn sử dụng từng bước

### Bước 1: Chuẩn bị
```bash
# Di chuyển vào thư mục dự án
cd /home/son/driver_nam/usb_keyboard_driver

# Kiểm tra các file
ls -la

# Cấp quyền thực thi cho scripts
chmod +x *.sh
```

### Bước 2: Build Driver
```bash
# Cách 1: Dùng script (khuyến nghị)
./build_driver.sh

# Cách 2: Build thủ công
make clean
make
```

**Kết quả mong đợi:**
- Driver build thành công
- Tạo file `usb_kbd_remap.ko` (khoảng 492KB)
- Không có lỗi compile

### Bước 3: Load Driver
```bash
# Load driver
sudo ./load_driver.sh

# Kiểm tra driver đã load thành công
lsmod | grep usb_kbd_remap
```

**Kết quả mong đợi:**
```
Loading USB Keyboard Remap Driver...
Driver loaded successfully!
[ xxxx.xxxxxx] usb_kbd_remap: Probing device HP USB Keyboard VID:0461 PID:4e8e
[ xxxx.xxxxxx] usb_kbd_remap: Attaching to input device HP USB Keyboard
[ xxxx.xxxxxx] usb_kbd_remap: Event handler attached successfully
```

### Bước 4: Test Driver
```bash
# Chạy test script
./test_driver.sh
```

**Kết quả mong đợi:**
- Driver được load thành công
- Hiển thị các key mappings
- Logs driver xuất hiện trong kernel logs

### Bước 5: Test thực tế

#### 5.1 Mở Text Editor
```bash
# Mở gedit
gedit &

# Hoặc nano
nano test.txt

# Hoặc bất kỳ text editor nào khác
```

#### 5.2 Test từng phím
1. **Test phím A**: Bấm `A` → Kết quả: `H`
2. **Test phím B**: Bấm `B` → Kết quả: `C`
3. **Test phím Q**: Bấm `Q` → Kết quả: `E`
4. **Test phím E**: Bấm `E` → Kết quả: `T`
5. **Test phím T**: Bấm `T` → Kết quả: `U`
6. **Test phím I**: Bấm `I` → Kết quả: `P`
7. **Test phím P**: Bấm `P` → Kết quả: `K`

#### 5.3 Kiểm tra logs
```bash
# Xem logs realtime
sudo dmesg -w | grep usb_kbd_remap

# Hoặc xem logs gần đây
dmesg | grep usb_kbd_remap | tail -10
```

## Troubleshooting

### Lỗi Build
```bash
# Nếu lỗi "No such file or directory" cho kernel headers
sudo dnf install kernel-devel-$(uname -r)

# Nếu lỗi missing tools
sudo dnf groupinstall "Development Tools"
```

### Lỗi Load Driver
```bash
# Nếu lỗi "Operation not permitted"
# Kiểm tra SELinux
sudo setenforce 0  # Tạm thời disable SELinux

# Nếu lỗi "Invalid module format"
# Rebuild driver với kernel hiện tại
make clean && make
```

### Driver không hoạt động
```bash
# Kiểm tra thiết bị USB
lsusb | grep -i "0461:4e8e"

# Kiểm tra driver đã load
lsmod | grep usb_kbd_remap

# Kiểm tra logs
dmesg | grep usb_kbd_remap
```

### Không thấy key mapping
```bash
# Kiểm tra device đang sử dụng
cat /proc/bus/input/devices | grep -A 5 -B 5 "HP USB Keyboard"

# Restart driver
sudo ./unload_driver.sh
sudo ./load_driver.sh
```

## Quản lý Driver

### Unload Driver
```bash
# Unload driver
sudo ./unload_driver.sh

# Hoặc thủ công
sudo rmmod usb_kbd_remap
```

### Kiểm tra trạng thái
```bash
# Kiểm tra driver đang load
lsmod | grep usb_kbd_remap

# Xem thông tin driver
modinfo usb_kbd_remap.ko

# Xem logs driver
dmesg | grep usb_kbd_remap
```

### Rebuild sau khi sửa code
```bash
# Unload driver cũ
sudo ./unload_driver.sh

# Rebuild
make clean
make

# Load driver mới
sudo ./load_driver.sh
```

## Tùy chỉnh Key Mappings

### Thay đổi mappings trong code
Sửa file `usb_kbd_remap.c`:
```c
// Thay đổi các biến module parameters
static unsigned int map_from_key = KEY_A;    // Phím nguồn
static unsigned int map_to_key = KEY_H;      // Phím đích
```

### Thay đổi USB HID mappings
Sửa trong hàm `kbd_raw_event()`:
```c
// Thêm mapping mới
else if (key_code == 0x04) {  // 'A' key in USB HID
    printk(KERN_DEBUG "usb_kbd_remap: Remapping A(0x04) to H(0x0B)\n");
    data[i] = 0x0B;  // 'H' key in USB HID
}
```

## Tài liệu tham khảo

### USB HID Scan Codes
- A = 0x04, B = 0x05, C = 0x06, ..., Z = 0x1D
- Q = 0x14, E = 0x08, T = 0x17, U = 0x18
- I = 0x0C, P = 0x13, K = 0x0E

### Linux Input Event Codes
- KEY_A = 30, KEY_B = 48, KEY_C = 46
- KEY_Q = 16, KEY_E = 18, KEY_T = 20
- KEY_I = 23, KEY_P = 25, KEY_K = 37

## Liên hệ
- Author: You <you@example.com>
- Version: 1.0
- License: GPL

## Lưu ý quan trọng
- Driver chỉ hoạt động với bàn phím HP USB (VID: 0x0461, PID: 0x4e8e)
- Cần quyền root để load/unload driver
- Backup dữ liệu quan trọng trước khi test
- Disable SELinux nếu gặp lỗi permission

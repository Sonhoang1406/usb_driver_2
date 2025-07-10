# Makefile for USB Keyboard Remap Driver - CentOS 6 32-bit compatible
obj-m := usb_kbd_remap.o

# Detect kernel directory for CentOS 6
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

# CentOS 6 32-bit specific compiler flags
EXTRA_CFLAGS += -Wall -Wno-unused-parameter -Wno-unused-variable
EXTRA_CFLAGS += -DLINUX -D__KERNEL__ -DMODULE
EXTRA_CFLAGS += -m32 -march=i686
EXTRA_CFLAGS += -O2 -fno-strict-aliasing -fno-common
EXTRA_CFLAGS += -fomit-frame-pointer -pipe
EXTRA_CFLAGS += -msoft-float -mregparm=3 -freg-struct-return
EXTRA_CFLAGS += -fno-pic -fno-stack-protector
EXTRA_CFLAGS += -ffreestanding -DCONFIG_AS_CFI=1

# Disable some warnings for older GCC in CentOS 6
EXTRA_CFLAGS += -Wno-declaration-after-statement
EXTRA_CFLAGS += -Wno-pointer-sign

# Include directories for CentOS 6
EXTRA_CFLAGS += -I$(KDIR)/include
EXTRA_CFLAGS += -I$(KDIR)/arch/x86/include
EXTRA_CFLAGS += -I$(KDIR)/arch/x86/include/generated

# Ensure 32-bit compilation
ARCH := i386
export ARCH

all:
	@echo "Building USB Keyboard Remap Driver for CentOS 6 32-bit..."
	@echo "Kernel directory: $(KDIR)"
	@echo "Architecture: $(ARCH)"
	@if [ ! -d "$(KDIR)" ]; then \
		echo "ERROR: Kernel headers not found at $(KDIR)"; \
		echo "Please install kernel-devel package:"; \
		echo "  sudo yum install kernel-devel-\$$(uname -r)"; \
		exit 1; \
	fi
	$(MAKE) ARCH=$(ARCH) -C $(KDIR) M=$(PWD) modules

clean:
	@echo "Cleaning build files..."
	$(MAKE) ARCH=$(ARCH) -C $(KDIR) M=$(PWD) clean
	rm -f *.o *.ko *.mod.* modules.order Module.symvers
	rm -f .*.cmd .tmp_versions -rf

install: all
	@echo "Installing driver..."
	$(MAKE) ARCH=$(ARCH) -C $(KDIR) M=$(PWD) modules_install
	depmod -a
	@echo "Driver installed successfully"

uninstall:
	@echo "Uninstalling driver..."
	rm -f /lib/modules/$(shell uname -r)/extra/usb_kbd_remap.ko
	depmod -a
	@echo "Driver uninstalled"

check-deps:
	@echo "Checking build dependencies for CentOS 6..."
	@which gcc >/dev/null 2>&1 || (echo "ERROR: gcc not found. Install with: sudo yum groupinstall 'Development Tools'" && exit 1)
	@which make >/dev/null 2>&1 || (echo "ERROR: make not found. Install with: sudo yum groupinstall 'Development Tools'" && exit 1)
	@[ -d "$(KDIR)" ] || (echo "ERROR: Kernel headers not found. Install with: sudo yum install kernel-devel-\$$(uname -r)" && exit 1)
	@echo "All dependencies satisfied"

debug: EXTRA_CFLAGS += -DDEBUG -g
debug: all

info:
	@echo "=== Build Information ==="
	@echo "Target: CentOS 6 32-bit"
	@echo "Kernel: $(shell uname -r)"
	@echo "Architecture: $(ARCH)"
	@echo "Kernel Dir: $(KDIR)"
	@echo "PWD: $(PWD)"
	@echo "GCC Version: $(shell gcc --version | head -n1)"
	@echo "========================="

.PHONY: all clean install uninstall check-deps debug info

PACKAGES = bash coreutils iputils net-tools strace util-linux iproute pciutils 
SMD = supermin.d

QEMU = qemu-system-x86_64
KERNEL = ./bzImage

KERNELU = ../linux/arch/x86/boot/bzImage

TARGET = min-initrd.d

.PHONY: all supermin build-package clean
all: clean $(TARGET)/root

clean:
	clear

supermin:
	@if [ ! -a $(SMD)/packages -o '$(PACKAGES) ' != "$$(tr '\n' ' ' < $(SMD)/packages)" ]; then \
	  $(MAKE) --no-print-directory build-package; \
	else \
	  touch $(SMD)/packages; \
	fi

build-package:
	supermin --prepare $(PACKAGES) -o $(SMD)

supermin.d/packages: supermin

supermin.d/init.tar.gz: init
	tar zcf $@ $^

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz 
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}

runU: all
	$(QEMU) -enable-kvm -m 1G -s -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0" -device  virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555
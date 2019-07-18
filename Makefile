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

supermin.d/usermultithreadedserver.tar.gz: usermultithreadedserver
	tar zcf $@ $^

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/usermultithreadedserver.tar.gz
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}

runL: #all
	$(QEMU) -enable-kvm -m 10G -s -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti" -device  virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555 -redir tcp:5556::5556 -redir tcp:5557::5557 -redir tcp:5558::5558 -redir tcp:5559::5559 -redir tcp:5560::5560 -redir tcp:5561::5561 -redir tcp:5562::5562 -redir tcp:5563::5563 -redir tcp:5564::5564

debugL: 
	$(QEMU) -m 10G -s -S -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti" -device  virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

runU: #all
	$(QEMU) -enable-kvm -m 10G -s -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti" -device  virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555 -redir tcp:5556::5556 -redir tcp:5557::5557 -redir tcp:5558::5558 -redir tcp:5559::5559 -redir tcp:5560::5560 -redir tcp:5561::5561 -redir tcp:5562::5562 -redir tcp:5563::5563 -redir tcp:5564::5564

debugU: 
	$(QEMU) -m 10G -s -S -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti" -device  virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555
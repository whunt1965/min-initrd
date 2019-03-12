PACKAGES = bash coreutils iputils net-tools strace util-linux #memcached 
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

min-server/min-server: min-server/min-server.c
	gcc -o $@ $^
supermin.d/min-server.tar.gz: min-server/min-server
	tar -zcf $@ -C min-server min-server

supermin.d/server.tar.gz:
	tar -zcf $@ server

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/min-server.tar.gz supermin.d/min-server.tar.gz supermin.d/server.tar.gz
	supermin --build -v --format ext2 supermin.d -o ${@D}

runL:  
	$(QEMU) -nodefaults -m 1G -nographic -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" # -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

debugL:  
	$(QEMU) -nodefaults -m 1G -s -S -nographic -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" # -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

runU:   
	$(QEMU) -m 1G -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" #-device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

debugU: 
	$(QEMU) -m 1G -s -S -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" # -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

#runU:   
#	$(QEMU) -m 1G -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -monitor stdio # -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" #-device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

#debugU: 
#	$(QEMU) -m 1G -s -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -monitor stdio # -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr" # -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

# runL:  
# 	$(QEMU) -nodefaults -enable-kvm -nographic -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios -append "console=ttyS0 root=/dev/sda nokaslr" -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

# debugL:  
# 	$(QEMU) -nodefaults -s -S -enable-kvm -smp 4 -nographic -kernel $(KERNEL) -initrd min-initrd.d/initrd -hda min-initrd.d/root -chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios -append "console=ttyS0 root=/dev/sda nokaslr" -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

# runU:   
# 	$(QEMU) -nodefaults -nographic -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios -append "console=ttyS0 root=/dev/sda nokaslr" #-device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

# debugU: 
# 	$(QEMU) -nodefaults -s -S -nographic -kernel $(KERNELU) -initrd min-initrd.d/initrd -hda min-initrd.d/root -chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios -append "console=ttyS0 root=/dev/sda nokaslr" -device e1000,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555
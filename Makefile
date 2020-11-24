PACKAGES = bash coreutils iputils net-tools strace util-linux iproute pciutils memcached ethtool kmod strace perf

SMD = supermin.d

QEMU = qemu-system-x86_64
options = -enable-kvm -smp 16 -m 30G
DEBUG = -S -s
KERNEL = .-kernel /bzImage
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none -u root -t 6 -m 16G -c 8192 -b 8192 -B binary"
COMMANDLINE = -append "console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none 0 ali"
NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=6 -device virtio-net-pci,mq=on,vectors=10,netdev=vlan1,mac=02:00:00:04:00:29
# 0 ukl57nosswitch
TARGET = min-initrd.d

#strace -v /sbin/kexec -p mykexec/bzImage --initrd=mykexec/initrd --append="console=ttyS0 root=/dev/sda nosmap mds=off ip=192.168.19.108:::255.255.255.0::eth0:none maxcpus=1" >& mytmp

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

supermin.d/user.tar.gz: userstack
	tar zcf $@ $^

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}

runU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugU: 
	$(QEMU) $(options) $(DEBUG) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

runL: 
	$(QEMU) $(options) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugL: all 
	$(QEMU) $(options) $(DEBUG) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

monU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(MONITOR) $(COMMANDLINE) $(NETWORK)

PACKAGES = bash coreutils iputils net-tools strace util-linux iproute pciutils 
SMD = supermin.d

QEMU = qemu-system-x86_64
options = -enable-kvm -smp 16 -m 20G -s
DEBUG = -S
KERNEL = .-kernel /bzImage
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ftrace=function_graph ftrace_dump_on_oops"
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap mds=off" # ftrace=function_graph ftrace_dump_on_oops"
COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none"
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none ftrace=function ftrace_dump_on_oops"
#NETWORK = -device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::11211-:11211
#NETWORK = -device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::11211-:11211 -object filter-dump,id=f1,netdev=usernet,file=dump.dat
#NETWORK = -device e1000,netdev=usernet,mac=52:55:00:d1:55:44 -netdev tap,id=usernet,ifname=alitap,script=no,downscript=0
NETWORK = -device virtio-net,netdev=usernet,mac=52:55:00:d1:55:44 -netdev tap,id=usernet,ifname=alitap,script=no,downscript=0

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

supermin.d/user.tar.gz: userstack
	tar zcf $@ $^

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz 
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}

runU:
	taskset -c 0-15 $(QEMU) $(options) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugU: 
	$(QEMU) $(options) $(DEBUG) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

runL: 
	$(QEMU) $(options) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugL: all 
	$(QEMU) $(options) $(DEBUG) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

monU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(MONITOR) $(COMMANDLINE) $(NETWORK)

E1000_NET_DEV=-device e1000,netdev=usernet,mac=52:55:00:d1:55:42 -netdev tap,id=usernet,ifname=alitap,script=no,downscript=0
runTU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(E1000_NET_DEV)

PACKAGES = bash coreutils iputils net-tools strace util-linux iproute2 pciutils  memcached
SMD = supermin.d

QEMU = taskset -c 0-15 qemu-system-x86_64 -cpu host
options = -enable-kvm -smp 16 -m 30G -s
DEBUG = -S
KERNEL = .-kernel /bzImage
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio
COMMANDLINE = -append "console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none"
NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=16 -device virtio-net-pci,mq=on,vectors=16,netdev=vlan1,mac=02:00:00:04:00:29
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ftrace=function_graph ftrace_dump_on_oops"
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap mds=off ip=192.168.19.136:::255.255.255.0::eth0:none"
#NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=4 -device virtio-net-pci,mq=on,vectors=10,netdev=vlan1,mac=02:00:00:04:00:29
#-netdev tap,id=network0,ifname=tap0,script=no,downscript=no -device virtio-net,netdev=network0,mac=52:55:00:d1:55:01
#--netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=4 --device virtio-net-pci,mq=on,vectors=10,netdev=vlan1,mac=02:00:00:04:00:29
#-netdev tap,id=tap0,script=no,downscript=0 -net nic,model=virtio,netdev=tap0,macaddr=52:55:00:d1:55:01
#NETWORK = -device virtio-net-pci,mq=on,netdev=network0,mac=52:55:00:d1:55:01 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no,vhost=on,queues=4
#-netdev tap,id=usernet,ifname=tap0,script=no,downscript=0 -device virtio-net,netdev=usernet,mac=52:55:00:d1:55:44
#ip=192.168.19.36:::255.255.224.0::eth0:none
#-device virtio-net,mq=on,vectors=4,netdev=usernet,mac=52:55:00:d1:55:44 -netdev tap,id=usernet,ifname=tap0,script=no,downscript=0,vhost=on,queues=4 #-device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::11211-:11211
#NETWORK = -device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::11211-:11211 -object filter-dump,id=f1,netdev=usernet,file=dump.dat

TARGET = min-initrd.d

.PHONY: all supermin build-package clean malloctest echoserver lb lebench
all: clean exportmods $(TARGET)/root

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

malloctest:
	gcc -o malloctest malloctest.c -lpthread -ggdb

echoserver:
	gcc -o echoserver echoserver.c -ggdb

lebench:
	gcc -o lebench OS_Eval.c -ggdb -lpthread

lb:
	gcc -o lb OS_Eval.c -ggdb -lpthread

supermin.d/init.tar.gz: init
	tar zcf $@ $^

supermin.d/malloctest.tar.gz: malloctest
	tar zcf $@ $^

supermin.d/echoserver.tar.gz: echoserver
	tar zcf $@ $^

supermin.d/lebench.tar.gz: lebench
	tar zcf $@ $^

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/lebench.tar.gz
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}

exportmods:
	export SUPERMIN_KERNEL=/mnt/normal/linux/arch/x86/boot/bzImage
	export SUPERMIN_MODULES=/mnt/normal/min-initrd/kmods/lib/modules/5.7.0+/

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

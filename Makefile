PACKAGES = bash coreutils iputils net-tools strace util-linux iproute2 pciutils  memcached
SMD = supermin.d

SMP = 16
TS = 0-15
QUEUES = 16
VECTORS = 33

QEMU = taskset -c $(TS) qemu-system-x86_64 -cpu host
options = -enable-kvm -smp cpus=$(SMP) -m 30G
DEBUG = -S
KERNEL = .-kernel /bzImage
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio
COMMANDLINE = -append "console=ttyS0 root=/dev/sda nosmap mds=off ip=192.168.19.108:::255.255.255.0::eth0:none -u root -t 16 -m 16G -c 8192 -b 8192 -l 192.168.19.108 -B binary"
NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=$(QUEUES) -device virtio-net-pci,mq=on,vectors=$(VECTORS),netdev=vlan1,mac=02:00:00:04:00:29

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

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz 
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

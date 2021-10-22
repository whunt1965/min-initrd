PACKAGES = bash ld-linux coreutils iputils net-tools strace util-linux iproute pciutils ethtool kmod strace perf python vim mount grep sed
SMD = supermin.d

SHELL = /bin/bash
#SMP = 4
SMP = 1
TS = 8-11
QUEUES = 4
VECTORS = 10

#QEMU = taskset -c $(TS) qemu-system-x86_64 -cpu host
#QEMU = qemu-system-x86_64 -cpu host
QEMU = qemu-system-x86_64
#options = -enable-kvm -smp cpus=$(SMP) -m 30G
#options = -enable-kvm -smp cpus=$(SMP) -m 3g
options = -smp cpus=$(SMP) -m 3g -no-reboot
DEBUG = -S -s
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
#DISPLAY = -nodefaults -nographic -serial stdio
DISPLAY = -nodefaults -nographic -serial file:"../test.out"
MONITOR = -nodefaults -nographic -serial mon:stdio
COMMANDLINE = -append "console=ttyS0 root=/dev/sda rw  net.ifnames=0 biosdevname=0 nowatchdog nosmap nosmep mds=off ip=192.168.19.136:::255.255.255.0::eth0:none -- -m /workloads/iperf.xml -a"
#COMMANDLINE = -append "console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nowatchdog nosmap nosmep mds=off ip=192.168.19.136:::255.255.255.0::eth0:none"
NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=$(QUEUES) -device virtio-net-pci,mq=on,vectors=$(VECTORS),netdev=vlan1,mac=02:00:00:04:00:29
#NETWORK = -netdev tap,id=vlan1,ifname=tap0,script=no,downscript=no,vhost=on,queues=$(QUEUES) -device virtrio-blk-device  mq=on,vectors=$(VECTORS),netdev=vlan1,mac=02:00:00:04:00:29
#NETWORK = 

#-----------------------------------------------

SMP2 = 4
TS2 = 12-15
QUEUES2 = 4
VECTORS2 = 10

QEMU2 = taskset -c $(TS2) qemu-system-x86_64 -cpu host
options2 = -enable-kvm -smp cpus=$(SMP2) -m 30G
DEBUG2 = -S -s
KERNELU2 = -kernel ../linux/arch/x86/boot/bzImage
SMOptions2 = -initrd min-initrd.d/initrd -hda min-initrd.d/root2
DISPLAY2 = -nodefaults -nographic -serial stdio
MONITOR2 = -nodefaults -nographic -serial mon:stdio
COMMANDLINE2 = -append "console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nosmap mds=off ip=192.168.19.137:::255.255.255.0::eth0:none -- -m /workloads/iperf.xml -a"
NETWORK2 = -netdev tap,id=vlan1,ifname=tap2,script=no,downscript=no,vhost=on,queues=$(QUEUES2) -device virtio-net-pci,mq=on,vectors=$(VECTORS2),netdev=vlan1,mac=02:00:00:04:00:30

#-----------------------------------------------

TARGET = min-initrd.d

.PHONY: all supermin build-package clean
all: $(TARGET)/root

clean:
	clear

supermin:
	@if [ ! -a $(SMD)/packages -o '$(PACKAGES) ' != "$$(tr '\n' ' ' < $(SMD)/packages)" ]; then \
	  $(MAKE) --no-print-directory build-package; \
	else \
	  touch $(SMD)/packages; \
	fi
	#cp ../mybench_small.static .

build-package:
	supermin --prepare $(PACKAGES) -o $(SMD)

supermin.d/packages: supermin

supermin.d/init.tar.gz: init
	tar zcf $@ $^

supermin.d/shutdown.tar.gz: shutdown
	tar zcf $@ $^
#supermin.d/workloads.tar.gz: workloads
#	tar zcf $@ $^

#supermin.d/uperf.static.tar.gz: uperf.static
#	tar zcf $@ $^

#supermin.d/netperf.static.tar.gz: netperf.static
#	tar zcf $@ $^

#supermin.d/netserver.static.tar.gz: netserver.static
#	tar zcf $@ $^

#supermin.d/set_irq_affinity_virtio.sh.tar.gz: set_irq_affinity_virtio.sh
#	tar zcf $@ $^

#supermin.d/mybench_small.static.tar.gz: mybench_small.static
#	tar zcf $@ $^

#supermin.d/mybench.static.tar.gz: mybench.static
#	tar zcf $@ $^

#supermin.d/server.static.tar.gz: server.static
#	tar zcf $@ $^

#$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/workloads.tar.gz \
#	supermin.d/set_irq_affinity_virtio.sh.tar.gz supermin.d/mybench_small.static.tar.gz
#	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}
#	- rm -rf $(TARGET)/root2
#	cp $(TARGET)/root $(TARGET)/root2

# Added from original min_initrd makefile and edited to comply with original build instruc
$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/shutdown.tar.gz
	#supermin --build --format ext2 supermin.d -o ${@D}
	supermin --build -v -v -v --size 8G --if-newer --format ext2 supermin.d -o ${@D}
	- rm -rf $(TARGET)/root2
	cp $(TARGET)/root $(TARGET)/root2

exportmods:
	export SUPERMIN_KERNEL=/mnt/normal/linux/arch/x86/boot/bzImage
	export SUPERMIN_MODULES=/mnt/normal/min-initrd/kmods/lib/modules/5.7.0+/

runU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugU: 
	$(QEMU) $(options) $(DEBUG) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

monU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(MONITOR) $(COMMANDLINE) $(NETWORK)

runU2:
	$(QEMU2) $(options2) $(KERNELU2) $(SMOptions2) $(DISPLAY2) $(COMMANDLINE2) $(NETWORK2)



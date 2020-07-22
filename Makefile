PACKAGES = bash coreutils #iputils net-tools strace util-linux iproute pciutils 
SMD = supermin.d

QEMU = qemu-system-x86_64
options = -enable-kvm -smp 1 -m 10G
DEBUG = -S -s
KERNEL = -kernel /bzImage

KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio

COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr nopti nosmap mds=off" #ip=10.255.19.133:::255.255.224.0::eth0:none"

# COMMANDLINE = -append "nokaslr nopti nosmap console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0"
# I'm removing entries that were passed to init, that we meant to be
# Passed to the kernel.
# COMMANDLINE = -append "nosmap console=ttyS0 mds=off root=/dev/sda net.ifnames=0 -- 2000 env0=0 env1=1 env2=2"
# COMMANDLINE = -append "init=/fakefile console=ttyS0 root=/dev/sda net.ifnames=0 biosdevname=0 nosmap" #ip=10.255.19.133
# Let's look for the defaults and work from there.
NETWORK = -device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555
# NETWORK =-netdev tap,id=tap0,vhost=on,script=no -net nic,model=virtio,netdev=tap0,macaddr=00:16:35:AF:94:4B

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
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugU: 
	$(QEMU) $(options) $(DEBUG) $(KERNELU) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

runL: 
	$(QEMU) $(options) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

debugL: all 
	$(QEMU) $(options) $(DEBUG) $(KERNEL) $(SMOptions) $(DISPLAY) $(COMMANDLINE) $(NETWORK)

monU:
	$(QEMU) $(options) $(KERNELU) $(SMOptions) $(MONITOR) $(COMMANDLINE) $(NETWORK)

runJABasic:
	qemu-system-x86_64 -enable-kvm -smp 1 -m 20G -kernel ../linux/arch/x86/boot/bzImage -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ip=192.168.19.133:::255.255.224.0::eth0:none" -device e1000,netdev=usernet,mac=52:55:00:d1:55:01 -netdev tap,id=usernet,ifname=tap0,script=no,downscript=0

runJA:
	qemu-system-x86_64 -enable-kvm -smp 1 -m 10G -kernel ../linux/arch/x86/boot/bzImage -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ip=192.168.19.133:::::eth0:none" -device e1000,netdev=usernet,mac=52:55:00:d1:55:01 -netdev tap,id=usernet,ifname=tap0,script=no,downscript=0

runVIRTIO:
	qemu-system-x86_64 -enable-kvm -smp 2 -m 10G -kernel ../linux/arch/x86/boot/bzImage -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append \
	"console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ip=192.168.19.133:::255.255.224.0::eth0:none" \
	-netdev tap,id=tap0,script=no,downscript=0 -net nic,model=virtio,netdev=tap0,macaddr=52:55:00:d1:55:01

runVIRTIODHCP:
	qemu-system-x86_64 -enable-kvm -smp 2 -m 10G -kernel ../linux/arch/x86/boot/bzImage -initrd min-initrd.d/initrd -hda min-initrd.d/root -nodefaults -nographic -serial stdio -append \
	"console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap ip=:::::eth0:dhcp" \
	-netdev tap,id=tap0,script=no,downscript=0 -net nic,model=virtio,netdev=tap0,macaddr=52:55:00:d1:55:01
# ip=:::::eth0:dhcp" \


QEMU=qemu-system-x86_64

# FUNDAMENTALS
KVM=-enable-kvm
CORES=-smp 1
MEM=-m 10G

# FILES
KERN=-kernel ../linux/arch/x86/boot/bzImage
INITRD=-initrd min-initrd.d/initrd
ROOT=-hda min-initrd.d/root

# CONSOLE
DISPLAY_CONF=-nographic -serial stdio

# DEFAULT DEVICES
DEF_DEV=-nodefaults


# NET
TAP=tutap

MAC=mac=52:55:00:d1:55:42
MACADDR=macaddr=52:55:00:d1:55:03

SCRIPTS=script=no,downscript=0

# NET DEVICES
E1000_NET_DEV=-device e1000,netdev=usernet,$(MAC) -netdev tap,id=usernet,ifname=$(TAP),$(SCRIPTS)

VIRTU_NET_DEV=-device virtio-net,netdev=usernet,$(MAC) -netdev tap,id=usernet,ifname=$(TAP),$(SCRIPTS)

PARAV_NET_DEV=-netdev tap,id=$(TAP),$(SCRIPTS) -net nic,model=virtio,netdev=$(TAP),$(MACADDR)

CONSOLE=console=ttyS0
FS_ROOT=root=/dev/sda
NET=ip=192.168.19.133:::255.255.255.0::eth0:none

CONFIG= $(KVM) $(CORES) $(MEM) $(KERN) $(INITRD) $(ROOT) $(DISPLAY_CONF) $(DEF_DEV)

# KERNEL COMMAND LINE BOOT PARAMETERS
BOOT_PARAMS=-append "$(CONSOLE) $(FS_ROOT) $(NET)"

runE1000:
	$(QEMU) $(CONFIG) $(BOOT_PARAMS) $(E1000_NET_DEV)

# This seems faster.
runVirtio-Net:
	$(QEMU) $(CONFIG) $(BOOT_PARAMS) $(VIRTU_NET_DEV)

runPara:
	$(QEMU) $(CONFIG) $(BOOT_PARAMS) $(PARAV_NET_DEV)

ping:
	ping 192.168.19.133

PACKAGES = bash coreutils iputils net-tools strace util-linux iproute pciutils
SMD = supermin.d

QEMU = qemu-system-x86_64
options = -enable-kvm -smp 12 -m 10G -s
DEBUG = -S
KERNEL = -kernel /bzImage
KERNELU = -kernel ../linux/arch/x86/boot/bzImage
SMOptions = -initrd min-initrd.d/initrd -hda min-initrd.d/root
DISPLAY = -nodefaults -nographic -serial stdio
MONITOR = -nodefaults -nographic -serial mon:stdio
# COMMANDLINE = -append "ftrace=function ftrace_dump_on_oops console=ttyS0 root=/dev/sda nokaslr net.ifn
ames=0 biosdevname=0 nopti nosmap"
COMMANDLINE = -append "console=ttyS0 root=/dev/sda nokaslr net.ifnames=0 biosdevname=0 nopti nosmap"
NETWORK = -device virtio-net,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::5555-:5555

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


# ftrace=function ftrace_dump_on_oops ftrace_notrace=ptdump_walk_pgd_level_core,ktime_get,_raw_spin_unlo
ck_irqrestore,idle_cpu,irqtime_account_irq,_raw_spin_lock_irqsave,kvm_steal_clock,__accumulate_pelt_segm
ents,rcu_dynticks_eqs_exit,update_rq_clock,update_irq_load_avg,__msecs_to_jiffies
                                                                                      61,1          Bot


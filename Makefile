PACKAGES = bash coreutils iputils net-tools strace util-linux
SMD = supermin.d

TARGET = min-initrd.d

.PHONY: all supermin build-package
all: $(TARGET)/root

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

$(TARGET)/root: supermin.d/packages supermin.d/init.tar.gz supermin.d/min-server.tar.gz
	supermin --build --format ext2 supermin.d -o ${@D}

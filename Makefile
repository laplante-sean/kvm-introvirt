include config.mk

build:
	cp $(KERNEL_CONFIG_FILE) ./kernel/.config
	$(MAKE) -C ./kernel/ oldconfig scripts prepare modules_prepare
	cp $(KERNEL_SYMVERS_FILE) ./kernel/
	KCPPFLAGS="-DKVM_INTROSPECTION_PATCH_VERSION=\\\"$(PATCH_VERSION)\\\"" $(MAKE) -C ./kernel/ M=arch/x86/kvm/

clean:
	$(MAKE) -C ./kernel/ M=arch/x86/kvm/ clean

distclean:
	rm -rf .pc
	rm -rf ./kernel/
	rm -f config.mk

all: build

install:
	mkdir -p $(INSTALL_DIR)
	cp ./kernel/arch/x86/kvm/kvm.ko $(INSTALL_DIR)
	cp ./kernel/arch/x86/kvm/kvm-intel.ko $(INSTALL_DIR)
	cp ./kernel/arch/x86/kvm/kvm-amd.ko $(INSTALL_DIR)
	/bin/bash -c 'if [ -f /usr/sbin/depmod ]; then /usr/sbin/depmod -a $(uname -r); fi'

package: build
	echo "TODO: dpkg-buildpackage -us -uc -j"

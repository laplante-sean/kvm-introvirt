include config.mk

WORKING_DIR ?= "."

build:
	cp $(KERNEL_CONFIG_FILE) $(WORKING_DIR)/kernel/.config
	$(MAKE) -C $(WORKING_DIR)/kernel/ oldconfig scripts prepare modules_prepare
	cp $(KERNEL_SYMVERS_FILE) $(WORKING_DIR)/kernel/
	KCPPFLAGS="-DKVM_INTROSPECTION_PATCH_VERSION=\\\"$(PATCH_VERSION)\\\"" $(MAKE) -C $(WORKING_DIR)/kernel/ M=arch/x86/kvm/

clean:
	$(MAKE) -C $(WORKING_DIR)/kernel/ M=arch/x86/kvm/ clean

distclean:
	rm -rf $(WORKING_DIR)/.pc
	rm -rf $(WORKING_DIR)/kernel/
	rm -f config.mk

all: build

install:
	mkdir -p $(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm.ko $(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm-intel.ko $(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm-amd.ko $(INSTALL_DIR)
	/bin/bash -c 'if [ -f /usr/sbin/depmod ]; then /usr/sbin/depmod -a $(uname -r); fi'

uninstall:
	rmmod kvm-intel kvm
	rm -rf $(INSTALL_DIR)
	depmod -a $(KERNEL_VERSION_FULL)
	modprobe kvm-intel

package: build
	mkdir -p dist
	mkdir -p ./debpkg/$(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm.ko ./debpkg/$(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm-intel.ko ./debpkg/$(INSTALL_DIR)
	cp $(WORKING_DIR)/kernel/arch/x86/kvm/kvm-amd.ko ./debpkg/$(INSTALL_DIR)
	dpkg-deb --build debpkg "dist/$(DEB_NAME)"
	rm -rf ./debpkg/lib
# kvm-introvirt

IntroVirt KVM module. Currently only supports Intel CPUs.

## Installation Instructions

kvm-introvirt can be installed from prebuilt packages using the PPA for Ubuntu bionic and focal.
Shut down any running VMs first, and then run:

```bash
sudo add-apt-repository ppa:srpape/introvirt
sudo apt-get update
sudo apt-get install kvm-introvirt
```

You will have to boot into the kernel that the kvm-introvirt module is built for, if the latest package does not match what your system is running or you can build from source.

## Build Instructions

Install the dependencies:

```bash
sudo apt-get install -y bc devscripts quilt git flex bison libssl-dev libelf-dev debhelper
```

Install the headers and modules for your kernel

```bash
sudo apt-get install linux-headers-$(uname -r) linux-modules-$(uname -r)
```

Clone and build the module (assuming the branch exists for your kernel)

```bash
git clone https://github.com/IntroVirt/kvm-introvirt.git
# Check if you're running an HWE kernel with: hwe-support-status
# If HWE supported:
git checkout ubuntu/$(lsb_release -sc)/Ubuntu-hwe-$(uname -r)
# Otherwise:
git checkout ubuntu/$(lsb_release -sc)/Ubuntu-$(uname -r)
./configure
make
sudo make install
```

The patched version of `kvm.ko`, `kvm-intel.ko`, and `kvm-amd.ko` are installed to `/lib/modules/$(uname -r)/updates/introvirt/`

Reload the KVM module

```bash
sudo rmmod kvm-intel kvm
sudo modprobe kvm-intel
```

If there are issues/errors loading the modified version of KVM, check `dmesg` for more details. To undo these changes and get the original version of KVM back:

```bash
sudo rmmod kvm-intel kvm
sudo rm -rf /lib/modules/$(uname -r)/updates/introvirt/
sudo depmod -a $(uname -r)
sudo modprobe kvm-intel
```

## Supporting a new version (if the branch did not exist)

The kernel module is built based on the branch name. To support a new version, reset the environment and create a new branch. Make sure to branch off of the most recent supported kernel as this makes applying the patch more straightforward.

```bash
# Cleans up the kernel folder
make distclean
git reset --hard
git clean -x -d -f
# Check if you're running an HWE kernel with: hwe-support-status
# If HWE supported:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-hwe-$(uname -r)
# Otherwise:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-$(uname -r)
# Run configure to clone the kernel into ./kernel and attempt to apply the patch
./configure
```

When running `./configure`, quilt will attempt to apply the patch to the new target kernel. If the patch does not cleanly apply, you will need to update it. When the patch fails to apply, we need to force apply what we can:

```bash
quilt push -a -f
```

This will apply the parts of the patch that didn't fail, and create `*.rej` files for the parts that failed. Now, manually inspect the `*.rej` files and adapt them to include the changes required for the patch to work. This is a manual process that requires testing/validation that the changes work as intended. Depending on how much the kernel changed, it could be a simple fix, or a more complicated process.

Once done, or if the patch applied successfully in the first place:

```bash
# Update the .patch file with the changes (if any) to the patch
quilt refresh
# Rename the patch for this kernel. For HWE:
quilt rename kvm-introvirt-hwe-$(uname -r)
# For non HWE:
quilt rename kvm-introvirt-$(uname -r)
# Update the header to specify the new kernel version we patched
quilt header -e
# Build it
make
sudo make install
# Load it
sudo rmmod kvm-intel kvm
sudo modprobe kvm-intel
# Test it - then un-apply the patch
quilt pop
# Then Commit the changes to the patch and push up the new branch
```

See instructions above for details on debugging if `modprobe` fails and how to uninstall the modified KVM.

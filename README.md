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

You will have to boot into the kernel that the kvm-introvirt module is built for, if the latest package does not match what your system is running.

## Build Instructions

Install dependencies:

```bash
sudo apt-get install -y bc devscripts quilt git flex bison libssl-dev libelf-dev debhelper
```

Install the headers and modules for your target kernel

```bash
sudo apt-get install linux-headers-$(uname -r) linux-modules-$(uname -r)
```

Clone and build the module

```bash
git clone https://github.com/IntroVirt/kvm-introvirt.git
# Check if you're running an HWE kernel with: hwe-support-status
# If HWE supported:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-hwe-$(uname -r)
# Otherwise:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-$(uname -r)
./configure
make
sudo make install
```

Reload the KVM module

```bash
sudo rmmod kvm-intel kvm
sudo modprobe kvm-intel
```

## Supporting a new version

The kernel module is built based on the branch name. To support a new version, reset the environment and create a new branch:

```bash
make distclean
git reset --hard
git clean -x -d -f
# Check if you're running an HWE kernel with: hwe-support-status
# If HWE supported:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-hwe-$(uname -r)
# Otherwise:
git checkout -b ubuntu/$(lsb_release -sc)/Ubuntu-$(uname -r)
```

When running `./configure`, quilt will attempt to apply the patch to the new target kernel. If the patch does not cleanly apply, you will need to update it.

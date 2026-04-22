#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# We add --pno (prepare-only) or skip the post-scripts to prevent dracut from 
# running before we have a chance to run depmod.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 3. FIX FOR DRACUT ERROR: Manual depmod
# Your logs show version: 6.19.12-cachyos1.lto.fc43.x86_64
# This command generates the missing modules.dep file that dracut was crying about.
KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto-core)
depmod -a "$KERNEL_VERSION"

# 4. INSTALL ADDONS & SCHEDULERS
# This step will now succeed because depmod has been run, 
# and this transaction will successfully trigger the initramfs generation.
rpm-ostree install \
    kernel-cachyos-lto-devel-matched \
    cachyos-settings \
    cachyos-addons \
    ananicy-cpp \
    cachyos-ananicy-rules \
    scx-manager \
    scx-scheds \
    scx-tools

# 5. ENABLE SERVICES
systemctl enable ananicy-cpp.service
systemctl enable scx-loader.service

# 6. CLEANUP
dnf5 clean all

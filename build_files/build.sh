#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# It is safer to override all three core kernel components at once 
# to prevent version mismatches during the build.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 3. FIX FOR DRACUT ERROR: Manual depmod
# Use 'kernel-cachyos-lto-core' for the version check as it's the most reliable provider
KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto-core)
depmod -a "$KERNEL_VERSION"

# 4. INSTALL ADDONS & SCHEDULERS
# We do this in a separate step to ensure the kernel swap is recognized
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
# These will now be baked into the image
systemctl enable ananicy-cpp.service
systemctl enable scx-loader.service

# 6. CLEANUP
dnf5 clean all

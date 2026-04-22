#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# Using the specific LTO package names
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto

# 3. FIX FOR DRACUT ERROR: Manual depmod
# We extract the version string to make it dynamic
KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto)
depmod -a "$KERNEL_VERSION"

# 4. INSTALL ADDONS & SCHEDULERS
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
systemctl enable ananicy-cpp
systemctl enable scx-loader

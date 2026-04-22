#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. Install all kernel packages and run depmod before letting dracut trigger
# Use a single dnf install, then immediately run depmod BEFORE rpm-ostree touches it
dnf5 install -y \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 3. Run depmod NOW, before rpm-ostree kernel-install hooks fire
KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto-core)
depmod -a "$KERNEL_VERSION"

# 4. NOW use rpm-ostree to finalize the kernel swap
# The modules.dep will already exist, so dracut will succeed
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 5. Install addons & schedulers
rpm-ostree install \
    kernel-cachyos-lto-devel-matched \
    cachyos-settings \
    cachyos-addons \
    ananicy-cpp \
    cachyos-ananicy-rules \
    scx-manager \
    scx-scheds \
    scx-tools

# 6. Enable services
systemctl enable ananicy-cpp.service
systemctl enable scx-loader.service

# 7. Cleanup
dnf5 clean all

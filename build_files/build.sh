#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. Download the kernel packages (don't install yet)
dnf5 download --destdir=/tmp/kernel-rpms \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 3. Install kernel packages WITH SCRIPTS SKIPPED
# This installs the files but prevents %posttrans from running
rpm -i --noscripts /tmp/kernel-rpms/kernel-cachyos-lto*.rpm

# 4. Run depmod immediately (before any dracut attempts)
KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto-core)
depmod -a "$KERNEL_VERSION"

# 5. Use rpm-ostree to properly integrate the kernel with dracut
# This will now succeed because modules.dep exists
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules

# 6. Install addons & schedulers
rpm-ostree install \
    kernel-cachyos-lto-devel-matched \
    cachyos-settings \
    cachyos-addons \
    ananicy-cpp \
    cachyos-ananicy-rules \
    scx-manager \
    scx-scheds \
    scx-tools

# 7. Enable services
systemctl enable ananicy-cpp.service
systemctl enable scx-loader.service

# 8. Cleanup
rm -rf /tmp/kernel-rpms
dnf5 clean all

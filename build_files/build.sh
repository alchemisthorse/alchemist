#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# The package name in the LTO repo is 'kernel-cachyos'. 
# The 'lto' part is in the repo name, not the package name itself.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel=kernel-cachyos

# 3. INSTALL ADDONS & SCHEDULERS
# Matching the names for the devel package and addons
rpm-ostree install \
    kernel-cachyos-devel-matched \
    cachyos-settings \
    cachyos-addons \
    ananicy-cpp \
    cachyos-ananicy-rules \
    scx-manager \
    scx-scheds \
    scx-tools

# 4. ENABLE SERVICES
systemctl enable ananicy-cpp
systemctl enable scx-loader

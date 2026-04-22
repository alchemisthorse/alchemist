#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# Using the specific LTO package names as they appear in the repo metadata.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel-cachyos-lto

# 3. INSTALL ADDONS & SCHEDULERS
# We install the LTO-matched devel headers and the scx tools.
rpm-ostree install \
    kernel-cachyos-lto-devel-matched \
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

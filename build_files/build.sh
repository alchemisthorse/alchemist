#!/bin/bash
set -ouex pipefail

# 1. Enable the specialized Copr repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP
# Swapping to the LTO-optimized kernel. 
# We target the base package and let rpm-ostree resolve the sub-packages.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel=kernel-cachyos-lto

# 3. INSTALL ADDONS & SCHEDULERS
# Added scx-scheds as requested.
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
# ananicy-cpp: Manages process priorities automatically.
# scx-loader: The service that manages and runs the sched-ext schedulers.
systemctl enable ananicy-cpp
systemctl enable scx-loader

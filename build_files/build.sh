#!/bin/bash
set -ouex pipefail

# 1. ADD REPOS (CachyOS Kernel & Addons)
# We use curl to drop the repo files directly into the system
curl -Lo /etc/yum.repos.d/bieszczaders-kernel-cachyos.repo https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-40/bieszczaders-kernel-cachyos-fedora-40.repo
curl -Lo /etc/yum.repos.d/bieszczaders-kernel-cachyos-addons.repo https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/repo/fedora-40/bieszczaders-kernel-cachyos-addons-fedora-40.repo

# 2. STRIP BLOAT (Handheld & Power stuff)
# We remove tuned because cachyos-settings and ananicy-cpp handle things better.
rpm-ostree override remove \
    power-profiles-daemon \
    steamdeck-dsp \
    steamdeck-firmware \
    jupiter-hw-support \
    jupiter-fan-control

# 3. THE "SWAP": Replace Fedora Kernel with CachyOS + Install your Addons
# This single command replaces the heart of the OS.
rpm-ostree override replace \
    --from repo=copr:copr.fedorainfraconfig.org:bieszczaders:kernel-cachyos \
    kernel kernel-core kernel-modules kernel-modules-extra kernel-modules-core \
    --install kernel-cachyos-devel-matched \
    --install cachyos-settings \
    --install cachyos-addons \
    --install ananicy-cpp \
    --install cachyos-ananicy-rules \
    --install scx-manager \
    --install scx-scheds \
    
# 4. ENABLE SERVICES
# This ensures your tuning starts automatically on boot.
systemctl enable ananicy-cpp

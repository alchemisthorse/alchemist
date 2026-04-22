#!/bin/bash
set -ouex pipefail

# 1. ADD REPOS
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. REMOVE CONFLICTS & BLOAT
# We MUST remove power-profiles-daemon so Tuned can work.
rpm-ostree override remove \
    power-profiles-daemon \
    steamdeck-dsp \
    steamdeck-firmware \
    jupiter-hw-support \
    jupiter-fan-control

# 3. THE KERNEL SWAP
# This swaps the kernel and adds the CachyOS-specific performance tools.
rpm-ostree override replace \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos \
    kernel kernel-core kernel-modules kernel-modules-extra kernel-modules-core \
    --install kernel-cachyos-devel-matched \
    --install cachyos-settings \
    --install cachyos-addons \
    --install ananicy-cpp \
    --install cachyos-ananicy-rules \
    --install scx-manager \
    --install scx-scheds

# 4. ENABLE SERVICES
systemctl enable ananicy-cpp
# Waydroid and Tuned are already enabled in Bazzite, 
# but running these again doesn't hurt just to be safe:
systemctl enable waydroid-container.service
systemctl enable tuned

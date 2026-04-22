#!/bin/bash
set -ouex pipefail

# 1. Enable both COPR repositories
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. STEP ONE: Replace the Kernel
# We use --from to point specifically to the kernel-cachyos repo.
# The A=B syntax maps the standard Fedora names to the CachyOS names.
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos \
    kernel=kernel-cachyos \
    kernel-core=kernel-cachyos-core \
    kernel-modules=kernel-cachyos-modules \
    kernel-modules-extra=kernel-cachyos-modules-extra \
    kernel-modules-core=kernel-cachyos-modules-core

# 3. STEP TWO: Install Addons
# These are new packages, so we do a standard install. 
# rpm-ostree will find these in the kernel-cachyos-addons repo.
rpm-ostree install \
    kernel-cachyos-devel-matched \
    cachyos-settings \
    cachyos-addons \
    ananicy-cpp \
    cachyos-ananicy-rules \
    scx-manager \
    scx-tools \
    scx-scheds

# 4. Final System Configuration
systemctl enable ananicy-cpp

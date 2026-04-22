#!/bin/bash
set -ouex pipefail

# 1. Enable the LTO kernel repo and the Addons repo
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. THE KERNEL SWAP (Using the LTO Repo)
# Notice we added the .lto suffix to the package names to match your screenshot
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto \
    kernel=kernel-cachyos-lto \
    kernel-core=kernel-cachyos-lto-core \
    kernel-modules=kernel-cachyos-lto-modules \
    kernel-modules-extra=kernel-cachyos-lto-modules-extra \
    kernel-modules-core=kernel-cachyos-lto-modules-core

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

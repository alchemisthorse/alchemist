# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# 1. Base Image - Starting from Bazzite (Gaming Fedora)
FROM ghcr.io/ublue-os/bazzite:stable

### MODIFICATIONS

# 2. RUN THE BUILD SCRIPT
# This runs your Alchemist build.sh (with CachyOS kernel/addons)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# 3. INTEL ARC A750 OPTIMIZATION (Device 56a1)
# This forces the modern Xe driver stack for your GPU
RUN rpm-ostree kargs --append="i915.force_probe=!56a1" --append="xe.force_probe=56a1"

### LINTING
RUN bootc container lint

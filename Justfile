# Check if the CachyOS kernel and Intel Arc tweaks are active (run this after installing)
check-alchemist:
    @echo "--- Kernel Version ---"
    uname -r
    @echo "--- Intel Arc Driver Status ---"
    cat /proc/cmdline | grep xe && echo "Xe Driver Active!" || echo "Xe Driver NOT found in boot args"
    @echo "--- Sched-ext Status ---"
    scx_loader --list-schedulers || echo "scx-manager not running yet"

# Install Bazaar (Flatpak Store) - Run this once you boot into your new OS
install-bazaar:
    flatpak install flathub io.github.arunsivaramanneo.Bazaar -y

# Quick update for your custom build
update:
    rpm-ostree upgrade
    flatpak update -y

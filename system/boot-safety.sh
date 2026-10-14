#!/usr/bin/env bash
# Boot safety setup for this Arch install (GRUB + btrfs, archinstall layout).
#
# Run ONE phase at a time as root, and reboot after each to confirm it boots:
#
#   sudo bash system/boot-safety.sh check     # read-only: show current state
#   sudo bash system/boot-safety.sh phase1    # consistent initramfs + linux-lts + UKI fallback entry
#   sudo bash system/boot-safety.sh phase2    # ESP -> /efi, kernels onto btrfs (/boot inside @)
#   sudo bash system/boot-safety.sh phase3    # snapper + snap-pac + grub-btrfs
#   sudo bash system/boot-safety.sh phase4    # tidy GRUB menu + Catppuccin theme
#
# Afterwards:
#   sudo bash system/boot-safety.sh rollback <N>   # make snapshot N the new root
#   sudo bash system/boot-safety.sh cleanup-esp    # remove stale kernels from the ESP (after phase2 reboot)
#
# See docs/boot-recovery.md for what to do when things go wrong.

set -euo pipefail

UKI_LABEL="Arch Linux (UKI fallback)"
TS=$(date +%Y%m%d-%H%M%S)
TOP=/run/btrfs-top
THEME_REV=0a37ab19f654e77129b409fed371891c01ffd0b9   # catppuccin/grub, MIT
THEME_DIR=/boot/grub/themes/catppuccin-mocha

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }
ok()   { echo "  [ok] $*"; }
# expect "description" cmd args...  -> ok, or abort loudly
expect() { local d=$1; shift; if "$@"; then ok "$d"; else die "check failed: $d"; fi; }

confirm() {
    read -r -p "$1 [y/N] " ans
    [[ $ans == [yY] ]] || die "aborted"
}

need_root() { [[ $EUID -eq 0 ]] || die "run with sudo"; }

root_dev() { findmnt -no SOURCE /home | sed 's/\[.*//'; }
root_uuid() { blkid -s UUID -o value "$(root_dev)"; }

# Directory the ESP is currently mounted on (/boot before phase2, /efi after).
esp_mount() {
    if mountpoint -q /efi; then echo /efi
    elif [[ $(findmnt -no FSTYPE /boot 2>/dev/null) == vfat ]]; then echo /boot
    else die "cannot find the mounted ESP"; fi
}

# Set KEY=VALUE in /etc/default/grub, replacing or appending.
grub_set() {
    local key=$1 val=$2
    if grep -q "^#\?${key}=" /etc/default/grub; then
        sed -i "s|^#\?${key}=.*|${key}=${val}|" /etc/default/grub
    else
        echo "${key}=${val}" >> /etc/default/grub
    fi
}

# Classic kernel+initramfs images for GRUB (and grub-btrfs). 'linux' also
# builds a UKI on the ESP that the firmware can boot directly, bypassing GRUB.
# No all-hardware fallback images: linux-lts, the UKI and snapshots cover that.
write_presets() {
    local esp=$1
    cat > /etc/mkinitcpio.d/linux.preset <<EOF
# Managed by dotfiles/system/boot-safety.sh
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default' 'uki')

default_image="/boot/initramfs-linux.img"

uki_uki="${esp}/EFI/Linux/arch-linux.efi"
EOF
    cat > /etc/mkinitcpio.d/linux-lts.preset <<EOF
# Managed by dotfiles/system/boot-safety.sh
ALL_kver="/boot/vmlinuz-linux-lts"
PRESETS=('default')

default_image="/boot/initramfs-linux-lts.img"
EOF
}

# Every initramfs must be built for the same kernel version as its vmlinuz.
verify_images() {
    local k kver iver img
    for k in linux linux-lts; do
        kver=$(file -bL "/boot/vmlinuz-$k" | grep -oP 'version \K\S+') \
            || die "/boot/vmlinuz-$k missing or unreadable"
        img=/boot/initramfs-$k.img
        iver=$(lsinitcpio "$img" | grep -oP '^usr/lib/modules/\K[^/]+' | sort -u) \
            || die "$img missing or unreadable"
        [[ $kver == "$iver" ]] || die "$img is for $iver but vmlinuz-$k is $kver"
        ok "$img matches $kver"
    done
}

grub_install() {
    local esp=$1
    grub-install --target=x86_64-efi --efi-directory="$esp" --boot-directory=/boot --bootloader-id=GRUB
    # Firmware fallback path (\EFI\BOOT\BOOTX64.EFI). This laptop currently
    # boots via this path, so it must point at the same GRUB.
    grub-install --target=x86_64-efi --efi-directory="$esp" --boot-directory=/boot --removable
}

# Extra GRUB menu entries. Numbered to sort after the kernels: 25 lands before
# "UEFI Firmware Settings" (30), 42 after the snapshots submenu (41).
write_grub_entries() {
    local esp_uuid=$1
    rm -f /etc/grub.d/45_uki_fallback   # older name, sorted after the snapshots
    # The ESP UUID never changes, so this entry keeps working after phase2.
    cat > /etc/grub.d/25_uki_fallback <<EOF
#!/bin/sh
# Managed by dotfiles/system/boot-safety.sh: boot the UKI on the ESP from GRUB.
cat <<'ENTRY'
menuentry '$UKI_LABEL' --class arch {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root $esp_uuid
    chainloader /EFI/Linux/arch-linux.efi
}
ENTRY
EOF
    # One clear USB entry instead of GRUB's per-firmware-entry BootNext list.
    # Looked up at grub-mkconfig time; emits nothing if the firmware has none.
    cat > /etc/grub.d/42_usb_boot <<'EOF'
#!/bin/sh
# Managed by dotfiles/system/boot-safety.sh: reboot once into the USB stick.
num=$(efibootmgr 2>/dev/null | awk -F'\t' '$1 ~ /^Boot[0-9A-F]{4}\*? EFI USB Device$/ {print substr($1, 5, 4); exit}')
[ -n "$num" ] || exit 0
echo "Adding boot menu entry for USB stick (Boot$num)" >&2
cat <<ENTRY
if [ "\$grub_platform" = "efi" ]; then
  menuentry 'Boot from USB stick' --class efi {
    if bootnext $num; then
      reboot
    fi
  }
fi
ENTRY
EOF
    chmod +x /etc/grub.d/25_uki_fallback /etc/grub.d/42_usb_boot
}

install_theme() {
    local tmp; tmp=$(mktemp -d)
    curl -fsSL "https://github.com/catppuccin/grub/archive/$THEME_REV.tar.gz" \
        | tar -xz -C "$tmp" --strip-components=1
    rm -rf "$THEME_DIR"
    mkdir -p "$(dirname "$THEME_DIR")"
    cp -r "$tmp/src/catppuccin-mocha-grub-theme" "$THEME_DIR"
    rm -rf "$tmp"
    # Minimal: drop the cat logo and move the menu up into the space it used.
    awk '/^\+ image \{/ {skip=1} skip && /^\}/ {skip=0; next} !skip' \
        "$THEME_DIR/theme.txt" > "$THEME_DIR/theme.txt.new"
    mv "$THEME_DIR/theme.txt.new" "$THEME_DIR/theme.txt"
    sed -i 's/^\(\s*top = \)60%/\140%/' "$THEME_DIR/theme.txt"
    rm -f "$THEME_DIR/logo.png"
    ok "theme installed to $THEME_DIR"
}

# Shorten "Arch Linux, with Linux linux-lts" to "Arch Linux, with linux-lts".
# 10_linux belongs to the grub package, so a pacman hook re-applies the edit
# after every grub upgrade.
apply_grub_titles() {
    sed -i 's/with Linux %s/with %s/' /etc/grub.d/10_linux
    mkdir -p /etc/pacman.d/hooks
    cat > /etc/pacman.d/hooks/90-grub-titles.hook <<'EOF'
# Managed by dotfiles/system/boot-safety.sh
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = grub

[Action]
Description = Shortening GRUB kernel entry titles...
When = PostTransaction
Exec = /usr/bin/sed -i "s/with Linux %s/with %s/" /etc/grub.d/10_linux
EOF
    ok "kernel entry titles shortened (pacman hook keeps it after grub updates)"
}

# Firmware boot entry for the UKI, placed last in BootOrder so it is only
# used when picked from the F12 boot menu.
ensure_uki_entry() {
    local esp_dev disk part num order entries
    entries=$(efibootmgr)
    if grep -qF "$UKI_LABEL" <<<"$entries"; then ok "firmware entry '$UKI_LABEL' exists"; return; fi
    esp_dev=$(findmnt -no SOURCE "$(esp_mount)")
    disk=/dev/$(lsblk -no PKNAME "$esp_dev")
    part=$(cat "/sys/class/block/$(basename "$esp_dev")/partition")
    efibootmgr --create --disk "$disk" --part "$part" \
        --label "$UKI_LABEL" --loader '\EFI\Linux\arch-linux.efi' >/dev/null
    entries=$(efibootmgr)
    num=$(grep -F "$UKI_LABEL" <<<"$entries" | grep -oP '^Boot\K[0-9A-F]{4}')
    order=$(awk '/^BootOrder/ {print $2}' <<<"$entries" | tr , '\n' | grep -vx "$num" | paste -sd,)
    efibootmgr -o "$order,$num" >/dev/null
    ok "added firmware entry Boot$num '$UKI_LABEL' (last in boot order)"
}

cmd_check() {
    info "Mounts"
    for m in / /boot /efi /.snapshots; do findmnt -no TARGET,SOURCE,FSTYPE "$m" || true; done
    info "Current kernel cmdline (BOOT_IMAGE present = booted via GRUB linux entry)"
    cat /proc/cmdline
    info "Kernel presets"
    grep -H -v '^#' /etc/mkinitcpio.d/*.preset | grep -v ':$' || true
    info "Files on the ESP"
    find "$(esp_mount)" -maxdepth 3 -type f | sort
    info "GRUB menu entries and what they boot"
    grep -E "^\s*(menuentry|submenu|linux|initrd|chainloader|uki)\b" /boot/grub/grub.cfg 2>/dev/null || echo "  (no /boot/grub/grub.cfg)"
    info "Firmware boot entries"
    efibootmgr
    info "Btrfs subvolumes"
    btrfs subvolume list /
    info "Snapper"
    snapper list 2>/dev/null || echo "  (not configured)"
}

cmd_phase1() {
    local esp esp_uuid; esp=$(esp_mount)
    [[ $esp == /boot ]] || die "phase1 expects the ESP on /boot (already past phase2?)"
    cat <<EOF
Phase 1 will:
  - back up the ESP to /root/esp-backup-$TS.tar
  - rewrite kernel presets: classic initramfs for GRUB, UKI kept as an extra
  - install linux-lts and rebuild every initramfs
  - re-enable GRUB's normal Linux entries (archinstall disabled 10_linux) and disable
    archinstall's 15_uki, so both kernels are listed at top level (linux stays the default)
  - add an explicit "$UKI_LABEL" entry to the GRUB menu
  - reinstall GRUB (named entry + firmware fallback path) and regenerate grub.cfg
  - add a firmware boot entry for the UKI, last in boot order
EOF
    confirm "Continue?"

    tar -C /boot -cf "/root/esp-backup-$TS.tar" . && ok "ESP backed up"
    cp -a /etc/default/grub "/etc/default/grub.bak-$TS"
    cp -a /etc/mkinitcpio.d/linux.preset "/root/linux.preset.bak-$TS"
    esp_uuid=$(blkid -s UUID -o value "$(findmnt -no SOURCE /boot)")

    write_presets /boot
    pacman -S --needed --noconfirm linux-lts
    mkinitcpio -P

    grub_set GRUB_DISABLE_SUBMENU y
    grub_set GRUB_TOP_LEVEL '"/boot/vmlinuz-linux"'
    # Keep zram as the only swap compressor, as on the current cmdline.
    grep -q 'zswap.enabled=0' /etc/default/grub || \
        sed -i 's|^GRUB_CMDLINE_LINUX="|GRUB_CMDLINE_LINUX="zswap.enabled=0 |' /etc/default/grub

    chmod +x /etc/grub.d/10_linux
    [[ -e /etc/grub.d/15_uki ]] && chmod -x /etc/grub.d/15_uki
    write_grub_entries "$esp_uuid"

    grub_install /boot
    grub-mkconfig -o /boot/grub/grub.cfg
    ensure_uki_entry

    info "Verifying"
    verify_images
    expect "UKI present" test -f /boot/EFI/Linux/arch-linux.efi
    expect "grub.cfg has linux-lts" grep -q 'vmlinuz-linux-lts' /boot/grub/grub.cfg
    expect "grub.cfg has initramfs-linux.img" grep -q 'initramfs-linux.img' /boot/grub/grub.cfg
    expect "fallback GRUB binary present" test -f /boot/EFI/BOOT/BOOTX64.EFI
    expect "grub.cfg has the UKI fallback entry" grep -q 'chainloader /EFI/Linux/arch-linux.efi' /boot/grub/grub.cfg
    efibootmgr

    cat <<EOF

Phase 1 done. Now reboot and check:
  - the GRUB menu shows "Arch Linux, with Linux linux" and "... linux-lts"
  - the default entry boots, and 'cat /proc/cmdline' starts with BOOT_IMAGE=
  - optional: reboot, pick linux-lts, confirm it boots too
  - optional: reboot, pick "$UKI_LABEL", confirm it boots too
  - 'efibootmgr' still lists GRUB and "$UKI_LABEL" (the firmware may drop them;
    that's OK, its fallback path still loads GRUB)
Then run phase2.
EOF
}

cmd_phase2() {
    local esp_dev esp_uuid
    [[ $(esp_mount) == /boot ]] || die "phase2 expects the ESP on /boot (already done?)"
    grep -q BOOT_IMAGE= /proc/cmdline || die "not booted through GRUB; finish and reboot after phase1 first"
    [[ -f /boot/vmlinuz-linux-lts ]] || die "run phase1 first"
    cat <<EOF
Phase 2 will:
  - back up the ESP to /root/esp-backup-$TS.tar and /etc/fstab to /etc/fstab.bak-$TS
  - mount the ESP at /efi instead of /boot
  - put /boot (kernels, initramfs, grub.cfg) on the btrfs root so snapshots include them
  - reinstall kernels and GRUB, regenerate grub.cfg
The old kernels stay on the ESP until you run cleanup-esp.
EOF
    confirm "Continue?"

    esp_dev=$(findmnt -no SOURCE /boot)
    esp_uuid=$(blkid -s UUID -o value "$esp_dev")
    tar -C /boot -cf "/root/esp-backup-$TS.tar" . && ok "ESP backed up"
    cp -a /etc/fstab "/etc/fstab.bak-$TS"

    # The old kernels and GRUB stay on the ESP, so undoing is just remounting it.
    trap "echo 'FAILED part way. To undo: umount /efi; cp /etc/fstab.bak-$TS /etc/fstab; systemctl daemon-reload; mount $esp_dev /boot' >&2" ERR

    umount /boot
    if [[ -n $(ls -A /boot) ]]; then
        mv /boot "/boot.old-$TS" && mkdir /boot
        ok "moved leftover files under /boot to /boot.old-$TS"
    fi
    mkdir -p /efi
    awk -v u="UUID=$esp_uuid" 'BEGIN{OFS="\t"} $1==u && $2=="/boot" {$2="/efi"} {print}' \
        "/etc/fstab.bak-$TS" > /etc/fstab
    grep -qP "^UUID=$esp_uuid\s+/efi\s" /etc/fstab || die "fstab edit failed"
    systemctl daemon-reload
    mount /efi && ok "ESP mounted at /efi"

    write_presets /efi
    # Repopulates /boot via the kernel and microcode packages' hooks.
    pacman -S --noconfirm linux linux-lts $(pacman -Qq intel-ucode amd-ucode 2>/dev/null || true)

    grub_install /efi
    grub-mkconfig -o /boot/grub/grub.cfg
    trap - ERR

    info "Verifying"
    verify_images
    expect "/boot/grub is on btrfs" test "$(grub-probe -t fs /boot/grub)" = btrfs
    expect "grub.cfg loads kernels from @" grep -q '/@/boot/vmlinuz-linux' /boot/grub/grub.cfg
    expect "fallback GRUB binary present" test -f /efi/EFI/BOOT/BOOTX64.EFI
    expect "UKI present" test -f /efi/EFI/Linux/arch-linux.efi

    cat <<EOF

Phase 2 done. Reboot and check:
  - GRUB menu appears and the default entry boots
  - 'cat /proc/cmdline' shows BOOT_IMAGE=/@/boot/vmlinuz-linux
  - 'findmnt /efi' shows the ESP
If GRUB fails: F12 at power-on -> "$UKI_LABEL" boots straight into Arch.
Then run phase3.
EOF
}

cmd_phase3() {
    local uuid
    mountpoint -q /efi && ! mountpoint -q /boot || die "run phase2 first"
    grep -q 'BOOT_IMAGE=/@/boot/' /proc/cmdline || die "reboot after phase2 first"
    # grub-btrfs-overlayfs is a busybox runtime hook; it does nothing under the
    # systemd initramfs hook, and read-only snapshots would then fail to boot.
    grep -qP '^HOOKS=\(.*\bsystemd\b' /etc/mkinitcpio.conf && \
        die "mkinitcpio HOOKS uses 'systemd'; switch to base udev ... (see /etc/mkinitcpio.conf) first"
    cat <<EOF
Phase 3 will:
  - install snapper, snap-pac, grub-btrfs, inotify-tools
  - create an @snapshots subvolume mounted at /.snapshots
  - snapshot / before and after every pacman run, plus hourly/daily timeline snapshots
  - add the grub-btrfs-overlayfs initramfs hook so read-only snapshots boot cleanly
  - list snapshots in the GRUB menu, updated automatically
/home is not snapshotted, so a rollback never loses your files.
EOF
    confirm "Continue?"

    pacman -S --needed --noconfirm snapper snap-pac grub-btrfs inotify-tools
    # snap-pac's hook during that install may have started snapperd, which only
    # reads its config list at startup.
    systemctl stop snapperd.service 2>/dev/null || true
    pkill -x snapperd || true

    if ! snapper --no-dbus -c root get-config >/dev/null 2>&1; then
        mountpoint -q /.snapshots && umount /.snapshots
        [[ -d /.snapshots ]] && rmdir /.snapshots
        snapper --no-dbus -c root create-config /
        # Replace snapper's nested subvolume with a top-level @snapshots so
        # rolling back @ never takes the snapshots with it.
        btrfs subvolume delete /.snapshots
        mkdir /.snapshots
        ok "snapper config 'root' created"
    fi
    # Restart snapperd again so it picks up the config just created.
    systemctl stop snapperd.service 2>/dev/null || true
    pkill -x snapperd || true

    mkdir -p "$TOP"
    mount -o subvolid=5 "$(root_dev)" "$TOP"
    [[ -d $TOP/@snapshots ]] || btrfs subvolume create "$TOP/@snapshots"
    umount "$TOP"

    uuid=$(root_uuid)
    if ! grep -qP '\s/\.snapshots\s' /etc/fstab; then
        cp -a /etc/fstab "/etc/fstab.bak-$TS"
        printf '\n# /dev/%s\nUUID=%s\t/.snapshots\tbtrfs\trw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=/@snapshots\t0 0\n' \
            "$(basename "$(root_dev)")" "$uuid" >> /etc/fstab
    fi
    systemctl daemon-reload
    mountpoint -q /.snapshots || mount /.snapshots
    chmod 750 /.snapshots
    ok "/.snapshots mounted from @snapshots"

    snapper -c root set-config \
        NUMBER_LIMIT=20 NUMBER_LIMIT_IMPORTANT=5 \
        TIMELINE_CREATE=yes TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
        TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0

    if ! grep -q '^HOOKS=.*grub-btrfs-overlayfs' /etc/mkinitcpio.conf; then
        cp -a /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak-$TS"
        sed -i '/^HOOKS=/ s/)$/ grub-btrfs-overlayfs)/' /etc/mkinitcpio.conf
    fi
    mkinitcpio -P

    systemctl enable --now snapper-timeline.timer snapper-cleanup.timer grub-btrfsd.service
    snapper -c root create -d "boot-safety baseline" --userdata important=yes
    grub-mkconfig -o /boot/grub/grub.cfg

    info "Verifying"
    verify_images
    snapper -c root list
    expect "grub-btrfs menu generated" grep -q menuentry /boot/grub/grub-btrfs.cfg
    expect "grub-btrfsd running" systemctl is-active --quiet grub-btrfsd

    cat <<EOF

Phase 3 done. Reboot and check:
  - GRUB has an "Arch Linux snapshots" submenu
  - booting a snapshot from it reaches the desktop (changes there are temporary)
Test a pacman run, then 'snapper list' should show a pre/post pair.
EOF
}

cmd_phase4() {
    local esp esp_uuid
    mountpoint -q /efi && ! mountpoint -q /boot || die "run phase2 first"
    esp=$(esp_mount)
    esp_uuid=$(blkid -s UUID -o value "$(findmnt -no SOURCE "$esp")")
    cat <<EOF
Phase 4 will:
  - stop building the all-hardware fallback initramfs images and delete them
  - drop GRUB's "EFI BootNext" entries; add one "Boot from USB stick" entry
  - move "$UKI_LABEL" up, next to the kernels
  - shorten kernel titles to "Arch Linux, with linux" / "... with linux-lts"
  - install a minimal Catppuccin Mocha GRUB theme, logo removed (catppuccin/grub @ ${THEME_REV:0:7})
EOF
    confirm "Continue?"

    cp -a /etc/default/grub "/etc/default/grub.bak-$TS"

    write_presets "$esp"
    rm -f /boot/initramfs-*-fallback.img
    mkinitcpio -P

    grub_set GRUB_DISABLE_BOOTNEXT true
    write_grub_entries "$esp_uuid"
    apply_grub_titles

    install_theme
    grub_set GRUB_THEME "\"$THEME_DIR/theme.txt\""
    grub-mkconfig -o /boot/grub/grub.cfg

    info "Verifying"
    verify_images
    expect "no fallback initramfs entries" bash -c "! grep -q 'fallback initramfs' /boot/grub/grub.cfg"
    expect "no EFI BootNext entries" bash -c "! grep -q '(EFI BootNext)' /boot/grub/grub.cfg"
    expect "USB stick entry present" grep -q "Boot from USB stick" /boot/grub/grub.cfg
    expect "theme enabled" grep -q "theme=.*catppuccin-mocha" /boot/grub/grub.cfg
    info "Menu"
    grep -E "^\s*(menuentry|submenu) " /boot/grub/grub.cfg | grep -oP "^\s*\w+ '\K[^']+"

    cat <<EOF

Phase 4 done. Reboot to see the new menu.
EOF
}

cmd_rollback() {
    local n=${1:-} src
    [[ $n =~ ^[0-9]+$ ]] || die "usage: rollback <snapshot number>  (see 'snapper list')"
    mkdir -p "$TOP"
    mount -o subvolid=5 "$(root_dev)" "$TOP"
    trap 'umount "$TOP"' EXIT
    src=$TOP/@snapshots/$n/snapshot
    [[ -d $src ]] || die "snapshot $n not found in @snapshots"
    echo "Snapshot $n: $(grep -oP '<description>\K[^<]*' "$TOP/@snapshots/$n/info.xml" || true)"
    echo "The current root (@) will be kept as @.broken-$TS."
    confirm "Make snapshot $n the new root?"
    mv "$TOP/@" "$TOP/@.broken-$TS"
    btrfs subvolume snapshot "$src" "$TOP/@"
    cat <<EOF

Done. Reboot now. Once you are happy with the restored system, delete the old root:
  sudo mount -o subvolid=5 $(root_dev) /mnt && sudo btrfs subvolume delete /mnt/@.broken-$TS && sudo umount /mnt
EOF
}

cmd_cleanup_esp() {
    mountpoint -q /efi && ! mountpoint -q /boot || die "only valid after phase2"
    grep -q 'BOOT_IMAGE=/@/boot/' /proc/cmdline || die "reboot after phase2 first"
    find /efi -maxdepth 1 \( -name 'vmlinuz-*' -o -name 'initramfs-*' -o -name '*-ucode.img' -o -name grub \) -print
    confirm "Delete these stale files from the ESP?"
    find /efi -maxdepth 1 \( -name 'vmlinuz-*' -o -name 'initramfs-*' -o -name '*-ucode.img' \) -delete
    rm -rf /efi/grub
    ok "ESP cleaned"
}

need_root
case ${1:-} in
    check)       cmd_check ;;
    phase1)      cmd_phase1 ;;
    phase2)      cmd_phase2 ;;
    phase3)      cmd_phase3 ;;
    phase4)      cmd_phase4 ;;
    rollback)    cmd_rollback "${2:-}" ;;
    cleanup-esp) cmd_cleanup_esp ;;
    *) sed -n '2,16p' "$0" | sed 's/^# \?//'; exit 1 ;;
esac

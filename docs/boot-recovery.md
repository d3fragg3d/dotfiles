# Boot Recovery

Setup is done by `system/boot-safety.sh` (run phases 1–3 once, rebooting after each).
Layout afterwards: ESP at `/efi`, kernels + `grub.cfg` in `/boot` on the btrfs `@`
subvolume, snapshots in a top-level `@snapshots` subvolume at `/.snapshots`.

Try these in order, from least to most drastic.

## 1. A kernel update broke boot

At the GRUB menu pick **Arch Linux, with Linux linux-lts**, or
**Arch Linux (UKI fallback)** (a separately built image on the ESP). Once booted, fix or downgrade the kernel:

```bash
sudo pacman -U /var/cache/pacman/pkg/linux-<previous-version>-x86_64.pkg.tar.zst
```

## 2. An update broke something (any package)

1. At the GRUB menu open **Arch Linux snapshots** and pick the `pre` snapshot from
   before the bad `pacman` run. It boots read-only with a temporary overlay — changes
   made there are thrown away on reboot.
2. Check things work, then make it permanent:

   ```bash
   sudo snapper list                                # find the snapshot number
   sudo bash ~/projects/dotfiles/system/boot-safety.sh rollback <N>
   sudo reboot
   ```

   The broken root is kept as `@.broken-<timestamp>`; the script prints how to delete it.

`/home` is a separate subvolume and is never rolled back.

## 3. GRUB itself is broken

Power on, tap **F12**, choose **Arch Linux (UKI fallback)**. This boots the
`linux` kernel directly from the ESP, bypassing GRUB. Then reinstall GRUB:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --bootloader-id=GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --removable
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 4. Nothing on the disk boots

Boot the Arch USB (GRUB → **Boot from USB stick**, or F12 → EFI USB Device), then:

```bash
mount -o subvolid=5 /dev/nvme0n1p2 /mnt
ls /mnt/@snapshots                     # each number has info.xml with date + description
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
umount /mnt
reboot
```

To repair instead of rolling back, chroot in:

```bash
mount -o subvol=@ /dev/nvme0n1p2 /mnt
arch-chroot /mnt
mount -a                  # inside the chroot: mounts /efi, /home, /.snapshots etc. from fstab
```

## 5. The disk or board dies

Snapshots live on the same SSD — they are not a backup. Keep an off-machine copy of
at least `/home` (external drive / NAS).

## Health checks

```bash
sudo snapper list                      # pre/post pairs after each pacman run
systemctl status grub-btrfsd          # keeps the GRUB snapshot menu current
efibootmgr                            # GRUB + UKI fallback entries present
sudo fwupdmgr get-updates             # Framework BIOS / EC firmware updates
```

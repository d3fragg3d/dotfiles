#!/usr/bin/env bash
set -e

DOTFILES="$HOME/projects/dotfiles"

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# ── Official packages ──────────────────────────────────────────────────────────


echo "==> Installing packages..."

sudo pacman -S --needed --noconfirm \
  hyprland \
  waybar \
  kitty \
  fuzzel \
  hyprlock \
  hypridle \
  awww \
  hyprsunset \
  hyprpolkitagent \
  swaync \
  thunar \
  grim \
  slurp \
  swappy \
  wl-clipboard \
  cliphist \
  brightnessctl \
  playerctl \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  nwg-look \
  gnome-themes-extra \
  bluez \
  bluez-utils \
  blueman \
  swayosd \
  eza \
  bat \
  zoxide \
  fzf \
  starship \
  fastfetch \
  btop \
  iwd \
  pavucontrol \
  pipewire \
  pipewire-pulse \
  wireplumber \
  libnotify \
  flatpak \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji \
  stow \
  xdg-user-dirs \
  git \
  neovim \
  ripgrep \
  fd \
  jq \
  curl \
  python \
  cmake \
  cpio \
  base-devel \
  syncthing \
  sddm \
  qt6-svg \
  ly \
  tlp \
  thermald \
  powertop \
  fwupd \
  udisks2 \
  pacman-contrib \
  earlyoom
# ly = alternative login manager, sddm is preferred

# ── AUR packages ───────────────────────────────────────────────────────────────

if ! command -v yay &>/dev/null; then
  echo "==> Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  pushd /tmp/yay
  makepkg -si --noconfirm
  popd
  rm -rf /tmp/yay
fi

echo "==> Installing AUR packages..."
yay -S --needed --noconfirm \
  hyprpicker \
  wallust-git \
  nordvpn-bin \
  where-is-my-sddm-theme \
  gruvbox-dark-gtk \
  wlogout

# ── Flatpak ────────────────────────────────────────────────────────────────────

echo "==> Installing Flatpak apps..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub app.zen_browser.zen

# ── Services ───────────────────────────────────────────────────────────────────

echo "==> Enabling services..."
sudo systemctl enable iwd
sudo systemctl enable bluetooth
sudo systemctl enable sddm
sudo systemctl enable tlp
sudo systemctl enable thermald
sudo systemctl enable earlyoom
sudo systemctl enable udisks2
sudo systemctl enable fstrim.timer
sudo systemctl enable --now nordvpnd
sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
sudo pacman -Rns --noconfirm power-profiles-daemon 2>/dev/null || true

echo "==> Configuring fwupd ESP location..."
printf '[uefi_capsule]\nEspLocation=/boot\n' | sudo tee /etc/fwupd/uefi_capsule.conf > /dev/null
# sudo systemctl enable ly  # alternative: uncomment and disable sddm to use ly instead
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service || true
systemctl --user enable syncthing || true

# ── Directories ────────────────────────────────────────────────────────────────

echo "==> Creating directories..."
# Flatpak apps (Zen, etc.) are sandboxed to only the XDG user dirs (e.g.
# ~/Downloads) — without this, downloads silently land in the flatpak's
# private cache instead of anywhere visible.
xdg-user-dirs-update
mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/syncthing/obsidian/scratch

# ── Dotfiles ───────────────────────────────────────────────────────────────────

echo "==> Installing oh-my-bash..."
if [ ! -d "$HOME/.oh-my-bash" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
fi

echo "==> Backing up pre-existing dotfiles that would conflict with stow..."
# oh-my-bash's installer (and other tools) write real files where stow needs to
# place a symlink; stow refuses to overwrite them, which aborts the rest of this
# script under `set -e`. Back them up instead of clobbering them.
for f in ~/.bashrc ~/.gitconfig ~/.config/mimeapps.list; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mv "$f" "$f.bak"
  fi
done

echo "==> Stowing dotfiles..."
cd "$DOTFILES"

stow -t ~ hyprland
stow -t ~ waybar
stow -t ~ fuzzel
stow -t ~ swaync
stow -t ~ kitty
stow -t ~ nvim
stow -t ~ bash
stow -t ~ git
stow -t ~ mimeapps
stow -t ~ gtk
stow -t ~ wlogout
stow -t ~ starship
stow -t ~ wallust

echo "==> Installing SDDM config..."
sudo mkdir -p /etc/sddm.conf.d
sudo cp "$DOTFILES/sddm/sddm.conf" /etc/sddm.conf.d/hyprland.conf
SDDM_THEME_DIR="/usr/share/sddm/themes/where_is_my_sddm_theme"
sudo cp "$DOTFILES/sddm/theme.conf" "$SDDM_THEME_DIR/theme.conf"
sudo mkdir -p "$SDDM_THEME_DIR/backgrounds"
sudo cp "$DOTFILES/sddm/backgrounds/mountains.svg" "$SDDM_THEME_DIR/backgrounds/mountains.svg"

echo "==> Stowing ly config (alternative login manager)..."
sudo rm -f /etc/ly/config.ini
sudo stow -t /etc/ly ly

# ── Permissions ────────────────────────────────────────────────────────────────

echo "==> Bootstrapping wallust defaults..."
[ -f ~/.config/waybar/style.css ]      || cp "$DOTFILES/waybar/.config/waybar/style.css"         ~/.config/waybar/style.css
[ -f ~/.config/swaync/style.css ]      || cp "$DOTFILES/swaync/.config/swaync/style.css"         ~/.config/swaync/style.css
[ -f ~/.config/starship.toml ]         || cp "$DOTFILES/starship/.config/starship.toml"           ~/.config/starship.toml
[ -f ~/.config/fuzzel/fuzzel.ini ]     || cp "$DOTFILES/fuzzel/.config/fuzzel/fuzzel.ini"         ~/.config/fuzzel/fuzzel.ini
# colors.lua / colors.css are generated by wallust and gitignored — seed them
# with a default so Hyprland/waybar don't error before the first wallust run.
[ -f ~/.config/hypr/colors.lua ]       || printf 'return {\n    accent = "rgb(c4956a)",\n    border_inactive = "rgb(252525)",\n}\n' > ~/.config/hypr/colors.lua
# TODO: drop this once hyprland.conf is removed (see wallust-hyprland.sh)
[ -f ~/.config/hypr/colors.conf ]      || printf '$accent          = rgb(c4956a)\n$border_inactive = rgb(252525)\n' > ~/.config/hypr/colors.conf
[ -f ~/.config/waybar/colors.css ]     || printf '@define-color accent #c4956a;\n' > ~/.config/waybar/colors.css

echo "==> Setting up script permissions..."
chmod +x ~/.config/hypr/scripts/*.sh

echo "==> Adding user to groups..."
sudo usermod -aG video "$USER"
sudo usermod -aG nordvpn "$USER"

# ── Done ───────────────────────────────────────────────────────────────────────

echo ""
echo "==> Done!"
echo ""
echo "Next steps:"
echo "  1. Log out and select Hyprland from the display manager"
echo "  2. Log back in with your NordVPN credentials: nordvpn login"
echo "  3. Disable the NordVPN tray/GUI (CLI-only): nordvpn set tray disable"
echo "  4. Neovim plugins install automatically on first launch"
echo "  5. Re-login for group changes (video, nordvpn) to take effect"

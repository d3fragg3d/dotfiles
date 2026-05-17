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
  fastfetch \
  btop \
  networkmanager \
  network-manager-applet \
  nm-connection-editor \
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
  ly  # alternative login manager — sddm is preferred

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
  hyprswitch \
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
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable sddm
# sudo systemctl enable ly  # alternative: uncomment and disable sddm to use ly instead
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service || true
systemctl --user enable syncthing || true

# ── Directories ────────────────────────────────────────────────────────────────

echo "==> Creating directories..."
mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/syncthing/obsidian/scratch

# ── Dotfiles ───────────────────────────────────────────────────────────────────

echo "==> Installing oh-my-bash..."
if [ ! -d "$HOME/.oh-my-bash" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
fi

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

echo "==> Installing system sleep hooks..."
sudo cp "$DOTFILES/system/systemd/system-sleep/nm-wifi-resume" /usr/lib/systemd/system-sleep/nm-wifi-resume
sudo chmod +x /usr/lib/systemd/system-sleep/nm-wifi-resume

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
echo "  3. Neovim plugins install automatically on first launch"
echo "  4. Re-login for group changes (video, nordvpn) to take effect"

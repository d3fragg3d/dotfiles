#!/usr/bin/env bash
set -e

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing packages..."

sudo pacman -S --needed --noconfirm \
  hyprland \
  waybar \
  kitty \
  fuzzel \
  dunst \
  hyprlock \
  hypridle \
  thunar \
  grim \
  slurp \
  wl-clipboard \
  cliphist \
  brightnessctl \
  playerctl \
  networkmanager \
  nm-connection-editor \
  pavucontrol \
  pipewire \
  pipewire-pulse \
  wireplumber \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji \
  stow \
  git \
  vim \
  emacs \
  stow

echo "==> Enabling services..."

sudo systemctl enable NetworkManager
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service || true

echo "==> Creating folders..."

mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots

echo "==> Applying dotfiles..."

stow -t ~ hyprland
stow -t ~ waybar
stow -t ~ fuzzel
stow -t ~ dunst
stow -t ~ kitty

echo "==> Applying ly theme..."
sudo rm -f /etc/ly/config.ini
sudo stow -t /etc/ly ly

echo "==> Adding user to video group (needed for brightnessctl)..."
sudo usermod -aG video "$USER"

echo "==> Done."
echo "Log out, choose Hyprland, and enjoy."
echo "NOTE: Re-login for video group (brightness keys) to take effect."

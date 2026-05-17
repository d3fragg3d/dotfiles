# Dotfiles

Chris King's Arch Linux dotfiles for a Hyprland-based desktop.

## Stack

| Role | Tool |
|---|---|
| Window manager | Hyprland |
| Bar | Waybar |
| Terminal | Kitty |
| Editor | Neovim (LazyVim) |
| Launcher | Fuzzel |
| Notifications | SwayNC |
| Display manager | SDDM (preferred) / Ly (available) |
| Notes | Obsidian + Syncthing |
| Browser | Zen Browser |
| Power menu | wlogout |
| Lock screen | hyprlock |
| Wallpaper | awww |
| Bluetooth | blueman |
| OSD | SwayOSD |
| GTK theme | Adwaita-dark / gruvbox-dark-gtk |
| System monitor | btop |

---

## Installation

```bash
git clone git@github.com:d3fragg3d/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash install.sh
```

`install.sh` installs all packages, stows configs, and enables services.

To stow an individual package:

```bash
stow -t ~ hyprland
```

To remove:

```bash
stow -D -t ~ hyprland
```

---

## Hyprland

### Plugins

#### hyprswitch (window switcher)

```bash
yay -S hyprswitch
```

Bind: `Alt + Tab` / `Alt + Shift + Tab` — window switcher with previews.

### Key bindings

| Bind | Action |
|---|---|
| `Super + Return` | Open terminal |
| `Super + B` | Open browser |
| `Super + R` | Open launcher (fuzzel) |
| `Super + N` | Workspace 3 — open Neovim |
| `Super + S` | Workspace 3 — open today's scratch note |
| `Super + V` | Clipboard history picker |
| `Super + C` | Toggle notification drawer |
| `Super + Shift + S` | Screenshot region → clipboard |
| `Super + Ctrl + S` | Screenshot region → file |
| `Super + Shift + L` | Lock screen |
| `Super + Shift + N` | Toggle night mode |
| `Super + /` | Toggle scratchpad terminal |
| `Alt + Tab` | Window switcher |

### Scratchpad terminal

`Super + /` toggles a Quake-style drop-down terminal. It spans the full screen width at 40% height, slides in from the bottom, and sits above Waybar. The window lives in `special:scratchpad` so it persists across workspace switches.

---

## Neovim

Built on [LazyVim](https://lazyvim.org). Config lives in `nvim/.config/nvim/`.

### Extras enabled

```lua
{ import = "lazyvim.plugins.extras.dap.core" }
{ import = "lazyvim.plugins.extras.lang.go" }
{ import = "lazyvim.plugins.extras.lang.python" }
{ import = "lazyvim.plugins.extras.lang.markdown" }
```

### Notable plugins

| Plugin | Purpose |
|---|---|
| `obsidian.nvim` | Obsidian vault integration |
| `render-markdown.nvim` | Inline markdown rendering |
| `oil.nvim` | File manager (press `-`) |
| `neo-tree.nvim` | File tree (`Space + e`) |

### Obsidian / notes keybinds

| Bind | Action |
|---|---|
| `Space + f + n` | New note — prompts for filename and title, writes frontmatter |
| `Space + f + s` | Open today's scratch note (`~/syncthing/obsidian/scratch/YYYY-MM-DD.md`) |
| `Space + f + b` | Buffer picker |

### render-markdown.nvim

Renders markdown inline in the buffer (headings, checkboxes, code blocks, callouts). Pairs with `obsidian.nvim` which has `ui = { enable = false }` to avoid conflicts.

Treesitter parsers are auto-installed via `plugins/treesitter.lua`:

```lua
ensure_installed = { "markdown", "markdown_inline" }
```

Markdown linting is disabled (`plugins/lint.lua`) as it's too noisy for personal notes.

---

## Notifications (SwayNC)

Migrated from dunst. SwayNC provides a notification drawer in addition to popup toasts.

```bash
sudo pacman -S swaync
stow -t ~ swaync
```

| Action | How |
|---|---|
| Toggle drawer | `Super + C` or click bell in waybar |
| Toggle Do Not Disturb | Right-click bell in waybar |
| Dismiss notification | Click X on the notification |
| Clear all | Click "Clear All" in the drawer |

---

## Display Manager

**SDDM** is the preferred login manager, themed with [where-is-my-sddm-theme](https://github.com/keyitdev/where-is-my-sddm-theme) and a custom gruvbox geometric mountain background.

Config lives in `sddm/`:

| File | Destination |
|---|---|
| `sddm.conf` | `/etc/sddm.conf.d/hyprland.conf` |
| `theme.conf` | `/usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf` |
| `backgrounds/mountains.svg` | `/usr/share/sddm/themes/where_is_my_sddm_theme/backgrounds/` |

`install.sh` handles placement automatically.

**Ly** is kept as a drop-in alternative. To switch to Ly:

```bash
sudo systemctl disable sddm
sudo systemctl enable ly
```

To switch back to SDDM:

```bash
sudo systemctl disable ly
sudo systemctl enable sddm
```

---

## Syncthing

Syncthing runs as a user service:

```bash
systemctl --user enable --now syncthing
```

A notification script polls the Syncthing event API and fires dunst/swaync alerts when sync starts and completes. It runs at login via `exec-once` in `hyprland.conf`:

```
~/.config/hypr/scripts/syncthing-notify.sh
```

The Obsidian vault syncs at `~/syncthing/obsidian/`.

---

## Bluetooth

Managed via `bluez` + `blueman`. The Waybar bluetooth module shows connection status and opens `blueman-manager` on click.

```bash
sudo systemctl enable --now bluetooth
```

Connected devices appear in the bar with the device name. Click the icon to open the full Bluetooth manager.

---

## Networking

NetworkManager handles all networking. `nmtui` is used for a TUI (click the network module in Waybar).

### WiFi resume after sleep

A systemd sleep hook at `/usr/lib/systemd/system-sleep/nm-wifi-resume` cycles the WiFi radio on wake, forcing NetworkManager to reconnect. Without it, WiFi can fail to reconnect after suspend.

Stored in `system/systemd/system-sleep/nm-wifi-resume` — `install.sh` copies it into place.

---

## Wallpaper

Managed by `awww` (a maintained fork of `swww`). The daemon starts at login via `exec-once` and a cycling script randomly selects a wallpaper from `~/Pictures/` every 10 minutes with a smooth wipe transition.

Script: `~/.config/hypr/scripts/wallpaper.sh`

To change the interval, edit `INTERVAL` (in seconds) at the top of the script.

---

## Lock Screen

`hyprlock` is used for locking. Config lives in `hyprland/.config/hypr/hyprlock.conf`.

Themed with the Sandstone palette — blurred wallpaper background, large clock, date label, and a styled password input field.

| Bind | Action |
|---|---|
| `Super + Shift + L` | Lock screen |

Lock is not included in the wlogout power menu to avoid a layer-shell conflict where wlogout reappears after unlock.

---

## SwayOSD

Volume and brightness keys use SwayOSD for a proper ephemeral OSD overlay instead of notifications. The server runs at login via `exec-once` in `hyprland.conf`.

If the OSD doesn't appear after a fresh install, start the server manually to confirm it works:

```bash
swayosd-server &
```

Then test with a volume key. It should auto-start on next login.

---

## Power Menu (wlogout)

Click the battery icon in Waybar to open wlogout. Config lives in `wlogout/.config/wlogout/`.

| Action | Keybind |
|---|---|
| Logout | `e` |
| Suspend | `s` |
| Reboot | `r` |
| Shutdown | `p` |

Lock is intentionally excluded — use `Super + Shift + L` instead. Running hyprlock from wlogout causes a layer-shell conflict where wlogout reappears after unlock.

The launch script (`scripts/wlogout.sh`) calculates margins from the live screen resolution so button size is consistent across different displays.

---

## Terminal Tools

Aliases in `.bashrc` replace standard commands transparently:

| Command | Replaces | Notes |
|---|---|---|
| `eza` | `ls` | Icons, git status via `ll` |
| `bat` | `cat` | Syntax highlighting, no paging |
| `zoxide` | `cd` | Learns frequently visited dirs |

`fastfetch` runs on every new terminal open. `btop` is available as a full system monitor — just run `btop`.

---

## GTK Theming

Managed via `nwg-look`. Config is stowed from `gtk/`. To change theme, run `nwg-look` and apply — changes are written back to the stowed files.

Installed themes: `Adwaita-dark` (default), `gruvbox-dark-gtk` (AUR, closer to the Sandstone palette).

---

## Waybar

Modules: workspaces · clock · weather · mpris · VPN · network · volume · bluetooth · battery · notifications · tray

| Click target | Action |
|---|---|
| Clock | Calendar popup |
| Weather | — (updates every 30 min via wttr.in) |
| Network | Open nmtui |
| Bluetooth | Open blueman-manager |
| Battery | Open wlogout power menu |
| Bell | Toggle notification drawer |

---

## License

[MIT](https://choosealicense.com/licenses/mit/)

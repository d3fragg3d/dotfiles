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
| `Alt + Tab` | Window switcher |

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

## Waybar

Modules: workspaces · clock · mpris · VPN · network · volume · battery · notifications · tray

Click the clock to open a calendar popup. Click the battery icon for the power menu.

---

## License

[MIT](https://choosealicense.com/licenses/mit/)

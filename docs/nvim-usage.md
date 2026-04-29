# Neovim Cheatsheet

> **Tip:** Press `Space` and wait — which-key shows everything available. `Space ?` lists all keymaps.

---

## Modes

| Key | Action |
|-----|--------|
| `i` | Enter insert mode (start typing) |
| `Esc` | Back to normal mode |
| `v` | Visual mode (select characters) |
| `V` | Visual line mode (select whole lines) |
| `Ctrl-v` | Visual block mode (column select) |

---

## Files & Projects

| Key | Action |
|-----|--------|
| `Space Space` | Find file in current project (hidden + symlinks) |
| `Space F` | Find file anywhere under `~` (break out of project) |
| `Space p` | Switch project |
| `Space f p` | Telescope project picker |
| `Space e` | Toggle file tree (neo-tree) |
| `-` | Browse directory of current file (oil) — `-` again to go up |
| `Space E` | File tree from git root |
| `Ctrl-x C-r` | Recent files |

---

## Search

| Key | Action |
|-----|--------|
| `Space /` | Ripgrep inside project |
| `Space s g` | Live grep |
| `/` | Search in current buffer |
| `n` / `N` | Next / previous match |
| `Space s t` | Search TODO / FIXME across project |

---

## Navigation

| Key | Action |
|-----|--------|
| `s` | Flash — type 2 chars, jump anywhere on screen |
| `g d` | Go to definition |
| `g r` | Go to references |
| `g I` | Go to implementation |
| `K` | Hover docs |
| `[d` / `]d` | Previous / next diagnostic |
| `[e` / `]e` | Previous / next error |

---

## Windows & Splits

| Key | Action |
|-----|--------|
| `Space \|` | Split vertically |
| `Space -` | Split horizontally |
| `Ctrl-h/j/k/l` | Move between splits |
| `Ctrl-w q` | Close split |

---

## Buffers & Tabs

| Key | Action |
|-----|--------|
| `Space ,` | Switch buffer (fuzzy) |
| `Space b d` | Delete buffer |
| `[b` / `]b` | Previous / next buffer |
| `Space b p` | Pin buffer |

---

## Moving Through a File

| Key | Action |
|-----|--------|
| `Ctrl-d` | Down half page |
| `Ctrl-u` | Up half page |
| `Ctrl-f` | Down full page |
| `Ctrl-b` | Up full page |
| `gg` | Top of file |
| `G` | Bottom of file |
| `{` / `}` | Jump between blank lines |
| `5j` / `5k` | Move exactly N lines down/up |

---

## Editing

| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl-r` | Redo |
| `y y` | Copy line |
| `d d` | Delete line |
| `p` | Paste |
| `g c c` | Toggle comment (line) |
| `g c` | Toggle comment (selection) |
| `>` / `<` | Indent / dedent selection |
| `Ctrl-a` | Increment number |
| `Ctrl-x` | Decrement number |

---

## LSP (in any language file)

| Key | Action |
|-----|--------|
| `Space c a` | Code action |
| `Space c r` | Rename symbol |
| `Space c f` | Format file |
| `Space x x` | Open diagnostics panel (Trouble) |
| `Space x l` | Location list |
| `Space x q` | Quickfix list |

---

## Git

| Key | Action |
|-----|--------|
| `Space g g` | Open lazygit |
| `Space g b` | Git blame line |
| `Space g s` | Git status (telescope) |
| `Space g c` | Git commits |
| `]h` / `[h` | Next / previous git hunk |
| `Space g h p` | Preview hunk |
| `Space g h s` | Stage hunk |
| `Space g h r` | Reset hunk |

---

## Debugging (Go)

| Key | Action |
|-----|--------|
| `Space d b` | Toggle breakpoint |
| `Space d c` | Continue |
| `Space d i` | Step into |
| `Space d v` | Step over |
| `Space d o` | Step out |
| `Space d x` | Stop |
| `Space d u` | Toggle debug UI |
| `Space d g` | Debug Go test at cursor |

---

## Terminal

| Key | Action |
|-----|--------|
| `Space f t` | Float terminal |
| `Space f T` | Terminal in current dir |
| `Ctrl-/` | Toggle terminal |

---

## Useful Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Plugin manager — update/view plugins |
| `:Mason` | Language server / tool manager |
| `:checkhealth` | Diagnose Neovim setup |
| `:noh` | Clear search highlights |

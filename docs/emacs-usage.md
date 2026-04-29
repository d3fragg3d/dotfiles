# Emacs Cheatsheet

> **Tip:** Press any prefix key (`C-c`, `C-x`, `M-s`, etc.) and **wait a second** — `which-key` will show everything available under that prefix. Use `C-h k` followed by any key to see what it does.

---

## Basics

| Key | Action |
|-----|--------|
| `C-x C-f` | Open file (type path, fuzzy completion works) |
| `C-x C-s` | Save file |
| `C-x C-w` | Save as |
| `C-x k` | Kill (close) buffer |
| `C-x C-c` | Quit Emacs |
| `C-/` | Undo |
| `C-g` | Cancel current command |
| `M-x` | Run any command by name |

---

## File Navigation

| Key | Action |
|-----|--------|
| `C-c f` | **Fuzzy find any file on disk** (fd, includes hidden dirs) |
| `C-x C-r` | **Recent files** (files you've had open before) |
| `C-c p f` | Find file in current project (Projectile) |
| `C-c p p` | Switch to a known project |
| `C-c p A` | Register a directory as a project |
| `C-x b` | Switch buffer (shows recent files too) |
| `C-x C-f` | Open file by path with fuzzy completion |

> For `~/.config/waybar/style.css`: hit `C-c f`, type `waybar style`, enter.

---

## Search

| Key | Action |
|-----|--------|
| `M-s l` | Search lines in current buffer |
| `M-s L` | Search lines across all open buffers |
| `M-s r` | Ripgrep across project |
| `M-s G` | Git grep |
| `M-s g` | Grep |
| `M-g g` | Go to line number |
| `M-g i` | Jump to symbol/heading in file (imenu) |

---

## Windows and Panes

**Splitting:**

| Key | Action |
|-----|--------|
| `C-S-<left>` / `C-S-<right>` | Split horizontally |
| `C-S-<up>` / `C-S-<down>` | Split vertically |

**Moving between panes:**

| Key | Action |
|-----|--------|
| `C-c <left/right/up/down>` | Move focus to pane in that direction |

**Closing:**

| Key | Action |
|-----|--------|
| `C-x 0` | Close current window |
| `C-x 1` | Close all other windows (maximise current) |
| `C-x 2` | Split below |
| `C-x 3` | Split right |

---

## Buffers

| Key | Action |
|-----|--------|
| `C-x b` | Switch buffer (fuzzy, shows all open files) |
| `C-x C-b` | List all buffers |
| `C-x k` | Kill current buffer |
| `M-y` | Browse clipboard/kill-ring history |

---

## Git (Magit)

| Key | Action |
|-----|--------|
| `M-x magit` | Open Magit status |
| `s` | Stage file/hunk |
| `u` | Unstage file/hunk |
| `c c` | Commit |
| `P p` | Push |
| `F p` | Pull |
| `b b` | Switch branch |
| `b c` | Create branch |
| `q` | Quit Magit window |

---

## Common Lisp / SLY

| Key | Action |
|-----|--------|
| `M-x sly` | Start SLY REPL (connects to SBCL) |
| `C-c C-c` | Compile form at point |
| `C-c C-k` | Compile and load current file |
| `C-c C-z` | Switch to REPL |

**In the debugger (SLDB):**

| Key | Action |
|-----|--------|
| `0-9` | Invoke restart by number |
| `v` | Show source of current frame |
| `e` | Eval expression in frame |
| `a` | Abort |
| `q` | Quit debugger |

---

## Go

| Key | Action |
|-----|--------|
| `C-c C-d` | Toggle breakpoint (DAP) |
| `C-c C-r` | Start debugger (DAP) |
| `C-c C-t` | Run test at point |
| `C-c C-f` | Run tests in current file |

LSP runs automatically when you open a `.go` file (requires `gopls` installed).

---

## Org Mode

| Key | Action |
|-----|--------|
| `C-c i` | Insert task list item |
| `C-c n` | Create new org file and link it |
| `TAB` | Cycle heading visibility |
| `C-c C-t` | Toggle TODO state |
| `C-c C-s` | Schedule item |
| `C-c C-d` | Set deadline |

---

## Config

| Key | Action |
|-----|--------|
| `C-c e` | Open `init.el` |
| `C-c r` | Reload config |
| `C-c t` | Toggle Treemacs file tree |

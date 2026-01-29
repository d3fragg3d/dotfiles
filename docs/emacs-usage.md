# Emacs Usage Guide

## 1. Opening / Adding a Project

- `C-c p p` — switch to a known project
- `C-c p A` — add a directory as a known project
- `C-c t` — toggle Treemacs file tree

## 2. Finding Files in a Project

- `C-c p f` — find file in current project (Projectile)
- `M-s d` — find file by name using `find` (Consult)
- `C-x b` — switch buffer (includes project buffers)
- `C-x p b` — switch buffer within current project

## 3. Searching Across a Project

- `M-s g` — grep
- `M-s G` — git-grep
- `M-s r` — ripgrep
- `M-s l` — search lines in current buffer
- `M-s L` — search lines across all buffers

## 4. Splitting and Navigating Windows

**Splitting:**
- `C-S-<up>` or `C-S-<down>` — split vertically
- `C-S-<left>` or `C-S-<right>` — split horizontally

**Navigation:**
- `S-<arrow>` — move focus to window in that direction (Windmove)

**Closing:**
- `C-x 0` — close current window
- `C-x 1` — close all other windows

## 5. Starting a Common Lisp REPL (SLY)

- `M-x sly` — start SLY connected to SBCL
- The REPL opens in a split window

## 6. Running / Reloading Lisp Code

- `C-c C-c` — compile the form at point
- `C-c C-k` — compile and load the current file
- `C-c C-l` — load a Lisp file
- `C-c C-z` — switch to the REPL buffer

## 7. Debugging Common Lisp

**Entering the debugger:**
- Errors automatically open the SLY debugger (SLDB)
- Invoke `(break)` in code to set a breakpoint

**In the debugger:**
- `v` — show source location of current frame
- `e` — evaluate expression in frame context
- `i` — inspect value at point
- `t` — toggle display of local variables
- `0-9` — invoke restart by number
- `a` — abort
- `c` — continue (if restart available)
- `q` — quit debugger

**Inspector:**
- `M-x sly-inspect` — inspect an expression
- `RET` — descend into value
- `l` — go back
- `q` — quit inspector

## 8. Opening a Terminal Inside Emacs

No custom keybinding configured. Use:
- `M-x term` — terminal emulator
- `M-x shell` — shell buffer
- `M-x eshell` — Emacs Lisp shell

;; Disable the toolbar (graphical)
(tool-bar-mode -1)

;; Disable the scrollbar
(scroll-bar-mode -1)

;; Highlight matching parens under caret
(show-paren-mode 1)

;; Do not display welcome message
(setq inhibit-startup-screen t)

;; Remember the current position in files on revisit
(save-place-mode t)

;; Remember command history between sessions
(savehist-mode t)

;; Retains recently opened files and allows the visiting of those files C-x C-r for example
(recentf-mode t)

;; Set custom-file to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Prevent adding `custom-set-variables` and `custom-set-faces` to `init.el`
(setq custom-buffer-done-kill t)

;; Add GitGutter like functionality
(global-diff-hl-mode)

;; Make sure we store autosaves and backups in their own dir so they don't taint repos
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-saves/" t)))


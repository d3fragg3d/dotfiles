;; Disable chrome we don't need
(tool-bar-mode -1)
(menu-bar-mode -1)
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

;; Make sure we store autosaves and backups in their own dir so they don't taint repos
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-saves/" t)))
(setq lock-file-name-transforms '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/locks/\\1" t)))

;; support multiple .env filenames
(add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . dotenv-mode))

;; stop annoying emacs sounds
(setq ring-bell-function 'ignore)

;; Allow for faster movement
(global-set-key (kbd "C-n")
    (lambda () (interactive) (forward-line  5)))
(global-set-key (kbd "C-p")
    (lambda () (interactive) (forward-line -5)))

;; Typing with a selection replaces it (like every other editor)
(delete-selection-mode t)

;; Auto-refresh buffers when files change on disk (e.g. after git checkout)
(global-auto-revert-mode t)

;; Line numbers in every buffer
(global-display-line-numbers-mode t)

;; Auto-close brackets, parens, quotes
(electric-pair-mode t)

;; Smooth pixel scrolling (Emacs 29+)
(pixel-scroll-precision-mode t)

;; Use spaces instead of tabs for indentation
(setq-default indent-tabs-mode nil)

;; Window / Pane splitting
(global-set-key (kbd "C-S-<up>") 'split-window-vertically)
(global-set-key (kbd "C-S-<down>") 'split-window-vertically)
(global-set-key (kbd "C-S-<left>") 'split-window-horizontally)
(global-set-key (kbd "C-S-<right>") 'split-window-horizontally)

;; Set up the keybinding for treemacs
(global-set-key (kbd "C-c t") 'treemacs)

(setq treemacs-show-hidden-files nil)
(treemacs-fringe-indicator-mode t)
(treemacs-filewatch-mode t)
(setq treemacs-file-event-delay 1000)

(require 'treemacs-project-follow-mode)
(treemacs-project-follow-mode t)
(setq treemacs-silent-refresh t)
(setq treemacs-show-hidden-files t)


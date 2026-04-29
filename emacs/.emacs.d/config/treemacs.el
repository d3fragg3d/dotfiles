(global-set-key (kbd "C-c t") 'treemacs)

(with-eval-after-load 'treemacs
  (setq treemacs-show-hidden-files t)
  (treemacs-fringe-indicator-mode t)
  (treemacs-filewatch-mode t)
  (setq treemacs-file-event-delay 1000)
  (require 'treemacs-project-follow-mode)
  (setq treemacs-project-follow-mode t)
  (setq treemacs-silent-refresh t))

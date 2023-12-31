;; Set the location of your configuration files directory
(setq config-dir (expand-file-name "config" user-emacs-directory))

;; Load individual configurations
(load (concat config-dir "/packages.el"))

(load (concat config-dir "/themes.el"))
(load (concat config-dir "/core.el"))
(load (concat config-dir "/vertico.el"))
(load (concat config-dir "/shortcuts.el"))

;; languages
(load (concat config-dir "/lisp.el"))
(load (concat config-dir "/javascript.el"))

(load (concat config-dir "/windmove.el"))
(load (concat config-dir "/projectile.el"))
(load (concat config-dir "/treemacs.el"))

(load custom-file 'noerror)

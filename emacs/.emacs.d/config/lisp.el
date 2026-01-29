;; Set the lisp interpreter
(setq inferior-lisp-program "/usr/bin/sbcl")

;; Use best practice indentation
(setq lisp-indent-function 'common-lisp-indent-function)

;; Enable rainbow parens for lisp
(add-hook 'lisp-mode-hook #'rainbow-delimiters-mode)


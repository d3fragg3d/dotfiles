(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))

;; Package initialization
(setq package-enable-at-startup nil)
(package-initialize)

;; Install and configure packages using use-package
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t) ; Automatically install packages if not present

;; lisp development env
(use-package slime)

;; language server protocol
(use-package lsp-mode)

;; languages
(use-package js2-mode)
(use-package typescript-mode)

;; git integration
(use-package magit)

;; emacs shortcut helper
(use-package which-key
  :config
  (which-key-mode))

;; autocomplete, for example on C-p-p to show available projects in a list automatically
(use-package vertico)
(use-package orderless)

;; colourful parens
(use-package rainbow-delimiters)

;; code completion
(use-package company)
(use-package slime-company)

;; easy pane and window navigation
(use-package windmove)

;; lets support fuzzy file searching to help with files that are not versioned
(use-package fzf)

;; dotenv support
(use-package dotenv-mode)

;; better project support
(use-package projectile)

;; need to include a file tree
(use-package treemacs)
(use-package treemacs-projectile)

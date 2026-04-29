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
(use-package sly
  :defer t)

;; language server protocol
(use-package lsp-mode
  :defer t)
(use-package lsp-ui
  :defer t
  :after lsp-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-sideline-enable t))

;; debugger adapter protocol (line-by-line debugging)
(use-package dap-mode
  :defer t
  :after lsp-mode
  :config
  (dap-auto-configure-mode))

;; Go
(use-package go-mode
  :mode "\\.go\\'")

;; git integration
(use-package magit
  :defer t)

;; emacs shortcut helper
(use-package which-key
  :config
  (which-key-mode))

;; autocomplete, for example on C-p-p to show available projects in a list automatically
(use-package vertico)
(use-package orderless)

;; Consult for search and project navigation
(use-package consult)

;; annotations in completion lists (file sizes, dates, descriptions)
(use-package marginalia
  :init
  (marginalia-mode))

;; colourful parens
(use-package rainbow-delimiters
  :defer t)

;; code completion - defer until after init to avoid slowing startup
(use-package company
  :hook (after-init . global-company-mode))

;; easy pane and window navigation
(use-package windmove)

;; file types
(use-package dotenv-mode
  :defer t)
(use-package yaml-mode
  :mode "\\.ya?ml\\'")

;; better project support
(use-package projectile)

;; file tree
(use-package treemacs
  :defer t)
(use-package treemacs-projectile
  :defer t
  :after (treemacs projectile))

;; Extra themes
(use-package doom-themes)

;; Better modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Jump to any visible text in 2 keystrokes
(use-package avy
  :bind ("C-;" . avy-goto-char-2))

;; Actions on any completion candidate
(use-package embark
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings))
  :init (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Edit search results inline across files
(use-package wgrep)

;; Envrc - Handy for bootstrapping envs
(use-package envrc
  :config
  (envrc-global-mode))

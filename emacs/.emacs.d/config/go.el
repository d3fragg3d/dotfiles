;; Go development environment
;;
;; Prerequisites (install via nix or your package manager):
;;   - go       : The Go compiler
;;   - gopls    : Go language server (LSP)
;;   - delve    : Go debugger (for dap-mode)

;; Enable LSP for Go files
(add-hook 'go-mode-hook #'lsp-deferred)

;; Format and organize imports on save
(defun my/go-before-save-hooks ()
  (when (derived-mode-p 'go-mode)
    (lsp-format-buffer)
    (lsp-organize-imports)))
(add-hook 'before-save-hook #'my/go-before-save-hooks)

;; Configure DAP (debugger) for Go
(with-eval-after-load 'dap-mode
  (require 'dap-dlv-go))

;; Keybindings for Go development (only active in go-mode)
(with-eval-after-load 'go-mode
  (define-key go-mode-map (kbd "C-c C-d") 'dap-breakpoint-toggle)  ; Toggle breakpoint
  (define-key go-mode-map (kbd "C-c C-r") 'dap-debug)              ; Start debugger
  (define-key go-mode-map (kbd "C-c C-t") 'go-test-current-test)   ; Run test at point
  (define-key go-mode-map (kbd "C-c C-f") 'go-test-current-file))  ; Run file tests

;; Extra: Show function signatures in echo area
(setq lsp-eldoc-enable-hover t)

;; Extra: Better completion with company
(setq lsp-completion-provider :capf)

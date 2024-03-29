(defun setup-ts-lsp ()
  (setq typescript-ts-mode-indent-offset 2)
  (setq typescript-indent-level 2)
  "Function to enable LSP for typescript-mode."
  (when buffer-file-name
    (when (string-match-p "\\.tsx?\\'" buffer-file-name)
      (lsp))))

(defun setup-js-lsp ()
  "Function to enable LSP for js2-mode."
  (setq typescript-indent-level 2)
  (when buffer-file-name
    (when (string-match-p "\\.jsx?\\'" buffer-file-name)
      (lsp))))

;; Add the hook to enable LSP for relevant modes
(add-hook 'js2-mode-hook #'setup-js-lsp)
(add-hook 'typescript-mode-hook #'setup-ts-lsp)

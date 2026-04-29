(vertico-mode t)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

;; vertico-directory: backspace deletes a path component, not a single character
(require 'vertico-directory)
(define-key vertico-map (kbd "RET") #'vertico-directory-enter)
(define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
(define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word)
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

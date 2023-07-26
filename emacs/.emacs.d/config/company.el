;; Enable Company mode globally
(add-hook 'after-init-hook 'global-company-mode)

;; Configure Company for Common Lisp
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-slime))

;; Set the delay before showing completion
(setq company-idle-delay 0.2)

;; File navigation
(global-set-key (kbd "C-x C-r") #'consult-recent-file)  ; recent files
(global-set-key (kbd "C-c f")   #'consult-fd)            ; find file by name (fd, includes hidden)

;; Buffer switching
(global-set-key (kbd "C-x b")   #'consult-buffer)
(global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window)
(global-set-key (kbd "C-x r b") #'consult-bookmark)
(global-set-key (kbd "C-x p b") #'consult-project-buffer)

;; Clipboard history
(global-set-key (kbd "M-y") #'consult-yank-pop)

;; Navigation within a file
(global-set-key (kbd "M-g g")   #'consult-goto-line)
(global-set-key (kbd "M-g M-g") #'consult-goto-line)
(global-set-key (kbd "M-g o")   #'consult-outline)
(global-set-key (kbd "M-g i")   #'consult-imenu)
(global-set-key (kbd "M-g I")   #'consult-imenu-multi)
(global-set-key (kbd "M-g f")   #'consult-flymake)  ; jump to errors

;; Search
(global-set-key (kbd "M-s l") #'consult-line)        ; search current buffer
(global-set-key (kbd "M-s L") #'consult-line-multi)  ; search all open buffers
(global-set-key (kbd "M-s r") #'consult-ripgrep)     ; search inside files across project

;; isearch integration
(define-key isearch-mode-map (kbd "M-s l") #'consult-line)
(define-key minibuffer-local-map (kbd "M-r") #'consult-history)

;; fd settings: include hidden directories (e.g. ~/.config)
(setq consult-fd-args '("fd" "--color=never" "--hidden" "--search-path" "."))

(defun insert-task-list-item ()
  "Insert a task list item under the current Org mode heading."
  (interactive)
  (insert " [%]\n")
  (insert "  - [ ] "))

(defun create-org-file-and-link ()
  "Create a new org file, add a template, and create a link in the current org file."
  (interactive)
  (let ((org-file-name (read-string "Enter new org file name: ")))
    (find-file (concat (file-name-directory buffer-file-name) org-file-name))
    (insert "#+TITLE: " org-file-name "\n\n")
    (save-buffer)
    (org-insert-link nil (concat org-file-name "::") org-file-name)
    (save-buffer)
    (switch-to-buffer (other-buffer))
    (message "Org file created and linked successfully!")))

;; Define a keybinding for the function
(eval-after-load 'org
  '(define-key org-mode-map (kbd "C-c i") 'insert-task-list-item))

(eval-after-load 'org
  '(define-key org-mode-map (kbd "C-c n") 'create-org-file-and-link))

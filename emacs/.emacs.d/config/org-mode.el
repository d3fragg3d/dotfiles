(defun insert-task-list-item ()
  "Insert a task list item under the current Org mode heading."
  (interactive)
  (insert " [%]\n")
  (insert "  - [ ] "))

(eval-after-load 'org
  '(define-key org-mode-map (kbd "C-c i") 'insert-task-list-item))

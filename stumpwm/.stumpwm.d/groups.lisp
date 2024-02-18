(in-package :stumpwm)

(defvar *ce/workspaces* (list "WWW" "Code" "Term"))
(stumpwm:grename (nth 0 *ce/workspaces*))
(dolist (workspace (cdr *ce/workspaces*))
  (stumpwm:gnewbg workspace))

(defvar *move-to-keybinds* (list "!" "@" "#" "$" "%" "^" "&" "*" "("))
(dotimes (y (length *ce/workspaces*))
  (let ((workspace (write-to-string (+ y 1))))
    (define-key *root-map* (kbd workspace) (concat "gselect " workspace))
    (define-key *root-map* (kbd (nth y *move-to-keybinds*)) (concat "gmove-and-follow " workspace))))

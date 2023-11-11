;; -*- mode: lisp -*-

(in-package :stumpwm)

(load "~/.stumpwm.d/vars.lisp")
;(load "~/.stumpwm.d/swank.lisp")
(load "~/.stumpwm.d/groups.lisp")

(set-prefix-key (stumpwm:kbd "s-x"))

(setf *mode-line-highlight-template* "^B~A^b")
(defcommand enable-all-mode-lines () ()
  "Enable all mode lines on the current screen."
  (loop for head in (screen-heads (current-screen))
        do (enable-mode-line (current-screen) head t)))

;; Enable the mode line on all current heads
(enable-all-mode-lines)

(define-key *root-map* (kbd "Q") "quit")
(define-key *root-map* (kbd "q") "delete")
(define-key *root-map* (kbd "h") "move-focus left")
(define-key *root-map* (kbd "j") "move-focus down")
(define-key *root-map* (kbd "k") "move-focus up")
(define-key *root-map* (kbd "l") "move-focus right")
(define-key *root-map* (kbd "H") "move-window left")
(define-key *root-map* (kbd "J") "move-window down")
(define-key *root-map* (kbd "K") "move-window up")
(define-key *root-map* (kbd "L") "move-window right")
(define-key *root-map* (kbd "d") "exec dmenu_run")
(define-key *top-map* (kbd "M-l") "resize-direction Right")
(define-key *top-map* (kbd "M-h") "resize-direction Left")
(define-key *top-map* (kbd "M-k") "resize-direction Up")
(define-key *top-map* (kbd "M-j") "resize-direction Down")

(define-key *root-map* (kbd "RET") "exec xfce4-terminal")


(defun key-press-hook (key key-seq cmd)
  (declare (ignore key))
  (unless (eq *top-map* *resize-map*)
    (let ((*message-window-gravity* :bottom-right))
      (message "Keys: ~a" (print-key-seq (reverse key-seq))))
    (when (stringp cmd)
      ;; give 'em time to read it
      (sleep 0.3))))

(defmacro replace-hook (hook fn)
  `(remove-hook ,hook ,fn)
  `(add-hook ,hook ,fn))

(replace-hook *key-press-hook* 'key-press-hook)

(load-module "battery-portable")
(load-module "stumptray")

(load-module "net")

(load-module "swm-gaps")

;; Head gaps run along the 4 borders of the monitor(s)
(setf swm-gaps:*head-gaps-size* 0)

;; Inner gaps run along all the 4 borders of a window
(setf swm-gaps:*inner-gaps-size* 5)

;; Outer gaps add more padding to the outermost borders of a window (touching
;; the screen border)
(setf swm-gaps:*outer-gaps-size* 10)

(load-module "clipboard-history")

(define-key *root-map* (kbd "C-y") "show-clipboard-history")
;; start the polling timer process
(clipboard-history:start-clipboard-manager)

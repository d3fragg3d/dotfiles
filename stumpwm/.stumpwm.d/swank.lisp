(in-package :stumpwm)

(ql:quickload :swank)
(swank-loader:init)
(let ((server-running nil))
  (defcommand swank () ()
    "Toggle the swank server on/off"
    (if server-running
	(progn
	  (swank:stop-server 4005)
	  (echo-string
	   (current-screen)
	   "Stopping swank.")
	  (setf server-running nil))
	(progn
	  (swank:create-server :port 4005
			       :style swank:*communication-style*
			       :dont-close t)
	  (echo-string
	   (current-screen)
	   "Starting swank. M-x slime-connect RET RET, then (in-package :stumpwm).")
	  (setf server-running t)))))

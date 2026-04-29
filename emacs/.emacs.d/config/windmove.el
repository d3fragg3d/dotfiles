;; C-c + arrow to move between panes (pairs with C-S-arrow for splitting in core.el)
;; Replaces default Shift+arrow which clashes with Hyprland's movefocus bindings
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

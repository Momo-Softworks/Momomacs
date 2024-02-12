(defconst momo/leader "C-c")

;; Remove some annoying bindings

(general-define-key
 "C-z" 'nil) ;; Removes Control-z minimizing Emacs window

(general-create-definer leader-def
  :prefix momo/leader)

(leader-def
  "c" 'kill-ring-save
  "x" 'kill-region
  "v" 'yank
  "y" 'undo-redo
  "z" 'undo)

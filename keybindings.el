(defconst momo/leader "C-c")

;; Remove some annoying bindings

(general-define-key
 "C-z" 'nil) ;; Removes Control-z minimizing Emacs window

(general-create-definer leader-def
  :prefix momo/leader)

;; Leader bindings
(leader-def
  "c" 'kill-ring-save
  "x" 'kill-region
  "v" 'yank
  "y" 'undo-redo
  "z" 'undo)


;; Dired bindings
(general-define-key :keymaps 'dired-mode-map
		    "H" 'dired-hide-dotfiles-mode
		    "h" 'dired-up-directory
		    "l" 'dired-find-file)

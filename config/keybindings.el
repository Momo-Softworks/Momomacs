(defconst momo/leader "C-c")
(defconst momo/org-leader "C-c o")
(defconst momo/roam-leader "C-c n")
(defconst momo/lsp-leader "")
;; Remove some annoying bindings

(general-define-key
 "C-z" 'nil ;; Removes Control-z minimizing Emacs window
 "C-x b" 'consult-buffer)



(general-create-definer leader-def
  :prefix momo/leader)

;; Leader bindings
(leader-def
  "C-c" 'kill-ring-save
  "C-x" 'kill-region
  "C-v" 'yank
  "C-y" 'undo-redo
  "C-z" 'undo)

;; Org bindings

(general-create-definer org-def
  :prefix momo/org-leader)

(org-def
  "c" 'org-capture
  "r" 'org-refile)

;; Roam bindings

(general-create-definer roam-def
  :prefix momo/roam-leader)

(roam-def
  "f" 'org-roam-node-find
  "c" 'org-roam-capture
  "i" 'org-roam-node-insert
  "j" 'org-roam-dailies-capture-today)


;; Dired bindings
(general-define-key :keymaps 'dired-mode-map
		    "H" 'dired-hide-dotfiles-mode
		    "h" 'dired-up-directory
		    "l" 'dired-find-file)

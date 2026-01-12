;;; keybindings.el --- Keybinding definitions -*- lexical-binding: t; -*-

;;; Commentary:
;; Global keybindings and leader key definitions.
;; Using C-c m as main leader to avoid conflicts with major modes.

;;; Code:

;; Leader key definitions
(defconst momo/leader "C-c m")      ; Main leader (m for momo)
(defconst momo/org-leader "C-c o")  ; Org-mode leader
(defconst momo/roam-leader "C-c n") ; Org-roam leader (n for notes)
(defconst momo/config-leader "C-c c") ; Config leader

;; Remove annoying default bindings
(general-define-key
 "C-z" nil              ; Remove suspend-frame binding
 "C-x b" #'consult-buffer
 "<f5>" #'momo/reload-config)

;; Create leader key definer
(general-create-definer leader-def
  :prefix momo/leader)

;; Main leader bindings (C-c m ...)
(leader-def
  "c" #'kill-ring-save    ; Copy
  "x" #'kill-region       ; Cut
  "v" #'yank              ; Paste
  "z" #'undo              ; Undo
  "y" #'undo-redo)        ; Redo

;; Config leader bindings (C-c c ...)
(general-create-definer config-def
  :prefix momo/config-leader)

(config-def
  "r" #'momo/reload-config
  "o" #'momo/open-config)

;; Org bindings

(general-create-definer org-def
  :prefix momo/org-leader)

(org-def
  "c" #'org-capture
  "r" #'org-refile)

;; Roam bindings

(general-create-definer roam-def
  :prefix momo/roam-leader)

(roam-def
  "f" #'org-roam-node-find
  "c" #'org-roam-capture
  "i" #'org-roam-node-insert
  "j" #'org-roam-dailies-capture-today)


;; Dired bindings
(general-define-key :keymaps 'dired-mode-map
		    "H" #'dired-hide-dotfiles-mode
		    "h" #'dired-up-directory
		    "l" #'dired-find-file)

(provide 'keybindings)
;;; keybindings.el ends here

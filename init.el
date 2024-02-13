;; Elpaca
(load (concat user-emacs-directory "modules/utils/elpaca"))

;; Custom Variables
(load (concat user-emacs-directory "momo"))

;; Utils
(load (concat user-emacs-directory "modules/utils/loaders"))
(load (concat user-emacs-directory "modules/utils/helpers"))
(load (concat user-emacs-directory "custom/minecraft"))

;; Settings
(load (concat user-emacs-directory "settings"))

;; Set theme
(momo/set-theme 'modus-vivendi-tinted)

;; Packages

;; Defaults
(momo/load "defaults/general")
(momo/load "defaults/savehist")
(momo/load "defaults/smartparens")
(momo/load "defaults/yasnippet")
(momo/load "defaults/eglot")
(momo/load "defaults/marginalia")
(momo/load "defaults/dired-hide-dotfiles")
(momo/load "defaults/ag")

;; Keybindings
(load (concat user-emacs-directory "keybindings"))

;; UI
(momo/load-doom-modeline)
(momo/load-modus-themes)
(momo/load-dashboard)

;; Keybindings
(momo/load-meow)
(momo/load-which-key)

;; Completions
(momo/load-vertico)
(momo/load-corfu)
(momo/load-orderless)

;; File-handling
(momo/load-pdf-tools)
;(momo/load-dirvish) ;; Slow when starting, for some reason...

;; Programming
(momo/load-racket)
(momo/load-java)
(momo/load-flycheck)
(momo/load-copilot)
(momo/load-rainbow-delimiters)

;; Project Management
(momo/load-projectile)
(momo/load-magit)

;; Org
(momo/load-org-modern)

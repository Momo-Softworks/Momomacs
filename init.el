;; Elpaca
(load (concat user-emacs-directory "modules/utils/elpaca"))

;; Custom Variables
(load (concat user-emacs-directory "momo"))

;; Guix
(load (concat user-emacs-directory "modules/utils/guix"))

;; Utils
(load (concat user-emacs-directory "modules/utils/loaders"))
(load (concat user-emacs-directory "modules/utils/helpers"))
(load (concat user-emacs-directory "custom/minecraft"))
(load (concat user-emacs-directory "custom/org"))

;; Defaults

(momo/load-defaults)

;; Settings
(load (concat user-emacs-directory "settings"))

;; Keybindings
(load (concat user-emacs-directory "keybindings"))

;; Packages

(momo/load-packages
      '(
        ;; UI
        doom-modeline
        modus-themes
        dashboard
        ;; Keybindings
        meow
        which-key
        ;; Completions
        vertico
        corfu
        orderless
        ;; File-Handling
        pdf-tools
        ;; Programming
        racket
        java
        flycheck
        copilot
        rainbow-delimiters
        ;; Project Management
        projectile
        magit
        ;; Org
        org-modern
        org-roam
        org-fragtog
        ;;Social
        elfeed
        ;; System
        exwm
        ))

(elpaca-wait)

(load-theme 'modus-vivendi-tinted t)

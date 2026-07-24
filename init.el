;; -*- lexical-binding: t; -*-

;;; Commentary:
;; Momomacs - A modular Emacs configuration
;; Main initialization file that loads all configuration modules in order.

;;; Code:

;; Load user configuration variables first cs initia


;; NOTE: user-config.el contains only defcustom declarations and basic elisp,
;;       no package dependencies. Loaded here so use-guix is available in elpaca.el
(load (expand-file-name "config/user-config" user-emacs-directory))

;; Personal overlay, phase 1: variables that must exist before the package
;; manager and modules load (machine specifics, feed lists, momo-* overrides).
(let ((early (expand-file-name "early.el" momo-personal-dir)))
  (when (file-exists-p early)
    (load early)))

;; Initialize Elpaca package manager
(load (expand-file-name "modules/utils/elpaca" user-emacs-directory))

;; Wait for Elpaca to fully activate before loading any packages
(elpaca-wait)

;; Load utilities (needed by other modules)
(load (expand-file-name "modules/utils/loaders" user-emacs-directory))
(load (expand-file-name "modules/utils/helpers" user-emacs-directory))
(load (expand-file-name "modules/utils/eca-helpers" user-emacs-directory))

;; Load Guix integration if enabled
(when momo-use-guix
  (load (expand-file-name "modules/utils/guix" user-emacs-directory)))

;; Load optional configuration modules (after elpaca and utilities are available)
;; NOTE: momo.el loads all optional modules from config/ directory
(load (expand-file-name "momo" user-emacs-directory))

;; Load default packages (from modules/defaults/)
(momo/load-defaults)

;; Load general settings
(load (expand-file-name "config/settings" user-emacs-directory))

;; Load packages with their configurations
;; UI and completions first (loaded early but through Elpaca's queue)
(momo/load-packages
 '(doom-modeline
   modus-themes
   dashboard
   vertico
   corfu
   orderless))

;; Wait for critical UI/completion packages to finish loading
(elpaca-wait)

;; Now load the rest (these can defer as needed)
(momo/load-packages
 '(;; Keybindings
   meow
   which-key
      
   ;; File handling
   pdf-tools
   visual-fill-column
   shrface
   dirvish
      
   ;; Programming
   racket
   geiser
   arei
   kawa
   java
   flycheck
   eca
   rainbow-delimiters
   parinfer-rust
   jinx
      
   ;; Project management
   projectile
   magit
   envrc
      
   ;; Org-mode
   org-modern
   org-roam
   org-fragtog
   citeproc
      
   ;; Social
   elfeed

   ;; Gaming
   packwiz

   ;; System (uncomment if needed)
   bluetooth
   pinentry))
   ;;exwm
      

;; Wait for all remaining packages to be installed and configured
(elpaca-wait)

;; EXWM is enabled only when Emacs is launched as the window manager: the
;; xsession entry point must export EXWM_LAUNCH (on Guix System, ~/.exwm does
;; this before re-loading init.el; elsewhere see examples/exwm/start-exwm).
;; Gating on it keeps a normal Emacs and the emacs --fg-daemon from ever
;; calling (exwm-enable).
(when (getenv "EXWM_LAUNCH")
  (momo/load-packages '(xdg-launcher exwm))
  (elpaca-wait)
  (server-start))

;; Apply theme
(load-theme 'modus-vivendi-tinted t)

;; Load keybindings last (after all packages are configured)
(load (expand-file-name "config/keybindings" user-emacs-directory))

;; Personal overlay, phase 2: final overrides (extra keybindings, theme
;; tweaks) — loaded after every framework module has had its say.
(let ((late (expand-file-name "late.el" momo-personal-dir)))
  (when (file-exists-p late)
    (load late)))

;; Display startup time
(message "Momomacs loaded in %.2f seconds"
         (float-time (time-subtract (current-time) before-init-time)))

(provide 'init)
;;; init.el ends here

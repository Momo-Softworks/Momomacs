;;; momo.el --- Momomacs configuration loader -*- lexical-binding: t; -*-

;; This file serves as the main entry point for Momomacs configuration.
;; All specific configuration has been moved to appropriate files in the config/ directory.

;; Load core user configuration
(load (concat user-emacs-directory "config/user-config"))

;; Load additional configuration modules
(load (concat user-emacs-directory "config/exwm-config"))
(load (concat user-emacs-directory "config/elfeed-config"))
(load (concat user-emacs-directory "config/project-utils"))
(load (concat user-emacs-directory "config/desktop-launcher"))

(provide 'momo)
;;; momo.el ends here

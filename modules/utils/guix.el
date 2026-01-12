;;; guix.el --- Guix package manager integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Integration with Guix package manager for Emacs packages.
;; When use-guix is t, packages are managed by Guix instead of Elpaca.

;;; Code:

;; Disable use-package's ensure since Guix manages packages
(setq use-package-always-ensure nil)

;; Load Guix-installed Emacs packages
(guix-emacs-autoload-packages)

(provide 'guix)
;;; guix.el ends here

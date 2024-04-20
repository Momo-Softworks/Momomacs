;; If using Guix, use it for proper package management.
(if use-guix
    (begin (setq use-package-always-ensure nil)
  (guix-emacs-autoload-packages)))

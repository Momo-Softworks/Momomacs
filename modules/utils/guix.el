;; If using Guix, use it for proper package management.
(if use-guix
    (setq use-package-always-ensure nil)
  (guix-emacs-autoload-packages))

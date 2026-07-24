;;; arei.el --- Arei/Ares Guile IDE integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Arei is supplied by Guix as `emacs-arei' in ~/.emacs.d/manifest.scm.
;; Ares itself is supplied by project manifests such as goblins-game-lab's
;; `guile-ares-rs' dependency.

;;; Code:

(use-package arei
  :commands (arei arei-mode global-arei-mode)
  :hook (scheme-mode . arei-mode)
  :custom
  ;; Avoid Geiser competing with Arei for Scheme CAPFs in buffers where Arei is
  ;; enabled.  Geiser itself remains available as a fallback REPL.
  (geiser-mode-auto-p nil))

(provide 'arei-config)
;;; arei.el ends here

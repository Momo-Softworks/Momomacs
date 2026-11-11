;;; arei.el --- Arei/Ares Guile IDE integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Arei is supplied by Guix as `emacs-arei' in ~/.emacs.d/manifest.scm.
;; Ares itself is supplied by project manifests such as goblins-game-lab's
;; `guile-ares-rs' dependency.

;;; Code:

(use-package arei
  ;; Not on MELPA; Guix users get it from the manifest instead (guix.el
  ;; skips this recipe when the package is already on the load-path).
  ;; Without a recipe Elpaca fails it on every start and keeps its log
  ;; window open, which made startup several seconds slower.
  :ensure (arei :repo "https://git.sr.ht/~abcdw/emacs-arei")
  :commands (arei arei-mode global-arei-mode)
  :hook (scheme-mode . arei-mode)
  :custom
  ;; Avoid Geiser competing with Arei for Scheme CAPFs in buffers where Arei is
  ;; enabled.  Geiser itself remains available as a fallback REPL.
  (geiser-mode-auto-p nil))

(provide 'arei-config)
;;; arei.el ends here

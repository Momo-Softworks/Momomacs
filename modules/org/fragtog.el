;;; fragtog.el --- Org LaTeX fragment preview configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for org-fragtog to automatically preview LaTeX fragments in org-mode.

;;; Code:

(use-package org-fragtog
  :after org
  :custom
  (org-startup-with-latex-preview t)
  :hook
  (org-mode . org-fragtog-mode)
  :config
  ;; Customize LaTeX preview options
  (plist-put org-format-latex-options :scale 1.5)
  (plist-put org-format-latex-options :foreground 'auto)
  (plist-put org-format-latex-options :background 'auto))

(provide 'fragtog)
;;; fragtog.el ends here

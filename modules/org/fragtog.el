(use-package org-fragtog
  :after org
  :hook
  (org-mode . org-fragtog-mode)
  :config
  (setq org-startup-with-latex-preview t)
  (plist-put org-format-latex-options :scale 1.5)
  (plist-put org-format-latex-options :foreground 'auto)
  (plist-put org-format-latex-options :background 'auto))

(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda . org-modern-agenda))
  :config
  (global-org-modern-mode))

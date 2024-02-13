(use-package org-roam
  :config
  (setq org-roam-directory (file-truename roam-directory))
  (org-roam-db-autosync-mode))

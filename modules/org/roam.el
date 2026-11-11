;;; roam.el --- Org-roam configuration -*- lexical-binding: t; -*-

(use-package org-roam
  :config
  (setq org-roam-directory (file-truename momo-roam-directory))
  (org-roam-db-autosync-mode))

(provide 'momo-roam)
;;; roam.el ends here

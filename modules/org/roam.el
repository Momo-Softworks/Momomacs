;;; roam.el --- Org-roam configuration -*- lexical-binding: t; -*-

(use-package org-roam
  ;; Wait for Org so startup doesn't load it; its commands stay autoloaded.
  :after org
  :config
  (setq org-roam-directory (file-truename momo-roam-directory))
  (org-roam-db-autosync-mode))

(provide 'momo-roam)
;;; roam.el ends here

;;; modern.el --- Org-modern styling configuration -*- lexical-binding: t; -*-

(use-package org-modern
  ;; Per-buffer hooks instead of `global-org-modern-mode', which loads Org
  ;; itself at startup.
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))

(provide 'momo-modern)
;;; modern.el ends here

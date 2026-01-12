;;; citeproc.el --- Citation processing configuration -*- lexical-binding: t; -*-

(use-package citeproc
  :after org
  :config
  (require 'oc-csl)
  (setq org-cite-export-processors
        '((t csl))))

(provide 'citeproc)
;;; citeproc.el ends here

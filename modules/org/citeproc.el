;;; citeproc.el --- Citation processing configuration -*- lexical-binding: t; -*-

;; Completely disable citeproc for now
;; Remove all citeproc configuration

;; Load org-cite processors
(with-eval-after-load 'oc
  ;; Load biblatex processor for LaTeX export
  (require 'oc-biblatex)
  ;; Load basic processor for other exports
  (require 'oc-basic)
  
  ;; Set org-cite to use appropriate processors
  ;; For LaTeX backend, use biblatex processor
  ;; For all other backends, use basic processor
  (setq org-cite-export-processors '((latex biblatex) (t basic)))
  )

(provide 'citeproc)
;;; citeproc.el ends here

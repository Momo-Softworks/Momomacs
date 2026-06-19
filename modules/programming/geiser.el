(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  ;; Use the Guile from the current environment (e.g. a `guix shell`),
  ;; so per-project load paths set via .dir-locals.el are respected.
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory)))

(use-package geiser-guile
  :after geiser)

(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory)))

(use-package geiser-guile
  :after geiser)

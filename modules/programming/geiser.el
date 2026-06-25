(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory))
  ;; Disable autodoc — it uses the font-lock buffer which steals
  ;; focus during Corfu completions.
  (geiser-repl-autodoc-p nil))

(use-package geiser-guile
  :after geiser)

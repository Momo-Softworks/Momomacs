(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory))
  ;; Disable REPL output highlighting — the font-lock buffer it uses
  ;; steals focus during Corfu completions.
  (geiser-repl-highlight-output-p nil))

(use-package geiser-guile
  :after geiser)

(use-package racket-mode
  :init
  ;; Let envrc/direnv's per-project PATH pick the racket (e.g. a project
  ;; manifest's), instead of the store path baked in at package build time.
  (setq racket-program "racket")
  (add-hook 'racket-mode-hook #'racket-xp-mode))

;;; -*- lexical-binding: t; -*-
(use-package racket-mode
  :defer t                              ; loads when a .rkt file opens
  :init
  ;; Let envrc/direnv's per-project PATH pick the racket (e.g. a project
  ;; manifest's), instead of the store path baked in at package build time.
  (setq racket-program "racket")
  ;; racket-xp-mode needs the racket binary; skip it (rather than erroring on
  ;; every .rkt file) when Racket isn't installed or not on this project's PATH.
  (add-hook 'racket-mode-hook
            (lambda ()
              (when (executable-find racket-program)
                (racket-xp-mode)))))

(use-package racket-mode
  :init
  (add-hook 'racket-mode-hook #'eglot-ensure))

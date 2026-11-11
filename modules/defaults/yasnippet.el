;;; -*- lexical-binding: t; -*-
(use-package yasnippet
  :defer t
  ;; Loading every snippet table takes ~0.4 s, so do it once Emacs is idle.
  :init (run-with-idle-timer 1 nil #'yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

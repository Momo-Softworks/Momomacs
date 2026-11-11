;;; -*- lexical-binding: t; -*-
(use-package eat
  :config
  (add-hook 'eshell-load-hook #'eat-eshell-mode))

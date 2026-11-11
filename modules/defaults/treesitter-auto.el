;;; -*- lexical-binding: t; -*-
(use-package treesit-auto
  :config
  (global-treesit-auto-mode)
  (setq treesit-auto-install 'prompt))

;;; dired-dotfiles.el --- Hide dotfiles in Dired -*- lexical-binding: t; -*-

;;; Commentary:
;; Hide dotfiles by default in Dired while retaining an interactive toggle.

;;; Code:

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode))

(provide 'momo-dired-dotfiles)
;;; dired-dotfiles.el ends here

(use-package dired-hide-dotfiles
  :hook
  ((dired-mode . dired-omit-mode)
   (dired-mode . dired-hide-dotfiles-mode)))

(unless (package-installed-p 'transient)
  (momo/load "libraries/transient.el"))

(use-package dirvish
  :after transient
  :config
  (dirvish-override-dired-mode))

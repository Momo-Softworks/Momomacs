(unless (package-installed-p 'transient)
  (momo/load "libraries/transient.el"))

(use-package magit
  :ensure t)

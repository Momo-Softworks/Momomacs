(use-package eglot
  :ensure nil
  :if (executable-find "yay")
  :ensure-system-package (jdtls . "yay -Sy --noconfirm jdtls")
  :hook (java-mode . ensure-eglot))

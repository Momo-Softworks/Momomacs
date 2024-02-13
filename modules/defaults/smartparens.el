(use-package smartparens
  
  :config
  (require 'smartparens-config)
  :hook
  ((prog-mode . smartparens-mode)
   (text-mode . smartparens-mode)))

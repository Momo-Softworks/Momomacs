(use-package projectile
  :ensure t
  :after (general)
  :config
  (projectile-mode +1)
  (setq projectile-project-search-path projects)
  (projectile-discover-projects-in-search-path)
  (general-define-key :keymaps 'projectile-mode-map
		      "C-c p" 'projectile-command-map))

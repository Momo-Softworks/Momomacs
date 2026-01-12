;;; projectile.el --- Projectile project management configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Projectile project management with custom project search paths.

;;; Code:

(use-package projectile
  :after (general)
  :config
  (projectile-mode +1)
  (setq projectile-project-search-path momo-projects)
  (setq projectile-verbose nil)
  (projectile-discover-projects-in-search-path)
  (general-define-key :keymaps 'projectile-mode-map
		      "C-c p" #'projectile-command-map))

(provide 'projectile)
;;; projectile.el ends here

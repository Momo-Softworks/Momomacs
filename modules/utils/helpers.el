;; -*- lexical-binding: t -*-

;; If using Guix, use it for proper package management.
(if use-guix
    (setq use-package-always-ensure nil)
  (guix-emacs-autoload-packages))

(defun momo/set-theme (theme)
  (interactive)
  (add-hook 'elpaca-after-init-hook
	    (lambda ()
	      (load-theme theme t))))

;; Add yay, and change if it's available.
(elpaca nil (if (executable-find "yay")
		(momo/load "utils/yay")))

;; Hide dotfiles in Dired
;; (defun momo/dired-hide-dotfiles ()
;;   "Hide all dotfiles in the current `dired` buffer."
;;   (interactive)
;;   (when (equal major-mode 'dired-mode)
;;     (dired-mark-files-regexp "^\\.")
;;     (dired-do-kill-lines)))

;; -*- lexical-binding: t -*-

(defun momo/set-theme (theme)
  (interactive)
  (add-hook 'elpaca-after-init-hook
	    (lambda ()
	      (load-theme theme t))))

;; Change package manager, depending on distro
(elpaca nil (if (executable-find "yay")
		(momo/load "utils/yay")))

;; Hide dotfiles in Dired
(defun momo/dired-hide-dotfiles ()
  "Hide all dotfiles in the current `dired` buffer."
  (interactive)
  (when (equal major-mode 'dired-mode)
    (dired-mark-files-regexp "^\\.")
    (dired-do-kill-lines)))

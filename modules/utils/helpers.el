;; -*- lexical-binding: t -*-

;; Add yay, and change if it's available.
(elpaca nil (if (executable-find "yay")
		(momo/load "utils/yay")))

(defun momo/set-theme (theme)
  (interactive)
  (if (not use-guix)
    (add-hook 'elpaca-after-init-hook
	      (lambda ()
		(load-theme theme t)))
    (add-hook 'after-init-hook
	      (lambda ()
		(load-theme theme t)))))

;;   (interactive)
;;   (when (equal major-mode 'dired-mode)
;;     (dired-mark-files-regexp "^\\.")
;;     (dired-do-kill-lines)))

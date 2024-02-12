;; -*- lexical-binding: t -*-

(defun momo/set-theme (theme)
  (interactive)
  (add-hook 'elpaca-after-init-hook
	    (lambda ()
	      (load-theme theme t))))

;; Change package manager, depending on distro
(elpaca nil (if (executable-find "yay")
		(momo/load "utils/yay")))

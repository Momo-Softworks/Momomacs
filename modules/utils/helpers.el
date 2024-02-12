;; -*- lexical-binding: t -*-

(defun momo/set-theme (theme)
  (interactive)
  (add-hook 'elpaca-after-init-hook
    (lambda ()
    (load-theme theme t))))

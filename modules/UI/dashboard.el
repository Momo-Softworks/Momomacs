;;; dashboard.el --- Dashboard configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the Emacs dashboard startup screen.

;;; Code:

(use-package dashboard
  :ensure (:wait t)
  :init
  (dashboard-setup-startup-hook)
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  
  ;; Set dashboard as initial buffer for emacsclient frames
  (setq initial-buffer-choice #'dashboard-open)
  
  ;; Refresh dashboard when creating new frames (for emacsclient)
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (with-current-buffer "*dashboard*"
                (dashboard-refresh-buffer)))))

(provide 'dashboard)
;;; dashboard.el ends here

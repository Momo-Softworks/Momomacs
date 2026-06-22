;;; dashboard.el --- Dashboard configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the Emacs dashboard startup screen.

;;; Code:

(use-package dashboard
  :ensure (:wait t)
  :config
  (dashboard-setup-startup-hook)
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  ;; `dashboard-initialize' only exists in some dashboard versions (e.g. not in
  ;; Guix's dashboard 1.8.0); guard so this works on either backend.
  (when (fboundp 'dashboard-initialize)
    (add-hook 'elpaca-after-init-hook #'dashboard-initialize))
  
  ;; Set dashboard as initial buffer for emacsclient frames
  (setq initial-buffer-choice #'dashboard-open)
  
  ;; Refresh dashboard when creating new frames (for emacsclient)
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (with-current-buffer "*dashboard*"
                (dashboard-refresh-buffer)))))

(provide 'dashboard)
;;; dashboard.el ends here

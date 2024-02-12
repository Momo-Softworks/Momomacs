(setq warning-suppress-log-types '((comp)))
(setq native-comp-async-report-warnings-errors -1)
(menu-bar-mode -1) ;; Disable menu bar
(tool-bar-mode -1) ;; Disable tool bar
(scroll-bar-mode -1) ;; Disable scroll bar
(set-face-attribute 'default nil :height 120) ;; Bigger fonts

;; Move backups and auto-saves to emacs folder
(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))

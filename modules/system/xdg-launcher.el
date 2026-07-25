;;; xdg-launcher.el --- XDG desktop application launcher -*- lexical-binding: t; -*-

;;; Commentary:
;; Use emacs-exwm/xdg-launcher for launching .desktop applications from EXWM
;; (bound to `s-p' in the EXWM module).

;;; Code:

(use-package xdg-launcher
  :commands (xdg-launcher-run-app))

(provide 'momo-xdg-launcher)
;;; xdg-launcher.el ends here

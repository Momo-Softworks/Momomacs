;;; xdg-launcher.el --- XDG desktop application launcher -*- lexical-binding: t; -*-

;;; Commentary:
;; Use emacs-exwm/xdg-launcher for launching .desktop applications from EXWM.
;; This replaces the custom desktop-launcher parser for `s-p'.

;;; Code:

(use-package xdg-launcher
  :commands (xdg-launcher-run-app))

(provide 'momo-xdg-launcher)
;;; xdg-launcher.el ends here

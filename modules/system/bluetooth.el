;;; bluetooth.el --- Bluetooth package configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Basic bluetooth package wiring for Momomacs.

;;; Code:

(defun momo/bluetooth-init-for-exwm ()
  "Initialize Emacs Bluetooth management after EXWM starts."
  (when (fboundp 'bluetooth-init)
    (condition-case err
        (bluetooth-init)
      (error
       (message "Bluetooth initialization failed: %s"
                (error-message-string err))))))

(use-package bluetooth
  :commands (bluetooth-init bluetooth-list-devices)
  :config
  (with-eval-after-load 'exwm
    (add-hook 'exwm-init-hook #'momo/bluetooth-init-for-exwm)))

(provide 'bluetooth)
;;; bluetooth.el ends here

;;; momo.el --- Momomacs configuration loader -*- lexical-binding: t; -*-

;;; Commentary:
;; This file loads optional configuration modules that may depend on packages.
;; All optional config files from the config/ directory are loaded here.

;;; Code:

;; Load optional configuration modules
(let ((config-dir (expand-file-name "config/" user-emacs-directory)))
  (dolist (module '("exwm-config"
                    "elfeed-config"
                    "elfeed-setup"
                    "project-utils"
                    "desktop-launcher"
                    "minecraft-utils"
                    "org-config"))
    (let ((module-file (expand-file-name module config-dir)))
      (condition-case err
          (load module-file)
        (error (warn "Failed to load optional module %s: %s" module err))))))

(provide 'momo)
;;; momo.el ends here

;;; momo.el --- Momomacs configuration loader -*- lexical-binding: t; -*-

;;; Commentary:
;; This file loads optional configuration modules that may depend on packages.
;; All optional config files from the config/ directory are loaded here.

;;; Code:

;; Load optional configuration modules.  The regexp skips dotfiles so
;; Emacs lockfiles (.#foo.el) are never picked up.
(let ((config-dir (expand-file-name "config/" user-emacs-directory)))
  (dolist (module (directory-files config-dir t "\\`[^.].*\\.el\\'"))
    ;; Compare base names; `module' is absolute, so matching the
    ;; exclusions against it directly would never succeed (which also
    ;; double-loaded settings/user-config on every startup).
    (let ((module-name (file-name-base module)))
      ;; Avoid loading files already handled explicitly in init.el
      (unless (member module-name '("settings" "keybindings" "user-config"))
        (condition-case err
            (load (file-name-sans-extension module))
          (error (warn "Failed to load optional module %s: %s" module-name err)))))))

(provide 'momo)
;;; momo.el ends here

;;; helpers.el --- Utility helper functions -*- lexical-binding: t; -*-

;;; Commentary:
;; This file contains general utility functions used across the configuration.

;;; Code:

(defun momo/reload-config ()
  "Reload the Emacs configuration."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory))
  (message "Configuration reloaded!"))

(defun momo/open-config ()
  "Open the main init.el file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(provide 'helpers)
;;; helpers.el ends here

;;; user-config.el --- User customization variables -*- lexical-binding: t; -*-

;;; Commentary:
;; This file contains ONLY user customization variables and must not depend on
;; any external packages. It is loaded before Elpaca so that variables like
;; momo-use-guix are available during package manager initialization.

;;; Code:

;; User customization group
(defgroup momo nil
  "Momo parent group"
  :prefix "momo-"
  :group 'emacs)

(defcustom momo-use-guix nil
  "Whether or not to use Guix as the primary project manager for Emacs"
  :type 'boolean
  :group 'momo)

(defcustom momo-projects (list (concat (getenv "HOME") "/Projects"))
  "Location of your projects"
  :type 'list
  :group 'momo)

(defcustom momo-roam-directory (concat (getenv "HOME") "/Documents/Roam")
  "Location of your org-roam"
  :type 'string
  :group 'momo)

(defcustom momo-capture-directory (concat (getenv "HOME") "/Documents/Org")
  "Location of your org captures"
  :type 'string
  :group 'momo)

;; Ensure directories exist
(unless (file-directory-p momo-capture-directory)
  (make-directory momo-capture-directory 1))

(unless (file-directory-p momo-roam-directory)
  (make-directory momo-roam-directory 1))

(provide 'user-config)
;;; user-config.el ends here

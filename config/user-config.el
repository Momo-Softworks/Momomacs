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

(defcustom momo-use-guix
  (cond
   ;; Explicit override wins: MOMO_USE_GUIX=1/0 (or yes/no, true/false).
   ((getenv "MOMO_USE_GUIX")
    (not (member (downcase (getenv "MOMO_USE_GUIX"))
                 '("" "0" "no" "false" "nil"))))
   ;; Otherwise auto-detect: a Guix System with the `guix' command available
   ;; uses the manifest backend; everyone else gets Elpaca.
   (t (and (executable-find "guix")
           (file-directory-p "/run/current-system"))))
  "Whether to use Guix (manifest.scm) as the Emacs package backend.
When non-nil, packages come from `guix-emacs-autoload-packages' and
use-package does not :ensure; when nil, Elpaca installs them.

Auto-detected per machine so Guix and non-Guix org members share this
config unchanged: t on a Guix System where `guix' is on PATH, nil
otherwise.  Override with the MOMO_USE_GUIX environment variable
(\"1\"/\"0\") or by customizing this variable."
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

(defcustom momo-personal-dir
  (expand-file-name "momomacs"
                    (or (getenv "XDG_CONFIG_HOME")
                        (concat (getenv "HOME") "/.config")))
  "Personal overlay directory (typically its own git repo).
Momomacs loads from it, when present, in three phases:
  early.el     before the package manager (set variables like
               `momo-use-guix', feed lists, machine specifics);
  config/*.el  alongside Momomacs' own optional configs (see momo.el) —
               also the place to prototype modules before promoting
               them into the framework;
  late.el      after everything else (final overrides)."
  :type 'directory
  :group 'momo)

;; Ensure directories exist
(unless (file-directory-p momo-capture-directory)
  (make-directory momo-capture-directory 1))

(unless (file-directory-p momo-roam-directory)
  (make-directory momo-roam-directory 1))

(provide 'user-config)
;;; user-config.el ends here

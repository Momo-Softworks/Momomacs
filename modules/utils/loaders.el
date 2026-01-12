;;; loaders.el --- Package loading utilities -*- lexical-binding: t; -*-

(require 'cl-lib)

(defun momo/get-package-directory (relative-path)
  "Get the full path for a package configuration file at RELATIVE-PATH."
  (expand-file-name (concat "modules/" relative-path) user-emacs-directory))

(defun momo/defun-packages (package-list)
  "Build an alist mapping package names to their configuration file paths.
PACKAGE-LIST is an alist of (PACKAGE-SYMBOL . RELATIVE-PATH) pairs."
  (cl-loop for (key . value) in package-list
	   collect (cons key (momo/get-package-directory value))))

(setq momo/packages-alist (momo/defun-packages '((elfeed . "social/elfeed")
						 (doom-modeline . "UI/doom-modeline")
						 (meow . "keybindings/meow")
						 (vertico . "completions/vertico")
						 (orderless . "completions/orderless")
						 (pdf-tools . "file-handling/pdf-tools")
						 (corfu . "completions/corfu")
						 (dirvish . "file-handling/dirvish")
						 (dashboard . "UI/dashboard")
						 (racket . "programming/racket")
						 (projectile . "project-management/projectile")
						 (magit . "project-management/magit")
						 (java . "programming/java")
						 (which-key . "keybindings/which-key")
						 (org-modern . "org/modern")
						 (flycheck . "programming/flycheck")
						 (eca . "programming/eca")
						 (rainbow-delimiters . "programming/rainbow-delimiters")
						 (org-roam . "org/roam")
						 (org-fragtog . "org/fragtog")
						 (citeproc . "org/citeproc")
						 (eat . "system/eat")
						 (exwm . "system/exwm")
						 (modus-themes . "UI/modus-themes"))))

(defun momo/load-packages (packages)
  "Load configuration files for each package in PACKAGES list.
Each package must have an entry in `momo/packages-alist'."
  (mapcar (lambda (package)
	    (unless (eq package nil)
	      (let ((config-file (alist-get package momo/packages-alist)))
		(if (not config-file)
		    (error "Can't find %s in momo/packages-alist" package)
		  (condition-case err
		      (load config-file)
		    (error (warn "Failed to load config for %s: %s" package err)))))))
	  packages))

(defun momo/load (module)
  "Load an elisp file MODULE from the modules directory.
MODULE should be a relative path like \"utils/helpers\"."
  (interactive "sModule to load: ")
  (let ((module-path (expand-file-name (concat "modules/" module) user-emacs-directory)))
    (condition-case err
        (load module-path)
      (error (warn "Failed to load module %s: %s" module err)))))


;; Defaults
(defun momo/load-defaults ()
  "Load all default packages from the modules/defaults/ directory.
Automatically loads all .el files in that directory."
  (let ((default-directory (expand-file-name "modules/defaults/" user-emacs-directory)))
    (when (file-directory-p default-directory)
      (normal-top-level-add-to-load-path '("."))
      (normal-top-level-add-subdirs-to-load-path)
      (mapc (lambda (file)
              (condition-case err
                  (load file)
                (error (warn "Failed to load default package %s: %s" file err))))
            (directory-files default-directory 't "^[^#.].*\\.el$")))))

(provide 'loaders)
;;; loaders.el ends here

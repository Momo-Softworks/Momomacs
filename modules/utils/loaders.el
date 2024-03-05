(require 'cl-lib)

(defgroup momo ()
  "Momo Softworks")

(defun momo/get-package-directory (relative-path)
  (concat user-emacs-directory "modules/" relative-path))

(defun momo/defun-packages (package-list)
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
						 (copilot . "programming/copilot")
						 (rainbow-delimiters . "programming/rainbow-delimiters")
						 (org-roam . "org/roam")
						 (org-fragtog . "org/fragtog")
						 (eat . "system/eat")
						 (exwm . "system/exwm")
						 (modus-themes . "UI/modus-themes"))))

(defun momo/load-packages (packages)
  (mapcar (lambda (package)
	    (unless (eq package nil)
	      (if (eq (alist-get package momo/packages-alist) nil)
		  (error "Can't find %s in momo/packages-alist" package)
		(load (alist-get package momo/packages-alist)))
	      )) packages))

(defun momo/load (module)
  "Loads an elisp file in the modules directory"
  (interactive)
  (load (concat user-emacs-directory "modules/" module)))


;; Defaults
(momo/load "defaults/general")
(momo/load "defaults/treesitter-auto")
(momo/load "defaults/savehist")
(momo/load "defaults/smartparens")
(momo/load "defaults/yasnippet")
(momo/load "defaults/eglot")
(momo/load "defaults/marginalia")
(momo/load "defaults/dired-hide-dotfiles")
(momo/load "defaults/ag")

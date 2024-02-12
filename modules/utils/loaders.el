(defgroup momo ()
  "Momo Softworks")

(defun momo/load (module)
  "Loads an elisp file in the modules directory"
  (interactive)
  (load (concat user-emacs-directory "modules/" module)))

(defun momo/load-doom-modeline ()
  "Loads Doom-modeline"
  (interactive)
  (momo/load "UI/doom-modeline"))

(defun momo/load-meow ()
  "Loads meow-mode"
  (interactive)
  (momo/load "keybindings/meow"))

(defun momo/load-vertico ()
  "Loads vertico"
  (interactive)
  (momo/load "completions/vertico"))

(defun momo/load-orderless ()
  "Loads orderless"
  (interactive)
  (momo/load "completions/orderless"))

(defun momo/load-corfu ()
  "Loads corfu"
  (interactive)
  (momo/load "completions/corfu"))

(defun momo/load-modus-themes ()
  "Loads modus-themes"
  (interactive)
  (momo/load "UI/modus-themes"))

(defun momo/load-pdf-tools ()
  "Loads pdf-tools"
  (interactive)
  (momo/load "file-handling/pdf-tools"))

(defun momo/load-dirvish ()
  "Loads dirvish"
  (interactive)
  (momo/load "file-handling/dirvish"))

(defun momo/load-dashboard ()
  "Loads dashboard"
  (interactive)
  (momo/load "UI/dashboard"))

(defun momo/load-racket ()
  "Loads racket-mode"
  (interactive)
  (momo/load "programming/racket"))

(defun momo/load-projectile ()
  "Loads projectile"
  (interactive)
  (momo/load "project-management/projectile"))

(defun momo/load-magit ()
  "Loads magit"
  (interactive)
  (momo/load "project-management/magit"))

(defun momo/load-java ()
  "Loads java-related packages"
  (interactive)
  (momo/load "programming/java"))

(defun momo/load-which-key ()
  "Loads which-key"
  (interactive)
  (momo/load "keybindings/which-key"))

(defun momo/load-org-modern ()
  "Loads org-modern"
  (interactive)
  (momo/load "org/org-modern"))


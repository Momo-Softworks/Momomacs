;;; manifest.scm --- Emacs packages for Momomacs, managed by Guix
;;;
;;; This manifest is the source of truth for Emacs packages ONLY when
;;; `momo-use-guix' is t (see config/user-config.el).  In that mode
;;; guix.el calls `guix-emacs-autoload-packages' and use-package does NOT
;;; :ensure, so anything the config loads MUST be listed here or it fails
;;; to load.  With `momo-use-guix' nil (the current default) Elpaca manages
;;; packages instead and this file is inert.
;;;
;;; Reusable on its own:  guix shell -m manifest.scm   /   guix package -m …
;;; Also composed into the Guix Home profile from
;;; ~/.config/guix/home/home-configuration.scm.

(specifications->manifest
 '(;; --- Completion / minibuffer / UI ---
   "emacs-vertico"
   "emacs-vertico-posframe"
   "emacs-corfu"
   "emacs-cape"
   "emacs-orderless"
   "emacs-consult"            ;loaded via modules/defaults/consult.el
   "emacs-marginalia"
   "emacs-doom-modeline"
   "emacs-modus-themes"
   "emacs-dashboard"
   "emacs-which-key"

   ;; --- Editing / keybindings ---
   "emacs-general"
   "emacs-meow"
   "emacs-smartparens"
   "emacs-yasnippet"
   "emacs-yasnippet-snippets"
   "emacs-treesit-auto"       ;loaded unconditionally via modules/defaults/
   "emacs-ag"

   ;; --- Programming ---
   "emacs-geiser"             ;modules/programming/geiser.el
   "emacs-geiser-guile"       ;  "
   "emacs-racket-mode"
   "emacs-flycheck"
   "emacs-rainbow-delimiters"
   "emacs-eglot"              ;NOTE: Emacs ships eglot built-in; this only
                              ;shadows it with a newer version.  java.el uses
                              ;eglot-ensure.  Drop if you don't need newer.

   ;; --- Project management ---
   "emacs-projectile"
   "emacs-magit"
   "emacs-envrc"              ;modules/project-management/envrc.el

   ;; --- Org ---
   "emacs-org-modern"
   "emacs-org-roam"
   "emacs-org-fragtog"        ;LaTeX fragment preview -> needs texlive below
   "emacs-citeproc"           ;modules/org/citeproc.el

   ;; --- File handling ---
   "emacs-pdf-tools"
   "emacs-visual-fill-column" ;modules/file-handling/visual-fill-column.el
   ;; "emacs-dirvish"  -- installed but NEVER loaded: `dirvish' is mapped in
   ;; loaders.el's alist but not passed to any momo/load-packages call.  Wire
   ;; it into init.el to use it, or leave it out.  Parked here until decided.

   ;; --- Social ---
   "emacs-elfeed"
   "emacs-elfeed-tube"        ;loaded by modules/social/elfeed.el

   ;; --- System / terminal ---
   "emacs-eat"

   ;; --- TeX toolchain: org-fragtog + eww LaTeX math rendering ---
   "texlive-scheme-basic"
   "texlive-dvisvgm"))

;;; ---------------------------------------------------------------------------
;;; Referenced by the config but NOT packaged in Guix (current channels).
;;; In Guix mode these are NOT errors: guix.el auto-falls-back to Elpaca for
;;; any package Guix/Emacs doesn't already provide.  Listed here only so they
;;; stay tracked for eventual packaging (e.g. via the Momo channel), after
;;; which they'd move up into the manifest proper:
;;;
;;;   emacs-shrface           modules/file-handling/shrface.el
;;;   emacs-eca               modules/programming/eca.el (uses a vendored
;;;                           ~/.emacs.d/eca/eca binary regardless)
;;;   emacs-elfeed-tube-mpv   modules/social/elfeed.el (companion to elfeed-tube)
;;;   emacs-packwiz           modules/gaming/packwiz.el (Momo channel?)
;;;   emacs-dired-hide-dotfiles  modules/defaults/ (loaded unconditionally)
;;;
;;; Conditional — only loaded for an EXWM session (init.el gates on
;;; EXWM_LAUNCH).  AVAILABLE in Guix as "emacs-exwm" but pulls an X11 stack,
;;; so left out by default; add it if you run the EXWM xsession:
;;;   ;; "emacs-exwm"
;;;
;;; Deliberately Elpaca-only (newer than Emacs ships; Guix's magit/doom-modeline
;;; bring their own as propagated inputs, so not needed here):
;;;   f, transient, shrink-path   -- see modules/utils/elpaca.el

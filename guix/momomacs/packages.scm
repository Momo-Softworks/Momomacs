;;; momomacs/packages.scm --- the Momomacs package set, as a Guix module.
;;;
;;; This is the channel-facing source of truth for every Guix package the
;;; Momomacs Emacs configuration needs.  Consumers:
;;;
;;;   * ../../manifest.scm wraps it so `guix shell -m manifest.scm' works
;;;     from a plain checkout, no channel required;
;;;   * a Guix Home config can (use-modules (momomacs packages)) — either
;;;     via the momomacs channel or via a load-path pointing at a live
;;;     checkout's guix/ directory (the fast path while hacking on it);
;;;   * `guix pull' compiles this module when momomacs is a channel.
;;;
;;; The specifications are resolved against the consumer's channels, so this
;;; module deliberately contains only spec strings, not package variables.

(define-module (momomacs packages)
  #:use-module (gnu packages)
  #:use-module (guix profiles)
  #:use-module (momomacs packages emacs)  ;channel-local emacs packages
  #:export (%momomacs-package-specifications
            momomacs-packages
            momomacs-manifest))

(define %momomacs-package-specifications
  ;; NOTE: this list is the manifest ONLY when `momo-use-guix' is t (see
  ;; config/user-config.el).  In that mode guix.el calls
  ;; `guix-emacs-autoload-packages' and use-package does NOT :ensure, so
  ;; anything the config loads MUST be listed here or it fails to load.
  ;; With `momo-use-guix' nil, Elpaca manages packages and this is inert.
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
    "emacs-geiser-guile"       ;  ""
    "emacs-arei"               ;modules/programming/arei.el
    "emacs-racket-mode"
    "emacs-flycheck"
    "emacs-rainbow-delimiters"
    "emacs-parinfer-rust-mode"
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
    "emacs-openwith"           ;modules/defaults/openwith.el (media -> player)
    "mpv"                      ;  ""  the player openwith hands media to
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
    "emacs-exwm"
    "emacs-xdg-launcher"
    "emacs-bluetooth"
    "emacs-pinentry"

    ;; --- TeX toolchain: org-fragtog + eww LaTeX math rendering ---
    ;; scheme-basic is too minimal for Org's preview preamble; these cover the
    ;; packages Org includes in math fragments (color/graphicx, amsmath,
    ;; amssymb, ulem).  Emacs also needs GUIX_TEXMF set so `latex' finds this
    ;; tree -- see modules/utils/guix.el.
    "texlive-scheme-basic"
    "texlive-dvisvgm"
    "texlive-graphics"     ;graphicx + color
    "texlive-amsmath"
    "texlive-amsfonts"     ;amssymb
    "texlive-ulem"

    ;; --- Flycheck linter backends ---
    "jq"                    ;json-jq checker
    "python-proselint"      ;proselint checker
    "python-yamllint"       ;yaml-yamllint checker
    "libxml2"               ;xml-xmllint checker

    ;; --- Spell checking (jinx + enchant + hunspell) ---
    "emacs-jinx"            ;async spell-checker
    "hunspell-dict-en-us")) ;English (US) dictionary

;;; ---------------------------------------------------------------------------
;;; Channel-local packages — needed by the config but absent from upstream
;;; Guix, so this channel carries them in (momomacs packages emacs) and
;;; appends them as variables below:
;;;
;;;   emacs-shrface           modules/file-handling/shrface.el
;;;                           (+ emacs-language-detection, its dependency)
;;;   emacs-eca               modules/programming/eca.el (elisp client only;
;;;                           the eca server binary is separate)
;;;   emacs-packwiz           modules/gaming/packwiz.el
;;;   emacs-dired-hide-dotfiles  modules/defaults/ (loaded unconditionally)
;;;
;;; NOT needed as a package: elfeed-tube-mpv ships inside upstream Guix's
;;; `emacs-elfeed-tube' (which also propagates emacs-mpv), so the spec above
;;; already covers modules/social/elfeed.el's use-package for it.
;;;
;;; Conditional — only loaded for an EXWM session (init.el gates on
;;; EXWM_LAUNCH).  `emacs-exwm' is included above so the Guix profile can start
;;; the EXWM xsession without falling back to Elpaca.
;;;
;;; Deliberately Elpaca-only (newer than Emacs ships; Guix's magit/doom-modeline
;;; bring their own as propagated inputs, so not needed here):
;;;   f, transient, shrink-path   -- see modules/utils/elpaca.el

(define %momomacs-channel-packages
  ;; Variables, not specs: these exist only in this channel, so spec-string
  ;; resolution against the consumer's channels cannot find them.
  (list emacs-language-detection
        emacs-shrface
        emacs-dired-hide-dotfiles
        emacs-eca
        emacs-packwiz))

(define (momomacs-packages)
  "The Momomacs package set, resolved against the consumer's channels."
  (append (specifications->packages %momomacs-package-specifications)
          %momomacs-channel-packages))

(define (momomacs-manifest)
  "The Momomacs package set as a manifest, for guix shell/package -m."
  (packages->manifest (momomacs-packages)))

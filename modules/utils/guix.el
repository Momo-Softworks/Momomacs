;;; guix.el --- Guix package backend with automatic Elpaca fallback -*- lexical-binding: t; -*-

;;; Commentary:
;; Active only when `momo-use-guix' is t.  Emacs packages come primarily from
;; Guix (manifest.scm), autoloaded here.  Anything Guix does NOT provide (and
;; that isn't built into Emacs) falls back to Elpaca automatically.
;;
;; Mechanism: Elpaca stays bootstrapped even in Guix mode.  We advise
;; use-package's :ensure handler so that, for any package Guix already provides
;; (i.e. already on `load-path' after `guix-emacs-autoload-packages'), :ensure
;; is forced to nil -- use-package still runs the package's :init/:config/etc.,
;; but Elpaca does NOT install it.  This overrides whatever the module wrote
;; (`:ensure t', `:ensure (:wait t)', an explicit recipe, or nothing), so Guix
;; packages are never re-fetched and the first `:wait' batch can't stall init.
;; Packages Guix lacks keep their :ensure and install via Elpaca as before.
;; No hand-maintained "not in Guix" list.

;;; Code:

(require 'cl-lib)
(require 'use-package-core)

;; Make every Guix-installed Emacs package visible on `load-path' BEFORE any
;; module's use-package form is expanded, so the check below is accurate.
(guix-emacs-autoload-packages)

(defun momo/package-on-load-path-p (name)
  "Non-nil if package NAME is already available (Guix-installed or built-in)."
  (and (locate-library (format "%s" name)) t))

;; Packages Guix lacks (and that have no explicit :ensure) still default to
;; installing via Elpaca; the handler below only neutralizes the ones Guix has.
(setq use-package-always-ensure t)

(defun momo/guix-skip-provided (orig name keyword ensure rest state)
  "Around-advice for `use-package-handler/:ensure'.
Force ENSURE to nil for any package Guix/Emacs already provides, so it loads
from Guix and Elpaca skips it; otherwise pass the module's ENSURE through."
  (funcall orig name keyword
           (if (momo/package-on-load-path-p name) nil ensure)
           rest state))

(advice-add 'use-package-handler/:ensure :around #'momo/guix-skip-provided)

(provide 'guix)
;;; guix.el ends here

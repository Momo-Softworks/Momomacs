;;; manifest.scm --- Emacs packages for Momomacs, managed by Guix
;;;
;;; Thin wrapper so a plain checkout works without the channel:
;;;   guix shell -m manifest.scm   /   guix package -m manifest.scm
;;;
;;; The actual package set (and its documentation) lives in the channel
;;; module guix/momomacs/packages.scm; channel consumers should
;;; (use-modules (momomacs packages)) instead of loading this file.

(add-to-load-path (string-append (dirname (current-filename)) "/guix"))

(use-modules (momomacs packages))

(momomacs-manifest)

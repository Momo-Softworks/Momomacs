;;; shrface.el --- Org-like styling for shr/eww buffers -*- lexical-binding: t; -*-

;;; Commentary:
;; `shrface' re-renders shr-based buffers (eww, EPUB, etc.) with org-like
;; styling: proper headline faces and levels, nicer bullets, fontified
;; links, and outline/imenu navigation.
;;
;; `shrface-basic'/`shrface-trial' must run *before* a page is rendered so
;; that `shr-external-rendering-functions' is in place, hence we set it up
;; as soon as eww is loaded.  `shrface-mode' (enabled per buffer after each
;; render) provides the outline/imenu navigation.

;;; Code:

(use-package shrface
  :defer t
  :init
  (with-eval-after-load 'eww
    (require 'shrface)
    (shrface-basic)
    (shrface-trial)
    (setq shrface-href-versatile t)
    (add-hook 'eww-after-render-hook #'shrface-mode)))

;;; shrface.el ends here

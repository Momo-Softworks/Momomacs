;;; visual-fill-column.el --- Centered, capped reading column -*- lexical-binding: t; -*-

;;; Commentary:
;; Installs `visual-fill-column', which lets text wrap at a chosen
;; `fill-column' and be centered with margins instead of stretching across
;; the whole window.  It is wired into eww for comfortable reading in
;; config/eww-config.el (see `momo/eww-setup-reading').

;;; Code:

(use-package visual-fill-column
  :defer t)

;;; visual-fill-column.el ends here

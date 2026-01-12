;;; modus-themes.el --- Modus themes configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Modus themes (vivendi and operandi).
;; High-contrast, accessible color themes by Protesilaos Stavrou.

;;; Code:

(use-package modus-themes
  :ensure (:wait t)
  :custom
  (modus-themes-italic-constructs t)    ; Use italics for certain constructs
  (modus-themes-bold-constructs t)      ; Use bold for certain constructs
  (modus-themes-mixed-fonts t)          ; Enable mixed font heights
  (modus-themes-headings '((1 . (1.5))  ; Level 1 headings 1.5x size
                           (2 . (1.3))  ; Level 2 headings 1.3x size
                           (t . (1.1))))) ; Other headings 1.1x size

(provide 'modus-themes)
;;; modus-themes.el ends here

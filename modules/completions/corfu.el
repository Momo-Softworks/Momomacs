;;; corfu.el --- Corfu completion configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Corfu in-buffer completion framework and Cape extensions.

;;; Code:

(use-package corfu
  :ensure (:wait t)
  :custom
  (corfu-cycle t)           ; Enable cycling for next/previous
  (corfu-auto t)            ; Enable auto completion
  (corfu-auto-prefix 1)     ; Minimum prefix length for auto completion
  (corfu-auto-delay 0)      ; No delay for auto completion
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :ensure nil
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; completion-at-point is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; Cape - Completion At Point Extensions
(use-package cape
  :ensure (:wait t)
  ;; Bind dedicated completion commands
  :general (("C-c c p" . completion-at-point)
         ("C-c c t" . complete-tag)
         ("C-c c d" . cape-dabbrev)
         ("C-c c h" . cape-history)
         ("C-c c f" . cape-file)
         ("C-c c k" . cape-keyword)
         ("C-c c s" . cape-elisp-symbol)
         ("C-c c e" . cape-elisp-block)
         ("C-c c a" . cape-abbrev)
         ("C-c c l" . cape-line)
         ("C-c c w" . cape-dict)
         ("C-c c :" . cape-emoji)
         ("C-c c \\" . cape-tex)
         ("C-c c _" . cape-tex)
         ("C-c c ^" . cape-tex)
         ("C-c c &" . cape-sgml)
         ("C-c c r" . cape-rfc1345))
  :init
  ;; Add to the global default value of `completion-at-point-functions'
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

(provide 'corfu)
;;; corfu.el ends here

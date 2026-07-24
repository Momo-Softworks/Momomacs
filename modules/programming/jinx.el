;;; jinx.el --- Jinx spell-checking configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Jinx is an async spell-checker backed by Enchant.
;; It highlights misspelled words lazily without blocking Emacs.

;;; Code:

(use-package jinx
  :demand t
  :config
  ;; English is the default; add more codes for multilingual documents.
;;  (setq jinx-languages '("en_US"))

  ;; Enable globally — jinx activates in text/org/prog-mode buffers
  ;; automatically via global-jinx-mode.
  (global-jinx-mode 1))

(provide 'jinx)
;;; jinx.el ends here

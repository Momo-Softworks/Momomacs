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
  ;; automatically via global-jinx-mode.  Jinx compiles a small C module
  ;; against Enchant on first use, so only turn it on when that module is
  ;; already built or a C compiler is around (stock Windows has neither,
  ;; and every buffer would otherwise error with "No C compiler found").
  (if (or (locate-library (concat "jinx-mod" module-file-suffix))
          (seq-some #'executable-find '("cc" "gcc" "clang")))
      (global-jinx-mode 1)
    (message "Jinx: no C compiler or prebuilt jinx-mod found; spell-checking is off")))

(provide 'momo-jinx)
;;; jinx.el ends here

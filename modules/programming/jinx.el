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
  ;; On Windows the module also needs libenchant on the PATH Emacs was
  ;; started with: Windows looks up DLLs there, and `setenv' can't change it.
  (if (and (or (locate-library (concat "jinx-mod" module-file-suffix))
               (seq-some #'executable-find '("cc" "gcc" "clang")))
           (or (not (eq system-type 'windows-nt))
               (locate-file "libenchant-2-2.dll"
                            (parse-colon-path
                             (getenv-internal "PATH" initial-environment)))))
      (global-jinx-mode 1)
    (message "Jinx: needs a C compiler and Enchant (on Windows, run the Momomacs installer); spell-checking is off")))

(provide 'momo-jinx)
;;; jinx.el ends here

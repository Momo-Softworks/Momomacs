(use-package flycheck
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode)

  ;; flycheck 36.0 (the latest -- identical in Guix and MELPA) ships an
  ;; `org-lint' checker that assumes each result's line is a number.  Org 9.7+
  ;; returns it as a propertized string (e.g. #("85" 0 2 (org-lint-marker ...))),
  ;; so the checker dies with `number-or-marker-p' in every Org buffer.  Coerce
  ;; a string line to a number at the single bottleneck, `flycheck-error-new-at'
  ;; (no legitimate checker passes a string line, so this is safe globally).
  (defun momo/flycheck-coerce-string-line (args)
    "Coerce a string LINE (first arg) to a number for `flycheck-error-new-at'."
    (if (stringp (car args))
        (cons (string-to-number (car args)) (cdr args))
      args))
  (advice-add 'flycheck-error-new-at :filter-args
              #'momo/flycheck-coerce-string-line))

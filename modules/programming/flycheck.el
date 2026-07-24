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
              #'momo/flycheck-coerce-string-line)

  ;; --- Checker chains (explicit, even when flycheck 36 defaults them) -------

  ;; emacs-lisp → emacs-lisp-checkdoc (docstring & style)
  ;; The `emacs-lisp' checker already byte-compiles in a subprocess, so
  ;; byte-compile warnings (unused vars, arg count mismatches, etc.) are
  ;; included.  checkdoc adds docstring format and naming convention checks.
  (flycheck-add-next-checker 'emacs-lisp 'emacs-lisp-checkdoc)

  ;; sh-bash → sh-shellcheck (requires shellcheck)
  ;; sh-bash uses `bash -n' for syntax; sh-shellcheck provides deeper
  ;; analysis once the `shellcheck' package is installed.
  (flycheck-add-next-checker 'sh-bash 'sh-shellcheck)

  ;; --- Checkers that auto-enable when their executables are on PATH ---------
  ;;
  ;; These require no configuration — flycheck auto-selects the best available
  ;; checker per mode.  The corresponding Guix packages are listed in
  ;; ~/.emacs.d/manifest.scm.
  ;;
  ;;   org-lint           built-in (no executable needed) — org-mode
  ;;   json-jq            package: jq                       — json-mode
  ;;   proselint          package: python-proselint         — text-mode
  ;;   yaml-yamllint      package: python-yamllint          — yaml-mode
  ;;   xml-xmllint        package: libxml2                  — nxml-mode
  )
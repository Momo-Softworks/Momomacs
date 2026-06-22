(use-package flycheck
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode)

  ;; Fix flycheck's built-in `org-lint' checker for Org 9.7+ (Emacs 30 / Guix).
  ;; Newer `org-lint' returns each result's line as a *propertized string*
  ;; (e.g. #("85" 0 2 (org-lint-marker ...))) rather than a number, which makes
  ;; flycheck's shipped checker fail with "number-or-marker-p". We override just
  ;; that checker's :start to coerce a string line to a number (works on both
  ;; old and new Org).  See flycheck-define-generic-checker for `org-lint'.
  (defun momo/flycheck-org-lint-start (checker callback)
    "Org-lint flycheck :start tolerant of Org 9.7+ propertized-string lines."
    (condition-case err
        (let ((errors
               (delq nil
                     (mapcar
                      (lambda (e)
                        (pcase e
                          (`(,_n [,line ,_trust ,desc ,_checker])
                           (flycheck-error-new-at
                            (if (stringp line) (string-to-number line) line)
                            nil 'info desc :checker checker))
                          (_
                           (flycheck-error-new-at
                            1 nil 'warning
                            (format "Unexpected org-lint format: %S" e)
                            :checker checker))))
                      (org-lint)))))
          (funcall callback 'finished errors))
      (error (funcall callback 'errored (error-message-string err)))))

  (with-eval-after-load 'flycheck
    (when (flycheck-valid-checker-p 'org-lint)
      (setf (flycheck-checker-get 'org-lint 'start)
            #'momo/flycheck-org-lint-start))))

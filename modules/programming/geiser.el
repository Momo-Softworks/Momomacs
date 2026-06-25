(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory))
  :config
  (setq geiser-default-implementation 'guile)
  (with-eval-after-load 'geiser-kawa
    (setq geiser-default-implementation 'guile))
  (defun momo/geiser--repl-connected-p ()
    "Return t if a Geiser REPL is connected and alive for the current buffer."
    (or (derived-mode-p 'geiser-repl-mode)
        (ignore-errors
          (let ((conn (geiser-repl--connection)))
            (and conn (geiser-con--connected-p conn))))
        (cl-some (lambda (b)
                   (with-current-buffer b
                     (and (derived-mode-p 'geiser-repl-mode)
                          (get-buffer-process b))))
                 (buffer-list))))
  (defun momo/geiser--wrap-capf ()
    (setq-local completion-at-point-functions
                (mapcar
                 (lambda (f)
                   (if (memq f '(geiser-capf--for-symbol
                                 geiser-capf--for-module))
                       (apply-partially
                        (lambda (fn &rest args)
                          (condition-case nil
                              (and (momo/geiser--repl-connected-p)
                                   (apply fn args))
                            (error nil)))
                        f)
                     f))
                 completion-at-point-functions)))
  (add-hook 'geiser-mode-hook #'momo/geiser--wrap-capf))

(use-package geiser-guile
  :after geiser)

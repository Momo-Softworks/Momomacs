(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile kawa))
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory))
  :config
  ;; Wrap geiser's capf functions so they silently return nil when
  ;; there's no REPL running, instead of spamming errors.
  (defun momo/geiser--repl-connected-p ()
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
                                 geiser-capf--for-module
                                 geiser-kawa-capf))
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

;; Phase 2: Prevent geiser's internal font-lock buffers from stealing focus.
;; Three functions use set-buffer on internal temp buffers, triggering
;; scheme-mode-hook (geiser-mode, geiser-kawa-capf-setup, etc.) in those
;; buffers.  Wrap them all with save-window-excursion.
(with-eval-after-load 'geiser-autodoc
  (advice-add 'geiser-autodoc--str :around
    (lambda (orig &rest args)
      (save-current-buffer
        (save-window-excursion
          (apply orig args))))))
(with-eval-after-load 'geiser-syntax
  (advice-add 'geiser-syntax--scheme-str :around
    (lambda (orig &rest args)
      (save-current-buffer
        (save-window-excursion
          (apply orig args)))))
  (advice-add 'geiser-syntax--fontify-syntax-region :around
    (lambda (orig &rest args)
      (save-current-buffer
        (save-window-excursion
          (apply orig args))))))

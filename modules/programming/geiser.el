(use-package geiser
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  ;; Use the Guile from the current environment (e.g. a `guix shell`),
  ;; so per-project load paths set via .dir-locals.el are respected.
  (geiser-repl-history-filename
   (expand-file-name "geiser-history" user-emacs-directory))
  :config
  ;; geiser-kawa (loaded later via kawa.el) may push itself as the
  ;; default implementation.  Re-assert Guile once kawa is done.
  (setq geiser-default-implementation 'guile)
  (with-eval-after-load 'geiser-kawa
    (setq geiser-default-implementation 'guile))
  ;; Corfu + Geiser = noise.  Geiser's capf functions in
  ;; completion-at-point-functions error when there's no REPL running,
  ;; and the errors spill into *Messages* on every keystroke.
  ;; Instead of trying to suppress each error, wrap the capf functions
  ;; so they silently return nil when anything goes wrong.
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
  ;; Wrap Geiser capf functions AFTER Geiser has added them to
  ;; completion-at-point-functions (it does so in geiser-mode, which
  ;; runs during scheme-mode-hook — after our hook).  Using
  ;; geiser-mode-hook ensures our wrapping wins.
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

;; Prevent geiser's internal font-lock buffer from stealing focus during
;; Corfu completions.  geiser-syntax--fontify-syntax-region calls set-buffer
;; on the font-lock buffer, which can confuse completion-at-point.
;; We wrap it to save and restore the current buffer and selected window.
(add-to-list 'display-buffer-alist
             '(" \\*Geiser font-lock\\*"
               (display-buffer-no-window)
               (allow-no-window . t)))

(with-eval-after-load 'geiser-syntax
  (defvar momo/geiser--orig-fontify
    (symbol-function 'geiser-syntax--fontify-syntax-region))
  (defun geiser-syntax--fontify-syntax-region (start end)
    "Like original, but preserves current buffer and window."
    (let ((orig-buf (current-buffer))
          (orig-win (selected-window)))
      (funcall momo/geiser--orig-fontify start end)
      (unless (eq (current-buffer) orig-buf)
        (set-buffer orig-buf))
      (unless (eq (selected-window) orig-win)
        (select-window orig-win)))))

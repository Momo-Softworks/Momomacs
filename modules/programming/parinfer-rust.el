;;; parinfer-rust.el — Parinfer minor mode via parinfer-rust
;;;
;;; parinfer-rust-mode is a minor mode that automatically manages parentheses
;;; in Lisp code by inferring close-parens from indentation (indent/smart modes)
;;; or correcting indentation from parens (paren mode).  The actual computation
;;; is done by the parinfer-rust-emacs Rust shared library.
;;;
;;; When installed via Guix (momo-use-guix), the library path is patched at
;;; package build time to point at the Guix store; no manual configuration
;;; is needed.  When installed via Elpaca, the library auto-downloads.
;;;
;;; NOTE: The emacs Rust crate (v0.19.0) in parinfer-rust-emacs is
;;; incompatible with Emacs 30's module ABI.  Loading the .so via `load'
;;; / `require' (which parinfer-rust-mode.el does at top level) calls
;;; emacs_module_init which returns error 2: provide succeeds but function
;;; registration fails.  A subsequent `module-load' call on the same handle
;;; completes the registration.  We do this in :config so it runs after
;;; parinfer-rust-mode.el's top-level require has done the partial init.
;;; Once the emacs crate is updated for Emacs 30 this whole block goes away.

(use-package parinfer-rust-mode
  :commands (parinfer-rust-mode
             parinfer-rust-switch-mode
             parinfer-rust-toggle-disable
             parinfer-rust-toggle-paren-mode)
  :hook ((emacs-lisp-mode . parinfer-rust-mode)
         (lisp-mode . parinfer-rust-mode)
         (scheme-mode . parinfer-rust-mode)
         (racket-mode . parinfer-rust-mode))
  :init
  ;; Never auto-download — the Guix package provides the library, and on
  ;; non-Guix machines Elpaca + the default download works fine.
  (setq parinfer-rust-auto-download nil)
  ;; Skip the initial indentation check.  With the default 'defer setting,
  ;; parinfer can false-positive on unbalanced quotes inside comment blocks
  ;; and stall in a half-enabled state.  'nil means "just run, don't ask."
  (setq parinfer-rust-check-before-enable nil)
  ;; parinfer-rust-flycheck.el incorrectly declares this only inside
  ;; eval-when-compile; declare it here so flycheck doesn't error with
  ;; "void-variable" before parinfer first executes.
  (defvar parinfer-rust--error nil)
  :config
  ;; We use flycheck, not flymake.  parinfer-rust-flymake.el unconditionally
  ;; adds itself to parinfer-rust-mode-hook and errors when flymake isn't
  ;; initialized.  Remove it.
  (remove-hook 'parinfer-rust-mode-hook 'parinfer-rust-setup-flymake)
  ;; Auto-disable conflicting minor modes (smartparens, electric-pair, etc.)
  (setq parinfer-rust-disable-troublesome-modes t)
  (add-to-list 'parinfer-rust-troublesome-modes 'smartparens-mode)
  ;; Complete the module initialization (see NOTE at top of file).
  ;; parinfer-rust-mode.el's top-level `require' has already partially
  ;; loaded the .so (provide succeeded, function registration failed).
  ;; A second call via module-load finishes the job.
  (unless (fboundp 'parinfer-rust-version)
    (condition-case nil
        (module-load parinfer-rust-library)
      (error nil)))
  ;; parinfer-rust-mode defers full activation when the buffer isn't in
  ;; the selected window (e.g. restored buffers at startup).  Force a
  ;; real enable whenever the mode turns on but the change tracker is
  ;; missing (the telltale sign of a deferred half-enable).
  (advice-add 'parinfer-rust-mode :after
              (lambda (&rest _)
                (when (and parinfer-rust-mode
                           (not parinfer-rust--change-tracker))
                  (parinfer-rust-mode-enable))))
  ;; A safe line-kill that won't fight parinfer's paren inference.
  (defun momo/parinfer-safe-kill-whole-line ()
    "Kill the current line with parinfer temporarily disabled."
    (interactive)
    (let ((was-disabled parinfer-rust--disable))
      (unless was-disabled (parinfer-rust-toggle-disable))
      (unwind-protect
          (kill-whole-line)
        (unless was-disabled (parinfer-rust-toggle-disable)))))
  :bind
  (:map parinfer-rust-mode-map
        ("C-c C-p t" . parinfer-rust-toggle-paren-mode)
        ("C-c C-p s" . parinfer-rust-switch-mode)
        ("C-c C-p d" . parinfer-rust-toggle-disable)
        ("<S-backspace>" . momo/parinfer-safe-kill-whole-line)))

(provide 'parinfer-rust)
;;; parinfer-rust.el ends here

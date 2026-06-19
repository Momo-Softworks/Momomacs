;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Increase garbage collection threshold during startup for faster loading
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Restore garbage collection settings after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024) ; 16MB
                  gc-cons-percentage 0.1)))

;; Disable package.el in favor of Elpaca
(setq package-enable-at-startup nil)

;; Use-package settings
(setq use-package-always-ensure t)

;; Prevent unwanted runtime compilation
(setq native-comp-deferred-compilation-deny-list nil)

;; Suppress compiler warnings
(setq native-comp-async-report-warnings-errors nil
      warning-suppress-log-types '((comp))
      warning-suppress-types '((emacs)))

;; Separate custom file from init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(defconst my-on-android (eq system-type 'android))

(when my-on-android
  (let ((termux-bin "/data/data/com.termux/files/usr/bin"))
    ;; Force Emacs to look in Termux bin folder first
    (setq exec-path (cons termux-bin exec-path))
    (setenv "PATH" (concat termux-bin ":" (getenv "PATH")))
    ;; Set Termux bash as the default shell
    (setq explicit-shell-file-name (concat termux-bin "/bash"))))

;; Put GNU Guix profiles on PATH/exec-path even when Emacs is launched from a
;; graphical session (which never sources ~/.bashrc).  Without this, envrc/direnv
;; and Geiser cannot find `guix`, `direnv` or the project's `guile`.
(dolist (guix-bin (list (expand-file-name "~/.config/guix/current/bin")
                        (expand-file-name "~/.guix-profile/bin")))
  (when (file-directory-p guix-bin)
    (add-to-list 'exec-path guix-bin)
    (setenv "PATH" (concat guix-bin path-separator (getenv "PATH")))))

;;; early-init.el ends here

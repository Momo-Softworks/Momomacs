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

;; On Windows, programs started from the Start menu inherit Explorer's PATH,
;; which stays stale until you sign out after installing Git or other tools.
;; Add the usual install folders so Elpaca can find git (and ag etc.) anyway.
(when (eq system-type 'windows-nt)
  (dolist (dir (list (expand-file-name "Git/cmd" (getenv "ProgramFiles"))
                     (and (getenv "LOCALAPPDATA")
                          (expand-file-name "Microsoft/WinGet/Links"
                                            (getenv "LOCALAPPDATA")))))
    (when (and dir (file-directory-p dir)
               (not (member dir exec-path)))
      (add-to-list 'exec-path dir)
      (setenv "PATH" (concat (convert-standard-filename dir)
                             path-separator (getenv "PATH")))))
  ;; MSYS2's UCRT64 toolchain (gcc, pkg-config, Enchant) lets Jinx build its
  ;; spell-check module and find libenchant at runtime.  Append it so its
  ;; Unix tools never shadow the Windows ones above.
  (let ((ucrt (or (getenv "MOMO_MSYS2_UCRT64") "C:/msys64/ucrt64/bin")))
    (when (and (file-directory-p ucrt) (not (member ucrt exec-path)))
      (setq exec-path (append exec-path (list ucrt)))
      (setenv "PATH" (concat (getenv "PATH") path-separator
                             (convert-standard-filename ucrt))))))

;;; early-init.el ends here

;;; settings.el --- General Emacs settings -*- lexical-binding: t; -*-

;;; Commentary:
;; General Emacs UI and behavior settings.
;; Org-mode specific settings are in org-config.el

;;; Code:

;; UI Settings
(menu-bar-mode -1)    ; Disable menu bar
(tool-bar-mode -1)    ; Disable tool bar
(scroll-bar-mode -1)  ; Disable scroll bar

;; Font settings
(set-face-attribute 'default nil :height 120)

;; Line spacing
(setq-default line-spacing 2)

;; Backup and auto-save configuration
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory))
      (autosave-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (unless (file-directory-p backup-dir)
    (make-directory backup-dir t))
  (unless (file-directory-p autosave-dir)
    (make-directory autosave-dir t))
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,autosave-dir t))))

;; Better defaults
(setq-default
 fill-column 80                    ; Set width for automatic line breaks
 help-window-select t              ; Focus new help windows when opened
 indent-tabs-mode nil              ; Use spaces instead of tabs
 tab-width 4                       ; Set width for tabs
 inhibit-startup-screen t          ; Disable start-up screen
 initial-scratch-message ""        ; Empty scratch buffer
 kill-ring-max 128                 ; Maximum length of kill ring
 load-prefer-newer t               ; Load newest version of a file
 mark-ring-max 128                 ; Maximum length of mark ring
 read-process-output-max (* 1024 1024)  ; Increase read size per process
 scroll-conservatively 10          ; Smooth scrolling
 select-enable-clipboard t         ; Merge system's and Emacs' clipboard
 vc-follow-symlinks t             ; Don't ask for confirmation when opening symlinked file
 )

;; Enable useful commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Display line numbers in programming modes
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Disable line numbers in scratch buffer to avoid display glitches
(add-hook 'lisp-interaction-mode-hook
          (lambda ()
            (when (string= (buffer-name) "*scratch*")
              (display-line-numbers-mode -1))))

;; Show matching parentheses
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Load custom file if it exists
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'settings)
;;; settings.el ends here


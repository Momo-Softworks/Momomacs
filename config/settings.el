;;; settings.el --- General Emacs settings -*- lexical-binding: t; -*-

;;; Commentary:
;; General Emacs UI and behavior settings.
;; Org-mode specific settings are in org-config.el

;;; Code:

;; UI Settings
(menu-bar-mode -1)    ; Disable menu bar
(tool-bar-mode -1)    ; Disable tool bar
(scroll-bar-mode -1)  ; Disable scroll bar

;; Font settings — Geist Mono for code (default/fixed-pitch), Geist for prose
;; (variable-pitch).  Both ship via the momomacs channel's `font-geist'
;; package.  Each block is guarded on font availability so a machine without
;; the package still starts cleanly (falling back to the height only).
(defvar momo-mono-font "Geist Mono"
  "Monospace family for the default and `fixed-pitch' faces.")
(defvar momo-variable-font "Geist"
  "Proportional family for the `variable-pitch' face.")
(defvar momo-font-height 120
  "Default face height, in 1/10 pt.")

(set-face-attribute 'default nil :height momo-font-height)
(when (find-font (font-spec :family momo-mono-font))
  (set-face-attribute 'default nil :family momo-mono-font)
  (set-face-attribute 'fixed-pitch nil :family momo-mono-font :height 1.0)
  ;; new frames (daemon/EXWM) pick the font up too
  (add-to-list 'default-frame-alist
               (cons 'font (format "%s-%d" momo-mono-font (/ momo-font-height 10)))))
(when (find-font (font-spec :family momo-variable-font))
  (set-face-attribute 'variable-pitch nil :family momo-variable-font :height 1.0))

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

;; Automatically refresh buffers when files change on disk.
(require 'autorevert)
(setq auto-revert-verbose nil)
(global-auto-revert-mode 1)

;; Show matching parentheses
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Load custom file if it exists
(when (file-exists-p custom-file)
  (load custom-file))

;; Browser / eww configuration now lives in config/eww-config.el
;; (loaded via momo.el).

(provide 'settings)
;;; settings.el ends here


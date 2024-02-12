(setq warning-suppress-log-types '((comp)))
(setq native-comp-async-report-warnings-errors -1)
(menu-bar-mode -1) ;; Disable menu bar
(tool-bar-mode -1) ;; Disable tool bar
(scroll-bar-mode -1) ;; Disable scroll bar
(set-face-attribute 'default nil :height 120) ;; Bigger fonts

;; Move backups and auto-saves to emacs folder
(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))

;; Change line spacing
(setq-default line-spacing 2)

;; Org
(setq
 ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-ellipsis "…"
 org-startup-indented t

 ;; Agenda styling
 org-list-indent-offset 2
 org-indent-indentation-per-level 4
 org-agenda-tags-column 0
 org-agenda-block-separator ?─
 org-agenda-time-grid
 '((daily today require-timed)
   (800 1000 1200 1400 1600 1800 2000)
   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 org-agenda-current-time-string
 "◀── now ─────────────────────────────────────────────────")


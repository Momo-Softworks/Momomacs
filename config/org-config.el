;;; org-config.el --- Org-mode capture and refile configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for org-mode, including capture templates, refile targets,
;; and general org-mode settings.

;;; Code:

;; General Org settings
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

;; Set org directory
(setq org-directory momo-capture-directory)

;; Capture templates
(setq org-capture-templates
      `(("t" "Todo" entry (file+headline ,(concat momo-capture-directory "/GTD/tasks.org") "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree ,(concat momo-capture-directory "/GTD/journal.org"))
         "* %?\nEntered on %U\n  %i\n  %a")
	("i" "Idea" entry (file ,(concat momo-capture-directory "/ideas.org"))
         "* %?\n")
	("T" "Tickler" entry
         (file+headline ,(concat momo-capture-directory "/GTD/ticklers.org") "Tickler")
         "* %i%? \n %U")))

;; Refile configuration
(setq org-refile-allow-creating-parent-nodes 'confirm
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

;; Refile targets
(setq org-refile-targets 
      `((,(expand-file-name "GTD/tasks.org" momo-capture-directory) :maxlevel . 9)
        (,(expand-file-name "GTD/someday.org" momo-capture-directory) :maxlevel . 9)
        (,(expand-file-name "GTD/projects.org" momo-capture-directory) :maxlevel . 9)
        (,(expand-file-name "GTD/delegated.org" momo-capture-directory) :maxlevel . 9)
        (,(expand-file-name "GTD/trash.org" momo-capture-directory) :maxlevel . 9)))

(provide 'org-config)
;;; org-config.el ends here

;;; org-config.el --- Org-mode capture and refile configuration -*- lexical-binding: t; -*-

(setq org-capture-templates
      `(("t" "Todo" entry (file+headline ,(concat capture-directory "/GTD/tasks.org") "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree ,(concat capture-directory "/GTD/journal.org"))
         "* %?\nEntered on %U\n  %i\n  %a")
	("i" "Idea" entry (file ,(concat capture-directory "/ideas.org"))
         "* %?\n")
	("T" "Tickler" entry
         (file+headline ,(concat capture-directory "/GTD/ticklers.org") "Tickler")
         "* %i%? \n %U")))

(setq org-directory capture-directory)

;; (unless (file-directory-p (concat capture-directory "/GTD"))
;;   (make-directory (concat capture-directory "/GTD") 1))

;; (unless (f-file-p (concat capture-directory "/GTD/tasks.org"))
;;   (dired-create-empty-file (concat capture-directory "/GTD/tasks.org")))

;; (unless (f-file-p (concat capture-directory "/GTD/someday.org"))
;;   (dired-create-empty-file (concat capture-directory "/GTD/someday.org")))

;; (unless (f-file-p (concat capture-directory "/GTD/projects.org"))
;;   (dired-create-empty-file (concat capture-directory "/GTD/projects.org")))

;; (unless (f-file-p (concat capture-directory "/GTD/delegated.org"))
;;   (dired-create-empty-file (concat capture-directory "/GTD/delegated.org")))

;; (unless (f-file-p (concat capture-directory "/GTD/trash.org"))
;;   (dired-create-empty-file (concat capture-directory "/GTD/trash.org")))

(setq org-refile-allow-creating-parent-nodes 'confirm)

(setq org-refile-targets `((,(concat capture-directory "/GTD/tasks.org") :maxlevel . 9)
                           (,(concat capture-directory "/GTD/someday.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/projects.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/delegated.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/trash.org") :maxlevel . 9)))

(provide 'org-config)
;;; org-config.el ends here

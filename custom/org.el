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

(setq org-refile-targets `((,(concat capture-directory "/GTD/tasks.org") :maxlevel . 9)
                           (,(concat capture-directory "/GTD/someday.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/projects.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/delegated.org") :maxlevel . 9)
			   (,(concat capture-directory "/GTD/trash.org") :maxlevel . 9)))

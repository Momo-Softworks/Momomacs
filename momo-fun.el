(add-hook 'elpaca-after-init-hook (lambda ()
				    (defun momo/new-project ()
				      "Create a new project using the supported facilities of Momomacs."
				      (interactive)
				      (let* ((options-and-functions
					      (list
					       (when (package-installed-p 'java-mode)
						 '("Java" . momo/new-java-project))
					       (when (package-installed-p 'racket-mode)
						 '("Racket" . momo/new-racket-project))))
					     (filtered-options-and-functions (seq-filter #'identity options-and-functions))
					     (options (mapcar #'car filtered-options-and-functions))
					     (project-type (completing-read "Project Type: " options))
					     (project-func (cdr (assoc project-type filtered-options-and-functions))))
					(when project-func
					  (funcall project-func))))

				    (defun momo/new-racket-project ()
				      (let* ((project-name (completing-read "Project Name:" '())))
					(mkdir (concat (car projects) "/" project-name))
					(make-empty-file (concat (car projects) "/" project-name "/main.scm"))))

				    (defun momo/new-java-project ()
				      (let* ((options-and-functions
					      (list
					       '("Gradle" . momo/new-java-gradle-project)
					       '("Minecraft" . momo/new-java-minecraft-project)))
					     (options (mapcar #'car options-and-functions))
					     (project-type (completing-read "Project Type:" options))
					     (project-func (cdr (assoc project-type options-and-functions))))
					(when project-func
					  (funcall project-func))))

				    (defun momo/new-java-gradle-project ()
				      (let* ((project-name (completing-read "Project Name:" '())))
					(mkdir (concat (car projects) "/" project-name))
					))

				    (defun momo/new-java-minecraft-project ()
				      (let* ((project-name (completing-read "Project Name:" '())))
					(mkdir (concat (car projects) "/" project-name))
					))

				    (defun momo/parse-desktop-file-for-name-and-exec (file-path)
				      "Parse a .desktop file and return the Name and Exec keys."
				      (with-temp-buffer
					(insert-file-contents file-path)
					(let ((name nil) (exec nil))
					  (goto-char (point-min))
					  (when (re-search-forward "^Name=\\(.*\\)$" nil t)
					    (setq name (match-string 1)))
					  (goto-char (point-min))
					  (when (re-search-forward "^Exec=\\(.*\\)$" nil t)
					    (setq exec (match-string 1)))
					  (when (and name exec)
					    (cons (capitalize name) exec)))))

				    (defun momo/list-desktop-applications ()
				      "List applications from .desktop files in $XDG_DATA_DIRS/applications, returning a list of cons cells (name . command)."
				      (let ((data-dirs (split-string (getenv "XDG_DATA_DIRS") ":"))
					    (applications '()))
					(dolist (dir data-dirs applications)
					  (let ((app-dir (concat dir "/applications")))
					    (when (file-exists-p app-dir)
					      (dolist (file (directory-files app-dir t "\\.desktop$"))
						(let ((app (momo/parse-desktop-file-for-name-and-exec file)))
						  (when app
						    (push app applications)))))))
					applications))


				    (defun momo/run-application ()
				      "Execute an application from .desktop files with completion without focusing on the output buffer."
				      (interactive)
				      (let* ((applications (momo/list-desktop-applications))
					     (names (mapcar 'car applications))
					     (selected-name (completing-read "Application: " names))
					     (command (cdr (assoc selected-name applications))))
					(when command
					  (let ((executable (car (split-string command))))
					    (start-process-shell-command executable nil executable)))))
				    ))

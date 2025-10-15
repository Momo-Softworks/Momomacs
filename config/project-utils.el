;;; project-utils.el --- Project creation utilities -*- lexical-binding: t; -*-

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

(provide 'project-utils)
;;; project-utils.el ends here

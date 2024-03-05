(defgroup momo nil
  "Momo parent group"
  :prefix "momo-"
  :group 'emacs)

(defcustom use-guix nil
  "Whether or not to use Guix as the primary project manager for Emacs"
  :type 'boolean
  :group 'momo)

(defcustom projects (list (concat (getenv "HOME") "/Projects"))
  "Location of your projects"
  :type 'list
  :group 'momo)

(defcustom roam-directory (concat (getenv "HOME") "/Documents/Roam")
  "Location of your org-roam"
  :type 'string
  :group 'momo)

(defcustom capture-directory (concat (getenv "HOME") "/Documents/Org")
  "Location of your org captures"
  :type 'string
  :group 'momo)

(setopt exwm-randr-workspace-monitor-plist '(1 "HDMI-A-4"
			    2 "HDMI-A-4"
			    3 "HDMI-A-4"
			    4 "HDMI-A-4"
			    5 "HDMI-A-4"
			    6 "DisplayPort-2"
			    7 "DisplayPort-2"
			    8 "DisplayPort-2"
			    9 "DisplayPort-2"
			    0 "DisplayPort-2"))

(defcustom xrandr-command "xrandr --output HDMI-A-4 --set TearFree on --left-of DisplayPort-2 --set TearFree on --auto"
  "Xrandr command for your setup"
  :type 'string
  :group 'momo)

(unless (file-directory-p capture-directory)
  (make-directory capture-directory 1))

(unless (file-directory-p roam-directory)
  (make-directory capture-directory 1))

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

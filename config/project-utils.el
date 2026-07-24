;;; project-utils.el --- Project creation utilities -*- lexical-binding: t; -*-

(defun momo/new-project ()
  "Create a new project using the supported facilities of Momomacs."
  (interactive)
  (let* ((options-and-functions
          (list
	   (when (package-installed-p 'java-mode)
	     '("Java" . momo/new-java-project))
           (when (package-installed-p 'racket-mode)
             '("Racket" . momo/new-racket-project))
           (when (executable-find (if (boundp 'packwiz-executable)
                                      packwiz-executable
                                    "packwiz"))
             '("Modpack (packwiz)" . momo/new-packwiz-project))))
         (filtered-options-and-functions (seq-filter #'identity options-and-functions))
         (options (mapcar #'car filtered-options-and-functions))
         (project-type (completing-read "Project Type: " options))
         (project-func (cdr (assoc project-type filtered-options-and-functions))))
    (when project-func
      (funcall project-func))))

(defun momo/new-racket-project ()
  (let* ((project-name (completing-read "Project Name:" '())))
    (mkdir (concat (car momo-projects) "/" project-name))
    (make-empty-file (concat (car momo-projects) "/" project-name "/main.scm"))))

(defun momo/new-packwiz-project ()
  "Create a new packwiz modpack project and initialise it natively."
  (let* ((project-name (read-string "Modpack Name: "))
         (dir (expand-file-name project-name (car momo-projects))))
    (make-directory dir t)
    (packwiz-init dir)))

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
    (mkdir (concat (car momo-projects) "/" project-name))
    ))

(defun momo/new-java-minecraft-project ()
  (let* ((project-name (completing-read "Project Name:" '())))
    (mkdir (concat (car momo-projects) "/" project-name))
    ))

;;; ---------------------------------------------------------------------------
;;; Project REPL convention
;;; ---------------------------------------------------------------------------
;; Any project can opt in by adding to .dir-locals.el:
;;
;;   ((nil . ((momo/repl-backend . geiser)
;;            (momo/geiser-repl-command . "make geiser-server")
;;            (momo/geiser-repl-socket  . "/tmp/my-project.sock"))))
;;
;; or, for Arei/Ares:
;;
;;   ((nil . ((momo/repl-backend . arei)
;;            (momo/arei-repl-command . "make ares-server")
;;            (momo/arei-repl-port-file . ".nrepl-port"))))
;;
;; `momo/repl-backend'       Either `geiser' or `arei' (defaults to `geiser').
;; `momo/*-repl-command'     Shell command that starts the backend server.
;; `momo/geiser-repl-socket' Unix socket path for Geiser to connect to.
;; `momo/arei-repl-port-file' nREPL port file written by guile-ares-rs.
;;
;; Backwards-compatible variables still work:
;; `momo/repl-command' and `momo/repl-socket' mean the Geiser command/socket.
;;
;; Then `M-x momo/project-repl-start' does everything.

(defvar momo/repl-backend nil
  "Project REPL backend selected by .dir-locals.el.")
(defvar momo/repl-command nil
  "Backward-compatible project REPL command.")
(defvar momo/repl-socket nil
  "Backward-compatible Geiser project REPL socket.")
(defvar momo/geiser-repl-command nil
  "Project command that starts a Geiser socket REPL.")
(defvar momo/geiser-repl-socket nil
  "Project Unix socket path for Geiser.")
(defvar momo/arei-repl-command nil
  "Project command that starts an Ares nREPL server.")
(defvar momo/arei-repl-port-file nil
  "Project .nrepl-port path for Arei/Ares auto-connect.")

(put 'momo/repl-backend 'safe-local-variable
     (lambda (value) (memq value '(geiser arei))))
(put 'momo/repl-command 'safe-local-variable #'stringp)
(put 'momo/repl-socket 'safe-local-variable #'stringp)
(put 'momo/geiser-repl-command 'safe-local-variable #'stringp)
(put 'momo/geiser-repl-socket 'safe-local-variable #'stringp)
(put 'momo/arei-repl-command 'safe-local-variable #'stringp)
(put 'momo/arei-repl-port-file 'safe-local-variable #'stringp)

(defun momo/project-repl--dir-local (symbol)
  "Return SYMBOL's value from `dir-local-variables-alist'."
  (alist-get symbol dir-local-variables-alist))

(defun momo/project-repl--await-geiser-connect (socket attempts)
  "Poll for SOCKET; call `geiser-connect-local' once it appears."
  (cond
   ((file-exists-p socket)
    (geiser-connect-local 'guile socket)
    (message "momo/project-repl: Geiser connected ✓"))
   ((> attempts 0)
    (run-with-timer 1 nil #'momo/project-repl--await-geiser-connect socket (1- attempts)))
   (t
    (message "momo/project-repl: timed out waiting for %s" socket))))

(defun momo/project-repl--await-arei-connect (port-file attempts)
  "Poll for PORT-FILE; call `sesman-start' for Arei once it appears."
  (cond
   ((or (not port-file) (file-exists-p port-file))
    (require 'arei)
    (unless (bound-and-true-p arei-mode)
      (arei-mode 1))
    (if (sesman-current-session 'Arei)
        (message "momo/project-repl: Arei already connected ✓")
      (sesman-start)
      (message "momo/project-repl: Arei connected ✓")))
   ((> attempts 0)
    (run-with-timer 1 nil #'momo/project-repl--await-arei-connect port-file (1- attempts)))
   (t
    (message "momo/project-repl: timed out waiting for %s" port-file))))

(defun momo/project-repl-start ()
  "Start this project's REPL server and connect the selected backend.
Reads project-local variables from `.dir-locals.el' via
`dir-local-variables-alist'."
  (interactive)
  (let* ((backend (or (momo/project-repl--dir-local 'momo/repl-backend) 'geiser))
         (cmd (pcase backend
                ('arei (or (momo/project-repl--dir-local 'momo/arei-repl-command)
                           (momo/project-repl--dir-local 'momo/repl-command)))
                ('geiser (or (momo/project-repl--dir-local 'momo/geiser-repl-command)
                             (momo/project-repl--dir-local 'momo/repl-command)))
                (_ (user-error "Unknown momo/repl-backend: %S" backend))))
         (geiser-socket (or (momo/project-repl--dir-local 'momo/geiser-repl-socket)
                            (momo/project-repl--dir-local 'momo/repl-socket)))
         (project-root (when-let ((project (project-current)))
                         (project-root project)))
         (arei-port-file-raw (or (momo/project-repl--dir-local 'momo/arei-repl-port-file)
                                 ".nrepl-port"))
         (arei-port-file (and arei-port-file-raw
                              (expand-file-name arei-port-file-raw
                                                (or project-root default-directory)))))
    (unless cmd
      (user-error "No project REPL command for backend %S -- add it to .dir-locals.el" backend))
    (pcase backend
      ('geiser (when geiser-socket (ignore-errors (delete-file geiser-socket))))
      ('arei (when arei-port-file (ignore-errors (delete-file arei-port-file)))))
    ;; Launch in the background: save-window-excursion prevents eat from
    ;; stealing the current window. Rename so `M-x eat' still opens fresh.
    (let ((buf (save-window-excursion (eat cmd))))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (rename-buffer "*momo/project-repl*" t))))
    (pcase backend
      ('geiser
       (if geiser-socket
           (progn
             (message "momo/project-repl: waiting for Geiser socket...")
             (run-with-timer 1 nil #'momo/project-repl--await-geiser-connect geiser-socket 20))
         (message "momo/project-repl: Geiser server started (no socket declared, skipping auto-connect)")))
      ('arei
       (message "momo/project-repl: waiting for Ares nREPL port...")
       (run-with-timer 1 nil #'momo/project-repl--await-arei-connect arei-port-file 20)))))

(provide 'project-utils)
;;; project-utils.el ends here

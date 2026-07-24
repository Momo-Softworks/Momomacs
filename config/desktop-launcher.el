;;; desktop-launcher.el --- Desktop application launcher utilities -*- lexical-binding: t; -*-

;;; Commentary:
;; Lightweight desktop application launcher for EXWM.
;; Respects common .desktop conventions so completion only shows entries that
;; are actually intended to be launched by the user.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defun momo/desktop-entry-value (key)
  "Return the value for KEY in the current buffer's Desktop Entry section."
  (goto-char (point-min))
  (when (re-search-forward
         (format "^%s=\\(.*\\)$" (regexp-quote key))
         nil t)
    (string-trim (match-string 1))))

(defun momo/desktop-entry-true-p (value)
  "Return non-nil when VALUE is a true-like desktop-entry boolean string."
  (and value (member (downcase value) '("true" "1"))))

(defun momo/desktop-entry-exec-program (command)
  "Extract the executable program name from desktop-entry COMMAND."
  (when (and command (not (string-empty-p command)))
    (let ((parts (split-string-and-unquote command))
          program)
      (while (and parts
                  (string-match-p "^[[:alpha:]_][[:alnum:]_]*=.*" (car parts)))
        (setq parts (cdr parts)))
      (setq program (car parts))
      (and program
           (not (member program '("sh" "bash" "env")))
           program))))

(defun momo/desktop-entry-clean-exec (command)
  "Normalize desktop-entry COMMAND for launching via shell.

Removes field codes such as %U, Flatpak file-forwarding groups such as
@@u %U @@, orphaned --file-forwarding flags, and trims surrounding whitespace."
  (when command
    (let* ((without-flatpak-forwarding
            (replace-regexp-in-string
             "[[:space:]]+@@[[:alpha:]]?[[:space:]][^@]*[[:space:]]@@"
             "" command))
           (without-orphaned-flatpak-flag
            (replace-regexp-in-string
             "[[:space:]]+--file-forwarding\\>"
             "" without-flatpak-forwarding))
           (without-field-codes
            (replace-regexp-in-string
             "%[fFuUdDnNickvm]" "" without-orphaned-flatpak-flag)))
      (string-trim without-field-codes))))

(defun momo/desktop-entry-visible-p ()
  "Return non-nil if the current desktop entry should be shown in launchers."
  (and (string= (or (momo/desktop-entry-value "Type") "Application") "Application")
       (not (momo/desktop-entry-true-p (momo/desktop-entry-value "Hidden")))
       (not (momo/desktop-entry-true-p (momo/desktop-entry-value "NoDisplay")))
       (not (momo/desktop-entry-true-p (momo/desktop-entry-value "Terminal")))))

(defun momo/parse-desktop-file-for-name-and-exec (file-path)
  "Return (NAME . EXEC) for a valid launcher at FILE-PATH, or nil.

Entries marked Hidden, NoDisplay, Terminal, or not of Type=Application are
ignored.  Entries with a TryExec/Exec program missing from PATH are skipped."
  (with-temp-buffer
    (insert-file-contents file-path)
    (when (momo/desktop-entry-visible-p)
      (let* ((name (or (momo/desktop-entry-value "Name")
                       (momo/desktop-entry-value "Name[en_US]")
                       (momo/desktop-entry-value "Name[en]")))
             (exec (momo/desktop-entry-clean-exec
                    (momo/desktop-entry-value "Exec")))
             (try-exec (momo/desktop-entry-value "TryExec"))
             (program (or try-exec (momo/desktop-entry-exec-program exec))))
        (when (and (not (string-empty-p (or name "")))
                   (not (string-empty-p (or exec "")))
                   (or (null program)
                       (file-name-absolute-p program)
                       (executable-find program)))
          (cons name exec))))))

(defun momo/desktop-application-directories ()
  "Return application directories in XDG precedence order."
  (let* ((data-home (or (getenv "XDG_DATA_HOME")
                        (expand-file-name "~/.local/share")))
         (data-dirs (split-string
                     (or (getenv "XDG_DATA_DIRS")
                         "/usr/local/share:/usr/share")
                     ":" t)))
    (mapcar (lambda (dir)
              (expand-file-name "applications" dir))
            (cons data-home data-dirs))))

(defun momo/list-desktop-applications ()
  "Return launchable desktop applications as (NAME . COMMAND) pairs.

Results are de-duplicated by display name and sorted alphabetically.
Directories earlier in XDG precedence win." 
  (let ((applications (make-hash-table :test #'equal)))
    (dolist (app-dir (momo/desktop-application-directories))
      (when (file-directory-p app-dir)
        (dolist (file (directory-files app-dir t "\\.desktop$") )
          (let ((app (momo/parse-desktop-file-for-name-and-exec file)))
            (when (and app (not (gethash (car app) applications)))
              (puthash (car app) (cdr app) applications))))))
    (sort (cl-loop for name being the hash-keys of applications using (hash-values command)
                   collect (cons name command))
          (lambda (left right)
            (string-lessp (downcase (car left))
                          (downcase (car right)))))))

(defun momo/run-application ()
  "Prompt for and launch a desktop application."
  (interactive)
  (let* ((applications (momo/list-desktop-applications))
         (names (mapcar #'car applications))
         (selected-name (completing-read "Application: " names nil t))
         (command (cdr (assoc selected-name applications))))
    (when command
      (start-process-shell-command command nil command))))

(provide 'desktop-launcher)
;;; desktop-launcher.el ends here

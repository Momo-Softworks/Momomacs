;;; desktop-launcher.el --- Desktop application launcher utilities -*- lexical-binding: t; -*-

(defun momo/parse-desktop-file-for-name-and-exec (file-path)
  "Parse a .desktop file and return the Name and Exec keys, removing placeholders."
  (with-temp-buffer
    (insert-file-contents file-path)
    (let ((name nil) (exec nil))
      (goto-char (point-min))
      (when (re-search-forward "^Name=\\(.*\\)$" nil t)
        (setq name (match-string 1)))
      (goto-char (point-min))
      (when (re-search-forward "^Exec=\\(.*\\)$" nil t)
        (setq exec (match-string 1))
        ;; Remove placeholders like %U, %u, %F, %f, etc.
        (setq exec (replace-regexp-in-string "%[UuFfDdNnIiMm]" "" exec))
        ;; Also strip trailing spaces that may be left after removing placeholders
        (setq exec (replace-regexp-in-string " +$" "" exec)))
      (when (and name exec)
        (cons (capitalize name) exec)))))

(defun momo/list-desktop-applications ()
  "List applications from .desktop files in $XDG_DATA_DIRS/applications, returning a list of cons cells (name . command)."
  (let ((data-dirs (split-string (or (getenv "XDG_DATA_DIRS") "/usr/local/share:/usr/share") ":"))
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
      ;; Execute the full command for Flatpak-based applications
      (start-process-shell-command command nil command))))

(provide 'desktop-launcher)
;;; desktop-launcher.el ends here

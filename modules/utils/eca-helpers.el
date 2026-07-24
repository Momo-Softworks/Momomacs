;;; eca-helpers.el --- AI-friendly Emacs helpers for ECA -*- lexical-binding: t; -*-

;;; Commentary:
;; One-liner helpers designed for AI consumption via `eca__eval-elisp`.
;; Every function returns a flat string, handles errors gracefully,
;; and never prompts interactively.
;;
;; Naming: momo/ec-<category>-<action>
;;   ec-buf-*   = buffers & files
;;   ec-org-*   = org-mode
;;   ec-roam-*  = org-roam
;;   ec-diag-*  = diagnostics
;;   ec-info-*  = system/state
;;   ec-git-*   = git
;;   ec-img-*   = screenshots

;;; Code:

(require 'cl-lib)

;; ── Internal helpers ─────────────────────────────────────────────────────────

(defun momo/ec--fmt (pairs)
  "Format an alist of PAIRS as \"key: value\\n\" lines."
  (mapconcat (lambda (pair)
               (format "%s: %s" (car pair) (cdr pair)))
             pairs "\n"))

(defun momo/ec--safe (thunk)
  "Call THUNK; return its string result or an error string."
  (condition-case err
      (funcall thunk)
    (error (format "ERROR: %s" (error-message-string err)))))

(defun momo/ec-eval-string-background (code)
  "Evaluate Elisp CODE in a UI-quiet context and return its result.

This is intended for ECA's `eval-elisp' custom tool.  It keeps ad-hoc
assistant evaluation from stealing focus, leaving random buffers selected, or
flooding `*Messages*' when evaluated forms call `message'."
  (let ((result nil))
    (momo/ec--safe
     (lambda ()
       (let ((inhibit-message t)
             (message-log-max nil)
             (display-buffer-alist
              (cons '("\\`\\*Messages\\*\\'" . (display-buffer-no-window))
                    display-buffer-alist))
             (pop-up-frames nil)
             (pop-up-windows nil))
         (save-window-excursion
           (save-current-buffer
             (setq result (eval (read code) lexical-binding)))))
       (if (stringp result)
           result
         (prin1-to-string result))))))

(defun momo/ec-eval-file-background (file)
  "Evaluate the first Elisp form from FILE using `momo/ec-eval-string-background'."
  (momo/ec-eval-string-background
   (with-temp-buffer
     (insert-file-contents file)
     (buffer-string))))

;; ── Buffers & Files ──────────────────────────────────────────────────────────

(defun momo/ec-buf-list ()
  "Return open buffers with their file names and modes, one per line.
Format: \"buffer-name | file-path | major-mode\""
  (momo/ec--safe
   (lambda ()
     (mapconcat
      (lambda (buf)
        (with-current-buffer buf
          (format "%s | %s | %s"
                  (buffer-name buf)
                  (or (buffer-file-name buf) "(no file)")
                  major-mode)))
      (seq-filter (lambda (b) (not (string-prefix-p " " (buffer-name b))))
                  (buffer-list))
      "\n"))))

(defun momo/ec-buf-current ()
  "Return info about the buffer the user is currently looking at.
Format: buffer-name | file-path | major-mode | line:col | point-pos"
  (momo/ec--safe
   (lambda ()
     (let ((buf (current-buffer)))
       (format "%s | %s | %s | line %d col %d | point %d"
               (buffer-name buf)
               (or (buffer-file-name buf) "(no file)")
               major-mode
               (line-number-at-pos)
               (current-column)
               (point))))))

(defun momo/ec-buf-contents (&optional buffer-or-file)
  "Return the contents of BUFFER-OR-FILE as a string.
BUFFER-OR-FILE can be a buffer name or file path.  Defaults to current buffer."
  (momo/ec--safe
   (lambda ()
     (let ((buf (cond ((null buffer-or-file) (current-buffer))
                      ((get-buffer buffer-or-file))
                      ((file-exists-p buffer-or-file)
                       (find-file-noselect buffer-or-file))
                      (t (error "No such buffer or file: %s" buffer-or-file)))))
       (with-current-buffer buf
         (buffer-substring-no-properties (point-min) (point-max)))))))

(defun momo/ec-buf-find-file (file-path)
  "Open FILE-PATH in Emacs and return the buffer name."
  (momo/ec--safe
   (lambda ()
     (let ((buf (find-file-noselect file-path)))
       (format "Opened: %s" (buffer-name buf))))))

(defun momo/ec-buf-show (buffer-or-file)
  "Switch Emacs display to BUFFER-OR-FILE so the user sees it.
BUFFER-OR-FILE can be a buffer name or file path."
  (momo/ec--safe
   (lambda ()
     (let ((buf (or (get-buffer buffer-or-file)
                    (find-file-noselect buffer-or-file))))
       (switch-to-buffer buf)
       (format "Showing: %s (%s)"
               (buffer-name buf)
               (or (buffer-file-name buf) "no file"))))))

(defun momo/ec-buf-goto (buffer-or-file line)
  "Open BUFFER-OR-FILE and move cursor to LINE (1-based), showing it to the user."
  (momo/ec--safe
   (lambda ()
     (let* ((lineno (if (stringp line) (string-to-number line) line))
            (buf (or (get-buffer buffer-or-file)
                     (find-file-noselect buffer-or-file))))
       (switch-to-buffer buf)
       (forward-line (1- lineno))
       (recenter)
       (format "At %s:%s" (buffer-name buf) lineno)))))

(defun momo/ec-buf-insert (text)
  "Insert TEXT at point in the current buffer (user-visible)."
  (momo/ec--safe
   (lambda ()
     (insert text)
     (format "Inserted %d chars" (length text)))))

(defun momo/ec-buf-save ()
  "Save the current buffer to disk. Returns file path or error."
  (momo/ec--safe
   (lambda ()
     (if (buffer-file-name)
         (progn (save-buffer)
                (format "Saved: %s" (buffer-file-name)))
       (error "Buffer has no file")))))

(defun momo/ec-buf-replace-region (start-line start-col end-line end-col new-text)
  "Replace text between START-LINE:START-COL and END-LINE:END-COL with NEW-TEXT."
  (momo/ec--safe
   (lambda ()
     (save-excursion
       (goto-char (point-min))
       (forward-line (1- start-line))
       (forward-char start-col)
       (let ((beg (point)))
         (goto-char (point-min))
         (forward-line (1- end-line))
         (forward-char end-col)
         (delete-region beg (point))
         (goto-char beg)
         (insert new-text))
       (format "Replaced region with %d chars" (length new-text))))))

(defun momo/ec-buf-select (start-line start-col end-line end-col)
  "Select/highlight the region from START-LINE:START-COL to END-LINE:END-COL."
  (momo/ec--safe
   (lambda ()
     (goto-char (point-min))
     (forward-line (1- start-line))
     (forward-char start-col)
     (push-mark (point) t nil)
     (goto-char (point-min))
     (forward-line (1- end-line))
     (forward-char end-col)
     (format "Selected from %s:%s to %s:%s" start-line start-col end-line end-col))))

;; ── Org-mode ─────────────────────────────────────────────────────────────────

(defun momo/ec-org-agenda (&optional days)
  "Return the org agenda for the next DAYS (default 7), one heading per line."
  (momo/ec--safe
   (lambda ()
     (require 'org)
     (let* ((ndays (or days 7))
            (cutoff (time-add (current-time) (days-to-time ndays)))
            (entries '()))
       (dolist (file (org-agenda-files))
         (with-current-buffer (find-file-noselect file)
           (org-check-agenda-file file)
           (org-map-entries
            (lambda ()
              (let ((scheduled (org-entry-get (point) "SCHEDULED"))
                    (deadline (org-entry-get (point) "DEADLINE"))
                    (sched-time (ignore-errors
                                  (org-time-string-to-time scheduled)))
                    (dead-time (ignore-errors
                                 (org-time-string-to-time deadline))))
                (when (or (and sched-time (time-less-p sched-time cutoff))
                          (and dead-time (time-less-p dead-time cutoff))
                          (and (not sched-time) (not dead-time)
                               (equal (org-entry-get (point) "TODO") "TODO")))
                  (push (format "%s | %s | TODO:%s | sched:%s | dead:%s"
                                (buffer-file-name)
                                (org-get-heading t t t t)
                                (or (org-entry-get (point) "TODO") "")
                                (or scheduled "")
                                (or deadline ""))
                        entries))))
            nil 'agenda)))
       (if entries
           (mapconcat #'identity (nreverse entries) "\n")
         "(no agenda entries found)")))))

(defun momo/ec-org-todo-list ()
  "Return all TODO items across agenda files with their state."
  (momo/ec--safe
   (lambda ()
     (require 'org)
     (let ((items '()))
       (dolist (file (org-agenda-files))
         (with-current-buffer (find-file-noselect file)
           (org-map-entries
            (lambda ()
              (push (format "%s | %s | %s | %s"
                            (or (org-entry-get (point) "TODO") "")
                            (org-get-heading t t t t)
                            (buffer-file-name)
                            (or (org-entry-get (point) "PRIORITY") ""))
                    items))
            "TODO<>\"\"|TODO=\"TODO\"" 'agenda)))
       (if items
           (mapconcat #'identity (nreverse items) "\n")
         "(no TODO items found)")))))

(defun momo/ec-org-capture (template-key &optional title)
  "Create an org-capture entry using TEMPLATE-KEY.
Known keys: t=Todo, j=Journal, i=Idea, T=Tickler."
  (momo/ec--safe
   (lambda ()
     (require 'org-capture)
     (unless (assoc template-key org-capture-templates)
       (error "Unknown capture key: %s" template-key))
     (org-capture nil template-key)
     (when title (insert title))
     (format "Capture started with key '%s'%s"
             template-key
             (if title (format " title: \"%s\"" title) "")))))

(defun momo/ec-org-search (query)
  "Search org headings with QUERY (org match syntax) and return matches.
Examples: \"+work-TODO\" \"+computer|+phone\" \"LEVEL=2\""
  (momo/ec--safe
   (lambda ()
     (require 'org)
     (let ((results '()))
       (org-map-entries
        (lambda ()
          (push (format "%s | %s | %s"
                        (org-get-heading t t t t)
                        (buffer-file-name)
                        (or (org-entry-get (point) "TODO") ""))
                results))
        query 'agenda)
       (if results
           (mapconcat #'identity (nreverse results) "\n")
         "(no matches)")))))

(defun momo/ec-org-heading-at-point ()
  "Return properties of the heading at point."
  (momo/ec--safe
   (lambda ()
     (if (derived-mode-p 'org-mode)
         (momo/ec--fmt
          `(("heading" . ,(or (org-get-heading t t t t) "(none)"))
            ("todo" . ,(or (org-entry-get (point) "TODO") ""))
            ("priority" . ,(or (org-entry-get (point) "PRIORITY") ""))
            ("tags" . ,(or (org-entry-get (point) "TAGS") ""))
            ("scheduled" . ,(or (org-entry-get (point) "SCHEDULED") ""))
            ("deadline" . ,(or (org-entry-get (point) "DEADLINE") ""))
            ("file" . ,(or (buffer-file-name) ""))))
       "(not in org-mode)"))))

(defun momo/ec-org-files ()
  "Return a list of all known org files (agenda + open buffers)."
  (momo/ec--safe
   (lambda ()
     (let ((files (delete-dups
                   (append (org-agenda-files)
                           (seq-mapcat
                            (lambda (buf)
                              (with-current-buffer buf
                                (when (and (derived-mode-p 'org-mode)
                                           (buffer-file-name))
                                  (list (buffer-file-name)))))
                            (buffer-list))))))
       (if files
           (mapconcat #'identity files "\n")
         "(no org files found)")))))

(defun momo/ec-org-schedule (date)
  "Schedule the org heading at point for DATE (YYYY-MM-DD)."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-schedule nil date)
     (format "Scheduled '%s' for %s" (org-get-heading t t t t) date))))

(defun momo/ec-org-deadline (date)
  "Set a deadline of DATE on the org heading at point."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-deadline nil date)
     (format "Deadline set for '%s': %s" (org-get-heading t t t t) date))))

(defun momo/ec-org-clock-in ()
  "Clock in on the org heading at point."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-clock-in)
     (format "Clocking in: %s" (org-get-heading t t t t)))))

(defun momo/ec-org-clock-out ()
  "Clock out of the currently clocked task."
  (momo/ec--safe
   (lambda ()
     (org-clock-out)
     "Clocked out")))

(defun momo/ec-org-tag (tag)
  "Add TAG to the org heading at point."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-set-tags (cl-union (org-get-tags nil t) (list tag) :test #'string=))
     (format "Added tag '%s' to '%s'" tag (org-get-heading t t t t)))))

(defun momo/ec-org-priority (priority)
  "Set PRIORITY (A, B, or C) on the org heading at point."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-priority priority)
     (format "Set priority %s on '%s'" priority (org-get-heading t t t t)))))

(defun momo/ec-org-new-heading (title &optional level)
  "Add a new org heading with TITLE after the current heading."
  (momo/ec--safe
   (lambda ()
     (unless (derived-mode-p 'org-mode)
       (error "Not in org-mode"))
     (org-insert-heading-respect-content)
     (insert title)
     (when level
       (org-do-promote (- (org-outline-level) level)))
     (format "Added heading: %s" title))))

;; ── Org-roam ─────────────────────────────────────────────────────────────────

(defun momo/ec-roam-nodes (&optional tag)
  "Return org-roam nodes, optionally filtered by TAG.  One node per line."
  (momo/ec--safe
   (lambda ()
     (unless (featurep 'org-roam)
       (error "org-roam is not loaded"))
     (let ((nodes (if tag
                      (org-roam-db-query
                       [:select [node:title file:file]
                        :from tags
                        :left-join nodes
                        :on (= tags:node-id nodes:id)
                        :where (= tags:tag $s1)]
                       tag)
                    (org-roam-db-query
                     [:select [title file] :from nodes]))))
       (if nodes
           (mapconcat (lambda (row)
                        (format "%s | %s" (car row) (cadr row)))
                      nodes "\n")
         "(no nodes found)")))))

(defun momo/ec-roam-find (title)
  "Find an org-roam node by TITLE and return its contents."
  (momo/ec--safe
   (lambda ()
     (unless (featurep 'org-roam)
       (error "org-roam is not loaded"))
     (let ((node (org-roam-node-from-title-or-alias title)))
       (unless node
         (error "No node found with title: %s" title))
       (let ((file (org-roam-node-file node)))
         (with-current-buffer (find-file-noselect file)
           (format "Node: %s\nFile: %s\n\n%s"
                   (org-roam-node-title node)
                   file
                   (buffer-substring-no-properties (point-min) (point-max)))))))))

;; ── Diagnostics ──────────────────────────────────────────────────────────────

(defun momo/ec-diag-current ()
  "Return diagnostics for the current buffer only."
  (momo/ec--safe
   (lambda ()
     (if (bound-and-true-p flycheck-mode)
         (if flycheck-current-errors
             (mapconcat
              (lambda (e)
                (format "%s:%s: %s [%s]"
                        (or (flycheck-error-line e) "?")
                        (or (flycheck-error-column e) "?")
                        (flycheck-error-message e)
                        (symbol-name (flycheck-error-level e))))
              flycheck-current-errors "\n")
           "(flycheck: no errors)")
       "(flycheck not active)"))))

;; ── System / Info ────────────────────────────────────────────────────────────

(defun momo/ec-info-emacs ()
  "Return Emacs version, key packages, and server status."
  (momo/ec--safe
   (lambda ()
     (momo/ec--fmt
      `(("emacs-version" . ,emacs-version)
        ("server-running" . ,(if (server-running-p) "yes" "no"))
        ("flycheck-version" . ,(if (featurep 'flycheck) flycheck-version "not loaded"))
        ("org-version" . ,(if (featurep 'org) (org-version) "not loaded"))
        ("org-roam" . ,(if (featurep 'org-roam) "loaded" "not loaded"))
        ("jinx" . ,(if (featurep 'jinx) "loaded" "not loaded"))
        ("exwm" . ,(if (getenv "EXWM_LAUNCH") "active (WM session)" "inactive"))
        ("project-root" . ,(or (when-let ((proj (project-current)))
                                 (project-root proj))
                               "(not in a project)")))))))

(defun momo/ec-info-project ()
  "Return info about the current project."
  (momo/ec--safe
   (lambda ()
     (if-let ((proj (project-current)))
         (let ((root (project-root proj))
               (files (project-files proj)))
           (format "root: %s\nfiles: %d\n\n%s"
                   root
                   (length files)
                   (mapconcat #'identity
                              (seq-take (sort (mapcar #'file-relative-name
                                                       (seq-filter
                                                        (lambda (f) (not (string-match "/\\." f)))
                                                        files))
                                              #'string<)
                                        200)
                              "\n")))
       "(not in a project)"))))

;; ── Git ──────────────────────────────────────────────────────────────────────

(defun momo/ec-git-status ()
  "Return a brief git status for the current project."
  (momo/ec--safe
   (lambda ()
     (let ((default-directory (or (when-let ((proj (project-current)))
                                    (project-root proj))
                                  default-directory)))
       (with-temp-buffer
         (if (zerop (call-process "git" nil t nil "status" "--short"))
             (let ((lines (split-string (buffer-string) "\n" t)))
               (if lines
                   (mapconcat #'identity lines "\n")
                 "(clean working tree)"))
           "(not a git repository)"))))))

(defun momo/ec-grep (pattern &optional dir)
  "Search for PATTERN (regex) in DIR (default: project root), return file:line."
  (momo/ec--safe
   (lambda ()
     (let ((default-directory (or dir
                                  (when-let ((proj (project-current)))
                                    (project-root proj))
                                  default-directory)))
       (with-temp-buffer
         (if (zerop (call-process "grep" nil t nil
                                  "-rn" "--include=*" "-e" pattern "."))
             (let ((lines (split-string (buffer-string) "\n" t)))
               (if lines
                   (mapconcat #'identity (seq-take lines 50) "\n")
                 "(no matches)"))
           "(grep failed)"))))))

(defun momo/ec-recentf ()
  "Return the 30 most recently opened files, one per line."
  (momo/ec--safe
   (lambda ()
     (if (bound-and-true-p recentf-list)
         (mapconcat #'identity (seq-take recentf-list 30) "\n")
       "(recentf not active)"))))

;; ── ECA Models ───────────────────────────────────────────────────────────────

(defun momo/ec-models ()
  "Return all available ECA models grouped by provider.
Flags [vision] based on model capabilities."
  (momo/ec--safe
   (lambda ()
     (require 'eca)
     (let* ((session (eca-session))
            (providers (eca--session-providers session))
            (out '()))
       (unless providers
         (error "No provider data cached — open ECA settings first"))
       (dolist (p providers)
         (let ((pid (plist-get p :id))
               (models (append (plist-get p :models) nil))
               (configured (plist-get p :configured)))
           (when models
             (push (format "\n[%s] %s" (if configured "✓" "✗") pid) out)
             (dolist (m models)
               (let* ((mid (plist-get m :id))
                      (caps (plist-get m :capabilities))
                      (vis (plist-get caps :vision)))
                 (push (format "  - %s%s" mid (if vis " [vision]" "")) out))))))
       (if out
           (mapconcat #'identity (nreverse out) "\n")
         "(no models found)")))))

;; ── Screenshot ───────────────────────────────────────────────────────────────

(defun momo/ec-screenshot (&optional type)
  "Capture the current Emacs frame as an image file.
TYPE is 'png (default), 'svg, 'pdf, or 'postscript.
Returns the file path to the captured image."
  (momo/ec--safe
   (lambda ()
     (let* ((fmt (or type 'png))
            (data (x-export-frames nil fmt))
            (ext (symbol-name fmt))
            (tmpfile (make-temp-file "emacs-screenshot-" nil (concat "." ext))))
       (with-temp-buffer
         (insert data)
         (write-region (point-min) (point-max) tmpfile))
       (format "Screenshot: %s (%d bytes)"
               tmpfile
               (file-attribute-size (file-attributes tmpfile)))))))

(defun momo/ec-screenshot-base64 ()
  "Capture the current Emacs frame as a base64 data URI.
Suitable for multimodal models: data:image/png;base64,..."
  (momo/ec--safe
   (lambda ()
     (let ((data (x-export-frames nil 'png)))
       (concat "data:image/png;base64,"
               (base64-encode-string data t))))))

(provide 'eca-helpers)
;;; eca-helpers.el ends here
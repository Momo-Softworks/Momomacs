;;; -*- lexical-binding: t; -*-
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
;; MELPA renamed its default branch from "master" to "main", but Elpaca's
;; MELPA menu still clones "master", so a fresh install fails with
;; "couldn't find remote ref master".  Clone "main" instead, and throw away a
;; half-made clone (a .git with no recipes/) left by an earlier failed run.
(defconst momo/melpa-branch "main")
(let ((melpa (expand-file-name "cache/melpa/" elpaca-directory)))
  (when (and (file-directory-p melpa)
             (not (file-directory-p (expand-file-name "recipes/" melpa))))
    (delete-directory melpa 'recursive)))
(with-eval-after-load 'elpaca-menu-melpa
  (defun elpaca-menu-melpa--clone (path)
    "Clone MELPA recipes repo to PATH, using `momo/melpa-branch'."
    (let ((default-directory path))
      (make-directory path t)
      (make-directory (expand-file-name ".git/info/" path) t)
      (message "Downloading MELPA recipes...")
      (let* ((process-environment (append (list (concat "GIT_CONFIG_SYSTEM=" null-device)
                                                (concat "GIT_CONFIG_GLOBAL=" null-device))
                                          process-environment))
             (branch momo/melpa-branch)
             (processes
              (list
               (elpaca-process-call "git" "init")
               (elpaca-process-call "git" "config" "core.sparseCheckout" "true")
               (with-temp-buffer
                 (insert "recipes")
                 (append-to-file (point-min) (point-max)
                                 (expand-file-name ".git/info/sparse-checkout" path)))
               (elpaca-process-call "git" "remote" "add" "origin" "https://github.com/melpa/melpa.git")
               (elpaca-process-call "git" "fetch" "--depth=1" "origin" branch)
               (elpaca-process-call "git" "checkout" "-B" branch (concat "origin/" branch))
               (elpaca-process-call "git" "branch" "--set-upstream-to" (concat "origin/" branch) branch)))
             (err (car (cl-remove-if #'zerop (delq nil processes) :key #'car))))
        (when err (error "Unable to clone MELPA: %S" err))
        (message "Downloading MELPA recipes...100%%")))))

(add-hook 'after-init-hook #'elpaca-process-queues)

;; Windows can't make symlinks without admin rights or Developer Mode, and
;; Elpaca builds packages by symlinking them, so copy files there instead.
(when (eq system-type 'windows-nt)
  (elpaca-no-symlink-mode))

;; Only open the *elpaca-log* window at startup when something really needs
;; building.  Elpaca's own check trusts a "built" flag that `elpaca-wait'
;; clears, so with our several waits the log opened on every start; Elpaca
;; then redraws it after each of its ~500 startup events, which cost ~4 s.
(defun momo/elpaca-log-initial-queues ()
  "Like `elpaca-log-initial-queues', but check the build dirs on disk."
  (unless elpaca-after-init-time
    (cl-loop for (_ . e) in (elpaca--queued)
             for dir = (elpaca<-build-dir e)
             for query = (cond ((eq (elpaca<-status e) 'failed) "#unique | failed")
                               ((not (and dir (file-exists-p dir))) "#unique | !finished"))
             when query return query)))
(with-eval-after-load 'elpaca
  (setq elpaca-log-functions
        (cons #'momo/elpaca-log-initial-queues
              (remq 'elpaca-log-initial-queues elpaca-log-functions))))

(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(elpaca-wait)

;; Fix for f package - explicitly specify files to include
(elpaca '(f :files (:defaults "f.el")))

;; Install transient explicitly so newer version shadows built-in (required by magit >= 4.x)
(elpaca 'transient)

(elpaca-wait)

;; Fix for shrink-path package
(elpaca 'shrink-path)

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
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
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(elpaca-wait)

(unless momo-use-guix
  (defun +elpaca-unload-seq (e) "Unload seq before continuing the elpaca build, then continue to build the recipe E."
	 (and (featurep 'seq) (unload-feature 'seq t))
	 (elpaca--continue-build e))
  (elpaca `(seq :build ,(append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
                                             elpaca--pre-built-steps
                                           elpaca-build-steps))
			(list '+elpaca-unload-seq 'elpaca--activate-package))))

  (elpaca-wait)

  ;; Unload jsonrpc to avoid conflicts with built-in version
  (defun +elpaca-unload-jsonrpc (e)
    "Unload jsonrpc before continuing the elpaca build, then continue to build the recipe E."
    (and (featurep 'jsonrpc) (unload-feature 'jsonrpc t))
    (elpaca--continue-build e))
  (elpaca `(jsonrpc :build ,(append (butlast (if (file-exists-p (expand-file-name "jsonrpc" elpaca-builds-directory))
															 elpaca--pre-built-steps
															 elpaca-build-steps))
																					(list '+elpaca-unload-jsonrpc 'elpaca--activate-package))))

    (elpaca-wait)

  ;; Unload transient to avoid conflicts with built-in version
  (defun +elpaca-unload-transient (e)
    "Unload jsonrpc before continuing the elpaca build, then continue to build the recipe E."
    (and (featurep 'transient) (unload-feature 'transient t))
    (elpaca--continue-build e))
  (elpaca `(transient :build ,(append (butlast (if (file-exists-p (expand-file-name "transient" elpaca-builds-directory))
															 elpaca--pre-built-steps
															 elpaca-build-steps))
																					(list '+elpaca-unload-transient 'elpaca--activate-package)))))

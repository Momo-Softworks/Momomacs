;;; eca.el --- ECA AI assistant configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for ECA (Editor Code Assistant) with custom binary path.

;;; Code:

(defun momo/eca-find-root-for-buffer ()
  "Return ECA root for current buffer, always as an absolute path.

This wraps ECA's default root detection so session workspace folders never
retain an abbreviated `~/` form, which avoids mismatches when ECA later
compares workspace roots against absolute file names."
  (expand-file-name (eca-find-root-for-buffer)))

(defun momo/eca--flymake-diagnostics-guard (orig-fn uri workspace)
  "Call ORIG-FN for URI and WORKSPACE only when WORKSPACE is a project root.

ECA's flymake integration assumes every workspace can be resolved by Emacs'
project API, but that is not true for non-project buffers such as `~/`.  In
that case `flymake--project-diagnostics` eventually calls `project-root` with a
nil project object and errors.  Skipping flymake's project-wide scan for such
workspaces avoids the crash while preserving diagnostics for real projects."
  (if (and (fboundp 'project-current)
           (let ((default-directory (file-name-as-directory
                                     (expand-file-name workspace))))
             (project-current nil)))
      (funcall orig-fn uri workspace)
    nil))

(use-package eca
  :defer t
  :commands (eca-mode eca-start)
  :custom
  ;; Use the already-installed eca binary directly, skipping version check for faster startup
  (eca-custom-command (list (expand-file-name "eca/eca" user-emacs-directory) "server"))
  (eca-find-root-for-buffer-function #'momo/eca-find-root-for-buffer)
  (eca-chat-focus-on-open nil)
  :init
  ;; Optional: Set up any keybindings to trigger ECA on-demand
  (global-set-key (kbd "C-c e") #'eca)
  :config
  (with-eval-after-load 'eca-editor
    (advice-add 'eca-editor--flymake-diagnostics :around
                #'momo/eca--flymake-diagnostics-guard)))

(provide 'eca)
;;; eca.el ends here

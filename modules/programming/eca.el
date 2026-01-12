;;; eca.el --- ECA AI assistant configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for ECA (Editor Code Assistant) with custom binary path.

;;; Code:

(use-package eca
  :defer t
  :commands (eca-mode eca-start)
  :custom
  ;; Use the already-installed eca binary directly, skipping version check for faster startup
  (eca-custom-command (list (expand-file-name "~/.config/emacs/eca/eca") "server"))
  :init
  ;; Optional: Set up any keybindings to trigger ECA on-demand
  (global-set-key (kbd "C-c e") #'eca))

(provide 'eca)
;;; eca.el ends here

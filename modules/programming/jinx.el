;;; jinx.el --- Jinx spell-checking configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Jinx is an async spell-checker backed by Enchant.
;; It highlights misspelled words lazily without blocking Emacs.

;;; Code:

(use-package jinx
  :demand t
  :config
  ;; English is the default; add more codes for multilingual documents.
;;  (setq jinx-languages '("en_US"))

  ;; Ignore generated ECA context tokens and prompt UI while preserving
  ;; spell checking in user-authored chat messages.
  (add-to-list 'jinx-exclude-faces
               '(eca-chat-mode
                 eca-chat-context-cursor-face
                 eca-chat-context-file-face
                 eca-chat-context-buffer-face
                 eca-chat-context-repo-map-face
                 eca-chat-context-mcp-resource-face
                 eca-chat-context-unlinked-face
                 eca-chat-prompt-prefix-face
                 eca-chat-prompt-stop-face
                 eca-chat-system-messages-face))

  ;; Enable globally — jinx activates in text/org/prog-mode buffers
  ;; automatically via global-jinx-mode.
  (global-jinx-mode 1))

(provide 'jinx)
;;; jinx.el ends here

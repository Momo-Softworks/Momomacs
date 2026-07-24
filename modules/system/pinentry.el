;;; pinentry.el --- Emacs pinentry integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Route GnuPG pinentry prompts into Emacs when gpg-agent allows it.

;;; Code:

(use-package pinentry
  :config
  (pinentry-start))

(provide 'pinentry)
;;; pinentry.el ends here

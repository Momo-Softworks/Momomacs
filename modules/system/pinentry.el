;;; pinentry.el --- Emacs pinentry integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Route GnuPG pinentry prompts into Emacs when gpg-agent allows it.

;;; Code:

;; pinentry talks to gpg-agent over a Unix socket, which Emacs on Windows
;; can't open, so skip it where local sockets aren't supported.
(use-package pinentry
  :if (featurep 'make-network-process '(:family local))
  :config
  (pinentry-start))

(provide 'momo-pinentry)
;;; pinentry.el ends here

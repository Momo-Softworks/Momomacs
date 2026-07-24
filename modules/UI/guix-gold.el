;;; guix-gold.el --- Guix Gold theme registration -*- lexical-binding: t; -*-

;;; Commentary:
;; Registers the bundled Guix Gold theme on `custom-theme-load-path'.
;; Guix Gold is a warm gold-and-ember theme tuned for Scheme / Guix hacking,
;; with a dark variant (`guix-gold') and a light one (`guix-gold-light').
;; Unlike the external Modus themes, this ships inside the framework, so there
;; is no package to fetch — the module only puts the theme dir on the load
;; paths.  The actual `load-theme' call lives in init.el.

;;; Code:

(let ((dir (expand-file-name "modules/UI/guix-gold/" user-emacs-directory)))
  (add-to-list 'custom-theme-load-path dir)
  (add-to-list 'load-path dir))       ; so the shared palette file is findable

(provide 'guix-gold)
;;; guix-gold.el ends here

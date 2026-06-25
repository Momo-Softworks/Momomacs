;;; kawa.el --- Kawa Scheme (geiser-kawa) for Momo Softworks modding -*- lexical-binding: t; -*-
;;
;; TEMPORARILY DISABLED to debug geiser attachment issues.
;; To re-enable: uncomment the (require 'momo-kawa) in init.el.
;; 
;; Kawa Scheme support for Minecraft 1.7.10 modding with geiser-kawa.
;;
;; geiser-kawa is the Momo-Softworks fork at ~/Projects/geiser-kawa.
;; It provides geiser-kawa-connect (proper Geiser connection to a running
;; REPL) and geiser-kawa-java-location (M-. to Java definitions).
;;
;; Two REPLs:
;;   - Standalone: M-x run-kawa or `make repl` (port 4243) — intellisense
;;   - In-game:    M-x geiser-kawa-connect → localhost 4242 — live coding

;;; Code:

;; (defvar momo/geiser-kawa-dir (expand-file-name "~/Projects/geiser-kawa")
;;   "Root of the geiser-kawa checkout (Momo-Softworks fork).")
;; 
;; (with-eval-after-load 'geiser
;;   (let ((elisp-dir (expand-file-name "elisp" momo/geiser-kawa-dir))
;;         (deps-jar  (expand-file-name
;;                     "target/kawa-geiser-0.1-SNAPSHOT-jar-with-dependencies.jar"
;;                     momo/geiser-kawa-dir)))
;;     (if (not (file-directory-p elisp-dir))
;;         (message "kawa.el: geiser-kawa checkout not found at %s -- skipping"
;;                  momo/geiser-kawa-dir)
;;       (add-to-list 'load-path elisp-dir)
;;       (when (require 'geiser-kawa nil t)
;;         (setq geiser-kawa-use-included-kawa t)
;;         (if (file-exists-p deps-jar)
;;             (setq geiser-kawa-deps-jar-path deps-jar)
;;           (message "kawa.el: geiser-kawa deps jar missing -- run ./mvnw package in %s"
;;                    momo/geiser-kawa-dir))))))

(provide 'momo-kawa)
;;; kawa.el ends here

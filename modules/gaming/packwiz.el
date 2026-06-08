;;; packwiz.el --- packwiz Minecraft modpack manager front-end -*- lexical-binding: t; -*-

;;; Commentary:
;; Installs packwiz.el (https://github.com/chubbymomo/packwiz.el), a native
;; Emacs front-end for the packwiz Minecraft modpack CLI: a transient command
;; tree plus a rich mod browser (CurseForge/Modrinth/GitHub search, mod pages,
;; per-project catalogue triage) and a serve+install+launch test loop.
;;
;; Turns on the globalized minor mode so buffers inside a pack get the ` pw'
;; lighter.  The leader binding (`C-c m k' -> `packwiz-dispatch') lives in
;; `config/keybindings.el'; new-project integration is in
;; `config/project-utils.el'.
;;
;; NB: this file does NOT `(provide 'packwiz)'.  The package itself provides
;; that feature; providing it here would shadow the real package on a config
;; reload and stop it ever loading.

;;; Code:

(use-package packwiz
  :ensure (packwiz :host github :repo "chubbymomo/packwiz.el")
  :config
  (global-packwiz-mode 1)
  ;; Meow integration.  Meow drops read-only/special buffers into MOTION state,
  ;; whose keymap binds `j'/`k'; meow's state maps are minor-mode maps, so they
  ;; shadow packwiz's single-key commands (e.g. `k' = skip).  Layer a copy of
  ;; each packwiz keymap over meow's state maps via
  ;; `minor-mode-overriding-map-alist': packwiz keys win, while meow's `SPC'
  ;; leader and unbound keys fall through.
  (with-eval-after-load 'meow
    (defun momo/packwiz--meow-override (mode-map)
      "Make MODE-MAP win over meow's NORMAL/MOTION keymaps in this buffer."
      (dolist (pair (list (cons 'meow-motion-mode (bound-and-true-p meow-motion-keymap))
                          (cons 'meow-normal-mode (bound-and-true-p meow-normal-keymap))))
        (let ((map (copy-keymap mode-map)))
          (when (cdr pair) (set-keymap-parent map (cdr pair)))
          (setq-local minor-mode-overriding-map-alist
                      (cons (cons (car pair) map)
                            (assq-delete-all (car pair)
                                             minor-mode-overriding-map-alist))))))
    (dolist (entry '((packwiz-browse-mode-hook   . packwiz-browse-mode-map)
                     (packwiz-search-mode-hook   . packwiz-search-mode-map)
                     (packwiz-list-mode-hook     . packwiz-list-mode-map)
                     (packwiz-mod-page-mode-hook . packwiz-mod-page-mode-map)
                     (packwiz-output-mode-hook   . packwiz-output-mode-map)))
      (let ((map-sym (cdr entry)))
        (add-hook (car entry)
                  (lambda () (momo/packwiz--meow-override (symbol-value map-sym))))))))

;;; packwiz.el ends here

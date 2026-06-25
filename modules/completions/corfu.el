;;; corfu.el --- Corfu completion configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Corfu in-buffer completion.  Auto completion disabled by default
;; per upstream recommendation — use M-TAB for manual completion,
;; TAB when the popup is visible.

;;; Code:

(use-package corfu
  :ensure (:wait t)
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  :bind
  (:map corfu-map
        ("TAB" . corfu-complete)
        ("<tab>" . corfu-complete))
  :init
  (global-corfu-mode))

;; Cape — additional completion backends
(use-package cape
  :ensure (:wait t)
  :init
  ;; Add useful backends globally.  They only fire where applicable.
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(provide 'corfu)
;;; corfu.el ends here

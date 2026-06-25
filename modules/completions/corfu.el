;;; corfu.el --- Corfu completion configuration -*- lexical-binding: t; -*-

;;; Code:

(use-package corfu
  :ensure (:wait t)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.3)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode))

(use-package cape
  :ensure (:wait t)
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(provide 'corfu)
;;; corfu.el ends here

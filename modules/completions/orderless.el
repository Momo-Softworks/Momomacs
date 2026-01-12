;;; orderless.el --- Orderless completion style -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for orderless completion style for flexible matching.

;;; Code:

(use-package orderless
  :ensure (:wait t)
  :init
  ;; Configure completion styles
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(provide 'orderless)
;;; orderless.el ends here

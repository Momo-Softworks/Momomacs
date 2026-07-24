;;; vertico.el --- Vertico completion configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Vertico minibuffer completion UI.

;;; Code:

(use-package vertico
  :ensure (:wait t)
  :init
  (vertico-mode)
  :general
  (:keymaps 'vertico-map
      "C-j" #'vertico-next
      "C-k" #'vertico-previous))

;; A few more useful configurations...
(use-package emacs
  :ensure nil
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Posframe

(use-package vertico-posframe
  :ensure (:wait t)
  :config
  (when (getenv "EXWM_LAUNCH")
    ;; Use the parent frame's exwm-geometry directly instead of relying
    ;; on `exwm-workspace-current-index' which can change when the
    ;; minibuffer activates.
    (defun momo/exwm-posframe-refposhandler (&optional frame)
      "Return screen position for posframe based on parent frame geometry."
      (when (bound-and-true-p exwm--connection)
        (if-let* ((parent (or frame (window-frame)))
                  (geom (ignore-errors
                          (frame-parameter parent 'exwm-geometry))))
            (cons (slot-value geom 'x) (slot-value geom 'y))
          (cons 0 0))))
    (setq vertico-posframe-refposhandler #'momo/exwm-posframe-refposhandler
          posframe-mouse-banish-function #'posframe-mouse-banish-simple
          ;; Force internal-border-width since child-frame-border-width
          ;; does nothing on unparented frames under EXWM.
          vertico-posframe-border-width 2
          vertico-posframe-parameters '((child-frame-border-width . 0)
                                        (internal-border-width . 2)))
    ;; Frame-local face application is broken on unparented frames,
    ;; so set the border color globally on the face.
    (set-face-attribute 'vertico-posframe-border nil :background "#5866a0"))
  (vertico-posframe-mode 1))

(provide 'vertico)
;;; vertico.el ends here

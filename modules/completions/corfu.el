;;; corfu.el --- Corfu completion configuration -*- lexical-binding: t; -*-

;;; Code:

(use-package corfu
  :ensure (:wait t)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode))

(use-package cape
  :ensure (:wait t)
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; EXWM multi-monitor fix for Corfu child frames.
;;
;; Corfu's `corfu--make-frame' unconditionally unparents its child
;; frame when EXWM is detected (so EXWM buffers don't draw on top).
;; After unparenting, the relative x/y become absolute screen
;; coordinates — landing on the wrong monitor.
;;
;; EXWM advises `x-create-frame' directly, so we cannot bind
;; `exwm--connection' to nil (that breaks frame creation itself).
;; Instead we temporarily suppress `make-frame-visible' so the frame
;; stays invisible while corfu creates, positions, and unparents it.
;; We then correct the absolute position and show the frame once.
(when (getenv "EXWM_LAUNCH")
  (defun momo/corfu--make-frame-around (orig-fun frame x y width height)
    "Fix Corfu child-frame position for EXWM multi-monitor."
    (if (not (bound-and-true-p exwm--connection))
        (funcall orig-fun frame x y width height)
      (let* ((parent (window-frame))
             (geom (ignore-errors (frame-parameter parent 'exwm-geometry)))
             (orig-mfv (symbol-function 'make-frame-visible))
             (was-visible (and frame (frame-live-p frame) (frame-visible-p frame)))
             result)
        ;; Hide immediately so size/position mutations are invisible.
        (when was-visible
          (make-frame-invisible frame))
        (fset 'make-frame-visible #'identity)
        (unwind-protect
            (setq result (funcall orig-fun frame x y width height))
          (fset 'make-frame-visible orig-mfv))
        (when (and result (frame-live-p result))
          (when (and geom (not (frame-parent result)))
            (let ((px (slot-value geom 'x))
                  (py (slot-value geom 'y))
                  (pos (frame-position result)))
              (unless (and (= px 0) (= py 0))
                (set-frame-position result (+ (car pos) px) (+ (cdr pos) py)))))
          (unless (frame-visible-p result)
            (make-frame-visible result))
          (raise-frame result))
        result)))
  (advice-add 'corfu--make-frame :around #'momo/corfu--make-frame-around))

(provide 'corfu)
;;; corfu.el ends here

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
;; Existing unparented frames can be positioned directly in root-window
;; coordinates.  Only keep a newly created or unexpectedly parented frame
;; invisible until Corfu has unparented it and we have corrected its position.
(when (getenv "EXWM_LAUNCH")
  (defun momo/corfu--make-frame-around (orig-fun frame x y width height)
    "Fix Corfu child-frame position for EXWM multi-monitor."
    (if (not (bound-and-true-p exwm--connection))
        (funcall orig-fun frame x y width height)
      (let* ((parent (window-frame))
             (geom (ignore-errors (frame-parameter parent 'exwm-geometry)))
             (px (if geom (slot-value geom 'x) 0))
             (py (if geom (slot-value geom 'y) 0)))
        (if (and (frame-live-p frame) (not (frame-parent frame)))
            ;; Corfu has already unparented this frame, so X/Y are now root
            ;; coordinates.  Correct them before Corfu moves the visible frame.
            (funcall orig-fun frame (+ x px) (+ y py) width height)
          ;; During initial creation Corfu still expects X/Y relative to the
          ;; parent.  Keep the frame hidden until it has been unparented, then
          ;; place it once in root coordinates and show it at the final position.
          (let ((orig-mfv (symbol-function 'make-frame-visible))
                (was-visible (and (frame-live-p frame) (frame-visible-p frame)))
                result)
            (when was-visible
              (make-frame-invisible frame))
            (fset 'make-frame-visible #'identity)
            (unwind-protect
                (setq result (funcall orig-fun frame x y width height))
              (fset 'make-frame-visible orig-mfv))
            (when (and (frame-live-p result) (not (frame-parent result)))
              (set-frame-position result (+ x px) (+ y py)))
            (when (and (frame-live-p result) (not (frame-visible-p result)))
              (make-frame-visible result))
            result)))))
  (advice-add 'corfu--make-frame :around #'momo/corfu--make-frame-around))

(provide 'corfu)
;;; corfu.el ends here

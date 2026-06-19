(use-package exwm
  :config

  ;; Set the initial workspace number.
  (unless (get 'exwm-workspace-number 'saved-value)
    (setq exwm-workspace-number 10))

  ;; Make class name the buffer name
  (add-hook 'exwm-update-class-hook
            (lambda ()
              (exwm-workspace-rename-buffer exwm-class-name)))

  ;; Global keybindings.
  (unless (get 'exwm-input-global-keys 'saved-value)
    (setq exwm-input-global-keys
          `(;; 's-r': Reset (to line-mode).
            ([?\s-r] . exwm-reset)
            ;; 's-w': Switch workspace.
            ([?\s-w] . exwm-workspace-switch)
            ;; 's-&': Launch application.
            ([?\s-&] . momo/run-application)
            ;; 's-N': Switch to certain workspace.
            ,@(mapcar (lambda (i)
                        `(,(kbd (format "s-%d" i)) .
                          (lambda ()
                            (interactive)
                            (exwm-workspace-switch-create ,i))))
                      (number-sequence 0 9)))))

  ;; Nice stuff
  (setq display-time-default-load-average nil)
  (display-time)

  (setq exwm-workspace-warp-cursor t)

  (setq mouse-autoselect-window t
        focus-follows-mouse t)

  (add-hook 'exwm-floating-setup-hook
            (lambda () (setq mode-line-format nil)))

  ;; RandR multi-monitor support.
  ;; exwm--global-minor-mode-body defers exwm-randr--init to exwm-init-hook
  ;; when called before exwm-wm-mode (i.e. before exwm--connection exists).
  ;; This is the canonical order per the EXWM source.  Monitor layout and
  ;; workspace assignments come from exwm-config.el via setopt.
  (require 'exwm-randr)
  (defun momo/apply-xrandr ()
    ;; Use async to match EXWM's recommended pattern and avoid blocking the
    ;; event loop during exwm-randr--init (start-exwm already ran xrandr before
    ;; Emacs started, so this re-run is idempotent).
    (start-process-shell-command "xrandr" nil momo-xrandr-command))
  (add-hook 'exwm-randr-screen-change-hook #'momo/apply-xrandr)
  (exwm-randr-mode 1)
  ;; Re-apply monitor assignments once Emacs enters the event loop.  The first
  ;; exwm-randr-refresh fires inside exwm-init-hook (before the event loop),
  ;; so any ConfigureNotify events queued during workspace init can still
  ;; arrive and re-layout geometry.  A deferred second pass guarantees the
  ;; final state is correct.
  (add-hook 'exwm-init-hook
            (lambda ()
              (run-with-timer 0.5 nil
                              (lambda ()
                                (ignore-errors (exwm-randr-refresh)))))
            t)

  ;; Advise packages that use posframe for a multi-head setup

  (defun get-focused-monitor-geometry ()
    "Get the geometry of the monitor displaying the selected frame in EXWM."
    (let* ((monitor-attrs (frame-monitor-attributes))
           (workarea (assoc 'workarea monitor-attrs))
           (geometry (cdr workarea)))
      (list (nth 0 geometry)
            (nth 1 geometry)
            (nth 2 geometry)
            (nth 3 geometry))))

  (defun advise-corfu-make-frame-with-monitor-awareness (orig-fun frame x y width height buffer)
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry))
           (new-x (+ monitor-x x))
           (new-y (+ monitor-y y)))
      (funcall orig-fun frame new-x new-y width height buffer)))

  (advice-add 'corfu--make-frame :around #'advise-corfu-make-frame-with-monitor-awareness)

  (defun advise-vertico-posframe-show-with-monitor-awareness (orig-fun buffer window-point &rest args)
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry)))
      (let ((vertico-posframe-poshandler
             (lambda (info)
               (let* ((parent-frame-width (plist-get info :parent-frame-width))
                      (parent-frame-height (plist-get info :parent-frame-height))
                      (posframe-width (plist-get info :posframe-width))
                      (posframe-height (plist-get info :posframe-height))
                      (x (+ monitor-x (/ (- parent-frame-width posframe-width) 2)))
                      (y (+ monitor-y (/ (- parent-frame-height posframe-height) 2))))
                 (cons x y)))))
        (apply orig-fun buffer window-point args))))

  (advice-add 'vertico-posframe--show :around #'advise-vertico-posframe-show-with-monitor-awareness)

  ;; Enable EXWM
  (exwm-wm-mode 1))

(use-package exwm
  :config

  ;; Make sure that dashboard.el is the initial buffer
  (if (package-installed-p 'dashboard)
    (setq initial-buffer-choice #'dashboard-open))
  
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
          `(
            ;; 's-r': Reset (to line-mode).
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
  ;; Line-editing shortcuts
  ;; (unless (get 'exwm-input-simulation-keys 'saved-value)
  ;;   (setq exwm-input-simulation-keys
  ;;         '(([?\C-b] . [left])
  ;;           ([?\C-f] . [right])
  ;;           ([?\C-p] . [up])
  ;;           ([?\C-n] . [down])
  ;;           ([?\C-a] . [home])
  ;;           ([?\C-e] . [end])
  ;;           ([?\M-v] . [prior])
  ;;           ([?\C-v] . [next])
  ;;           ([?\C-d] . [delete])
  ;;           ([?\C-k] . [S-end delete]))))

  ;; Nice stuff
  (setq display-time-default-load-average nil)
  (display-time)

  (setq exwm-workspace-warp-cursor t)

  (setq mouse-autoselect-window t
	focus-follows-mouse t)
  
  ;; No need to set window config, done in momo.el
  (require 'exwm-randr)
  (add-hook 'exwm-randr-screen-change-hook
            (lambda ()
              (start-process-shell-command
               "xrandr" nil xrandr-command)))
  (exwm-randr-enable)

  ;; Advise packages that use posframe for a multi-head setup

  (defun get-focused-monitor-geometry ()
    "Get the geometry of the monitor displaying the selected frame in EXWM."
    (let* ((monitor-attrs (frame-monitor-attributes))
           (workarea (assoc 'workarea monitor-attrs))
           (geometry (cdr workarea)))
      (list (nth 0 geometry) ; X
            (nth 1 geometry) ; Y
            (nth 2 geometry) ; Width
            (nth 3 geometry) ; Height
            )))

  (defun advise-corfu-make-frame-with-monitor-awareness (orig-fun frame x y width height buffer)
    "Advise `corfu--make-frame` to be monitor-aware, adjusting X and Y according to the focused monitor."

    ;; Get the geometry of the currently focused monitor
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry))
           ;; You may want to adjust the logic below if you have specific preferences
           ;; on where on the monitor the posframe should appear.
           ;; Currently, it places the posframe at its intended X and Y, but ensures
           ;; it's within the bounds of the focused monitor.
           (new-x (+ monitor-x x))
           (new-y (+ monitor-y y)))

      ;; Call the original function with potentially adjusted coordinates
      (funcall orig-fun frame new-x new-y width height buffer)))


  (advice-add 'corfu--make-frame :around #'advise-corfu-make-frame-with-monitor-awareness)

  (defun advise-vertico-posframe-show-with-monitor-awareness (orig-fun buffer window-point &rest args)
    "Advise `vertico-posframe--show` to position the posframe according to the focused monitor."

    ;; Extract the focused monitor's geometry
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry)))

      ;; Override poshandler buffer-local variable to use monitor-aware positioning
      (let ((vertico-posframe-poshandler
             (lambda (info)
               (let* ((parent-frame-width (plist-get info :parent-frame-width))
                      (parent-frame-height (plist-get info :parent-frame-height))
                      (posframe-width (plist-get info :posframe-width))
                      (posframe-height (plist-get info :posframe-height))
                      ;; Calculate center position on the focused monitor
                      (x (+ monitor-x (/ (- parent-frame-width posframe-width) 2)))
                      (y (+ monitor-y (/ (- parent-frame-height posframe-height) 2))))
		 (cons x y)))))

	;; Call the original function with potentially adjusted poshandler
	(apply orig-fun buffer window-point args))))

  (advice-add 'vertico-posframe--show :around #'advise-vertico-posframe-show-with-monitor-awareness)

  
  ;; Enable EXWM
  (exwm-enable))

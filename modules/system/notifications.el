;;; notifications.el --- Emacs as the desktop notification server -*- lexical-binding: t; -*-

;;; Commentary:
;; Makes Emacs itself the org.freedesktop.Notifications server (via ednc) and
;; renders arriving notifications as a floating, themed toast (via posframe).
;;
;; Why this exists: the EXWM xsession launches Emacs via
;; `dbus-launch --exit-with-session emacs', so every app started from EXWM
;; (Signal, Discord, ...) inherits this Emacs's session bus.  With nothing
;; owning `org.freedesktop.Notifications' on that bus, Electron apps block on a
;; synchronous D-Bus notify call when backgrounded and freeze -- grey/stale
;; window, GUI unresponsive -- until the call is answered (EXWM issue #768; not
;; a GPU or occlusion problem).  ednc claims that bus name so the call returns
;; immediately (unfreezing the app) AND the notification surfaces in Emacs.
;;
;; The toast uses posframe the same way vertico-posframe does -- proven on this
;; EXWM setup to float over focused X clients and to land on the monitor in use.
;; The one deliberate divergence from vertico-posframe is the refposhandler:
;; see `momo/ednc--refposhandler' below.
;;
;; Loaded only for an EXWM session (init.el gates on EXWM_LAUNCH), since the
;; freeze it cures is specific to Emacs-as-window-manager owning the bus.

;;; Code:

;; posframe is a direct dependency here.  Under `momo-use-guix' it is on
;; `load-path' already (propagated by emacs-vertico-posframe / listed in the
;; momomacs channel), so :ensure is forced to nil; otherwise Elpaca installs it.
(use-package posframe
  :ensure t
  :demand t)

(defface momo/ednc-app-face
  '((t :inherit (mode-line-emphasis bold)))
  "Face for the application-name line of an ednc toast.")

(defconst momo/ednc--toast-buffer " *ednc-toast*" "Buffer backing the toast.")
(defconst momo/ednc--toast-margin 24
  "Inset in px from the current monitor's top-right corner.")
(defconst momo/ednc--toast-timeout 6 "Seconds a toast stays up.")
(defconst momo/ednc--toast-padding 14
  "Invisible internal border in px -> uniform padding inside the toast.")
(defconst momo/ednc--toast-border-width 2
  "Width in px of the toast's visible, themed outer border.")
(defconst momo/ednc--toast-max-width 46
  "Maximum toast width in columns, so long bodies wrap instead of sprawl.")

(defun momo/ednc--make-toast-input-transparent (frame)
  "Make the ednc toast FRAME ignore all X11 pointer input.
`no-accept-focus' prevents keyboard focus, but a normal mapped X window can
still interrupt an application's active pointer grab (notably Moonlight's).
An empty Shape input region keeps the toast visible while mouse events pass
through it and, crucially, is installed before the frame is mapped."
  (when (and (frame-live-p frame)
             (equal (car-safe (frame-parameter frame 'posframe-buffer))
                    momo/ednc--toast-buffer)
             (bound-and-true-p exwm--connection))
    (condition-case nil
        (let* ((window-id (frame-parameter frame 'outer-window-id))
               (xid (if (stringp window-id)
                        (string-to-number
                         window-id
                         (if (string-prefix-p "0x" window-id) 16 10))
                      window-id)))
          (require 'xcb-shape)
          (xcb:get-extension-data exwm--connection 'xcb:shape)
          (xcb:+request
           exwm--connection
           (make-instance 'xcb:shape:Rectangles
                          :operation xcb:shape:SO:Set
                          :destination-kind xcb:shape:SK:Input
                          :ordering xcb:ClipOrdering:Unsorted
                          :destination-window xid
                          :x-offset 0
                          :y-offset 0
                          :rectangles nil))
          (xcb:flush exwm--connection))
      (error nil))))

;; `posframe-show' creates its frame hidden, then calls this internal function
;; to map it.  Advising that boundary lets the empty input shape take effect on
;; the very first notification, before mapping can disturb a pointer grab.
(unless (advice-member-p #'momo/ednc--make-toast-input-transparent
                         'posframe--make-frame-visible)
  (advice-add 'posframe--make-frame-visible :before
              #'momo/ednc--make-toast-input-transparent))

(defun momo/ednc--refposhandler (&optional frame)
  "Absolute origin (X . Y) of the current EXWM workspace's monitor.
This is what lets the toast land on the right monitor and float over
focused X windows.

NOTE: unlike `vertico-posframe-refposhandler-default' (and Momomacs'
own `momo/exwm-posframe-refposhandler'), this reads
`exwm-workspace--workareas' by `exwm-workspace-current-index' rather
than the parent frame's `exwm-geometry' parameter.  Those handlers use
the parent geometry because `exwm-workspace-current-index' can shift
when the minibuffer activates -- but a notification toast arrives
asynchronously with no minibuffer involved, and the parent frame of an
async toast reports `exwm-geometry' of (0 . 0) even on a non-primary
monitor, which would misplace the toast onto the left screen.  The
workarea lookup is correct for this async case (verified on both
monitors).  Returns nil off EXWM so posframe falls back to normal
parent-frame-relative placement."
  (cond
   ((bound-and-true-p exwm--connection)
    (or (ignore-errors
          (let ((info (elt exwm-workspace--workareas
                           exwm-workspace-current-index)))
            (cons (oref info x) (oref info y))))
        (ignore-errors (posframe-refposhandler-xwininfo frame))
        (cons 0 0)))
   (t nil)))

(defun momo/ednc--poshandler-top-right (info)
  "Top-right of the parent frame, inset by `momo/ednc--toast-margin'.
Returns non-negative coordinates so posframe adds the refposhandler's
monitor origin verbatim -- the toast stays fully inside one monitor
instead of spilling across the boundary."
  (let ((frame-width    (plist-get info :parent-frame-width))
        (posframe-width (plist-get info :posframe-width)))
    (cons (max 0 (- frame-width posframe-width momo/ednc--toast-margin))
          momo/ednc--toast-margin)))

(defun momo/ednc--border-color ()
  "A themed color for the toast's outer border."
  (or (face-background 'mode-line nil t)
      (face-foreground 'font-lock-comment-face nil t)
      (face-foreground 'default nil t)))

(defun momo/ednc--format (n)
  "Render ednc notification N as the toast string.
Padding comes from the frame's internal border, so none is added here."
  (let ((app     (ednc-notification-app-name n))
        (summary (ednc-notification-summary n))
        (body    (ednc-notification-body n)))
    (concat
     (propertize (or app "") 'face 'momo/ednc-app-face) "\n"
     (propertize (or summary "") 'face 'bold)
     (if (and body (not (string-empty-p body)))
         (concat "\n" body) ""))))

(defun momo/ednc-show-toast (text)
  "Show TEXT as a themed top-right toast on the current monitor."
  (when (and (fboundp 'posframe-show) (display-graphic-p))
    (let ((bg (face-background 'default nil t)))
      (with-current-buffer (get-buffer-create momo/ednc--toast-buffer)
        ;; Wrap on word boundaries and drop the fringe continuation arrow,
        ;; so wrapped bodies read cleanly instead of showing a curl marker.
        (setq-local truncate-lines nil
                    word-wrap t
                    fringe-indicator-alist '((continuation nil nil)))
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert text)
          (goto-char (point-min))))
      ;; Posframe normally warps the pointer away when it thinks the pointer
      ;; overlaps a popup.  Its calculation does not account for our absolute
      ;; EXWM refposhandler and sends the pointer to the monitor's top-right.
      ;; The toast is X11 input-transparent, so no banishing is needed here.
      (let ((posframe-mouse-banish-function #'ignore))
        (posframe-show
         momo/ednc--toast-buffer
         :poshandler #'momo/ednc--poshandler-top-right
         :refposhandler #'momo/ednc--refposhandler
         :background-color bg
         :foreground-color (face-foreground 'default nil t)
         :border-width momo/ednc--toast-border-width
         :border-color (momo/ednc--border-color)
         ;; Invisible inner border == uniform padding on every side.
         :internal-border-width momo/ednc--toast-padding
         :internal-border-color bg
         :left-fringe 10 :right-fringe 10
         :max-width momo/ednc--toast-max-width
         :lines-truncate nil
         :cursor nil
         :accept-focus nil
         :timeout momo/ednc--toast-timeout
         :override-parameters '((no-accept-focus . t)
                                (no-focus-on-map . t)))))))

(defun momo/ednc-hide-toast ()
  "Hide the toast frame."
  (when (fboundp 'posframe-hide)
    (posframe-hide momo/ednc--toast-buffer)))

(defun momo/ednc-present-toast (_old new)
  "ednc presenter: pop NEW as a toast; dismiss when notifications clear."
  (if new
      (ignore-errors (momo/ednc-show-toast (momo/ednc--format new)))
    (unless (ednc-notifications) (momo/ednc-hide-toast))))

(use-package ednc
  :ensure t
  :demand t
  :config
  (require 'posframe)
  (ednc-mode 1)
  ;; Keep ednc's default *ednc-log* presenter (a persistent scrollback of
  ;; every notification); add the toast alongside it.
  (add-hook 'ednc-notification-presentation-functions
            #'momo/ednc-present-toast))

(provide 'notifications)
;;; notifications.el ends here

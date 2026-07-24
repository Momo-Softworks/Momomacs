;;; exwm.el --- EXWM configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; EXWM configuration following the upstream wiki structure while keeping the
;; surrounding Momomacs module layout intact.

;;; Code:

(defvar exwm-systemtray-height)
(defvar exwm-randr-workspace-monitor-plist)

(declare-function exwm-input-send-next-key "ext:exwm-input")
(declare-function exwm-workspace-rename-buffer "ext:exwm-workspace")
(declare-function exwm-wm-mode "ext:exwm")
(declare-function xdg-launcher-run-app "ext:xdg-launcher")

(defun momo/exwm-launch-command (command)
  "Launch shell COMMAND asynchronously."
  (start-process-shell-command command nil command))

(defun momo/exwm-shell-command (command)
  "Prompt for a shell COMMAND and launch it asynchronously."
  (interactive (list (read-shell-command "$ ")))
  (momo/exwm-launch-command command))

(defun momo/exwm-open-terminal ()
  "Open an `eat' terminal buffer."
  (interactive)
  (require 'eat)
  (eat))

(defun momo/exwm-rename-buffer-by-class ()
  "Rename an EXWM buffer to its X class name."
  (when (and (boundp 'exwm-class-name) exwm-class-name)
    (exwm-workspace-rename-buffer exwm-class-name)))

(defun momo/exwm-rename-buffer-by-title ()
  "Rename select EXWM buffers using their window title."
  (when (and (boundp 'exwm-class-name)
             (boundp 'exwm-title)
             exwm-class-name
             exwm-title
             (member exwm-class-name '("Firefox" "LibreWolf" "Chromium")))
    (exwm-workspace-rename-buffer exwm-title)))

(defun momo/exwm-run-init-commands ()
  "Run commands listed in `momo-exwm-init-commands'."
  (dolist (command momo-exwm-init-commands)
    (let ((program (car (split-string command "[ \t]+" t))))
      (when (and program (executable-find program))
        (momo/exwm-launch-command command)))))

(use-package exwm
  :demand t
  :config
  (require 'exwm-randr)
  (require 'exwm-systemtray)

  (setq exwm-workspace-number momo-exwm-workspace-number
        exwm-workspace-warp-cursor t
        exwm-layout-show-all-buffers t
        exwm-workspace-show-all-buffers t
        exwm-systemtray-height 24
        mouse-autoselect-window nil
        focus-follows-mouse nil
        exwm-input-prefix-keys
        '(?	 ?\C-x ?\C-u ?\C-h ?\M-x ?\M-& ?\M-: ?\C-\M-j ?\C-\\)
        exwm-input-simulation-keys
        '(([?\C-b] . [left])
          ([?\C-f] . [right])
          ([?\C-p] . [up])
          ([?\C-n] . [down])
          ([?\C-a] . [home])
          ([?\C-e] . [end])
          ([?\M-v] . [prior])
          ([?\C-v] . [next])
          ([?\C-d] . [delete])
          ([?\C-k] . [S-end delete])))

  (setq exwm-input-global-keys
        `(([?\s-r] . exwm-reset)
          ([?\s-w] . exwm-workspace-switch)
          ([?\s-&] . momo/exwm-shell-command)
          (,(kbd "s-p") . xdg-launcher-run-app)
          (,(kbd "s-`") . (lambda ()
                            (interactive)
                            (exwm-workspace-switch-create 0)))
          (,(kbd "s-<return>") . momo/exwm-open-terminal)
          (,(kbd "s-b") . (lambda ()
                             (interactive)
                             (momo/exwm-launch-command momo-exwm-default-browser-command)))
          (,(kbd "s-g") . exwm-input-grab-keyboard)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))

  (add-hook 'exwm-update-class-hook #'momo/exwm-rename-buffer-by-class)
  (add-hook 'exwm-update-title-hook #'momo/exwm-rename-buffer-by-title)
  (add-hook 'exwm-init-hook #'momo/exwm-run-init-commands)
  (add-hook 'exwm-floating-setup-hook
            (lambda ()
              (setq-local mode-line-format nil)))

  (define-key exwm-mode-map [?	] #'self-insert-command)
  (define-key exwm-mode-map [?
] #'self-insert-command)
  (define-key exwm-mode-map (kbd "C-q") #'exwm-input-send-next-key)

  (setq exwm-randr-workspace-monitor-plist
        momo-exwm-randr-workspace-monitor-plist)

  (add-hook 'exwm-randr-screen-change-hook
            (lambda ()
              (when (executable-find "xrandr")
                (start-process-shell-command "xrandr" nil momo-exwm-xrandr-command))))

  (display-time-mode 1)
  (exwm-systemtray-mode 1)
  (exwm-randr-mode 1)
  (exwm-wm-mode 1))

(provide 'exwm)
;;; exwm.el ends here

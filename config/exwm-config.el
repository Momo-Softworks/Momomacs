;;; exwm-config.el --- EXWM window manager configuration -*- lexical-binding: t; -*-

(defcustom momo-xrandr-command "xrandr --output eDP --off --output DisplayPort-2 --mode 1920x1080 --pos 0x0 --primary --output DisplayPort-1 --mode 1920x1080 --right-of DisplayPort-2"
  "Xrandr command for your setup"
  :type 'string
  :group 'momo)

;; Use setq rather than setopt: this file is loaded before exwm-randr is
;; available, so setopt may not find the defcustom and could silently fail
;; inside momo.el's condition-case.  setq is sufficient here because
;; exwm-randr--init always calls exwm-randr-refresh after loading the mode.
(setq exwm-randr-workspace-monitor-plist '(1 "DisplayPort-1"
					   2 "DisplayPort-1"
					   3 "DisplayPort-1"
					   4 "DisplayPort-1"
					   5 "DisplayPort-1"
					   6 "DisplayPort-2"
					   7 "DisplayPort-2"
					   8 "DisplayPort-2"
					   9 "DisplayPort-2"
					   0 "DisplayPort-2"))

(provide 'exwm-config)
;;; exwm-config.el ends here

;;; exwm-config.el --- EXWM window manager configuration -*- lexical-binding: t; -*-

(defcustom momo-xrandr-command "xrandr --output DP-2 --mode 1920x1080 --primary --output DP-3 --mode 1920x1080 --right-of DP-2"
  "Xrandr command for your setup"
  :type 'string
  :group 'momo)

(setopt exwm-randr-workspace-monitor-plist '(1 "DP-2"
					       2 "DP-2"
					       3 "DP-2"
					       4 "DP-2"
					       5 "DP-2"
					       6 "DP-3"
					       7 "DP-3"
					       8 "DP-3"
					       9 "DP-3"
					       0 "DP-3"))

(provide 'exwm-config)
;;; exwm-config.el ends here

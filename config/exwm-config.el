;;; exwm-config.el --- EXWM window manager configuration -*- lexical-binding: t; -*-

(defcustom momo-xrandr-command "xrandr --output DP1 --mode 2560x1440 --rate 119.87 --output DP2-2 --mode 2560x1440 --rate 60 --right-of DP1"
  "Xrandr command for your setup"
  :type 'string
  :group 'momo)

(setopt exwm-randr-workspace-monitor-plist '(1 "DP1"
					       2 "DP1"
					       3 "DP1"
					       4 "DP1"
					       5 "DP1"
					       6 "DP2-2"
					       7 "DP2-2"
					       8 "DP2-2"
					       9 "DP2-2"
					       0 "DP2-2"))

(provide 'exwm-config)
;;; exwm-config.el ends here

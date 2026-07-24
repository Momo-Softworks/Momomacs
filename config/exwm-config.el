;;; exwm-config.el --- EXWM user configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; User-tunable EXWM settings that stay separate from the package module.
;; This file is loaded early from `momo.el`, before the EXWM package itself.

;;; Code:

(defcustom momo-exwm-workspace-number 10
  "Number of EXWM workspaces to create."
  :type 'integer
  :group 'momo)

(defcustom momo-exwm-default-browser-command "librewolf"
  "Browser command used by EXWM shortcuts."
  :type 'string
  :group 'momo)

(defcustom momo-exwm-xrandr-command
  (string-join
   '("xrandr"
     "--output eDP --off"
     "--output DisplayPort-1 --primary --mode 1920x1080 --rate 100 --pos 0x0 --rotate normal --set TearFree on"
     "--output DisplayPort-2 --mode 1920x1080 --rate 100 --right-of DisplayPort-1 --rotate normal --set TearFree on")
   " ")
  "Xrandr command applied by `exwm-randr-mode'."
  :type 'string
  :group 'momo)

(defcustom momo-exwm-randr-workspace-monitor-plist
  '(1 "DisplayPort-1" 2 "DisplayPort-1" 3 "DisplayPort-1" 4 "DisplayPort-1" 5 "DisplayPort-1"
    6 "DisplayPort-2" 7 "DisplayPort-2" 8 "DisplayPort-2" 9 "DisplayPort-2" 0 "DisplayPort-2")
  "Workspace-to-monitor mapping for EXWM RandR integration."
  :type '(repeat (choice integer string))
  :group 'momo)

(defcustom momo-exwm-init-commands
  (list momo-exwm-xrandr-command
        "xsetroot -cursor_name left_ptr"
        "xset r rate 200 60")
  "Shell commands run when EXWM finishes initializing.

Commands that are unavailable are skipped by the EXWM module, so this list can
safely contain optional X11 utilities that are not always installed."
  :type '(repeat string)
  :group 'momo)

;; Apply the checked-in EXWM defaults even if stale values were persisted in a
;; running session or custom state.
(setq momo-exwm-xrandr-command
      (string-join
       '("xrandr"
         "--output eDP --off"
         "--output DisplayPort-1 --primary --mode 1920x1080 --rate 100 --pos 0x0 --rotate normal --set TearFree on"
         "--output DisplayPort-2 --mode 1920x1080 --rate 100 --right-of DisplayPort-1 --rotate normal --set TearFree on")
       " ")
      momo-exwm-randr-workspace-monitor-plist
      '(1 "DisplayPort-1" 2 "DisplayPort-1" 3 "DisplayPort-1" 4 "DisplayPort-1" 5 "DisplayPort-1"
        6 "DisplayPort-2" 7 "DisplayPort-2" 8 "DisplayPort-2" 9 "DisplayPort-2" 0 "DisplayPort-2")
      momo-exwm-init-commands
      (list momo-exwm-xrandr-command
            "xsetroot -cursor_name left_ptr"
            "xset r rate 200 60"))

(provide 'exwm-config)
;;; exwm-config.el ends here

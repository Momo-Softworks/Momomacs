;;; exwm-config.el --- EXWM user configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; User-tunable EXWM settings that stay separate from the package module.
;; This file is loaded early from `momo.el', before the EXWM package itself.
;;
;; The values here are GENERIC starting points meant to work on any single-
;; monitor machine — a place to begin, not a personal setup.  Machine-specific
;; values (your exact monitor names/layout, preferred browser, per-workspace
;; monitor mapping) belong in your personal overlay, which loads after this
;; file and can simply `setq' these variables.  See Samuel's overlay
;; `config/exwm-config.el' for a worked example.

;;; Code:

(defcustom momo-exwm-workspace-number 10
  "Number of EXWM workspaces to create."
  :type 'integer
  :group 'momo)

(defcustom momo-exwm-default-browser-command "firefox"
  "Browser command used by EXWM shortcuts.
Override in your overlay if you use a different browser."
  :type 'string
  :group 'momo)

(defcustom momo-exwm-xrandr-command "xrandr --auto"
  "Xrandr command applied by `exwm-randr-mode'.
The default (`xrandr --auto') just enables connected outputs at their
preferred modes, which is safe on any hardware.  For a fixed multi-monitor
layout, override this in your overlay with the full `xrandr --output …' form."
  :type 'string
  :group 'momo)

(defcustom momo-exwm-randr-workspace-monitor-plist '()
  "Workspace-to-monitor mapping for EXWM RandR integration.
Empty by default (every workspace on the primary output).  Override in your
overlay with a plist like (1 \"HDMI-1\" 2 \"HDMI-1\" 3 \"DP-1\" …)."
  :type '(repeat (choice integer string))
  :group 'momo)

(defcustom momo-exwm-init-commands
  (list momo-exwm-xrandr-command
        "xsetroot -cursor_name left_ptr"
        "xset r rate 200 60")
  "Shell commands run when EXWM finishes initializing.

Commands whose program is unavailable are skipped by the EXWM module, so this
list can safely contain optional X11 utilities that are not always installed."
  :type '(repeat string)
  :group 'momo)

(provide 'exwm-config)
;;; exwm-config.el ends here

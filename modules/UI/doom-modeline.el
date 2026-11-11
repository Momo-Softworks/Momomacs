;;; doom-modeline.el --- Doom modeline configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the Doom modeline - a modern and minimal modeline.
;; Its icons come from nerd-icons, which needs the "Symbols Nerd Font Mono"
;; font; `momo/ensure-nerd-font' installs it on first graphical start.

;;; Code:

(defun momo/nerd-font-installed-p ()
  "Return non-nil if the nerd-icons font is available to Emacs."
  (find-font (font-spec :family (if (boundp 'nerd-icons-font-family)
                                    nerd-icons-font-family
                                  "Symbols Nerd Font Mono"))))

(defun momo/install-nerd-font-windows ()
  "Download the nerd-icons font and install it for the current Windows user.
No admin rights are needed: the font goes in the per-user Fonts folder and
is registered under HKCU, which is what Windows does for \"Install\"."
  (let ((ttf (make-temp-file "NFM" nil ".ttf"))
        (script "
$d = Join-Path $env:LOCALAPPDATA 'Microsoft\\Windows\\Fonts'
New-Item -ItemType Directory -Force -Path $d | Out-Null
$dest = Join-Path $d 'SymbolsNerdFontMono-Regular.ttf'
Copy-Item -LiteralPath $args[0] -Destination $dest -Force
New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' -Name 'Symbols Nerd Font Mono (TrueType)' -Value $dest -PropertyType String -Force | Out-Null
"))
    (url-copy-file "https://raw.githubusercontent.com/rainstormstudio/nerd-icons.el/main/fonts/NFM.ttf"
                   ttf t)
    (unwind-protect
        (unless (zerop (call-process "powershell" nil nil nil
                                     "-NoProfile" "-NonInteractive"
                                     "-ExecutionPolicy" "Bypass"
                                     "-Command"
                                     (concat "& {" script "}")
                                     (convert-standard-filename ttf)))
          (error "PowerShell font install failed"))
      (delete-file ttf))))

(defun momo/ensure-nerd-font ()
  "Install the nerd-icons font if it is missing.
Runs only in a graphical frame.  On Linux (Guix included) and macOS this
uses `nerd-icons-install-fonts', which installs into the user's font folder."
  (when (and (display-graphic-p)
             (not (momo/nerd-font-installed-p)))
    (condition-case err
        (progn
          (message "Installing Symbols Nerd Font Mono for modeline icons...")
          (if (eq system-type 'windows-nt)
              (momo/install-nerd-font-windows)
            (require 'nerd-icons)
            (nerd-icons-install-fonts t))
          (message "Nerd font installed. Restart Emacs if icons still show as boxes."))
      (error (message "Could not install the nerd font: %s" (error-message-string err))))))

(use-package doom-modeline
  :ensure (:wait t)
  :init
  (doom-modeline-mode 1)
  ;; After startup so a slow download never delays the first frame.
  (add-hook 'emacs-startup-hook #'momo/ensure-nerd-font))

(provide 'momo-doom-modeline)
;;; doom-modeline.el ends here

;;; guix-gold-light-theme.el --- Warm gold-and-ember theme for Scheme (light)  -*- lexical-binding: t; -*-

;; Light sibling of guix-gold.  Same face set (guix-gold-palette.el), the CSS
;; light palette, and light-tinted diff backgrounds.  Syntax tokens >=7:1 on bg.

(eval-and-compile
  (add-to-list 'load-path
               (file-name-directory
                (or load-file-name buffer-file-name default-directory))))
(require 'guix-gold-palette)

(deftheme guix-gold-light
  "Warm gold-and-ember theme tuned for Scheme / Guix hacking (light).")

(apply #'custom-theme-set-faces 'guix-gold-light
       (guix-gold--faces
        (list
         :bg "#f7edd8" :bg-soft "#efe3c8" :bg-hl "#e8d9b8"
         :fg "#2a2116" :fg-dim "#514328" :cursor "#8a5410"
         :comment "#543c3b"
         :keyword "#6d420f" :builtin "#991e0d" :string "#395108"
         :type "#2a468c" :quote "#7e2a63" :error "#a81848" :paren "#4c4c4f"
         :r0 "#6d420f" :r1 "#2a468c" :r2 "#7e2a63" :r3 "#395108"
         ;; derived diff backgrounds (light tints) + emphasis variants
         :add-bg "#dcecc4" :add-bg-hi "#c6e0a4"
         :del-bg "#f2d6cc" :del-bg-hi "#eabcaa"
         :chg-bg "#ecdcaa" :chg-bg-hi "#e0c98a"
         :add-fg "#395108" :del-fg "#991e0d" :chg-fg "#6d420f")))

(custom-theme-set-variables
 'guix-gold-light
 '(rainbow-delimiters-max-face-count 4))

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'guix-gold-light)
(provide 'guix-gold-light-theme)
;;; guix-gold-light-theme.el ends here

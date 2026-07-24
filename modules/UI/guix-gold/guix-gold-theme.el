;;; guix-gold-theme.el --- Warm gold-and-ember theme for Scheme (dark)  -*- lexical-binding: t; -*-

;; Gold keywords; ember builtins; periwinkle types/functions/numbers; pink
;; quotes/constants; green strings; crimson errors.  Syntax tokens >=7:1 on bg.
;; Face set lives in guix-gold-palette.el; this file supplies the dark palette.
;;
;; Locked syntax decisions: function-name=periwinkle (params stay default fg),
;; variable-name=fg, constant=pink, doc=green italic, warning=ember.

;; Find the shared palette on `load-path'.  Its dir is added by the framework
;; module and by Guix (guix-emacs); this fallback covers a bare direct load
;; (default-directory is always bound, so it also works at byte-compile time
;; when load-file-name/buffer-file-name are nil).
(eval-and-compile
  (add-to-list 'load-path
               (file-name-directory
                (or load-file-name buffer-file-name default-directory))))
(require 'guix-gold-palette)

(deftheme guix-gold
  "Warm gold-and-ember theme tuned for Scheme / Guix hacking (dark).")

(apply #'custom-theme-set-faces 'guix-gold
       (guix-gold--faces
        (list
         :bg "#1d1712" :bg-soft "#262019" :bg-hl "#33291f"
         :fg "#ece0c8" :fg-dim "#b3a488" :cursor "#f2b632"
         :comment "#aca893"
         :keyword "#f2b632" :builtin "#fe8019" :string "#9ccc5f"
         :type "#9bb4f0" :quote "#e79bd0" :error "#f2506a" :paren "#c0b4b3"
         :r0 "#f2b632" :r1 "#9bb4f0" :r2 "#e79bd0" :r3 "#a9cf63"
         ;; derived diff backgrounds (dark tints) + emphasis variants
         :add-bg "#22301a" :add-bg-hi "#2f4322"
         :del-bg "#3a1c1f" :del-bg-hi "#52262b"
         :chg-bg "#332a15" :chg-bg-hi "#443714"
         :add-fg "#9ccc5f" :del-fg "#f2506a" :chg-fg "#f2b632")))

(custom-theme-set-variables
 'guix-gold
 '(rainbow-delimiters-max-face-count 4))

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'guix-gold)
(provide 'guix-gold-theme)
;;; guix-gold-theme.el ends here

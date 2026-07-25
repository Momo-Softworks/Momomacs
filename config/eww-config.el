;;; eww-config.el --- eww browser configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the built-in `eww' browser, focused on reading long or
;; math-heavy documentation comfortably:
;;
;;   1. Long navigation sidebars: `eww-readable' (reader mode, `R') strips
;;      site chrome so only the article body shows.  Set `eww-readable-urls'
;;      to auto-apply it for chosen sites.
;;
;;   2. LaTeX not rendering: MathJax pages typeset math with JavaScript, which
;;      eww never runs, so you see the raw source (e.g. "\\({\\mathbb{R}^3}\\)").
;;      `momo/eww-render-math' (C-c C-l) replaces each \\(..\\)/\\[..\\] fragment
;;      with an image from the org LaTeX-preview pipeline.  Set
;;      `momo/eww-math-auto-url-regexp' to render automatically on chosen URLs.
;;
;; Site-specific readers (auto-render URLs, per-site DOM helpers) belong in a
;; personal overlay; see Samuel's overlay `config/eww-config.el' for a worked
;; example (Paul's Online Math Notes: auto-math + foldable "Show Solution").

;;; Code:

(require 'browse-url)
(require 'cl-lib)

(defgroup momo-eww nil
  "Momomacs tweaks for the eww browser."
  :group 'eww)

;; Use eww as the default browser for org-mode links and `browse-url'.
(setq browse-url-browser-function #'eww-browse-url)


;;;; Reading experience ----------------------------------------------------

;; Render pages with the Emacs theme instead of each site's own colors
;; (much better contrast on a dark theme), reflow text to the window width,
;; use nicer bullets, and keep images from dominating the split.
(with-eval-after-load 'shr
  (setq shr-use-colors nil          ; ignore page colors; use the theme
        shr-fill-text nil           ; reflow to window width (visual-line-mode)
        shr-bullet "• "
        shr-max-image-proportion 0.7))

(defcustom momo/eww-reading-fill-column 90
  "Comfortable line width (in columns) for eww reading buffers.
Used by `visual-fill-column-mode' to cap and center the text column."
  :type 'integer
  :group 'momo-eww)

(defcustom momo/eww-text-scale 1
  "Amount to bump the text size in eww buffers (see `text-scale-set').
Set to 0 to leave the default size."
  :type 'integer
  :group 'momo-eww)

(defun momo/eww-setup-reading ()
  "Apply comfortable reading defaults in the current eww buffer.
Bumps the text size and, when `visual-fill-column' is available, caps the
line width to `momo/eww-reading-fill-column' and centers it.  eww itself
enables `visual-line-mode' (because `shr-fill-text' is nil), so this does
not touch it."
  (when (and (integerp momo/eww-text-scale)
             (/= momo/eww-text-scale 0))
    (text-scale-set momo/eww-text-scale))
  (when (fboundp 'visual-fill-column-mode)
    (setq-local fill-column momo/eww-reading-fill-column)
    (setq-local visual-fill-column-center-text t)
    (visual-fill-column-mode 1)))

(add-hook 'eww-mode-hook #'momo/eww-setup-reading)


;;;; Window placement (open pages beside the current buffer) ---------------

(defconst momo/eww--buffer-name-regexp "\\`\\*eww\\(\\*\\|-\\)"
  "Regexp matching eww page buffers (\"*eww*\" and \"*eww-HOST*\").")

(defcustom momo/eww-open-in-split t
  "When non-nil, open eww pages in a side window instead of the same window.
Pages opened from org links (\\[org-open-at-point]) or `browse-url' then
appear in a split alongside the current buffer, and navigation within eww
reuses that same window.  Set with `momo/eww-toggle-split' or re-evaluate
`momo/eww-apply-window-placement' after customizing."
  :type 'boolean
  :group 'momo-eww)

(defcustom momo/eww-split-direction 'right
  "Side on which `momo/eww-open-in-split' places the eww window.
One of `right', `left', `below' or `above' (see `display-buffer-in-direction')."
  :type '(choice (const right) (const left) (const below) (const above))
  :group 'momo-eww)

(defcustom momo/eww-split-size 0.5
  "Fraction of the frame given to the eww side window.
Used as `window-width' for left/right splits, `window-height' otherwise."
  :type 'number
  :group 'momo-eww)

(defun momo/eww--display-buffer-entry ()
  "Build the `display-buffer-alist' entry placing eww pages in a split.
`display-buffer-reuse-window' comes first so navigating within eww (or
opening another page while eww is visible) reuses the existing window
instead of creating a new split each time."
  `(,momo/eww--buffer-name-regexp
    (display-buffer-reuse-window display-buffer-in-direction)
    (direction . ,momo/eww-split-direction)
    (,(if (memq momo/eww-split-direction '(left right))
          'window-width 'window-height)
     . ,momo/eww-split-size)))

(defun momo/eww-apply-window-placement ()
  "Apply (or remove) the eww split rule in `display-buffer-alist'.
Honors `momo/eww-open-in-split'.  Safe to call repeatedly."
  (setq display-buffer-alist
        (cl-remove-if (lambda (e)
                        (and (stringp (car-safe e))
                             (string= (car e) momo/eww--buffer-name-regexp)))
                      display-buffer-alist))
  (when momo/eww-open-in-split
    (add-to-list 'display-buffer-alist (momo/eww--display-buffer-entry))))

(defun momo/eww-toggle-split ()
  "Toggle whether eww pages open in a side window (`momo/eww-open-in-split')."
  (interactive)
  (setq momo/eww-open-in-split (not momo/eww-open-in-split))
  (momo/eww-apply-window-placement)
  (message "eww pages will now open %s"
           (if momo/eww-open-in-split "in a split" "in the same window")))

(momo/eww-apply-window-placement)


;;;; Open current page in the system browser -------------------------------

(defun momo/eww-open-in-system-browser ()
  "Open the current eww URL in the system's default browser.
Useful when eww doesn't render a page well and you need the full browser."
  (interactive)
  (let ((url (eww-current-url)))
    (if url
        (browse-url-generic url)
      (message "No URL to open in eww buffer"))))


;;;; LaTeX / MathJax rendering ---------------------------------------------

(defcustom momo/eww-math-auto-url-regexp nil
  "Regexp of eww URLs whose LaTeX math is rendered automatically, or nil.
When nil (the default) math is never auto-rendered; use `momo/eww-render-math'
\(bound to \\`C-c C-l' in eww buffers) on demand.  Set this to a URL regexp
\(typically in your overlay) to auto-render math on matching pages."
  :type '(choice (const :tag "Never auto-render" nil) regexp)
  :group 'momo-eww)

(defcustom momo/eww-math-process 'dvisvgm
  "The org LaTeX-preview process used to render math in eww buffers.
Must be a key of `org-preview-latex-process-alist', e.g. `dvisvgm'
\(crisp SVG) or `dvipng' (raster PNG)."
  :type 'symbol
  :group 'momo-eww)

(defconst momo/eww-math-regexp
  (rx (or (seq "\\(" (*? anychar) "\\)")
          (seq "\\[" (*? anychar) "\\]")))
  "Regexp matching inline \\(..\\) and display \\[..\\] LaTeX fragments.")

(defvar momo/eww-math-cache-directory
  (expand-file-name "eww-math/" temporary-file-directory)
  "Directory where rendered eww math images are cached.")

(defun momo/eww--math-image-file (value type options)
  "Return a cached image file for LaTeX VALUE, creating it if needed.
TYPE is an `org-preview-latex-process-alist' key; OPTIONS is an
`org-format-latex-options'-style plist.  Returns the file name, or nil
if rendering failed."
  (require 'org)
  (let* ((info (cdr (assq type org-preview-latex-process-alist)))
         (ext  (or (plist-get info :image-output-type) "png"))
         (hash (sha1 (prin1-to-string (list value type options))))
         (file (expand-file-name (concat hash "." ext)
                                 momo/eww-math-cache-directory)))
    (unless (file-exists-p file)
      (make-directory momo/eww-math-cache-directory t)
      (condition-case err
          ;; BUFFER non-nil -> use :scale/:foreground/:background options.
          (org-create-formula-image value file options t type)
        (error
         (message "eww math: failed to render %S: %s" value
                  (error-message-string err))
         (setq file nil))))
    (and file (file-exists-p file) file)))

(defun momo/eww--default-foreground ()
  "Return a valid foreground color for math, based on the `default' face.
Falls back to a sensible light/dark color when the face color is
unspecified (e.g. on a non-graphical frame)."
  (let ((fg (face-attribute 'default :foreground nil 'default))
        (bg (face-attribute 'default :background nil 'default)))
    (cond
     ((and (stringp fg) (color-defined-p fg)) fg)
     ;; Foreground unspecified: pick based on background luminance.
     ((and (stringp bg) (color-defined-p bg)
           (< (apply #'+ (color-name-to-rgb bg)) 1.5))
      "white")
     (t "black"))))

(defun momo/eww--math-options ()
  "Build `org-create-formula-image' OPTIONS resolved for the current theme.
Reuses `org-format-latex-options' (scale, etc.) but pins the foreground to
the buffer's `default' face and uses a transparent background so the math
blends with the eww buffer."
  (require 'org)
  (org-combine-plists
   org-format-latex-options
   (list :foreground (momo/eww--default-foreground)
         :background nil)))

;;;###autoload
(defun momo/eww-render-math ()
  "Render LaTeX math fragments in the current eww buffer as images.
Scans for inline \\(..\\) and display \\[..\\] fragments (MathJax source
that eww cannot run) and overlays each with an image produced by the org
LaTeX-preview pipeline.  Re-running refreshes the overlays."
  (interactive)
  (unless (derived-mode-p 'eww-mode)
    (user-error "Not an eww buffer"))
  (require 'org)
  (let ((options (momo/eww--math-options))
        (type momo/eww-math-process)
        (count 0))
    (remove-overlays (point-min) (point-max) 'momo-eww-math t)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward momo/eww-math-regexp nil t)
        (let* ((beg (match-beginning 0))
               (end (match-end 0))
               (value (match-string-no-properties 0))
               (file (momo/eww--math-image-file value type options)))
          (when file
            (let ((img (create-image file
                                     (if (string-suffix-p ".svg" file) 'svg 'png)
                                     nil :ascent 'center))
                  (ov  (make-overlay beg end)))
              (overlay-put ov 'momo-eww-math t)
              (overlay-put ov 'display img)
              (overlay-put ov 'help-echo value)
              (overlay-put ov 'evaporate t)
              (cl-incf count))))))
    (when (called-interactively-p 'interactive)
      (message "eww math: rendered %d fragment%s" count
               (if (= count 1) "" "s")))
    count))

(defun momo/eww-render-math-maybe ()
  "Auto-render math when the eww URL matches `momo/eww-math-auto-url-regexp'.
Intended for `eww-after-render-hook'.  No-op when the regexp is nil."
  (let ((url (eww-current-url)))
    (when (and url momo/eww-math-auto-url-regexp
               (string-match-p momo/eww-math-auto-url-regexp url))
      (momo/eww-render-math))))

(add-hook 'eww-after-render-hook #'momo/eww-render-math-maybe)


;;;; Keybindings ----------------------------------------------------------

(add-hook 'eww-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-b") #'momo/eww-open-in-system-browser)
            (local-set-key (kbd "C-c C-o") #'eww-open-file)
            (local-set-key (kbd "C-c C-l") #'momo/eww-render-math)))

(provide 'eww-config)
;;; eww-config.el ends here

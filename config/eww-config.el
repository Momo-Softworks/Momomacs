;;; eww-config.el --- eww browser configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the built-in `eww' browser.  Two problems are solved
;; here for math-heavy pages (e.g. Paul's Online Math Notes,
;; tutorial.math.lamar.edu), which are opened from org links via C-c C-o:
;;
;;   1. Long navigation sidebars: eww renders site navigation linearly
;;      before the article, forcing a lot of scrolling.  We auto-apply
;;      `eww-readable' (reader mode) for those URLs so only the article
;;      body is shown.  `R' still toggles it manually anywhere.
;;
;;   2. LaTeX not rendering: those pages typeset math with MathJax, which
;;      is JavaScript and never runs in eww, so you see the raw source
;;      (e.g. "\\({\\mathbb{R}^3}\\)").  We post-process the eww buffer and
;;      replace each \\(..\\)/\\[..\\] fragment with an image rendered by the
;;      same org LaTeX-preview pipeline already used for org buffers.

;;; Code:

(require 'browse-url)
(require 'cl-lib)

(defgroup momo-eww nil
  "Momomacs tweaks for the eww browser."
  :group 'eww)

;; Use eww as the default browser for org-mode links and `browse-url'.
(setq browse-url-browser-function #'eww-browse-url)


;;;; Readable mode (strip navigation sidebars) -----------------------------

(with-eval-after-load 'eww
  ;; Auto-apply reader mode for these URLs.  Each entry is a regexp (or a
  ;; (regexp . readability) cons).  `R' toggles readable mode manually.
  (setq eww-readable-urls
        '("\\`https?://tutorial\\.math\\.lamar\\.edu/")))


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

(defcustom momo/eww-math-auto-url-regexp
  "\\`https?://tutorial\\.math\\.lamar\\.edu/"
  "Regexp of eww URLs whose LaTeX math is rendered automatically.
For any page whose URL matches, math is rendered after the page loads.
On other pages, render on demand with `momo/eww-render-math'
\(bound to \\`C-c C-l' in eww buffers)."
  :type 'regexp
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
Intended for `eww-after-render-hook'."
  (let ((url (eww-current-url)))
    (when (and url (string-match-p momo/eww-math-auto-url-regexp url))
      (momo/eww-render-math))))

(add-hook 'eww-after-render-hook #'momo/eww-render-math-maybe)


;;;; Foldable "Show Solution" sections (Paul's Online Math Notes) ----------

;; Paul's Notes hides each worked-example solution behind a JavaScript
;; "Show Solution" toggle: a <span class="soln-title"> ("Show Solution")
;; followed by a <div class="soln-content"> (the answer).  eww runs no
;; JavaScript, so the solutions are revealed immediately.  We detect those
;; nodes by DOM class, hide the solution body by default, and make "Show
;; Solution" a foldable toggle -- so you can attempt a problem first.

(require 'text-property-search)

(defconst momo/eww--soln-invisible 'momo-eww-soln
  "Symbol used in `buffer-invisibility-spec' to hide eww solution bodies.")

(defcustom momo/eww-hide-solutions t
  "When non-nil, fold \"Show Solution\" sections in eww (hidden by default).
Click or press RET/TAB on the \"Show Solution\" line to reveal a solution,
or toggle them all with `momo/eww-toggle-all-solutions' (\\`C-c C-s')."
  :type 'boolean
  :group 'momo-eww)

(defvar momo/eww-solution-toggle-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'momo/eww-toggle-solution)
    (define-key map (kbd "TAB") #'momo/eww-toggle-solution)
    (define-key map [mouse-1] #'momo/eww-toggle-solution)
    map)
  "Keymap active on an eww \"Show Solution\" toggle.")

;; --- Render-time tagging via shr (by DOM class) --------------------------

(defun momo/shr-tag-div (dom)
  "Render a <div>, tagging `soln-content' solution bodies for folding."
  (if (string-match-p "soln-content" (or (dom-attr dom 'class) ""))
      (let ((start (point)))
        (shr-tag-div dom)
        (put-text-property start (point) 'momo-eww-solution t))
    (shr-tag-div dom)))

(defun momo/shr-tag-span (dom)
  "Render a <span>, tagging the `soln-title' (\"Show Solution\") toggle."
  (let ((start (point)))
    (shr-generic dom)
    (when (string-match-p "soln-title" (or (dom-attr dom 'class) ""))
      (put-text-property start (point) 'momo-eww-soln-toggle t))))

(with-eval-after-load 'shr
  (add-to-list 'shr-external-rendering-functions '(div . momo/shr-tag-div))
  (add-to-list 'shr-external-rendering-functions '(span . momo/shr-tag-span)))

;; --- Folding overlays (post-render) --------------------------------------

(defun momo/eww--solution-arrow (hidden)
  "Return the fold indicator string for a solution; HIDDEN selects which."
  (propertize (if hidden "▸ " "▾ ") 'face 'shr-h5))

(defun momo/eww--set-solution (body hidden)
  "Show or hide the solution BODY overlay; HIDDEN non-nil hides it."
  (overlay-put body 'invisible (and hidden momo/eww--soln-invisible))
  (let ((tog (overlay-get body 'momo-eww-soln-toggle)))
    (when tog
      (overlay-put tog 'before-string (momo/eww--solution-arrow hidden)))))

(defun momo/eww--fold-one-solution (beg end)
  "Hide the solution body between BEG and END and wire up its toggle."
  (let ((body (make-overlay beg end))
        tbeg tend)
    (save-excursion
      (goto-char beg)
      (let ((m (text-property-search-backward 'momo-eww-soln-toggle t t)))
        (when m
          (setq tbeg (prop-match-beginning m)
                tend (prop-match-end m)))))
    (overlay-put body 'momo-eww-soln-body t)
    (overlay-put body 'evaporate t)
    (when (and tbeg tend)
      (let ((tog (make-overlay tbeg tend)))
        (overlay-put tog 'momo-eww-soln-toggle-ov t)
        (overlay-put tog 'momo-eww-soln-target body)
        (overlay-put body 'momo-eww-soln-toggle tog)
        (overlay-put tog 'keymap momo/eww-solution-toggle-map)
        (overlay-put tog 'mouse-face 'highlight)
        (overlay-put tog 'face 'link)
        (overlay-put tog 'help-echo "mouse-1/RET: show or hide this solution")))
    (momo/eww--set-solution body t)))

(defun momo/eww-fold-solutions ()
  "Hide \"Show Solution\" bodies in the current eww buffer.
Intended for `eww-after-render-hook'."
  (when momo/eww-hide-solutions
    (add-to-invisibility-spec momo/eww--soln-invisible)
    (let ((pos (point-min)))
      (while (setq pos (text-property-any pos (point-max) 'momo-eww-solution t))
        (let ((end (or (next-single-property-change pos 'momo-eww-solution)
                       (point-max))))
          (momo/eww--fold-one-solution pos end)
          (setq pos end))))))

(add-hook 'eww-after-render-hook #'momo/eww-fold-solutions)

;; --- Commands ------------------------------------------------------------

(defun momo/eww-toggle-solution (&optional event)
  "Toggle the solution whose \"Show Solution\" toggle is at point or EVENT."
  (interactive (list last-input-event))
  (let* ((pos (if (and (consp event) (event-end event))
                  (posn-point (event-end event))
                (point)))
         (tog (seq-find (lambda (o) (overlay-get o 'momo-eww-soln-toggle-ov))
                        (overlays-at pos)))
         (body (and tog (overlay-get tog 'momo-eww-soln-target))))
    (if (not body)
        (user-error "No solution toggle here")
      (momo/eww--set-solution body (not (overlay-get body 'invisible))))))

(defun momo/eww-toggle-all-solutions ()
  "Reveal all solutions if any are hidden, otherwise hide them all."
  (interactive)
  (let* ((bodies (seq-filter (lambda (o) (overlay-get o 'momo-eww-soln-body))
                             (overlays-in (point-min) (point-max))))
         (any-hidden (seq-some (lambda (o) (overlay-get o 'invisible)) bodies)))
    (if (null bodies)
        (message "No solutions on this page")
      (dolist (b bodies) (momo/eww--set-solution b (not any-hidden)))
      (message "%s all solutions" (if any-hidden "Revealed" "Hid")))))


;;;; Keybindings ----------------------------------------------------------

(add-hook 'eww-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-b") #'momo/eww-open-in-system-browser)
            (local-set-key (kbd "C-c C-o") #'eww-open-file)
            (local-set-key (kbd "C-c C-l") #'momo/eww-render-math)
            (local-set-key (kbd "C-c C-s") #'momo/eww-toggle-all-solutions)))

(provide 'eww-config)
;;; eww-config.el ends here

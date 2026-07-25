(use-package dirvish
  :after dired
  :config
  (dirvish-override-dired-mode)

  ;; Dirvish renders file previews by opening the file in a temporary buffer.
  ;; That path trips `openwith' — which launches mpv on media files — so merely
  ;; scrolling past a gif/video would spawn a player.  Bind `openwith's
  ;; association list empty for the duration of a preview; real opens (RET on a
  ;; media file) still hand off to the external player.  `dirvish-preview-
  ;; environment' is the same mechanism dirvish uses to quiet local variables.
  (add-to-list 'dirvish-preview-environment '(openwith-associations))

  ;; Dirvish's archive dispatcher (which shells out to 7z) keys on
  ;; `dirvish-archive-exts', but upstream lists "gzip"/"bzip2" rather than the
  ;; extensions files actually carry ("gz"/"tgz"/"bz2"/...).  Without these, a
  ;; .tar.gz falls through to the default dispatcher and jka-compr errors trying
  ;; to uncompress it.  Register the real extensions so 7z previews them and the
  ;; buffer path is never taken.
  (dolist (ext '("gz" "tgz" "bz2" "tbz2" "xz" "txz" "zst" "tzst" "lz" "lzma"))
    (add-to-list 'dirvish-archive-exts ext)
    (add-to-list 'dirvish-binary-exts ext))

  ;; Upstream's archive dispatcher runs `7z l -ba FILE'.  7z still prints its
  ;; scan progress indicator ("  0M Scan /path/...") ahead of the listing, which
  ;; shows up as a garbage first line in the preview.  `-bd' disables that
  ;; progress indicator; everything else matches upstream.  Redefining the
  ;; dispatcher here overrides `dirvish-widgets' cleanly, no source patch.
  (dirvish-define-preview archive (file ext)
    "Preview archive files.  Require: `7z' executable (`7zz' on macOS)."
    :require (dirvish-7z-program)
    (when (member ext dirvish-archive-exts)
      `(shell . (,dirvish-7z-program "l" "-ba" "-bd" ,file)))))

;;; openwith.el --- open media files in an external player -*- lexical-binding: t; -*-

;;; Commentary:
;; Makes RET (find-file) on a media file — in dired or anywhere — open it
;; in an external player instead of a buffer.  Override `momo-media-player'
;; (e.g. in the personal overlay's early.el) to point at a specific player
;; binary; `momo-media-extensions' controls which files are handed over.

;;; Code:

(defcustom momo-media-player "mpv"
  "External player command for media files opened via `openwith'."
  :type 'string
  :group 'momo)

(defcustom momo-media-player-args '("--keep-open=yes")
  "Arguments passed to `momo-media-player' before the file."
  :type '(repeat string)
  :group 'momo)

(defcustom momo-media-extensions
  '("mp4" "webm" "mkv" "mov" "avi" "m4v" "flv" "gif"
    "mp3" "m4a" "opus" "flac" "ogg" "wav")
  "File extensions opened with `momo-media-player'."
  :type '(repeat string)
  :group 'momo)

(use-package openwith
  :config
  (setq openwith-associations
        `((,(openwith-make-extension-regexp momo-media-extensions)
           ,momo-media-player (,@momo-media-player-args file))))
  (openwith-mode 1))

;;; openwith.el ends here

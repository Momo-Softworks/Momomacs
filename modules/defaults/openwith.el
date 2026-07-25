;;; openwith.el --- open media files in an external player -*- lexical-binding: t; -*-

;;; Commentary:
;; Makes RET (find-file) on a media file — in dired or anywhere — open it in an
;; external player instead of a buffer.  Override `momo-media-player' (e.g. in
;; the personal overlay's early.el) to point at a specific player binary;
;; `momo-video-extensions' / `momo-audio-extensions' control which files are
;; handed over.
;;
;; Video and audio are split so they can take different args: notably video can
;; be forced fullscreen via `momo-video-player-extra-args'.  This matters under
;; EXWM, where an external player is an X window that gets tiled into a split of
;; the current layout rather than replacing it; opening video fullscreen avoids
;; that.  On a normal window manager the player floats, so the default leaves it
;; windowed.

;;; Code:

(defcustom momo-media-player "mpv"
  "External player command for media files opened via `openwith'."
  :type 'string
  :group 'momo)

(defcustom momo-media-player-args '("--keep-open=yes")
  "Arguments passed to `momo-media-player' for all media (video and audio)."
  :type '(repeat string)
  :group 'momo)

(defcustom momo-video-player-extra-args '()
  "Extra args added after `momo-media-player-args' for video files only.
Empty by default (windowed).  Under EXWM the external player window is tiled
into a split of the current layout instead of replacing it; set this in your
overlay to e.g. \\='(\"--fullscreen\") so video takes over the screen.  Left off
audio so audio files do not open a black fullscreen window."
  :type '(repeat string)
  :group 'momo)

(defcustom momo-video-extensions '("mp4" "webm" "mkv" "mov" "avi" "m4v" "flv")
  "Video file extensions opened with `momo-media-player'.

Deliberately excludes image formats.  openwith works by intercepting
`insert-file-contents' for matching files (a \"\" `file-name-handler-alist'
entry), so anything that reads a matching file's bytes hands it to the player.
`gif' in particular is an image that `image-mode' re-reads on a timer to
animate/refit — which fires openwith outside Dirvish's synchronous preview
guard and spawns the player mid-browse.  Gifs animate fine in Emacs and Dirvish
previews, so they are left to `image-mode'."
  :type '(repeat string)
  :group 'momo)

(defcustom momo-audio-extensions '("mp3" "m4a" "opus" "flac" "ogg" "wav")
  "Audio file extensions opened with `momo-media-player'.
These never take `momo-video-player-extra-args' (e.g. fullscreen)."
  :type '(repeat string)
  :group 'momo)

(use-package openwith
  :config
  (setq openwith-associations
        `((,(openwith-make-extension-regexp momo-video-extensions)
           ,momo-media-player (,@momo-media-player-args ,@momo-video-player-extra-args file))
          (,(openwith-make-extension-regexp momo-audio-extensions)
           ,momo-media-player (,@momo-media-player-args file))))
  (openwith-mode 1))

;;; openwith.el ends here

;;; elfeed-setup.el --- Elfeed package setup and integration -*- lexical-binding: t; -*-

(with-eval-after-load 'elfeed
  (defun add-to-elfeed (value)
    (push value elfeed-feeds))

  (defun add-list-to-elfeed (url-list)
    (mapcar #'add-to-elfeed url-list))

  ;; Initialize elfeed-feeds if not already set
  (unless (boundp 'elfeed-feeds)
    (setq elfeed-feeds '()))
  
  (add-list-to-elfeed momo-rss-feeds)

  (defun elfeed-v-mpv (url)
    "Watch a video from URL in MPV and catch errors to display in minibuffer."
    (interactive)
    (message "Starting mpv, might take a moment...")
    (let ((process-connection-type nil)
          (proc (start-process "mpv" "*mpv-output*" "mpv" url)))
      (set-process-sentinel proc 'mpv-process-sentinel)))

  (defun mpv-process-sentinel (proc event)
    "Sentinel function for handling MPV process events."
    (when (string-match-p "exited abnormally" event)
      (message "mpv encountered an error: %s" event)))

  (defun elfeed-mpv-entry ()
    "Run the current entry link URL in mpv"
    (interactive)
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
	(elfeed-v-mpv link))))

  (defun elfeed-eww-entry ()
    "Run the current entry link URL in eww"
    (interactive)
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
	(eww link)))))

(with-eval-after-load 'elfeed-tube
  (defvar momo/youtube-channels-cache-file
    (expand-file-name "youtube-channels-cache.el" user-emacs-directory)
    "File to cache the last processed YouTube channels.")

  (defun create-youtube-url (channel)
    (concat "https://www.youtube.com/@" channel))

  (defun create-youtube-urls (channel-list)
    (mapcar #'create-youtube-url channel-list))

  (defun fetch-youtube-rss-url (url callback)
    "Fetch the RSS URL from a YouTube channel page asynchronously."
    (url-retrieve url (lambda (status callback)
			(unless (plist-get status :error)
			  (goto-char (point-min))
			  (when (re-search-forward "\"rssUrl\":\"\\(https://www\\.youtube\\.com/feeds/videos\\.xml\\?channel_id=[^\"]*\\)\"" nil t)
			    (when callback
			      (funcall callback (match-string 1))))))
                  (list callback)))

  (defun process-youtube-channel (url)
    "Fetch the RSS URL for a given YouTube channel URL."
    (fetch-youtube-rss-url url (lambda (rss-url)
				 (when rss-url
                                   (push rss-url elfeed-feeds)
                                   (message "Fetched RSS URL: %s" rss-url)))))

  (defun fetch-all-youtube-rss-urls ()
    "Fetch RSS URLs for all provided YouTube channel URLs."
    (interactive)
    (mapc #'process-youtube-channel (create-youtube-urls momo-youtube-channel-urls))
    (momo/save-youtube-channels-cache))

  (defun momo/youtube-channels-changed-p ()
    "Check if the YouTube channel list has changed since last fetch."
    (let ((cached-channels (momo/load-youtube-channels-cache)))
      (not (equal (sort (copy-sequence momo-youtube-channel-urls) #'string<)
                  (sort (copy-sequence cached-channels) #'string<)))))

  (defun momo/save-youtube-channels-cache ()
    "Save the current YouTube channel list to cache file."
    (with-temp-file momo/youtube-channels-cache-file
      (prin1 momo-youtube-channel-urls (current-buffer))))

  (defun momo/load-youtube-channels-cache ()
    "Load the cached YouTube channel list."
    (when (file-exists-p momo/youtube-channels-cache-file)
      (with-temp-buffer
        (insert-file-contents momo/youtube-channels-cache-file)
        (read (current-buffer)))))

  ;; Only fetch if channels have changed or cache doesn't exist
  (when (or (not (file-exists-p momo/youtube-channels-cache-file))
            (momo/youtube-channels-changed-p))
    (message "YouTube channel list changed, fetching RSS URLs...")
    (fetch-all-youtube-rss-urls)))

(provide 'elfeed-setup)
;;; elfeed-setup.el ends here

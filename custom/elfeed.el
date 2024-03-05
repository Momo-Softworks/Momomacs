;; -*- lexical-binding: t; -*-

(defvar youtube-channel-urls '("Kyle.Gabriel"
                               "Orthocast"
                               "MentisWave"
                               "Vercidium"
                               "DyerClips"
                               "ThePrimeagen"
                               "esorem"
                               "NewWorldReview"
                               "AtomicFrontier"
                               "orthodoxmemesquad503"
                               "VinceVintage"
                               "MentalOutlaw"
                               "Memology101"
                               "BlacktailStudio"
                               "Seraphim-Hamilton"
                               "joshbetts1022"
                               "aarthificial"
                               "LetsTalkReligion"
                               "TwoMinutePapers"
                               "JohnDoyle"
                               "redeemedzoomer6053"
                               "MicTheSnare"
                               "TechnoTim"
                               "GavinFreeborn"
                               "Exercise4CheatMeals"
                               "ZacBuilds"
                               "SebastianLague"
                               "veritasium"
                               "JoshuaWeissman"
                               "OrthodoxKyle"
                               "BrodieRobertson"
                               "TheLinuxEXP"
                               "CleoAbram"
                               "BibleIllustrated"
                               "EmperorLemon"
                               "Patristix"
                               "bycloudAI"
                               "EthanChlebowski"
                               "harmonyharmonyharmony"
                               "kurzgesagt"
                               "SystemCrafters"
                               "TheRubber"
                               "PatristicNectarFilms"
                               "living_orthodox"
                               "emacselements"
                               "Fireship"
                               "MarkRober"
                               "AIandGames"
                               "abcdw"
                               "TastingHistory"
                               "OrthodoxEthos"
                               "ChurchoftheEternalLogos"
                               "NoBoilerplate"
                               "t3ssel8r"
                               "aiexplained-official"
                               "dreamsofcode"
                               "JayDyer"
                               "PolyMatter"
                               "StosselTV"
                               "andiswerkstatt-ow4uw"
                               "DIYPerks"
                               "jubilee"
                               "QuantaScienceChannel"
                               "LinusTechTips")
  "List of YouTube channel URLs to process.")

(defun create-youtube-url (channel)
  (concat "https://www.youtube.com/@" channel))

(defun create-youtube-urls (channel-list)
  (mapcar #'create-youtube-url channel-list))

(defun add-to-elfeed (value)
  (push value elfeed-feeds))

(defun add-list-to-elfeed (url-list)
  (mapcar #'add-to-elfeed url-list))

(defun fetch-youtube-rss-url (url callback)
  "Fetch the RSS URL from a YouTube channel page asynchronously."
  (url-retrieve url                (lambda (status callback)
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
  (mapc #'process-youtube-channel (create-youtube-urls youtube-channel-urls)))

(fetch-all-youtube-rss-urls)

(setq twitter-feeds '("https://rsshub-production-7458.up.railway.app/twitter/user/crazyclipsonly/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/GlobalOrthodox/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/FrankHassleYT/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/Gentilenewsnet/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/wigger/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/DudespostingWs/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/WomenPostingLs/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/Tomhennessey69/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/OrthodoxEthos/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/banterwithb/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/lporiginalg/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/GarbageHuman23/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/Jay_D007/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/iamyesyouareno/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/AnaniasFather/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/MomsPostingLs/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/RealBroNat/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/Muhsoci0factors/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/reddit_lies/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/PicturesFoIder/readable=1&showAuthorInTitle=1"
		      "https://rsshub-production-7458.up.railway.app/twitter/user/FAFO_TV/readable=1&showAuthorInTitle=1"))


(add-list-to-elfeed twitter-feeds)

(add-to-elfeed "https://boards.4channel.org/g/index.rss")

(defun elfeed-v-mpv (url)
  "Watch a video from URL in MPV and catch errors to display in minibuffer."
  (interactive)
  (message "Starting mpv, might take a moment...")
  (let ((process-connection-type nil)
        (proc (start-process "mpv" "*mpv-output*" "mpv" url))) ; Corrected line
    ;; Set a sentinel for the process
    (set-process-sentinel proc 'mpv-process-sentinel)))

(defun mpv-process-sentinel (proc event)
  "Sentinel function for handling MPV process events."
  (when (string-match-p "exited abnormally" event)
    ;; When the process exits with an error, display a message in the minibuffer
    (message "mpv encountered an error: %s" event)))

(defun elfeed-mpv-entry ()
  "Run the current entry link URL in mpv"
  (interactive)
  (let ((link (elfeed-entry-link elfeed-show-entry)))
    (when link
      (elfeed-v-mpv link))))

(setq mailcap-user-mime-data
      '((("mpv %s" "video/webm" nil))))

(defun elfeed-eww-entry ()
  "Run the current entry link URL in eww"
  (interactive)
  (let ((link (elfeed-entry-link elfeed-show-entry)))
    (when link
      (eww link))))

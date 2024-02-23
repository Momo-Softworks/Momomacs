(defgroup momo nil
  "Momo parent group"
  :prefix "momo-"
  :group 'emacs)

(defcustom use-guix nil
  "Whether or not to use Guix as the primary project manager for Emacs"
  :type 'boolean
  :group 'momo)

(defcustom projects (list (concat (getenv "HOME") "/Projects"))
  "Location of your projects"
  :type 'list
  :group 'momo)

(defcustom roam-directory (concat (getenv "HOME") "/Documents/Roam")
  "Location of your org-roam"
  :type 'string
  :group 'momo)

(defcustom capture-directory (concat (getenv "HOME") "/Documents/Org")
  "Location of your org captures"
  :type 'string
  :group 'momo)

(unless (file-directory-p capture-directory)
  (make-directory capture-directory 1))

(unless (file-directory-p roam-directory)
  (make-directory capture-directory 1))

(if (package-installed-p 'elfeed-tube)
  (elfeed-tube-add-feeds '("Veritasium"
                         "Tom Scott"
                         "System Crafters")))

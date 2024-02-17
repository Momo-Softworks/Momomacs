(defgroup momo nil
  "Momo parent group"
  :prefix "momo-"
  :group 'emacs)

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

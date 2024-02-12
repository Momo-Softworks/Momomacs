(defgroup momo nil
  "Momo parent group"
  :prefix "momo-"
  :group 'emacs)

(defcustom projects (list (concat (getenv "HOME") "/Projects"))
  "Location of your projects"
  :type 'list
  :group 'momo)

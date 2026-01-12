;;; elfeed.el --- Elfeed RSS reader configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Elfeed RSS reader with YouTube integration via elfeed-tube.

;;; Code:

(use-package elfeed
  :demand t)

;; Optional YouTube integration

(use-package elfeed-tube
  :after elfeed
  :demand t
  :config
  (elfeed-tube-setup)

  :bind (:map elfeed-show-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)))


(use-package elfeed-tube-mpv
  :bind (:map elfeed-show-mode-map
              ("C-c C-f" . elfeed-tube-mpv-follow-mode)
              ("C-c C-w" . elfeed-tube-mpv-where)))

(provide 'elfeed)
;;; elfeed.el ends here

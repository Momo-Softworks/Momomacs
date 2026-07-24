;;; momomacs/packages/fonts.scm --- Fonts Momomacs uses that upstream Guix
;;; does not provide.  Referenced as variables from (momomacs packages) so
;;; they ride along with the package set in every consumption mode.

(define-module (momomacs packages fonts)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)   ;unzip (release asset is a .zip)
  #:export (font-geist))

(define font-geist
  (package
    (name "font-geist")
    (version "1.7.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/vercel/geist-font/releases/download/v"
             version "/geist-font-v" version ".zip"))
       (sha256
        (base32 "1qh45fw3mf5kg57w8w6v2m682pd5mi0m0vhrjm4894kbmk901j3z"))))
    (build-system font-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          ;; Keep just Geist + Geist Mono in installable outline formats; drop
          ;; the pixel family and the web (woff/woff2) copies the browser uses.
          (add-after 'unpack 'prune
            (lambda _
              (for-each (lambda (d)
                          (when (file-exists? d) (delete-file-recursively d)))
                        '("GeistPixel" "Geist/webfonts" "GeistMono/webfonts"
                          "geist-font/GeistPixel"
                          "geist-font/Geist/webfonts"
                          "geist-font/GeistMono/webfonts")))))))
    (native-inputs (list unzip))
    (home-page "https://vercel.com/font")
    (synopsis "Geist and Geist Mono typefaces by Vercel")
    (description "Geist is a sans-serif typeface family designed by Vercel with
basement.studio for developer tools and design work; Geist Mono is its
monospace companion.  This package installs the static, italic, and variable
TrueType and OpenType files for both families.")
    (license license:silofl1.1)))

;;; momomacs/packages/emacs.scm --- Emacs packages Momomacs needs that Guix
;;; does not (yet) provide.  Referenced as variables from (momomacs packages)
;;; so they ride along with the spec list in every consumption mode.
;;;
;;; Versioning: git-version snapshots pinned to the exact commit built
;;; against, upstream's Version header as the base.  To bump: update commit +
;;; hash (guix hash -rx <checkout>) and revision.

(define-module (momomacs packages emacs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages emacs-build)  ;emacs-dash/s/f/compat
  #:use-module (gnu packages emacs-xyz)
  #:export (emacs-language-detection
            emacs-shrface
            emacs-dired-hide-dotfiles
            emacs-eca
            emacs-packwiz))

(define emacs-language-detection
  (let ((commit "54a6ecf55304fba7d215ef38a4ec96daff2f35a4")
        (revision "0"))
    (package
      (name "emacs-language-detection")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/andreasjansson/language-detection.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0p8kim8idh7hg9398kpgjawkxq9hb6fraxpamdkflg8gjk0h5ppa"))))
      (build-system emacs-build-system)
      (home-page "https://github.com/andreasjansson/language-detection.el")
      (synopsis "Automatic programming-language detection of code snippets")
      (description "This package detects the programming language of a code
snippet using a pre-trained classifier.  It is used by shrface and eww to
pick the right major mode for fontifying code blocks in HTML buffers.")
      (license license:gpl3+))))

(define emacs-shrface
  (let ((commit "9016f3d7276c29feeb49337f765d9fa5f889adf0")
        (revision "0"))
    (package
      (name "emacs-shrface")
      (version (git-version "2.6.5" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/chenyanming/shrface")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0s8m3l2xphkcpvpjh2ads1p5kfasn8aja1xzbbhzlq96cm3yrxaa"))))
      (build-system emacs-build-system)
      (propagated-inputs (list emacs-language-detection))
      (home-page "https://github.com/chenyanming/shrface")
      (synopsis "Org-like faces and outline navigation for shr/eww buffers")
      (description "shrface extends shr and shr-based renderers (eww, nov.el,
mu4e, ...) with Org-like styling: headline faces with levels, bullets,
versatile links, code-block fontification (via language-detection), and
outline/imenu navigation.")
      (license license:gpl3+))))

(define emacs-dired-hide-dotfiles
  (let ((commit "0d035ba8c5decc5957d50f3c64ef860b5c2093a1")
        (revision "0"))
    (package
      (name "emacs-dired-hide-dotfiles")
      (version (git-version "0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/mattiasb/dired-hide-dotfiles")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0c2qb2jnwzgv55qki4lciik6xm32xj1w183ngv7gy4inmr5shz4h"))))
      (build-system emacs-build-system)
      (home-page "https://github.com/mattiasb/dired-hide-dotfiles")
      (synopsis "Minor mode to hide dotfiles in Dired")
      (description "This package provides @code{dired-hide-dotfiles-mode}, a
minor mode that hides dotfiles in Dired buffers, with a toggle command.")
      (license license:gpl3+))))

(define emacs-eca
  (let ((commit "7361d5dc849c1973ec5a97d5371b86201c42ebcb")
        (revision "0"))
    (package
      (name "emacs-eca")
      (version (git-version "0.0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/editor-code-assistant/eca-emacs")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "07nyhqr36ghx1srx9dj5b11s971xk8f6i4ak8vm0ar9a4hf8hk9w"))))
      (build-system emacs-build-system)
      (propagated-inputs
       (list emacs-dash emacs-s emacs-f emacs-markdown-mode emacs-compat))
      (home-page "https://github.com/editor-code-assistant/eca-emacs")
      (synopsis "Emacs client for ECA, the Editor Code Assistant")
      (description "eca-emacs is the Emacs front-end for ECA (Editor Code
Assistant), an editor-agnostic AI pair-programming server: chat, context
management, and tool-call integration inside Emacs.  The eca server binary is
distributed separately.")
      (license license:asl2.0))))

(define emacs-packwiz
  (let ((commit "1be0b37a943516262b6214959576a1ac94e9cb35")
        (revision "0"))
    (package
      (name "emacs-packwiz")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/chubbymomo/packwiz.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1782fjl7r225cby6wyw41gawjpyn3imn0yxrnjrag4p2gf715a6k"))))
      (build-system emacs-build-system)
      (propagated-inputs (list emacs-transient))
      (home-page "https://github.com/chubbymomo/packwiz.el")
      (synopsis "Emacs front-end for the packwiz Minecraft modpack manager")
      (description "packwiz.el is a native Emacs interface to the packwiz
Minecraft modpack CLI: a transient command tree, a mod browser with
CurseForge/Modrinth/GitHub search, per-project catalogue triage, and a
serve/install/launch test loop.  The packwiz binary itself is a separate
package.")
      (license license:gpl3+))))

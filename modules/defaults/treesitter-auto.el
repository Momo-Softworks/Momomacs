(use-package treesit-auto
  :config
  (global-treesit-auto-mode)
  ;; Never prompt to download/compile a grammar on the fly.  Dirvish previews
  ;; open each file in a real buffer, so `prompt' asks to install a grammar for
  ;; every file browsed; `t' would silently compile them mid-browse (needs a
  ;; toolchain + network).  `nil' falls back cleanly to the non-treesit mode.
  ;; Install grammars deliberately instead — `M-x treesit-auto-install-all', or
  ;; the tree-sitter-* Guix packages.
  (setq treesit-auto-install nil))

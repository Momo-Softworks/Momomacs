(use-package copilot
  :after jsonrpc
  :ensure (:repo "copilot-emacs/copilot.el"
                 :host github
                 :files ("dist" "*.el")))

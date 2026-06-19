(use-package envrc
  ;; Enable late, after other env-manipulating modes, per envrc's own advice.
  :hook (after-init . envrc-global-mode))

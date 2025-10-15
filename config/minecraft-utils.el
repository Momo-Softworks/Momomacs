;;; minecraft-utils.el --- Minecraft project utilities -*- lexical-binding: t; -*-

(with-eval-after-load 'projectile
  (defun momo/minecraft-prepare-runs ()
    (interactive)
    (projectile-run-async-shell-command-in-root "./gradlew prepareRuns"))

  (defun momo/minecraft-run-client ()
    (interactive)
    (projectile-run-async-shell-command-in-root "./gradlew runClient"))

  (defun momo/minecraft-run-server ()
    (interactive)
    (projectile-run-async-shell-command-in-root "./gradlew runServer"))

  (defun momo/minecraft-build-jar ()
    (interactive)
    (projectile-run-async-shell-command-in-root "./gradlew jar")))

(provide 'minecraft-utils)
;;; minecraft-utils.el ends here

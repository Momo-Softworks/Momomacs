(add-to-list 'system-packages-supported-package-managers
             '(yay .
                      ((default-sudo . nil)
                       (install . "yay -S")
                       (search . "yay -Ss")
                       (uninstall . "yay -Rs")
                       (update . "yay -Syu")
                       (clean-cache . "yay -Sc")
                       (log . "cat /var/log/pacman.log")
                       (change-log . "yay -Qc")
                       (get-info . "yay -Qi")
                       (get-info-remote . "yay -Si")
                       (list-files-provided-by . "yay -Ql")
                       (owning-file . "yay -Qo")
                       (owning-file-remote . "yay -F")
                       (verify-all-packages . "yay -Qkk")
                       (verify-all-dependencies . "yay -Dk")
                       (remove-orphaned . "yay -Rns $(pacman -Qtdq)")
                       (list-installed-packages . "yay -Qe")
                       (list-installed-packages-all . "yay -Q")
                       (list-dependencies-of . "yay -Qi")
                       (noconfirm . "--noconfirm"))))

(setq system-packages-package-manager 'yay)
(setq system-packages-use-sudo nil)
(setq system-packages-noconfirm t)
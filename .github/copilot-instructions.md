# Copilot Instructions for Momomacs

## Repository Overview

Momomacs is a modular Emacs configuration designed for efficiency and customization. It uses Elpaca as the primary package manager with optional Guix support.

## Project Structure

### Root Files
- `init.el` - Main initialization file that loads all modules in sequence
- `early-init.el` - Early initialization (runs before GUI initialization)
- `momo.el` - Configuration loader that loads config modules from `config/`
- `manifest.scm` - Guix package manifest for Guix users

### Directories

#### `config/`
User configuration files and utilities:
- `user-config.el` - Core user customization variables (defcustom definitions)
- `exwm-config.el` - EXWM window manager configuration
- `elfeed-config.el` - RSS and YouTube feed configurations
- `elfeed-setup.el` - Elfeed package setup
- `project-utils.el` - Project creation utilities
- `desktop-launcher.el` - Desktop application launcher
- `minecraft-utils.el` - Minecraft-specific project utilities
- `org-config.el` - Org-mode capture and refile configuration
- `settings.el` - General Emacs settings
- `keybindings.el` - Keybinding definitions

#### `modules/`
Package-specific configuration organized by category:
- `UI/` - User interface packages (doom-modeline, modus-themes, dashboard)
- `completions/` - Completion frameworks (vertico, corfu, orderless)
- `defaults/` - Default packages loaded automatically via `momo/load-defaults`
- `file-handling/` - File management (pdf-tools, dirvish)
- `keybindings/` - Keybinding packages (meow, which-key)
- `libraries/` - Library packages (transient)
- `org/` - Org-mode extensions (modern, roam, fragtog)
- `programming/` - Programming language support (racket, java, copilot, flycheck, rainbow-delimiters)
- `project-management/` - Project tools (magit, projectile)
- `social/` - Social/feed readers (elfeed)
- `system/` - System integration (exwm, eat)
- `utils/` - Utility functions and package managers (elpaca, guix, loaders, helpers)

## Coding Conventions

### Emacs Lisp Style
- Always use `lexical-binding: t` in file headers
- Follow standard Emacs Lisp file header format:
  ```elisp
  ;;; filename.el --- Description -*- lexical-binding: t; -*-
  ```
- End files with:
  ```elisp
  (provide 'module-name)
  ;;; filename.el ends here
  ```
- Use 2-space indentation
- Prefix custom functions and variables with `momo/` or package-specific prefix
- Define customization groups under `momo` parent group

### Package Configuration
- Use `use-package` macro for package configuration
- Structure package configs simply and clearly:
  ```elisp
  (use-package package-name
    :config
    (configuration-here))
  ```
- For Guix compatibility, wrap non-Guix packages:
  ```elisp
  (unless use-guix
    (use-package package-name
      :ensure (:repo "..." :host github)))
  ```

### Module Organization
- Each package should have its own `.el` file in the appropriate category directory
- Default packages (always loaded) go in `modules/defaults/`
- Optional packages go in category-specific directories (e.g., `modules/programming/`)
- New packages must be registered in `momo/packages-alist` in `modules/utils/loaders.el`

### Loading System
- `momo/load-packages` - Load specific packages from the alist
- `momo/load-defaults` - Automatically load all files from `modules/defaults/`
- `momo/load` - Load a specific module by relative path from `modules/`
- Packages are loaded in `init.el` using `momo/load-packages` with a list of symbols

## Key Variables
- `use-guix` - Boolean flag for Guix integration (default: nil)
- `projects` - List of project directories
- `roam-directory` - Org-roam notes location
- `capture-directory` - Org capture files location
- `momo/packages-alist` - Mapping of package symbols to file paths

## Dependencies
- the-silver-searcher (ag) - Required for code search
- jdtls - Java language server (for Java development)

## Adding New Packages

1. Create a new `.el` file in the appropriate `modules/` subdirectory
2. Use `use-package` for configuration
3. Add the package to `momo/packages-alist` in `modules/utils/loaders.el`:
   ```elisp
   (package-name . "category/package-name")
   ```
4. Add the package symbol to the load list in `init.el`

## Testing Changes
- Test Emacs configuration by launching Emacs: `emacs -Q -l init.el`
- Check for errors in `*Messages*` buffer
- Verify package loading with `M-x list-packages` or `M-x elpaca-manager`

## Common Patterns

### Hooks
```elisp
(add-hook 'mode-name-hook 'function-to-call)
(add-hook 'mode-name-hook #'function-to-call)  ; Preferred with sharp quote
```

### Mode Activation
```elisp
(package-mode)           ; Enable in current buffer
(global-package-mode 1)  ; Enable globally
```

### Keybindings
- Custom keybindings defined in `config/keybindings.el`
- Uses Meow modal editing (vim-like but different)
- Leader key and modal bindings defined in `modules/keybindings/meow.el`

## Important Notes
- Elpaca is the package manager, not package.el or straight.el
- The configuration supports both Elpaca and Guix package management
- `elpaca-wait` is used to ensure packages are installed before configuration
- Some built-in packages (seq, jsonrpc, transient) need special unload handling with Elpaca
- The configuration is designed to work without an internet connection once packages are installed

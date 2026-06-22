# Guix packaging TODO — Emacs packages not yet in Guix

Momomacs can run as either an Elpaca config (default on non-Guix machines) or a
Guix config (`momo-use-guix` t, auto-detected on Guix System). In Guix mode,
packages come from `manifest.scm`; anything Guix doesn't provide is **fetched
automatically via Elpaca as a fallback** (see `modules/utils/guix.el`), so the
editor still works today.

The packages below are the remaining gap: they are referenced by the config but
are **not in upstream Guix**, so on a Guix machine they currently come from
Elpaca rather than the reproducible Guix profile. Packaging them (e.g. in the
Momo channel) and moving them into `manifest.scm` would make Guix members fully
reproducible. Until then, no action is required — the fallback covers them.

| Package | Used by | Upstream (verify) | Notes |
|---|---|---|---|
| `emacs-shrface` | `modules/file-handling/shrface.el` | github: `chenyanming/shrface` | Readable shr/eww + org rendering. Pulls `shr-tag-pre-highlight`. |
| `emacs-dired-hide-dotfiles` | `modules/defaults/dired-hide-dotfiles.el` | github: `mattiasb/dired-hide-dotfiles` | Tiny single-file package; easy first one to package. |
| `emacs-elfeed-tube-mpv` | `modules/social/elfeed.el` | github: `karthink/elfeed-tube` | `elfeed-tube` itself **is** in Guix; the `-mpv` companion file isn't packaged separately. Likely just add `elfeed-tube-mpv.el` to the existing `emacs-elfeed-tube` package (needs `emacs-mpv`). |
| `emacs-eca` | `modules/programming/eca.el` | github: `editor-code-assistant/eca-emacs` (verify) | Editor Code Assistant client. Also relies on a vendored `~/.emacs.d/eca/eca` server binary, which is independent of the elisp package. |
| `emacs-packwiz` | `modules/gaming/packwiz.el` | github: `chubbymomo/packwiz.el` | Momo's own package (recipe already pinned in the module). Natural fit for the Momo channel. |

## How to retire an entry

1. Package it for Guix (define the package; for Momo-owned ones, add to the Momo
   channel).
2. Add its `emacs-<name>` spec to `manifest.scm`.
3. Done — `guix.el` will then see it on `load-path` and automatically stop
   routing it through Elpaca (no code change needed).

## Notes / non-gaps

- `emacs-eglot` is in the manifest but Emacs ships eglot built-in; the manifest
  entry only shadows it with a newer version. Drop it if not needed.
- `f`, `transient`, `shrink-path` are installed via Elpaca on purpose (newer than
  Emacs/Guix ship); see `modules/utils/elpaca.el`. Not gaps.
- `emacs-dirvish` is in the manifest but not currently loaded by `init.el`
  (mapped in `loaders.el` but never passed to `momo/load-packages`).
</content>

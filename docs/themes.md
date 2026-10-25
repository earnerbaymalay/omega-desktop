# Theme & appearance

Omega is a Catppuccin-Mauve (Mocha) desktop. The repo ships **configuration only** —
no theme binaries or assets. Install the theme/icon packages below from your
distro or the upstream projects, then the XFCE configs in `config/` will pick
them up.

## Active look

| Slot | Name |
|------|------|
| GTK / application theme | `catppuccin-mocha-mauve-standard+default` |
| Window manager (xfwm4) | `Catppuccin-Mauve-Dark` |
| Icon theme | `Papirus-Dark` |
| Cursor theme | `catppuccin-mocha-mauve-cursors` |
| Interface font | `Inter 10` |
| Secondary icon set | `Hatter-Purple` |

## Where to get them

- **Catppuccin GTK** — <https://github.com/catppuccin/gtk> (flavour: mocha, accent: mauve).
- **Catppuccin xfwm4** — <https://github.com/catppuccin/xfwm4> (`Catppuccin-Mauve-Dark`).
- **Catppuccin cursors** — <https://github.com/catppuccin/cursors> (`mocha-mauve`).
- **Papirus** — your distro's `papirus-icon-theme` package.
- **Inter** — your distro's `inter-font` / `ttf-inter` package.

## Applying

The relevant keys live in `config/.config/xfce4/xfconf/xfce-perchannel-xml/`:

- `xsettings.xml` → GTK theme, icon theme, cursor, font.
- `xfwm4.xml` → window-manager theme.

`install.sh` symlinks these into place (backing up any existing files as `*.bak`).
Log out and back in, or run `xfce4-panel -r`, after installing the packages.

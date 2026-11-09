# spine-tweaks

English | [日本語](README.ja.md)

Styling for Tern's Spine chat (omp conversations):

- Your own picture as your avatar.
- A tinted, rounded background behind your messages.

## Install

```sh
tern plugin install github.com/ryosuz/tern/plugins/spine-tweaks
```

## Your avatar

Nothing replaces the avatar until you choose a picture. Run **Spine Tweaks:
choose avatar…** from the palette and enter the path of a PNG, JPEG, GIF or
WebP picture, up to 512 KiB. A square picture of about 256 px works best.

The plugin copies the picture to its data folder as `avatar`:

| OS | Data folder |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/spine-tweaks/` |
| Linux | `~/.local/state/tern/plugin-data/spine-tweaks/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\spine-tweaks\` |

Updating or reinstalling the plugin doesn't touch that folder, so the picture
stays. **Spine Tweaks: clear avatar** removes it, and the avatar goes back to
Tern's own. If you put a file there by hand, reload plugins to apply it.

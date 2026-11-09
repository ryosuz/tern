# spine-tweaks

English | [日本語](README.ja.md)

Make your side of Tern's Spine chat (omp conversations) look like yours:

- Your own picture as your avatar.
- A tinted, rounded background behind your messages, so they stand out from
  the replies.

It only changes the Spine chat style. To use it, choose **Chat style: Spine**
from the palette.

## Install

```sh
tern plugin install github.com/ryosuz/tern/plugins/spine-tweaks
```

The message background applies right away. The avatar stays Tern's own until
you choose a picture.

## Set your avatar

1. Run **Spine Tweaks: choose avatar…** from the palette.
2. Enter the path of a PNG, JPEG, GIF or WebP picture, up to 512 KiB
   (`~/…` works). A square picture of about 256 px looks best.

The avatar changes at once. To go back to Tern's own avatar, run **Spine
Tweaks: clear avatar**.

## Commands

All are in the palette under **Spine Tweaks**.

| Command | Does |
| --- | --- |
| Spine Tweaks: choose avatar… | Uses a picture as your avatar |
| Spine Tweaks: clear avatar | Goes back to Tern's own avatar |

## Where your picture is kept

The plugin keeps a copy of your picture, named `avatar`, in its data folder:

| OS | Data folder |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/spine-tweaks/` |
| Linux | `~/.local/state/tern/plugin-data/spine-tweaks/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\spine-tweaks\` |

It stays when you update or reinstall the plugin, so there's no need to set
it again. You can also put a picture there yourself as `avatar`; run
**Reload plugins** to apply it.

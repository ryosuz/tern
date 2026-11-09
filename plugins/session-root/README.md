# session-root

English | [日本語](README.ja.md)

Give each Tern session its own root directory. Once a session has one, new
tabs in it open there instead of wherever you happened to be.

Handy when each session is a project: a new tab in the `api` session starts in
the api repository, a new tab in `web` starts in the web repository.

## Install

```sh
tern plugin install github.com/ryosuz/tern/plugins/session-root
```

## Quick start

1. Switch to the session and `cd` to the project's directory.
2. Run **Session root: use this directory** from the palette.
3. Press ⌘T, or the + on the session's row in the tab list: the tab opens in
   that directory.

To start a fresh session for a project, run **New session at directory…** and
enter the path. The session is named after the folder and rooted there.

## Commands

All are in the palette under **Session Root**.

| Command | Does |
| --- | --- |
| Session root: use this directory | Makes the focused pane's directory the current session's root |
| Session root: set… | Asks for the root (an absolute path or `~/…`) |
| Session root: clear | Removes the current session's root |
| New session at directory… | Creates a session for a directory, with that directory as its root |

## What opens at the root

- New Tab: ⌘T, the toolbar's +, and the palette.
- The + on a session's row in the vertical tab list.

Splits still open in the current pane's directory. Sessions without a root
behave as usual.

## Where roots are kept

In the plugin's data folder, as `kv.json`:

| OS | Data folder |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/session-root/` |
| Linux | `~/.local/state/tern/plugin-data/session-root/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\session-root\` |

Roots survive updating or reinstalling the plugin. Renaming a session keeps
its root, and closing a session removes it.

## Known limitations

- **A brief flicker with the session row's +.** That button opens the tab in
  the old directory first; the plugin then swaps it for one at the root.
- **Tabs opened from another window** on the same session don't move to the
  root.
- **Remote hosts.** A root on a remote host isn't checked for existence, so a
  typo is saved as typed.
- **Renaming a session while Tern is closed** loses its root. Set it again.

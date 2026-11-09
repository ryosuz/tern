# session-root

English | [日本語](README.ja.md)

Gives each Tern session a root directory. New tabs in a session that has a
root open there.

| Where a tab opens from | How it reaches the root |
| --- | --- |
| New Tab (⌘T, the toolbar's +, the palette) | `tern.override("new_tab")` opens it at the root |
| The + on a session's row in the vertical tab list | That button doesn't run New Tab: it opens a shell in the directory of the session's focused pane. `tab_created` notices the tab and replaces it with one at the root, in the same position |

Splits keep Tern's usual behavior.

## Commands

All are in the palette under **Session Root**.

| Command | Does |
| --- | --- |
| Session root: use this directory | The focused pane's directory becomes the current session's root |
| Session root: set… | Asks for the root (absolute path or `~/…`) |
| Session root: clear | Drops the current session's root |
| New session at directory… | Asks for a directory and creates a session named after it, rooted there |

## Storage

Roots live in `tern.kv` (`<state>/plugin-data/session-root/kv.json`) under
the key `sessions`, nested by scope, then session name:

```json
{
  "sessions": {
    "local": { "LMS": { "root": "/path/to/lms", "id": 51539607557 } },
    "remote:dev.example.com": { "api": { "root": "/srv/api" } }
  }
}
```

Because the scope and the name are separate levels, a local session and a
remote session never share a key, whatever they are called. Each entry also
remembers the session's id. On `window_start` the plugin refreshes those ids,
so a rename during a run keeps the root.

A session's root is removed when the session ends:

- **While a window runs.** `session_ended` removes it (when both the id and
  the name match).
- **While no window runs** (for example `tern kill session`). The next
  `window_start` removes local roots whose session no longer exists. Roots
  on remote hosts stay, since their host may not be attached yet.

## Install

From the repository root:

```sh
tern plugin link plugins/session-root
```

A linked plugin reloads every time you save. `tern plugin unlink session-root` removes it.

For type checking with luau-lsp, generate `tern.d.luau` (not committed) and
regenerate it after a Tern update:

```sh
tern plugin types plugins/session-root
```

## Limits

- **The + button.** Replacing the tab starts a shell and closes it right
  away. Only a single shell tab that took the focused pane's directory is
  replaced. Tabs another plugin opens in a directory of its own choosing
  (for example `cx.layout:new_tab({cwd = ...})`) are left alone.
- **Tabs opened outside the window.** A tab created by another window on
  the same session fires no `tab_created` here, so it doesn't move to the
  root. Tabs from Carly or `tern` CLI scripts haven't been tested.
- **Remote hosts.** The plugin checks that a root exists only on this
  machine. On a remote host the path is stored as typed.
- **Renames across a Tern restart.** Session ids aren't trusted across
  restarts. A session renamed while its window was closed loses its root.

# tern

English | [日本語](README.ja.md)

Plugins for [Tern](https://stencil.so/tern), one folder each under `plugins/`.

| Plugin | What it does |
| --- | --- |
| [session-root](plugins/session-root) | Gives each session a root directory that new tabs open in |
| [spine-tweaks](plugins/spine-tweaks) | Your own avatar and a message background in Spine chats |
| [spine-caret-fix](plugins/spine-caret-fix) | A personal workaround for the Spine editor's caret; not meant for others |

Install one by its folder:

```sh
tern plugin install github.com/ryosuz/tern/plugins/session-root
```

Each plugin's README explains how to use it.

## Development

Clone the repository and link the plugin you're working on, from the
repository root. Tern then loads it from your checkout and reloads it every
time you save:

```sh
tern plugin link plugins/session-root
```

A plugin that is already installed must be removed first
(`tern plugin remove session-root`). To stop using the checkout, run
`tern plugin unlink session-root`.

For type checking with luau-lsp, generate `tern.d.luau` in the plugin's
folder and add it to luau-lsp's `luau-lsp.types.definitionFiles` setting.
The file is ignored by git; generate it again after updating Tern.

```sh
tern plugin types plugins/session-root
```

Plugin API: <https://docs.stencil.so/tern/>.

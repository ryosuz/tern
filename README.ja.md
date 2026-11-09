# tern

[English](README.md) | 日本語

[Tern](https://stencil.so/tern) のプラグイン集です。`plugins/` の下にプラグインごとのフォルダがあります。

| プラグイン | 内容 |
| --- | --- |
| [session-root](plugins/session-root) | セッションごとに root ディレクトリを決め、新しいタブをそこで開く |
| [spine-tweaks](plugins/spine-tweaks) | Spine 形式のチャットで、自分のアバター画像とメッセージ背景を設定する |
| [spine-caret-fix](plugins/spine-caret-fix) | Spine の入力欄のカーソル位置を直す自分用の回避策。他の人向けではない |

フォルダを指定してインストールします。

```sh
tern plugin install github.com/ryosuz/tern/plugins/session-root
```

使い方は各プラグインの README にあります。

## 開発

リポジトリを clone し、ルートで作業中のプラグインを link します。Tern は clone したフォルダから直接読み込み、保存するたびに再読み込みします。

```sh
tern plugin link plugins/session-root
```

すでにインストールしているプラグインは、先に外す必要があります（`tern plugin remove session-root`）。link をやめるときは `tern plugin unlink session-root` を実行します。

luau-lsp で型チェックするには、プラグインのフォルダに `tern.d.luau` を生成し、luau-lsp の `luau-lsp.types.definitionFiles` 設定に追加します。このファイルは git の管理対象外です。Tern を更新したら生成し直してください。

```sh
tern plugin types plugins/session-root
```

プラグイン API のドキュメント：<https://docs.stencil.so/tern/>

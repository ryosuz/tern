# session-root

[English](README.md) | 日本語

Tern のセッションごとに root ディレクトリを持たせるプラグインです。root を設定したセッションでは、新しいタブがそこで開きます。

| タブを開く操作 | root で開く仕組み |
| --- | --- |
| New Tab（⌘T、ツールバーの ＋、パレット） | `tern.override("new_tab")` で root に開く |
| 縦タブ一覧のセッション行の ＋ | このボタンは New Tab を通らず、そのセッションでフォーカスしていたペインのディレクトリでシェルを開く。それを `tab_created` で検知し、root で開いたタブに同じ位置で差し替える |

分割は Tern の通常どおりです。

## コマンド

パレットの **Session Root** グループに入っています。

| コマンド | 動作 |
| --- | --- |
| Session root: use this directory | フォーカス中のペインのディレクトリを、今のセッションの root にする |
| Session root: set… | root を入力して設定する（絶対パスか `~/…`） |
| Session root: clear | 今のセッションの root を解除する |
| New session at directory… | ディレクトリを入力し、その名前のセッションを作って root にする |

## 保存先

root は `tern.kv`（`<state>/plugin-data/session-root/kv.json`）のキー `sessions` に、スコープ → セッション名の 2 段で保存されます。

```json
{
  "sessions": {
    "local": { "LMS": { "root": "/path/to/lms", "id": 51539607557 } },
    "remote:dev.example.com": { "api": { "root": "/srv/api" } }
  }
}
```

スコープと名前を別の階層に分けているので、どんな名前でもローカルとリモートのセッションが同じキーになることはありません。各エントリはセッション id も記録しており、`window_start` のたびに id を付け直すので、起動中にセッション名を変えても root は付いていきます。

セッションが終わると、その root は削除されます。

- **ウィンドウが開いているとき**：`session_ended` で削除します（id と名前の両方が一致した場合）。
- **ウィンドウが開いていないとき**（`tern kill session` など）：次の `window_start` で、もう存在しないローカルセッションの root を削除します。リモートホストの root は、そのホストにまだ接続していないだけかもしれないので残します。

## インストール

リポジトリのルートで実行します。

```sh
tern plugin link plugins/session-root
```

link したプラグインは保存のたびに再読み込みされます。外すときは `tern plugin unlink session-root` を実行します。

luau-lsp で型チェックするには `tern.d.luau`（コミットしない）を生成します。Tern を更新したら生成し直してください。

```sh
tern plugin types plugins/session-root
```

## 制限

- **＋ ボタン**：差し替えでシェルを 1 つ起動してすぐ閉じます。差し替えるのは、フォーカスしていたペインのディレクトリを引き継いだシェル 1 つだけのタブです。他のプラグインが自分で選んだディレクトリで開いたタブ（例：`cx.layout:new_tab({cwd = ...})`）はそのままにします。
- **このウィンドウの外で開いたタブ**：同じセッションでも、別のウィンドウで作られたタブではこのウィンドウに `tab_created` が届かないので、root に移りません。Carly や `tern` CLI のスクリプトから開いたタブは試していません。
- **リモートホスト**：root が存在するかは自分のマシンでしか確認しません。リモートでは入力したパスをそのまま保存します。
- **再起動をまたいだ改名**：再起動後のセッション id は信用しません。ウィンドウを閉じている間にセッション名を変えると、root は失われます。

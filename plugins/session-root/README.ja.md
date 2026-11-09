# session-root

[English](README.md) | 日本語

Tern のセッションごとに root ディレクトリを決められるプラグインです。root を決めたセッションでは、新しいタブがいつもそのディレクトリで開きます。

セッションをプロジェクトごとに分けている人向けです。たとえば `api` セッションの新しいタブは api のリポジトリで、`web` セッションの新しいタブは web のリポジトリで開きます。

## インストール

```sh
tern plugin install github.com/ryosuz/tern/plugins/session-root
```

## 使い方

1. 対象のセッションに切り替え、プロジェクトのディレクトリに `cd` します。
2. パレットで **Session root: use this directory** を実行します。
3. ⌘T か、タブ一覧のセッション行の ＋ を押すと、そのディレクトリでタブが開きます。

新しいプロジェクト用にセッションを作るときは、**New session at directory…** を実行してパスを入力します。フォルダ名のセッションができ、そのフォルダが root になります。

## コマンド

パレットの **Session Root** グループに入っています。

| コマンド | 動作 |
| --- | --- |
| Session root: use this directory | フォーカス中のペインのディレクトリを、今のセッションの root にする |
| Session root: set… | root を入力して設定する（絶対パスか `~/…`） |
| Session root: clear | 今のセッションの root を解除する |
| New session at directory… | ディレクトリを指定してセッションを作り、そこを root にする |

## root で開くもの

- New Tab（⌘T、ツールバーの ＋、パレット）
- 縦タブ一覧のセッション行の ＋

分割は今までどおり、今いるペインのディレクトリで開きます。root を決めていないセッションも、今までどおりの動作です。

## root の確認

ステータスラインに、今のセッションの root がフォルダのアイコン付きで `~/src/api` のように表示されます。クリックすると root を変更できます。ステータスラインが出ていない場合は、パレットの **Show status line** で表示してください。

## 設定の保存先

プラグインのデータフォルダの `kv.json` に保存されます。

| OS | データフォルダ |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/session-root/` |
| Linux | `~/.local/state/tern/plugin-data/session-root/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\session-root\` |

プラグインを更新・再インストールしても root は残ります。セッション名を変えても root は付いていき、セッションを閉じると root も消えます。

## 制限

- **セッション行の ＋ で一瞬ちらつく**：このボタンは一度元のディレクトリでタブを開くので、それを root で開いたタブに差し替えています。
- **別のウィンドウで開いたタブ**：同じセッションでも、root には移りません。
- **リモートホスト**：root が存在するかを確認しないので、打ち間違えたパスもそのまま保存されます。
- **Tern を閉じている間のセッション名の変更**：root が失われます。設定し直してください。

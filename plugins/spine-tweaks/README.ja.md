# spine-tweaks

[English](README.md) | 日本語

Tern の Spine 形式のチャット（omp の会話表示）の見た目を調整するプラグインです。

- 自分のアバターを好きな画像にする
- 自分のメッセージに色付きの背景と角丸を付ける

## インストール

```sh
tern plugin install github.com/ryosuz/tern/plugins/spine-tweaks
```

## アバター画像

画像を指定するまではアバターを変えません。パレットで **Spine Tweaks: choose avatar…** を実行し、PNG・JPEG・GIF・WebP の画像のパスを入力します（512 KiB まで）。256px 程度の正方形の画像が向いています。

指定した画像はデータフォルダに `avatar` という名前でコピーされます。

| OS | データフォルダ |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/spine-tweaks/` |
| Linux | `~/.local/state/tern/plugin-data/spine-tweaks/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\spine-tweaks\` |

このフォルダはプラグインを更新・再インストールしても残るので、画像を設定し直す必要はありません。**Spine Tweaks: clear avatar** で画像を消すと、Tern の標準のアバターに戻ります。手でファイルを置いた場合は、プラグインを再読み込みすると反映されます。

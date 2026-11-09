# spine-tweaks

[English](README.md) | 日本語

Tern の Spine 形式のチャット（omp の会話表示）で、自分の発言の見た目を変えるプラグインです。

- 自分のアバターを好きな画像にできます。
- 自分のメッセージに色付きの背景と角丸が付き、返信と見分けやすくなります。

変わるのは Spine 形式のチャットだけです。パレットで **Chat style: Spine** を選んで使ってください。

## インストール

```sh
tern plugin install github.com/ryosuz/tern/plugins/spine-tweaks
```

メッセージの背景はインストールしてすぐ反映されます。アバターは、画像を指定するまで Tern の標準のままです。

## アバターの設定

1. パレットで **Spine Tweaks: choose avatar…** を実行します。
2. PNG・JPEG・GIF・WebP の画像のパスを入力します（512 KiB まで。`~/…` も使えます）。256px 程度の正方形の画像がきれいに見えます。

アバターはすぐに切り替わります。Tern の標準のアバターに戻すには **Spine Tweaks: clear avatar** を実行します。

## コマンド

パレットの **Spine Tweaks** グループに入っています。

| コマンド | 動作 |
| --- | --- |
| Spine Tweaks: choose avatar… | 画像をアバターにする |
| Spine Tweaks: clear avatar | Tern の標準のアバターに戻す |

## 画像の保存先

指定した画像は、プラグインのデータフォルダに `avatar` という名前でコピーされます。

| OS | データフォルダ |
| --- | --- |
| macOS | `~/Library/Application Support/Tern/plugin-data/spine-tweaks/` |
| Linux | `~/.local/state/tern/plugin-data/spine-tweaks/` |
| Windows | `%LOCALAPPDATA%\Tern\plugin-data\spine-tweaks\` |

プラグインを更新・再インストールしても残るので、設定し直す必要はありません。このフォルダに自分で `avatar` という名前の画像を置くこともできます。その場合は **Reload plugins** を実行すると反映されます。

# Karabiner-Elements 設定ガイド

USキーボードで日本語かな入力（かわせみ4）をWindows標準IMEの配列に合わせるための設定と、そのトラブルシュート手順。

## ファイル構成と同期の運用

| 場所 | 役割 |
|---|---|
| `home/dot_config/karabiner/karabiner.json` | chezmoi ソース（このリポジトリ） |
| `~/.config/karabiner/karabiner.json` | 実機の設定。Karabiner が監視していて変更は即時反映 |

**注意: Karabiner は設定ロード時に JSON を正規化（キーをアルファベット順に並べ替え）して書き戻す。** また Karabiner-Elements の設定GUIでルールを追加・削除した場合も実機側だけが変わる。このため実機とソースは容易にズレる。

- 実機側で動作確認が取れたら `chezmoi add ~/.config/karabiner/karabiner.json` でソースに取り込む
- GUIでルールを取り込むと既存ルールと**重複**することがある（同じキーを対象にした場合、先頭のルールが勝つ）。重複したら片方を削除する

## ルール構成

### 1. 左Option（Alt）キーの連打でIMEを切り替える

`left_alt` 単押しで英数/かなをトグルする。

### 2. US配列かな入力をWindows標準IME配列に合わせる（ことえり準拠の差分のみ）

かわせみ4（およびことえりのかな入力）のUSキーボード配列は macOS 標準配列で、Windows 標準IMEの配列とは**記号キー帯だけ**が異なる。差分のみをキーイベント変換で埋める。

参考資料:
- [USキーボードでのかな入力（zenn/komatsuh）](https://zenn.dev/komatsuh/articles/komatsuh_kana_us_keyboard)
- [hiroyuki-komatsu/keyboard_layouts](https://github.com/hiroyuki-komatsu/keyboard_layouts) の `kana_us_mac_highlight.png` / `kana_us_win_highlight.png`（macOS/Windows 両配列の全キー対応図）

変換表（Windows配列で出したい文字 ← ことえり配列上のその文字の位置に変換）:

| 押すキー | 出る文字 | 変換先（ことえり上の位置） |
|---|---|---|
| `` ` `` | ろ | Shift+`'` |
| Shift+`-` | ー | Shift+`]` |
| `=` | へ | `\` |
| Shift+`=` | ＋ | テンキー `+`（keypad_plus） |
| Shift+`[` | 「 | Shift+`=` |
| `]` | ゜ | `=` |
| Shift+`]` | 」 | Shift+`[` |
| `\` | む | `]` |
| Shift+`\` | ？ | クリップボード貼り付け（下記参照） |

**変換しないキー**: `0`（わ/を）、`-`（ほ）、`,`（ね/、）、`.`（る/。）、`/`（め/・）は、ことえり配列が元から Windows と同じ。過去に Shift 入れ替えルールを入れて逆に壊していたことがあるので追加しないこと。

キーイベント変換なので IME の未確定文字列（変換バッファ）はそのまま維持される。

#### 入力ソース条件

各 manipulator は `input_source_if` で以下に限定している（実測値）:

- かわせみ4: `input_source_id: jp.monokakido.inputmethod.Kawasemi4.Japanese` + `input_mode_id: com.apple.inputmethod.Japanese`
- ことえりかな入力: `com.apple.inputmethod.Kotoeri.KanaTyping.Japanese`

かわせみのメジャーアップデートで ID が変わる可能性がある。実際の ID は **Karabiner-EventViewer → Variables** で確認できる。

### Shift+`\` の「？」だけが特殊な理由

ことえりのUSかな配列には「？」がどのキーにも存在しないため、キーイベント変換では出せない。代わりに shell_command で以下を実行している:

```
クリップボード退避 → 「？」をコピー → ⌘V送信 → クリップボード復元
```

**副作用: 未確定文字列があると、貼り付けの時点で確定される。** これはアプリ外部から文字を挿入する以上避けられない原理的な制約。

- `osascript` の `keystroke "？"` は使えない（keystroke は非ASCII文字を送信できない）
- ⌘V送信の前に `delay 0.15` を入れているのは、物理Shiftキーが押されたままだと合成イベントと合体して **⌘⇧V** に化けるため（アプリによっては別コマンドになる）
- かわせみ4側でかな配列をカスタマイズする機能は存在しない（`KeySettings/*.nkset` はショートカット割り当てで、かな配列テーブルはバイナリ内固定）

#### 補完策: 変換辞書に？を登録する（未確定のまま出せる）

未確定文字列の途中に？を入れたい場合は、かわせみの単語登録で？を辞書に入れておくとIMEネイティブに出せる（確定されない）。

- **よみ「・」（Shift+`/`）→ 候補「？」、品詞は「記号類」** がおすすめ。1打+変換で出せて、通常入力との干渉が少ない（記号類は「記号・マークに読みを付けて登録する」ための品詞で、この用途の設計意図そのもの）
- よみ「はてな」でも可（標準辞書で既に変換できる場合もある）
- よみ「。」は**非推奨**。かわせみの句読点変換トリガ（`convert_triggerKuten`）と衝突し、普段の句点入力のたびに？が候補に混ざる

登録はかわせみメニュー → 単語登録（Kawasemi4 WordRegister）から。バイナリ辞書のため外部からの自動登録はできない。

使い分け:

| 場面 | 手段 |
|---|---|
| 未確定の文中に？を入れる | ・を打って変換 → ？を選択（辞書方式） |
| 確定済みの位置に1打で？ | Shift+`\`（クリップボード方式・確定を伴う） |

## トラブルシュート

### ルールが効かないときのチェックリスト

1. **ログを見る**（shell_command のエラーはここに出る）:
   ```bash
   tail -40 ~/.local/share/karabiner/log/console_user_server.log
   ```
2. **Shift+`\` の発火確認**: shell_command にデバッグログを仕込んである。押した時刻と結果コードが追記されるか見る:
   ```bash
   cat /tmp/kana_debug.log   # 「HH:MM:SS fired」「done rc=0」が増えれば発火している
   ```
   - `fired` が増えない → Karabiner がルールにマッチしていない（入力ソース条件・ルール重複を疑う）
   - `fired` は増えるが文字が出ない → osascript の権限か ⌘⇧V 化けを疑う
3. **アクセシビリティ権限**: `osascript にはキー操作の送信は許可されません (1002)` がログに出たら、システム設定 → プライバシーとセキュリティ → アクセシビリティに以下を追加:
   ```
   /Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_console_user_server
   ```
   **付与後はプロセス再起動しないと反映されないことがある:**
   ```bash
   launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server
   ```
4. **入力ソースIDの確認**: Karabiner-EventViewer を開き、かな入力モードで Variables タブの `input_source_id` / `input_mode_id` が条件の正規表現とマッチしているか確認。
5. **実機とソースのズレ**: `chezmoi diff` で確認（他ファイルのテンプレートエラーで落ちる場合は個別パス指定でも試す）。

### 挙動確認に使ったコマンド

```bash
# 有効になっているルール一覧を表示
python3 -c "
import json
d = json.load(open('$HOME/.config/karabiner/karabiner.json'))
for p in d['profiles']:
    print('profile:', p['name'], 'selected:', p.get('selected'))
    for r in p['complex_modifications']['rules']:
        print('  rule:', r['description'], len(r['manipulators']))
"

# macOSに登録されている入力ソースIDの確認
defaults read com.apple.HIToolbox AppleSelectedInputSources
```

## Parallels・リモートデスクトップでの挙動

Karabiner は物理キーボードのHIDイベントをOSレベルで書き換えるため、Mac上で動くすべてのアプリ（Parallels のVMウィンドウ、RDPクライアント含む）に変換後のキーが届く。発動条件は `input_source_if`（Mac側の入力ソース）なので：

| ケース | 挙動 |
|---|---|
| Mac側を英数(ABC)にしてゲスト/リモート側のWindows IMEでかな入力 | **正しく動く（推奨）**。ルール不発動で素のUSキーが届き、Windows IMEがネイティブのWindows配列で変換する |
| Mac側がかわせみのままVM/リモートへ入力 | **二重変換で化ける**。例: `=` はKarabinerが `\` に変換し、Windows側かな入力では「む」になる。Shift+`\` の？も合成⌘Vの扱いが不安定 |
| 他マシンからこのMacへ画面共有/VNC接続 | **ルールは効かない**。リモートから注入される合成イベントはKarabinerの物理HID横取りを通らない |

Parallels や RDP クライアントを導入した場合は、全 manipulator に `frontmost_application_unless` を追加すると入力ソースの切り替え忘れ対策になる：

```json
{ "type": "frontmost_application_unless",
  "bundle_identifiers": ["^com\\.parallels\\.desktop\\.console$", "^com\\.microsoft\\.rdc\\.macos$"] }
```

## Linuxでの代替手段

Karabiner相当のキーリマップツール：

| ツール | 特徴 |
|---|---|
| [keyd](https://github.com/rvaiya/keyd) | evdev/uinputでOSレベル横取り。INI風設定。シンプルで堅い |
| [kanata](https://github.com/jtroo/kanata) | Rust製、Linux/Windows/macOS対応。クロスプラットフォームでKarabiner代替になり得る |
| [xremap](https://github.com/xremap/xremap) | Rust製、アプリごとの条件分岐（`frontmost_application_if` 相当）に対応。YAML設定・コマンド実行可 |
| [kmonad](https://github.com/kmonad/kmonad) | 高機能・老舗。Lisp風設定 |

shell_command 相当は xremap のコマンド実行＋ `wtype`/`ydotool`（Wayland）や `xdotool`（X11）で再現できる（uinput権限の設定が必要）。

**ただし、かな配列の用途ならIME層で解決するのが正攻法。** macOSでのKarabinerハックは「かわせみ/ことえりのかな配列が固定」なことへの迂回策だが、Linuxでは：

- **Mozc（fcitx5/ibus）** — USかな配列は最小限の調整でJIS配列に近い設計
- **[ibus-hiragana](https://esrille.github.io/ibus-hiragana/layouts.html)（esrille）** — かな配列そのものをカスタマイズ可能。Windows風USかな配列を直接定義でき、リマップ不要・？も配列に含められる（未確定問題も存在しない）

**WSL2の場合**：キーボードとIMEはWindowsホスト側の管轄なので、Windows標準IMEがネイティブにWindows配列でかな入力する。リマップ自体が不要（必要ならWindows側で PowerToys Keyboard Manager / AutoHotkey / kanata）。

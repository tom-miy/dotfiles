# Dotfiles

このリポジトリは私の dotfiles を管理するためのものです。[chezmoi](https://www.chezmoi.io/) を使用して、以下の環境間で設定を同期します。
 * macOs
 * Ubuntu
 * Dev Container
 * WSL2

## セットアップ

### 1. chezmoiのインストール

#### macOS

```bash
brew install chezmoi
```

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:$GITHUB_USERNAME/dotfiles.git
```
#### Ubuntu

```bash
snap install chezmoi --classic
```

#### その他のプラットフォーム
[公式インストールガイド](https://www.chezmoi.io/install/)を参照してください。

### 2. dotfilesの初期化

```bash
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
```

### 3. dotfilesの適用

```bash
chezmoi apply
```

## 主な設定ファイル

- `.zshrc` - Zshの設定
- `.gitconfig` - Gitの設定
- `Sheldon/plugins.toml` - Zshプラグインの管理

## プラットフォーム固有の設定

プラットフォーム固有の設定は `.chezmoi.toml.tmpl` で管理されています。

## メンテナンス

### 設定の更新

```bash
chezmoi update
```


### 変更の適用

```bash
chezmoi apply
```


### 差分の確認

```bash
chezmoi diff
```

### installコマンドファイル生成

```bash
chezmoi generate install.sh > install.sh
chmod a+x install.sh
```

### `~/.config/git/config`設定例


```bash
~/.config/git/
├── config                # メインの設定
├── personal/            
│   └── config           # 個人用の設定
├── business/
│   └── config           # 仕事用の設定
├── ignore               # グローバルな.gitignore
└── attributes          # gitattributes
```

```conf
[core]
    editor = cursor
    excludesfile = ~/.config/git/ignore

[init]
    defaultBranch = main

[ghq]
    root = ~/ghq/misc
# 条件付きインクルード
[includeIf "gitdir:~/personal/"]
    path = ~/.config/git/personal/config

[includeIf "gitdir:~/work/"]
    path = ~/.config/git/business/config
```

### dev container設定例

customizationsはcursorの場合もvscodeで大丈夫なはず
```json
{
    "name": "Your Dev Container",
    "customizations": {
        "vscode": {
            "settings": {
                "dotfiles.repository": "${localEnv:HOME}/.local/share/chezmoi",
                "dotfiles.targetPath": "~/.local/share/chezmoi",
                "dotfiles.installCommand": "chezmoi init --apply"
            }
        }
    },
    "features": {
        "ghcr.io/meaningful-ooo/devcontainer-features/chezmoi:1": {}
    },
    // ローカルのdotfilesディレクトリをマウント
    "mounts": [
        "source=${localEnv:HOME}/.local/share/chezmoi,target=/home/vscode/.local/share/chezmoi,type=bind"
    ]
}
```

### Cursor用devcontainer dotfiles設定

Cursorでdevcontainerを使用する場合、以下の設定を `~/.cursor` に追加してdotfilesを自動で同期できます：

#### 1. `~/.cursor/devcontainer.json` にdotfiles設定を追加

```json
{
    "dotfiles": {
        "repository": "tom-miy/dotfiles-devcontainer",
        "installCommand": "./install.sh"
    }
}
```

#### 2. プロジェクト固有の `.devcontainer/devcontainer.json` 設定

```json
{
    "name": "Your Dev Container",
    "customizations": {
        "vscode": {
            "settings": {
                "dotfiles.repository": "tom-miy/dotfiles-devcontainer",
                "dotfiles.installCommand": "./install.sh"
            }
        }
    }
}
```

#### 3. ローカルdotfilesディレクトリを直接マウントする場合

```json
{
    "name": "Your Dev Container",
    "mounts": [
        "source=${localEnv:HOME}/.local/share/chezmoi,target=/workspaces/.dotfiles,type=bind"
    ],
    "postCreateCommand": "cd /workspaces/.dotfiles && ./install.sh"
}
```
### 参考
[ghqとSSHの設定で複数のGitアカウントを効率よく管理する方法](https://www.fourier.jp/blog/ghq-ssh-multi-git-account-management?utm_source=pocket_shared)
[Powerlevel10kのフォント](https://qiita.com/831kirimi/items/582e0abc26dbd7776d9b)
[zshの補完を強化するTips](https://qiita.com/syui/items/ed2d36698a5cc314557d)
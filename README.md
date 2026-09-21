# dotfiles

[mise](https://mise.jdx.dev/) でツールを一元管理する dotfiles プロジェクトです。
Linux (WSL) / macOS / Windows で同じ設定を使えます。

## 方針

- **すべてのツールを mise で管理** — `[tools]` に定義し、apt / brew / winget などで
  個別にインストールしません (mise 本体の導入だけは installer が行います)。
- **dotfiles も mise で配置** — `[dotfiles]` で `~/.gitconfig` などを管理します。
- **エディタは neovim** — `git` や `jj` から起動されるエディタを `nvim` に設定します。

## セットアップ

`~/dotfiles` に clone してから実行してください。

### Linux / macOS

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Windows (PowerShell 7+)

```powershell
git clone <this-repo> $HOME\dotfiles
cd $HOME\dotfiles
pwsh -File install.ps1
```

installer は次のことを行います。

1. mise が無ければインストール (`mise.run` / `winget`)
2. リポジトリを `mise trust`
3. `mise dot apply` で dotfiles を配置
4. `mise install` でツールをインストール
5. `mise bootstrap` でシェル activation などを設定
6. (Windows) PowerShell プロファイルに `mise activate pwsh` を追記

完了後は新しいシェルを開いてください。

## ディレクトリ構成

```
dotfiles/
├── mise.toml                 # bootstrap プロジェクト設定 (dotfiles の配置)
├── dotfiles/
│   ├── mise/config.toml      # mise グローバル設定 (ツール / 環境変数)
│   ├── git/.gitconfig        # git (editor = nvim, pager = delta, gh 認証)
│   ├── git/.gitignore_global
│   ├── jj/config.toml        # jujutsu (editor = nvim)
│   ├── nvim/                 # Neovim 設定 (lua)
│   ├── starship/starship.toml # starship プロンプト設定
│   ├── wezterm/wezterm.lua   # WezTerm 設定 (Windows 専用)
│   └── powershell/profile.ps1 # PowerShell profile (CurrentUserAllHosts)
├── install.sh                # Linux / macOS 用 installer
├── install.ps1               # Windows 用 installer
└── README.md
```

`dotfiles/mise/config.toml` は `~/.config/mise/config.toml` にリンクされ、
**グローバル設定**として機能します。これにより、どのディレクトリでも
mise 管理のツールが使えます。

| 配置元 | 配置先 |
| :--- | :--- |
| `dotfiles/mise/config.toml` | `~/.config/mise/config.toml` |
| `dotfiles/git/.gitconfig` | `~/.gitconfig` |
| `dotfiles/git/.gitignore_global` | `~/.gitignore_global` |
| `dotfiles/jj/config.toml` | Linux/macOS: `~/.config/jj/config.toml` / Windows: `%APPDATA%\jj\config.toml` |
| `dotfiles/nvim` | Linux/macOS: `~/.config/nvim` / Windows: `%LOCALAPPDATA%\nvim` |
| `dotfiles/starship/starship.toml` | `~/.config/starship.toml` |
| `dotfiles/wezterm/wezterm.lua` | Windows: `~/.config/wezterm/wezterm.lua` (copy モード / Windows 専用) |
| `dotfiles/powershell/profile.ps1` | Windows: `~/Documents/PowerShell/profile.ps1` / Linux: `~/.config/powershell/profile.ps1` |

## インストールされる主なツール

| カテゴリ | ツール |
| :--- | :--- |
| 言語 / ランタイム | node, pnpm, go, rust, uv |
| エディタ | **neovim** |
| VCS | git (既存), **jujutsu (jj)**, lazygit, **lazyjj** |
| AI | **opencode**, codex, antigravity-cli |
| CLI | just, rg, fd, jq, yq, ast-grep, eza, bat, fzf, delta, shellcheck, tokei, hyperfine, typst, gh |
| プロンプト | **starship** |
| コンテナ (Linux のみ) | **podman** (mise bootstrap のホストパッケージ `dnf:podman` として導入) |

### lazyjj について

`lazyjj` は mise のレジストリに存在しないため、GitHub Releases から
取得する `github:Cretezy/lazyjj` バックエンドを使っています。
最新の 0.6.x にはバイナリが添付されていないため、プリビルドのある
**`0.5.0` に固定**しています。新しいバージョンを使いたい場合は
`cargo:lazyjj` に切り替えてください (Rust ツールチェーンが必要)。

### シェル設定 (エイリアス / starship / PowerShell)

すべて `mise.toml` の `[dotfiles]` で管理しています。

- **エイリアス / 関数**
  - `nv` は引数なしならカレントディレクトリを開く (`nvim .` 相当)、引数ありはそのまま渡す
  - bash: `~/.bashrc` に `nv` 関数と `alias lj='lazyjj'` をブロックとして追記
    (`[dotfiles."~/.bashrc/aliases"]`)
  - PowerShell: `profile.ps1` に `nv` 関数と `Set-Alias lj lazyjj`
- **starship の初期化**
  - bash: `[dotfiles."~/.bashrc/starship"]` → `eval "$(starship init bash)"`
  - zsh: `[dotfiles."~/.zshrc/starship"]` → `eval "$(starship init zsh)"`
  - fish: `[dotfiles."~/.config/fish/config.fish/starship"]` → `starship init fish | source`
  - PowerShell: `profile.ps1` に `Invoke-Expression (&starship init powershell)`
- **PowerShell の初期化ファイル**
  - `$PROFILE` (`Microsoft.PowerShell_profile.ps1`) は編集せず、
    PowerShell が全ホスト共通で自動的に読み込む **`profile.ps1` (CurrentUserAllHosts)**
    を mise で丸ごと管理します。中身は mise activation・starship・エイリアス・
    関数 (`agy`, `touch`) です。

## 編集と反映

- ツールを追加/変更: `dotfiles/mise/config.toml` の `[tools]` を編集
- dotfiles の追加: `mise.toml` の `[dotfiles]` に追記し、`dotfiles/` に実体を置く
- 反映: `mise install` (ツール) / `mise dot apply` (dotfiles) / `mise bootstrap`

便利タスク:

```sh
mise run status   # dotfiles / bootstrap / tools の状態を表示
mise run apply    # dotfiles を再適用
```

## 注意事項

- **`~/dotfiles` に clone する前提**のパス設定は含まれていません。別の場所に
  置く場合は `mise.toml` の `[dotfiles]` の source を調整してください。
- **Neovim 設定 (`~/.config/nvim`) はディレクトリごと symlink で管理しています。**
  lazy.nvim が書き込む `lazy-lock.json` もリポジトリ側 (`dotfiles/nvim/`) に反映されます。
- **Windows での symlink** — 開発者モードが有効なら symlink、無効なら mise が
  自動的にコピーへフォールバックします。コピーになった場合は変更の反映に
  `mise dot apply` の再実行が必要です。
- **PowerShell は `$PROFILE` を編集しません。** 代わりに `profile.ps1`
  (CurrentUserAllHosts) を mise で管理します。既存の `$PROFILE` に
  `agy` / `touch` などが残っている場合は、重複を避けるため手動で削除してください。
- **WezTerm 設定は Windows 専用** (`os = "windows"` の variant) です。リポジトリは
  WSL 上にあり Windows とはファイルシステムが別なので、symlink ではなく **copy
  モード**で配置します。反映には Windows 側で `mise dot apply`（または
  `install.ps1`）の実行が必要です。
- `antigravity-cli` など一部ツールは Windows 向けバイナリが無い場合があります。
  その場合 `mise install` が該当ツールのみエラーを報告します。

#!/usr/bin/env pwsh
# =============================================================================
# dotfiles installer for Windows (PowerShell 7+)
#
#   pwsh -File install.ps1
#
# mise を (未導入なら) winget でインストールし、dotfiles とツールを
# セットアップします。PowerShell の初期化 (activation / starship / エイリアス /
# 関数) は $PROFILE ではなく mise 管理の profile.ps1 に配置します。
# =============================================================================
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepoDir = Split-Path -Parent $PSCommandPath

function Info($Message) { Write-Host "==> $Message" -ForegroundColor Blue }
function Warn($Message) { Write-Host "[!] $Message" -ForegroundColor Yellow }

# 1. mise をインストール (未導入時のみ)
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    Info 'mise を winget でインストールします...'
    winget install --id jdx.mise --exact --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
}

Set-Location -LiteralPath $RepoDir

# 2. このリポジトリの設定を信頼
Info "設定を信頼: $RepoDir"
mise trust

# 既存の実ファイルがあればバックアップしてから置き換える
function Backup-Target($Target) {
    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        if ($item.Attributes.ToString().Contains('ReparsePoint')) { return }
        $stamp = Get-Date -Format 'yyyyMMddHHmmss'
        Copy-Item -LiteralPath $Target -Destination "$Target.bak.$stamp" -Recurse -Force
        Warn "既存ファイルをバックアップ: $Target -> $Target.bak.$stamp"
    }
}
Backup-Target "$HOME/.config/mise/config.toml"
Backup-Target "$HOME/.gitconfig"
Backup-Target "$HOME/.gitignore_global"
Backup-Target "$HOME/.config/jj/config.toml"
Backup-Target "$HOME/.config/starship.toml"
Backup-Target "$HOME/.config/wezterm/wezterm.lua"
Backup-Target "$HOME/AppData/Local/nvim"
Backup-Target "$HOME/Documents/PowerShell/profile.ps1"

# 3. dotfiles を配置 (グローバル mise 設定へのリンクを含む)
Info 'dotfiles を適用します...'
mise dot apply --yes --force

# 4. リンクしたグローバル設定を信頼
mise trust "$HOME/.config/mise/config.toml" 2>$null

# 5. ツールをインストール
Info 'ツールをインストールします...'
mise install
if ($LASTEXITCODE -ne 0) { Warn '一部ツールのインストールに失敗しました。bootstrap は続行します。' }

# 6. シェル activation など残りの bootstrap を実行
Info 'bootstrap を実行します...'
mise bootstrap --yes

# 7. PowerShell の初期化 (mise activation / starship / エイリアス / 関数) は
#    mise の [dotfiles] が profile.ps1 (CurrentUserAllHosts) として配置するため、
#    $PROFILE は編集しない。

Info '完了しました。ターミナルを再起動してください。'

#!/usr/bin/env bash
# =============================================================================
# dotfiles installer for Linux / macOS
#
#   ./install.sh
#
# mise を (未導入なら) インストールし、dotfiles とツールをセットアップします。
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# 1. mise をインストール (未導入時のみ)
if ! command -v mise >/dev/null 2>&1; then
  info "mise をインストールします..."
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

cd "$REPO_DIR"

# 2. このリポジトリの設定を信頼
info "設定を信頼: $REPO_DIR"
mise trust

# 既存の実ファイルがあればバックアップしてから置き換える
backup_target() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    cp -a "$target" "$backup"
    warn "既存ファイルをバックアップ: $target -> $backup"
  fi
}
backup_target "$HOME/.config/mise/config.toml"
backup_target "$HOME/.gitconfig"
backup_target "$HOME/.gitignore_global"
backup_target "$HOME/.config/jj/config.toml"
backup_target "$HOME/.config/starship.toml"
backup_target "$HOME/.config/wezterm/wezterm.lua"
backup_target "$HOME/.config/nvim"
backup_target "$HOME/.config/powershell/profile.ps1"

# 3. dotfiles を配置 (グローバル mise 設定へのリンクを含む)
info "dotfiles を適用します..."
mise dot apply --yes --force

# 4. リンクしたグローバル設定を信頼 (リンク後のパスに対して必要)
mise trust "$HOME/.config/mise/config.toml" >/dev/null 2>&1 || true

# 5. ツールをインストール
info "ツールをインストールします..."
if ! mise install; then
  warn "一部ツールのインストールに失敗しました。bootstrap は続行します。"
fi

# 6. シェル activation など残りの bootstrap を実行
info "bootstrap を実行します..."
mise bootstrap --yes

info "完了しました。新しいシェルを開いてください (例: exec \$SHELL -l)。"

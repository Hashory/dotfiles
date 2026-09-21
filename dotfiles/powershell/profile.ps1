# =============================================================================
# PowerShell profile (CurrentUserAllHosts)
#
# ~/dotfiles で管理 (mise の [dotfiles] 経由で配置):
#   Windows : ~/Documents/PowerShell/profile.ps1
#   Linux   : ~/.config/powershell/profile.ps1
#
# このファイルは PowerShell が全ホスト共通で自動的に読み込みます。
# 個別の $PROFILE (Microsoft.PowerShell_profile.ps1) は編集しません。
# =============================================================================

# mise activation
(&mise activate pwsh) | Out-String | Invoke-Expression

# starship prompt
Invoke-Expression (&starship init powershell)

# aliases
# nv: 引数なしならカレントディレクトリを開く (nvim . 相当)
# 古い alias が残っていても関数が優先されるよう除去する
Remove-Item Alias:nv -ErrorAction SilentlyContinue
function nv {
    if ($args.Count -eq 0) {
        nvim .
    } else {
        nvim @args
    }
}
Set-Alias lj lazyjj

# agy を常に --dangerously-skip-permissions で起動する
# Set-Alias agy "agy --dangerously-skip-permissions"
function agy { & (Get-Command agy -CommandType Application) --dangerously-skip-permissions $args }

# touch: ファイルが無ければ作成、あれば更新日時を更新する
function touch {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Paths
    )
    process {
        foreach ($path in $Paths) {
            if (Test-Path $path) {
                # If it exists: update the last write time to the current time
                (Get-Item $path).LastWriteTime = Get-Date
            } else {
                # If it doesn't exist: create a new file
                New-Item -Path $path -ItemType File | Out-Null
            }
        }
    }
}

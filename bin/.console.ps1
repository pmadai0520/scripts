#################################################################################
#                     コンソールプロンプト変更
#################################################################################
###	更新日：2022年2月21日
#################################################################################
#                     プロンプトの一時変更
#################################################################################
<#
prompt関数を定義
function prompt {
  (Get-Date -format "[yyyy/MM/dd HH:mm:ss]") + (Split-Path (get-location) -Leaf) + "> "
}
#>
#################################################################################
#                     プロンプトの一時変更
#################################################################################

# プロンプトに時刻とカレントディレクトリ後尾要素の表示
# function:prompt関数(prompt関数のオーバーライド)
function prompt {
    (Get-Date -format "[yyyy/MM/dd HH:mm:ss]") + (Split-Path (get-location) -Leaf) + "> "
  }
  
# コンソールのUIを変更
# タイトルを変更
# Get-Hostは$hostで代替可能$host.privatedata
$Title = (Get-Host).UI.RawUI
$Title.WindowTitle = "WindowsPowerShell"

# エラー時の文字色を変更
$host.privatedata.errorforegroundcolor = “DarkGray”

# 実行ポリシー確認
Write-Host "実行ポリシー" (Get-ExecutionPolicy) -ForegroundColor "Yellow"
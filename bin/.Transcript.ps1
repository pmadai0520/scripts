# 開始ディレクトリの指定
Set-Location $DHWK_BASE

# ログの概要定義
$Ov = Read-Host "ログの概要を入力(不要の場合、enter で PS 代入)"

# タイムスタンプ取得
$TimeStamp   = (Get-Date -Format 'yyyyMMdd-HHmmss')

# ユーザ情報取得
# 環境変数：コンピュータ・環境変数：ユーザ情報
$UserInfo    = $Env:COMPUTERNAME + '-' + $Env:username

# ログファイル名定義：ログディレクトリ + ログ概要_ ) + タイムスタンプ + ユーザ情報
# ログ概要が空白の場合、PSを代入
if ($Ov -eq "") {$Ov = 'PS'}
$LogFilePath = $LogFolder + '\' + $Ov + '_' + $TimeStamp + '_' + $UserInfo + '.log'

# トランスクリプト開始
# Append:追加する
Start-Transcript -Path $LogFilePath -Append


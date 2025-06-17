#################################################################################
#                     フォルダ定義・作成・移動								   
#################################################################################
###	更新日：2025-06-05 08:21:54
#################################################################################

# ユーザドキュメントフォルダ定義
$UserDoc = (Split-Path -Parent $LscriptFolder)

# 読み込みファイルフォルダ定義
$ReadFileFolder = (Join-Path $DHWK_BASE readfile)

# ログフォルダ定義  
$LogFolder   = (Join-Path $DHWK_BASE logs)

# 共有フォルダ定義
$ShareFolder = (Join-Path $DHWK_BASE share)

# toolsフォルダ定義
$ToolsFolder = (Join-Path $DHWK_BASE tools)

# バックアップフォルダ定義
$BackupFolder = (Join-Path $DHWK_BASE bk)

# エビデンスフォルダ定義
$EvidenceFolder = (Join-Path $DHWK_BASE evidence)

# エビデンスフォルダ定義
$TextFolder = (Join-Path $DHWK_BASE text)

# スクリプト、ログフォルダ確認・作成
# ログフォルダ確認・作成
if (!(Test-Path -Path $LogFolder)) {New-Item -Path $LogFolder -ItemType Directory | Out-Null}
# スクリプトフォルダ確認・作成
if (!(Test-Path -Path $ScriptFolder)) {New-Item -Path $ScriptFolder -ItemType Directory | Out-Null}
# 共有フォルダ確認・作成
if (!(Test-Path -Path $ShareFolder)) {New-Item -Path $ShareFolder -ItemType Directory | Out-Null}
# バックアップフォルダ確認・作成
if (!(Test-Path -Path $BackupFolder)) {New-Item -Path $BackupFolder -ItemType Directory | Out-Null}
# エビデンスフォルダ確認・作成
if (!(Test-Path -Path $EvidenceFolder)) {New-Item -Path $EvidenceFolder -ItemType Directory | Out-Null}
# テキストフォルダ確認・作成
if (!(Test-Path -Path $TextFolder)) {New-Item -Path $TextFolder -ItemType Directory | Out-Null}

#################################################################################
###	更新日：2025-06-16 14:51:59
#################################################################################
#################################################################################
#  関数定義     　　　　　　　　　　
#################################################################################

<#
    間をコメント
#>

#################################################################################
#                     CD,DVDマウントドライブ情報取得　　　　　　　　　　　　　　　　  
#################################################################################

#   マウントしているドライブパス取得
<#  .DriveType
CDRom	5	
ドライブは、CD-ROM、DVD-ROM などの光ディスク ドライブです。
Fixed	3	
ドライブは固定ディスクです。
Network	4	
ドライブはネットワーク ドライブです。
NoRootDirectory	1	
ドライブにはルート ディレクトリがありません。
Ram	6	
ドライブは RAM ディスクです。
Removable	2	
ドライブは、USB フラッシュ ドライブなどのリムーバブル ストレージ デバイスです。
Unknown	0	
ドライブの種類は不明です。
#>

function drive{
    $drive = (Get-CimInstance Win32_LogicalDisk | ?{ $_.DriveType -eq 5}).DeviceID
    Write-Host "CDRom（DriveType -eq 5）が存在すれば表示します。"
    if ($drive -eq $null) {
        Write-Host "CDRom（DriveType -eq 5）は存在しません。"
    }
    Write-host $drive
}

#################################################################################
# ★Alias   ファイルの更新日順ソート
#################################################################################

function ll ($targetfile)
{
    Write-Host "更新日付順に表示します。"
    if ([string]::IsNullOrEmpty($targetfile)) {
        Get-ChildItem | Sort-Object LastWriteTime
    } else {
        $currentdir = (Convert-Path .) + '\'
        $fullpath = (Join-Path $currentdir $targetfile)
        Get-ChildItem $fullpath | Sort-Object LastWriteTime
    }
}

#################################################################################
# ★Alias   エクスプローラー起動
#################################################################################

function ex ($targetfile)
{
    if ([string]::IsNullOrEmpty($targetfile)) {
        Start-Process C:\WINDOWS\explorer.exe
    } elseif ($targetfile.IndexOf(":\")){
        Start-Process C:\WINDOWS\explorer.exe $targetfile
    } else {
        $currentdir = (Convert-Path .) + '\'
        $fullpath = (Join-Path $currentdir $targetfile)
        Start-Process C:\WINDOWS\explorer.exe $fullpath
    }
}

#################################################################################
# ★Exping　　　　　　　　　　　　　　                   
#################################################################################

# pingを実行する宛先を指定する
function exping ($targets)
{

# 設定
# pingを実行する間隔(ミリ秒)
$interval = 500

# 繰り返し数
$repeat   = 100000

@(1..$repeat) | foreach {
    $targets | foreach {
        # 間隔をあけるためのsleep
        Start-Sleep -Milliseconds $interval
        try {
            # ping実行
            $tc = Test-Connection $_ -count 1 -ErrorAction Stop

            #結果の格納
            $result = "○"
        } catch [Exception] {
            # 失敗した場合
            $result = "×"
        }
        # 現在時刻
        $datetime = Get-Date -F "yyyy/MM/dd HH:mm:ss.fff"

        # CSV形式で結果情報を作成
        $row = $result + "," + $datetime  + "," + $tc.Address + "," + $tc.ResponseTime 

        # CSVからオブジェクトを出力
        $row | ConvertFrom-Csv -Header @("Result","DateTime","Target","ResponseTime(ms)") 
    }

#} | Out-GridView -Title "Ping Results" # グリッドビューを表示する
} | Format-Table
}

#################################################################################
# ★diff　　　　　　　　　　　　　　　　       
#################################################################################
<#
.SYNOPSIS
    2つのファイルを比較

.DESCRIPTION
    修正前と修正後のファイルを比較し、差分をコンソールに表示する。
    [+]が修正後に存在する行(追加/変更)、[-]が修正後に存在しない行(削除/変更)。

.PARAMETER FromFile
    修正前ファイル

.PARAMETER ToFile
    修正後ファイル

.PARAMETER Full
    変更なしの行も表示する場合に指定。
    変更なしの行は[=]で表示。

.NOTES
    行番号は出ません

.EXAMPLE
    diffc .\File_ver1.txt .\File_ver2.txt
    File_ver1.txt と File_ver2.txt の差分を表示

.EXAMPLE
    diffc C:\Work\before.csv D:\Tmp\after.csv -Full
    before.csv と after.csv の差分を変更がない行も含めて表示
#>
function diffc([Parameter(Mandatory)][string]$FromFile, [Parameter(Mandatory)][string]$ToFile, [switch]$Full)
{
    Compare-Object (Get-Content $FromFile) (Get-Content $ToFile) -IncludeEqual:$Full | 
        ForEach-Object {
            [string]$line = ""
            [string]$foreColor = ""
            if ($_.SideIndicator -eq "=>")
            {
                # 修正後に存在する行（追加または変更された行）
                $line = "[+] " + $_.InputObject
                $foreColor = "Green"
            }
            elseif ($_.SideIndicator -eq "<=")
            {
                # 修正後に存在しない行（削除または変更された行）
                $line = "[-] " + $_.InputObject
                $foreColor = "Magenta"
            }
            elseif ($Full)
            {
                # 変更がない行
                $line = "[=] " + $_.InputObject
                $foreColor = "Gray"
            a}

            Write-Host $line -ForegroundColor $foreColor
        }
}

#################################################################################
# ★dhzip　　　　　　　　　　　　　　　　       
#################################################################################
function dhzip
{
<#
.SYNOPSIS(概要)

.DESCRIPTION(説明)

.NOTES(注釈)

.EXAMPLE(例)

.UPDATE（更新日）
#>
    ####################################################
    #  圧縮1
    #  ログオンスクリプトフォルダ 配下のMIT-WKフォルダ配下を圧縮
    ####################################################

    # 圧縮ファイル定義
    $destination = ".\DH-WK.zip"

    # ログオンスクリプトフォルダ移動
    Set-Location $LscriptFolder

    # 圧縮対象ディレクトリ
    $path = ".\DH-WK"

    # 除外ルール (*ワイルドカード使用可能)
    $exclude = @("bk","evidence","install","logs","media","share","tools_org","ttl_org","work","z_tools","")

  # 圧縮対象フォルダ取得(除外フォルダ)
    $files = Get-ChildItem -Path $path -Exclude $exclude

    # 圧縮処理1
    Compress-Archive -Path $files -DestinationPath $destination
    if ($? -eq "True") {
       Write-Host '圧縮1（DH-WK）成功'
    } else {
           Write-Host '圧縮1（DH-WK）に失敗しました。'
           Write-Host　"エラー内容を確認してください。"
           exit 1
    }   

    ####################################################
    #  圧縮2
    #  ユーザドキュメント 配下のWindowsPowerShellフォルダを圧縮
    #  DH-WKフォルダを除外し、圧縮1で作成したDH-WK-*.zipを含めて圧縮
    ####################################################

    # 圧縮ファイル定義
    $DateTime = (Get-Date -Format "yyyyMMddHHmmss")
    $destination = ".\WPS-$Env:COMPUTERNAME-$DateTime.zip"

    # ログオンスクリプトフォルダ移動
    Set-Location $UserDoc

    # 圧縮対象ディレクトリ
    $path = ".\WindowsPowerShell"

    # 除外ルール (*ワイルドカード使用可能)
    $exclude = @("DH-WK","VSCode")

    # 圧縮対象フォルダ取得(除外フォルダ)
    $files = Get-ChildItem -Path $path -Exclude $exclude

    # 圧縮処理2
    Compress-Archive -Path $files -DestinationPath $destination
    if ($? -eq "True") {
       Write-Host '圧縮2（WindowsPowerShell）成功'
       Write-Host '圧縮1のDH-WK.zipを削除'
       Remove-Item ".\WindowsPowerShell\DH-WK.zip"
       if ($? -ne "True") {
            Write-Host 'DH-WK.zipの削除に失敗しました。'
        } else {
            Write-Host 'DH-WK.zip削除完了'
        }    
    } else {
           Write-Host '圧縮2（WindowsPowerShell）に失敗しました。'
           Write-Host　"エラー内容を確認してください。"
    }
}

#################################################################################
# copy-dir　　　　　　　　　　　　　　　　       
#################################################################################
<#
.SYNOPSIS(概要)
    ・指定したディレクトリ構成(第1階層)をコピーして別のディレクトリに作成する
.DESCRIPTION(説明)
    ・指定したディレクトリ構成(第1階層)情報を取得して、指定したディレクトリ内に同じ構成でディレクトリを作成する
.NOTES(注釈)
    ・作成元・先のディレクトリが確認できなければ、処理なしで終了する
.EXAMPLE(例)
    copy-dir
.UPDATE（更新日）
    ・2022-10-11 11:39:11
#>

function copy-dir
{

    #   Read-Hostのメッセージにカラーを付与するための関数
    function Set-Env() {
        param
        (
            [Parameter(Position = 0, ValueFromPipeline = $true)]
            [string]$msg,
            [string]$BackgroundColor = "DarkGray",
            [string]$ForegroundColor = "White"
        )
    
        Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor -NoNewline $msg;
        return Read-Host
    }
    

#ディレクトリ情報を取得(ディレクトリを指定)して同じ構成でディレクトリを作成
#カレントディレクトリ(１階層)のみ対応

$SourcePath = Set-Env "＜１＞取得するディレクトリ情報(１階層のみ)を入力（省略時は、処理を終了）："
$DestinationPath = Set-Env "＜２＞ディレクトリを作成するパスを入力（省略時は、処理を終了）："

#   $SourcePath の確認
if (Test-Path $SourcePath){
    Write-Host "▶     【作成元ディレクトリを確認しました。処理を継続します。】" -BackgroundColor 9
}
else{
    Write-Host "▶     【作成元ディレクトリを確認できませんでした。処理を終了します。】" -BackgroundColor 12
    return
}

#   $DestinationPath の確認
if (Test-Path $DestinationPath){
    Write-Host "▶     【作成先ディレクトリを確認しました。処理を継続します。】" -BackgroundColor 9
}
else{
    Write-Host "▶     【作成先ディレクトリを確認できませんでした。処理を終了します】" -BackgroundColor 12
    return
}

$Choice = Set-Env "▶     【ディレクトリの作成を開始しますか？[Y/N]】"
if ($Choice -ne "Y"){
    Write-Host "▶     【ディレクトリの作成処理をキャンセルしました。】" -BackgroundColor 9
    return    
}

#   作成元のディレクトリ情報からディレクトリ名のみ変数に格納
$SourceDir = (Get-ChildItem $SourcePath -Attributes directory).name 

#   作成先のディレクトリに作成元から取得したディレクトリ名でディレクトリを新規作成
Write-Host "▶     【ディレクトリ作成開始します。】" -BackgroundColor 9

#既存のフォルダを確認して、
#変数から要素を削除、
#削除した要素を別の変数に代入

#ForEach($CheckDir in $SourceDir){if (Test-Path $DestinationPath\$CheckDir) {$SourceDir = $SourceDir -ne $CheckDir}}
$ExistDir = @();
ForEach($CheckDir in $SourceDir){if (Test-Path $DestinationPath\$CheckDir) {
    $SourceDir = $SourceDir -ne $CheckDir
    if ($SourceDir -eq $False){
        Write-Host "▶     【作成するディレクトリが存在しないため処理をキャンセルしました。】" -BackgroundColor 12
        return
    }    
    $ExistDir += $CheckDir;
}}

#   からの場合のスキップ処理を追加
Write-Host "▶     【「$ExistDir」はすでに存在するため、作成をスキップします。】" -BackgroundColor 9

if ($SourceDir -eq $null){
    Write-Host "▶     【作成するディレクトリが存在しないため処理をキャンセルしました。】" -BackgroundColor 12
    return  
}
ForEach($MakeDir in $SourceDir){New-Item $DestinationPath -name $MakeDir -ItemType Directory}

#   作成後のディレクトリを確認
Write-Host #改行用
Write-Host "▶     【作成後のディレクトリを確認します。】" -BackgroundColor 9
Get-ChildItem $DestinationPath
}

#################################################################################
# get-dirsize　　　　　　　　　　　　　　　　       
#################################################################################
<#
.SYNOPSIS(概要)
    ・
.DESCRIPTION(説明)
    ・
.NOTES(注釈)
    ・
.EXAMPLE(例)
    get-dirsize
.UPDATE（更新日）
    ・
#>

function get-dirsize
{

    #   Read-Hostのメッセージにカラーを付与するための関数
    function Set-Env() {
        param
        (
            [Parameter(Position = 0, ValueFromPipeline = $true)]
            [string]$msg,
            [string]$BackgroundColor = "DarkGray",
            [string]$ForegroundColor = "White"
        )
    
        Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor -NoNewline $msg;
        return Read-Host
    }
    

#カレントディレクトリ(１階層)のみ対応

$TargetPath = Set-Env "▶     【取得するディレクトリ情報を入力（省略時は、処理を終了）】："

#   $TargetPath の確認
if (Test-Path $TargetPath){
    Write-Host "▶     【対象ディレクトリを確認しました。処理を継続します。】" -BackgroundColor 8
}
else{
    Write-Host "▶     【対象ディレクトリを確認できませんでした。処理を終了します。】" -BackgroundColor 12
    return
}

$Choice = Set-Env "▶     【ディレクトリのサイズ取得を開始しますか？[Y/N]】"
if ($Choice -ne "Y"){
    Write-Host "▶     【ディレクトリのサイズ取得処理をキャンセルしました。】" -BackgroundColor 8
    return    
}



Write-Host "▶     【ディレクトリサイズ取得を開始します。】" -BackgroundColor 8
#   サイズ変数を初期化
$size = 0

Get-ChildItem $TargetPath -Recurse | ForEach-Object {
    $size += $_.Length
}

Write-Host #改行用
Write-Host "▶     【ディレクトリサイズを表示します。】" -BackgroundColor 8
#   .NET Framework System.Mathクラス Roundメソッド
$sizeMB = [Math]::Round($($size/1MB),3)
$sizeGB = [Math]::Round($($size/1GB),3)
Write-Host "▶     【ディレクトリの合計サイズ(MB) {$TargetPath}: $sizeMB MB"
Write-Host "▶     【ディレクトリの合計サイズ(GB) {$TargetPath}: $sizeGB GB"
}


#################################################################################
# furufuru　　　　　　　　　　　　　　　　       
#################################################################################
function furufuru {
<#
.SYNOPSIS
    スクリーンセーバー・ロック回避用マウス移動ツール
.DESCRIPTION
    一定間隔でマウスカーソルをわずかに動かし、スクリーンセーバーや画面ロックを防止します。
.EXAMPLE
    furufuru
.NOTES
    Ctrl+C で停止してください。
#>

    # .NETのCursorクラスを利用するためにSystem.Windows.Formsをロード
    Add-Type -AssemblyName System.Windows.Forms

    # mouse_event の定義（既に定義済みならスキップ）
    if (-not ("Win32Functions.Win32MouseEventNew" -as [type])) {
        $signature = @'
            [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
            public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
        Add-Type -MemberDefinition $signature -Name "Win32MouseEventNew" -Namespace Win32Functions -PassThru | Out-Null
    }

    Write-Host "マウスふるふるを起動します。"
    Write-Host "Ctrl+Cで終了します。"

    # 定数・変数定義
    $MOUSEEVENTF_MOVE = 0x00000001
    $SleepSec = 50
    $MoveMouseDistance = 1
    $MoveMouseDistanceX = 1
    [bool]$Flag = $true

    try {
        while ($true) {
            Start-Sleep -Seconds $SleepSec

            # 現在位置取得
            $x = [System.Windows.Forms.Cursor]::Position.X
            $y = [System.Windows.Forms.Cursor]::Position.Y

            # マウスを左右にわずかに移動（物理的な動き）
            [Win32Functions.Win32MouseEventNew]::mouse_event($MOUSEEVENTF_MOVE, -$MoveMouseDistance, 0, 0, 0)
            [Win32Functions.Win32MouseEventNew]::mouse_event($MOUSEEVENTF_MOVE, $MoveMouseDistance, 0, 0, 0)

            # 座標を変更（アプリの座標監視対策）
            if ($Flag) {
                $x += $MoveMouseDistanceX
            } else {
                $x -= $MoveMouseDistanceX
            }
            $Flag = -not $Flag

            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
        }
    } finally {
        Write-Host "`nマウスふるふるを停止しました。"
    }
}

# --- 関数実行用 ---
# --- 関数を実行 ---
#furufuru

#################################################################################
#   Get-ListenPort
#################################################################################

function Get-ListenPort
{
    #   以下の条件でリッスン情報を取得
    #   -a:すべての接続とリッスン ポート
    #   -n:アドレスとポート番号を数値形式
    #   -o:所有するプロセス ID
    $ListeningPorts = netstat -ano | select-string LISTENIN
    write-host "プロトコル",",", "ローカルアドレス",",", "プロセス名"
        foreach ($ListeningPort in $ListeningPorts ) {
            $PortInfo = -split $ListeningPort.line
            $ProcessName = (get-process -id $PortInfo[4]).ProcessName

            write-host $PortInfo[0],",",$PortInfo[1],",",$ProcessName | format-table -autosize
        }
}

#################################################################################
# ★Replace-File　　　　　　　　　　　　　　　　       
#################################################################################
function Replace-File
{
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER FromFile

.PARAMETER ToFile

.PARAMETER Full

.NOTES
確認メッセージを表示
.EXAMPLE

.EXAMPLE

#>
# パラメータ宣言
param(
[String]$from,                      #「置換前の文字列」
[String]$to,                        #「置換後の文字列」
[String]$in,                        #「変換対象のフォルダ」
[String]$out,                       #「変換後のファイルの保存先」
[String]$encoding = "Shift_JIS"     #「テキスト・ファイルの文字コード」
)
$from = Read-Host "置換前文字を入力(入力がない場合、終了します)" 
if ($from -eq "") {
    Write-Host "入力がないため終了します"
    return
 }
$to = Read-Host "置換後文字を入力(入力がない場合、終了します)" 
if ($to -eq "") {
    Write-Host "入力がないため終了します"
    return
 }
$in = Read-Host "置換対象ファイル格納ディレクトリをフルパスで入力(入力がない場合、終了します)" 
if ($in -eq "") {
    Write-Host "入力がないため終了します"
    return
 }
$out = Read-Host "置換後ファイル格納ディレクトリをフルパスで入力(入力がない場合、終了します)" 
if ($out -eq "") {
    Write-Host "入力がないため終了します"
    return
 }

$result = yes_or_no
if ($result -eq 3) {
    return
}

# 引数$encodingから、文字コードを表すEncodingオブジェクトを生成
$enc = [Text.Encoding]::GetEncoding($encoding)
# 与えられたパス（c:\tmp\Convert）から合致するファイルリストを取得
# ディレクトリを再帰的に抽出する場合は（-recurse）
Get-ChildItem $in |
# 取得したファイルを順番に処理
ForEach-Object {
# 取得したオブジェクトがファイルの場合のみ処理（フォルダの場合はスキップ）
if($_.GetType().Name -eq "FileInfo"){
    # 変換元ファイルをStreamReaderオブジェクトで読み込み
$reader = New-Object IO.StreamReader($_.FullName, $enc)
# 保存先のパス、保存先の親フォルダのパスを生成
$o_path = $_.FullName.ToLower().Replace($in.ToLower(), $out)
$o_folder = Split-Path $o_path -parent
# 保存先のフォルダが存在しない場合にフォルダを自動生成
if(!(Test-Path $o_folder)){
[void][IO.Directory]::CreateDirectory($o_folder)
}
# 保存先ファイルをStreamWriterオブジェクトでオープン
$writer = New-Object IO.StreamWriter($o_path, $false, $enc)
# 変換元ファイルを順に読み込み、保存先ファイルに書き込み
while(!$reader.EndOfStream){
#$writer.WriteLine($reader.ReadLine().Replace($from, $to))
$str = $reader.ReadLine() -ireplace $from, $to
$writer.WriteLine($str)
}
# ファイルをすべてクローズ
$reader.Close()
$writer.Close()
}
}
}

#################################################################################
# ★get-chat　　　　　　　　　　　　　　　　       
#################################################################################
function get-chat {
    # 事前に Microsoft Graph PowerShell SDKのインストール　※要インターネット
    # Install-Module Microsoft.Graph

    # Microsoft.Graph関連モジュールインストール
    # Get-InstalledModule Microsoft.Graph*

    Import-Module Microsoft.Graph.Teams
    $RequiredScopes = @("Chat.Read")
    Connect-MgGraph -Scopes $RequiredScopes

    # ここは固有チャットIDの確認が必要
    $chatId = "19:f56a1d8891794779b4f61a4d5cff2007@thread.v2"
    # ファイル名にチャット名入れる
    $chatName = "チャット名"
    $chatMessages = Get-MgChatMessage -ChatId $chatId -All -PageSize 50

    $csv = @()
    foreach ($message in $chatMessages) {
        if ($message.body.contentType -eq "html") {
            $html = New-Object -ComObject "HTMLFile"
            $html.IHTMLDocument2_write($message.body.content)
            $message.body.content = $html.IHTMLDocument2_body.innerText
        }
        $data = New-Object PSObject | Select-Object DateTime, From, Content, Attachments
        $data.DateTime = $message.createdDateTime.AddHours(9)
        $data.From = $message.from.user.displayName
        $data.Content = $message.body.content
        $temp = $message.attachments | ForEach-Object { $_.ContentUrl}
        $data.Attachments = $temp -join "; "
        $csv += $data
    }
    # CSV格納を
    $csv | Export-Csv -Path $LogFolder\$chatName"_chat.csv" -NoTypeInformation -Encoding UTF8 -Force

    Disconnect-MgGraph

    Write-Host "出力したチャット情報のコピー処理開始"
    #Write-Host "クライアントのパスを入力（省略時は、処理終了。）"
    #$remote_dir = Read-Host '例：\\tsclient\C\Users\SEF175\Documents\WindowsPowerShell\DH-WK）'
    $kadai_dir = "パス"
    $hirono_readfile_dir = "パス"
    if (Test-Path $kadai_dir){
        # chat情報を移動(元は削除)、ミラーはしない
        robocopy /R:2 /W:2 /V "$LogFolder" "$hirono_readfile_dir" "チャット名_chat.csv" /TEE /LOG:$BackupFolder\robo_チャット名_chat.csv.log
        robocopy /R:2 /W:2 /V /MOV "$LogFolder" "$kadai_dir" "チャット名_chat.csv" /TEE /LOG+:$BackupFolder\robo_チャット名_chat.csv.log
    }else{
        Write-Host "指定しているクライアントパスにアクセスできないため処理を終了します。"
        return
    }
}

#################################################################################
# ★sakura　　　　　　　　　　　　　　　　       
#################################################################################
function sakura {
    # 保存先のディレクトリ
    $saveDir = $TextFolder

    # Sakuraエディタのパス
    $sakuraPath = "$ToolsFolder\sakura\sakura.exe"

    # 0バイトのファイルを削除する処理
    $zeroByteFiles = Get-ChildItem -Path $saveDir | Where-Object { $_.Length -eq 0 }

    foreach ($file in $zeroByteFiles) {
        Try {
            # ファイルが他のプロセスに使われていない場合、削除
            Remove-Item -Path $file.FullName -ErrorAction Stop
            Write-Host "Deleted: $($file.FullName)"
        }
        Catch {
            # ファイルが他のプロセスによって掴まれている場合はスキップ
            Write-Host "Skipped: $($file.FullName) - File is in use"
        }
    }

    # 現在の日時を取得して yyyymmddhhmmss 形式に変換
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    # 保存するファイル名を作成
    $saveFileName = "$timestamp.txt"

    # フルパスの作成
    $savePath = Join-Path $saveDir $saveFileName

    # 空のファイルを作成する
    New-Item -Path $savePath -ItemType File

    # Sakuraエディタでファイルを開く
    Start-Process -FilePath $sakuraPath -ArgumentList "`"$savePath`""

    # ファイル格納フォルダを開く
    Start-Process -FilePath $saveDir

    # 必要であれば、他の操作を続けることが可能

}



# Read-Hostのメッセージにカラーを付与するための関数(確認用)
function Set-Conf {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$msg,
        [string]$BackgroundColor = "DarkGray",
        [string]$ForegroundColor = "White"
    )

    Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor -NoNewline $msg
    return Read-Host
}

# Read-Hostのメッセージにカラーを付与するための関数(出力用)
function Set-Out {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$msg,
        [string]$BackgroundColor = "DarkBlue",
        [string]$ForegroundColor = "White"
    )

    Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor -NoNewline $msg
    return Read-Host
}

# Read-Hostのメッセージにカラーを付与するための関数(エラー出力用)
function Set-Err {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$msg,
        [string]$BackgroundColor = "DarkRed",
        [string]$ForegroundColor = "White"
    )

    Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor -NoNewline $msg
    return Read-Host
}

Set-Out "＜処理開始＞Outlookの受信トレイからメールを検索します。Enterを押してください。"

# 検索条件をインタラクティブに確認
$searchWord = Set-Conf "＜１＞検索する文字を入力（未入力はエラー終了）："
if ([string]::IsNullOrWhiteSpace($searchWord)) {
    Set-Err "検索文字が未入力です。処理を終了します。Enterを押してください。"
    return
}

$senderFilter = Set-Conf "＜２＞差出人で絞り込む場合、差出人名を入力（省略時はすべて対象）："
$dateFilter = Set-Conf "＜３＞受信日(yyyy/mm/dd)で絞り込む場合、日付を入力（省略時はすべて対象）："

Set-Out "▶ 【検索条件: '$searchWord', 差出人: '$senderFilter', 受信日: '$dateFilter' で検索します。Enterを押してください。】"

$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")
$inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)

$filterParts = @()
$filterParts += "@SQL=""urn:schemas:httpmail:textdescription"" LIKE '%$searchWord%' OR ""urn:schemas:httpmail:subject"" LIKE '%$searchWord%'"
if (-not [string]::IsNullOrWhiteSpace($senderFilter)) {
    $filterParts += "urn:schemas:httpmail:fromname LIKE '%$senderFilter%'"
}
if (-not [string]::IsNullOrWhiteSpace($dateFilter)) {
    $startDate = [DateTime]::Parse($dateFilter).ToString("yyyy/MM/dd 00:00")
    $endDate = [DateTime]::Parse($dateFilter).AddDays(1).ToString("yyyy/MM/dd 00:00")
    $filterParts += "urn:schemas:httpmail:datereceived >= '$startDate' AND urn:schemas:httpmail:datereceived < '$endDate'"
}

$filter = [string]::Join(" AND ", $filterParts)
$foundItems = $inbox.Items.Restrict($filter)

Write-Host "該当メール数：" $foundItems.Count

foreach ($mail in $foundItems) {
    $body = $mail.Body -replace "[\r\n]+", " "
    $subject = $mail.Subject
    $sender = $mail.SenderName
    $received = $mail.ReceivedTime.ToString("yyyy/MM/dd")

    Write-Host "件名：" $subject
    Write-Host "差出人：" $sender
    Write-Host "受信日時：" $received

    $pattern = ".{0,20}" + [regex]::Escape($searchWord) + ".{0,20}"
    $matches = [regex]::Matches($body, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($matches.Count -eq 0) {
        Write-Host "（該当箇所を取得できませんでした）"
    } else {
        foreach ($match in $matches) {
            $highlighted = $match.Value.Replace($searchWord, "[[$searchWord]]")
            Write-Host "該当部分：" $highlighted
        }
    }
    Write-Host "----------------------------"
}

[System.Runtime.InteropServices.Marshal]::ReleaseComObject($inbox) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($namespace) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null

$inbox = $namespace = $outlook = $null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Set-Out "検索処理が完了しました。Enterを押して終了してください。"
Read-Host

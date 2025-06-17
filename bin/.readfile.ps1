#################################################################################
#                     ファイル読み込み
#################################################################################
###	更新日：2022-04-18
#################################################################################
#                     読み込みファイルリスト読み込み
#################################################################################

#   読み込みファイルリスト読み込み
$read_file_list = Import-Csv $ReadFileFolder\.readfile_list.csv -Encoding Default # | Format-Table は入れると、配列にできない

#   読み込みファイルリスト（.readfile_list.csv）の行数取得　※列数は4列固定
#   行数定義
$low = (Get-Content -Path $ReadFileFolder\.readfile_list.csv -Encoding Default | Measure-Object -Line).Lines
#   列定義
$col = 4
#   1行目ヘッダー行を除外
$low = $low - 1

#   一次元配列定義
#   概要
$gaiyou = @()
#   読み込みファイル名
$filename = @()
#   変数名（呼び出し用）
$valiable = @()
#   詳細
$detail = @()

#   読み込みファイルリストから、該当行を一次元配列に格納
ForEach ($b in $read_file_list){
    $gaiyou += $b.概要
    $filename += $b.ファイル名
    $valiable += $b.変数名
    $detail += $b.詳細
}

#   二次元配列の定義　.readfile_list.csvのデータ格納、列,行　※ヘッダー行除く
$tdarray = New-Object "System.Object[,]"$col,$low

#   二次元配列へ一次元配列からデータを格納
#   二次元配列の始まりは[0][0]のため、配列数は[$col - 1][$low - 1]とする。
#   $retu,$gyou は配列から要素を取り出す一時的な配列数値として定義
$low = $low - 1
$col = $col - 1

for ($retu = 0 ; $retu -le $col ; $retu++){
    for ($gyou = 0 ; $gyou -le $low ; $gyou++){
        if  ($retu -eq 0){
            $tdarray[$retu,$gyou] = $gaiyou[$gyou]
        } elseif ($retu -eq 1){
            $tdarray[$retu,$gyou] = $filename[$gyou]
        } elseif ($retu -eq 2){
            $tdarray[$retu,$gyou] = $valiable[$gyou]
        } elseif ($retu -eq 3){
            $tdarray[$retu,$gyou] = $detail[$gyou]
        }
    }
}

#   配列から変数名を取得し、変数名（write_xxxx）を設定、値に配列から取得したファイルのデータを格納
#   Format-Table は ogv を使用できるようにコメントアウト
For ($gyou = 0 ; $gyou -le $low ; $gyou++){
    Set-Variable -name ($tdarray[2,$gyou]) -value (Import-Csv $ReadFileFolder\$($tdarray[1,$gyou]) -Encoding Default) #| Format-Table ※ogvを使用できるようにコメント)
}

#   $acount_host_list 個別対応
#   ★木津川
#   アカウントリストFormat-Table(ft):木津川
#$kizu = $acount_host_list.ForEach{if($_.組織名 -eq "木津川"){$_}} | Format-Table

#   $acount_host_list 個別対応
#   ★姫路
#   アカウントリストFormat-Table(ft):姫路
#$himeji = $acount_host_list.ForEach{if($_.組織名 -eq "姫路"){$_}} | Format-Table

#   $acount_host_list 個別対応
#   ★川崎
#   アカウントリストFormat-Table(ft):川崎
#$kawasaki = $acount_host_list.ForEach{if($_.組織名 -eq "川崎"){$_}} | Format-Table

#   ★名古屋
#   アカウントリストFormat-Table(ft):名古屋
#$nagoya = $acount_host_list.ForEach{if($_.組織名 -eq "名古屋"){$_}} | Format-Table

#   ★尼崎
#   アカウントリストFormat-Table(ft):尼崎
#$ama = $acount_host_list.ForEach{if($_.組織名 -eq "尼崎"){$_}} | Format-Table
#
#   ★金沢
#   アカウントリストFormat-Table(ft):金沢
#$kanazawa = $acount_host_list.ForEach{if($_.組織名 -eq "金沢"){$_}} | Format-Table
#
#   本番税
#$kanazawa_zh = $acount_host_list.ForEach{if(($_.組織名 -eq "金沢") -And ($_.環境区分 -eq "本番税")){$_}} | Format-Table
#   本番共通
#$kanazawa_kh = $acount_host_list.ForEach{if(($_.組織名 -eq "金沢") -And ($_.環境区分 -eq "本番共通")){$_}} | Format-Table
#   本番住記
#$kanazawa_jh = $acount_host_list.ForEach{if(($_.組織名 -eq "金沢") -And ($_.環境区分 -eq "本番住記")){$_}} | Format-Table

#   参考情報：アカウントリストOut-GridView(PowershelCoreにはない)
#   GUIのためコマンドレット実行時点でGUI表示されるため、変数に代入できない 
#$acount_host_list | ogv -OutputMode Multiple
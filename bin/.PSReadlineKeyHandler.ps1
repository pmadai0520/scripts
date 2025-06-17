#################################################################################
#                     PSReadlineKeyHandler設定          　　　　　　　　　　　　　　　    
#################################################################################

# bashに近いキーバインドに変更

# カーソル位置から行頭までのテキストを削除します
Set-PSReadlineKeyHandler -Key 'Ctrl+u' -Function BackwardDeleteLine
# カーソルを 1 文字前に戻します
Set-PSReadlineKeyHandler -Key 'Ctrl+b' -Function BackwardChar
# カーソルを 1 文字先に進めます
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -Function ForwardChar
# カーソル位置の文字を削除します
Set-PSReadlineKeyHandler -Key 'Ctrl+d' -Function DeleteChar
# カーソルの前の文字を削除します
Set-PSReadlineKeyHandler -Key 'Ctrl+h' -Function BackwardDeleteChar
# 履歴を逆方向に検索します
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
# 履歴を順方向に検索します
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward
# カーソルを行頭に移動します
Set-PSReadlineKeyHandler -Key 'Ctrl+a' -Function BeginningOfLine
# カーソルを行末に移動します
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -Function EndOfLine

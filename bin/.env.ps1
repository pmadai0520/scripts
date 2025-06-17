####################################################
### 更新日：2025-06-17 20:15:01
####################################################
#   環墁変数PATH定義
####################################################
#   PATH追加
####################################################

#   VSCode
$env:Path = $env:Path + ";$LscriptFolder\VSCode\"

#   sakura
$env:Path = $env:path + ";$ToolsFolder\sakura\"

#   winscp
$env:Path = $env:Path + ";$ToolsFolder\winscp\"

#   everything
$env:Path = $env:Path + ";$ToolsFolder\EverythingPortable\"

#   DU
$env:Path = $env:Path + ";$ToolsFolder\DU\"

#   teraterm
$env:path = $env:Path + ";$ToolsFolder\teraterm\"

#   shortcut
$env:path = $env:Path + ";$MITWK_BASE\shortcut\"

#   Sysinternals
$env:path = $env:Path + ";$ToolsFolder\SysinternalsSuite\"

#   vim
$env:path = $env:Path + ";$ToolsFolder\vim\"

#   WinMerge
$env:path = $env:Path + ";$ToolsFolder\WinMerge\"

#   UnixUtils
$env:path = $env:Path + ";$ToolsFolder\UnxUtils\usr\local\wbin\"
##	lessの日本語化対応
$env:LESSCHARSET = "dos"

#   Python
$env:path = $env:Path + ";$MITWK_BASE\bin\01_python\"

#   powershell
$env:path = $env:Path + ";$MITWK_BASE\bin\02_powershell\"

#   drowio
$env:path = $env:Path + ";$ToolsFolder\drawio\"
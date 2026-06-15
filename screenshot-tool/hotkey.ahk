; ===================================
; スクリーンショットツール ホットキー
; PrintScreen キーで即起動
; ===================================

#SingleInstance Force
#NoTrayIcon

; PrintScreen キーを押すと範囲選択キャプチャ起動
; 変えたい場合: PrintScreen を以下に書き換え
;   ^+s  → Ctrl+Shift+S
;   ^!s  → Ctrl+Alt+S
;   F12  → F12キー

^+s::
{
    scriptDir := A_ScriptDir
    Run('powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "' . scriptDir . '\screenshot.ps1"')
}

@echo off
echo AutoHotkey スタートアップ登録セットアップ
echo ==========================================

:: AutoHotkeyのパスを探す
set AHK_PATH=
if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" (
    set AHK_PATH=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe
) else if exist "C:\Program Files\AutoHotkey\AutoHotkey.exe" (
    set AHK_PATH=C:\Program Files\AutoHotkey\AutoHotkey.exe
) else (
    echo [エラー] AutoHotkey が見つかりません。
    echo 先に https://www.autohotkey.com/ からインストールしてください。
    pause
    exit /b 1
)

echo AutoHotkey: %AHK_PATH%

:: スタートアップフォルダにショートカット作成
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set SCRIPT_PATH=%~dp0hotkey.ahk

powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%STARTUP%\スクリーンショットHotkey.lnk'); $s.TargetPath = '%AHK_PATH%'; $s.Arguments = '\"%SCRIPT_PATH%\"'; $s.Save()"

echo.
echo [完了] PC起動時に自動でホットキーが有効になります。
echo 今すぐ有効にするには hotkey.ahk をダブルクリックしてください。
echo.
pause

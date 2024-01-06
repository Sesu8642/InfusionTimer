mkdir release

call flutter clean
call flutter build windows

:: zip to release directory
powershell Compress-Archive -Force "build/windows/x64/runner/Release/*" "release/enthusiast_timer_windows.zip"

pause
mkdir release

call .\flutter\bin\flutter.bat clean
call .\flutter\bin\flutter.bat build windows

:: zip to release directory
powershell Compress-Archive -Force "build/windows/x64/runner/Release/*" "release/enthusiast_timer_windows.zip"

pause
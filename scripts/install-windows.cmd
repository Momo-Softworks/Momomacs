@echo off
rem Double-click to install Momomacs on Windows. Arguments are passed through,
rem e.g.  install-windows.cmd -NoSpellCheck
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1" %*
echo.
pause

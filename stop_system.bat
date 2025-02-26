@echo off
echo Stopping ProXDefend XDR System...

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Please run as Administrator
    pause
    exit /b 1
)

REM Stop Windows Agent if running
echo Stopping Windows Agent...
sc query ProXDefendAgent >nul 2>&1
if %errorLevel% equ 0 (
    net stop ProXDefendAgent
)

REM Stop Node.js processes (Web Interface)
echo Stopping Web Interface...
taskkill /F /IM node.exe >nul 2>&1

REM Stop Python processes (XDR Server)
echo Stopping XDR Server...
taskkill /F /IM python.exe >nul 2>&1

REM Optionally stop MongoDB
set /p STOP_MONGO="Stop MongoDB? (y/n): "
if /i "%STOP_MONGO%"=="y" (
    echo Stopping MongoDB...
    net stop MongoDB
)

echo.
echo ProXDefend XDR System stopped successfully!
echo.
echo Press any key to exit this window...
pause >nul

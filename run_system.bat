@echo off
echo Starting ProXDefend XDR System...

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Please run as Administrator
    pause
    exit /b 1
)

REM Start MongoDB if not running
echo Checking MongoDB...
sc query MongoDB >nul 2>&1
if %errorLevel% neq 0 (
    echo Starting MongoDB...
    net start MongoDB
    if %errorLevel% neq 0 (
        echo Error: Failed to start MongoDB
        pause
        exit /b 1
    )
)

REM Start XDR Server
echo Starting XDR Server...
cd server
start "ProXDefend XDR Server" python xdr_server.py
cd ..

REM Wait for server to initialize
timeout /t 5 /nobreak

REM Start Web Interface
echo Starting Web Interface...
cd frontend
start "ProXDefend Web Interface" npm run dev
cd ..

REM Start Windows Agent if on Windows
echo Checking Windows Agent...
sc query ProXDefendAgent >nul 2>&1
if %errorLevel% neq 0 (
    echo Starting Windows Agent...
    net start ProXDefendAgent
    if %errorLevel% neq 0 (
        echo Warning: Failed to start Windows Agent
    )
)

echo.
echo ProXDefend XDR System started successfully!
echo Server running on https://localhost:8443
echo Web Interface running on http://localhost:3000
echo.
echo Press any key to exit this window...
pause >nul

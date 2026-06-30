@echo off
chcp 65001 >nul
title TELEFORGE
color 0D
cls
echo.
echo   ████████████████████████████████████████████████████████████████████████████
echo   █                                                                           █
echo   █  ███████ ███████ ██      ███████ ███████  █████ ███████  █████ ███████  █
echo   █   █████ ██      ██      ██      ██      ██   ██ ██   ██ ██      ██       █
echo   █   █████ ███████ ██      ███████ ███████ ██   ██ ███████ ██ ████ ███████  █
echo   █   █████ ██      ██      ██      ██      ██   ██ ██ ████ ██   ██ ██       █
echo   █   █████ ███████ ███████ ███████ ██       █████ ██   ██  █████ ███████  █
echo   █                                                                           █
echo   ████████████████████████████████████████████████████████████████████████████
echo.
echo          CLAUDE CODE  +  OPENCODE FREE MODELS
echo          Channel: https://t.me/TeleforgeOfficial
echo.
echo.
start https://t.me/TeleforgeOfficial
echo [*] Checking system requirements...
echo.

:: ========== CHECK ADMIN ==========
net session >nul 2>&1
set ADMIN=%errorlevel%

:: ========== CHECK / INSTALL NODE.JS ==========
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Node.js not found. Installing...
    echo     Downloading Node.js LTS...
    curl -L -o "%TEMP%\node.msi" "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi" --progress-bar
    if %ADMIN% equ 0 (
        msiexec /i "%TEMP%\node.msi" /quiet /norestart
    ) else (
        echo [!] Run as Administrator for Node.js install, or install manually from nodejs.org
        pause
    )
    echo [*] Installing... please wait.
    call waitfor /t 15 >nul
    call refreshenv >nul 2>&1
    set "PATH=%PATH%;C:\Program Files\nodejs\;%APPDATA%\npm\"
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VER=%%i
    echo [OK] Node.js %NODE_VER%
)

:: ========== CHECK / INSTALL PYTHON ==========
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Python not found. Installing...
    echo     Downloading Python...
    curl -L -o "%TEMP%\python-installer.exe" "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" --progress-bar
    "%TEMP%\python-installer.exe" /quiet InstallAllUsers=0 PrependPath=1
    echo [*] Installing... please wait.
    call waitfor /t 15 >nul
    set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Python\Python311\;%LOCALAPPDATA%\Programs\Python\Python311\Scripts\"
) else (
    for /f "tokens=*" %%i in ('python --version') do set PY_VER=%%i
    echo [OK] Python %PY_VER%
)

:: ========== INSTALL PIP REQUESTS ==========
python -c "import requests" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Installing Python requests library...
    pip install requests -q
)
echo [OK] Python requests ready
echo.

:: ========== GET API KEY ==========
cls
echo ============================================
echo   ENTER YOUR OPENCODE API KEY
echo ============================================
echo.
echo Get it from: https://opencode.ai/auth
echo.
set /p API_KEY="API Key: "
if "%API_KEY%"=="" (
    echo [!] API key required!
    pause
    exit /b 1
)
echo [OK] API key saved
echo.

:: ========== UNINSTALL OLD CLAUDE ==========
echo [*] Removing old Claude Code if exists...
call npm uninstall -g @anthropic-ai/claude-code 2>nul
echo [OK] Old version removed
echo.

:: ========== INSTALL CLAUDE CODE ==========
echo [*] Installing Claude Code v2.1.196...
call npm install -g @anthropic-ai/claude-code@2.1.196
if %errorlevel% neq 0 (
    echo [!] Installation failed! Check internet connection.
    pause
    exit /b 1
)
echo [OK] Claude Code v2.1.196 installed
echo.

:: ========== SAVE API KEY ==========
echo %API_KEY% > "%USERPROFILE%\.opencode_key"
echo [OK] API key saved
echo.

:: ========== COPY PROXY ==========
copy "%~dp0proxy.py" "%USERPROFILE%\proxy.py" >nul
echo [OK] Proxy script copied
echo.

:: ========== CREATE SETTINGS.JSON ==========
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
(
echo {
echo   "$schema": "https://json.schemastore.org/claude-code-settings.json",
echo   "env": {
echo     "ANTHROPIC_BASE_URL": "http://127.0.0.1:4001",
echo     "ANTHROPIC_API_KEY": "%API_KEY%",
echo     "CLAUDE_CODE_DISABLE_LEGACY_MODEL_REMAP": "1"
echo   },
echo   "model": "claude-opus-4-1",
echo   "theme": "dark"
echo }
) > "%USERPROFILE%\.claude\settings.json"
echo [OK] settings.json created
echo.

:: ========== CREATE START_CLAUDE.BAT ON DESKTOP ==========
set "SC=%USERPROFILE%\Desktop\start_claude.bat"
echo @echo off > "%SC%"
echo chcp 65001 ^>nul >> "%SC%"
echo title TELEFORGE >> "%SC%"
echo color 0D >> "%SC%"
echo cls >> "%SC%"
echo echo. >> "%SC%"
echo echo   ████████████████████████████████████████████████████████████████████████████ >> "%SC%"
echo echo   █                                                                           █ >> "%SC%"
echo echo   █  ███████ ███████ ██      ███████ ███████  █████ ███████  █████ ███████  █ >> "%SC%"
echo echo   █   █████ ██      ██      ██      ██      ██   ██ ██   ██ ██      ██       █ >> "%SC%"
echo echo   █   █████ ███████ ██      ███████ ███████ ██   ██ ███████ ██ ████ ███████  █ >> "%SC%"
echo echo   █   █████ ██      ██      ██      ██      ██   ██ ██ ████ ██   ██ ██       █ >> "%SC%"
echo echo   █   █████ ███████ ███████ ███████ ██       █████ ██   ██  █████ ███████  █ >> "%SC%"
echo echo   █                                                                           █ >> "%SC%"
echo echo   ████████████████████████████████████████████████████████████████████████████ >> "%SC%"
echo echo. >> "%SC%"
echo echo          CLAUDE CODE  +  OPENCODE FREE MODELS >> "%SC%"
echo echo          Channel: https://t.me/TeleforgeOfficial >> "%SC%"
echo echo. >> "%SC%"
echo echo [*] Starting Proxy... >> "%SC%"
echo start /B python "%USERPROFILE%\proxy.py" >> "%SC%"
echo timeout /t 3 /nobreak ^>nul >> "%SC%"
echo echo. >> "%SC%"
echo echo  ============================================================ >> "%SC%"
echo echo    [OK] Proxy is running on port 4001 >> "%SC%"
echo echo    [OK] Type this command to start Claude: >> "%SC%"
echo echo. >> "%SC%"
echo echo          ^>^>^>  claude  ^<^<^< >> "%SC%"
echo echo. >> "%SC%"
echo echo    Press Ctrl+C to stop proxy when done >> "%SC%"
echo echo  ============================================================ >> "%SC%"
echo echo. >> "%SC%"
echo cmd /k >> "%SC%"
echo [OK] start_claude.bat created on Desktop!
echo.

:: ========== CLEANUP ==========
del "%TEMP%\node.msi" "%TEMP%\python-installer.exe" 2>nul

:: ========== DONE ==========
cls
echo ============================================
echo            SETUP COMPLETE!
echo ============================================
echo.
echo [OK] Claude Code v2.1.196 installed
echo [OK] Proxy configured
echo [OK] API key saved
echo [OK] start_claude.bat on Desktop
echo.
echo  DOUBLE-CLICK: start_claude.bat (Desktop)
echo.
echo  Need help? https://t.me/TeleforgeOfficial
echo.
pause

@echo off
setlocal

echo Checking for existing Python 3 installation...

REM 1. Check if 'python' is already valid (Version 3.x)
python --version 2>nul | findstr /b /c:"Python 3." >nul
if %ERRORLEVEL% NEQ 0 goto :Install

REM --- PYTHON FOUND ---
for /f "tokens=*" %%v in ('python --version 2^>nul') do echo Found %%v. Skipping installation.
echo.
pause
exit /b 0

:Install
REM --- PYTHON MISSING ---
echo Python 3 not found. Installing Python 3.13 from Microsoft Store...

winget install --name "Python 3.13" --exact --source msstore --accept-package-agreements --accept-source-agreements --silent

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installation failed.
    exit /b 1
)

REM --- VERIFY IMMEDIATE AVAILABILITY ---
echo.
echo Verifying installation...
python --version 2>nul | findstr /b /c:"Python 3." >nul

if %ERRORLEVEL% EQU 0 (
    echo -----------------------------------------------------------------------
    echo Success! Python is installed and ready to use immediately.
    echo -----------------------------------------------------------------------
) else (
    echo -----------------------------------------------------------------------
    echo Success. However, you must RESTART your terminal to update the Path.
    echo -----------------------------------------------------------------------
)

endlocal

pause

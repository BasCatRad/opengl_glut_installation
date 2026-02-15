@echo off
setlocal enabledelayedexpansion
title OpenGL GLUT Installer
color 0A

echo ============================================
echo   OpenGL GLUT - Visual Studio Installer
echo ============================================
echo.

:: -----------------------------------------------
:: 1. Check for administrator privileges
:: -----------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Administrator privileges required.
    echo     Requesting elevation...
    echo.
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

echo [OK] Running as Administrator.
echo.

:: -----------------------------------------------
:: 2. Determine script location (where files are)
:: -----------------------------------------------
set "SCRIPT_DIR=%~dp0"

:: -----------------------------------------------
:: 3. Auto-detect Visual Studio Documents folder
:: -----------------------------------------------
set "VS_FOUND="
for /d %%D in ("%USERPROFILE%\Documents\Visual Studio *") do (
    set "VS_DIR=%%D"
    set "VS_FOUND=1"
)

if not defined VS_FOUND (
    echo [ERROR] Could not find a "Visual Studio *" folder in:
    echo         %USERPROFILE%\Documents\
    echo.
    echo Please make sure Visual Studio is installed and has been
    echo launched at least once.
    echo.
    pause
    exit /b 1
)

echo [OK] Found Visual Studio folder:
echo      %VS_DIR%
echo.

set "TEMPLATE_DEST=%VS_DIR%\Templates\ProjectTemplates\OpenGL GLUT Project"

:: -----------------------------------------------
:: 4. Copy the project template
:: -----------------------------------------------
echo [..] Installing project template...

if exist "%TEMPLATE_DEST%" (
    echo      Removing old template...
    rmdir /s /q "%TEMPLATE_DEST%" >nul 2>&1
)

robocopy "%SCRIPT_DIR%OpenGL GLUT Project" "%TEMPLATE_DEST%" /e /xd .vs /njh /njs /ndl /nc /ns /np >nul 2>&1

if exist "%TEMPLATE_DEST%\OpenGL GLUT Project\MyTemplate.vstemplate" (
    echo [OK] Project template installed to:
    echo      %TEMPLATE_DEST%
) else (
    echo [ERROR] Failed to copy project template.
    echo         Source: %SCRIPT_DIR%OpenGL GLUT Project
    echo         Dest:   %TEMPLATE_DEST%
    pause
    exit /b 1
)
echo.

:: -----------------------------------------------
:: 5. Copy DLLs to system directories
:: -----------------------------------------------
echo [..] Installing freeglut DLLs...

:: x64 DLL -> System32
if exist "%SCRIPT_DIR%x64\freeglut.dll" (
    copy /y "%SCRIPT_DIR%x64\freeglut.dll" "%SystemRoot%\System32\freeglut.dll" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] x64 freeglut.dll -^> %SystemRoot%\System32\
    ) else (
        echo [ERROR] Failed to copy x64 freeglut.dll to System32.
    )
) else (
    echo [SKIP] x64\freeglut.dll not found, skipping.
)

:: x86 DLL -> SysWOW64
if exist "%SCRIPT_DIR%x86\freeglut.dll" (
    copy /y "%SCRIPT_DIR%x86\freeglut.dll" "%SystemRoot%\SysWOW64\freeglut.dll" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] x86 freeglut.dll -^> %SystemRoot%\SysWOW64\
    ) else (
        echo [ERROR] Failed to copy x86 freeglut.dll to SysWOW64.
    )
) else (
    echo [SKIP] x86\freeglut.dll not found, skipping.
)

echo.

:: -----------------------------------------------
:: 6. Done
:: -----------------------------------------------
echo ============================================
echo   Installation complete!
echo ============================================
echo.
echo   Next steps:
echo   1. Restart Visual Studio if it is open.
echo   2. File -^> New -^> Project
echo   3. Search for "OpenGL GLUT Project"
echo   4. Build and run!
echo.
pause

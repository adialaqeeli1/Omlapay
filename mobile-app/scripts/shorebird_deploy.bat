@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  OmlaPay - Shorebird Deploy (Windows wrapper)
REM ------------------------------------------------------------
REM  Thin wrapper that forwards to scripts/shorebird_deploy.sh.
REM  All logic lives in the .sh - this only ensures a bash shell
REM  exists (Git Bash / WSL), installing Git Bash if neither is
REM  present, then runs the script with your args.
REM
REM  Usage (from cmd.exe or PowerShell):
REM    scripts\shorebird_deploy.bat release
REM    scripts\shorebird_deploy.bat release --version=1.0.1
REM    scripts\shorebird_deploy.bat patch
REM    scripts\shorebird_deploy.bat patch --patch-version=1.0.0+36 --platforms=android
REM ============================================================

REM Move to the project root (parent of this scripts\ folder).
pushd "%~dp0.."

echo.
echo ============================================================
echo  Shorebird Deploy (Windows) - checking for a bash shell...
echo ============================================================

REM --- Try to locate a bash shell ---
call :detect_bash
if defined BASH goto :run_bash

REM --- No Git Bash. Is WSL available? Use it without installing. ---
where wsl >nul 2>nul
if !ERRORLEVEL! equ 0 goto :run_wsl

REM --- Nothing found: install Git for Windows (Git Bash), then re-check. ---
echo No Git Bash or WSL found. Installing Git for Windows...
call :install_git

call :detect_bash
if defined BASH (
    echo.
    echo Git Bash installed successfully.
    goto :run_bash
)

echo.
echo [ERROR] Git Bash is still not available after the install attempt.
echo Please install Git for Windows manually, then re-run:
echo   https://git-scm.com/download/win
set "EXIT_CODE=1"
pause
goto :done

REM ============================================================
:run_bash
echo Using bash: !BASH!
echo Running: scripts/shorebird_deploy.sh %*
echo.
"!BASH!" "scripts/shorebird_deploy.sh" %*
set "EXIT_CODE=!ERRORLEVEL!"
goto :done

REM ============================================================
:run_wsl
echo No Git Bash found - using WSL.
echo Running: bash scripts/shorebird_deploy.sh %*
echo.
wsl bash "scripts/shorebird_deploy.sh" %*
set "EXIT_CODE=!ERRORLEVEL!"
goto :done

REM ============================================================
REM  :detect_bash  -> sets BASH if a Git Bash shell is found
REM ============================================================
:detect_bash
set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "BASH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
if not defined BASH for /f "delims=" %%i in ('where bash 2^>nul') do if not defined BASH set "BASH=%%i"
exit /b 0

REM ============================================================
REM  :install_git  -> winget first, then PowerShell download
REM ============================================================
:install_git
REM 1. Prefer winget (built into modern Windows 10/11).
where winget >nul 2>nul
if !ERRORLEVEL! equ 0 (
    echo Installing Git via winget ^(a UAC prompt may appear^)...
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    exit /b 0
)

REM 2. Fallback: download the latest Git installer from GitHub and run it silently.
echo winget not found - downloading the Git for Windows installer...
set "GIT_INSTALLER=%TEMP%\GitForWindowsInstaller.exe"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$r = Invoke-RestMethod -UseBasicParsing https://api.github.com/repos/git-for-windows/git/releases/latest;" ^
  "$a = $r.assets ^| Where-Object { $_.name -like '*-64-bit.exe' } ^| Select-Object -First 1;" ^
  "if (-not $a) { Write-Error 'Could not find a Git installer asset.'; exit 1 };" ^
  "Write-Host ('Downloading ' + $a.name + ' ...');" ^
  "Invoke-WebRequest -UseBasicParsing $a.browser_download_url -OutFile '%GIT_INSTALLER%'"
if !ERRORLEVEL! neq 0 (
    echo [ERROR] Failed to download the Git installer.
    exit /b 1
)
echo Running the Git installer silently ^(a UAC prompt may appear^)...
"%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP- /SUPPRESSMSGBOXES /COMPONENTS=""
del "%GIT_INSTALLER%" >nul 2>nul
exit /b 0

REM ============================================================
:done
popd
endlocal & exit /b %EXIT_CODE%

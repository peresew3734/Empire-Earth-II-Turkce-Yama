@echo off
chcp 65001 >nul
title Empire Earth II - Turkce Yamayi Geri Al
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Ee2Yama.ps1" -Mode Undo
echo.
echo Yama geri alindi. Oyun yeniden Ingilizce.
pause
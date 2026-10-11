@echo off
chcp 65001 >nul
title Empire Earth II - Turkce Yama Kontrolu
cd /d "%~dp0"
echo.
echo  Yamanin kurulu olup olmadigini kontrol ediyor...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Ee2Yama.ps1" -Mode Check
echo.
pause

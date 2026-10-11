@echo off
chcp 65001 >nul
title Empire Earth II - Turkce Yama Kurulumu
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Ee2Yama.ps1" -Mode Install
echo.
echo Tamamlandi. Simdi oyunu baslatabilirsiniz.
echo (Ilk acilista metin dosyalari yeniden derlenir, bu birkac saniye surebilir.)
pause
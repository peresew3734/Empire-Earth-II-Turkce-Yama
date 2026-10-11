@echo off
chcp 65001 >nul
title Empire Earth II - Turkce Yama (ASCII Karakter Modu)
cd /d "%~dp0"
echo.
echo  Turkce karakterler oyunun fontunda gorunmezse bu modu kullanin.
echo  Harfler duz harflere indirgenir: ı=i  İ=I  ş=s  Ş=S  ğ=g  Ğ=G
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Ee2Yama.ps1" -Mode Install -Kodlama Ascii
echo.
echo Tamamlandi. Simdi oyunu baslatabilirsiniz.
pause
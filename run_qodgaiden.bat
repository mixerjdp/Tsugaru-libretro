@echo off
setlocal

set "TSUGARU_CDROM_FIRST_MODE1READ_TRACE=1"
set "TSUGARU_CDROM_FIRST_MODE1READ_TRACE_LIMIT=128"

set "EXE=C:\sw\Tsugaru\gui\build-vs\main_cui\Release\Tsugaru_CUI.exe"
set "WORK=C:\sw\Tsugaru\gui\build-vs\main_cui\Release"
set "ROMDIR=C:\sw\Tsugaru\gui\build-vs\main_gui\Release"
set "CDIMG=D:\Emulation\ROMs\FmTowns\tqodga\Queen of Duellist Gaiden, The + Gaiden Alpha (Japan).chd"

pushd "%WORK%"
"%EXE%" "%ROMDIR%" -APP QODGAIDEN -CD "%CDIMG%" -BOOTKEY CD
popd

endlocal

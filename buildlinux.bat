@echo off
setlocal

set "ROOT=%~dp0"
set "SSH_HOST=juan@192.168.31.128"
set "REMOTE_DIR=/home/juan/tsugaru"
set "BUILD_DIR=%ROOT%libretro-build\linux64"

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Building Tsugaru libretro core for Linux on VM...

ssh %SSH_HOST% "cd %REMOTE_DIR% && git pull --rebase 2>&1" >nul
if errorlevel 1 (
    echo Cloning repository...
    ssh %SSH_HOST% "git clone https://github.com/mixerjdp/TOWNSEMU.git %REMOTE_DIR%"
)
if errorlevel 1 exit /b %errorlevel%

echo Configuring CMake...
ssh %SSH_HOST% "rm -rf %REMOTE_DIR%/build_linux && cmake -S %REMOTE_DIR%/src -B %REMOTE_DIR%/build_linux -DBUILD_LIBRETRO_CORE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON 2>&1"
if errorlevel 1 exit /b %errorlevel%

echo Building...
ssh %SSH_HOST% "cd %REMOTE_DIR%/build_linux && cmake --build . --parallel --target tsugaru_libretro 2>&1"
if errorlevel 1 exit /b %errorlevel%

echo Copying .so to local...
scp %SSH_HOST%:%REMOTE_DIR%/build_linux/libretro/tsugaru_libretro.so "%BUILD_DIR%\tsugaru_libretro.so"
if errorlevel 1 exit /b %errorlevel%

echo Copying .info file...
copy /Y "%ROOT%tsugaru_libretro.info" "%BUILD_DIR%\tsugaru_libretro.info" >nul

echo Done. Built: %BUILD_DIR%\tsugaru_libretro.so
exit /b 0
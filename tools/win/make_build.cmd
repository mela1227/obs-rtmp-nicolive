@echo off
rem make build tool for obs-rtmp-nicolive

rem ##### Settings #####
rem You must change follow lines to suite your environment.
set OBS_APP=C:\Program Files (x86)\obs-studio
set OBS_SRC=%HOMEDRIVE%%HOMEPATH%\Documents\obs-studio-0.16.3
set CURL_SRC=%HOMEDRIVE%%HOMEPATH%\Documents\curl-7.49.0

set QT_VERSION=5.7
set QT_DIR=C:\Qt
set QT32_DIR=%QT_DIR%
set QT64_DIR=%QT_DIR%

set MINGW_DIR=C:\MinGW
set VS2015_DIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0
set CMAKE_DIR=C:\Program Files\CMake\bin

rem ##### Create variables (should not modified) #####
set PEXPORTS_EXE=%MINGW_DIR%\bin\pexports.exe
set LIB_EXE=%VS2015_DIR%\VC\bin\lib.exe
set QT32_CMAKE=%QT32_DIR%\%QT_VERSION%\msvc2015\lib\cmake
set QT64_CMAKE=%QT64_DIR%\%QT_VERSION%\msvc2015_64\lib\cmake
set CMAKE_EXE=%CMAKE_DIR%\cmake.exe

rem ##### Checking #####
rem check current directory
cd ..\..
if /i "%CD%\tools\win\make_build.cmd" neq "%~f0" call :die "You must run this batch on the top directory of sources" 255

rem check file
call :check_exist "%PEXPORTS_EXE%" "Not found pexports.exe. Please install mingw32-pexpots or change MINGW_DIR"
call :check_exist "%LIB_EXE%" "Not found lib.exe. Please install VS2015 or change VS2015_DIR"
call :check_exist "%QT32_CMAKE%" "Not found qt 32bit cmake. Please install Qt msvc2015_opengl or change QT32_DIR"
call :check_exist "%QT64_CMAKE%" "Not found qt 64bit cmake. Please install Qt msvc2015_64_opengl or change QT64_DIR"
call :check_exist "%OBS_APP%" "Not found obs-studio application. Please install obs-stduio application or change OBS_APP"
call :check_exist "%OBS_SRC%" "Not found obs-studio sourcs. Please install obs-stduio soruces or change OBS_SRC"
call :check_exist "%CURL_SRC%" "Not found curl sourcs. Please install curl soruces or change CURL_SRC"
call :check_exist "%CMAKE_EXE%" "Not found cmake. Please install cmake or change CMAKE_DIR"

"%CMAKE_EXE%" > NUL 2>&1
if errorlevel 1 call :die "Failed check CMake. Please install CMake ant set PATH"

echo Check all ok, and will create build environments.
echo Will remove all files in build, build32, and build64.
set /p REPLY="Are you ok? [y|N]:"
if /i "0%REPLY:~0,1%0" neq "0y0" call :die Canceled 0

rem ##### Create build environments #####
if exist build rmdir /s /q build
if exist build32 rmdir /s /q build32
if exist build64 rmdir /s /q build64

mkdir build
if errorlevel 1 call :die "Failed mkdir build"
mkdir build32
if errorlevel 1 call :die "Failed mkdir build32"
mkdir build64
if errorlevel 1 call :die "Failed mkdir build64"

mkdir build\lib32
mkdir build\lib64

rem obs.dll
"%PEXPORTS_EXE%" /EXPORTS "%OBS_APP%\bin\32bit\obs.dll" > "build\lib32\obs.def"
"%PEXPORTS_EXE%" /EXPORTS "%OBS_APP%\bin\64bit\obs.dll" > "build\lib64\obs.def"
"%LIB_EXE%" /MACHINE:x86 /def:"build\lib32\obs.def" /out:"build\lib32\obs.lib"
"%LIB_EXE%" /MACHINE:x64 /def:"build\lib64\obs.def" /out:"build\lib64\obs.lib"
rem libcurl.dll
"%PEXPORTS_EXE%" /EXPORTS "%OBS_APP%\bin\32bit\libcurl.dll" > "build\lib32\libcurl.def"
"%PEXPORTS_EXE%" /EXPORTS "%OBS_APP%\bin\64bit\libcurl.dll" > "build\lib64\libcurl.def"
"%LIB_EXE%" /MACHINE:x86 /def:"build\lib32\libcurl.def" /out:"build\lib32\libcurl.lib"
"%LIB_EXE%" /MACHINE:x64 /def:"build\lib64\libcurl.def" /out:"build\lib64\libcurl.lib"

rem TODO
echo "%CMAKE_EXE%" -G"Visual Studio 14 2015" -DCMAKE_PREFIX_PATH="%QT32_CMAKE:\=/%" -DOBS_SRC="%OBS_SRC:\=/%" -DOBS_APP="%OBS_APP:\=/%" -DcurlPath="%CURL_SRC:\=/%" -D_CURL_LIBRARY_DIRS=./build .. > build32\run_cmake.cmd
echo @echo ##### CMake done. Please open rtmp-nicolive.sln ##### >> build32\run_cmake.cmd
echo @echo You MUST change Debug to Release before build! >> build32\run_cmake.cmd
echo pause >> build32\run_cmake.cmd

echo "%CMAKE_EXE%" -G"Visual Studio 14 2015 Win64" -DCMAKE_PREFIX_PATH="%QT64_CMAKE:\=/%" -DOBS_SRC="%OBS_SRC:\=/%" -DOBS_APP="%OBS_APP:\=/%" -DcurlPath="%CURL_SRC:\=/%" -D_CURL_LIBRARY_DIRS=./build .. > build64\run_cmake.cmd
echo @echo ##### CMake done. Please open rtmp-nicolive.sln ##### >> build64\run_cmake.cmd
echo @echo You MUST change Debug to Release before build! >> build64\run_cmake.cmd
echo pause >> build64\run_cmake.cmd

copy tools\win\_make_package.cmd build\make_package.cmd

echo ##### Succeeded to create build environments. Please cmake and build. #####
echo Next step
echo cd ..\build32 and run run_cmake.cmd and build rtmp-nicolive.sln
echo cd ..\build64 and run run_cmake.cmd and build rtmp-nicolive.sln
echo cd ..\build and make_package.cmd
echo and last, copy your obs-studio application directory!
pause
start build
start build32
start build64

goto :eof

rem ##### Modules #####
:check_exist
set file_path=%~1
set fail_message=%~2
if not exist "%file_path%" call :die "%fail_message%"
goto :eof

:die
set message=%~1
if "a%~2a" == "aa" (
	set /a code=1
) else (
	set /a code=%~2
)
echo %message%
pause
exit %code%
goto :eof

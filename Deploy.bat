:: Deploy script for BogBat.
::
:: This script compiles release versions of the 64 bit build of BogBat and 
:: places it in a zip file ready for release.
::
:: This script uses MSBuild and InfoZip's zip.exe. The MSBuild project also
:: requires an executable version of BogBat itself.
::
:: Get zip.exe from https://delphidabbler.com/extras/info-zip
:: Get BogBat from https://delphidabbler.com/software/bogbat

:: To use the script:
::   1) Start the Embarcadero RAD Studio Command Prompt to set the required
::      environment variables for MSBuild.
::   2) Set the ZipRoot environment variable to the directory where zip.exe is
::      installed.
::   3) Set the BogBatRoot environment variable to the directory where
::      BogBat.exe is installed.
::   3) Change directory to that where this script is located.
::   4) Run the script.
::
:: Usage:
::   Deploy <version>
:: where
::   <version> is the version number of the release, e.g. 0.5.3-beta or 1.2.0.

@echo off

echo ------------------------
echo Deploying BogBat Release
echo ------------------------

:: Check for required parameter
if "%1"=="" goto paramerror

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror
if "%BogBatRoot%"=="" goto envvarerror

:: Set variables
set Version=%1
set BuildRoot=.\_build
set Win64Dir=%BuildRoot%\Win64\Release\exe
set ReleaseDir=%BuildRoot%\release
set OutFile=%ReleaseDir%\bogbat-exe-%Version%.zip
set SrcDir=src
set ProjectName=BogBat
set Exe64=%ProjectName%.exe
set ReadMe=%ReleaseDir%\README.txt
set WebDocs=https://github.com/ddabapps/bogbat/blob/main/README.md

:: Make a clean directory structure
if exist %BuildRoot% rmdir /S /Q %BuildRoot%
mkdir %ReleaseDir%

setlocal

:: Build Pascal
cd %SrcDir%

echo.
echo Building 64 bit version
echo.
msbuild %ProjectName%.dproj /p:config=Release /p:platform=Win64
echo.

endlocal

:: Create read-me file
echo For installation information see %WebDocs% > %ReadMe%

:: Create zip files
echo.
echo Creating zip files
%ZipRoot%\zip.exe -j -9 %OutFile% %Win64Dir%\%EXE64%
%ZipRoot%\zip.exe -j -9 %OutFile% %ReadMe%

del %ReadMe%

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:paramerror
echo.
echo ***ERROR: Please specify a version number as a parameter
echo.
goto end

:envvarerror
echo.
echo ***ERROR: ZipRoot and/or BogBatRoot environment variables not set
echo.
goto end

:: End
:end

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
::   Deploy

@echo off

echo ------------------------
echo Deploying BogBat Release
echo ------------------------

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror
if "%BogBatRoot%"=="" goto envvarerror

:: Get the version number from the version info file - this MUST exist
:: get major version number (required)
set VerFile=.\src\VERSION
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^ver-major" "%VerFile%"'
) do (
    set verMajor=%%A
  )
)
:: get minor version number (required)
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^ver-minor" "%VerFile%"'
) do (
    set verMinor=%%A
  )
)
:: get patch number (required)
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^ver-patch" "%VerFile%"'
) do (
    set verPatch=%%A
  )
)
:: get suffix (optional)
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^ver-suffix" "%VerFile%"'
) do (
    set verSuffix=%%A
)
:: check for required values
if not defined verMajor (
    goto badversionerror
)
if not defined verMinor (
    goto badversionerror
)
if not defined verPatch (
    goto badversionerror
)

:: Set variables
set Version=%verMajor%.%verMinor%.%verPatch%%suffix%
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
echo Building 64 bit version %Version%
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

:envvarerror
echo.
echo ***ERROR: ZipRoot and/or BogBatRoot environment variables not set:
echo           ZipRoot=%ZipRoot%
echo           BogBatRoot=%BogBatRoot%
echo.
goto end

:badversionerror
echo.
echo ***ERROR: An expected field is not set in %VerFile%:
echo           verMajor=%verMajor%
echo           verMinor=%verMinor%
echo           verPatch=%verPatch%
echo.
goto end

:: Done

:end

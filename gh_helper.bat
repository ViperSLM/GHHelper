@echo off
setlocal enabledelayedexpansion
title ViperSLM's GH Helper Script [Venues]
goto setup

:setup
call :title
echo [93mSetup:[0m
echo.

set DONEMSG=Done [Press any key to go back to main menu]

:: Default config name
set CONFIG=gh_helper.cfg

if exist %CONFIG% (
	:: if it exists, read the config line by line
	for /f "tokens=1,* delims==" %%A in ('type "%CONFIG%"') do (
		:: Dynamically set variables
		set %%A=%%B
	)
) else (
	echo -- Enter path to Guitar Hero SDK [GHSDK]
	set /p GHSDK= [Input]: 
	echo -- Where should the final venue be copied to? [e.g. [GHWT Folder]\DATA\MODS]
	set /p GHWT_MODS= [Input]: 
	echo -- What is the internal name of the venue? [e.g. z_example]
	set /p VENUE= [Input]: 
	echo -- What will be the final folder name for the venue?
	set /p FINAL_OUTPUT= [Input]: 
	
	goto save-config
)
goto setup-env

:save-config
:: Save the configuration
(
	echo GHSDK=%GHSDK%
	echo GHWT_MODS=%GHWT_MODS%
	echo VENUE=%VENUE%
	echo FINAL_OUTPUT=%FINAL_OUTPUT%
) > "%CONFIG%"
goto setup-env

:setup-env
set OUTPUT=%VENUE%-output
set QB=%VENUE%-src

if not exist %OUTPUT% (
	mkdir %OUTPUT%\Content
	if exist venue.ini copy venue.ini %OUTPUT%
)

if not exist %QB% mkdir %QB%
:: Create PAK root folder and the 'zones' folder if it doesn't exist already
if not exist %VENUE% (
	mkdir %VENUE%\zones\%VENUE%
	
	:: Copy anything found in 'assets' folder
	if exist ..\assets (
		xcopy /E ..\assets\*.* %VENUE%
	)
)

:: Setup is done, go to main menu
goto menu

:menu
call :title
echo [93mVenue:[0m %VENUE% [93m[ Output:[0m %FINAL_OUTPUT% [93m][0m
echo.
echo [1]	Pack venue
echo [2]	Obtain venue geometry from PAK
echo [3]	Convert ROQ script to QBC
echo [4]	Compile all scripts in %QB%
echo [5]	Cleanup compiled scripts in %QB%
echo.
echo [6]	Copy packed venue into Guitar Hero
echo [7]	View variables
echo [8]	Quit
echo.
echo Type in a number
echo.
choice /C:12345678 >NUL
if errorlevel 1 set M=1
if errorlevel 2 set M=2
if errorlevel 3 set M=3
if errorlevel 4 set M=4
if errorlevel 5 set M=5
if errorlevel 6 set M=6
if errorlevel 7 set M=7
if errorlevel 8 set M=8
if %M%==1 goto pack-venue
if %M%==2 goto get-venuegeo
if %M%==3 goto convert-roq
if %M%==4 goto compile
if %M%==5 goto cleanup-scripts
if %M%==6 goto copy-venue
if %M%==7 goto viewvars
if %M%==8 goto quit
echo.
goto menu

:copy-venue
call :title
echo.
xcopy /Y /E %OUTPUT%\*.* "%GHWT_MODS%\%FINAL_OUTPUT%"
echo Venue %VENUE% has been copied to %GHWT_MODS%\%FINAL_OUTPUT%
echo.
echo %DONEMSG%
pause >NUL
goto menu

:pack-venue
call :title
echo.
echo Packing %VENUE%...
node %GHSDK%\sdk.js createpak -zone %VENUE% -out %OUTPUT%\Content\%VENUE%.pak.xen %VENUE%
echo Finished
echo.
echo %DONEMSG%
pause >NUL
goto menu

:get-venuegeo
call :title
echo.
echo Please make sure that '%VENUE%.pak.xen' is accessible from '%FINAL_OUTPUT%\Content'
pause
:: Temporary folder where extracted contents will go
if not exist temp mkdir temp
echo.
echo Extracting PAK...
node "%GHSDK%\sdk.js" extract %FINAL_OUTPUT%\Content\%VENUE%.pak.xen temp
move temp\*.scn.xen %VENUE%\zones\%VENUE%\%VENUE%.scn.xen
echo.
echo. Copy .tex files? (Choose No if your venue uses custom crowd models)
echo [1 = Yes, 2 = No]
choice /C:12 >NUL
if errorlevel 1 set C=1
if errorlevel 2 set C=2
if %C%==1 move temp\*.tex.xen %VENUE%\zones\%VENUE%\%VENUE%.tex.xen
echo.
echo Delete temp folder?
echo [1 = Yes, 2 = No]
choice /C:12 >NUL
if errorlevel 1 set C=1
if errorlevel 2 set C=2
if %C%==1 rmdir /s /q temp
echo.
echo %DONEMSG%
pause >NUL
goto menu

:cleanup-scripts
call :title
echo.
del %QB%\*.qb.xen
echo.
echo %DONEMSG%
pause >NUL
goto menu

:convert-roq
set INPUT=
call :title
echo.
echo Enter the name of the script [excluding the file extension]
set /p INPUT= [Input]: 
:: Compile with NodeROQ, then decompile back into QBC
node "%GHSDK%\sdk.js" compile %INPUT%.txt
node "%GHSDK%\sdk.js" decompile -q %INPUT%.qb.xen
del %INPUT%.qb.xen
echo.
echo Conversion finished. You'll probably need to handle the checksum to string conversion yourself
echo.
echo %DONEMSG%
pause >NUL
goto menu

:compile
call :title
echo.
echo Put any scripts inside the %QB% folder, then press any key to begin
echo [ROQ = .txt, QBC = .q]
echo.
pause >NUL
echo Compiling scripts...

:: Process ROQ syntax scripts
for %%f in (%QB%\*.txt) do (
	echo %%f...
	node "%GHSDK%\sdk.js" compile %%f
)

:: Process QBC syntax scripts
for %%f in (%QB%\*.q) do (
	echo %%f...
	node "%GHSDK%\sdk.js" compile %%f
)
echo Finished compiling!
echo.
echo Copy compiled venue scripts into '%VENUE%\zones\%VENUE%'? [Only applies to %VENUE%*.qb.xen files]
echo [1 = Yes, 2 = No]
choice /C:12 >NUL
if errorlevel 1 set C=1
if errorlevel 2 set C=2

if %C%==1 (
	:: Move all compiled script into the venue's zones folder
	move %QB%\%VENUE%*.qb.xen %VENUE%\zones\%VENUE%
)

if exist *.qb.xen (
	echo Copy other compiled scripts into '%VENUE%'?
	echo [1 = Yes, 2 = No]
	choice /C:12 >NUL
	if errorlevel 1 set C=1
	if errorlevel 2 set C=2
	
	if %C%==1 (
		move %QB%\*.qb.xen %VENUE%
	)
)

echo.
echo %DONEMSG%
pause >NUL
goto menu

:viewvars
call :title
echo Variables:
echo.
echo [93mGHSDK[0m: 		[92m%GHSDK%[0m
echo [93mGHWT_MODS[0m: 	[92m%GHWT_MODS%[0m
echo [93mVENUE[0m:		[92m%VENUE%[0m
echo [93mFINAL_OUTPUT[0m:	[92m%FINAL_OUTPUT%[0m
echo.
pause
goto menu

:quit
endlocal
:: Clear all the variables in case if this was ran from command prompt
set GHSDK=
set GHWT_MODS=
set VENUE=
set FINAL_OUTPUT=
exit

:title
cls
echo [92m----------------------------------------------------[0m
echo  [96mViperSLM's GH Helper Script[0m
echo [92m----------------------------------------------------[0m
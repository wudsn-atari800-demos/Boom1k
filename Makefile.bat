echo off
call Make-Settings.bat

cd %BASE_DIR%

rem Clean main directory
if exist *-Test.lab   del /Q *-Test.lab
if exist *-Test.lst   del /Q *-Test.lst
if exist *-Test.xex   del /Q *-Test.xex
if exist *-Test.atdbg del /Q *-Test.atdbg

rem Make main file
call :make 

set ATR=%RELEASE%.atr
C:\jac\system\Atari800\Tools\ATR\HIAS\dir2atr.exe -m -b MyDos4534 %ATR% make\atr

rem To compile the loader along, the .xex files must not be deleted.
goto keepXEXfiles
if exist %RELEASE%.xex             del %RELEASE%.xex
:keepXEXfiles

if NOT X%1==XSTART goto :EOF
start %ATR%
goto :eof

:make
if exist make\atr\%RELEASE_FILENAME% del make\atr\%RELEASE_FILENAME%
C:\jac\system\Atari800\Tools\ASM\MADS\mads.exe %RELEASE%.asm -o:%RELEASE%.xex
if ERRORLEVEL 1 goto :mads_error
dir *.*
copy %RELEASE%.xex make\atr\%RELEASE_FILENAME%
if ERRORLEVEL 1 goto :mads_error

goto :eof

:mads_error
echo ERROR: MADS compilation errors occurred. Check error messages above.
pause
exit


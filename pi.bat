@echo off
rem ascii art source: https://www.raspberrypi.org/forums/viewtopic.php?p=78678#p78678
rem batch file colours source: http://stackoverflow.com/questions/4339649/how-to-have-multiple-colors-in-a-windows-batch-file/5344911#5344911
call :initecko

call :ecko 0a "    .~~.   .~~.  "
echo(
call :ecko 0a "   '. \ ' ' / .'  "
echo(
call :ecko 0c "    .~ .~~~..~."
call :ecko 0a "			Raspberry Pi Finder
echo(
call :ecko 0c "   : .~.'~'.~. :"   
echo(
call :ecko 0c "  ~ (   ) (   ) ~"  
call :ecko 0a "		Michael Whinfrey
echo(
call :ecko 0c " ( : '~'.~.'~' : )"
echo(
call :ecko 0c "  ~ .~ (   ) ~. ~  "
echo(
call :ecko 0c "   (  : '~' :  )   "
echo(
call :ecko 0c "    '~ .~~~. ~'    "
echo(
call :ecko 0c "        '~'"
echo(
echo(

@echo off
setlocal 
set ip_address_string="IP Address"
set ip_address_string="IPv4 Address"
for /f "usebackq tokens=2 delims=:" %%f in (`ipconfig ^| findstr /c:%ip_address_string%`) do (
    call :ecko 02 "Local IP Address is: %%f"
    echo(
    set local_address=%%f
    goto :foundip
)

:foundip

for /f "tokens=1 delims=." %%a in ("%local_address%") do set ip1=%%a
for /f "tokens=2 delims=." %%a in ("%local_address%") do set ip2=%%a
for /f "tokens=3 delims=." %%a in ("%local_address%") do set ip3=%%a

call :ecko 02 "refreshing arp tables on subnet %ip1%.%ip2%.%ip3%.0"
echo(
set /a pi_count=0
set /a n=0
set /a row_count=0

:repeat
set /a n+=1
set /a row_count+=1
set current_ip=%ip1%.%ip2%.%ip3%.%n%

@ ping -n 1 -w 100 %current_ip% >NUL
call :ecko 0a "."
if %row_count% gtr 25 (
	echo(
	set /a row_count=0
)
for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"

for /f "usebackq tokens=5 delims=-. " %%f in (`arp -a ^| findstr /r "%current_ip%\>"`) do set arp1=%%f
for /f "usebackq tokens=6 delims=-. " %%f in (`arp -a ^| findstr /r "%current_ip%\>"`) do set arp2=%%f

IF %arp1%==b8 (
	if %arp2%==27 (
		echo .
		call :ecko 0c " * Candidate: %current_ip%"
echo(
		set arp1=0
		set arp2=0
		set /a pi_count+=1
		set /a row_count=0
	)
)

if %n% lss 254 goto repeat

call :cleanupecko
echo(

if %pi_count% lss 1 (
	call :ecko 0c "I didn't find any raspberry pi's =("
	echo(
	goto :eof
)

echo found %pi_count% devices, listed above.
goto :eof

:ecko Color  Str  [/n]
setlocal
set "str=%~2"
call :eckoVar %1 str %3
exit /b

:eckoVar  Color  StrVar  [/n]
if not defined %~2 exit /b
setlocal enableDelayedExpansion
set "str=a%DEL%!%~2:\=a%DEL%\..\%DEL%%DEL%%DEL%!"
set "str=!str:/=a%DEL%/..\%DEL%%DEL%%DEL%!"
set "str=!str:"=\"!"
pushd "%temp%"
findstr /p /A:%1 "." "!str!\..\x" nul
if /i "%~3"=="/n" echo(
exit /b

:initecko
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
<nul >"%temp%\x" set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%.%DEL%"
exit /b

:cleanupecko
del "%temp%\x"
exit /b


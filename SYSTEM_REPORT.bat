::--------------------------------------------::
::     SYSTEM REPORT - Windows CMD Report     ::
::  Author: Diogo Santos Pombo - \Õ/ - @2026  ::
::--------------------------------------------::

@echo off
setlocal EnableExtensions
title SYSTEM REPORT
color F0

set "SPACE= "
set "VERBOSE=0"
set "IS_ADMIN=0"

rem =========================================================
rem PARSE ARGS (-V or -v)
rem =========================================================
:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
if /I "%~1"=="-V" set "VERBOSE=1"
shift
goto PARSE_ARGS
:ARGS_DONE

rem =========================================================
rem CHECK ADMIN PRIVILEGES
rem =========================================================
net session >nul 2>&1
if not errorlevel 1 set "IS_ADMIN=1"

rem =========================================================
rem HEADER
rem =========================================================
echo.
echo.
echo     ******************** SYSTEM REPORT ********************
echo.
echo.
echo Date/Time : %DATE% %TIME%
echo Computer  : %COMPUTERNAME%
echo User      : %USERNAME%
echo Admin     : %IS_ADMIN%
echo Verbose   : %VERBOSE%
echo.
echo ============================================================
echo.

rem =========================================================
rem SYSTEM
rem =========================================================
echo **** SYSTEM ****
ver
echo.
hostname
echo.
where query >nul 2>&1
if errorlevel 1 (
    echo [!] THE QUERY COMMAND IS NOT AVALIABLE.
) else (
    query user
)
echo.
systeminfo /fo list

call :V SYSTEM


rem =========================================================
rem USERS
rem =========================================================
echo.
echo.
echo **** USERS ****
net user
echo.
net localgroup
echo.
net accounts

call :V USERS


rem =========================================================
rem DRIVERS
rem =========================================================
echo.
echo.
echo **** DRIVERS ****
if "%VERBOSE%"=="1" (
    driverquery /v
) else (
    driverquery
)

call :V DRIVERS


rem =========================================================
rem TASKS
rem =========================================================
echo.
echo.
echo **** TASKS ****
if "%VERBOSE%"=="1" (
    tasklist /v
) else (
    tasklist
)
echo.
echo ** USER PROCESS **
where query >nul 2>&1
if errorlevel 1 (
    echo [!] THE QUERY COMMAND IS NOT AVALIABLE.
) else (
    query process
)

call :V TASKS


rem =========================================================
rem STORAGE
rem =========================================================
echo.
echo.
echo **** STORAGE ****
echo.
echo ** THIS SECTION ONLY WORKS IF RUN AS ADMINISTRATOR! **
echo.

if "%IS_ADMIN%"=="0" (
    echo [!] NOT RUNNING AS ADMIN. SKIPPING FSUTIL COMMANDS.
) else (
    fsutil volume diskfree %SystemDrive%
    echo.
    fsutil fsinfo volumeinfo %SystemDrive%
)

call :V STORAGE


rem =========================================================
rem SECURITY
rem =========================================================
echo.
echo.
echo **** SECURITY ****
echo.
echo ** THIS SECTION ALWAYS RUNS. SOME DETAILS MAY REQUIRE ADMIN. **
echo.

call :SECURITY_ALWAYS
call :V SECURITY


rem =========================================================
rem REMOTE SERVERS
rem =========================================================
echo.
echo.
echo **** REMOTE SERVERS ****
echo.

query termserver >nul 2>&1
if errorlevel 1 (
    echo [!] NO REMOTE DESKTOP SESSION HOST FOUND OR NOT APPLICABLE.
) else (
    query termserver
)

call :V REMOTE


rem =========================================================
rem END
rem =========================================================
echo.
echo.
echo ******************** END OF REPORT! ********************
echo.

pause > nul
exit /b


rem =========================================================
rem VERBOSE DISPATCHER
rem =========================================================
:V
if not "%VERBOSE%"=="1" exit /b

if /I "%~1"=="SYSTEM"    goto V_SYSTEM
if /I "%~1"=="USERS"     goto V_USERS
if /I "%~1"=="DRIVERS"   goto V_DRIVERS
if /I "%~1"=="TASKS"     goto V_TASKS
if /I "%~1"=="STORAGE"   goto V_STORAGE
if /I "%~1"=="SECURITY"  goto V_SECURITY
if /I "%~1"=="REMOTE"    goto V_REMOTE
exit /b


rem =========================================================
rem VERBOSE : SYSTEM
rem =========================================================
:V_SYSTEM
echo.
echo ** SYSTEM DETAILS (VERBOSE / POWERSHELL) **
echo.

echo ** CPU CORES / LOGICAL PROCESSORS **
powershell -NoLogo -NonInteractive -Command ^
  "Get-CimInstance Win32_Processor | Select Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List"

echo.
echo ** BIOS SERIAL NUMBER **
powershell -NoLogo -NonInteractive -Command ^
  "Get-CimInstance Win32_BIOS | Select SMBIOSBIOSVersion,SerialNumber,ReleaseDate | Format-List"

echo.
echo ** UPTIME (DURATION) **
powershell -NoLogo -NonInteractive -Command ^
  "$OS=Get-CimInstance Win32_OperatingSystem; (Get-Date)-$OS.LastBootUpTime | Format-List"

echo.
echo ** WINDOWS UBR (BUILD REVISION) **
powershell -NoLogo -NonInteractive -Command ^
  "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select ProductName,DisplayVersion,CurrentBuild,UBR | Format-List"

echo.
echo ** PROXY SETTINGS (WINHTTP) **
netsh winhttp show proxy

exit /b


rem =========================================================
rem VERBOSE : USERS
rem =========================================================
:V_USERS
echo.
echo ** USER CONTEXT (VERBOSE) **
whoami
echo.
echo ** USER GROUPS **
whoami /groups
exit /b


rem =========================================================
rem VERBOSE : DRIVERS
rem =========================================================
:V_DRIVERS
exit /b


rem =========================================================
rem VERBOSE : TASKS
rem =========================================================
:V_TASKS
echo.
echo ** TOP PROCESSES (CPU) **
powershell -NoLogo -NonInteractive -Command ^
  "Get-Process | Sort CPU -Desc | Select -First 15 Name,Id,CPU,WS | Format-Table -Auto"

echo.
echo ** TOP PROCESSES (MEMORY WORKING SET) **
powershell -NoLogo -NonInteractive -Command ^
  "Get-Process | Sort WS -Desc | Select -First 15 Name,Id,WS | Format-Table -Auto"

echo.
echo ** SERVICES **
sc query type= service state=all

echo.
echo ** TASKLIST WITH SERVICES (MAY BE LARGE) **
tasklist /svc

echo.
echo ** EVENT LOGS (SYSTEM - LAST 25 CRITICAL/ERROR) **
wevtutil qe System /c:25 /f:text /rd:true

echo.
echo ** EVENT LOGS (APPLICATION - LAST 25 CRITICAL/ERROR) **
wevtutil qe Application /c:25 /f:text /rd:true

exit /b


rem =========================================================
rem VERBOSE : STORAGE
rem =========================================================
:V_STORAGE
echo.
echo ** STORAGE DETAILS (VERBOSE / POWERSHELL) **
echo.

echo ** VOLUMES (IF AVAILABLE) **
powershell -NoLogo -NonInteractive -Command ^
  "if (Get-Command Get-Volume -EA SilentlyContinue) {Get-Volume | Select DriveLetter,FileSystemLabel,FileSystem,Size,SizeRemaining,HealthStatus | Format-Table -Auto} else {'Get-Volume not available'}"

echo.
echo ** PHYSICAL DISKS (IF AVAILABLE) **
powershell -NoLogo -NonInteractive -Command ^
  "if (Get-Command Get-PhysicalDisk -EA SilentlyContinue) {Get-PhysicalDisk | Select FriendlyName,MediaType,Size,HealthStatus,OperationalStatus | Format-List} else {'Get-PhysicalDisk not available'}"

echo.
echo ** DISKS (IF AVAILABLE) **
powershell -NoLogo -NonInteractive -Command ^
  "if (Get-Command Get-Disk -EA SilentlyContinue) {Get-Disk | Select Number,FriendlyName,PartitionStyle,OperationalStatus,HealthStatus,Size | Format-Table -Auto} else {'Get-Disk not available'}"

echo.
echo ** BITLOCKER STATUS (ADMIN ONLY) **
if "%IS_ADMIN%"=="0" (
    echo [!] NOT RUNNING AS ADMIN. SKIPPING BITLOCKER.
) else (
    manage-bde -status
)

exit /b


rem =========================================================
rem SECURITY ALWAYS
rem =========================================================
:SECURITY_ALWAYS
echo ** WINDOWS FIREWALL PROFILES **
powershell -NoLogo -NonInteractive -Command ^
  "if (Get-Command Get-NetFirewallProfile -EA SilentlyContinue) {Get-NetFirewallProfile | Select Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -Auto} else {'Get-NetFirewallProfile not available'}"

echo.
echo ** MICROSOFT DEFENDER STATUS **
powershell -NoLogo -NonInteractive -Command ^
  "if (Get-Command Get-MpComputerStatus -EA SilentlyContinue) {Get-MpComputerStatus | Select AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,RealTimeProtectionEnabled,QuickScanAge,FullScanAge,NISSignatureAge | Format-List} else {'Defender cmdlets not available'}"

exit /b


rem =========================================================
rem VERBOSE : SECURITY
rem =========================================================
:V_SECURITY
echo.
echo ** SECURITY DETAILS (VERBOSE) **
echo.
powershell -NoLogo -NonInteractive -Command ^
  "Get-Service WinDefend,WSCsvc,MpsSvc -EA SilentlyContinue | Format-Table Name,Status,StartType -Auto"

echo.
echo ** APPLOCKER (EFFECTIVE POLICY) **
if "%IS_ADMIN%"=="0" (
    echo [!] NOT RUNNING AS ADMIN. SKIPPING APPLOCKER.
) else (
    powershell -NoLogo -NonInteractive -Command ^
      "if (Get-Command Get-AppLockerPolicy -EA SilentlyContinue) {Get-AppLockerPolicy -Effective | Format-List} else {'AppLocker not available'}"
)
exit /b


rem =========================================================
rem VERBOSE : REMOTE
rem =========================================================
:V_REMOTE
exit /b
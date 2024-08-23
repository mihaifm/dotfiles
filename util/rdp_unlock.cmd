@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

for /f "tokens=1-3 delims= " %%a in ('qwinsta^| findstr "rdp-tcp"^| findstr "Active"') do set SessionID=%%c

%windir%\System32\tscon.exe %SessionID% /dest:console

endlocal
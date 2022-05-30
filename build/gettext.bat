@echo off
echo Generating file list..
dir ..\src\*.lua /L /B /S > %TEMP%\listfile.txt
echo Generating .POT file...
E:\programs\gettext\bin\xgettext -kgettext --from-code utf-8 --copyright-holder=sirinsidiator --package-name=AwesomeGuildStore --msgid-bugs-address=insidiator@cmos.at -cTRANSLATORS: -o ..\translations\messages.pot -L Lua --no-wrap -D ..\src -f %TEMP%\listfile.txt
"C:\Program Files\PowerShell\7\pwsh.exe" -Command "(Get-Content ..\translations\messages.pot) -replace 'charset=CHARSET', 'charset=UTF-8' | Out-File ..\translations\messages.pot"
echo Done.
del %TEMP%\listfile.txt
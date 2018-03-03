@echo off
echo Generating file list..
dir ..\src\*.lua /L /B /S > %TEMP%\listfile.txt
echo Generating .POT file...
E:\programs\gettext\bin\xgettext -kgettext --from-code utf-8 --copyright-holder=sirinsidiator --package-name=AwesomeGuildStore --msgid-bugs-address=insidiator@cmos.at -cTRANSLATORS: -o ..\translations\messages.pot -L Lua --no-wrap -D ..\src -f %TEMP%\listfile.txt
echo Done.
del %TEMP%\listfile.txt
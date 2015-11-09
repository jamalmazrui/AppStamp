@echo off
cls
if exist stamp.exe del stamp.exe
c:\pbwin10\bin\pbwin.exe /ic:\pbwin10\winapi;c:\AppStamp c:\AppStamp\stamp.bas

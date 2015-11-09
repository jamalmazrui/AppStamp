@echo off
cls
if exist elevate.exe del elevate.exe
c:\pbwin10\bin\pbwin.exe /ic:\pbwin10\winapi;c:\AppStamp c:\AppStamp\elevate.bas

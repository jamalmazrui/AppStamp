' Stamp
' Version 1.1
' Copyright 2009 - 2015 by Jamal Mazrui
' GNU Lesser General Public License(LGPL)

#Include "win32API.inc"
#Include "EOIni.inc"
#Include "DateTime.inc"

Function FileGetTime(ByVal sPath As String) As String
Local iYear As Long, iMonth  As Long, iDay  As Long, iHour As Long, iMinute As Long, iSecond As Long
Local CreationTime As FILETIME, LastAccessTime As FILETIME, LastWriteTime  As FILETIME, LT  As FILETIME, ST As SYSTEMTIME
Local ReOpenBuff As OFSTRUCT, nFile  As Long, hFile  As Dword

Try
nFile = FreeFile
Open sPath For Input Access Read Lock Shared As #nFile
Catch
Exit Function
Finally
hFile = FileAttr(nFile, 2)
GetFileTime hFile, CreationTime, LastAccessTime, LastWriteTime
Close #nFile
FileTimeToLocalFileTime LastWriteTime, LT
FileTimeToSystemTime LT, ST
iYear   = ST.wYear
iMonth  = ST.wMonth
iDay    = ST.wDay
iHour   = ST.wHour
iMinute = ST.wMinute
iSecond = ST.wSecond
' Function = Format$(iYear, "0000") + Format$(iMonth, "00") + Format$(iDay, "00") + Format$(iHour, "00") + Format$(iMinute, "00") + Format$(iSecond, "00")
Function = Format$(iYear, "0000") & "-" & Format$(iMonth, "00") & "-" & Format$(iDay, "00") & " " & Format$(iHour, "00") & ":" & Format$(iMinute, "00") & ":" & Format$(iSecond, "00")
End Try
End Function

Function DialogInput(sTitle As String, sMessage As String, sValue As String) As String
Function = InputBox$(sMessage, sTitle, sValue)
End Function

Function DialogShow(sTitle As String, sMessage As String) As Long
' show a standard message box

Dim iFlags As Long

DialogShow = %True
iFlags = %mb_IconInformation Or %mb_SystemModal
If sTitle = "" Then sTitle = "Show"
MsgBox sMessage, iFlags, sTitle
End Function

Function StringQuote(ByVal s$) As String
Function = Chr$(34) & s$ & Chr$(34)
End Function

Function DialogConfirm(sTitle As String, sMessage As String, sDefault As String) As String
' Get choice from a standard Yes, No, or Cancel message box

Dim iFlags As Long, iChoice As Long

DialogConfirm = ""
iFlags = %mb_YesNoCancel
iFlags = iFlags or %mb_IconQuestion	' 32 query icon
iFlags = iFlags Or %mb_SystemModal ' 4096	System modal
If sTitle = "" Then sTitle = "Confirm"
If sDefault = "N" Then iFlags = iFlags Or %mb_DefButton2
iChoice = MsgBox(sMessage, iFlags, sTitle)
If iChoice = %IDCancel Then Exit Function

If iChoice = %IDYes Then
DialogConfirm = "Y"
Else
DialogConfirm = "N"
End If
End Function

Function Say(sText As String) As Long
Dim sExe As String
sExe = appPath$ & "SayLine.exe"
Shell(StringQuote(sExe) & sText, 0)
End Function

Function PBMain() As Long
Dim iCount As Long, iTime As Long, iDay As Long, iMonth As Long
Dim nTime As Double
Dim sAppName As String, sAppVersion As String, sAppPath As String, sAppStampIniPath As String, sAppStampIniURL As String, sAppSetupURL As String, sAppSetup As String
Dim sIni As String, sSection As String, sTempSetup As String, sLocalTime As String, sServerTime As String, sTempIni As String, sDefault As String, sVersion as String, sTime As String, sValue As String, sTitle As String, sMessage As String
Dim sDay As String, sMonth As String, sMissing As String

sIni = Trim$(Command$, Any $DQ)
If Len(sIni) = 0 Then
sTitle = "Stamp"
sMessage = "Enter 4 parameters, or path of ini file:"
sIni = Trim$(DialogInput(sTitle, sMessage, ""))
If Len(sIni) = 0 Then Exit Function
End If

' sIni = Trim$(sIni, Any Chr$(32) & Chr$(34))
If IsFile(sIni) Then
sIni = PathScan$(FULL, sIni)
sSection = "Stamp"
sAppName = Ini_GetKey(sIni, sSection, "AppName", "")
sAppPath = Ini_GetKey(sIni, sSection, "AppPath", "")
sAppStampIniPath = Ini_GetKey(sIni, sSection, "AppStampIniPath", "")
sAppVersion = Ini_GetKey(sIni, sSection, "AppVersion", "")
Else
sAppName = Command$(1)
sAppPath = Command$(2)
sAppStampIniPath = Command$(3)
sAppVersion = Command$(4)
End If

If Len(sAppName) = 0 Then sMissing = "AppName"
If Len(sAppPath) = 0 Then sMissing += ", AppPath"
If Len(sAppStampIniPath) = 0 Then sMissing += ", AppStampIniPath"
If Len(sAppVersion) = 0 Then sMissing += ", AppVersion"
sMissing = Trim$(sMissing, Any " ,")
If Len(sMissing) > 0 Then
sTitle = "Error"
sMessage = "Missing " & sMissing
DialogShow sTitle, sMessage
Exit Function
End If

sSection = "Versions"
sLocalTime = FileGetTime(sAppPath)
sLocalTime = Left$(sLocalTime, Len(sLocalTime) - 3)
sValue = sAppVersion & "|" & sLocalTime
Ini_SetKey(sAppStampIniPath, sSection, sAppName, sValue)
sTitle = "Done"
sMessage = "Stamped " & sAppName & " with " & sValue
DialogShow sTitle, sMessage
End Function


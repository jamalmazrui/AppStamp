' Elevate
' Version 1.1
' Copyright 2009 - 2015 by Jamal Mazrui
' GNU Lesser General Public License(LGPL)

#Include "win32API.inc"
#Include "EOIni.inc"
#Include "DateTime.inc"

Function URL2File(ByVal z_URL As Asciiz * %MAX_PATH, ByVal z_file As Asciiz * %MAX_PATH) As Long
Function = IsFalse URLDownloadToFile(ByVal 0&, z_url, z_file, ByVal 0&, ByVal 0&)
End Function

Function FileMakeTemp(Optional ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH

If Len(sPath) = 0 Then sPath = DirGetTemp()
GetTempFilename(ByVal StrPtr(sPath), "tmp_", 0, z)
Function = Trim$(z, Any $Nul + $Spc)
End Function

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

Function DirGetTemp() As String
Local zPath As ASCIIZ*%MAX_PATH
GetTempPath(%MAX_Path, zPath)
Function = zPath
End Function

Function GetMeridianTime(sTime As String) As String
Dim iHour As Long
Dim sHour As String, sSuffix As String

sHour = Left$(sTime, 2)
iHour = Val(sHour)
if iHour >= 12 Then
sSuffix = " PM"
iHour = iHour - 12
Else
sSuffix = " AM"
End If

If iHour = 0 Then iHour = 12
sHour = Format$(iHour)
If Len(sHour) = 1 Then sHour = "0" & sHour
Function = sHour & Mid$(sTime, 3) & sSuffix
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
sTitle = "Elevate"
sMessage = "Enter 4 parameters, or path of ini file:"
sIni = Trim$(DialogInput(sTitle, sMessage, ""))
If Len(sIni) = 0 Then Exit Function
End If

' sIni = Trim$(sIni, Any Chr$(32) & Chr$(34))
If IsFile(sIni) Then
sIni = PathScan$(FULL, sIni)
sSection = "Elevate"
sAppName = Ini_GetKey(sIni, sSection, "AppName", "")
sAppPath = Ini_GetKey(sIni, sSection, "AppPath", "")
sAppStampIniURL = Ini_GetKey(sIni, sSection, "AppStampIniURL", "")
sAppSetupURL = Ini_GetKey(sIni, sSection, "AppSetupURL", "")
sAppSetup = Ini_GetKey(sIni, sSection, "AppSetup", "")
Else
sAppName = Command$(1)
sAppPath = Command$(2)
sAppStampIniURL = Command$(3)
sAppSetupURL = Command$(4)
sAppSetup = Command$(5)
End If

If Len(sAppName) = 0 Then sMissing = "AppName"
If Len(sAppPath) = 0 Then sMissing += ", AppPath"
If Len(sAppStampIniURL) = 0 Then sMissing += ", AppStampIniURL"
If Len(sAppSetupURL) = 0 Then sMissing += ", AppSetupURL"
If Len(sAppSetup) = 0 Then sMissing += ", AppSetup"
sMissing = Trim$(sMissing, Any " ,")
If Len(sMissing) > 0 Then
sTitle = "Error"
sMessage = "Missing " & sMissing
DialogShow sTitle, sMessage
Exit Function
End If

sSection = "Versions"
sTempSetup = DirGetTemp & sAppSetup
sLocalTime = FileGetTime(sAppPath)
sLocalTime = Left$(sLocalTime, Len(sLocalTime) - 3)
sTempIni = FileMakeTemp
URL2File sAppStampIniURL, sTempIni
sValue = Ini_GetKey(sTempIni, sSection, sAppName, "")
Kill sTempIni
If Len(sValue) = 0 Then
sTitle = "Confirm"
sMessage = "Cannot find information about " & sAppName & " on server." & $CrLf & "Download Anyway?"
sDefault = "Y"
Else
sVersion = Parse$(sValue, "|", 1)
sServerTime = Parse$(sValue, "|", 2)

If sServerTime > sLocalTime Then
sDefault = "Y"
sMessage = "Newer "
ElseIf sServerTime = sLocalTime Then
sDefault = "N"
sMessage = "Current "
Else
sDefault = "N"
sMessage = "Older "
End If

sTime = sServerTime
nTime = StrToDate(sTime)
iMonth = Month(nTime)
sMonth = MonthName(iMonth)
iDay = DayOfWeek(nTime)
sDay = DayName(iDay)
' MsgBox sTime
' MsgBox Format$(iDay)
' MsgBox sDay

sTime = Parse$(sTime, " ", 2)
sTime = sDay & ", " & sMonth & " " & Format$(Day(nTime)) & ", " & Format$(Year(nTime)) & " at " & GetMeridianTime(sTime)
sMessage = sMessage & sAppName & " " & sVersion & $CrLf & "released on " & sTime & $CrLf
sMessage = sMessage & "Download from " & $CrLf & sAppSetupURL & $CrLf & "to Temp folder, and run installer?"
End If

If DialogConfirm("Confirm", sMessage, sDefault) <> "Y" Then
Exit Function
End If

' StdOut "Plese wait"
If IsFalse URL2File(sAppSetupURL, sTempSetup) Then
sTitle = "Error"
sMessage = "Unable to download" & $CrLf & sAppSetupURL
DialogShow sTitle, sMessage
Exit Function
End If

sTitle = "Download Done"
sMessage = "Ready to run installer.  Please close " & sAppName & ", so files may be replaced, then press OK to continue ..."
DialogShow sTitle, sMessage
ShellExecute ByVal 0&, ByVal 0&, ByCopy sTempSetup, ByVal 0&, ByVal 0&, ByVal 1&
' Shell StringQuote(sTempSetup), 0
Kill sTempSetup
End Function

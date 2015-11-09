[Setup]
AppName=AppStamp
AppVerName=AppStamp 1.1
AppPublisher=Jamal Mazrui
AppPublisherURL=http://NonvisualDevelopment.org
DefaultDirName=C:\AppStamp
;CreateAppDir=no
OutputDir=c:\AppStamp
OutputBaseFilename=AppStamp_setup
;DisableDirPage=yes
DefaultGroupName=AppStamp
DisableProgramGroupPage=yes
DisableReadyPage=yes
;DisableFinishedPage=yes
Compression=lzma
SolidCompression=yes

[Files]
;Source: "c:\AppStamp\Stamp.bas"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\AppStamp\Stamp.exe"; DestDir: "{app}"; Flags: ignoreversion
;Source: "c:\AppStamp\Elevate.bas"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\AppStamp\Elevate.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\AppStamp\AppStamp.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\AppStamp\source\*.*"; DestDir: "{app}\source"; Flags: ignoreversion
Source: "c:\AppStamp\docs\*.*"; DestDir: "{app}\docs"; Flags: ignoreversion

[INI]
Filename: "{app}\AppStamp.ini"; Section: "Elevate"; Key: "AppPath"; String: "{app}\Stamp.exe"

[Run]
FileName:"{app}\docs\AppStamp.htm"; Description: "Read AppStamp documentation"; Flags: shellexec skipifdoesntexist postinstall skipifsilent

[Icons]
Name: "{group}\Launch Stamp Utility"; Filename: "{app}\Stamp.exe";
Name: "{group}\Launch Elevate Utility"; Filename: "{app}\Elevate.exe";
Name: "{group}\Elevate AppStamp"; Filename: "{app}\Elevate.exe"; Parameters: """{app}\AppStamp.ini""";
Name: "{group}\Read AppStamp documentation"; Filename: "{app}\docs\AppStamp.htm"; 
Name: "{group}\Uninstall AppStamp"; Filename: "{uninstallexe}"


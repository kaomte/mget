!define PRODUCT_NAME "Ruby Movie Get"
!define PRODUCT_VERSION "1.20.1"
!define PRODUCT_WEB_SITE "http://movie-get.org/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\mget.rb"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON "..\gfx\mget.ico"
!define MUI_UNICON "..\gfx\mget2.ico"

!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\COPYING"
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$WINDIR\system32\cmd.exe "
!define MUI_FINISHPAGE_RUN_PARAMETERS "/k cd $PROGRAMFILES\mget\Downloads\ && mget"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Polish"

!macro GetCleanDir INPUTDIR
  !define Index_GetCleanDir 'GetCleanDir_Line${__LINE__}'
  Push $R0
  Push $R1
  StrCpy $R0 "${INPUTDIR}"
  StrCmp $R0 "" ${Index_GetCleanDir}-finish
  StrCpy $R1 "$R0" "" -1
  StrCmp "$R1" "\" ${Index_GetCleanDir}-finish
  StrCpy $R0 "$R0\"
${Index_GetCleanDir}-finish:
  Pop $R1
  Exch $R0
  !undef Index_GetCleanDir
!macroend

!macro RemoveFilesAndSubDirs DIRECTORY
  !define Index_RemoveFilesAndSubDirs 'RemoveFilesAndSubDirs_${__LINE__}'

  Push $R0
  Push $R1
  Push $R2

  !insertmacro GetCleanDir "${DIRECTORY}"
  Pop $R2
  FindFirst $R0 $R1 "$R2*.*"
${Index_RemoveFilesAndSubDirs}-loop:
  StrCmp $R1 "" ${Index_RemoveFilesAndSubDirs}-done
  StrCmp $R1 "." ${Index_RemoveFilesAndSubDirs}-next
  StrCmp $R1 ".." ${Index_RemoveFilesAndSubDirs}-next
  IfFileExists "$R2$R1\*.*" ${Index_RemoveFilesAndSubDirs}-directory
  ; file
  Delete "$R2$R1"
  goto ${Index_RemoveFilesAndSubDirs}-next
${Index_RemoveFilesAndSubDirs}-directory:
  ; directory
  RMDir /r "$R2$R1"
${Index_RemoveFilesAndSubDirs}-next:
  FindNext $R0 $R1
  Goto ${Index_RemoveFilesAndSubDirs}-loop
${Index_RemoveFilesAndSubDirs}-done:
  FindClose $R0

  Pop $R2
  Pop $R1
  Pop $R0
  !undef Index_RemoveFilesAndSubDirs
!macroend

LangString msg_uninstall ${LANG_POLISH} "Czy na pewno chcesz usunąć $(^Name) i wszystkie jego komponenty?"
LangString msg_uninstall ${LANG_ENGLISH} "Do you want to delete $(^Name) and all his components?"
LangString msg_uninstall_ ${LANG_POLISH} "$(^Name) został pomyślnie usunięty."
LangString msg_uninstall_ ${LANG_ENGLISH} "$(^Name) was successfully deleted."

LangString msg_register ${LANG_POLISH} "Pobierz przez MGET"
LangString msg_register2 ${LANG_POLISH} "Pobierz i konwertuj przez MGET"
LangString msg_register ${LANG_ENGLISH} "Download with MGET"
LangString msg_register2 ${LANG_ENGLISH} "Download and Convert with MGET"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "mget-${PRODUCT_VERSION}-win.exe"
InstallDir "$PROGRAMFILES\mget"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""


ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "WIN" SEC01
  CreateDirectory "$WINDIR\mplayer"
  SetOutPath "$WINDIR"
  SetOverwrite try
  File "..\mget.rb"
  File "mplayer.exe"
  File "ffmpeg.exe"
  File "wget.exe"
SectionEnd

Section "mget" SEC02
  CreateDirectory "$PROGRAMFILES\mget\Downloads"
  SetOutPath "$PROGRAMFILES\mget\"
  SetOverwrite try
  File "..\mget.rb"
  File "mget.bat"
  File "..\COPYING"
  File "..\docs\mget.html"
  File "..\gfx\mget.ico"
  
  WriteRegStr HKCR ".mpkg" "" "MPKG"
  WriteRegStr HKCR "MPKG" "" "Media Package"
  WriteRegStr HKCR "MPKG\DefaultIcon" "" "$PROGRAMFILES\mget\mget.ico"
  WriteRegStr HKCR "MPKG\shell\download" "" "$(msg_register)"
  WriteRegStr HKCR "MPKG\shell\download\command" "" 'C:\WINDOWS\system32\cmd.exe /c "C:\WINDOWS\mget.rb -dCi "%1""'
  WriteRegStr HKCR "MPKG\shell" "" "download"
  WriteRegStr HKCR "MPKG\shell\convert" "" "$(msg_register2)"
  WriteRegStr HKCR "MPKG\shell\convert\command" "" 'C:\WINDOWS\system32\cmd.exe /c "C:\WINDOWS\mget.rb -dcri "%1""'

  WriteRegStr HKCR "mget" "" "URL:Media Protocol"
  WriteRegStr HKCR "mget" "Source Filter" "{6B6D0800-9ADA-11d0-A520-00A0D10129C0}"
  WriteRegStr HKCR "mget" "Animation" "dxmasf.dll,150"
  WriteRegStr HKCR "mget" "URL Protocol" ""
  WriteRegStr HKCR "mget\DefaultIcon" "" "$PROGRAMFILES\mget\mget.ico"
  WriteRegStr HKCR "mget\shell" "" "open"
  WriteRegStr HKCR "mget\shell\open" "" ""
  WriteRegStr HKCR "mget\shell\open\command" "" '"C:\Program Files\mget\mget.bat" "%L"'

  FileOpen $4 "$APPDATA\Opera\Opera\profile\opera6.ini" a
  FileSeek $4 0 END
  FileWrite $4 "$\r$\n"
  FileWrite $4 "mget=1,0,"
  FileWrite $4 "$\r$\n"
  FileClose $4
SectionEnd

Section "lib" SEC03
  ReadRegStr $R1 HKLM "Software\RubyInstaller" "DefaultPath"

  CreateDirectory "$R1\lib\ruby\1.8\mget"
  SetOutPath "$R1\lib\ruby\1.8\mget\"
  SetOverwrite try
  File /r "..\lib\mget\*.rb"
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateDirectory "$SMPROGRAMS\mget"
  CreateShortCut "$SMPROGRAMS\mget\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\mget\Manual.lnk" "$INSTDIR\mget.html"
  CreateShortCut "$SMPROGRAMS\mget\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\mget\Downloads.lnk" "$PROGRAMFILES\mget\Downloads\"
  CreateShortCut "$SMPROGRAMS\mget\mget.lnk" "$WINDIR\system32\cmd.exe " "/k cd $PROGRAMFILES\mget\Downloads && mget"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$WINDIR\mget.rb"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$WINDIR\mget.rb"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(msg_uninstall_)"
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(msg_uninstall)" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  ReadRegStr $R1 HKLM "Software\RubyInstaller" "DefaultPath"

  !insertmacro RemoveFilesAndSubDirs "$R1\lib\ruby\1.8\mget"
  !insertmacro RemoveFilesAndSubDirs "$SMPROGRAMS\mget"
  RMDir "$R1\lib\ruby\1.8\mget"
  RMDir "$SMPROGRAMS\mget"

  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninstall.exe"
  Delete "$PROGRAMFILES\mget\COPYING"
  Delete "$PROGRAMFILES\mget\mget.html"
  Delete "$PROGRAMFILES\mget\mget.rb"
  Delete "$PROGRAMFILES\mget\mget.ico"
  Delete "$PROGRAMFILES\mget\mget.bat"
  Delete "$WINDIR\wget.exe"
  Delete "$WINDIR\ffmpeg.exe"
  Delete "$WINDIR\mplayer.exe"
  Delete "$WINDIR\mget.rb"
  Delete "$WINDIR\${PRODUCT_NAME}.url"

  DeleteRegKey HKCR ".mpkg"
  DeleteRegKey HKCR "MPKG"
  DeleteRegKey HKCR "mget"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
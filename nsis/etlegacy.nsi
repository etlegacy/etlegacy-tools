; ------------------------
; ET:Legacy NSIS installer
; ------------------------
; Before running NSIS, ensure to add in the current folder:
; - the NSIS zip plug-in             (http://nsis.sourceforge.net/ZipDLL_plug-in)
; - the NSIS md5 plug-in (ANSI)      (http://nsis.sourceforge.net/MD5_plugin)
; - the NSIS simple firewall plug-in (http://nsis.sourceforge.net/NSIS_Simple_Firewall_Plugin)
; - the ET:Legacy binary files in a "etlegacy-windows-${VERSION}" subfolder without Omni-bot files.
; Change the version number below. You don't need to change anything else.

!define VERSION "2.71rc3"

; ------------------------
; GENERAL
; ------------------------

!addplugindir "."
CRCCheck on
RequestExecutionLevel admin

; Variables
Name "ET:Legacy ${VERSION}"
OutFile "etlegacy-windows-${VERSION}-full-installer.exe"
BrandingText "ET:Legacy ${VERSION} | http://www.etlegacy.com"
!define PRODUCT_DIR_REGKEY "SOFTWARE\Enemy Territory - Legacy"
!define PRODUCT_UNINST_KEY "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Enemy Territory - Legacy"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" "InstallPath"
InstallDir "$PROGRAMFILES\Enemy Territory - Legacy\"

; Header file
!include MUI2.nsh

; Interface configuration
!define MUI_ICON "etlegacy-windows-${VERSION}\etl.ico"
!define MUI_UNICON "etlegacy-windows-${VERSION}\etl.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"     ; 150x57
!define MUI_WELCOMEFINISHPAGE_BITMAP "side.bmp" ; 164x314
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "side.bmp"
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_ABORTWARNING
!define MUI_UNCOMPONENTSPAGE_SMALLDESC

; Pages
!define MUI_FINISHPAGE_TEXT "ET:Legacy ${VERSION} has been installed on your computer.$\n$\n\
You will find your ETKEY, profile folder and all downloaded files in the $DOCUMENTS\ETLegacy directory."
!define MUI_FINISHPAGE_RUN "$INSTDIR\etl.exe"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "etlegacy-windows-${VERSION}\COPYING.txt"
!define MUI_PAGE_HEADER_TEXT "License Agreement - Assets"
!insertmacro MUI_PAGE_LICENSE "EULA_Wolfenstein_Enemy_Territory.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

; ------------------------
; INSTALL
; ------------------------

; Sections
Section "Enemy Territory: Legacy" FILES
    SectionIn RO
    SetOverwrite ifnewer
    SetOutPath $INSTDIR
    File /r "etlegacy-windows-${VERSION}\*.*"
    SimpleFC::AddApplication "ET:Legacy" "$INSTDIR\etl.exe" 0 2 "" 1
    SimpleFC::AddApplication "ET:Legacy server" "$INSTDIR\etlded.exe" 0 2 "" 1
SectionEnd

Section "Wolfenstein: Enemy Territory assets" ASSETS
    SetOverwrite ifdiff
    AddSize 224530
    SetOutPath $TEMP

    SetRegView 32
    ReadRegStr $1 HKLM "Software\Activision\Wolfenstein - Enemy Territory" "InstallPath"

    IfFileExists "$INSTDIR\etmain\pak0.pk3" COPY_PAK1
    IfFileExists "$1\etmain\pak0.pk3" 0 +3
    copyfiles "$1\etmain\pak0.pk3" "$INSTDIR\etmain\"
    GOTO COPY_PAK1
    IfFileExists "$TEMP\etl_install\pak0.pk3" 0 GET_INSTALL
    copyfiles "$TEMP\etl_install\pak0.pk3" "$INSTDIR\etmain\"
    GOTO COPY_PAK1

    COPY_PAK1:
        IfFileExists "$INSTDIR\etmain\pak1.pk3" COPY_PAK2
        IfFileExists "$1\etmain\pak1.pk3" 0 +3
        copyfiles "$1\etmain\pak1.pk3" "$INSTDIR\etmain\"
        GOTO COPY_PAK2
        IfFileExists "$TEMP\etl_install\pak1.pk3" 0 GET_PATCH
        copyfiles "$TEMP\etl_install\pak1.pk3" "$INSTDIR\etmain\"
        GOTO COPY_PAK2

    COPY_PAK2:
        IfFileExists "$INSTDIR\etmain\pak2.pk3" COPY_MP_BIN
        IfFileExists "$1\etmain\pak2.pk3" 0 +3
        copyfiles "$1\etmain\pak2.pk3" "$INSTDIR\etmain\"
        GOTO COPY_MP_BIN
        IfFileExists "$TEMP\etl_install\pak2.pk3" 0 GET_PATCH
        copyfiles "$TEMP\etl_install\pak2.pk3" "$INSTDIR\etmain\"
        GOTO COPY_MP_BIN

    COPY_MP_BIN:
        IfFileExists "$INSTDIR\etmain\mp_bin.pk3" END
        IfFileExists "$1\etmain\mp_bin.pk3" 0 +3
        copyfiles "$1\etmain\mp_bin.pk3" "$INSTDIR\etmain\"
        GOTO END
        IfFileExists "$TEMP\etl_install\mp_bin.pk3" 0 GET_PATCH
        copyfiles "$TEMP\etl_install\mp_bin.pk3" "$INSTDIR\etmain\"
        GOTO END

    GET_INSTALL:
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        NSISdl::download "http://wolffiles.de/filebase/ET/Full%20Version/WolfET.exe" WolfET.exe
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        NSISdl::download "http://mirror.etlegacy.com/WolfET.exe" WolfET.exe
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        NSISdl::download "http://ftp.freenet.de/pub/4players/hosted/et/official/WolfET.exe" WolfET.exe
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        NSISdl::download "http://ftp.games.skynet.be/pub/wolfenstein/WolfET.exe" WolfET.exe
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        NSISdl::download "http://download.hirntot.org/misc/WolfET.exe" WolfET.exe
        IfFileExists "$TEMP\WolfET.exe" CHECK_INSTALL
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download Error: Couldn't fetch Installer file." \
        IDCANCEL USERCANCEL IDRETRY GET_INSTALL

    CHECK_INSTALL:
        md5dll::GetMD5File "$TEMP\WolfET.exe"
        Pop $0
        ${If} $0 == "5cc104767ecdf0feb3a36210adf46a8e"
        GOTO UNPACK_INSTALL
        ${Else}
        Delete "$TEMP\WolfET.exe"
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Integrity Error: Installer MD5 checksum failed." \
        IDCANCEL USERCANCEL IDRETRY GET_INSTALL
        ${EndIf}

    UNPACK_INSTALL:
        MessageBox MB_ICONINFORMATION|MB_OK "During extraction of W:ET assets the screen will get black for a few seconds."
        ExecWait "$TEMP\WolfET.exe /x $TEMP\etl_install"
        IfFileExists "$TEMP\etl_install\pak0.pk3" +2
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Installer extraction failed."
        copyfiles "$TEMP\etl_install\pak0.pk3" "$INSTDIR\etmain"
        IfFileExists "$INSTDIR\etmain\pak0.pk3" COPY_PAK1
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Copy failed (pak0.pk3)."

    GET_PATCH:
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        NSISdl::download "http://wolffiles.de/filebase/ET/Patches/ET_Patch_2_60.exe" ET_Patch_2_60.exe
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        NSISdl::download "http://mirror.etlegacy.com/ET_Patch_2_60.exe" ET_Patch_2_60.exe
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        NSISdl::download "http://ftp.freenet.de/pub/4players/hosted/et/official/ET_Patch_2_60.exe" ET_Patch_2_60.exe
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        NSISdl::download "http://ftp.games.skynet.be/pub/wolfenstein/ET_Patch_2_60.exe" ET_Patch_2_60.exe
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        NSISdl::download "http://download.hirntot.org/misc/ET_Patch_2_60.exe" ET_Patch_2_60.exe
        IfFileExists "$TEMP\ET_Patch_2_60.exe" CHECK_PATCH
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download Error: Couldn't fetch Patch file." \
        IDCANCEL USERCANCEL IDRETRY GET_PATCH

    CHECK_PATCH:
        md5dll::GetMD5File "$TEMP\ET_Patch_2_60.exe"
        Pop $0
        ${If} $0 == "a7ba6fdee3de6150b887068d58e91729"
        GOTO UNPACK_PATCH
        ${Else}
        Delete "$TEMP\ET_Patch_2_60.exe"
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Integrity Error: Patch MD5 checksum failed." \
        IDCANCEL USERCANCEL IDRETRY GET_PATCH
        ${EndIf}

    UNPACK_PATCH:
        ExecWait "$TEMP\ET_Patch_2_60.exe /x $TEMP\etl_install"
        IfFileExists "$TEMP\etl_install\pak1.pk3" +2
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Patch extraction failed."
        copyfiles "$TEMP\etl_install\pak1.pk3" "$INSTDIR\etmain\"
        IfFileExists "$INSTDIR\etmain\pak1.pk3" +2
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Copy failed (pak1.pk3)."
        copyfiles "$TEMP\etl_install\pak2.pk3" "$INSTDIR\etmain\"
        IfFileExists "$INSTDIR\etmain\pak2.pk3" +2
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Copy failed (pak2.pk3)."
        copyfiles "$TEMP\etl_install\mp_bin.pk3" "$INSTDIR\etmain\"
        IfFileExists "$INSTDIR\etmain\mp_bin.pk3" +2
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Copy failed (mp_bin.pk3)."
        GOTO END

    USERCANCEL:
        Messagebox MB_OK|MB_ICONEXCLAMATION "Make sure to copy W:ET assets files (pak0.pk3, pak1.pk3, pak2.pk3 and mp_bin.pk3) into $INSTDIR\etmain before you run ET:Legacy."

    END:
SectionEnd

Section "Omni-bot" OMNIBOT
    AddSize 65000 ; approx
    SetOutPath $TEMP
    GOTO GET_BOT

    GET_BOT:
        IfFileExists "$TEMP\omnibot-windows-latest.zip" UNPACK_BOT
        NSISdl::download "http://mirror.etlegacy.com/omnibot/omnibot-windows-latest.zip" omnibot-windows-latest.zip
        IfFileExists "$TEMP\omnibot-windows-latest.zip" UNPACK_BOT
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download Error: Couldn't fetch Omni-bot files." \
        IDCANCEL END IDRETRY GET_BOT

    UNPACK_BOT:
        ZipDLL::extractall "$TEMP\omnibot-windows-latest.zip" "$INSTDIR\legacy\omni-bot"
        IfFileExists "$INSTDIR\legacy\omni-bot\*.*" END
        MessageBox MB_ICONEXCLAMATION|MB_OK "Fatal Error: Omni-bot extraction failed."

    END:
        SetOutPath $INSTDIR
        CreateDirectory "$SMPROGRAMS\Enemy Territory - Legacy"
        CreateShortCut "$SMPROGRAMS\Enemy Territory - Legacy\Launch Enemy Territory - Legacy with Omni-bots.lnk" "$INSTDIR\etl.exe"  "+set omni_bot enable 1 +set omnibot_path legacy\omni-bot\"
SectionEnd

Section -URI
    WriteRegStr HKCR "et" "URL Protocol" ""
    WriteRegStr HKCR "et" "" "URL: Enemy Territory Protocol"
    WriteRegStr HKCR "et\DefaultIcon" "" "$INSTDIR\etl.exe"
    WriteRegStr HKCR "et\shell\open\command" "" "$INSTDIR\etl.exe +set fs_basepath $\"$INSTDIR$\" +connect $\"%1$\""
SectionEnd

Section -ETKEY
    IfFileExists "$DOCUMENTS\ETLegacy\etmain\etkey" END
    IfFileExists "$LOCALAPPDATA\Punkbuster\ET\etmain\etkey" COPYAPPDATA
    ReadRegStr $1 HKLM "Software\Activision\Wolfenstein - Enemy Territory" "InstallPath"
    IfFileExists "$1\etmain\etkey" COPYETMAIN
    GOTO NOKEY

    COPYAPPDATA:
        MessageBox MB_YESNO "ETKEY found. Do you want to use it with ET:Legacy?" IDNO END
        CreateDirectory `$DOCUMENTS\ETLegacy\etmain`
        CopyFiles `$LOCALAPPDATA\Punkbuster\ET\etmain\etkey` `$DOCUMENTS\ETLegacy\etmain`
        GOTO END

    COPYETMAIN:
        MessageBox MB_YESNO "ETKEY found. Do you want to use it with ET:Legacy?" IDNO END
        CreateDirectory `$DOCUMENTS\ETLegacy\etmain`
        CopyFiles `$1\etmain\etkey` `$DOCUMENTS\ETLegacy\etmain`
        GOTO END

    NOKEY:
        Messagebox MB_OK|MB_ICONINFORMATION "No ETKEY found. ET:Legacy will create a new ETKEY upon start. If you got a Backup of your own ETKEY copy it to $DOCUMENTS\ETLegacy\etmain."
        GOTO END

    END:
SectionEnd

Section -Shortcuts
    SetOutPath $INSTDIR
    CreateDirectory "$SMPROGRAMS\Enemy Territory - Legacy"
    CreateShortCut "$SMPROGRAMS\Enemy Territory - Legacy\Enemy Territory - Legacy Homepage.lnk" "http://www.etlegacy.com" "" "$INSTDIR\etl.ico"
    CreateShortCut "$SMPROGRAMS\Enemy Territory - Legacy\Launch Enemy Territory - Legacy.lnk" "$INSTDIR\etl.exe"
    CreateShortCut "$SMPROGRAMS\Enemy Territory - Legacy\Play on ETLegacy.com.lnk" "et://etlegacy.com:27960" "" "$INSTDIR\etl.ico"
    CreateShortCut "$SMPROGRAMS\Enemy Territory - Legacy\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    CreateShortCut "$DESKTOP\ET-Legacy.lnk" "$INSTDIR\etl.exe"
SectionEnd

Section -Post
    WriteUninstaller "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "InstallPath" "$INSTDIR"
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "Version" "${VERSION}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "Enemy Territory: Legacy"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "ET:Legacy Team"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "http://www.etlegacy.com"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\etl.exe"
    WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoRepair" 1
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${FILES} "Install Enemy Territory: Legacy files."
    !insertmacro MUI_DESCRIPTION_TEXT ${ASSETS} "Retrieve Wolfenstein: Enemy Territory .pk3 assets. Data files will be downloaded if not found locally."
    !insertmacro MUI_DESCRIPTION_TEXT ${OMNIBOT} "Install Omni-bot files for your server or offline training. The latest version will be downloaded."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ------------------------
; UNINSTALL
; ------------------------

Section "un.ET:Legacy" UNFILES
    SectionIN RO
    Delete "$INSTDIR\*.*"
    Delete "$INSTDIR\etmain\*.cfg"
    RMDir /r "$INSTDIR\legacy"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKCR "et"
    RMDir /r "$SMPROGRAMS\Enemy Territory - Legacy"
    Delete "$DESKTOP\ET-Legacy.lnk"
    SimpleFC::RemoveApplication "$INSTDIR\etl.exe"
    SimpleFC::RemoveApplication "$INSTDIR\etlded.exe"
SectionEnd

Section /o "un.Wolf:ET assets" UNASSETS
    Delete "$INSTDIR\etmain\*.pk3"
    RMDir "$INSTDIR\etmain"
    RMDir "$INSTDIR"
SectionEND

Section /o "un.ET:Legacy User files" WOLFETL
    RMDir /r "$DOCUMENTS\ETLegacy"
SectionEND

; Section descriptions
!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${UNFILES} "Uninstall Enemy Territory: Legacy and Omni-bot files."
    !insertmacro MUI_DESCRIPTION_TEXT ${UNASSETS} "Uninstall Wolfenstein: Enemy Territory .pk3 assets (pak0.pk3, pak1.pk3, pak2.pk3 and mp_bin.pk3)."
    !insertmacro MUI_DESCRIPTION_TEXT ${WOLFETL} "Delete ETKEY and all created or downloaded files inside the $DOCUMENTS\ETLegacy folder."
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

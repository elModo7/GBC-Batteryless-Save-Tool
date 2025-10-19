;@Ahk2Exe-SetName PokePrism batteryless save Injector & Extractor
;@Ahk2Exe-SetDescription Extracts & Replaces save files in a batteryless Pokemon Prism
;@Ahk2Exe-SetVersion 1.0
;@Ahk2Exe-SetCopyright Copyright (c) 2025`, elModo7 / VictorDevLog
;@Ahk2Exe-SetOrigFilename Pokemon Prism Batteryless Save Injector & Extractor.exe
version := "1.0"
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <aboutScreen>
#Include <b64logo>
; GDI+ Startup
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll") ; Load module
VarSetCapacity(GdiplusStartupInput, (A_PtrSize = 8 ? 24 : 16), 0) ; GdiplusStartupInput structure
NumPut(1, GdiplusStartupInput, 0, "UInt") ; GdiplusVersion
VarSetCapacity(pToken, 0)
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &GdiplusStartupInput, "Ptr", 0) ; Initialize GDI+

BMPLogo := GdipCreateFromBase64(B64Logo, 2)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip) ; Free GDI+ module from memory


statLabel := "v1.0 elModo7 / VictorDevLog 2025"
Gui +E0x10 +HwndhGui
Gui, Margin, 12, 12
Gui, Font, s10, Segoe UI
Gui, Add, Text, xm ym+2 cGray, Batteryless Pokémon Prism v0.95.254 Save Manager

; -- Left column: Paths and actions -------------------------------------------
Gui, Add, GroupBox, xm y+8 w430 h105, Batteryless ROM
Gui, Add, Text, xm+12 yp+28, Batteryless ROM file dump (.gbc):
Gui, Add, Edit, xm+12 y+4 w330 vRomPath ReadOnly -Wrap
Gui, Add, Button, x+8 yp-1 w70 gBrowseRom, Browse...

; Actions
Gui, Add, Button, xm y+16 w210 h34 gInjectSave Default, Inject Save -> ROM
Gui, Add, Button, x+10 yp w210 h34 gExtractSave, Extract Save -> ROM

; -- Right column: Cover art placeholder --------------------------------------
Gui, Add, GroupBox, x+12 ym w170 h190, Game Cover
Gui, Add, Picture, xp+10 yp+28 w150 h150 vCoverPic Border Center, % "HBITMAP:*" BMPLogo
; Info / Help row
Gui, Add, Button, xm y+16 w150 gOpenFolderRom, Open ROM Folder
Gui, Add, Button, x+8 yp w110 gAbout, About

Gui Add, StatusBar, vstatus, %statLabel%
Gui, Show, w640 h270, Pokémon Prism Bootleg Tool
return

BrowseRom:
    FileSelectFile, pickedRom, 3,, Select Pokémon Prism Batteryless ROM, Game Boy Color ROM (*.gbc)
    setRomFile(pickedRom)
Return

InjectSave:
    GuiControlGet, rom,, RomPath
    if (rom = "")
    {
        MsgBox, 48, Missing path, Please select a ROM first.
        Return
    }
    FileSelectFile, saveFilePath,,,Select save file to inject, *.sav;*.srm;*.sa1
	if (saveFilePath == "")
	{
		fileObj.Close()
		GuiControl,,status, % "Injection cancelled."
		return
	}
	SplitPath, rom, romFileName, romFilePathFolder
	FileCopy, % rom, % romFilePathFolder "\" romFileName ".bak"
	
	saveFileObj := FileOpen(saveFilePath, "r")
	saveFileData := saveFileObj.Read()
	saveFileObj.Close()
	
	fileObj := FileOpen(rom, "rw")
	fileObj.Pos := 0x210000
	fileObj.Write(saveFileData)
	fileObj.Close()
	
	MsgBox 0x40, Done!, Save file injected.
	GuiControl,,status, % "Ready"
Return

ExtractSave:
    GuiControlGet, rom,, RomPath
    if (rom = "")
    {
        MsgBox, 48, Missing ROM, Please select a ROM file first.
        Return
    }
	fileObj := FileOpen(rom, "r")
	fileObj.Pos := 0x210000 ; Save data location
	data := fileObj.Read(0x8030) ; Save data + RTC
	fileObj.Close()

	FileDelete, output.sav
	fileObj2 := FileOpen("output.sav", "w")
	fileObj2.Write(data)
	fileObj2.Close()
	MsgBox 0x40, Done!, Save file was extracted.`nFile: output.sav
	GuiControl,,status, % "Ready."
Return

OpenFolderRom:
    GuiControlGet, rom,, RomPath
    if (rom = "")
    {
        MsgBox, 48, Open ROM Folder, Please select a ROM first.
        Return
    }
    SplitPath, rom, , romDir
    Run, %romDir%
Return

OpenFolderSave:
    GuiControlGet, sav,, SavePath
    if (sav = "")
    {
        MsgBox, 48, Open Save Folder, Please select a Save first.
        Return
    }
    SplitPath, sav, , savDir
    Run, %savDir%
Return

About:
    showAboutScreen("Pokemon Prism Bootleg Tool", "This tool allows you to extract and inject save data to a batteryless patched Pokemon Prism rom (v0.94.254).")
Return


GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	global
    for i, file in FileArray
    {
		setRomFile(file)
	}
}

setRomFile(file) {
	global
	SetWorkingDir, %file%
	GuiControl,,status, Working...
	fileObj := FileOpen(file, "rw")
	if(fileObj.Length > 0x210000)
	{
		if (file != "")
		{
			GuiControl,, RomPath, % file
			SB_SetText("ROM selected.")
		}
		fileObj.Close()
	}
	else
	{
		GuiControl,, RomPath,
		SB_SetText("ROM error.")
		MsgBox, 0x10,Error!, % file "`n`nYour ROM file is not compatible with the patcher! (" fileObj.Length " bits)."
		fileObj.Close()
	}
}

GuiEscape:
GuiClose:
	ExitApp

aboutGuiEscape:
aboutGuiClose:
	AboutGuiClose()
return

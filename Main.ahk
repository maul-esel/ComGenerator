/*
File: Main.ahk
Script: ComGenerator

Purpose:
automatic creation of classes compatible with the CCF (https://github.com/maul-esel/COM-Classes).

Authors:
* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
script header
*/
#SingleInstance force
#NoEnv
#KeyHistory 0
ListLines Off
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
OnExit Cleanup

/*
#Includes
*/
#include CCF\Unknown\Unknown.ahk
#include CCF\TypeInfo\TypeInfo.ahk
#include CCF\TypeLib\TypeLib.ahk

/*
Gui
*/
Gui main: Add, Text, x5 y5, Interface ID (IID):
Gui main: Add, Edit, vInterfaceID x150 yp w300
Gui main: Add, Button, x5 y30 w125 vLoadInfoButton gLoadLibraryInformation, Load

Gui main: Add, Text, x5 yp+40, Interface Name:
Gui main: Add, Edit, vInterfaceName Readonly x150 yp w300
Gui main: Add, Text, x5 yp+30, Type Library GUID:
Gui main: Add, Edit, vTypeLibGUID Readonly x150 yp w300
Gui main: Add, Text, x5 yp+30, Type Library Version:
Gui main: Add, Edit, vTypeLibMajorVer Readonly x150 yp w145
Gui main: Add, Edit, vTypeLibMinorVer Readonly x305 yp w145

Gui main: Add, Button, x5 yp+30 w125 disabled vLoadLibButton gLoadTypeLibrary, Load library
Gui main: Add, Text, vInfoMissingWarning x150 yp w300 cRed hidden, Not enough information available!

Gui main: Show
return

mainGuiClose:
ExitApp
return

Cleanup:
ExitApp
return

LoadLibraryInformation:
Gui main: Submit, NoHide

GuiControl main:, InterfaceName, % name := Registry_GetName4IID(InterfaceID)
GuiControl main:, TypeLibGUID, % libid := Registry_GetTypeLib4IID(InterfaceID)

version := Registry_GetTypeLibVersion4IID(InterfaceID)
StringSplit, version, version,.
GuiControl main:, TypeLibMajorVer, %version1%
GuiControl main:, TypeLibMinorVer, %version2%

if (name && libid && version)
{
	GuiControl main: Disable, LoadInfoButton
	GuiControl main: Disable, InterfaceID
	GuiControl main: Enable, LoadLibButton
	GuiControl main: Hide, InfoMissingWarning
}
else
{
	GuiControl main: Show, InfoMissingWarning
}
return

LoadTypeLibrary:
Gui Submit, NoHide
ptr := TypeLib.FromRegistry(TypeLibGUID)
return

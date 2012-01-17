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

/*
#Includes
*/
#include CCF\Unknown\Unknown.ahk
#include CCF\TypeInfo\TypeInfo.ahk
#include CCF\TypeLib\TypeLib.ahk

#include ErrorCodes.ahk

/*
Gui
*/
Gui main: Add, Groupbox, x5 y0 w620 h95 cGray

Gui main: Add, Text, x10 y10 w300, Interface ID (IID):
Gui main: Add, Edit, vInterfaceID xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vLoadInfoButton gLoadLibraryInformation, Load

Gui main: Add, Text, x320 y10 w300, Interface name:
Gui main: Add, Edit, vInterfaceName xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vSearchIIDButton gSearchIID4Name, Search

Gui main: Add, Text, x10 yp+40, Type Library GUID:
Gui main: Add, Edit, vTypeLibGUID Readonly x150 yp w300
Gui main: Add, Text, x10 yp+30, Type Library Version:
Gui main: Add, Edit, vTypeLibMajorVer Readonly x150 yp w145
Gui main: Add, Edit, vTypeLibMinorVer Readonly x305 yp w145
Gui main: Add, Button, x10 yp+30 w125 disabled vLoadLibButton gLoadTypeLibrary, Load library

Gui main: Add, Text, x10 yp+40, ITypeLib pointer:
Gui main: Add, Edit, vTypeLibPtr Readonly x150 yp w300
Gui main: Add, Button, x10 yp+30 w125 disabled vSearchTypeButton gLoadTypeInfo, Search for type

Gui main: Add, Text, x10 yp+40, ITypeInfo pointer:
Gui main: Add, Edit, vTypeInfoPtr Readonly x150 yp w300
Gui main: Add, Button, x10 yp+30 w125 disabled vGenerateButton gGenerateClass, Generate class

Gui main: Add, Statusbar

Gui main: Default
SB_SetParts(315)
SetStatus(), SetError()

Gui main: Show, w630
return

mainGuiClose:
ExitApp
return

LoadLibraryInformation:
SetStatus("Loading information...")

Gui main: Submit, NoHide

GuiControl main:, InterfaceName, % name := Registry_GetName4IID(InterfaceID)
GuiControl main:, TypeLibGUID, % libid := Registry_GetTypeLib4IID(InterfaceID)

version := Registry_GetTypeLibVersion4IID(InterfaceID)
StringSplit, version, version,.
GuiControl main:, TypeLibMajorVer, %version1%
GuiControl main:, TypeLibMinorVer, %version2%

if (name && libid && version)
{
	GuiControl main: +Readonly, InterfaceID
	GuiControl main: +Readonly, InterfaceName

	GuiControl main: Disable, LoadInfoButton
	GuiControl main: Disable, SearchIIDButton
	GuiControl main: Enable, LoadLibButton

	SetError()
}
else
{
	SetError("Not enough information available!")
}
SetStatus()
return


SearchIID4Name:
SetStatus("Searching type...")

Gui main: Submit, NoHide

if (!InterfaceName)
{
	SetError("No name specified."), SetStatus()
	return
}

iid := Registry_SearchIID4Name(InterfaceName)
GuiControl main:, InterfaceID, % iid ? iid : ""

if (iid)
{
	SetError()
}
else
{
	SetError("Could not find interface """ . InterfaceName . """.")
}
SetStatus()
return

LoadTypeLibrary:
SetStatus("Loading type library...")

Gui Submit, NoHide

try
{
	lib := TypeLib.FromRegistry(TypeLibGUID, TypeLibMajorVer, TypeLibMinorVer)
}
catch exception
{
	SetError("Could not load type library """ . TypeLibGUID . """."), SetStatus()
	return
}
GuiControl main:, TypeLibPtr, % lib.ptr
GuiControl main: Enable, SearchTypeButton

SetError(), SetStatus()
return

LoadTypeInfo:
SetStatus("Loading type info...")

Gui Submit, NoHide

try
{
	type := lib.GetTypeInfoOfGuid(InterfaceID)
}
catch exception
{
	SetError("Could not load type """ . InterfaceName . """ from type library """ . TypeLibGUID . """."), SetStatus()
	return
}
GuiControl main:, TypeInfoPtr, % type.ptr
GuiControl main: Enable, GenerateButton

SetError(), SetStatus()
return

GenerateClass:
throw Exception("Not implemented!", -1)
return

SetStatus(text = "Ready.")
{
	Gui main: Default
	SB_SetText(text, 1)
}

SetError(text = "")
{
	Gui main: Default
	SB_SetText("`t`t" . text, 2)
}
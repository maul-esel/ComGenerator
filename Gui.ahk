/*
File: Gui.ahk
Script: ComGenerator

Purpose:
	Holds the UI-related code.

Authors:
* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+

License:
	http://unlicense.org
*/
/*
Label: BuildGui
builds the GUI
*/
BuildGui:
Gui main: New,, ComGenerator

Gui main: Add, Groupbox, x5 y0 w620 h95 cGray

Gui main: Add, Text, x10 y10 w300, Interface ID (IID):
Gui main: Add, Edit, vInterfaceID xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vLoadInfoButton gGui_LoadLibraryInformation, Load

Gui main: Add, Text, x320 y10 w300, Interface name:
Gui main: Add, Edit, vInterfaceName xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vSearchIIDButton gGui_SearchIID4Name, Search

Gui main: Add, Text, x10 yp+40, Type Library GUID:
Gui main: Add, Edit, vTypeLibGUID Readonly x150 yp w300
Gui main: Add, Text, x10 yp+30, Type Library Version:
Gui main: Add, Edit, vTypeLibMajorVer Readonly x150 yp w145
Gui main: Add, Edit, vTypeLibMinorVer Readonly x305 yp w145
Gui main: Add, Button, x10 yp+30 w125 disabled vLoadLibButton gGui_LoadTypeLibrary, Load library

Gui main: Add, Text, x10 yp+40, ITypeLib pointer:
Gui main: Add, Edit, vTypeLibPtr Readonly x150 yp w300
Gui main: Add, Button, x10 yp+30 w125 disabled vLoadTypeButton gGui_LoadTypeInfo, Search for type

Gui main: Add, Text, x10 yp+40, ITypeInfo pointer:
Gui main: Add, Edit, vTypeInfoPtr Readonly x150 yp w300
Gui main: Add, Button, x10 yp+30 w125 disabled vGenerateButton gGui_GenerateClass, Generate class

Gui main: Add, Statusbar

Gui main: Default
SB_SetParts(210, 210)
Status(), Error()

Gui main: Show, w630
return

/*
Label: Gui_LoadLibraryInformation
*/
Gui_LoadLibraryInformation:
Status("Loading information...")

Gui main: Submit, NoHide

GuiControl main:, InterfaceName, % name := GetName4IID(InterfaceID)
GuiControl main:, TypeLibGUID, % libid := GetTypeLib4IID(InterfaceID)

version := GetTypeLibVersion4IID(InterfaceID)
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

	Error()
}
else
{
	Error("Not enough information available!")
}
Status()
return

/*
Label: Gui_SearchIID4Name
*/
Gui_SearchIID4Name:
Gui main: Submit, NoHide
if (!InterfaceName)
{
	Error("No name specified."), Status()
	return
}
iid := SearchIID4Name(InterfaceName)
GuiControl main:, InterfaceID, % iid ? iid : ""
return

/*
Label: Gui_LoadTypeLibrary
*/
Gui_LoadTypeLibrary:
Gui main: Submit, NoHide
lib := LoadTypeLibrary(TypeLibGUID, TypeLibMajorVer, TypeLibMinorVer)

GuiControl main:, TypeLibPtr, % lib.ptr
if IsObject(lib)
	GuiControl main: Enable, SearchTypeButton
return

/*
Label: Gui_LoadTypeInfo
*/
Gui_LoadTypeInfo:
Gui main: Submit, NoHide
type := LoadTypeInfo(lib, InterfaceID)

GuiControl main:, TypeInfoPtr, % type.ptr
if IsObject(type)
	GuiControl main: Enable, GenerateButton
return

/*
Label: Gui_GenerateClass
*/
Gui_GenerateClass:
throw Exception("Not implemented!", -1)
return

/*
Label: mainGuiClose
Invoked when the main window is closed.

Remarks:
	Any cleanup not directly connected to the UI should instead be placed in an OnExit label.
*/
mainGuiClose:
ExitApp
return

/*
Function: Gui_Status
If the app is in GUI mode, reports the current status to the user

Parameters:
	STR text - the text to report
*/
Gui_Status(text = "Ready.")
{
	Gui main: Default
	SB_SetText(text, 1)
}

/*
Function: Gui_Error
If the app is in GUI mode, reports an error to the user

Parameters:
	STR text - the text to report
*/
Gui_Error(code, msg)
{
	Gui main: Default
	SB_SetText("`t`t" . ERROR.Messages[code]), SB_SetText("`t`t" . msg, 2)
}
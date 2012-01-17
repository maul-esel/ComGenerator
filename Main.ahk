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
check app mode
*/
if 0 > 0 ; CMD mode
{
	IsUIMode(false)
	Cmd_Run(Cmd_Arguments())
}
else ; UI mode
{
	IsUIMode(true)
	Gosub BuildGui
}
return

/*
Function: Status
Reports the current status to the user
*/
Status(text = "Ready.")
{
	return IsUIMode() ? Gui_Status(text) : Cmd_Status(text)
}

/*
Function: Error
Reports an error to the user.

Parameters:
	[opt] UINT code - the error to report. Take the value from the ERROR class.
	[opt] BOOL exit - if the app is in CMD mode, defines whether the app should be shut down.
	[opt] STR msg - an additional message to display.
*/
Error(code = -1, exit = false, msg = "")
{
	return IsUIMode() ? Gui_Error(code, msg) : Cmd_Error(code, exit, msg)
}

/*
Function: IsUIMode
retrieves whether the app is in UI mode or not. The value defaults to "false". If a value of "true" is passed, the value is changed.
*/
IsUIMode(val = true)
{
	static is_ui := false
	if val
		is_ui := true
	return val
}

GetName4IID(iid)
{
	Status("Reading interface name for interface """ . iid . """.")
	name := Registry_GetName4IID(iid)
	if (!name)
	{
		return "", Status(), Error(ERROR.READ_NAME, false, "IID: " . iid)
	}
	return name, Status(), Error()
}

GetTypeLib4IID(iid)
{
	Status("Reading type library guid for interface """ . iid . """.")
	guid := Registry_GetTypeLib4IID(iid)
	if (!guid)
	{
		return 0, Status(), Error(ERROR.READ_TYPELIB, true, "IID: " . iid)
	}
	return guid, Status(), Error()
}

GetTypeLibVersion4IID(iid)
{
	Status("Reading type library version for """ . iid . """.")
	version := Registry_GetTypeLibVersion4IID(iid)
	if (!version)
	{
		return "", Status(), Error(ERROR.READ_TYPELIB_VERSION, true, "IID: " . iid)
	}
	return version, Status(), Error()
}

SearchIID4Name(name)
{
	Status("Searching IID for interface """ . name . """.")
	iid := Registry_SearchIID4Name(name)
	if (!iid)
	{
		return 0, Status(), Error(ERROR.FIND_INTERFACE, true, "Interface: " . name)
	}
	return iid, Status(), Error()
}

LoadTypeLibrary(guid, vMajor, vMinor)
{
	Status("Loading type library """ . guid . """...")
	try
	{
		lib := TypeLib.FromRegistry(guid, vMajor, vMinor)
	}
	catch exception
	{
		return false, Status(), Error(ERROR.LOAD_LIBRARY, true, "Type library: " . guid)
	}
	return lib, Status(), Error()
}

LoadTypeInfo(lib, iid)
{
	Status("Loading type info for """ . iid . """...")
	try
	{
		type := lib.GetTypeInfoOfGuid(iid)
	}
	catch exception
	{
		return false, Status(), Error(ERROR.LOAD_TYPE, true, "IID: " . iid)
	}
	return type, Status(), Error()
}

/*
#Includes (not executed at loadtime)
*/
#include CCF\Unknown\Unknown.ahk
#include CCF\TypeInfo\TypeInfo.ahk
#include CCF\TypeLib\TypeLib.ahk

#include Gui.ahk
#include Cmd.ahk
#include ERROR.ahk
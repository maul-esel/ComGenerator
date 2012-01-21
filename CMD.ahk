/*
File: CMD.ahk
Script: ComGenerator

Purpose:
	Holds the commandline-related code.

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
Function: Cmd_Status
If the app is in CMD mode, reports  reports the current status to the user

Parameters:
	STR text - the text to report
*/
Cmd_Status(text)
{
	static out
	if !IsObject(out)
		out := FileOpen(DllCall("GetStdHandle", "UInt", -11, "UPtr"), "h `n") ; create object here because it requires AttachConsole() to be called previously

	out.WriteLine(text)
	out.Read(0)
}

/*
Function: Cmd_Error
If the app is in CMD mode, , reports an error to the user

Parameters:
	STR text - the text to report
	BOOL exit - true if the app should be shutdown
*/
Cmd_Error(code, exit, msg)
{
	static err
	if !IsObject(err)
		err := FileOpen(DllCall("GetStdHandle", "UInt", -12, "UPtr"), "h `n") ; same as in Cmd_Status

	msg ? err.WriteLine(msg) : ""
	err.WriteLine(ERROR.Messages[code])
	err.Read(0)

	if (exit)
		ExitApp code
}

/*
Function: Cmd_Arguments
process command line arguments and returns them as an array
*/
Cmd_Arguments()
{
	global 0
	static args

	if !IsObject(args)
	{
		args := []
		Loop %0%
			args.Insert(%A_Index%) ; dynamic vars resolve to globals
	}
	return args
}

/*
Function: Cmd_Run
The main execution routine

Parameters:
	ARRAY args - the command line parameters as returned by <Cmd_Arguments>.
*/
Cmd_Run(args)
{
	; check if a name was passed:
	name_index := Cmd_IndexOf(args, "--name")
	if (name_index)
	{
		name := args[name_index + 1]
		if (name)
			iid := SearchIID4Name(name)
	}

	; check if an IID was passed (overrides name):
	iid_index := Cmd_IndexOf(args, "--iid")
	if (iid_index)
	{
		iid2 := args[iid_index + 1]
		if (iid2)
			iid := iid2
	}

	; check if a CLSID of an implementing class was passed:
	clsid_index := Cmd_IndexOf(args, "--clsid")
	if (clsid_index)
	{
		clsid := args[clsid_index + 1]
		if (!clsid)
			return Error(ERROR.INVALID_CMD, true), Status()
	}

	; ensure an interface was passed via IID or name:
	if (!iid)
	{
		return Error(ERROR.INVALID_CMD, true), Status()
	}

	version := AHKVersion.NONE

	if (Cmd_IndexOf(args, "--ahk_L"))
		version |= AHKVersion.AHK_L
	if (Cmd_IndexOf(args, "--ahk2"))
		version |= AHKVersion.AHK2

	if (version == AHKVersion.NONE)
		version := AHKVersion.AHK2

	lib_guid := GetTypeLib4IID(iid)
	version := GetTypeLibVersion4IID(iid)
	StringSplit version, version, .

	lib := LoadTypeLibrary(lib_guid, version1, version2)
	type := LoadTypeInfo(lib, iid)

	Error(ERROR.NOT_IMPLEMENTED, true, "Class generation:")
}

/*
Function: Cmd_IndexOf
a small wrapper function that returns the index of a specified value in an array
*/
Cmd_IndexOf(array, value)
{
	for index, val in array
		if (val == value)
			return index
}
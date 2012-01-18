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
		out := FileOpen(DllCall("GetStdHandle", "UInt", -11, "UPtr"), "h `n")
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
		err := FileOpen(DllCall("GetStdHandle", "UInt", -12, "UPtr"), "h `n")
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
			args.Insert(%A_Index%)
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
	name_index := Cmd_IndexOf(args, "--name")
	if (name_index)
	{
		name := args[name_index + 1]
		if (name)
			iid := SearchIID4Name(name)
	}

	iid_index := Cmd_IndexOf(args, "--iid")
	if (iid_index)
	{
		iid2 := args[iid_index + 1]
		if (iid2)
			iid := iid2
	}

	if (!iid)
	{
		return Error(ERROR.INVALID_CMD, true), Status()
	}
}

Cmd_IndexOf(array, value)
{
	for index, val in array
		if (val == value)
			return index
}
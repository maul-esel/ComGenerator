/*
Function: FormatHRESULT
formats a HRESULT error code and returns a description in the system language

Parameters:
	[opt] HRESULT hr - the error code to format. If ommitted, A_LastError is used.

Returns:
	STR description - the description

Credits:
	Inspired by Bentschi's A_LastError() function (german forum)
*/
FormatHRESULT(error = "~")
{
	static ALLOCATE_BUFFER := 0x00000100, FROM_SYSTEM := 0x00001000, IGNORE_INSERTS := 0x00000200

	error := error == "~" ? A_LastError : error
	size := DllCall("FormatMessage", "UInt", ALLOCATE_BUFFER|FROM_SYSTEM|IGNORE_INSERTS, "UPtr", 0, "UInt", error, "UInt", 0x10000, "UPtr*", bufaddr, "UInt", 0, "UPtr", 0)
    msg := StrGet(bufaddr, size)

	return error . " - " . msg
}
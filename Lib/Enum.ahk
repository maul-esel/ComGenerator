/*
File: Enum.ahk
Script: ComGenerator

Purpose:
	helper methods for enum handling

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
Function: Enum_HasFlag
checks if a value combined using the "|" operator has a specific flag

Parameters:
	UINT var - the variable to check
	UINT flag - the flag to check for

Remarks:
	All flags combined to var as well as flag must be powers of 2
*/
Enum_HasFlag(var, flag)
{
	return (var & flag) == flag
}
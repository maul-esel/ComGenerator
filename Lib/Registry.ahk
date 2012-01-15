/*
Function: Registry_GetName4IID
gets the interface name for the specified IID.

Parameters:
	STR iid - the IID of the interface

Returns:
	STR name - the interface name, if found
*/
Registry_GetName4IID(iid)
{
	RegRead, name, HKCR, Interface\%iid%
	return name
}

/*
Function: Registry_GetTypeLib4IID
gets the type library GUID for the specified interface.

Parameters:
	STR iid - the IID of the interface

Returns:
	STR guid - the GUID of the type library, if found.
*/
Registry_GetTypeLib4IID(iid)
{
	RegRead, lib, HKCR, Interface\%iid%\TypeLib
	return lib
}

/*
Function: Registry_GetTypeLibVersion4IID
gets the type library version for the specified interface

Parameters:
	STR iid - the IID of the interface

Returns:
	STR version - the version number, if found
*/
Registry_GetTypeLibVersion4IID(iid)
{
	RegRead version, HKCR, Interface\%iid%\TypeLib, Version
	return version
}

/*
Function: Registry_GetMethodCount4IID
gets the number of methods in the specified interface

Parameters:
	STR iid - the IID of the interface

Returns:
	UINT count - the method count, including inherited members. If this is 0, the number was not found.
*/
Registry_GetMethodCount4IID(iid)
{
	RegRead count, HKCR, Interface\%iid%\NumMethod
	return count
}
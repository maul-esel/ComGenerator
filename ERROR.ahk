class ERROR
{
	static CLEAR := -1

	static SUCCESS := 0x00

	static ABORTED := 0x01

	static INVALID_CMD := 0x02

	static FIND_INTERFACE := 0x03

	static READ_NAME := 0x04

	static READ_TYPELIB := 0x05

	static READ_TYPELIB_VERSION := 0x06

	static LOAD_LIBRARY := 0x07

	static LOAD_TYPE := 0x08

	static NAME_MISSING := 0x09

	static NOT_IMPLEMENTED := 0x0A

	static Messages := { (ERROR.CLEAR) : ""
						, (ERROR.SUCCESS) : "Success!"
						, (ERROR.ABORTED) : "Operation aborted by user."
						, (ERROR.INVALID_CMD) : "Invalid command line options."
						, (ERROR.FIND_INTERFACE) : "The IID for the specified interface name could not be found."
						, (ERROR.READ_NAME) : "The name for the specified IID could not be read."
						, (ERROR.READ_TYPELIB) : "The type library for the specified IID could not be read."
						, (ERROR.READ_TYPELIB_VERSION) : "The type library version for the specified IID could not be read."
						, (ERROR.LOAD_LIBRARY) : "The type library could not be loaded."
						, (ERROR.LOAD_TYPE) : "The specified type could not be loaded from the type library."
						, (ERROR.NAME_MISSING) : "No name was specified."
						, (ERROR.NOT_IMPLEMENTED) : "This action has not yet been implemented." }
}
/*
File: CCFGenerator.ahk
Script: ComGenerator

Purpose:
	the actual creation of classes

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
class CCFGenerator
{
	AHK2Methods := []

	AHKLMethods := []

	version := AHKVersion.NONE

	typeInfo := 0

	__New(type, version)
	{
		this.typeInfo := type, this.version := version
	}

	isAHK_L()
	{
		return Enum_HasFlag(this.version, AHKVersion.AHK_L)
	}

	isAHK2()
	{
		return Enum_HasFlag(this.version, AHKVersion.AHK2)
	}

	Generate()
	{
		tkind := this.typeInfo.GetTypeAttr().typekind
		if (tkind == TYPEKIND.ENUM)
			return GenerateEnumClass()
		else if (tkind == TYPEKIND.RECORD)
			return GenerateStructClass()
		else if (tkind == TYPEKIND.INTERFACE)
			return GenerateInterfaceClass()
		else
			throw Exception("CCFGenerator.Generate(): The specified type information cannot be wrapped into a CCF class.", -1)
	}

	GenerateInterfaceClass()
	{
	
	}

	GenerateStructClass()
	{
	
	}

	GenerateEnumClass()
	{
		if (!this.typeInfo.GetDocumentation(MEMBERID.NIL, enum_name, enum_doc))
			throw Exception("Error calling TypeInfo.GetDocumentation():`n`t" . this.typeInfo.error.description, -1)
		for each, var in ITypeInfoEx_LoadVariables(this.typeInfo)
		{
			if (var.varkind != VARKIND.CONST)
				throw Exception("CCFGenerator.GenerateEnumClass(): only constant variables can be wrapped!", -1)

			if (!this.typeInfo.GetDocumentation(var.memid, name, doc))
				throw Exception("CCFGenerator.GenerateEnumClass(): Error calling TypeInfo.GetDocumentation():`n`t" . this.typeInfo.error.description, -1)

			/*
			TODO:
				* (map to AHK type)
				* create documentation
				* get value from var.lpvarValue
			*/
			type := var.elemdescVar.tdesc.vt
			if (type == VARENUM.PTR || type == VARENUM.ARRAY || type == VARENUM.CARRAY || type == VARENUM.USERDEFINED)
			{
				throw Exception("CCFGenerator.GenerateEnumClass(): Cannot handle pointers, arrays, safearrays or user-defined types in enumerations!", -1)
			}
			NumPut(NumGet(1*var.lpvarValue, 00, "UInt64"), value, 00, "UInt64")
		}
	}
}


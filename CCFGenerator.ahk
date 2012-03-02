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

	typeInfo2 := 0

	typeAttr := 0

	__New(type, version)
	{
		this.typeInfo := type, this.version := version
		this.typeAttr := type.GetTypeAttr(), this.typeInfo.AddRef()

		pTypeInfo2 := type.QueryInterface(TypeInfo2.IID)
		if (pTypeInfo2 != 0)
			this.typeInfo2 := new TypeInfo2(pTypeInfo2)
	}

	__Delete()
	{
		this.typeInfo.ReleaseTypeAttr(this.typeAttr), this.typeInfo.Release()
		if (this.typeInfo2)
			this.typeInfo2.Release()
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
		tkind := this.typeAttr.typekind
		if (tkind == TYPEKIND.ENUM)
			return this.GenerateEnumClass()
		else if (tkind == TYPEKIND.RECORD)
			return this.GenerateStructClass()
		else if (tkind == TYPEKIND.INTERFACE)
			return this.GenerateInterfaceClass()
		else
			throw Exception("CCFGenerator.Generate(): The specified type information cannot be wrapped into a CCF class.", -1, "Type was of kind """ Obj_FindValue(TYPEKIND, tkind) """.")
	}

	GenerateInterfaceClass()
	{
		if (!this.typeInfo.GetDocumentation(MEMBERID.NIL, interface_name, interface_doc))
			if (!this.typeInfo2 || !this.typeInfo2.GetDocumentation2(MEMBERID.NIL, 0, interface_doc))
				throw Exception("Error calling TypeInfo.GetDocumentation()", -1, this.typeInfo.error.description)

		; wrapping base types:
		Loop % this.typeAttr.cImplTypes + 1
		{
			; TODO: if already wrapped
			;	continue
			hreftype := this.typeInfo.GetRefTypeOfImplType(A_Index)
			info := this.typeInfo.GetRefTypeInfo(hreftype)
			basetype := new CCFGenerator(info, this.version)

			try {
				result := basetype.Generate()
			} catch ex {
				;throw Exception("CCFGenerator.GenerateInterfaceClass(): A base type could not be generated.", -1, ex.extra)
			}
		}

		Loop % this.typeAttr.cFuncs
		{
			func := this.typeInfo.GetFuncDesc(A_Index - 1)
			id := func.memid
			this.typeInfo.GetDocumentation(id, name, doc)

			if (func.funckind != FUNCKIND.PUREVIRTUAL)
				throw Exception("Can only wrap pure virtual methods!", -1, "Method """ name """ is of kind """ Obj_FindValue(FUNCKIND, func.funckind) """.")

			vtbl_index := func.oVft // A_PtrSize
			; todo: wrap method

			if (func.invkind != INVOKEKIND.METHOD)
			{
				; todo: create pseudo-property
			}

			MsgBox % func.GetOriginalPointer()
			this.typeInfo.ReleaseFuncDesc(func)
		}
	}

	GenerateStructClass()
	{
	
	}

	GenerateEnumClass()
	{
		if (!this.typeInfo.GetDocumentation(MEMBERID.NIL, enum_name, enum_doc))
			throw Exception("Error calling TypeInfo.GetDocumentation()", -1, this.typeInfo.error.description)
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


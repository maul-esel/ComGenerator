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
		if (pTypeInfo2)
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
		return CCFramework.HasEnumFlag(this.version, AHKVersion.AHK_L)
	}

	isAHK2()
	{
		return CCFramework.HasEnumFlag(this.version, AHKVersion.AHK2)
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

		; TODO: if not already wrapped {
		baseRef := this.typeInfo.GetRefTypeOfImplType(0)
		, baseInfo := this.typeInfo.GetRefTypeInfo(hreftype)
		, baseGenerator := new CCFGenerator(info, this.version)

		try {
			result := baseGenerator.Generate()
		} catch exception {
			;throw Exception("CCFGenerator.GenerateInterfaceClass(): The base type could not be generated.", -1, ex.extra)
		}
		; }

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
			MsgBox % var.varkind " - " Obj_FindValue(VARKIND, var.varkind) " - " var.lpstrSchema
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

	IsIDispatch()
	{
		return CCFramework.HasEnumFlag(this.typeAttr.wTypeFlags, TYPEFLAG.FDISPATCHABLE)
	}

	GetNameForHREFTYPE(href)
	{
		info := this.typeInfo.GetRefTypeInfo(href)
		info.GetDocumentation(-1, name)
		return name
	}

	ResolveType(tdesc)
	{
		if (tdesc.vt == VARENUM.PTR)
			return this.ResolveType(tdesc.lptdesc) "*"
		else if (tdesc.vt == VARENUM.SAFEARRAY)
			return "ComObjArray[" this.ResolveType(tdesc.lptdesc) "]"
		else if (tdesc.vt == VARENUM.CARRAY)
		{
			; todo
		}
		else if (tdesc.vt == VARENUM.USERDEFINED)
		{
			return this.GetNameForHREFTYPE(tdesc.hreftype)
		}

		; "normal" types
		if (tdesc.vt == VARENUM.I1)
			return "Char"
		else if (tdesc.vt == VARENUM.UI1)
			return "UChar"
		else if (tdesc.vt == VARENUM.I2)
			return "Short"
		else if (tdesc.vt == VARENUM.UI2)
			return "UShort"
		else if (tdesc.vt == VARENUM.I4 || tdesc.vt == VARENUM.BOOL || tdesc.vt == VARENUM.INT || tdesc.vt == VARENUM.HRESULT)
			return "Int"
		else if (tdesc.vt == VARENUM.UI4 || tdesc.vt == VARENUM.UINT)
			return "UInt"
		else if (tdesc.vt == VARENUM.I8 || tdesc.vt == VARENUM.UI8)
			return "Int64"
		else if (tdesc.vt == VARENUM.R4)
			return "Float"
		else if (tdesc.vt == VRENUM.R8)
			return "Double"
		else if (tdesc.vt == VARENUM.CY)
			throw Exception("Type 'CY' could not be mapped.", -1, "Not implemented")
		else if (tdesc.vt == VARENUM.DATE)
			throw Exception("Type 'DATE' could not be mapped.", -1, "Not implemented")
		else if (tdesc.vt == VARENUM.BSTR || tdesc.vt == VARENUM.LPSTR)
			return "Str"
		else if (tdesc.vt == VARENUM.LPWSTR)
			return this.isAHK_L() ? "WStr" : "Str"
		else if (tdesc.vt == VARENUM.DISPATCH || tdesc.vt == VARENUM.UNKNOWN)
			return "Ptr"
		else if (tdesc.vt == VARENUM.ERROR)
			throw Exception("Type 'ERROR' could not be mapped.", -1, "Not implemented")
		else if (tdesc.vt == VARENUM.VARIANT)
			throw Exception("Type 'VARIANT' could not be mapped.", -1, "Not implemented")
		else if (tdesc.vt == VARENUM.DECIMAL)
			throw Exception("Type 'DECIMAL' could not be mapped.", -1, "Not implemented")
		else if (tdesc.vt == VARENUM.VOID)
			return ""
		throw Exception("Could not resolve type", -1, "VT value: " tdesc.vt (name := Obj_FindValue(VARENUM, vt) ? " - " name : ""))
	}
}


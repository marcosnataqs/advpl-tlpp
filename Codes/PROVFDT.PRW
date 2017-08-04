#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} PROVFDT

Exporta relatório de verbas referente a férias e décimo
terceiro analítico e sintético.

@author Marcos Natã Santos
@since 05/10/2016
@version undefined

@type function
/*/

User Function PROVFDT()
	Local oComboBo1
	Local oComboBo2
	Local oGet1
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local aButtons := {}
	Static oDlg
	Private cComboBo1 := "Sintetico"
	Private cComboBo2 := "Ferias"
	Private dGet1 := Date()

	DEFINE MSDIALOG oDlg TITLE "Provisão Férias/Décimo Terceiro" FROM 000, 000  TO 265, 500 COLORS 0, 16777215 PIXEL

	@ 015, 024 GROUP oGroup1 TO 060, 224 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 027, 035 SAY oSay1 PROMPT "Sintético: verba por centro de custo" SIZE 098, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 035 SAY oSay2 PROMPT "Analítico: funcionário por verba" SIZE 083, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 035 SAY oSay6 PROMPT "Data ref.: data do cálculo da provisão" SIZE 092, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 077, 025 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"Sintetico","Analitico"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 077, 140 MSCOMBOBOX oComboBo2 VAR cComboBo2 ITEMS {"Ferias","Decimo Terceiro","Ambos"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 025 SAY oSay3 PROMPT "Tipo:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 140 SAY oSay4 PROMPT "Por:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 095, 025 SAY oSay5 PROMPT "Data Ref.:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 025 MSGET oGet1 VAR dGet1 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| ProcExport()} , {|| oDlg:End()},, aButtons)

Return

// Configura exportação
Static Function ProcExport()
	Local cDataRec := DTOC(dGet1)
	Private cDataRef := SUBSTR(cDataRec, 7, 4) + SUBSTR(cDataRec, 4, 2) + SUBSTR(cDataRec, 1, 2)
	Private cTargetDir := "C:\Windows\Temp\"
	Private cTableName := cComboBo1 + " - " + cComboBo2
	Private cFerias := "'830', '831', '832', '833', '834'"
	Private cDecTerc := "'845', '846', '847', '848'"
	Private cAmbos := cFerias + ", " + cDecTerc
	Private cTipo := cComboBo1
	Private cPor := cComboBo2

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")

Return

// Estrutura do arquivo excel
Static Function RunExport()
	Private oExcel := FWMsExcel():New()
	Private oExcelApp := MsExcel():New()
	Private aHead := {}
	Private aRow := {}

	oExcel:AddworkSheet("provfdt")
	oExcel:AddTable("provfdt", cTableName)

//	If cTipo = "Sintetico"
//		HeadSnt()
//		BodySnt()
//	ElseIf cTipo = "Analitico"
		HeadAnl()
		BodyAnl()
//	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile(cTargetDir + "provfdt"+cDataRef+".xls")
	oExcelApp:WorkBooks:Open(cTargetDir + "provfdt"+cDataRef+".xls")
	oExcelApp:SetVisible(.T.)

Return

// FUNÇÃO NÃO UTILIZADA
// Cria cabeçalho sintético
Static Function HeadSnt()
	cQry := "SELECT SRZ.RZ_CC CC, COUNT(SRZ.RZ_CC) TOTAL FROM SRZ010 SRZ "
	cQry += "WHERE SRZ.D_E_L_E_T_ = ' ' "
	cQry += "AND SRZ.RZ_CC LIKE '1%' "
	cQry += "OR SRZ.RZ_CC LIKE '2%' "
	cQry += "GROUP BY SRZ.RZ_CC "
	cQry += "ORDER BY SRZ.RZ_CC "

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	AADD(aHead, "Verba")
	oExcel:AddColumn("provfdt", cTableName, "Verba x CC", 2, 1)

	AADD(aHead, "Desc")
	oExcel:AddColumn("provfdt", cTableName, "Descrição", 2, 1)

	While QRY->(!EOF())
		oExcel:AddColumn("provfdt", cTableName, QRY->CC, 2, 3, .T.)
		AADD(aHead, QRY->CC)
		QRY->(DbSkip())
	EndDo

	AADD(aHead, "Total")
	oExcel:AddColumn("provfdt", cTableName, "Total", 2, 3, .T.)

Return

// FUNÇÃO NÃO UTILIZADA
// Gera corpo de dados sintético
Static Function BodySnt()
	Local i
	Local cTmp
	Local cRange
	Local nTotalCalc := 0
	aRow := Array(Len(aHead))

	If cPor = "Ferias"
		cRange := cFerias
	ElseIf cPor = "Decimo Terceiro"
		cRange := cDecTerc
	Else
		cRange := cAmbos
	EndIf

	cQry := "SELECT SRV.RV_COD VERBA, SRV.RV_DESC DES, SRZ.RZ_CC CC, SRZ.RZ_MAT MAT, SRZ.RZ_VAL TOTAL "
	cQry += "FROM SRV010 SRV "
	cQry += "LEFT JOIN SRZ010 SRZ ON SRV.RV_COD = SRZ.RZ_PD "
	cQry += "AND SRZ.D_E_L_E_T_ = ' ' "
	cQry += "WHERE SRV.D_E_L_E_T_ = ' ' "
	cQry += "AND SRV.RV_COD IN ("+ cRange +") "
	cQry += "ORDER BY SRZ.RZ_PD, SRZ.RZ_CC, SRZ.RZ_MAT DESC "

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	cTmp := QRY->VERBA

	While QRY->(!EOF())
		IncProc(ALLTRIM(QRY->VERBA) + " - " + ALLTRIM(QRY->CC))
		If cTmp = QRY->VERBA
			For i := 1 To Len(aHead)
				If aHead[i] = "Desc" .And. Empty(aRow[i])
					aRow[i] := QRY->DES
				EndIf
				If aHead[i] = "Verba" .And. Empty(aRow[i])
					aRow[i] := QRY->VERBA
				EndIf
				If QRY->CC = aHead[i] .And. QRY->MAT = "zzzzzz"
					aRow[i] := QRY->TOTAL
				EndIf
			Next
			cTmp := QRY->VERBA
		Else
			For i := 1 To Len(aHead)
				If Empty(aRow[i])
					aRow[i] := 0
				EndIf
				If aHead[i] != "Desc" .And. aHead[i] != "Verba" .And. aHead[i] != "Total"
					nTotalCalc += aRow[i]
				EndIf
				If aHead[i] = "Total" .And. Empty(aRow[i])
					aRow[i] := nTotalCalc
				EndIf
				If aHead[i] = "Total" .And. !Empty(aRow[i])
					oExcel:AddRow("provfdt", cTableName, aRow)
					nTotalCalc := 0
				EndIf
			Next
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				If aHead[i] = "Desc" .And. Empty(aRow[i])
					aRow[i] := QRY->DES
				EndIf
				If aHead[i] = "Verba" .And. Empty(aRow[i])
					aRow[i] := QRY->VERBA
				EndIf
				If QRY->CC = aHead[i] .And. QRY->MAT = "zzzzzz"
					aRow[i] := QRY->TOTAL
				EndIf
			Next
			cTmp := QRY->VERBA
		EndIf
		QRY->(DbSkip())
		If QRY->(EOF())
			For i := 1 To Len(aHead)
				If Empty(aRow[i])
					aRow[i] := 0
				EndIf
				If aHead[i] != "Desc" .And. aHead[i] != "Verba" .And. aHead[i] != "Total"
					nTotalCalc += aRow[i]
				EndIf
				If aHead[i] = "Total" .And. Empty(aRow[i])
					aRow[i] := nTotalCalc
				EndIf
				If aHead[i] = "Total" .And. !Empty(aRow[i])
					oExcel:AddRow("provfdt", cTableName, aRow)
					nTotalCalc := 0
				EndIf
			Next
		EndIf
	EndDo

Return

// Cria cabeçalho analítico
Static Function HeadAnl()
	Local aHeadFs := Array(10)
	Local aHeadDt := Array(4)
	Local aHeadAb := Array(14)
	Local aHeadFnl
	Local nI

	aHeadFs := {'830', '831', '832', '833', '834', '830', '831', '832', '833', '834'}
	aHeadDt := {'845', '846', '847', '848'}
	aHeadAb := {'830', '831', '832', '833', '834', '830', '831', '832', '833', '834', '845', '846', '847', '848'}

	If cPor = "Ferias"
		aHeadFnl := aHeadFs
	ElseIf cPor = "Decimo Terceiro"
		aHeadFnl := aHeadDt
	Else
		aHeadFnl := aHeadAb
	EndIf

	AADD(aHead, "func")
	oExcel:AddColumn("provfdt", cTableName, "Funcionário x Verba", 2, 1)

	AADD(aHead, "cc")
	oExcel:AddColumn("provfdt", cTableName, "CC", 2, 1)

	For nI := 1 To Len(aHeadFnl)
		If nI >= 6 .And. nI <= 10
			oExcel:AddColumn("provfdt", cTableName, aHeadFnl[nI] + " - Vencida", 2, 3, .T.)
		Else
			oExcel:AddColumn("provfdt", cTableName, aHeadFnl[nI], 2, 3, .T.)
		EndIf

		AADD(aHead, aHeadFnl[nI])
	Next

	AADD(aHead, "Total")
	oExcel:AddColumn("provfdt", cTableName, "Total", 2, 3, .T.)

Return

// Gera corpo de dados analítico
Static Function BodyAnl()
	Local i
	Local cTmp
	Local cRange
	Local nTotalCalc := 0
	Local lFlag1 := .T.
	Local lFlag2 := .T.
	aRow := Array(Len(aHead))

	If cPor = "Ferias"
		cRange := cFerias
	ElseIf cPor = "Decimo Terceiro"
		cRange := cDecTerc
	Else
		cRange := cAmbos
	EndIf

	cQry := "SELECT SRA.RA_MAT MAT, SRA.RA_NOME NOME, SRA.RA_CC CC, SRV.RV_COD VERBA, SRV.RV_DESC VDESC, SRT.RT_TIPPROV TIPO, SRT.RT_VALOR VALOR"
	cQry += "FROM SRA010 SRA "
	cQry += "LEFT JOIN SRT010 SRT ON SRT.RT_MAT = SRA.RA_MAT "
	cQry += "AND SRT.D_E_L_E_T_ = ' ' "
	cQry += "AND SRT.RT_DATACAL = '"+ cDataRef +"' "
	cQry += "AND SRT.RT_VERBA IN ("+ cRange +") "
	cQry += "LEFT JOIN SRV010 SRV ON SRV.RV_COD = SRT.RT_VERBA "
	cQry += "AND SRV.D_E_L_E_T_ = ' ' "
	cQry += "WHERE SRA.D_E_L_E_T_ = ' ' "
	cQry += "ORDER BY SRA.RA_CC, SRA.RA_MAT, SRV.RV_COD, SRT.RT_TIPPROV DESC"

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	cTmp := QRY->MAT

	While QRY->(!EOF())
		IncProc(ALLTRIM(QRY->MAT) + " - " + ALLTRIM(QRY->CC))
		If cTmp = QRY->MAT
			For i := 1 To Len(aHead)
				If aHead[i] = "func" .And. Empty(aRow[i])
					aRow[i] := QRY->NOME
				EndIf
				If aHead[i] = "cc" .And. Empty(aRow[i])
					aRow[i] := QRY->CC
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "2" .And. lFlag1 = .T.
					aRow[i] := QRY->VALOR
					lFlag1 := .F.
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "1" .And. lFlag2 = .T.
					aRow[i] := QRY->VALOR
					lFlag2 = .F.
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "3"
					aRow[i] := QRY->VALOR
				EndIf
			Next
			lFlag1 := .T.
			lFlag2 = .T.
			cTmp := QRY->MAT
		Else
			For i := 1 To Len(aHead)
				If Empty(aRow[i])
					aRow[i] := 0
				EndIf
				If aHead[i] != "func" .And. aHead[i] != "cc" .And. aHead[i] != "Total"
					nTotalCalc += aRow[i]
				EndIf
				If aHead[i] = "Total" .And. Empty(aRow[i])
					aRow[i] := nTotalCalc
				EndIf
				If aHead[i] = "Total" .And. !Empty(aRow[i])
					oExcel:AddRow("provfdt", cTableName, aRow)
					nTotalCalc := 0
				EndIf
			Next
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				If aHead[i] = "func" .And. Empty(aRow[i])
					aRow[i] := QRY->NOME
				EndIf
				If aHead[i] = "cc" .And. Empty(aRow[i])
					aRow[i] := QRY->CC
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "2" .And. lFlag1 = .T.
					aRow[i] := QRY->VALOR
					lFlag1 := .F.
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "1" .And. lFlag2 = .T.
					aRow[i] := QRY->VALOR
					lFlag2 = .F.
				EndIf
				If QRY->VERBA = aHead[i] .And. Empty(aRow[i]) .And. QRY->TIPO = "3"
					aRow[i] := QRY->VALOR
				EndIf
			Next
			lFlag1 := .T.
			lFlag2 = .T.
			cTmp := QRY->MAT
		EndIf
		QRY->(DbSkip())
	EndDo

Return
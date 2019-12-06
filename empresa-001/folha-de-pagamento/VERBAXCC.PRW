#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | VERBAXCC | Autor | Marcos Natã | Data | 27/09/2016 	   |
//+--------------------------------------------------------------------+
//| Descr. | Exporta relatório de verbas por centro de custo		   |
//+--------------------------------------------------------------------+
//| Uso | Departamento Pessoal / Recursos Humanos                      |
//+--------------------------------------------------------------------+

User Function VERBAXCC()
	Local oGet1
	Local oGroup1
	Local oSay1
	Local oSay2
	Local aButtons := {}
	Static oDlg
	Private dGet1 := Date()

	DEFINE MSDIALOG oDlg TITLE "Verba por Centro de Custo" FROM 000, 000  TO 210, 500 COLORS 0, 16777215 PIXEL

	@ 012, 025 GROUP oGroup1 TO 062, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 026, 034 SAY oSay1 PROMPT "Exporta relatório de verbas por centro de custo, totalizado por verbas/CC e agrupado por centro de custo em excel." SIZE 181, 025 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 025 SAY oSay2 PROMPT "Mês Ref.:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 077, 025 MSGET oGet1 VAR dGet1 SIZE 039, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| ProcExport()} , {|| oDlg:End()},, aButtons)

Return

// Seleciona local para exportação
Static Function ProcExport()
	Local cDataRec := DTOC(dGet1)
	Private cDataRef := SUBSTR(cDataRec, 7, 4) + SUBSTR(cDataRec, 4, 2)
	Private targetDir := "C:\Windows\Temp\"

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

	oExcel:AddworkSheet("verbaxcc")
	oExcel:AddTable("verbaxcc", "Verba por CC")

	HeadEx()
	BodyEx()

	oExcel:Activate()
	oExcel:GetXMLFile(targetDir + "verbaxcc"+cDataRef+".xls")
	oExcelApp:WorkBooks:Open(targetDir + "verbaxcc"+cDataRef+".xls")
	oExcelApp:SetVisible(.T.)

Return

// Cria cabeçalho
Static Function HeadEx()
	cQry := "SELECT RD_CC CC, COUNT(RD_CC) FUNC FROM SRD010 "
	cQry += "WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND RD_DATARQ = '"+ cDataRef +"' "
	cQry += "GROUP BY RD_CC "
	cQry += "ORDER BY RD_CC "

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	AADD(aHead, "Verba")
	oExcel:AddColumn("verbaxcc", "Verba por CC", "Verba x CC", 2, 1)
	
	AADD(aHead, "Desc")
	oExcel:AddColumn("verbaxcc", "Verba por CC", "Descrição", 2, 1)

	While QRY->(!EOF())
		oExcel:AddColumn("verbaxcc", "Verba por CC", QRY->CC, 2, 3, .T.)
		AADD(aHead, QRY->CC)
		QRY->(DbSkip())
	EndDo

	AADD(aHead, "Total")
	oExcel:AddColumn("verbaxcc", "Verba por CC", "Total", 2, 3, .T.)

Return

// Gera corpo de dados
Static Function BodyEx()
	Local i
	Local cTmp
	aRow := Array(Len(aHead))

	cQry := "SELECT SRV.RV_COD VERBA, SRV.RV_DESC DES, SRD.RD_CC CC, SUM(SRD.RD_VALOR) TOTAL FROM SRV010 SRV "
	cQry += "LEFT JOIN SRD010 SRD ON SRV.RV_COD = SRD.RD_PD "
	cQry += "AND SRD.D_E_L_E_T_ = ' ' "
	cQry += "AND SRD.RD_DATARQ = '"+ cDataRef +"' "
	cQry += "WHERE SRV.D_E_L_E_T_ = ' ' "
	cQry += "GROUP BY ROLLUP(SRV.RV_COD, SRV.RV_DESC, SRD.RD_CC) "
	cQry += "HAVING SUM(SRD.RD_VALOR) > 0 "
	cQry += "ORDER BY SRV.RV_COD "

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
				If Empty(QRY->CC) .And. (aHead[i] = "Total") .And. !Empty(QRY->TOTAL)
					aRow[i] := QRY->TOTAL
				EndIf
				If QRY->CC = aHead[i]
					aRow[i] := QRY->TOTAL
				EndIf
			Next
			cTmp := QRY->VERBA
		Else
			For i := 1 To Len(aHead)
				If Empty(aRow[i])
					aRow[i] := 0
				EndIf
				If aHead[i] = "Total" .And. !Empty(aRow[i])
					oExcel:AddRow("verbaxcc", "Verba por CC", aRow)
				EndIf
			Next
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				If aHead[i] = "Verba" .And. Empty(aRow[i])
					aRow[i] := QRY->VERBA
				EndIf
				If Empty(QRY->CC) .And. (aHead[i] = "Total") .And. !Empty(QRY->TOTAL)
					aRow[i] := QRY->TOTAL
				EndIf
				If QRY->CC = aHead[i]
					aRow[i] := QRY->TOTAL
				EndIf
			Next
			cTmp := QRY->VERBA
		EndIf
		QRY->(DbSkip())
	EndDo

Return
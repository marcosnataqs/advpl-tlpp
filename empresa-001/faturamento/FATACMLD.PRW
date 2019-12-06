#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | FATACMLD | Autor | Marcos Natã | Data | 05/06/2017 	   |
//+--------------------------------------------------------------------+
//| Descr. | Faturamento/preço médio das cápsulas por período.         |
//+--------------------------------------------------------------------+
//| Uso | Genix Qualicaps                                              |
//+--------------------------------------------------------------------+

User Function FATACMLD()
	Local oGet1
	Local oGroup1
	Local oSay1
	Local oSay2
	Local cTitle := "Faturamento Preço Médio"
	Local aButtons := {}
	Static oDlg
	Private dGet1 := FirstDate(MonthSub(Date(), 12))

	DEFINE MSDIALOG oDlg TITLE cTitle FROM 000, 000  TO 210, 500 COLORS 0, 16777215 PIXEL

	@ 012, 025 GROUP oGroup1 TO 052, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 026, 034 SAY oSay1 PROMPT "Informe a data inicial para cálculo do preço médio. Será calculado o período de 12 meses a partir da data inicial." SIZE 181, 025 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 025 SAY oSay2 PROMPT "Data Inicial:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 025 MSGET oGet1 VAR dGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| ProcExport()} , {|| oDlg:End()},, aButtons)

Return

// Seleciona local para exportação
Static Function ProcExport()
	Private cDataRec := DTOS(dGet1)
	Private dDataInicial := dGet1
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

	oExcel:AddworkSheet("fatacmld")
	oExcel:AddTable("fatacmld", "Faturamento de Cápsulas - Preço Médio")

	// Cabeçalho do relatório
	HeadEx()
	// Corpo do relatório
	BodyEx()

	oExcel:Activate()
	oExcel:GetXMLFile(targetDir + "fatacmld"+cDataRec+".xls")
	oExcelApp:WorkBooks:Open(targetDir + "fatacmld"+cDataRec+".xls")
	oExcelApp:SetVisible(.T.)

Return

// Cria cabeçalho
Static Function HeadEx()
	AADD(aHead, "Grupo")
	oExcel:AddColumn("fatacmld", "Faturamento de Cápsulas - Preço Médio", "Grupo", 1, 1)

	AADD(aHead, SUBSTR(DTOS(dDataInicial), 1, 6))
	oExcel:AddColumn("fatacmld", "Faturamento de Cápsulas - Preço Médio", MesExtenso(Month(dDataInicial)) + "/" + cValToChar(Year(dDataInicial)), 2, 3)

	For i := 1 To 12
		AADD(aHead, SUBSTR(DTOS(MonthSum(dDataInicial, i)), 1, 6))
		oExcel:AddColumn("fatacmld", "Faturamento de Cápsulas - Preço Médio", MesExtenso(Month(MonthSum(dDataInicial, i))) + "/" +cValToChar(Year(MonthSum(dDataInicial, i))), 2, 3)
	Next

Return

// Gera corpo de dados
Static Function BodyEx()
	Local cTmp
	Private i
	Private aMes := {'PRIMEIRO', 'SEGUNDO', 'TERCEIRO', 'QUARTO', 'QUINTO', 'SEXTO',;
	'SETIMO', 'OITAVO', 'NONO', 'DECIMO', 'DECIMOP', 'DECIMOS', 'DECIMOT'}
	aRow := Array(Len(aHead))

	cQry := "SELECT * FROM( "
	cQry += "SELECT "
	cQry += "SD2.D2_GRUPO GRUPO, "
	cQry += "SD2.D2_QUANT QUANT, "
	cQry += "SD2.D2_VALBRUT VALBRUT, "
	cQry += "SUBSTR(SD2.D2_EMISSAO, 1, 6) EMISSAO "
	cQry += "FROM SD2010 SD2 "
	cQry += "INNER JOIN SF4010 SF4 ON SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = ' ' "
	cQry += "AND SF4.F4_ESTOQUE = 'S' AND SF4.F4_DUPLIC = 'S' "
	cQry += "WHERE SD2.D_E_L_E_T_ = ' ' "
	cQry += "AND SUBSTR(SD2.D2_EMISSAO, 1, 6) >= '"+SUBSTR(cDataRec, 1, 6)+"' "
	cQry += "AND SD2.D2_GRUPO IN ('0009','1001','1002','1003','1004','1005','1006','1007','1008', "
	cQry += "'1009','1010','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010', "
	cQry += "'2011','3001','3002','3003','3004','3005','3006','3007','3008','3009','3010','3011')) "
	cQry += "PIVOT( "
	cQry += "SUM(QUANT) AS QUANT, "
	cQry += "SUM(VALBRUT) AS VALBRUT "
	cQry += "FOR EMISSAO "
	cQry += "IN ('"+SUBSTR(DTOS(dDataInicial), 1, 6)+"' AS PRIMEIRO, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 1)), 1, 6)+"' AS SEGUNDO, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 2)), 1, 6)+"' AS TERCEIRO, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 3)), 1, 6)+"' AS QUARTO, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 4)), 1, 6)+"' AS QUINTO, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 5)), 1, 6)+"' AS SEXTO, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 6)), 1, 6)+"' AS SETIMO, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 7)), 1, 6)+"' AS OITAVO, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 8)), 1, 6)+"' AS NONO, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 9)), 1, 6)+"' AS DECIMO, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 10)), 1, 6)+"' AS DECIMOP, '"+SUBSTR(DTOS(MonthSum(dDataInicial, 11)), 1, 6)+"' AS DECIMOS, "
	cQry += "'"+SUBSTR(DTOS(MonthSum(dDataInicial, 12)), 1, 6)+"' AS DECIMOT)) "
	cQry += "ORDER BY GRUPO "

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	cTmp := QRY->GRUPO

	While QRY->(!EOF())
		IncProc(ALLTRIM(QRY->GRUPO))
		If cTmp = QRY->GRUPO
			For i := 1 To Len(aHead)
				If aHead[i] = "Grupo" .And. Empty(aRow[i])
					aRow[i] := QRY->GRUPO + " - " + Posicione("SBM",1,xFilial("SBM")+QRY->GRUPO,"BM_DESC")
				EndIf
				If aHead[i] = SUBSTR(DTOS(MonthSum(dDataInicial, 0)), 1, 6) .And. Empty(aRow[i])
					aRow[i] := (&("QRY->" + &("aMes[i-1]") + "_VALBRUT")/&("QRY->" + &("aMes[i-1]") + "_QUANT"))
				EndIf
				If aHead[i] = SUBSTR(DTOS(MonthSum(dDataInicial, i-2)), 1, 6) .And. Empty(aRow[i])
					aRow[i] := (&("QRY->" + &("aMes[i-1]") + "_VALBRUT")/&("QRY->" + &("aMes[i-1]") + "_QUANT"))
				EndIf
			Next
			cTmp := QRY->GRUPO
		Else
			For i := 1 To Len(aHead)
				If Empty(aRow[i])
					aRow[i] := 0
				EndIf
			Next
			For i := 2 To Len(aHead)
				// Não imprime a linha caso não houver valor no período
				If aRow[i] != 0
					oExcel:AddRow("fatacmld", "Faturamento de Cápsulas - Preço Médio", aRow)
					EXIT
				EndIf
			Next
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				If aHead[i] = "Grupo" .And. Empty(aRow[i])
					aRow[i] := QRY->GRUPO + " - " + Posicione("SBM",1,xFilial("SBM")+QRY->GRUPO,"BM_DESC")
				EndIf
				If aHead[i] = SUBSTR(DTOS(MonthSum(dDataInicial, 0)), 1, 6) .And. Empty(aRow[i])
					aRow[i] := (&("QRY->" + &("aMes[i-1]") + "_VALBRUT")/&("QRY->" + &("aMes[i-1]") + "_QUANT"))
				EndIf
				If aHead[i] = SUBSTR(DTOS(MonthSum(dDataInicial, i-2)), 1, 6) .And. Empty(aRow[i])
					aRow[i] := (&("QRY->" + &("aMes[i-1]") + "_VALBRUT")/&("QRY->" + &("aMes[i-1]") + "_QUANT"))
				EndIf
			Next
			cTmp := QRY->GRUPO
		EndIf
		QRY->(DbSkip())
		If QRY->(EOF())
			For i := 2 To Len(aHead)
				// Não imprime a linha caso não houver valor no período
				If aRow[i] != 0
					oExcel:AddRow("fatacmld", "Faturamento de Cápsulas - Preço Médio", aRow)
					EXIT
				EndIf
			Next
		EndIf
	EndDo

Return
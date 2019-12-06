#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | ECONSOP | Autor | Marcos Natã | Data | 21/03/2017 	       |
//+--------------------------------------------------------------------+
//| Descr. | Exporta relatório para análise de consumo da O.P.         |
//|        | baseado na estrutura do protudo em produção.              |
//+--------------------------------------------------------------------+
//| Uso    | PCP, Controladoria                                        |
//+--------------------------------------------------------------------+

User Function ECONSOP()
	Private oGet1
	Private cGet1 := Space(11)
	Private oGroup1
	Private oSay1
	Private oSay2
	Private aButtons := {}
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Paramentros" FROM 000, 000  TO 210, 500 COLORS 0, 16777215 PIXEL

	@ 012, 025 GROUP oGroup1 TO 052, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 026, 034 SAY oSay1 PROMPT "Informe a Ordem de Produção que deseja analisar. Obs.: A O.P. deve ter apontamentos." SIZE 181, 025 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 025 SAY oSay2 PROMPT "Ordem de Produção:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 025 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "SC2" PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End(), ProcExport()} , {|| oDlg:End()},, aButtons)

Return

// Configura exportação
Static Function ProcExport()
	Private cTargetDir := "C:\Windows\Temp\"
	Private cTableName := "Consumo de Ordem de Produção"

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
	Private nSemAptos := 0

	oExcel:AddworkSheet("ECONSOP")
	oExcel:AddTable("ECONSOP", cTableName)

	// Estrutura da exportação para excel
	Head()
	Body()

	If nSemAptos = 0
		oExcel:Activate()
		oExcel:GetXMLFile(cTargetDir + "ECONSOP" + cValToChar(cGet1) +".xls")
		oExcelApp:WorkBooks:Open(cTargetDir + "ECONSOP" + cValToChar(cGet1) +".xls")
		oExcelApp:SetVisible(.T.)
	EndIf

Return

// Cria cabeçalho
Static Function Head()
	Local i

	Aadd(aHead, "COMPONENTE")
	Aadd(aHead, "COMP_DESC")
	Aadd(aHead, "UN_ESTRUTURA")
	Aadd(aHead, "QTD_ESTRUTURA")
	Aadd(aHead, "CALCULO")
	Aadd(aHead, "CONSUMO")
	Aadd(aHead, "CONS_DESC")
	Aadd(aHead, "UN")
	Aadd(aHead, "QTD_CONSUMIDA")
	Aadd(aHead, "PERC. DIFERENÇA")

	For i := 1 To Len(aHead)
		oExcel:AddColumn("ECONSOP", cTableName, aHead[i], 2, 1)
	Next

Return

// Gera corpo de dados
Static Function Body()
	Private i
	Private j
	Private aStrut := {}
	aRow := Array(Len(aHead))

	cQry1 := "SELECT SD3.D3_OP OP, SD3.D3_COD PRODUTO, SB1.B1_DESC PROD_DESC, SUM(SD3.D3_QUANT) QTD_PRODUZIDA, "
	cQry1 += "(SUBSTRB(SC2.C2_DATRF, 7,2) || '/' || SUBSTRB(SC2.C2_DATRF, 5,2) || '/' || SUBSTRB(SC2.C2_DATRF, 1,4)) ENCERRAMENTO FROM SD3010 SD3 "
	cQry1 += "INNER JOIN SC2010 SC2 ON (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN) = SD3.D3_OP AND SC2.D_E_L_E_T_ = ' ' "
	cQry1 += "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQry1 += "WHERE SD3.D_E_L_E_T_ = ' ' "
	cQry1 += "AND SD3.D3_CF = 'PR0' "
	cQry1 += "AND SD3.D3_OP = '"+cValToChar(cGet1)+"' "
	cQry1 += "AND SD3.D3_ESTORNO = ' ' "
	cQry1 += "GROUP BY SD3.D3_OP, SD3.D3_COD, SC2.C2_DATRF, SB1.B1_DESC "

	cQry1 := ChangeQuery(cQry1)
	If Select("QRY1") > 0
		QRY1->(dbCloseArea())
	EndIf

	TCQUERY cQry1 NEW ALIAS "QRY1"

	If Empty(QRY1->PRODUTO)
		Alert("Ordem de Produção sem apontamentos.")
		nSemAptos := 1
		Return
	EndIf

	cQry2 := "SELECT SG1.G1_COD, SG1.G1_COMP COMPONENTE, SB11.B1_DESC COMP_DESC, SG1.G1_XUN UN_ESTRUTURA, SG1.G1_QUANT QTD_ESTRUTURA, SB1.B1_QB QTD_BASE, "
	cQry2 += "(SG1.G1_QUANT * ("+cValToChar(QRY1->QTD_PRODUZIDA)+" / (CASE WHEN SB1.B1_QB > 0  THEN SB1.B1_QB ELSE 1 END))) CALCULO "
	cQry2 += "FROM SG1010 SG1 "
	cQry2 += "LEFT JOIN SB1010 SB1 ON SB1.B1_COD = SG1.G1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQry2 += "INNER JOIN SB1010 SB11 ON SB11.B1_COD = SG1.G1_COMP AND SB11.D_E_L_E_T_ = ' ' "
	cQry2 += "WHERE SG1.D_E_L_E_T_ = ' ' "
	cQry2 += "AND SG1.G1_COD = '"+QRY1->PRODUTO+"' "
	cQry2 += "ORDER BY SG1.G1_COD, SG1.G1_COMP "

	cQry2 := ChangeQuery(cQry2)
	If Select("QRY2") > 0
		QRY2->(dbCloseArea())
	EndIf

	TCQUERY cQry2 NEW ALIAS "QRY2"

	cQry3 := "SELECT SD3.D3_OP, SD3.D3_COD CONSUMO, SB1.B1_DESC CONS_DESC, SD3.D3_UM UN, SUM(SD3.D3_QUANT) QTD_CONSUMIDA FROM SD3010 SD3 "
	cQry3 += "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQry3 += "WHERE SD3.D_E_L_E_T_ = ' ' "
	cQry3 += "AND SD3.D3_CF != 'PR0' "
	cQry3 += "AND SD3.D3_OP = '"+cValToChar(cGet1)+"' "
	cQry3 += "AND SD3.D3_ESTORNO = ' ' "
	cQry3 += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_UM, SB1.B1_DESC "
	cQry3 += "ORDER BY SD3.D3_OP, SD3.D3_COD "

	cQry3 := ChangeQuery(cQry3)
	If Select("QRY3") > 0
		QRY3->(dbCloseArea())
	EndIf

	TCQUERY cQry3 NEW ALIAS "QRY3"

	While QRY2->(!EOF())
		Aadd(aStrut, {QRY2->COMPONENTE, QRY2->CALCULO})
		QRY2->(DbSkip())
	EndDo

	QRY2->(DbGoTop())

	ProcRegua(QRY3->(RecCount()))

	aRow := {"O.P.:", QRY1->OP, "ENCERRAMENTO:", QRY1->ENCERRAMENTO, "QTD. BASE:", AllTrim(cValToChar(QRY2->QTD_BASE)),;
	"PRODUTO:", AllTrim(QRY1->PRODUTO), "QTD:", QRY1->QTD_PRODUZIDA}

	oExcel:AddRow("ECONSOP", cTableName, aRow)
	aRow := Array(Len(aHead))

	While QRY3->(!EOF()) .Or. QRY2->(!EOF())
		IncProc(QRY3->CONSUMO)

		If QRY2->(!EOF())
			For i := 1 To 5
				If Empty(aRow[i])
					aRow[i] := &("QRY2->"+aHead[i])
				EndIf
			Next
		EndIf

		If QRY3->(!EOF())
			For i := 6 To 10
				If Empty(aRow[i]) .And. i != 10
					aRow[i] := &("QRY3->"+aHead[i])
				EndIf
				If i = 10
					For j := 1 To Len(aStrut)
						If QRY3->CONSUMO = aStrut[j][1]
							aRow[i] := Transform(((QRY3->QTD_CONSUMIDA - aStrut[j][2]) / aStrut[j][2]) * 100, "@E 99999.99 %")
						EndIf
					Next
				EndIf
			Next
		EndIf

		QRY2->(DbSkip())
		QRY3->(DbSkip())
		oExcel:AddRow("ECONSOP", cTableName, aRow)
		aRow := Array(Len(aHead))
	EndDo

Return
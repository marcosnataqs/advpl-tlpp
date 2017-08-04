#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} LIBDIA

Exporta relatório excel para visualização diária de cápsulas liberadas.

@author Marcos Natã Santos
@since 27/03/2017
@version undefined

@type function
/*/

User Function LIBDIA()
	Private oGet1
	Private dGet1 := Date()
	Private oGroup1
	Private oSay1
	Private oSay2
	Private aButtons := {}
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Parâmetros" FROM 000, 000  TO 210, 500 COLORS 0, 16777215 PIXEL

	@ 012, 025 GROUP oGroup1 TO 052, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 026, 034 SAY oSay1 PROMPT "Informe a data referência que deseja visualizar as liberações." SIZE 181, 025 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 025 SAY oSay2 PROMPT "Data ref.:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 025 MSGET oGet1 VAR dGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End(), ProcExport()} , {|| oDlg:End()},, aButtons)

Return

// Configura exportação
Static Function ProcExport()
	Private cDataRec := DTOC(dGet1)
	Private cDataRef := SUBSTR(cDataRec, 7, 4) + SUBSTR(cDataRec, 4, 2) + SUBSTR(cDataRec, 1, 2)
	Private cTargetDir := "C:\Windows\Temp\"
	Private cTableName := "Cápsulas Liberadas " + cDataRec

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
	Private aRow1 := {}
	Private aRow2 := {}
	Private nTotal1
	Private nTotal2
	Private nTotal3

	oExcel:AddworkSheet("LIBDIA")
	oExcel:AddTable("LIBDIA", cTableName)

	// Estrutura da exportação para excel
	Head()
	Body()

	oExcel:Activate()
	oExcel:GetXMLFile(cTargetDir + "LIBDIA"+cDataRef+".xls")
	oExcelApp:WorkBooks:Open(cTargetDir + "LIBDIA"+cDataRef+".xls")
	oExcelApp:SetVisible(.T.)

Return

// Cria cabeçalho
Static Function Head()

	cQry :=  "SELECT BM_TAMANHO FROM SBM010 "
	cQry +=  "WHERE D_E_L_E_T_ = ' ' "
	cQry +=  "AND BM_GRUPO >= '3000' "
	cQry +=  "AND BM_GRUPO <= '3011' "
	cQry +=  "ORDER BY BM_TAMANHO "

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	Aadd(aHead, "TAMANHO:")
	oExcel:AddColumn("LIBDIA", cTableName, aHead[1], 1, 1)

	While QRY->(!EOF())
		oExcel:AddColumn("LIBDIA", cTableName, AllTrim(QRY->BM_TAMANHO), 2, 1)
		Aadd(aHead, AllTrim(QRY->BM_TAMANHO))
		QRY->(DbSkip())
	EndDo

	Aadd(aHead, "TOTAL")
	oExcel:AddColumn("LIBDIA", cTableName, "TOTAL", 2, 1)

Return

// Gera corpo de dados
Static Function Body()
	Private i
	aRow := Array(Len(aHead))
	aRow1 := Array(Len(aHead))
	aRow2 := Array(Len(aHead))

	cQry :=  "SELECT SBM.BM_TAMANHO TAM, SB1.B1_TIPOINT TIPO, SUM(SD7.D7_QTDE) QTD "
	cQry +=  "FROM SD7010 SD7 "
	cQry +=  "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SD7.D7_PRODUTO "
	cQry +=  "INNER JOIN SBM010 SBM ON SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQry +=  "WHERE SD7.D_E_L_E_T_ = ' ' "
	cQry +=  "AND SD7.D7_PRODUTO >= '1001000' "
	cQry +=  "AND SD7.D7_PRODUTO <= '3011999' "
	cQry +=  "AND SD7.D7_TIPO = '1' "
	cQry +=  "AND SD7.D7_DATA = '"+cDataRef+"' "
	cQry +=  "AND SD7.D7_ESTORNO = ' ' "
	cQry +=  "AND SD7.D7_LIBERA = 'S' "
	cQry +=  "GROUP BY SBM.BM_TAMANHO, SB1.B1_TIPOINT, SD7.D7_DATA "
	cQry +=  "ORDER BY SBM.BM_TAMANHO, SB1.B1_TIPOINT "

	cQry := ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	aRow[1] := "AMBOS:"
	aRow1[1] := "BRUTO:"
	aRow2[1] := "FRACIONADO:"

	While QRY->(!EOF())
		IncProc(QRY->TAM)

		For i := 2 To (Len(aHead)-1)
			If Empty(aRow1[i]) .And. aHead[i] == AllTrim(QRY->TAM) .And. AllTrim(QRY->TIPO) == 'B'
				aRow1[i] := QRY->QTD
				nTotal1 := somastr(cValToChar(nTotal1), cValToChar(QRY->QTD))
			ElseIf Empty(aRow1[i])
				aRow1[i] := 0
			EndIf
		Next
		For i := 2 To (Len(aHead)-1)
			If Empty(aRow2[i]) .And. aHead[i] == AllTrim(QRY->TAM) .And. AllTrim(QRY->TIPO) == 'F'
				aRow2[i] := QRY->QTD
				nTotal2 := somastr(cValToChar(nTotal2), cValToChar(QRY->QTD))
			ElseIf Empty(aRow2[i])
				aRow2[i] := 0
			EndIf
		Next

		QRY->(DbSkip())
	EndDo

	For i := 2 To (Len(aHead)-1)
		aRow[i] := somastr(cValToChar(aRow1[i]), cValToChar(aRow2[i]))
		nTotal3 := somastr(cValToChar(nTotal3), cValToChar(aRow[i]))
	Next

	aRow[Len(aHead)] := nTotal3
	aRow1[Len(aHead)] := nTotal1
	aRow2[Len(aHead)] := nTotal2

	oExcel:AddRow("LIBDIA", cTableName, aRow1)
	aRow1 := Array(Len(aHead))
	oExcel:AddRow("LIBDIA", cTableName, aRow2)
	aRow2 := Array(Len(aHead))
	oExcel:AddRow("LIBDIA", cTableName, aRow)
	aRow := Array(Len(aHead))

Return
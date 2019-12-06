#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} VIT101

Relatório para auxiliar na derrubada de materiais
para separação no Evolutio

@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
User Function VIT101() //U_VIT101()
	nOrdem  	:=	""
	Tamanho 	:=	"G"
	Limite  	:=	220
	Titulo  	:=	"DERRUBADA OPS"
	cDesc1  	:=	"Este programa ira emitir uma planilha contendo uma lista"
	cDesc2  	:=	"de produtos que precisam ser derrubados para atender"
	cDesc3  	:=	" a Ordem de Produção."
	cString 	:=	"SB2"
	aReturn 	:=	{"Zebrado",1,"Administracao",1,2,1,"",1}
	nomeProg	:=	"VIT094"
	cSeconds	:= 	SUBSTR(cValToChar(Seconds()),1,5)
	wnrel		:=  "DERRUBADA" + cSeconds + AllTrim(cUserName)
	aLinha  	:=	{}
	aOrdem  	:=	{}
	nLastkey	:=	0
	cCancel 	:= 	"***** CANCELADO PELO OPERADOR *****"
	cBcont  	:=	0
	m_pag   	:=	1
	li      	:=	80
	cBtxt   	:=	Space(10)
	lContinua	:=	.T.

	cPerg := "PERGVIT101"
	PergSX1()
	Pergunte(cPerg, .F.)

	wnrel	:=	SetPrint(cString, wnrel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., "", .T., Tamanho, "", .F.)

	If nLastKey == 27
		Set Filter To
		Return
	EndIf

	SetDefault(aReturn, cString)

	nTipo	:=	if(aReturn[4] == 1, 15, 18)
	nOrdem	:=	aReturn[8]

	If nLastKey == 27
		Set Filter To
		Return
	EndIf

	// Processa relatório
	ProcExport()
Return

/*/{Protheus.doc} ProcExport
Configuração
@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
Static Function ProcExport()
	Private cTargetDir := "C:\Windows\Temp\"
	Private cTable := "DERRUBADA OPS"
	Private cWorkSheet := "DERRUBADA"

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")
Return

/*/{Protheus.doc} RunExport
Estrutra do relatório
@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
Static Function RunExport()
	Private oExcel := FWMsExcel():New()
	Private oExcelApp := MsExcel():New()
	Private aHead := {}
	Private aRow := {}

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet, cTable)

	// Estrutura da exportação para excel
	Head()
	Body()

	oExcel:Activate()
	oExcel:GetXMLFile(cTargetDir + cWorkSheet + cSeconds + AllTrim(cUserName) + ".xls")
	oExcelApp:WorkBooks:Open(cTargetDir + cWorkSheet + cSeconds + AllTrim(cUserName) + ".xls")
	oExcelApp:SetVisible(.T.)
Return

/*/{Protheus.doc} Head
Cabeçalho do relatório
@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
Static Function Head()
	Local i

	Aadd(aHead, "OP")
	Aadd(aHead, "PA")
	Aadd(aHead, "COD")
	Aadd(aHead, "COMPONENTE")
	Aadd(aHead, "REQUERIDO")
	Aadd(aHead, "ENDERECO")
	Aadd(aHead, "LOTE")
	Aadd(aHead, "ARMAZEM")
	Aadd(aHead, "QTD")
	Aadd(aHead, "DTVALID")

	For i := 1 To Len(aHead)
		If aHead[i] == "DTVALID"
			oExcel:AddColumn(cWorkSheet, cTable, aHead[i], 2, 4)
		ElseIf aHead[i] $ "REQUERIDO/QTD"
			oExcel:AddColumn(cWorkSheet, cTable, aHead[i], 2, 2)
		Else
			oExcel:AddColumn(cWorkSheet, cTable, aHead[i], 2, 1)
		EndIf
	Next
Return

/*/{Protheus.doc} Body
Corpo do relatório
@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
Static Function Body()
	Local i
	Local cProduto := ""
	aRow := Array(Len(aHead))

	cQry :=  "SELECT "
	cQry +=  "  (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN) OP, "
	cQry +=  "  SG1.G1_COD                                   PA, "
	cQry +=  "  SG1.G1_COMP                                  COD, "
	cQry +=  "  SB1.B1_DESC                                  COMPONENTE, "
	cQry +=  "  SUM(SG1.G1_QUANT)                            REQUERIDO, "
	cQry +=  "  SBF.BF_LOCALIZ                               ENDERECO, "
	cQry +=  "  SBF.BF_LOTECTL                               LOTE, "
	cQry +=  "  SBF.BF_LOCAL                                 ARMAZEM, "
	cQry +=  "  (SBF.BF_QUANT - SBF.BF_EMPENHO)              QTD, "
	cQry +=  "  SB8.B8_DTVALID                               DTVALID "
	cQry +=  "FROM " + RetSqlName("SC2") + " SC2 "
	cQry +=  "  INNER JOIN SG1010 SG1 "
	cQry +=  "    ON SG1.D_E_L_E_T_ <> '*' "
	cQry +=  "       AND SG1.G1_FILIAL = '" + xFilial("SG1") + "' "
	cQry +=  "       AND SG1.G1_COD = SC2.C2_PRODUTO "
	cQry +=  "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQry +=  "    ON SB1.D_E_L_E_T_ <> '*' "
	cQry +=  "       AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQry +=  "       AND SB1.B1_COD = SG1.G1_COMP "
	cQry +=  "  INNER JOIN " + RetSqlName("SBF") + " SBF "
	cQry +=  "    ON SBF.D_E_L_E_T_ <> '*' "
	cQry +=  "       AND SBF.BF_FILIAL = '" + xFilial("SBF") + "' "
	cQry +=  "       AND SBF.BF_PRODUTO = SG1.G1_COMP "
	cQry +=  "       AND SBF.BF_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQry +=  "       AND SBF.BF_LOCALIZ NOT IN ('02PESAGEM','CRD126','CRD123') "
	cQry +=  "		 AND (SBF.BF_QUANT - SBF.BF_EMPENHO) > 0 "
	cQry +=  "  INNER JOIN " + RetSqlName("SB8") + " SB8 "
	cQry +=  "    ON SB8.D_E_L_E_T_ <> '*' "
	cQry +=  "       AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' "
	cQry +=  "       AND SB8.B8_PRODUTO = SBF.BF_PRODUTO "
	cQry +=  "       AND SB8.B8_LOTECTL = SBF.BF_LOTECTL "
	cQry +=  "       AND SB8.B8_LOCAL = SBF.BF_LOCAL "
	cQry +=  "WHERE SC2.D_E_L_E_T_ <> '*' "
	cQry +=  "      AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQry +=  "      AND SC2.C2_DATRF = ' ' "
	cQry +=  "      AND SC2.C2_EMISSAO >= '" + GetMV("MV_XSC2COP") + "' "
	cQry +=  "      AND (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN) "
	cQry +=  "      BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQry +=  "GROUP BY SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SG1.G1_COMP, SB1.B1_DESC, "
	cQry +=  "  SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_LOTECTL, SBF.BF_QUANT, SB8.B8_DTVALID, "
	cQry +=  "  SBF.BF_EMPENHO, SG1.G1_COD "
	cQry +=  "ORDER BY SC2.C2_NUM, SG1.G1_COMP, SB8.B8_DTVALID "
	cQry := ChangeQuery(cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	QRY->(DbGoTop())
	While QRY->(!EOF())
		IncProc(QRY->COD)
		For i := 1 To Len(aHead)
			If cProduto == QRY->COD .And. aHead[i] $ "OP/PA/COD/COMPONENTE/REQUERIDO"
				aRow[i] := ""
			ElseIf aHead[i] == "DTVALID"
				aRow[i] := DToC(SToD(QRY->&(aHead[i])))
			ElseIf aHead[i] == "PA"
				aRow[i] := AllTrim(Posicione("SB1",1,xFilial("SB1")+QRY->&(aHead[i]),"B1_DESC"))
			Else
				aRow[i] := IIF(aHead[i] $ "REQUERIDO/QTD", QRY->&(aHead[i]), AllTrim(QRY->&(aHead[i])))
			EndIf
		Next
		cProduto := QRY->COD
		oExcel:AddRow(cWorkSheet, cTable, aRow)
		aRow := Array(Len(aHead))
		QRY->(DbSkip())
		If cProduto <> QRY->COD
			oExcel:AddRow(cWorkSheet, cTable, Array(Len(aHead)))
		EndIf
	EndDo
	QRY->(dbCloseArea())
Return

/*/{Protheus.doc} PergSX1
@author marcos.santos
@since 20/02/2018
@version 1.0

@type function
/*/
Static Function PergSX1()
	aGrpSX1:={}
	aAdd(aGrpSX1,{cPerg,"01","De O.P.?", "MV_CH1","C",11,0,0,"G",Space(60),"MV_PAR01" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"SC2"})
	aAdd(aGrpSX1,{cPerg,"02","Ate O.P.?", "MV_CH2","C",11,0,0,"G",Space(60),"MV_PAR02" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"SC2"})
	aAdd(aGrpSX1,{cPerg,"03","De local?", "MV_CH3","C",02,0,0,"G",Space(60),"MV_PAR03" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"  "})
	aAdd(aGrpSX1,{cPerg,"04","Ate local?", "MV_CH4","C",02,0,0,"G",Space(60),"MV_PAR04" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"  "})

	For i := 1 To Len(aGrpSX1)
		If ! SX1->(dbSeek(aGrpSX1[i,1]+aGrpSX1[i,2]))
			SX1->(RecLock("SX1",.T.))
			SX1->X1_GRUPO  := aGrpSX1[i,01]
			SX1->X1_ORDEM  := aGrpSX1[i,02]
			SX1->X1_PERGUNT:= aGrpSX1[i,03]
			SX1->X1_VARIAVL:= aGrpSX1[i,04]
			SX1->X1_TIPO   := aGrpSX1[i,05]
			SX1->X1_TAMANHO:= aGrpSX1[i,06]
			SX1->X1_DECIMAL:= aGrpSX1[i,07]
			SX1->X1_PRESEL := aGrpSX1[i,08]
			SX1->X1_GSC    := aGrpSX1[i,09]
			SX1->X1_VALID  := aGrpSX1[i,10]
			SX1->X1_VAR01  := aGrpSX1[i,11]
			SX1->X1_DEF01  := aGrpSX1[i,12]
			SX1->X1_CNT01  := aGrpSX1[i,13]
			SX1->X1_VAR02  := aGrpSX1[i,14]
			SX1->X1_DEF02  := aGrpSX1[i,15]
			SX1->X1_CNT02  := aGrpSX1[i,16]
			SX1->X1_VAR03  := aGrpSX1[i,17]
			SX1->X1_DEF03  := aGrpSX1[i,18]
			SX1->X1_CNT03  := aGrpSX1[i,19]
			SX1->X1_VAR04  := aGrpSX1[i,20]
			SX1->X1_DEF04  := aGrpSX1[i,21]
			SX1->X1_CNT04  := aGrpSX1[i,22]
			SX1->X1_VAR05  := aGrpSX1[i,23]
			SX1->X1_DEF05  := aGrpSX1[i,24]
			SX1->X1_CNT05  := aGrpSX1[i,25]
			SX1->X1_F3     := aGrpSX1[i,26]
			SX1->(MsUnlock())
		EndIf
	Next
Return
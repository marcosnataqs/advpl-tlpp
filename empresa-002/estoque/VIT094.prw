#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} VIT094

Relat�rio de Saldos Avaliando Pesagem

@author marcos.santos
@since 06/02/2018
@version 1.0

@type function
/*/
User Function VIT094() //U_VIT094()
	nOrdem  	:=	""
	Tamanho 	:=	"G"
	Limite  	:=	220
	Titulo  	:=	"CONTROLE DE SALDOS"
	cDesc1  	:=	"Este programa ira emitir uma planilha contendo uma lista"
	cDesc2  	:=	"de produtos por armazem."
	cDesc3  	:=	" "
	cString 	:=	"SB2"
	aReturn 	:=	{"Zebrado",1,"Administracao",1,2,1,"",1}
	nomeProg	:=	"VIT094"
	cSeconds	:= 	cValToChar(Seconds())
	wnrel		:=  "SALDOS" + cSeconds + AllTrim(cUserName)
	aLinha  	:=	{}
	aOrdem  	:=	{}
	nLastkey	:=	0
	cCancel 	:= 	"***** CANCELADO PELO OPERADOR *****"
	cBcont  	:=	0
	m_pag   	:=	1
	li      	:=	80
	cBtxt   	:=	Space(10)
	lContinua	:=	.T.

	cPerg := "PERGVIT094"
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

	// Processa relat�rio
	ProcExport()
Return

/*/{Protheus.doc} ProcExport
Configura��o
@author marcos.santos
@since 08/02/2018
@version 1.0

@type function
/*/
Static Function ProcExport()
	Private cTargetDir := "C:\Windows\Temp\"
	Private cTable := "CONTROLE DE SALDOS"
	Private cWorkSheet := "SALDOS"

	If !ApOleClient('MsExcel')
		MsgAlert("� necess�rio instalar o excel antes de exportar este relat�rio.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")
Return

/*/{Protheus.doc} RunExport
Estrutra do relat�rio
@author marcos.santos
@since 08/02/2018
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

	// Estrutura da exporta��o para excel
	Head()
	Body()

	oExcel:Activate()
	oExcel:GetXMLFile(cTargetDir + cWorkSheet + cSeconds + AllTrim(cUserName) + ".xls")
	oExcelApp:WorkBooks:Open(cTargetDir + cWorkSheet + cSeconds + AllTrim(cUserName) + ".xls")
	oExcelApp:SetVisible(.T.)
Return

/*/{Protheus.doc} Head
Cabe�alho do relat�rio
@author marcos.santos
@since 08/02/2018
@version 1.0

@type function
/*/
Static Function Head()
	Local i

	Aadd(aHead, "PRODUTO")
	Aadd(aHead, "DESCRICAO")
	Aadd(aHead, "LOCAL")
	Aadd(aHead, "UN")
	Aadd(aHead, "SALDO")
	Aadd(aHead, "ENDERECAR")
	Aadd(aHead, "ENDERECADO")
	Aadd(aHead, "EMPENHO")
	Aadd(aHead, "WMS")
	Aadd(aHead, "DISPONIVEL")

	For i := 1 To Len(aHead)
		If aHead[i] == "DESCRICAO"
			oExcel:AddColumn(cWorkSheet, cTable, aHead[i], 1, 1)
		Else
			oExcel:AddColumn(cWorkSheet, cTable, aHead[i], 2, 2)
		EndIf
	Next
Return

/*/{Protheus.doc} Body
Corpo do relat�rio
@author marcos.santos
@since 08/02/2018
@version 1.0

@type function
/*/
Static Function Body()
	Local i
	Local nQ := 0
	aRow := Array(Len(aHead))

	cQry :=  "SELECT "
	cQry +=  "  SB2.B2_COD                                      PRODUTO, "
	cQry +=  "  SB1.B1_DESC                                     DESCRICAO, "
	cQry +=  "  SB2.B2_LOCAL                                    LOCAL, "
	cQry +=  "  SB1.B1_UM                                       UN, "
	cQry +=  "  SB2.B2_QATU                                     SALDO, "
	cQry +=  "  SB2.B2_QACLASS                                  ENDERECAR, "
	cQry +=  "  (SB2.B2_QATU - SB2.B2_QACLASS)                  ENDERECADO, "
	cQry +=  "  SB2.B2_QEMP                                     EMPENHO, "
	cQry +=  "  SB2.B2_XEMPWMS                                  WMS, "
	cQry +=  "  (SB2.B2_QATU - SB2.B2_QEMP - SB2.B2_XEMPWMS)	DISPONIVEL "
	cQry +=  "FROM " + RetSqlName("SB2") + " SB2 "
	cQry +=  "  INNER JOIN SB1010 SB1 "
	cQry +=  "    ON SB1.D_E_L_E_T_ <> '*' "
	cQry +=  "       AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQry +=  "       AND SB1.B1_COD = SB2.B2_COD "
	cQry +=  "WHERE SB2.D_E_L_E_T_ <> '*' "
	cQry +=  "      AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
	cQry +=  "      AND SB2.B2_QATU > 0 " // Apenas produtos com saldo
	cQry +=  "      AND SB2.B2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQry +=  "      AND SB1.B1_TIPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQry +=  "      AND SB2.B2_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	cQry := ChangeQuery(cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	QRY->(DbGoTop())
	While QRY->(!EOF())
		IncProc(QRY->PRODUTO)
		If QRY->LOCAL == "98"
			nQ := Quarentena(QRY->PRODUTO)
		EndIf
		For i := 1 To Len(aHead)
			If Empty(aRow[i]) .And. aHead[i] == "ENDERECAR" .And. QRY->LOCAL == "98"
				aRow[i] := QRY->&(aHead[i]) + nQ
				Loop
			EndIf
			If Empty(aRow[i]) .And. aHead[i] == "ENDERECADO" .And. QRY->LOCAL == "98"
				aRow[i] := QRY->&(aHead[i]) - nQ
				Loop
			EndIf
			If Empty(aRow[i])
				aRow[i] := QRY->&(aHead[i])
			EndIf
		Next
		oExcel:AddRow(cWorkSheet, cTable, aRow)
		aRow := Array(Len(aHead))
		QRY->(DbSkip())
	EndDo
	QRY->(dbCloseArea())
Return

/*/{Protheus.doc} Quarentena
Retorna quantidade n�o endere�ada na quarentena
@author marcos.santos
@since 08/02/2018
@version 1.0
@param cProduto, characters, description
@type function
/*/
Static Function Quarentena(cProduto)
	Local nQuant := 0

	cQry :=  "SELECT SUM(BF_QUANT) SALDO "
	cQry +=  "FROM " + RetSqlName("SBF") + " "
	cQry +=  "WHERE D_E_L_E_T_ <> '*' "
	cQry +=  "      AND BF_FILIAL = '" + xFilial("SBF") + "' "
	cQry +=  "      AND BF_LOCAL = '98' "
	cQry +=  "      AND BF_PRODUTO = '" + cProduto + "' "
	cQry +=  "      AND BF_QUANT > 0 " // Apenas produtos com saldo
	cQry +=  "      AND BF_LOCALIZ IN "
	cQry +=  "          ('PISO','AMOST','CRD123','END01','END02','END03','END15','END18', "
	cQry +=  "				'END21','END24','QUARENTENA','QUARENTENA DESV','QUARENTENA PA') "
	cQry := ChangeQuery(cQry)

	If Select("QRY1") > 0
		QRY1->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY1"

	nQuant := QRY1->SALDO

	QRY1->(dbCloseArea())

Return IIF(nQuant = Nil, 0, nQuant)

/*/{Protheus.doc} PergSX1
@author marcos.santos
@since 06/02/2018
@version 1.0

@type function
/*/
Static Function PergSX1()
	aGrpSX1:={}
	aAdd(aGrpSX1,{cPerg,"01","Do produto?", "MV_CH1","C",15,0,0,"G",Space(60),"MV_PAR01" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"SB1"})
	aAdd(aGrpSX1,{cPerg,"02","Ate o produto?", "MV_CH2","C",15,0,0,"G",Space(60),"MV_PAR02" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"SB1"})
	aAdd(aGrpSX1,{cPerg,"03","Do tipo?", "MV_CH3","C",02,0,0,"G",Space(60),"MV_PAR03" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"02 "})
	aAdd(aGrpSX1,{cPerg,"04","Ate o tipo?", "MV_CH4","C",02,0,0,"G",Space(60),"MV_PAR04" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"02 "})
	aAdd(aGrpSX1,{cPerg,"05","Do local?", "MV_CH5","C",02,0,0,"G",Space(60),"MV_PAR05" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"   "})
	aAdd(aGrpSX1,{cPerg,"06","Ate o local?", "MV_CH6","C",02,0,0,"G",Space(60),"MV_PAR06" ,Space(15) ,Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),Space(15),Space(15),Space(30),"   "})

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
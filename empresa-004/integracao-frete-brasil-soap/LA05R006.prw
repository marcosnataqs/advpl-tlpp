#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R006

Relatório de Ocorrências Sintético

@author Marcos Natã Santos
@since 30/11/2018
@version 12.1.17
@type function
/*/
User Function LA05R006() //-- U_LA05R006()
	Local cPerg := "LA05R006"
	Private oReport

	AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
ReportDef
@author Marcos Natã Santos
@since 30/11/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef()
	Local oReport, oSectionInfo
	Local cTitulo := "OCORRÊNCIAS SINTÉTICO - " + DTOC(MV_PAR07) + " a " + DTOC(MV_PAR08)
	Local cDescricao := "Relatório de Ocorrências Sintético - Apresenta a última ocorrência da nota."

	oReport := TReport():New("LA05R006",cTitulo,"LA05R006", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

	oSectionInfo := TRSection():New(oReport, "STATUS DAS ENTREGAS - " + DTOC(MV_PAR07) + " a " + DTOC(MV_PAR08))
	oSectionInfo:SetTotalInLine(.F.)
	TRCell():New(oSectionInfo, "ZS_EMISSAO", "", RetTitle("ZS_EMISSAO"), PesqPict("SZS","ZS_EMISSAO"), TamSX3("ZS_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_NUMNF", "", RetTitle("ZS_NUMNF"), PesqPict("SZS","ZS_NUMNF"), TamSX3("ZS_NUMNF")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_SERIE", "", RetTitle("ZS_SERIE"), PesqPict("SZS","ZS_SERIE"), TamSX3("ZS_SERIE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_PEDIDO", "", RetTitle("ZS_PEDIDO"), PesqPict("SZS","ZS_PEDIDO"), TamSX3("ZS_PEDIDO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_CLILOJ", "", RetTitle("ZS_CLILOJ"), PesqPict("SZS","ZS_CLILOJ"), TamSX3("ZS_CLILOJ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_CLINOME", "", RetTitle("ZS_CLINOME"), PesqPict("SZS","ZS_CLINOME"), TamSX3("ZS_CLINOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_OCORREN", "", RetTitle("ZT_OCORREN"), PesqPict("SZT","ZT_OCORREN"), TamSX3("ZT_OCORREN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_CODIGO", "", RetTitle("ZT_CODIGO"), PesqPict("SZT","ZT_CODIGO"), TamSX3("ZT_CODIGO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_DESCRI", "", RetTitle("ZT_DESCRI"), PesqPict("SZT","ZT_DESCRI"), TamSX3("ZT_DESCRI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_OCORDAT", "", RetTitle("ZT_OCORDAT"), PesqPict("SZT","ZT_OCORDAT"), TamSX3("ZT_OCORDAT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_OCORHR", "", RetTitle("ZT_OCORHR"), PesqPict("SZT","ZT_OCORHR"), TamSX3("ZT_OCORHR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZT_TRANSRS", "", RetTitle("ZT_TRANSRS"), PesqPict("SZT","ZT_TRANSRS"), TamSX3("ZT_TRANSRS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    
Return oReport

/*/{Protheus.doc} ReportDef
PrintReport
@author Marcos Natã Santos
@since 30/11/2018
@version 12.1.17
@type function
/*/
Static Function PrintReport(oReport)
	Local oSectionInfo := oReport:Section(1)
	Local cQry         := ""
	Local cNota		   := ""
	Local aOcorrencia  := {}

	cQry := "SELECT SZS.ZS_EMISSAO, " + CRLF
	cQry += "	SZS.ZS_NUMNF, " + CRLF
	cQry += "	SZS.ZS_SERIE, " + CRLF
	cQry += "	SZS.ZS_PEDIDO, " + CRLF
	cQry += "	SZS.ZS_CLILOJ, " + CRLF
	cQry += "	SZS.ZS_CLINOME, " + CRLF
	cQry += "	SZT.ZT_OCORREN, " + CRLF
	cQry += "	SZT.ZT_CODIGO, " + CRLF
	cQry += "	SZT.ZT_DESCRI, " + CRLF
	cQry += "	SZT.ZT_OCORDAT, " + CRLF
	cQry += "	SZT.ZT_OCORHR, " + CRLF
	cQry += "	SZT.ZT_TRANSRS " + CRLF
	cQry += "FROM "+ RetSqlName("SZS") +" SZS " + CRLF
	cQry += "INNER JOIN "+ RetSqlName("SZT") +" SZT " + CRLF
	cQry += "ON SZT.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SZT.ZT_FILIAL = '"+ xFilial("SZT") +"' " + CRLF
	cQry += "AND SZT.ZT_CHAVENF = SZS.ZS_CHAVENF " + CRLF
	cQry += "WHERE SZS.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SZS.ZS_FILIAL = '"+ xFilial("SZS") +"' " + CRLF
	cQry += "AND SZS.ZS_NUMNF BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
	cQry += "AND SUBSTR(SZS.ZS_CLILOJ,1,6) BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' " + CRLF
	cQry += "AND SUBSTR(SZS.ZS_CLILOJ,7,2) BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' " + CRLF
	cQry += "AND SZS.ZS_EMISSAO BETWEEN '"+ DTOS(MV_PAR07) +"' AND '"+ DTOS(MV_PAR08) +"' " + CRLF
	cQry += "ORDER BY SZS.ZS_EMISSAO, SZS.ZS_NUMNF, SZT.ZT_OCORDAT, SZT.ZT_OCORHR " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
	oSectionInfo:Init()
	oReport:SetMeter(TMP1->(RecCount()))
	cNota := TMP1->ZS_NUMNF
	While TMP1->(!EOF())
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		//------------------------------------------------------------//
		//-- Selecionar apenas a ultima ocorrencia para nota fiscal --//
		//------------------------------------------------------------//
		If cNota <> TMP1->ZS_NUMNF
			oSectionInfo:Cell("ZS_EMISSAO"):SetValue(aOcorrencia[1])
			oSectionInfo:Cell("ZS_NUMNF"):SetValue(aOcorrencia[2])
			oSectionInfo:Cell("ZS_SERIE"):SetValue(aOcorrencia[3])
			oSectionInfo:Cell("ZS_PEDIDO"):SetValue(aOcorrencia[4])
			oSectionInfo:Cell("ZS_CLILOJ"):SetValue(aOcorrencia[5])
			oSectionInfo:Cell("ZS_CLINOME"):SetValue(aOcorrencia[6])
			oSectionInfo:Cell("ZT_OCORREN"):SetValue(aOcorrencia[7])
			oSectionInfo:Cell("ZT_CODIGO"):SetValue(aOcorrencia[8])
			oSectionInfo:Cell("ZT_DESCRI"):SetValue(aOcorrencia[9])
			oSectionInfo:Cell("ZT_OCORDAT"):SetValue(aOcorrencia[10])
			oSectionInfo:Cell("ZT_OCORHR"):SetValue(aOcorrencia[11])
			oSectionInfo:Cell("ZT_TRANSRS"):SetValue(aOcorrencia[12])
			oSectionInfo:PrintLine()
		EndIf

		cNota := TMP1->ZS_NUMNF
		aOcorrencia := {}
		AADD(aOcorrencia, STOD(TMP1->ZS_EMISSAO))
		AADD(aOcorrencia, TMP1->ZS_NUMNF)
		AADD(aOcorrencia, TMP1->ZS_SERIE)
		AADD(aOcorrencia, TMP1->ZS_PEDIDO)
		AADD(aOcorrencia, TMP1->ZS_CLILOJ)
		AADD(aOcorrencia, TMP1->ZS_CLINOME)
		AADD(aOcorrencia, TMP1->ZT_OCORREN)
		AADD(aOcorrencia, TMP1->ZT_CODIGO)
		AADD(aOcorrencia, TMP1->ZT_DESCRI)
		AADD(aOcorrencia, STOD(TMP1->ZT_OCORDAT))
		AADD(aOcorrencia, TMP1->ZT_OCORHR)
		AADD(aOcorrencia, TMP1->ZT_TRANSRS)

		TMP1->(dbSkip())
	EndDo

	If Len(aOcorrencia) > 0
		oSectionInfo:Cell("ZS_EMISSAO"):SetValue(aOcorrencia[1])
		oSectionInfo:Cell("ZS_NUMNF"):SetValue(aOcorrencia[2])
		oSectionInfo:Cell("ZS_SERIE"):SetValue(aOcorrencia[3])
		oSectionInfo:Cell("ZS_PEDIDO"):SetValue(aOcorrencia[4])
		oSectionInfo:Cell("ZS_CLILOJ"):SetValue(aOcorrencia[5])
		oSectionInfo:Cell("ZS_CLINOME"):SetValue(aOcorrencia[6])
		oSectionInfo:Cell("ZT_OCORREN"):SetValue(aOcorrencia[7])
		oSectionInfo:Cell("ZT_CODIGO"):SetValue(aOcorrencia[8])
		oSectionInfo:Cell("ZT_DESCRI"):SetValue(aOcorrencia[9])
		oSectionInfo:Cell("ZT_OCORDAT"):SetValue(aOcorrencia[10])
		oSectionInfo:Cell("ZT_OCORHR"):SetValue(aOcorrencia[11])
		oSectionInfo:Cell("ZT_TRANSRS"):SetValue(aOcorrencia[12])
		oSectionInfo:PrintLine()
	EndIf

	oSectionInfo:Finish()
    TMP1->(DbCloseArea())
	MS_FLUSH()

Return

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 30/11/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","De nota fiscal?", "MV_CH1","C",9,0,0,"G", "MV_PAR01","","","","",""})
	aAdd(aRegs,{"02","Até nota fiscal?","MV_CH2","C",9,0,0,"G", "MV_PAR02","","","","",""})
	aAdd(aRegs,{"03","De cliente?",     "MV_CH3","C",6,0,0,"G", "MV_PAR03","","","","SA1",""})
	aAdd(aRegs,{"04","Até cliente?",    "MV_CH4","C",6,0,0,"G", "MV_PAR04","","","","SA1",""})
	aAdd(aRegs,{"05","De loja?",        "MV_CH5","C",2,0,0,"G", "MV_PAR05","","","","",""})
    aAdd(aRegs,{"06","Até loja?",       "MV_CH6","C",2,0,0,"G", "MV_PAR06","","","","",""})
    aAdd(aRegs,{"07","De emissão?",     "MV_CH7","D",10,0,0,"G","MV_PAR07","","","","",""})
    aAdd(aRegs,{"08","Até emissão?",    "MV_CH8","D",10,0,0,"G","MV_PAR08","","","","",""})

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		dbSeek(cPerg+aRegs[i][1])
		If !Found()
			RecLock("SX1",!Found())
			SX1->X1_GRUPO   := cPerg
			SX1->X1_ORDEM   := aRegs[i][01]
			SX1->X1_PERGUNT := aRegs[i][02]
			SX1->X1_VARIAVL := aRegs[i][03]
			SX1->X1_TIPO    := aRegs[i][04]
			SX1->X1_TAMANHO := aRegs[i][05]
			SX1->X1_DECIMAL := aRegs[i][06]
			SX1->X1_PRESEL  := aRegs[i][07]
			SX1->X1_GSC     := aRegs[i][08]
			SX1->X1_VAR01   := aRegs[i][09]
			SX1->X1_DEF01   := aRegs[i][10]
			SX1->X1_DEF02   := aRegs[i][11]
			SX1->X1_DEF03   := aRegs[i][12]
			SX1->X1_F3      := aRegs[i][13]
			SX1->X1_VALID   := aRegs[i][14]
			MsUnlock()
		Endif
	Next

	RestArea(aArea)

Return
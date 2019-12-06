#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R005

Relatório de Ocorrências Analítico

@author Marcos Natã Santos
@since 30/11/2018
@version 12.1.17
@type function
/*/
User Function LA05R005() //-- U_LA05R005()
	Private oReport

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
	Local oReport, oSection, oSectionInfo
	Local cTitulo := "OCORRÊNCIAS ANALÍTICO"
	Local cDescricao := "Relatório de Ocorrências Analítico"

	oReport := TReport():New("LA05R005",cTitulo,"LA05R005", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage    := .F.
    oReport:lPrtParamPage := .F.

	oSectionInfo := TRSection():New(oReport, "CABEÇALHO")
	oSectionInfo:SetTotalInLine(.F.)
	TRCell():New(oSectionInfo, "ZS_NUMNF", "", RetTitle("ZS_NUMNF"), PesqPict("SZS","ZS_NUMNF"), TamSX3("ZS_NUMNF")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_SERIE", "", "Cliente", PesqPict("SZS","ZS_SERIE"), TamSX3("ZS_SERIE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_PEDIDO", "", RetTitle("ZS_PEDIDO"), PesqPict("SZS","ZS_PEDIDO"), TamSX3("ZS_PEDIDO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_CLILOJ", "", RetTitle("ZS_CLILOJ"), PesqPict("SZS","ZS_CLILOJ"), TamSX3("ZS_CLILOJ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_CLINOME", "", RetTitle("ZS_CLINOME"), PesqPict("SZS","ZS_CLINOME"), TamSX3("ZS_CLINOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_CHAVENF", "", RetTitle("ZS_CHAVENF"), PesqPict("SZS","ZS_CHAVENF"), TamSX3("ZS_CHAVENF")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_REMETEN", "", RetTitle("ZS_REMETEN"), PesqPict("SZS","ZS_REMETEN"), TamSX3("ZS_REMETEN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_RMTTRS", "", RetTitle("ZS_RMTTRS"), PesqPict("SZS","ZS_RMTTRS"), TamSX3("ZS_RMTTRS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZS_EMISSAO", "", RetTitle("ZS_EMISSAO"), PesqPict("SZS","ZS_EMISSAO"), TamSX3("ZS_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection := TRSection():New(oReport, "ITENS")
	oSection:SetTotalInLine(.F.)
	TRCell():New(oSection, "ZT_OCORREN", "", RetTitle("ZT_OCORREN"), PesqPict("SZT","ZT_OCORREN"), TamSX3("ZT_OCORREN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_OCORDAT", "", RetTitle("ZT_OCORDAT"), PesqPict("SZT","ZT_OCORDAT"), TamSX3("ZT_OCORDAT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_OCORHR", "", RetTitle("ZT_OCORHR"), PesqPict("SZT","ZT_OCORHR"), TamSX3("ZT_OCORHR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_CODIGO", "", RetTitle("ZT_CODIGO"), PesqPict("SZT","ZT_CODIGO"), TamSX3("ZT_CODIGO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_DESCRI", "", RetTitle("ZT_DESCRI"), PesqPict("SZT","ZT_DESCRI"), TamSX3("ZT_DESCRI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_TRANSPO", "", RetTitle("ZT_TRANSPO"), PesqPict("SZT","ZT_TRANSPO"), TamSX3("ZT_TRANSPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_TRANSRS", "", RetTitle("ZT_TRANSRS"), PesqPict("SZT","ZT_TRANSRS"), TamSX3("ZT_TRANSRS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_SOLUDAT", "", RetTitle("ZT_SOLUDAT"), PesqPict("SZT","ZT_SOLUDAT"), TamSX3("ZT_SOLUDAT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_SOLUHR", "", RetTitle("ZT_SOLUHR"), PesqPict("SZT","ZT_SOLUHR"), TamSX3("ZT_SOLUHR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_SOLURSP", "", RetTitle("ZT_SOLURSP"), PesqPict("SZT","ZT_SOLURSP"), 20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZT_CANCDAT", "", RetTitle("ZT_CANCDAT"), PesqPict("SZT","ZT_CANCDAT"), TamSX3("ZT_CANCDAT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    
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
	Local oSection := oReport:Section(2)
	Local cQry

	oSectionInfo:Init()

	If oReport:Cancel()
		Return
	EndIf

	oSectionInfo:Cell("ZS_NUMNF"):SetValue(SZS->ZS_NUMNF)
	oSectionInfo:Cell("ZS_SERIE"):SetValue(SZS->ZS_SERIE)
	oSectionInfo:Cell("ZS_PEDIDO"):SetValue(SZS->ZS_PEDIDO)
	oSectionInfo:Cell("ZS_CLILOJ"):SetValue(SZS->ZS_CLILOJ)
	oSectionInfo:Cell("ZS_CLINOME"):SetValue(SZS->ZS_CLINOME)
	oSectionInfo:Cell("ZS_CHAVENF"):SetValue(SZS->ZS_CHAVENF)
	oSectionInfo:Cell("ZS_REMETEN"):SetValue(SZS->ZS_REMETEN)
	oSectionInfo:Cell("ZS_RMTTRS"):SetValue(SZS->ZS_RMTTRS)
	oSectionInfo:Cell("ZS_EMISSAO"):SetValue(SZS->ZS_EMISSAO)

	oSectionInfo:PrintLine()

	cQry := "SELECT ZT_OCORREN, " + CRLF
    cQry += "    ZT_OCORDAT, " + CRLF
    cQry += "    ZT_OCORHR, " + CRLF
    cQry += "    ZT_CODIGO, " + CRLF
    cQry += "    ZT_DESCRI, " + CRLF
    cQry += "    ZT_TRANSPO, " + CRLF
    cQry += "    ZT_TRANSRS, " + CRLF
    cQry += "    ZT_SOLUDAT, " + CRLF
    cQry += "    ZT_SOLUHR, " + CRLF
    cQry += "    ZT_SOLURSP, " + CRLF
    cQry += "    ZT_CANCDAT " + CRLF
    cQry += "FROM " + RetSqlName("SZT") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZT_FILIAL = '"+ xFilial("SZT") +"' " + CRLF
    cQry += "AND ZT_CHAVENF = '"+ SZS->ZS_CHAVENF +"' " + CRLF
    cQry += "ORDER BY ZT_OCORDAT, ZT_OCORHR " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
	oSection:Init()
	oReport:SetMeter(TMP1->(RecCount()))
	While TMP1->(!EOF())
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		oSection:Cell("ZT_OCORREN"):SetValue(TMP1->ZT_OCORREN)
		oSection:Cell("ZT_OCORDAT"):SetValue(STOD(TMP1->ZT_OCORDAT))
		oSection:Cell("ZT_OCORHR"):SetValue(TMP1->ZT_OCORHR)
		oSection:Cell("ZT_CODIGO"):SetValue(TMP1->ZT_CODIGO)
		oSection:Cell("ZT_DESCRI"):SetValue(TMP1->ZT_DESCRI)
		oSection:Cell("ZT_TRANSPO"):SetValue(TMP1->ZT_TRANSPO)
		oSection:Cell("ZT_TRANSRS"):SetValue(TMP1->ZT_TRANSRS)
		oSection:Cell("ZT_SOLUDAT"):SetValue(STOD(TMP1->ZT_SOLUDAT))
		oSection:Cell("ZT_SOLUHR"):SetValue(TMP1->ZT_SOLUHR)
		oSection:Cell("ZT_SOLURSP"):SetValue(TMP1->ZT_SOLURSP)
		oSection:Cell("ZT_CANCDAT"):SetValue(STOD(TMP1->ZT_CANCDAT))

		oSection:PrintLine()

		TMP1->(dbSkip())
	EndDo

	oSection:Finish()
	oSectionInfo:Finish()

    TMP1->(DbCloseArea())
	MS_FLUSH()

Return
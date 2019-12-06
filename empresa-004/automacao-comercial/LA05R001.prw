#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R001

Relatório de Pedido de Venda Automação

@author Marcos Natã Santos
@since 28/05/2018
@version 12.1.17
@type function
/*/
User Function LA05R001()
	Private oReport

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef

ReportDef

@author Marcos Natã Santos
@since 28/05/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef()
	Local oReport, oSection, oSectionInfo
	Local cTitulo := "PEDIDO DE VENDA"
	Local cDescricao := "Relatório de Pedido de Venda Automação"

	oReport := TReport():New("LA05R001",cTitulo,"LA05R001", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage    := .F.
    oReport:lPrtParamPage := .F.

	oSectionInfo := TRSection():New(oReport, "CABEÇALHO")
	oSectionInfo:SetTotalInLine(.F.)
	TRCell():New(oSectionInfo, "ZL_NUM", "", RetTitle("ZL_NUM"), PesqPict("SZL","ZL_NUM"), TamSX3("ZL_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_NOMECLI", "", "Cliente", PesqPict("SZL","ZL_NOMECLI"), TamSX3("ZL_NOMECLI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_DESCOND", "", RetTitle("ZL_DESCOND"), PesqPict("SZL","ZL_DESCOND"), TamSX3("ZL_DESCOND")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_EMISSAO", "", RetTitle("ZL_EMISSAO"), PesqPict("SZL","ZL_EMISSAO"), TamSX3("ZL_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection := TRSection():New(oReport, "ITENS")
	oSection:SetTotalInLine(.F.)
	TRCell():New(oSection, "ZM_PRODUTO", "", RetTitle("ZM_PRODUTO"), PesqPict("SZM","ZM_PRODUTO"), TamSX3("ZM_PRODUTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_DESCRI", "", RetTitle("ZM_DESCRI"), PesqPict("SZM","ZM_DESCRI"), TamSX3("ZM_DESCRI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_QTD", "", RetTitle("ZM_QTD"), PesqPict("SZM","ZM_QTD"), TamSX3("ZM_QTD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_VALOR", "", RetTitle("ZM_VALOR"), PesqPict("SZM","ZM_VALOR"), TamSX3("ZM_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_TOTAL", "", RetTitle("ZM_TOTAL"), PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_PERDESC", "", RetTitle("ZM_PERDESC"), PesqPict("SZM","ZM_PERDESC"), TamSX3("ZM_PERDESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZM_VALDESC", "", RetTitle("ZM_VALDESC"), PesqPict("SZM","ZM_VALDESC"), TamSX3("ZM_VALDESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRFunction():New(oSection:Cell("ZM_QTD"),, "SUM",,,PesqPict("SZM","ZM_QTD"),,.F.,.T.,.F.,oSectionInfo)
	TRFunction():New(oSection:Cell("ZM_TOTAL"),, "SUM",,,PesqPict("SZM","ZM_TOTAL"),,.F.,.T.,.F.,oSectionInfo)
	TRFunction():New(oSection:Cell("ZM_VALDESC"),, "SUM",,,PesqPict("SZM","ZM_VALDESC"),,.F.,.T.,.F.,oSectionInfo)

Return oReport

/*/{Protheus.doc} ReportDef

PrintReport

@author Marcos Natã Santos
@since 28/05/2018
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

	oSectionInfo:Cell("ZL_NUM"):SetValue(SZL->ZL_NUM)
	oSectionInfo:Cell("ZL_NUM"):SetAlign("LEFT")

	oSectionInfo:Cell("ZL_NOMECLI"):SetValue(SZL->ZL_NOMECLI)
	oSectionInfo:Cell("ZL_NOMECLI"):SetAlign("LEFT")

	oSectionInfo:Cell("ZL_DESCOND"):SetValue(SZL->ZL_DESCOND)
	oSectionInfo:Cell("ZL_DESCOND"):SetAlign("LEFT")

	oSectionInfo:Cell("ZL_EMISSAO"):SetValue(SZL->ZL_EMISSAO)
	oSectionInfo:Cell("ZL_EMISSAO"):SetAlign("LEFT")
	oSectionInfo:Cell("ZL_EMISSAO"):SetSize(10)

	oSectionInfo:PrintLine()

	cQry := "SELECT ZM_PRODUTO, ZM_DESCRI, ZM_QTD, ZM_VALOR, ZM_TOTAL, ZM_PERDESC, ZM_VALDESC " + CRLF
	cQry += "FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ SZL->ZL_NUM +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ SZL->ZL_CLIENTE +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ SZL->ZL_LOJA +"' " + CRLF
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

		oSection:Cell("ZM_PRODUTO"):SetValue(TMP1->ZM_PRODUTO)
		oSection:Cell("ZM_PRODUTO"):SetAlign("LEFT")

		oSection:Cell("ZM_DESCRI"):SetValue(TMP1->ZM_DESCRI)
		oSection:Cell("ZM_DESCRI"):SetAlign("LEFT")

		oSection:Cell("ZM_QTD"):SetValue(TMP1->ZM_QTD)
		oSection:Cell("ZM_QTD"):SetAlign("CENTER")

		oSection:Cell("ZM_VALOR"):SetValue(TMP1->ZM_VALOR)
		oSection:Cell("ZM_VALOR"):SetAlign("CENTER")

		oSection:Cell("ZM_TOTAL"):SetValue(TMP1->ZM_TOTAL)
		oSection:Cell("ZM_TOTAL"):SetAlign("CENTER")

		oSection:Cell("ZM_PERDESC"):SetValue(TMP1->ZM_PERDESC)
		oSection:Cell("ZM_PERDESC"):SetAlign("CENTER")

		oSection:Cell("ZM_VALDESC"):SetValue(TMP1->ZM_VALDESC)
		oSection:Cell("ZM_VALDESC"):SetAlign("CENTER")

		oSection:PrintLine()

		TMP1->(dbSkip())
	EndDo

	oSection:Finish()
	oSectionInfo:Finish()

	MS_FLUSH()

Return
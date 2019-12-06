#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R003

Rastro analítico Pedido de Venda

@author Marcos Natã Santos
@since 29/06/2018
@version 12.1.17
@type function
/*/
User Function LA05R003()
	Private oReport

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef

ReportDef

@author Marcos Natã Santos
@since 20/06/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef()
	Local oReport, oSectionInfo, oSection1
	Local cTitulo := "RASTRO ANALÍTICO"
	Local cDescricao := "Rastro Analítico Pedido de Venda"

	oReport := TReport():New("LA05R003",cTitulo,"LA05R003", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
    oReport:lParamPage    := .F.
    oReport:lPrtParamPage := .F.

	oSectionInfo := TRSection():New(oReport, "PEDIDO DE VENDA")
	oSectionInfo:SetTotalInLine(.F.)
	TRCell():New(oSectionInfo, "ZL_NUM", "", RetTitle("ZL_NUM"), PesqPict("SZL","ZL_NUM"), TamSX3("ZL_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_NOMECLI", "", "Cliente", PesqPict("SZL","ZL_NOMECLI"), TamSX3("ZL_NOMECLI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_EMISSAO", "", RetTitle("ZL_EMISSAO"), PesqPict("SZL","ZL_EMISSAO"), TamSX3("ZL_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "TOTAL", "", "Vlr Total", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "FAT", "", "Vlr Faturado", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "AFAT", "", "Vlr a Faturar", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "CORTE", "", "Vlr Corte", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A3_NOME", "", "Vendedor", PesqPict("SA3","A3_NOME"), TamSX3("A3_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection1 := TRSection():New(oReport, "PEDIDOS CENTRO DISTRIBUICAO")
	oSection1:SetTotalInLine(.F.)
    TRCell():New(oSection1, "C5_NUM", "", "Pedido Fábrica", PesqPict("SC5","C5_NUM"), TamSX3("C5_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "PEDCD", "", "Pedido C.D.", PesqPict("SC5","C5_NUM"), TamSX3("C5_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "C5_EMISSAO", "", RetTitle("C5_EMISSAO"), PesqPict("SC5","C5_EMISSAO"), TamSX3("C5_EMISSAO")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "NOTA", "", "Nota Fiscal", PesqPict("SF2","F2_DOC"), TamSX3("F2_DOC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "TOTAL", "", "Vlr Total", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*/{Protheus.doc} ReportDef

PrintReport

@author Marcos Natã Santos
@since 29/06/2018
@version 12.1.17
@type function
/*/
Static Function PrintReport(oReport)
	Local oSectionInfo := oReport:Section(1)
	Local oSection1     := oReport:Section(2)
	Local cQry
    Local aAreaSZL     := SZL->(GetArea())
    Local cVendedor    := ""
    Local aDados       := {}
    Local nTotal       := 0
    Local nFat         := 0
    Local nCorte       := 0

    SZL->(dbSetOrder(1))
    If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )

        oSectionInfo:Init()

        If oReport:Cancel()
            Return
        EndIf

        cVendedor := AllTrim(Posicione("SA3",1,xFilial("SA3")+SZL->ZL_VEND,"A3_NOME"))
        aDados    := TotPed(SZL->ZL_NUM,SZL->ZL_CLIENTE,SZL->ZL_LOJA)
        nTotal    := aDados[1]
        nFat      := TotFat(SZL->ZL_NUM)
        nCorte    := aDados[2]

        oSectionInfo:Cell("ZL_NUM"):SetValue(SZL->ZL_NUM)
        oSectionInfo:Cell("ZL_NUM"):SetAlign("LEFT")

        oSectionInfo:Cell("ZL_NOMECLI"):SetValue(SZL->ZL_NOMECLI)
        oSectionInfo:Cell("ZL_NOMECLI"):SetAlign("LEFT")

        oSectionInfo:Cell("ZL_EMISSAO"):SetValue(SZL->ZL_EMISSAO)
        oSectionInfo:Cell("ZL_EMISSAO"):SetAlign("LEFT")
        oSectionInfo:Cell("ZL_EMISSAO"):SetSize(10)

        oSectionInfo:Cell("TOTAL"):SetValue( nTotal )
        oSectionInfo:Cell("TOTAL"):SetAlign("LEFT")

        oSectionInfo:Cell("FAT"):SetValue( nFat )
        oSectionInfo:Cell("FAT"):SetAlign("LEFT")

        oSectionInfo:Cell("AFAT"):SetValue( nTotal - nFat - nCorte )
        oSectionInfo:Cell("AFAT"):SetAlign("LEFT")

        oSectionInfo:Cell("CORTE"):SetValue( nCorte )
        oSectionInfo:Cell("CORTE"):SetAlign("LEFT")

        oSectionInfo:Cell("A3_NOME"):SetValue( cVendedor )
        oSectionInfo:Cell("A3_NOME"):SetAlign("LEFT")

        oSectionInfo:PrintLine()

        cQry := "SELECT C5_NUM, C5_EMISSAO, C5_XPVCD " + CRLF
        cQry += "FROM " + RetSqlName("SC5") + CRLF
        cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "AND C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
        cQry += "AND C5_XPEDPAI = '"+ SZL->ZL_NUM +"' " + CRLF
        cQry += "ORDER BY C5_EMISSAO " + CRLF
        cQry := ChangeQuery(cQry)

        If Select("TMP1") > 0
            TMP1->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "TMP1"

        TMP1->(dbGoTop())
        COUNT TO NQTREG
        TMP1->(dbGoTop())

        If NQTREG > 0
            oSection1:Init()
	        oReport:SetMeter(NQTREG)
            While TMP1->( !EOF() )
                If oReport:Cancel()
                    Exit
                EndIf

                oReport:IncMeter()

                oSection1:Cell("C5_NUM"):SetValue(TMP1->C5_NUM)
                oSection1:Cell("C5_NUM"):SetAlign("CENTER")

                oSection1:Cell("PEDCD"):SetValue("")
                oSection1:Cell("PEDCD"):SetAlign("CENTER")

                oSection1:Cell("C5_EMISSAO"):SetValue(DTOC(STOD(TMP1->C5_EMISSAO)))
                oSection1:Cell("C5_EMISSAO"):SetAlign("LEFT")

                oSection1:Cell("NOTA"):SetValue(BuscaNota("0102",TMP1->C5_NUM))
                oSection1:Cell("NOTA"):SetAlign("CENTER")

                oSection1:Cell("TOTAL"):SetValue( TotFat(TMP1->C5_NUM, .T.) )
                oSection1:Cell("TOTAL"):SetAlign("LEFT")

                oSection1:PrintLine()

                If !Empty(TMP1->C5_XPVCD)
                    cQry := "SELECT C5_NUM, C5_EMISSAO " + CRLF
                    cQry += "FROM " + RetSqlName("SC5") + CRLF
                    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
                    cQry += "AND C5_FILIAL = '0101' " + CRLF // Centro de Distribuição
                    cQry += "AND C5_NUM = '"+ TMP1->C5_XPVCD +"' " + CRLF
                    cQry += "ORDER BY C5_EMISSAO " + CRLF
                    cQry := ChangeQuery(cQry)

                    If Select("TMP3") > 0
                        TMP3->(DbCloseArea())
                    EndIf

                    TcQuery cQry New Alias "TMP3"

                    TMP3->(dbGoTop())
                    COUNT TO NQTREG
                    TMP3->(dbGoTop())

                    If NQTREG > 0
                        oSection1:Cell("C5_NUM"):SetValue("")
                        oSection1:Cell("C5_NUM"):SetAlign("CENTER")

                        oSection1:Cell("PEDCD"):SetValue(TMP3->C5_NUM)
                        oSection1:Cell("PEDCD"):SetAlign("CENTER")

                        oSection1:Cell("C5_EMISSAO"):SetValue(DTOC(STOD(TMP3->C5_EMISSAO)))
                        oSection1:Cell("C5_EMISSAO"):SetAlign("LEFT")

                        oSection1:Cell("NOTA"):SetValue(BuscaNota("0101",TMP3->C5_NUM))
                        oSection1:Cell("NOTA"):SetAlign("CENTER")

                        oSection1:Cell("TOTAL"):SetValue( TotFat(TMP3->C5_NUM, .T., "0101") )
                        oSection1:Cell("TOTAL"):SetAlign("LEFT")

                        oSection1:PrintLine()
                    EndIf
                EndIf

                TMP1->( dbSkip() )
            EndDo
            TMP1->(DbCloseArea())
        EndIf

        oSection1:Finish()
        oSectionInfo:Finish()

    EndIf

	MS_FLUSH()
    RestArea(aAreaSZL)

Return

/*/{Protheus.doc} TotPed

Retorna total do Pedido de Venda

@author Marcos Natã Santos
@since 29/06/2018
@version 12.1.17
@type function
/*/
Static Function TotPed(cPed,cCodCli,cLoja)
    Local cQry
    Local aRet := {0,0}

    cQry := "SELECT SUM(ZM_TOTAL) TOTAL, SUM(ZM_QTDCORT * ZM_VALOR) VLCORTE " + CRLF
    cQry += "FROM " + RetSqlName("SZM") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
    cQry += "AND ZM_NUM = '"+ cPed +"' " + CRLF
    cQry += "AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
    cQry += "AND ZM_LOJA = '"+ cLoja +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
    COUNT TO NQTREG
    TMP1->(dbGoTop())

    If NQTREG > 0
        aRet[1] += TMP1->TOTAL
        aRet[2] += TMP1->VLCORTE
    EndIf

    TMP1->(DbCloseArea())

Return aRet

/*/{Protheus.doc} TotFat

Retorna total já faturado do Pedido de Venda

@author Marcos Natã Santos
@since 29/06/2018
@version 12.1.17
@type function
/*/
Static Function TotFat(cPed,lOrig,cFil)
    Local nTotal   := 0
    Local cQry

    Default lOrig := .F.
    Default cFil  := ""

    cQry := "SELECT SUM(C6_VALOR) TOTAL " + CRLF
    cQry += "FROM " + RetSqlName("SC6") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    If !Empty(cFil)
        cQry += "AND C6_FILIAL = '"+ cFil +"' " + CRLF
    Else
        cQry += "AND C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    EndIf
    If lOrig
        cQry += "AND C6_NUM = '"+ cPed +"' " + CRLF
    Else
        cQry += "AND C6_XPEDPAI = '"+ cPed +"' " + CRLF
    EndIf
    cQry := ChangeQuery(cQry)

	If Select("TMP2") > 0
		TMP2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP2"

	TMP2->(dbGoTop())
    COUNT TO NQTREG
    TMP2->(dbGoTop())

    If NQTREG > 0
        nTotal := TMP2->TOTAL
    EndIf

    TMP2->(DbCloseArea())

Return nTotal

/*/{Protheus.doc} BuscaNota

Busca dados da nota fiscal

@author Marcos Natã Santos
@since 05/07/2018
@version 12.1.17
@type function
/*/
Static Function BuscaNota(cFil,cPed)
	Local cQry
	Local cNota := ""

	cQry := "SELECT SF2.F2_DOC, SF2.F2_EMISSAO " + CRLF
	cQry += "FROM "+ RetSqlName("SD2") +" SD2 " + CRLF
	cQry += "INNER JOIN SF2010 SF2 " + CRLF
	cQry += "ON SF2.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SF2.F2_FILIAL = '"+ cFil +"' " + CRLF
	cQry += "AND SF2.F2_DOC = SD2.D2_DOC " + CRLF
	cQry += "AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + CRLF
	cQry += "AND SF2.F2_LOJA = SD2.D2_LOJA " + CRLF
	cQry += "WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SD2.D2_FILIAL = '"+ cFil +"' " + CRLF
	cQry += "AND SD2.D2_PEDIDO = '"+ cPed +"' " + CRLF
	cQry += "AND ROWNUM = 1 " + CRLF
	cQry := ChangeQuery(cQry)
	
	If Select("NOTA") > 0
		NOTA->(DbCloseArea())
	EndIf
	
	TcQuery cQry New Alias "NOTA"
	
	NOTA->(dbGoTop())
	COUNT TO NQTREG
	NOTA->(dbGoTop())

	If NQTREG > 0
        cNota := AllTrim(NOTA->F2_DOC)
	EndIf

Return cNota
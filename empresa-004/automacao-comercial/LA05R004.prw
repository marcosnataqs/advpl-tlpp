#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R004

Rastro sintético Pedido de Venda

@author Marcos Natã Santos
@since 29/06/2018
@version 12.1.17
@type function
/*/
User Function LA05R004()
    Local cPerg := "LA05R004"
	Private oReport

    AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)

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
	Local cTitulo := "RASTRO SINTÉTICO"
	Local cDescricao := "Rastro Sintético Pedido de Venda"

	oReport := TReport():New("LA05R004",cTitulo,"LA05R004", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSectionInfo := TRSection():New(oReport, "PEDIDOS DE VENDA")
	oSectionInfo:SetTotalInLine(.F.)
	TRCell():New(oSectionInfo, "ZL_NUM", "", RetTitle("ZL_NUM"), PesqPict("SZL","ZL_NUM"), TamSX3("ZL_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_NOMECLI", "", "Cliente", PesqPict("SZL","ZL_NOMECLI"), TamSX3("ZL_NOMECLI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_EMISSAO", "", RetTitle("ZL_EMISSAO"), PesqPict("SZL","ZL_EMISSAO"), TamSX3("ZL_EMISSAO")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "TOTAL", "", "Vlr Total", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "FAT", "", "Vlr Faturado", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "AFAT", "", "Vlr a Faturar", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "CORTE", "", "Vlr Corte", PesqPict("SZM","ZM_TOTAL"), TamSX3("ZM_TOTAL")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A3_NOME", "", "Vendedor", PesqPict("SA3","A3_NOME"), TamSX3("A3_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

    TRFunction():New(oSectionInfo:Cell("TOTAL"),, "SUM",,,PesqPict("SZM","ZM_TOTAL"),,.F.,.T.,.F.,oSectionInfo)
	TRFunction():New(oSectionInfo:Cell("FAT"),, "SUM",,,PesqPict("SZM","ZM_TOTAL"),,.F.,.T.,.F.,oSectionInfo)
	TRFunction():New(oSectionInfo:Cell("AFAT"),, "SUM",,,PesqPict("SZM","ZM_TOTAL"),,.F.,.T.,.F.,oSectionInfo)
    TRFunction():New(oSectionInfo:Cell("CORTE"),, "SUM",,,PesqPict("SZM","ZM_TOTAL"),,.F.,.T.,.F.,oSectionInfo)
    
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
	Local cQry
    Local cVendedor    := ""
    Local aDados       := {}
    Local nTotal       := 0
    Local nFat         := 0
    Local nCorte       := 0

    cQry := "SELECT ZL_NUM, ZL_CLIENTE, ZL_LOJA, ZL_NOMECLI, ZL_EMISSAO, ZL_VEND " + CRLF
    cQry += "FROM " + RetSqlName("SZL") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZL_FILIAL = '"+ xFilial("SZL") +"' " + CRLF
    cQry += "AND ZL_NUM     BETWEEN '"+ MV_PAR01 +"'   AND '"+ MV_PAR02 +"' " + CRLF
    cQry += "AND ZL_CLIENTE BETWEEN '"+ MV_PAR03 +"'  AND '"+ MV_PAR04 +"' " + CRLF
    cQry += "AND ZL_VEND    BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' " + CRLF
    cQry += "AND ZL_EMISSAO BETWEEN '"+ DTOS(MV_PAR07) +"'  AND '"+ DTOS(MV_PAR08) +"' " + CRLF
    cQry += "ORDER BY ZL_NUM, ZL_EMISSAO " + CRLF
    cQry := ChangeQuery(cQry)

    MemoWrite("C:\Users\marcosnqs\Desktop\querys\LA05R004.sql", cQry)

    If Select("TMP") > 0
        TMP->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP"

    TMP->(dbGoTop())
    COUNT TO NQTREG
    TMP->(dbGoTop())

    If NQTREG > 0
        oSectionInfo:Init()
        oReport:SetMeter(NQTREG)

        While TMP->( !EOF() )
            If oReport:Cancel()
                Return
            EndIf

            oReport:IncMeter()

            cVendedor := AllTrim(Posicione("SA3",1,xFilial("SA3")+TMP->ZL_VEND,"A3_NOME"))
            aDados    := TotPed(TMP->ZL_NUM,TMP->ZL_CLIENTE,TMP->ZL_LOJA)
            nTotal    := aDados[1]
            nFat      := TotFat(TMP->ZL_NUM)
            nCorte    := aDados[2]

            oSectionInfo:Cell("ZL_NUM"):SetValue(TMP->ZL_NUM)
            oSectionInfo:Cell("ZL_NUM"):SetAlign("LEFT")

            oSectionInfo:Cell("ZL_NOMECLI"):SetValue(TMP->ZL_NOMECLI)
            oSectionInfo:Cell("ZL_NOMECLI"):SetAlign("LEFT")

            oSectionInfo:Cell("ZL_EMISSAO"):SetValue(DTOC(STOD(TMP->ZL_EMISSAO)))
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

            cVendedor := ""
            nTotal := nFat := nCorte := 0
            
            TMP->( dbSkip() )
        EndDo

        oSectionInfo:Finish()
        TMP->( dbCloseArea() )
    EndIf

	MS_FLUSH()

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

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 05/07/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","De pedido?","MV_CH1","C",6,0,0,"G","MV_PAR01","","","","SZL",""})
	aAdd(aRegs,{"02","Até pedido?","MV_CH2","C",6,0,0,"G","MV_PAR02","","","","SZL",""})
	aAdd(aRegs,{"03","De cliente?","MV_CH3","C",6,0,0,"G","MV_PAR03","","","","SA1",""})
    aAdd(aRegs,{"04","Até cliente?","MV_CH4","C",6,0,0,"G","MV_PAR04","","","","SA1",""})
    aAdd(aRegs,{"05","De vendedor?","MV_CH5","C",6,0,0,"G","MV_PAR05","","","","SA3",""})
    aAdd(aRegs,{"06","Até vendedor?","MV_CH6","C",6,0,0,"G","MV_PAR06","","","","SA3",""})
    aAdd(aRegs,{"07","Emissão De?","MV_CH7","D",10,0,0,"G","MV_PAR07","","","","",""})
    aAdd(aRegs,{"08","Emissão Até?","MV_CH8","D",10,0,0,"G","MV_PAR08","","","","",""})

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
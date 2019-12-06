#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA05R002

Histórico do Pedido de Venda Automação

@author Marcos Natã Santos
@since 20/06/2018
@version 12.1.17
@type function
/*/
User Function LA05R002()
    Local cPerg := "LA05R002"
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
	Local oReport, oSection, oSectionInfo
	Local cTitulo := "HISTÓRICO PEDIDO DE VENDA"
	Local cDescricao := "Histórico de Pedido de Venda Automação"

	oReport := TReport():New("LA05R002",cTitulo,"LA05R002", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
    //oReport:lParamPage    := .F.
    //oReport:lPrtParamPage := .F.

	oSectionInfo := TRSection():New(oReport, "PEDIDO DE VENDA")
	oSectionInfo:SetTotalInLine(.F.)
    //oSectionInfo:aTable := {}
	//oSectionInfo:AddTable('SZL')
    //oSectionInfo:AddTable('SZO')
    TRCell():New(oSectionInfo, "ZL_NUM", "", RetTitle("ZL_NUM"), PesqPict("SZL","ZL_NUM"), TamSX3("ZL_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_NOMECLI", "", "Cliente", PesqPict("SZL","ZL_NOMECLI"), TamSX3("ZL_NOMECLI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "ZL_EMISSAO", "", RetTitle("ZL_EMISSAO"), PesqPict("SZL","ZL_EMISSAO"), TamSX3("ZL_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A3_NOME", "", "Vendedor", PesqPict("SA3","A3_NOME"), TamSX3("A3_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	oSection := TRSection():New(oReport, "HISTORICO")
	oSection:SetTotalInLine(.F.)
    TRCell():New(oSection, "ZO_USRNAME", "", "Responsável", PesqPict("SZO","ZO_USRNAME"), TamSX3("ZO_USRNAME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZO_DATA", "", RetTitle("ZO_DATA"), PesqPict("SZO","ZO_DATA"), TamSX3("ZO_DATA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZO_HORA", "", RetTitle("ZO_HORA"), PesqPict("SZO","ZO_HORA"), TamSX3("ZO_HORA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "ZO_OBS", "", "Movimento", PesqPict("SZO","ZO_OBS"), TamSX3("ZO_OBS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*/{Protheus.doc} ReportDef

PrintReport

@author Marcos Natã Santos
@since 20/06/2018
@version 12.1.17
@type function
/*/
Static Function PrintReport(oReport)
	Local oSectionInfo := oReport:Section(1)
	Local oSection     := oReport:Section(2)
	Local cQry
    Local aAreaSZL     := SZL->(GetArea())
    Local cVendedor    := ""

    cQry := "SELECT ZL_NOMECLI, ZL_NUM, ZL_CLIENTE, ZL_LOJA, ZL_VEND, ZL_NOMECLI, ZL_EMISSAO  " + CRLF
    cQry += "FROM "+ RetSqlName("SZL") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZL_NUM BETWEEN '"+ MV_PAR01 +"'   AND '"+ MV_PAR02 +"' " + CRLF
    cQry += "AND ZL_CLIENTE  BETWEEN '"+ MV_PAR03 +"'  AND '"+ MV_PAR04 +"' " + CRLF
    //MemoWrite("C:\LINEA\LA05R002.sql", cQry)

    //SZL->(dbSetOrder(1))
    //If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
    If Select("TMP1") > 0
        TMP1->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP1"

    TMP1->(dbGoTop())
    oReport:SetMeter(TMP1->(RecCount()))
    While TMP1->(!EOF())
        oSectionInfo:Init()

        If oReport:Cancel()
           Return
        EndIf
        oReport:IncMeter()
        cVendedor    := AllTrim(Posicione("SA3",1,xFilial("SA3")+TMP1->ZL_VEND,"A3_NOME"))

        oSectionInfo:Cell("ZL_NUM"):SetValue(TMP1->ZL_NUM)
        oSectionInfo:Cell("ZL_NUM"):SetAlign("LEFT")

        oSectionInfo:Cell("ZL_NOMECLI"):SetValue(TMP1->ZL_NOMECLI)
        oSectionInfo:Cell("ZL_NOMECLI"):SetAlign("LEFT")

        oSectionInfo:Cell("ZL_EMISSAO"):SetValue(TMP1->ZL_EMISSAO)
        oSectionInfo:Cell("ZL_EMISSAO"):SetAlign("LEFT")
        oSectionInfo:Cell("ZL_EMISSAO"):SetSize(10)

        oSectionInfo:Cell("A3_NOME"):SetValue(cVendedor)
        oSectionInfo:Cell("A3_NOME"):SetAlign("LEFT")

        oSectionInfo:PrintLine()

        cQry := "SELECT ZO_USRNAME, ZO_DATA, ZO_HORA, ZO_OBS " + CRLF
        cQry += "FROM "+ RetSqlName("SZO") + CRLF
        cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "AND ZO_NUM = '"+ TMP1->ZL_NUM +"' " + CRLF
        //cQry += "AND ZO_NUM BETWEEN '"+ MV_PAR01 +"'   AND '"+ MV_PAR02 +"' " + CRLF
        cQry += "AND ZO_CLIENTE = '"+ TMP1->ZL_CLIENTE +"' " + CRLF
        //cQry += "AND ZO_CLIENTE  BETWEEN '"+ MV_PAR03 +"'  AND '"+ MV_PAR04 +"' " + CRLF
        cQry += "AND ZO_LOJA = '"+ TMP1->ZL_LOJA +"' " + CRLF
        //MemoWrite("C:\LINEA\LA05R002"+TMP1->ZL_NUM+".sql", cQry)

        cQry := ChangeQuery(cQry)

        If Select("TMP2") > 0
            TMP2->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "TMP2"

        TMP2->(dbGoTop())
        oSection:Init()
        oReport:SetMeter(TMP2->(RecCount()))
        While TMP2->(!EOF())
            If oReport:Cancel()
                Exit
            EndIf

            oReport:IncMeter()

            oSection:Cell("ZO_USRNAME"):SetValue(TMP2->ZO_USRNAME)
            oSection:Cell("ZO_USRNAME"):SetAlign("LEFT")

            oSection:Cell("ZO_DATA"):SetValue(DTOC(STOD(TMP2->ZO_DATA)))
            oSection:Cell("ZO_DATA"):SetAlign("LEFT")
            oSection:Cell("ZO_DATA"):SetSize(15)

            oSection:Cell("ZO_HORA"):SetValue(TMP2->ZO_HORA)
            oSection:Cell("ZO_HORA"):SetAlign("LEFT")

            oSection:Cell("ZO_OBS"):SetValue(TMP2->ZO_OBS)
            oSection:Cell("ZO_OBS"):SetAlign("LEFT")

            oSection:PrintLine()

            TMP2->(dbSkip())
        EndDo
        oSection:Finish()
        TMP1->(dbSkip())
        oSectionInfo:Finish()
    //EndIf
    EndDo

	MS_FLUSH()
    RestArea(aAreaSZL)
Return


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
	aAdd(aRegs,{"02","Até pedido?","MV_CH2","C",6,0,0,"G","MV_PAR02","999999","","","SZL",""})
	aAdd(aRegs,{"03","De cliente?","MV_CH3","C",6,0,0,"G","MV_PAR03","","","","SA1",""})
    aAdd(aRegs,{"04","Até cliente?","MV_CH4","C",6,0,0,"G","MV_PAR04","999999","","","SA1",""})

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
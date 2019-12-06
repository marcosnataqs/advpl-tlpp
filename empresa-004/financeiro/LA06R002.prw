#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA06R002

Posição de Clientes Custom

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
User Function LA06R002()
    Local cPerg := "LA06R002"
	Private oReport

    AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef

ReportDef

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef()
	Local oReport, oSectionInfo
	Local cTitulo := "POSICÃO DE CLIENTES"
	Local cDescricao := "Posição de Clientes Custom"

	oReport := TReport():New("LA06R002",cTitulo,"LA06R002", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

	oSectionInfo := TRSection():New(oReport, "POSIÇÃO DE CLIENTES")
	oSectionInfo:SetTotalInLine(.F.)
    TRCell():New(oSectionInfo, "INFO", "", "Info", PesqPict("SE1","E1_PREFIXO"), TamSX3("E1_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "E1_PREFIXO", "", RetTitle("E1_PREFIXO"), PesqPict("SE1","E1_PREFIXO"), TamSX3("E1_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_TIPO", "", RetTitle("E1_TIPO"), PesqPict("SE1","E1_TIPO"), TamSX3("E1_TIPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_CLIENTE", "", RetTitle("E1_CLIENTE"), PesqPict("SE1","E1_CLIENTE"), TamSX3("E1_CLIENTE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_LOJA", "", RetTitle("E1_LOJA"), PesqPict("SE1","E1_LOJA"), TamSX3("E1_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A1_NOME", "", "Razão Social", PesqPict("SA2","A1_NOME"), TamSX3("A1_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_NUM", "", RetTitle("E1_NUM"), PesqPict("SE1","E1_NUM"), TamSX3("E1_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_PARCELA", "", RetTitle("E1_PARCELA"), PesqPict("SE1","E1_PARCELA"), TamSX3("E1_PARCELA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_VALOR", "", RetTitle("E1_VALOR"), PesqPict("SE1","E1_VALOR"), TamSX3("E1_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_MULTA", "", RetTitle("E1_MULTA"), PesqPict("SE1","E1_MULTA"), TamSX3("E1_MULTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_JUROS", "", RetTitle("E1_JUROS"), PesqPict("SE1","E1_JUROS"), TamSX3("E1_JUROS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_DESCONT", "", RetTitle("E1_DESCONT"), PesqPict("SE1","E1_DESCONT"), TamSX3("E1_DESCONT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_DECRESC", "", RetTitle("E1_DECRESC"), PesqPict("SE1","E1_DECRESC"), TamSX3("E1_DECRESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_ACRESC", "", RetTitle("E1_ACRESC"), PesqPict("SE1","E1_ACRESC"), TamSX3("E1_ACRESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_VALBX", "", "Vlr Baixa", PesqPict("SE1","E1_VALOR"), TamSX3("E1_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_SALDO", "", RetTitle("E1_SALDO"), PesqPict("SE1","E1_SALDO"), TamSX3("E1_SALDO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_EMISSAO", "", RetTitle("E1_EMISSAO"), PesqPict("SE1","E1_EMISSAO"), TamSX3("E1_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "EMISSAO", "", "Emissao",, 20,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_VENCREA", "", RetTitle("E1_VENCREA"), PesqPict("SE1","E1_VENCREA"), TamSX3("E1_VENCREA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "VENCREA", "", "Vencto",, 20,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_BAIXA", "", RetTitle("E1_BAIXA"), PesqPict("SE1","E1_BAIXA"), TamSX3("E1_BAIXA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_DTDISPO", "", RetTitle("E5_DTDISPO"), PesqPict("SE5","E5_DTDISPO"), TamSX3("E5_DTDISPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_MOTBX", "", RetTitle("E5_MOTBX"), PesqPict("SE5","E5_MOTBX"), TamSX3("E5_MOTBX")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_HIST", "", RetTitle("E1_HIST"), PesqPict("SE1","E1_HIST"), TamSX3("E1_HIST")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_DOCUMEN", "", RetTitle("E5_DOCUMEN"), PesqPict("SE5","E5_DOCUMEN"), TamSX3("E5_DOCUMEN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_NATUREZ", "", RetTitle("E1_NATUREZ"), PesqPict("SE1","E1_NATUREZ"), TamSX3("E1_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_XGRPVEN", "", RetTitle("E1_XGRPVEN"), PesqPict("SE1","E1_XGRPVEN"), TamSX3("E1_XGRPVEN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "ACY_DESCRI", "", RetTitle("ACY_DESCRI"), PesqPict("SE1","ACY_DESCRI"), TamSX3("ACY_DESCRI")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E1_VEND1", "", RetTitle("E1_VEND1"), PesqPict("SE1","E1_VEND1"), TamSX3("E1_VEND1")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A3_NOME", "", "Representante", PesqPict("SA3","A3_NOME"), TamSX3("A3_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*/{Protheus.doc} ReportDef

PrintReport

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
Static Function PrintReport(oReport)
	Local oSectionInfo := oReport:Section(1)
	Local cQry
    Local cNaturez := ""
    Local cPref    := ""
    Local cNum     := ""
    Local cParcela := ""
    Local cTipo    := ""
    Local cLoja    := ""

    oReport:SetMeter(QRYSE1())
    oSectionInfo:Init()
    While TMP1->( !EOF() )
        oReport:IncMeter()
        If oReport:Cancel()
            Return
        EndIf

        oSectionInfo:Cell("INFO"):SetValue(TMP1->TIT)
        oSectionInfo:Cell("E1_PREFIXO"):SetValue(TMP1->E1_PREFIXO)
        oSectionInfo:Cell("E1_NUM"):SetValue(TMP1->E1_NUM)
        oSectionInfo:Cell("E1_PARCELA"):SetValue(TMP1->E1_PARCELA)
        oSectionInfo:Cell("E1_TIPO"):SetValue(TMP1->E1_TIPO)
        oSectionInfo:Cell("E1_VALOR"):SetValue(TMP1->E1_VALOR)
        oSectionInfo:Cell("E1_MULTA"):SetValue(TMP1->E1_MULTA)
        oSectionInfo:Cell("E1_JUROS"):SetValue(TMP1->E1_JUROS)
        oSectionInfo:Cell("E1_DESCONT"):SetValue(TMP1->E1_DESCONT)
        oSectionInfo:Cell("E1_DECRESC"):SetValue(TMP1->E1_DECRESC)
        oSectionInfo:Cell("E1_ACRESC"):SetValue(TMP1->E1_ACRESC)
        oSectionInfo:Cell("E1_SALDO"):SetValue(TMP1->E1_SALDO)
        oSectionInfo:Cell("E1_EMISSAO"):SetValue(STOD(TMP1->E1_EMISSAO))
        oSectionInfo:Cell("EMISSAO"):SetValue( MesExtenso(Month(STOD(TMP1->E1_EMISSAO))) + "/" + cValToChar(Year(STOD(TMP1->E1_EMISSAO))) )
        oSectionInfo:Cell("E1_VENCREA"):SetValue(STOD(TMP1->E1_VENCREA))
        oSectionInfo:Cell("VENCREA"):SetValue( MesExtenso(Month(STOD(TMP1->E1_VENCREA))) + "/" + cValToChar(Year(STOD(TMP1->E1_VENCREA))) )
        oSectionInfo:Cell("E1_VALBX"):SetValue(0)
        oSectionInfo:Cell("E1_BAIXA"):SetValue(STOD(TMP1->E1_BAIXA))
        oSectionInfo:Cell("E5_DTDISPO"):SetValue("")
        oSectionInfo:Cell("E5_MOTBX"):SetValue("")
        oSectionInfo:Cell("E1_HIST"):SetValue(TMP1->E1_HIST)
        oSectionInfo:Cell("E5_DOCUMEN"):SetValue("")
        oSectionInfo:Cell("E1_NATUREZ"):SetValue(TMP1->E1_NATUREZ)
        oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP1->E1_NATUREZ, "ED_DESCRIC") )
        oSectionInfo:Cell("E1_CLIENTE"):SetValue(TMP1->E1_CLIENTE)
        oSectionInfo:Cell("E1_LOJA"):SetValue(TMP1->E1_LOJA)
        oSectionInfo:Cell("A1_NOME"):SetValue( Posicione("SA1",1,xFilial("SA1")+TMP1->E1_CLIENTE+TMP1->E1_LOJA, "A1_NOME") )
        oSectionInfo:Cell("E1_XGRPVEN"):SetValue(TMP1->E1_XGRPVEN)
        oSectionInfo:Cell("ACY_DESCRI"):SetValue( Posicione("ACY",1,xFilial("ACY")+TMP1->E1_XGRPVEN, "ACY_DESCRI") )
        oSectionInfo:Cell("E1_VEND1"):SetValue(TMP1->E1_VEND1)
        oSectionInfo:Cell("A3_NOME"):SetValue( Posicione("SA3",1,xFilial("SA3")+TMP1->E1_VEND1, "A3_NOME") )

        oSectionInfo:PrintLine()

        QRYSE5(TMP1->E1_NUM,TMP1->E1_CLIENTE,TMP1->E1_LOJA,TMP1->E1_PREFIXO,TMP1->E1_TIPO,TMP1->E1_PARCELA)
        While TMP2->( !EOF() )

            oSectionInfo:Cell("INFO"):SetValue(TMP2->BX)
            oSectionInfo:Cell("E1_PREFIXO"):SetValue(TMP2->E5_PREFIXO)
            oSectionInfo:Cell("E1_NUM"):SetValue(TMP2->E5_NUMERO)
            oSectionInfo:Cell("E1_PARCELA"):SetValue(TMP2->E5_PARCELA)
            oSectionInfo:Cell("E1_TIPO"):SetValue(TMP2->E5_TIPO)
            oSectionInfo:Cell("E1_VALOR"):SetValue(0)
            oSectionInfo:Cell("E1_MULTA"):SetValue(TMP2->E5_VLMULTA)
            oSectionInfo:Cell("E1_JUROS"):SetValue(TMP2->E5_VLJUROS)
            oSectionInfo:Cell("E1_DESCONT"):SetValue(0)
            oSectionInfo:Cell("E1_DECRESC"):SetValue("")
            oSectionInfo:Cell("E1_ACRESC"):SetValue("")
            oSectionInfo:Cell("E1_SALDO"):SetValue("")
            oSectionInfo:Cell("E1_EMISSAO"):SetValue("")
            oSectionInfo:Cell("EMISSAO"):SetValue("")
            oSectionInfo:Cell("E1_VENCREA"):SetValue("")
            oSectionInfo:Cell("VENCREA"):SetValue("")
            oSectionInfo:Cell("E1_VALBX"):SetValue(TMP2->E5_VALOR)
            oSectionInfo:Cell("E1_BAIXA"):SetValue(STOD(TMP2->E5_DATA))
            oSectionInfo:Cell("E5_DTDISPO"):SetValue(STOD(TMP2->E5_DTDISPO))
            oSectionInfo:Cell("E5_MOTBX"):SetValue(TMP2->E5_MOTBX)
            oSectionInfo:Cell("E1_HIST"):SetValue(TMP2->E5_HISTOR)
            oSectionInfo:Cell("E5_DOCUMEN"):SetValue(TMP2->E5_DOCUMEN)
            If TMP2->E5_MOTBX == "CMP"
                cPref    := SubStr(TMP2->E5_DOCUMEN,1,3)
                cNum     := SubStr(TMP2->E5_DOCUMEN,4,9)
                cParcela := SubStr(TMP2->E5_DOCUMEN,13,3)
                cTipo    := SubStr(TMP2->E5_DOCUMEN,16,3)
                cLoja    := SubStr(TMP2->E5_DOCUMEN,19,2)
                cNaturez := NATCMP(cPref,cNum,cParcela,cTipo,cLoja)

                If !Empty(cNaturez)
                    oSectionInfo:Cell("E1_NATUREZ"):SetValue(cNaturez)
                    oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+cNaturez, "ED_DESCRIC") )
                Else
                    oSectionInfo:Cell("E1_NATUREZ"):SetValue(TMP2->E5_NATUREZ)
                    oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP1->E1_NATUREZ, "ED_DESCRIC") )
                EndIf
            
            Else
                oSectionInfo:Cell("E1_NATUREZ"):SetValue(TMP2->E5_NATUREZ)
                oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP1->E1_NATUREZ, "ED_DESCRIC") )
            EndIf
            oSectionInfo:Cell("E1_CLIENTE"):SetValue(TMP2->E5_CLIENTE)
            oSectionInfo:Cell("E1_LOJA"):SetValue(TMP2->E5_LOJA)
            oSectionInfo:Cell("A1_NOME"):SetValue( Posicione("SA1",1,xFilial("SA1")+TMP1->E1_CLIENTE+TMP1->E1_LOJA, "A1_NOME") )
            oSectionInfo:Cell("E1_XGRPVEN"):SetValue(TMP1->E1_XGRPVEN)
            oSectionInfo:Cell("ACY_DESCRI"):SetValue( Posicione("ACY",1,xFilial("ACY")+TMP1->E1_XGRPVEN, "ACY_DESCRI") )
            oSectionInfo:Cell("E1_VEND1"):SetValue(TMP1->E1_VEND1)
            oSectionInfo:Cell("A3_NOME"):SetValue( Posicione("SA3",1,xFilial("SA3")+TMP1->E1_VEND1, "A3_NOME") )

            oSectionInfo:PrintLine()
            
            TMP2->( dbSkip() )
        EndDo

        TMP2->( DbCloseArea() )
        TMP1->( dbSkip() )
    EndDo

    TMP1->( DbCloseArea() )
    oSectionInfo:Finish()

	MS_FLUSH()

Return

/*/{Protheus.doc} QRYSE1

QRYSE1 - Busca dados tabela SE1

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
Static Function QRYSE1()
    Local cQry
    Local nQtReg := 0

    cQry := "SELECT 'TIT' TIT, " + CRLF
    cQry += "    E1_PREFIXO, " + CRLF
    cQry += "    E1_NUM, " + CRLF
    cQry += "    E1_PARCELA, " + CRLF
    cQry += "    E1_TIPO, " + CRLF
    cQry += "    E1_VALOR, " + CRLF
    cQry += "    E1_MULTA, " + CRLF
    cQry += "    E1_JUROS, " + CRLF
    cQry += "    E1_DESCONT, " + CRLF
    cQry += "    E1_DECRESC, " + CRLF
    cQry += "    E1_ACRESC, " + CRLF
    cQry += "    E1_SALDO, " + CRLF
    cQry += "    E1_EMISSAO, " + CRLF
    cQry += "    E1_VENCREA, " + CRLF
    cQry += "    E1_BAIXA, " + CRLF
    cQry += "    E1_HIST, " + CRLF
    cQry += "    E1_NATUREZ, " + CRLF
    cQry += "    E1_CLIENTE, " + CRLF
    cQry += "    E1_LOJA, " + CRLF
    cQry += "    E1_XGRPVEN, " + CRLF
    cQry += "    E1_VEND1 " + CRLF
    cQry += "FROM " + RetSqlName("SE1") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E1_FILIAL = '"+ xFilial("SE1") +"' " + CRLF
    cQry += "AND E1_CLIENTE BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
    cQry += "AND E1_LOJA BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' " + CRLF
    cQry += "AND E1_EMISSAO BETWEEN '"+ DTOS(MV_PAR05) +"' AND '"+ DTOS(MV_PAR06) +"' " + CRLF
    cQry += "AND E1_NATUREZ BETWEEN '"+ MV_PAR07 +"' AND '"+ MV_PAR08 +"' " + CRLF
    cQry += "AND E1_TIPO = 'NF' " + CRLF //-- Filtra apenas vendas --//
    cQry += "AND E1_NATUREZ NOT IN('305010012') " + CRLF //-- Desconsidera ICMS-ST --//
    cQry += "ORDER BY E1_EMISSAO " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMP1") > 0
        TMP1->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP1"
    TMP1->( dbGoTop() )
    COUNT TO nQtReg
    TMP1->( dbGoTop() )

Return nQtReg

/*/{Protheus.doc} QRYSE5

QRYSE5 - Busca dados tabela SE5

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
Static Function QRYSE5(cNum,cCliente,cLoja,cPref,cTipo,cParcela)
    Local cQry

    cQry := "SELECT 'BX' BX, " + CRLF
    cQry += "    E5_PREFIXO, " + CRLF
    cQry += "    E5_NUMERO, " + CRLF
    cQry += "    E5_PARCELA, " + CRLF
    cQry += "    E5_TIPO, " + CRLF
    cQry += "    E5_VALOR, " + CRLF
    cQry += "    E5_VLMULTA, " + CRLF
    cQry += "    E5_VLJUROS, " + CRLF
    cQry += "    E5_VLDESCO, " + CRLF
    cQry += "    E5_DATA, " + CRLF
    cQry += "    E5_DTDISPO, " + CRLF
    cQry += "    E5_MOTBX, " + CRLF
    cQry += "    E5_HISTOR, " + CRLF
    cQry += "    E5_DOCUMEN, " + CRLF
    cQry += "    E5_NATUREZ, " + CRLF
    cQry += "    E5_CLIENTE, " + CRLF
    cQry += "    E5_LOJA " + CRLF
    cQry += "FROM " + RetSqlName("SE5") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E5_FILIAL = '"+ xFilial("SE5") +"' " + CRLF
    cQry += "AND E5_RECPAG = 'R' " + CRLF
    cQry += "AND E5_NUMERO = '"+ cNum +"' " + CRLF
    cQry += "AND E5_CLIENTE = '"+ cCliente +"' " + CRLF
    cQry += "AND E5_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "AND E5_PREFIXO = '"+ cPref +"' " + CRLF
    cQry += "AND E5_TIPO = '"+ cTipo +"' " + CRLF
    cQry += "AND E5_PARCELA = '"+ cParcela +"' " + CRLF
    cQry += "ORDER BY E5_DATA " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMP2") > 0
        TMP2->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP2"

Return

/*/{Protheus.doc} NATCMP

Busca natureza real da compensação

@author Marcos Natã Santos
@since 26/09/2018
@version 12.1.17
@type function
/*/
Static Function NATCMP(cPref,cNum,cParcela,cTipo,cLoja)
    Local cQry
    Local nQtReg   := 0
    Local cNaturez := ""

    cQry := "SELECT E1_NATUREZ " + CRLF
    cQry += "FROM " + RetSqlName("SE1") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E1_FILIAL = '"+ xFilial("SE1") +"' " + CRLF
    cQry += "AND E1_PREFIXO = '"+ cPref +"' " + CRLF
    cQry += "AND E1_NUM = '"+ cNum +"' " + CRLF
    cQry += "AND E1_PARCELA = '"+ cParcela +"' " + CRLF
    cQry += "AND E1_TIPO = '"+ cTipo +"' " + CRLF
    cQry += "AND E1_LOJA = '"+ cLoja +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMP3") > 0
        TMP3->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP3"
    TMP3->( dbGoTop() )
    COUNT TO nQtReg
    TMP3->( dbGoTop() )

    If nQtReg > 0
        cNaturez = TMP3->E1_NATUREZ
    EndIf

    TMP3->(DbCloseArea())

Return cNaturez

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 26/09/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","De cliente?","MV_CH1","C",6,0,0,"G","MV_PAR01","","","","SA1",""})
	aAdd(aRegs,{"02","Até cliente?","MV_CH2","C",6,0,0,"G","MV_PAR02","","","","SA1",""})
	aAdd(aRegs,{"03","De loja?","MV_CH3","C",2,0,0,"G","MV_PAR03","","","","",""})
    aAdd(aRegs,{"04","Até loja?","MV_CH4","C",2,0,0,"G","MV_PAR04","","","","",""})
    aAdd(aRegs,{"05","De emissão?","MV_CH5","D",10,0,0,"G","MV_PAR05","","","","",""})
    aAdd(aRegs,{"06","Até emissão?","MV_CH6","D",10,0,0,"G","MV_PAR06","","","","",""})
    aAdd(aRegs,{"07","De natureza?","MV_CH7","C",10,0,0,"G","MV_PAR07","","","","",""})
    aAdd(aRegs,{"08","Até natureza?","MV_CH8","C",10,0,0,"G","MV_PAR08","","","","",""})

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
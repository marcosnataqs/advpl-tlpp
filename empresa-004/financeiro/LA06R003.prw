#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA06R003

Posição de Fornecedores Custom

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
User Function LA06R003()
    Local cPerg := "LA06R003"
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
	Local cTitulo := "POSICÃO DE FORNECEDORES"
	Local cDescricao := "Posição de Fornecedores Custom"

	oReport := TReport():New("LA06R003",cTitulo,"LA06R003", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

	oSectionInfo := TRSection():New(oReport, "POSICÃO DE FORNECEDORES")
	oSectionInfo:SetTotalInLine(.F.)
    TRCell():New(oSectionInfo, "INFO", "", "Info", PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectionInfo, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_TIPO", "", RetTitle("E2_TIPO"), PesqPict("SE2","E2_TIPO"), TamSX3("E2_TIPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_MULTA", "", RetTitle("E2_MULTA"), PesqPict("SE2","E2_MULTA"), TamSX3("E2_MULTA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_JUROS", "", RetTitle("E2_JUROS"), PesqPict("SE2","E2_JUROS"), TamSX3("E2_JUROS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_DESCONT", "", RetTitle("E2_DESCONT"), PesqPict("SE2","E2_DESCONT"), TamSX3("E2_DESCONT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_DECRESC", "", RetTitle("E2_DECRESC"), PesqPict("SE2","E2_DECRESC"), TamSX3("E2_DECRESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_ACRESC", "", RetTitle("E2_ACRESC"), PesqPict("SE2","E2_ACRESC"), TamSX3("E2_ACRESC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_SALDO", "", RetTitle("E2_SALDO"), PesqPict("SE2","E2_SALDO"), TamSX3("E2_SALDO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_VENCREA", "", RetTitle("E2_VENCREA"), PesqPict("SE2","E2_VENCREA"), TamSX3("E2_VENCREA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_VALBX", "", "Vlr Baixa", PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_BAIXA", "", RetTitle("E2_BAIXA"), PesqPict("SE2","E2_BAIXA"), TamSX3("E2_BAIXA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_DTDISPO", "", RetTitle("E5_DTDISPO"), PesqPict("SE5","E5_DTDISPO"), TamSX3("E5_DTDISPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_MOTBX", "", RetTitle("E5_MOTBX"), PesqPict("SE5","E5_MOTBX"), TamSX3("E5_MOTBX")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_HIST", "", RetTitle("E2_HIST"), PesqPict("SE2","E2_HIST"), TamSX3("E2_HIST")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E5_DOCUMEN", "", RetTitle("E5_DOCUMEN"), PesqPict("SE5","E5_DOCUMEN"), TamSX3("E5_DOCUMEN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSectionInfo, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    
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
    Local cFornece := ""
    Local cLoja    := ""

    oReport:SetMeter(QRYSE2())
    oSectionInfo:Init()
    While TMP1->( !EOF() )
        oReport:IncMeter()
        If oReport:Cancel()
            Return
        EndIf

        oSectionInfo:Cell("INFO"):SetValue(TMP1->TIT)
        oSectionInfo:Cell("E2_PREFIXO"):SetValue(TMP1->E2_PREFIXO)
        oSectionInfo:Cell("E2_NUM"):SetValue(TMP1->E2_NUM)
        oSectionInfo:Cell("E2_PARCELA"):SetValue(TMP1->E2_PARCELA)
        oSectionInfo:Cell("E2_TIPO"):SetValue(TMP1->E2_TIPO)
        oSectionInfo:Cell("E2_VALOR"):SetValue(TMP1->E2_VALOR)
        oSectionInfo:Cell("E2_MULTA"):SetValue(TMP1->E2_MULTA)
        oSectionInfo:Cell("E2_JUROS"):SetValue(TMP1->E2_JUROS)
        oSectionInfo:Cell("E2_DESCONT"):SetValue(TMP1->E2_DESCONT)
        oSectionInfo:Cell("E2_DECRESC"):SetValue(TMP1->E2_DECRESC)
        oSectionInfo:Cell("E2_ACRESC"):SetValue(TMP1->E2_ACRESC)
        oSectionInfo:Cell("E2_SALDO"):SetValue(TMP1->E2_SALDO)
        oSectionInfo:Cell("E2_EMISSAO"):SetValue(STOD(TMP1->E2_EMISSAO))
        oSectionInfo:Cell("E2_VENCREA"):SetValue(STOD(TMP1->E2_VENCREA))
        oSectionInfo:Cell("E2_VALBX"):SetValue(0)
        oSectionInfo:Cell("E2_BAIXA"):SetValue(STOD(TMP1->E2_BAIXA))
        oSectionInfo:Cell("E5_DTDISPO"):SetValue("")
        oSectionInfo:Cell("E5_MOTBX"):SetValue("")
        oSectionInfo:Cell("E2_HIST"):SetValue(TMP1->E2_HIST)
        oSectionInfo:Cell("E5_DOCUMEN"):SetValue("")
        oSectionInfo:Cell("E2_NATUREZ"):SetValue(TMP1->E2_NATUREZ)
        oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP1->E2_NATUREZ, "ED_DESCRIC") )
        oSectionInfo:Cell("E2_FORNECE"):SetValue(TMP1->E2_FORNECE)
        oSectionInfo:Cell("E2_LOJA"):SetValue(TMP1->E2_LOJA)
        oSectionInfo:Cell("A2_NOME"):SetValue( Posicione("SA2",1,xFilial("SA2")+TMP1->E2_FORNECE+TMP1->E2_LOJA, "A2_NOME") )

        oSectionInfo:PrintLine()

        QRYSE5(TMP1->E2_NUM,TMP1->E2_FORNECE,TMP1->E2_LOJA,TMP1->E2_PREFIXO,TMP1->E2_TIPO,TMP1->E2_PARCELA)
        While TMP2->( !EOF() )

            oSectionInfo:Cell("INFO"):SetValue(TMP2->BX)
            oSectionInfo:Cell("E2_PREFIXO"):SetValue(TMP2->E5_PREFIXO)
            oSectionInfo:Cell("E2_NUM"):SetValue(TMP2->E5_NUMERO)
            oSectionInfo:Cell("E2_PARCELA"):SetValue(TMP2->E5_PARCELA)
            oSectionInfo:Cell("E2_TIPO"):SetValue(TMP2->E5_TIPO)
            oSectionInfo:Cell("E2_VALOR"):SetValue(0)
            oSectionInfo:Cell("E2_MULTA"):SetValue(TMP2->E5_VLMULTA)
            oSectionInfo:Cell("E2_JUROS"):SetValue(TMP2->E5_VLJUROS)
            oSectionInfo:Cell("E2_DESCONT"):SetValue(0)
            oSectionInfo:Cell("E2_DECRESC"):SetValue("")
            oSectionInfo:Cell("E2_ACRESC"):SetValue("")
            oSectionInfo:Cell("E2_SALDO"):SetValue("")
            oSectionInfo:Cell("E2_EMISSAO"):SetValue("")
            oSectionInfo:Cell("E2_VENCREA"):SetValue("")
            oSectionInfo:Cell("E2_VALBX"):SetValue(TMP2->E5_VALOR)
            oSectionInfo:Cell("E2_BAIXA"):SetValue(STOD(TMP2->E5_DATA))
            oSectionInfo:Cell("E5_DTDISPO"):SetValue(STOD(TMP2->E5_DTDISPO))
            oSectionInfo:Cell("E5_MOTBX"):SetValue(TMP2->E5_MOTBX)
            oSectionInfo:Cell("E2_HIST"):SetValue(TMP2->E5_HISTOR)
            oSectionInfo:Cell("E5_DOCUMEN"):SetValue(TMP2->E5_DOCUMEN)
            If TMP2->E5_MOTBX == "CMP"
                cPref    := SubStr(TMP2->E5_DOCUMEN,1,3)
                cNum     := SubStr(TMP2->E5_DOCUMEN,4,9)
                cParcela := SubStr(TMP2->E5_DOCUMEN,13,3)
                cTipo    := SubStr(TMP2->E5_DOCUMEN,16,3)
                cFornece := SubStr(TMP2->E5_DOCUMEN,19,6)
                cLoja    := SubStr(TMP2->E5_DOCUMEN,25,2)
                cNaturez := NATCMP(cPref,cNum,cParcela,cTipo,cFornece,cLoja)

                If !Empty(cNaturez)
                    oSectionInfo:Cell("E2_NATUREZ"):SetValue(cNaturez)
                    oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+cNaturez, "ED_DESCRIC") )
                Else
                    oSectionInfo:Cell("E2_NATUREZ"):SetValue(TMP2->E5_NATUREZ)
                    oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP2->E5_NATUREZ, "ED_DESCRIC") )
                EndIf
            
            Else
                oSectionInfo:Cell("E2_NATUREZ"):SetValue(TMP2->E5_NATUREZ)
                oSectionInfo:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMP2->E5_NATUREZ, "ED_DESCRIC") )
            EndIf
            oSectionInfo:Cell("E2_FORNECE"):SetValue(TMP2->E5_FORNECE)
            oSectionInfo:Cell("E2_LOJA"):SetValue(TMP2->E5_LOJA)
            oSectionInfo:Cell("A2_NOME"):SetValue( Posicione("SA2",1,xFilial("SA2")+TMP1->E2_FORNECE+TMP1->E2_LOJA, "A2_NOME") )

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

/*/{Protheus.doc} QRYSE2

QRYSE2 - Busca dados tabela SE2

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
Static Function QRYSE2()
    Local cQry
    Local nQtReg := 0

    cQry := "SELECT 'TIT' TIT, " + CRLF
    cQry += "    E2_PREFIXO, " + CRLF
    cQry += "    E2_NUM, " + CRLF
    cQry += "    E2_PARCELA, " + CRLF
    cQry += "    E2_TIPO, " + CRLF
    cQry += "    E2_VALOR, " + CRLF
    cQry += "    E2_MULTA, " + CRLF
    cQry += "    E2_JUROS, " + CRLF
    cQry += "    E2_DESCONT, " + CRLF
    cQry += "    E2_DECRESC, " + CRLF
    cQry += "    E2_ACRESC, " + CRLF
    cQry += "    E2_SALDO, " + CRLF
    cQry += "    E2_EMISSAO, " + CRLF
    cQry += "    E2_VENCREA, " + CRLF
    cQry += "    E2_BAIXA, " + CRLF
    cQry += "    E2_HIST, " + CRLF
    cQry += "    E2_NATUREZ, " + CRLF
    cQry += "    E2_FORNECE, " + CRLF
    cQry += "    E2_LOJA " + CRLF
    cQry += "FROM " + RetSqlName("SE2") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "AND E2_FORNECE BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
    cQry += "AND E2_LOJA BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' " + CRLF
    cQry += "AND E2_EMISSAO BETWEEN '"+ DTOS(MV_PAR05) +"' AND '"+ DTOS(MV_PAR06) +"' " + CRLF
    cQry += "AND E2_NATUREZ BETWEEN '"+ MV_PAR07 +"' AND '"+ MV_PAR08 +"' " + CRLF
    cQry += "ORDER BY E2_EMISSAO " + CRLF
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
    cQry += "    E5_FORNECE, " + CRLF
    cQry += "    E5_LOJA " + CRLF
    cQry += "FROM " + RetSqlName("SE5") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E5_FILIAL = '"+ xFilial("SE5") +"' " + CRLF
    cQry += "AND E5_RECPAG = 'P' " + CRLF
    cQry += "AND E5_NUMERO = '"+ cNum +"' " + CRLF
    cQry += "AND E5_FORNECE = '"+ cCliente +"' " + CRLF
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
Static Function NATCMP(cPref,cNum,cParcela,cTipo,cFornece,cLoja)
    Local cQry
    Local nQtReg   := 0
    Local cNaturez := ""

    cQry := "SELECT E2_NATUREZ " + CRLF
    cQry += "FROM " + RetSqlName("SE2") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "AND E2_PREFIXO = '"+ cPref +"' " + CRLF
    cQry += "AND E2_NUM = '"+ cNum +"' " + CRLF
    cQry += "AND E2_PARCELA = '"+ cParcela +"' " + CRLF
    cQry += "AND E2_TIPO = '"+ cTipo +"' " + CRLF
    cQry += "AND E2_FORNECE = '"+ cFornece +"' " + CRLF
    cQry += "AND E2_LOJA = '"+ cLoja +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMP3") > 0
        TMP3->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMP3"
    TMP3->( dbGoTop() )
    COUNT TO nQtReg
    TMP3->( dbGoTop() )

    If nQtReg > 0
        cNaturez = TMP3->E2_NATUREZ
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
	aAdd(aRegs,{"01","De fornecedor?","MV_CH1","C",6,0,0,"G","MV_PAR01","","","","SA2",""})
	aAdd(aRegs,{"02","Até fornecedor?","MV_CH2","C",6,0,0,"G","MV_PAR02","","","","SA2",""})
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
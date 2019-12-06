#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

#Define DMPAPER_A4 9

/*/{Protheus.doc} LA06R001

Relatório Oscilação de Caixa

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
User Function LA06R001()
	Private oReport

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef

ReportDef

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef()
	Local oReport, oSection1
	Local cTitulo := "OSCILAÇÃO DE CAIXA"
	Local cDescricao := "Relatório Oscilação de Caixa"

	oReport := TReport():New("LA06R001",cTitulo,"LA06R001", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetPortrait()
    oReport:lParamPage    := .F.
    oReport:lPrtParamPage := .F.

	oSection1 := TRSection():New(oReport, "DOC SEM PC")
	TRCell():New(oSection1, "F1_DTDIGIT", "", RetTitle("F1_DTDIGIT"), PesqPict("SF1","F1_DTDIGIT"), TamSX3("F1_DTDIGIT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_VENCTO", "", RetTitle("E2_VENCTO"), PesqPict("SE2","E2_VENCTO"), TamSX3("E2_VENCTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]-6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "E2_CCD", "", "C. Custo", PesqPict("SE2","E2_CCD"), TamSX3("E2_CCD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "CTT_DESC01", "", "C. Custo", PesqPict("CTT","CTT_DESC01"), TamSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection2 := TRSection():New(oReport, "DOC COND PAG DIFERENTE PC")
    TRCell():New(oSection2, "F1_DTDIGIT", "", RetTitle("F1_DTDIGIT"), PesqPict("SF1","F1_DTDIGIT"), TamSX3("F1_DTDIGIT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_VENCTO", "", RetTitle("E2_VENCTO"), PesqPict("SE2","E2_VENCTO"), TamSX3("E2_VENCTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]-6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "E2_CCD", "", "C. Custo", PesqPict("SE2","E2_CCD"), TamSX3("E2_CCD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2, "CTT_DESC01", "", "C. Custo", PesqPict("CTT","CTT_DESC01"), TamSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSection3 := TRSection():New(oReport, "PEDIDOS DE COMPRA")
    TRCell():New(oSection3, "F1_DTDIGIT", "", RetTitle("F1_DTDIGIT"), PesqPict("SF1","F1_DTDIGIT"), TamSX3("F1_DTDIGIT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_VENCTO", "", RetTitle("E2_VENCTO"), PesqPict("SE2","E2_VENCTO"), TamSX3("E2_VENCTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]-6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "E2_CCD", "", "C. Custo", PesqPict("SE2","E2_CCD"), TamSX3("E2_CCD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection3, "CTT_DESC01", "", "C. Custo", PesqPict("CTT","CTT_DESC01"), TamSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSection4 := TRSection():New(oReport, "INC MANUAL FINANCEIRO")
    TRCell():New(oSection4, "F1_DTDIGIT", "", RetTitle("F1_DTDIGIT"), PesqPict("SF1","F1_DTDIGIT"), TamSX3("F1_DTDIGIT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_VENCTO", "", RetTitle("E2_VENCTO"), PesqPict("SE2","E2_VENCTO"), TamSX3("E2_VENCTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]-6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "E2_CCD", "", "C. Custo", PesqPict("SE2","E2_CCD"), TamSX3("E2_CCD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection4, "CTT_DESC01", "", "C. Custo", PesqPict("CTT","CTT_DESC01"), TamSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSection5 := TRSection():New(oReport, "DP INTEGRACAO FIN")
    TRCell():New(oSection5, "F1_DTDIGIT", "", RetTitle("F1_DTDIGIT"), PesqPict("SF1","F1_DTDIGIT"), TamSX3("F1_DTDIGIT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_EMISSAO", "", RetTitle("E2_EMISSAO"), PesqPict("SE2","E2_EMISSAO"), TamSX3("E2_EMISSAO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_VENCTO", "", RetTitle("E2_VENCTO"), PesqPict("SE2","E2_VENCTO"), TamSX3("E2_VENCTO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection5, "E2_FORNECE", "", RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE"), TamSX3("E2_FORNECE")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_LOJA", "", RetTitle("E2_LOJA"), PesqPict("SE2","E2_LOJA"), TamSX3("E2_LOJA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection5, "A2_NOME", "", "Razão Social", PesqPict("SA2","A2_NOME"), TamSX3("A2_NOME")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection5, "E2_PREFIXO", "", RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO"), TamSX3("E2_PREFIXO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection5, "E2_NUM", "", RetTitle("E2_NUM"), PesqPict("SE2","E2_NUM"), TamSX3("E2_NUM")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_PARCELA", "", RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1]-6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_VALOR", "", RetTitle("E2_VALOR"), PesqPict("SE2","E2_VALOR"), TamSX3("E2_VALOR")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_NATUREZ", "", RetTitle("E2_NATUREZ"), PesqPict("SE2","E2_NATUREZ"), TamSX3("E2_NATUREZ")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection5, "ED_DESCRIC", "", "Desc. Naturez", PesqPict("SED","ED_DESCRIC"), TamSX3("ED_DESCRIC")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "E2_CCD", "", "C. Custo", PesqPict("SE2","E2_CCD"), TamSX3("E2_CCD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5, "CTT_DESC01", "", "C. Custo", PesqPict("CTT","CTT_DESC01"), TamSX3("CTT_DESC01")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRFunction():New(oSection1:Cell("E2_VALOR"),, "SUM",,"Total Doc Sem PC",PesqPict("SE2","E2_VALOR"),,.T.,.T.,.F.,oSection1)
    TRFunction():New(oSection2:Cell("E2_VALOR"),, "SUM",,"Total Doc Cond Pag Dif PC",PesqPict("SE2","E2_VALOR"),,.T.,.T.,.F.,oSection2)
    TRFunction():New(oSection3:Cell("E2_VALOR"),, "SUM",,"Total Pedidos Compra",PesqPict("SE2","E2_VALOR"),,.T.,.T.,.F.,oSection3)
    TRFunction():New(oSection4:Cell("E2_VALOR"),, "SUM",,"Total Inc. Manual Financeiro",PesqPict("SE2","E2_VALOR"),,.T.,.T.,.F.,oSection4)
    TRFunction():New(oSection5:Cell("E2_VALOR"),, "SUM",,"Total DP Integraçao FIN",PesqPict("SE2","E2_VALOR"),,.T.,.T.,.F.,oSection5)

Return oReport

/*/{Protheus.doc} ReportDef

PrintReport

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    Local oSection3 := oReport:Section(3)
    Local oSection4 := oReport:Section(4)
    Local oSection5 := oReport:Section(5)
	Local cQry
    Local nQtReg    := 0
    Local nMeter    := 5
    Local aTitulos  := {}
    Local aTitulos2 := {}
    Local nI        := 0

    oReport:SetMeter(nMeter)

    //------------------------------------------------//
    //-- Seção 1 - Documentos sem pedidos de compra --//
    //------------------------------------------------//
    nQtReg := QRYSEC1()
    If nQtReg > 0

        oSection1:Init()
        oReport:IncMeter()
        While TMPSEC1->(!EOF())
            If oReport:Cancel()
                Exit
            EndIf

            oSection1:Cell("F1_DTDIGIT"):SetValue(STOD(TMPSEC1->F1_DTDIGIT))
            oSection1:Cell("E2_EMISSAO"):SetValue(STOD(TMPSEC1->E2_EMISSAO))
            oSection1:Cell("E2_VENCTO"):SetValue(STOD(TMPSEC1->E2_VENCTO))
            oSection1:Cell("E2_FORNECE"):SetValue(TMPSEC1->E2_FORNECE)
            oSection1:Cell("E2_LOJA"):SetValue(TMPSEC1->E2_LOJA)
            oSection1:Cell("A2_NOME"):SetValue( Posicione("SA2",1,xFilial("SA2")+TMPSEC1->E2_FORNECE+TMPSEC1->E2_LOJA, "A2_NOME") )
            oSection1:Cell("E2_PREFIXO"):SetValue(TMPSEC1->E2_PREFIXO)
            oSection1:Cell("E2_NUM"):SetValue(TMPSEC1->E2_NUM)
            oSection1:Cell("E2_PARCELA"):SetValue(TMPSEC1->E2_PARCELA)
            oSection1:Cell("E2_VALOR"):SetValue(TMPSEC1->E2_VALOR)
            oSection1:Cell("E2_NATUREZ"):SetValue(TMPSEC1->E2_NATUREZ)
            oSection1:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMPSEC1->E2_NATUREZ, "ED_DESCRIC") )
            oSection1:Cell("E2_CCD"):SetValue(TMPSEC1->E2_CCD)
            oSection1:Cell("CTT_DESC01"):SetValue( Posicione("CTT",1,xFilial("CTT")+TMPSEC1->E2_CCD, "CTT_DESC01") )

            oSection1:PrintLine()

            TMPSEC1->(dbSkip())
        EndDo

        oSection1:Finish()
        TMPSEC1->(DbCloseArea())
        nQtReg := 0
    Else
        TMPSEC1->(DbCloseArea())
    EndIf

    //----------------------------------------------------------------------//
    //-- Seção 2 - Documentos c/ cond. pag. diferente do pedido de compra --//
    //----------------------------------------------------------------------//
    aTitulos2 := QRYSEC2()
    If Len(aTitulos2) > 0

        oSection2:Init()
        oReport:IncMeter()
        For nI := 1 To Len(aTitulos2)
            If oReport:Cancel()
                Exit
            EndIf

            oSection2:Cell("F1_DTDIGIT"):SetValue(aTitulos2[nI][1])
            oSection2:Cell("E2_EMISSAO"):SetValue(aTitulos2[nI][2])
            oSection2:Cell("E2_VENCTO"):SetValue(aTitulos2[nI][3])
            oSection2:Cell("E2_FORNECE"):SetValue(aTitulos2[nI][4])
            oSection2:Cell("E2_LOJA"):SetValue(aTitulos2[nI][5])
            oSection2:Cell("A2_NOME"):SetValue(aTitulos2[nI][6])
            oSection2:Cell("E2_PREFIXO"):SetValue(aTitulos2[nI][7])
            oSection2:Cell("E2_NUM"):SetValue(aTitulos2[nI][8])
            oSection2:Cell("E2_PARCELA"):SetValue(aTitulos2[nI][9])
            oSection2:Cell("E2_VALOR"):SetValue(aTitulos2[nI][10])
            oSection2:Cell("E2_NATUREZ"):SetValue(aTitulos2[nI][11])
            oSection2:Cell("ED_DESCRIC"):SetValue(aTitulos2[nI][12])
            oSection2:Cell("E2_CCD"):SetValue(aTitulos2[nI][13])
            oSection2:Cell("CTT_DESC01"):SetValue(aTitulos2[nI][14])

            oSection2:PrintLine()

        Next nI

        oSection2:Finish()
    EndIf

    //---------------------------------//
    //-- Seção 3 - Pedidos de Compra --//
    //---------------------------------//
    aTitulos := QRYSEC3()
    If Len(aTitulos) > 0

        oSection3:Init()
        oReport:IncMeter()

        For nI := 1 To Len(aTitulos)

            If oReport:Cancel()
                Exit
            EndIf

            oSection3:Cell("F1_DTDIGIT"):SetValue(aTitulos[nI][1])
            oSection3:Cell("E2_EMISSAO"):SetValue(aTitulos[nI][2])
            oSection3:Cell("E2_VENCTO"):SetValue(aTitulos[nI][3])
            oSection3:Cell("E2_FORNECE"):SetValue(aTitulos[nI][4])
            oSection3:Cell("E2_LOJA"):SetValue(aTitulos[nI][5])
            oSection3:Cell("A2_NOME"):SetValue(aTitulos[nI][6])
            oSection3:Cell("E2_PREFIXO"):SetValue(aTitulos[nI][7])
            oSection3:Cell("E2_NUM"):SetValue(aTitulos[nI][8])
            oSection3:Cell("E2_PARCELA"):SetValue(aTitulos[nI][9])
            oSection3:Cell("E2_VALOR"):SetValue(aTitulos[nI][10])
            oSection3:Cell("E2_NATUREZ"):SetValue(aTitulos[nI][11])
            oSection3:Cell("ED_DESCRIC"):SetValue(aTitulos[nI][12])
            oSection3:Cell("E2_CCD"):SetValue(aTitulos[nI][13])
            oSection3:Cell("CTT_DESC01"):SetValue(aTitulos[nI][14])

            oSection3:PrintLine()

        Next nI

        oSection3:Finish()
    EndIf

    //------------------------------------------------//
    //-- Seção 4 - Inclusão Manual Financeiro Pagar --//
    //------------------------------------------------//
    nQtReg := QRYSEC4()
    If nQtReg > 0

        oSection4:Init()
        oReport:IncMeter()
        While TMPSEC4->(!EOF())
            If oReport:Cancel()
                Exit
            EndIf

            oSection4:Cell("F1_DTDIGIT"):SetValue(STOD(TMPSEC4->E2_EMISSAO))
            oSection4:Cell("E2_EMISSAO"):SetValue(STOD(TMPSEC4->E2_EMISSAO))
            oSection4:Cell("E2_VENCTO"):SetValue(STOD(TMPSEC4->E2_VENCTO))
            oSection4:Cell("E2_FORNECE"):SetValue(TMPSEC4->E2_FORNECE)
            oSection4:Cell("E2_LOJA"):SetValue(TMPSEC4->E2_LOJA)
            oSection4:Cell("A2_NOME"):SetValue( Posicione("SA2",1,xFilial("SA2")+TMPSEC4->E2_FORNECE+TMPSEC4->E2_LOJA, "A2_NOME") )
            oSection4:Cell("E2_PREFIXO"):SetValue(TMPSEC4->E2_PREFIXO)
            oSection4:Cell("E2_NUM"):SetValue(TMPSEC4->E2_NUM)
            oSection4:Cell("E2_PARCELA"):SetValue(TMPSEC4->E2_PARCELA)
            oSection4:Cell("E2_VALOR"):SetValue(TMPSEC4->E2_VALOR)
            oSection4:Cell("E2_NATUREZ"):SetValue(TMPSEC4->E2_NATUREZ)
            oSection4:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMPSEC4->E2_NATUREZ, "ED_DESCRIC") )
            oSection4:Cell("E2_CCD"):SetValue(TMPSEC4->E2_CCD)
            oSection4:Cell("CTT_DESC01"):SetValue( Posicione("CTT",1,xFilial("CTT")+TMPSEC4->E2_CCD, "CTT_DESC01") )

            oSection4:PrintLine()

            TMPSEC4->(dbSkip())
        EndDo

        oSection4:Finish()
        TMPSEC4->(DbCloseArea())
        nQtReg := 0
    Else
        TMPSEC4->(DbCloseArea())
    EndIf

    //-------------------------------------------//
    //-- Seção 5 - Folha de Pagamento DP x FIN --//
    //-------------------------------------------//
    nQtReg := QRYSEC5()
    If nQtReg > 0

        oSection5:Init()
        oReport:IncMeter()
        While TMPSEC5->(!EOF())
            If oReport:Cancel()
                Exit
            EndIf

            oSection5:Cell("F1_DTDIGIT"):SetValue(STOD(TMPSEC5->E2_EMISSAO))
            oSection5:Cell("E2_EMISSAO"):SetValue(STOD(TMPSEC5->E2_EMISSAO))
            oSection5:Cell("E2_VENCTO"):SetValue(STOD(TMPSEC5->E2_VENCTO))
            oSection5:Cell("E2_FORNECE"):SetValue(TMPSEC5->E2_FORNECE)
            oSection5:Cell("E2_LOJA"):SetValue(TMPSEC5->E2_LOJA)
            oSection5:Cell("A2_NOME"):SetValue( Posicione("SA2",1,xFilial("SA2")+TMPSEC5->E2_FORNECE+TMPSEC5->E2_LOJA, "A2_NOME") )
            oSection5:Cell("E2_PREFIXO"):SetValue(TMPSEC5->E2_PREFIXO)
            oSection5:Cell("E2_NUM"):SetValue(TMPSEC5->E2_NUM)
            oSection5:Cell("E2_PARCELA"):SetValue(TMPSEC5->E2_PARCELA)
            oSection5:Cell("E2_VALOR"):SetValue(TMPSEC5->E2_VALOR)
            oSection5:Cell("E2_NATUREZ"):SetValue(TMPSEC5->E2_NATUREZ)
            oSection5:Cell("ED_DESCRIC"):SetValue( Posicione("SED",1,xFilial("SED")+TMPSEC5->E2_NATUREZ, "ED_DESCRIC") )
            oSection5:Cell("E2_CCD"):SetValue(TMPSEC5->E2_CCD)
            oSection5:Cell("CTT_DESC01"):SetValue( Posicione("CTT",1,xFilial("CTT")+TMPSEC5->E2_CCD, "CTT_DESC01") )

            oSection5:PrintLine()

            TMPSEC5->(dbSkip())
        EndDo

        oSection5:Finish()
        TMPSEC5->(DbCloseArea())
        nQtReg := 0
    Else
        TMPSEC5->(DbCloseArea())
    EndIf

	MS_FLUSH()

Return

/*/{Protheus.doc} QRYSEC1

Dados Seção 1

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function QRYSEC1()
    Local cQry   := ""
    Local nQtReg := 0

    cQry := "SELECT DISTINCT SF1.F1_DTDIGIT, " + CRLF
    cQry += "                SE2.E2_EMISSAO, " + CRLF
    cQry += "                SE2.E2_PREFIXO, " + CRLF
    cQry += "                SE2.E2_NUM,  " + CRLF
    cQry += "                SE2.E2_PARCELA,  " + CRLF
    cQry += "                SE2.E2_VALOR,  " + CRLF
    cQry += "                SE2.E2_VENCTO,  " + CRLF
    cQry += "                SE2.E2_NATUREZ,  " + CRLF
    cQry += "                SE2.E2_CCD,  " + CRLF
    cQry += "                SE2.E2_FORNECE,  " + CRLF
    cQry += "                SE2.E2_LOJA " + CRLF
    cQry += "FROM "+ RetSqlName("SF1") +" SF1 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SD1") +" SD1 " + CRLF
    cQry += "    ON SD1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD1.D1_FILIAL = '"+ xFilial("SD1") +"' " + CRLF
    cQry += "    AND SD1.D1_DOC = SF1.F1_DOC " + CRLF
    cQry += "    AND SD1.D1_SERIE = SF1.F1_SERIE " + CRLF
    cQry += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE " + CRLF
    cQry += "    AND SD1.D1_LOJA = SF1.F1_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SE2") +" SE2 " + CRLF
    cQry += "    ON SE2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE2.E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "    AND SE2.E2_NUM = SF1.F1_DOC " + CRLF
    cQry += "    AND SE2.E2_FORNECE = SF1.F1_FORNECE " + CRLF
    cQry += "    AND SE2.E2_LOJA = SF1.F1_LOJA " + CRLF
    cQry += "WHERE SF1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF1.F1_FILIAL = '"+ xFilial("SF1") +"' " + CRLF
    cQry += "    AND SF1.F1_TIPO = 'N' " + CRLF
    cQry += "    AND SF1.F1_EMISSAO > '"+ DTOS(SZR->ZR_DATFECH) +"' " + CRLF
    cQry += "    AND SF1.F1_EMISSAO <= '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "    AND SE2.E2_VENCTO BETWEEN '"+ DTOS(SZR->ZR_DATINI) +"' AND '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "    AND SD1.D1_PEDIDO = ' ' " + CRLF
    cQry += "ORDER BY SE2.E2_EMISSAO, SE2.E2_NUM " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSEC1") > 0
		TMPSEC1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSEC1"

	TMPSEC1->(dbGoTop())
    COUNT TO nQtReg
    TMPSEC1->(dbGoTop())

Return nQtReg

/*/{Protheus.doc} QRYSEC2

Dados Seção 2

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function QRYSEC2()
    Local cQry     := ""
    Local nQtReg   := 0
    Local aAreaSE4 := SE4->( GetArea() )
    Local aParcela := {}
    Local aSE4     := {}
    Local nValPed  := 0
    Local nValNf   := 0
    Local nX       := 0
    Local nI       := 0
    Local aTitulos := {}
    Local aDados   := {}

    cQry := "SELECT DISTINCT SF1.F1_EMISSAO, " + CRLF
    cQry += "                SF1.F1_DOC, " + CRLF
    cQry += "                SF1.F1_FORNECE, " + CRLF
    cQry += "                SF1.F1_LOJA, " + CRLF
    cQry += "                SF1.F1_VALBRUT, " + CRLF
    cQry += "                SF1.F1_COND, " + CRLF
    cQry += "                SC7.C7_COND " + CRLF
    cQry += "FROM "+ RetSqlName("SF1") +" SF1 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SD1") +" SD1 " + CRLF
    cQry += "    ON SD1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD1.D1_FILIAL = '"+ xFilial("SD1") +"' " + CRLF
    cQry += "    AND SD1.D1_DOC = SF1.F1_DOC " + CRLF
    cQry += "    AND SD1.D1_SERIE = SF1.F1_SERIE " + CRLF
    cQry += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE " + CRLF
    cQry += "    AND SD1.D1_LOJA = SF1.F1_LOJA " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SC7") +" SC7 " + CRLF
    cQry += "    ON SC7.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC7.C7_FILIAL = '"+ xFilial("SC7") +"' " + CRLF
    cQry += "    AND SC7.C7_NUM = SD1.D1_PEDIDO " + CRLF
    cQry += "    AND SC7.C7_FORNECE = SD1.D1_FORNECE " + CRLF
    cQry += "    AND SC7.C7_LOJA = SD1.D1_LOJA " + CRLF
    cQry += "    AND SC7.C7_PRODUTO = SD1.D1_COD " + CRLF
    cQry += "WHERE SF1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF1.F1_FILIAL = '"+ xFilial("SF1") +"' " + CRLF
    cQry += "    AND SF1.F1_TIPO = 'N' " + CRLF
    cQry += "    AND SF1.F1_EMISSAO > '"+ DTOS(SZR->ZR_DATFECH) +"' " + CRLF
    cQry += "    AND SF1.F1_EMISSAO <= '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "    AND SD1.D1_PEDIDO <> ' ' " + CRLF
    cQry += "    AND SC7.C7_COND <> SF1.F1_COND " + CRLF
    cQry += "ORDER BY SF1.F1_EMISSAO, SF1.F1_DOC " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSEC2") > 0
		TMPSEC2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSEC2"

	TMPSEC2->(dbGoTop())
    COUNT TO nQtReg
    TMPSEC2->(dbGoTop())

    If nQtReg > 0
        While TMPSEC2->( !EOF() )

            dbSelectArea("SE4")
            SE4->(dbSetOrder(1))
            If SE4->(dbSeek(xFilial("SE4") + TMPSEC2->C7_COND))
                aSE4 := {SE4->E4_CODIGO, SE4->E4_COND, SE4->E4_TIPO,;
                            SE4->E4_DDD, SE4->E4_IPI, SE4->E4_SOLID}
            EndIf

            aParcela := Condicao(TMPSEC2->F1_VALBRUT, TMPSEC2->C7_COND,, STOD(TMPSEC2->F1_EMISSAO),,,aSE4,)

            For nX := 1 To Len(aParcela)
                If aParcela[nX,1] >= SZR->ZR_DATINI .And. aParcela[nX,1] <= SZR->ZR_DATFIM
                    nValPed += aParcela[nX,2] //-- Valor total dos títulos no período
                EndIf
            Next nX

            dbSelectArea("SE4")
            SE4->(dbSetOrder(1))
            If SE4->(dbSeek(xFilial("SE4") + TMPSEC2->F1_COND))
                aSE4 := {SE4->E4_CODIGO, SE4->E4_COND, SE4->E4_TIPO,;
                            SE4->E4_DDD, SE4->E4_IPI, SE4->E4_SOLID}
            EndIf

            aParcela := Condicao(TMPSEC2->F1_VALBRUT, TMPSEC2->F1_COND,, STOD(TMPSEC2->F1_EMISSAO),,,aSE4,)

            For nX := 1 To Len(aParcela)
                If aParcela[nX,1] >= SZR->ZR_DATINI .And. aParcela[nX,1] <= SZR->ZR_DATFIM
                    nValNf += aParcela[nX,2] //-- Valor total dos títulos no período
                EndIf
            Next nX

            //-------------------------------------------------------------------------------//
            //-- Avalia se o valor, baseado na condição de pagamento do pedido, no período --//
            //-- é diferente do valor, baseado na condição de pagamento da NF.             --//
            //-------------------------------------------------------------------------------//
            If nValPed <> nValNf
                aDados := RetTit(TMPSEC2->F1_DOC, TMPSEC2->F1_FORNECE, TMPSEC2->F1_LOJA)
                If Len(aDados) > 0
                    For nI := 1 To Len(aDados)
                        AADD(aTitulos, aDados[nI])
                    Next nI
                EndIf
            EndIf

            nValPed := nValNf := 0

            TMPSEC2->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaSE4)
    TMPSEC2->(DbCloseArea())

Return aTitulos

/*/{Protheus.doc} QRYSEC3

Dados Seção 3

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function QRYSEC3()
    Local cQry     := ""
    Local nQtReg   := 0
    Local aAreaSE4 := SE4->( GetArea() )
    Local aSE4     := {}
    Local aParcela := {}
    Local aTitulos := {}
    Local nX       := 0
    Local cNaturez := ""

    cQry := "SELECT DISTINCT SC7.C7_EMISSAO, " + CRLF
    cQry += "    SC7.C7_XDTCX, " + CRLF
    cQry += "    SC7.C7_NUM, " + CRLF
    cQry += "    SC7.C7_PRECO, " + CRLF
    cQry += "    SC7.C7_COND, " + CRLF
    cQry += "    SC7.C7_FORNECE, " + CRLF
    cQry += "    SC7.C7_LOJA, " + CRLF
    cQry += "    SC7.C7_CC " + CRLF
    cQry += "FROM "+ RetSqlName("SC7") +" SC7 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SCR") +" SCR " + CRLF
    //-- Considera alçadas de liberação deletadas
    // cQry += "    ON SCR.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    ON SCR.CR_FILIAL = '"+ xFilial("SCR") +"' " + CRLF
    cQry += "    AND SCR.CR_NUM = SC7.C7_NUM " + CRLF
    cQry += "WHERE SC7.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC7.C7_FILIAL = '"+ xFilial("SC7") +"' " + CRLF
    cQry += "    AND SC7.C7_CONAPRO = 'L' " + CRLF
    cQry += "    AND SC7.C7_FLUXO = 'S' " + CRLF
    cQry += "    AND CR_DATALIB  > '"+ DTOS(SZR->ZR_DATFECH) +"' " + CRLF
    cQry += "    AND CR_DATALIB <= '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "ORDER BY SC7.C7_EMISSAO, SC7.C7_XDTCX, SC7.C7_NUM " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSEC3") > 0
		TMPSEC3->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSEC3"

	TMPSEC3->(dbGoTop())
    COUNT TO nQtReg
    TMPSEC3->(dbGoTop())

    If nQtReg > 0
        While TMPSEC3->( !EOF() )
            
            dbSelectArea("SE4")
            SE4->(dbSetOrder(1))
            If SE4->(dbSeek(xFilial("SE4") + TMPSEC3->C7_COND))
                aSE4 := {SE4->E4_CODIGO, SE4->E4_COND, SE4->E4_TIPO,;
                            SE4->E4_DDD, SE4->E4_IPI, SE4->E4_SOLID}
            EndIf
            
            aParcela := Condicao(TMPSEC3->C7_PRECO, TMPSEC3->C7_COND,, STOD(TMPSEC3->C7_XDTCX),,,aSE4,)

            //-- Para debug e análise de títutlos --//
            // If AllTrim(TMPSEC3->C7_NUM) == "030264"
            //     For nX := 1 To Len(aParcela)
            //         MsgInfo( "Parcela " + cValToChar(nX) + " -> " + DTOC(aParcela[nX,1]) + " " + cValToChar(aParcela[nX,2]) )
            //     Next nX
            // EndIf

            For nX := 1 To Len(aParcela)
                If aParcela[nX,1] >= SZR->ZR_DATINI .And. aParcela[nX,1] <= SZR->ZR_DATFIM
                    cNaturez := Posicione("SA2",1,xfilial("SA2")+TMPSEC3->C7_FORNECE+TMPSEC3->C7_LOJA,"A2_NATUREZ")
                    AADD(aTitulos,;
                            {STOD(TMPSEC3->C7_EMISSAO),; //-- Digitação
                            STOD(TMPSEC3->C7_XDTCX),; //-- Emissão
                            aParcela[nX,1],; //-- Vencimento
                            TMPSEC3->C7_FORNECE,; //-- Cod. Fornecedor
                            TMPSEC3->C7_LOJA,; //-- Loja
                            Posicione("SA2",1,xFilial("SA2")+TMPSEC3->C7_FORNECE+TMPSEC3->C7_LOJA, "A2_NOME"),; //N Fantasia
                            "",; // Prefixo
                            PadL(TMPSEC3->C7_NUM,9,"0"),; //-- Num. Título
                            StrZero(nX,2),; //-- Parcela
                            aParcela[nX,2],; //-- Valor
                            cNaturez,; //-- Natureza
                            Posicione("SED",1,xFilial("SED")+cNaturez, "ED_DESCRIC"),; //-- Desc. Nat.
                            TMPSEC3->C7_CC,; //-- CC
                            Posicione("CTT",1,xFilial("CTT")+TMPSEC3->C7_CC, "CTT_DESC01")}) //-- Desc CC
                EndIf
            Next nX

            TMPSEC3->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaSE4)
    TMPSEC3->(DbCloseArea())

Return aTitulos

/*/{Protheus.doc} QRYSEC4

Dados Seção 4

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function QRYSEC4()
    Local cQry   := ""
    Local nQtReg := 0

    cQry := "SELECT SE2.E2_EMISSAO, " + CRLF
    cQry += "    SE2.E2_PREFIXO, " + CRLF
    cQry += "    SE2.E2_NUM,  " + CRLF
    cQry += "    SE2.E2_PARCELA,  " + CRLF
    cQry += "    SE2.E2_VALOR,  " + CRLF
    cQry += "    SE2.E2_VENCTO,  " + CRLF
    cQry += "    SE2.E2_NATUREZ,  " + CRLF
    cQry += "    SE2.E2_CCD,  " + CRLF
    cQry += "    SE2.E2_FORNECE,  " + CRLF
    cQry += "    SE2.E2_LOJA " + CRLF
    cQry += "FROM "+ RetSqlName("SE2") +" SE2 " + CRLF
    cQry += "WHERE SE2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE2.E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "    AND SE2.E2_ORIGEM = 'FINA050' " + CRLF
    cQry += "    AND SE2.E2_EMISSAO > '"+ DTOS(SZR->ZR_DATFECH) +"' " + CRLF
    cQry += "    AND SE2.E2_EMISSAO <= '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "    AND SE2.E2_VENCTO BETWEEN '"+ DTOS(SZR->ZR_DATINI) +"' AND '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSEC4") > 0
		TMPSEC4->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSEC4"

	TMPSEC4->(dbGoTop())
    COUNT TO nQtReg
    TMPSEC4->(dbGoTop())

Return nQtReg

/*/{Protheus.doc} QRYSEC5

Dados Seção 5

@author Marcos Natã Santos
@since 23/08/2018
@version 12.1.17
@type function
/*/
Static Function QRYSEC5()
    Local cQry   := ""
    Local nQtReg := 0

    cQry := "SELECT SE2.E2_EMISSAO, " + CRLF
    cQry += "    SE2.E2_PREFIXO, " + CRLF
    cQry += "    SE2.E2_NUM,  " + CRLF
    cQry += "    SE2.E2_PARCELA,  " + CRLF
    cQry += "    SE2.E2_VALOR,  " + CRLF
    cQry += "    SE2.E2_VENCTO,  " + CRLF
    cQry += "    SE2.E2_NATUREZ,  " + CRLF
    cQry += "    SE2.E2_CCD,  " + CRLF
    cQry += "    SE2.E2_FORNECE,  " + CRLF
    cQry += "    SE2.E2_LOJA " + CRLF
    cQry += "FROM "+ RetSqlName("SE2") +" SE2 " + CRLF
    cQry += "WHERE SE2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE2.E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "    AND SE2.E2_PREFIXO = 'GPE' " + CRLF
    cQry += "    AND SE2.E2_ORIGEM = 'GPEM670' " + CRLF
    cQry += "    AND SE2.E2_EMISSAO > '"+ DTOS(SZR->ZR_DATFECH) +"' " + CRLF
    cQry += "    AND SE2.E2_EMISSAO <= '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry += "    AND SE2.E2_VENCTO BETWEEN '"+ DTOS(SZR->ZR_DATINI) +"' AND '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSEC5") > 0
		TMPSEC5->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSEC5"

	TMPSEC5->(dbGoTop())
    COUNT TO nQtReg
    TMPSEC5->(dbGoTop())

Return nQtReg

/*/{Protheus.doc} RetTit

Retorna dados do título a pagar

@author Marcos Natã Santos
@since 29/08/2018
@version 12.1.17
@type function
/*/
Static Function RetTit(cNum,cFornece,cLoja)
    Local cQry
    Local nQtReg
    Local aTitulos := {}

    cQry := "SELECT E2_EMISSAO, " + CRLF
    cQry += "    E2_PREFIXO, " + CRLF
    cQry += "    E2_NUM, " + CRLF
    cQry += "    E2_PARCELA, " + CRLF
    cQry += "    E2_VALOR, " + CRLF
    cQry += "    E2_VENCTO, " + CRLF
    cQry += "    E2_NATUREZ, " + CRLF
    cQry += "    E2_CCD, " + CRLF
    cQry += "    E2_FORNECE, " + CRLF
    cQry += "    E2_LOJA " + CRLF
    cQry += "FROM "+ RetSqlName("SE2") +" " + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND E2_FILIAL = '"+ xFilial("SE2") +"' " + CRLF
    cQry += "AND E2_NUM = '"+ cNum +"' " + CRLF
    cQry += "AND E2_FORNECE = '"+ cFornece +"' " + CRLF
    cQry += "AND E2_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "AND E2_VENCTO BETWEEN '"+ DTOS(SZR->ZR_DATINI) +"' AND '"+ DTOS(SZR->ZR_DATFIM) +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSE2") > 0
		TMPSE2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSE2"

	TMPSE2->(dbGoTop())
    COUNT TO nQtReg
    TMPSE2->(dbGoTop())

    If nQtReg > 0
        While TMPSE2->( !EOF() )

            AADD(aTitulos, {;
            STOD(TMPSE2->E2_EMISSAO),;
            STOD(TMPSE2->E2_EMISSAO),;
            STOD(TMPSE2->E2_VENCTO),;
            TMPSE2->E2_FORNECE,;
            TMPSE2->E2_LOJA,;
            Posicione("SA2",1,xFilial("SA2")+TMPSE2->E2_FORNECE+TMPSE2->E2_LOJA, "A2_NOME"),;
            TMPSE2->E2_PREFIXO,;
            TMPSE2->E2_NUM,;
            TMPSE2->E2_PARCELA,;
            TMPSE2->E2_VALOR,;
            TMPSE2->E2_NATUREZ,;
            Posicione("SED",1,xFilial("SED")+TMPSE2->E2_NATUREZ, "ED_DESCRIC"),;
            TMPSE2->E2_CCD,;
            Posicione("CTT",1,xFilial("CTT")+TMPSE2->E2_CCD, "CTT_DESC01")})

            TMPSE2->( dbSkip() )
        EndDo
    EndIf

Return aTitulos
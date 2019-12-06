#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} FUPSUP
Follow Up Suprimentos
@type User Function
@author Marcos Natã Santos
@since 23/08/2019
@version 1.0
@param cNumPedComp, char
/*/
User Function FUPSUP(cNumPedComp) //-- U_FUPSUP("029536")
    Local oProcess    := Nil
    Local oHtml       := Nil
    Local cID         := ""
    Local cLink       := ""
    Local cWFWS       := GetMv("MV_WFWS")

    Default cNumPedComp := ""

    oProcess := TWFProcess():New("FUP", "Follow Up Suprimentos")
    oProcess:NewTask("Follow Up Suprimentos", "/workflow/fup/layouts/fup01.htm")

    oHtml := oProcess:oHTML

    //-------------------------//
    //-- Cabeçalho do Pedido --//
    //-------------------------//
    PedCab(@oHtml, cNumPedComp)

    //---------------------//
    //-- Itens do Pedido --//
    //---------------------//
    PedItens(@oHtml, cNumPedComp)

    //---------------------//
    //-- Dados do Pedido --//
    //---------------------//
    PedDados(@oHtml, cNumPedComp)

    oProcess:cSubject := "Follow Up Suprimentos"
    oProcess:cTo      := "fup"
    oProcess:bReturn  := "U_FUPRET()"
    oProcess:bTimeOut := { {"U_FUPTMOUT()", 15, 0, 0} }

    //-- Inicia o processo e obtem o ID do processo --//
    cID := oProcess:Start("\workflow\messenger\emp" + cEmpAnt + "\fup")
    cLink := cWFWS + "/messenger/emp01/fup/"+ cID +".htm"

    //-- Grava ID do processo no pedido de compra --//
    GrvProcess(cNumPedComp, cID)

Return cLink

/*/{Protheus.doc} PedCab
Cabeçalho do pedido de compra
@type Static Function
@author Marcos Natã Santos
@since 16/09/2019
@version 1.0
@param oHtml, object
@param cNumPedComp, char
/*/
Static Function PedCab(oHtml, cNumPedComp)
    Local cFornece    := ""
    Local cLoja       := ""
    Local cContato    := ""
    Local cFornecedor := ""
    Local cEndereco   := ""
    Local cBairro     := ""
    Local cMunicipio  := ""
    Local cFornTel    := ""

    If !Empty(cNumPedComp)
        cFornece := POSICIONE("SC7", 1, xFilial("SC7") + cNumPedComp, "C7_FORNECE")
        cLoja := POSICIONE("SC7", 1, xFilial("SC7") + cNumPedComp, "C7_LOJA")
        cContato := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_CONTATO"))
        cFornecedor := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_NREDUZ"))
        cEndereco := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_END"))
        cBairro := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_BAIRRO"))
        cMunicipio := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_MUN"))
        cFornTel := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_TEL"))
        cFornFax := AllTrim(POSICIONE("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_FAX"))

        oHtml:ValByName("FUPWFP12", "WFHTTPRET.APL")
        oHtml:ValByName("cNumPedComp", cNumPedComp)
        oHtml:ValByName("cContato", cContato)
        oHtml:ValByName("cFornecedor", cFornecedor)
        oHtml:ValByName("cEndereco", cEndereco)
        oHtml:ValByName("cBairro", cBairro)
        oHtml:ValByName("cMunicipio", cMunicipio)
        oHtml:ValByName("cFornTel", cFornTel)
        oHtml:ValByName("cFornFax", cFornFax)
    EndIf
Return

/*/{Protheus.doc} PedItens
Itens do pedido de compra
@type Static Function
@author Marcos Natã Santos
@since 16/09/2019
@version 1.0
@param oHtml, object
@param cNumPedComp, char
/*/
Static Function PedItens(oHtml, cNumPedComp)
    Local aAreaSC7 := SC7->( GetArea() )
    Local xLinkes := ""
    Local xlinkar := ""

    SC7->( dbSetOrder(1) )
    If SC7->(dbSeek(xFilial("SC7")+cNumPedComp))
        While SC7->( !EOF() ) .And. AllTrim(SC7->C7_NUM) == AllTrim(cNumPedComp)

            xLinkes := xlinkar := ""
            xLinkes := AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "b1_xlinkes"))
            xlinkar := AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "b1_xlinkar"))

            aAdd((oHtml:ValByName("it.item")), SC7->C7_ITEM)
            aAdd((oHtml:ValByName("it.produto")), SC7->C7_PRODUTO)
            aAdd((oHtml:ValByName("it.descricao")), SC7->C7_DESCRI)
            aAdd((oHtml:ValByName("it.unidade")), SC7->C7_UM)
            aAdd((oHtml:ValByName("it.quantidade")), cValToChar(SC7->C7_QUANT))
            aAdd((oHtml:ValByName("it.valor")), ValToCurrency(SC7->C7_PRECO))
            aAdd((oHtml:ValByName("it.total")), ValToCurrency(SC7->C7_TOTAL))
            aAdd((oHtml:ValByName("it.linkar")), IIF(Empty(xlinkar), "N/A", "<a href="+ xlinkar +">Baixar</a>"))
            aAdd((oHtml:ValByName("it.linkes")), IIF(Empty(xLinkes), "N/A", "<a href="+ xLinkes +">Baixar</a>"))
            aAdd((oHtml:ValByName("it.aPosicProd")), {"","Em Produção","Em Estoque"})
            aAdd((oHtml:ValByName("it.dtfat")), DTOC(STOD(Space(8))))

            SC7->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaSC7)
Return

/*/{Protheus.doc} PedDados
Dados do pedido de compra
@type Static Function
@author Marcos Natã Santos
@since 16/09/2019
@version 1.0
@param oHtml, object
@param cNumPedComp, char
/*/
Static Function PedDados(oHtml, cNumPedComp)
    Local aValores := TotPedCp(cNumPedComp)

    //-- Local de Entrega --//
    oHtml:ValByName("cNomeEmp", AllTrim(SM0->M0_NOME))
    oHtml:ValByName("cEndEnt1", AllTrim(SM0->M0_ENDENT))
    oHtml:ValByName("cEndEnt2", AllTrim(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT + " - " + AllTrim(SM0->M0_CEPENT))

    //-- Totalizadores --//
    oHtml:ValByName("cValMerc", ValToCurrency( aValores[1] ))
    oHtml:ValByName("cFrete", ValToCurrency( aValores[2] ))
    oHtml:ValByName("cDescontos", ValToCurrency( aValores[3] ))
    oHtml:ValByName("cDespesas", ValToCurrency( aValores[4] ))
    oHtml:ValByName("cSeguro", ValToCurrency( aValores[5] ))
    oHtml:ValByName("cTotalPed", ValToCurrency( aValores[1] ))
Return

/*/{Protheus.doc} ValToCurrency
Transforma numerico em caracter (moeda)
@type Static Function
@author Marcos Natã Santos
@since 16/09/2019
@version 1.0
@param nVal, numeric
@return cCurrency, char
/*/
Static Function ValToCurrency(nVal)
    Local cCurrency := ""
    cCurrency := "R$ " + AllTrim(TRANSFORM(nVal, PesqPict("SC7", "C7_TOTAL")))
Return cCurrency

/*/{Protheus.doc} FUPRET
Processa a resposta do serviço de workflow (Follow Up Suprimentos)
@type User Function
@author Marcos Natã Santos
@since 23/08/2019
@version 1.0
@param oProcess, object
/*/
User Function FUPRET(oProcess)
    Local aAreaSZQ := SZQ->( GetArea() )
    Local nX := 0
    Local cNumPC := AllTrim(oProcess:oHtml:RetByName("cNumPedComp"))
    Local cItem := ""
    Local cProdEst := ""

    //------------------------------------------------
    //-- Realiza gravação da resposta do fornecedor
    //--
    //-- Campos:
    //-- Posição do produto (Produção ou Em Estoque)
    //-- Data de faturamento do fornecedor
    //------------------------------------------------
    If !Empty(cNumPC)
        SZQ->( dbSetOrder(1) )
        For nX := 1 To Len(oProcess:oHtml:RetByName("it.item"))
            cItem := oProcess:oHtml:RetByName("it.item")[nX]
            If AllTrim(oProcess:oHtml:RetByName("it.aPosicProd")[nX]) == "Em Produção"
                cProdEst := "1"
            ElseIf AllTrim(oProcess:oHtml:RetByName("it.aPosicProd")[nX]) == "Em Estoque"
                cProdEst := "2"
            EndIf

            If SZQ->( dbSeek(xFilial("SZQ") + cNumPC + cItem) )
                RecLock("SZQ", .F.)
                SZQ->ZQ_PRODEST := cProdEst
                SZQ->ZQ_DTFAT := STOD(StrTran(oProcess:oHtml:RetByName("it.dtfat")[nX], "-"))
                SZQ->( MsUnLock() )
            EndIf

            cItem := ""
        Next nX
    EndIf

    RestArea(aAreaSZQ)
    oProcess:Finish()
Return

/*/{Protheus.doc} FUPTMOUT
Time Out para workflow
@type User Function
@author Marcos Natã Santos
@since 29/09/2019
@version 1.0
@param oProcess, object
/*/
User Function FUPTMOUT(oProcess)
    oProcess:Finish()
Return

/*/{Protheus.doc} GrvProcess
Grava ID do processo no pedido de compra
@type Static Function
@author Marcos Natã Santos
@since 29/09/2019
@version 1.0
@param cNumPedComp, char
@param cID, char
/*/
Static Function GrvProcess(cNumPedComp, cID)
    Local aAreaSC7 := SC7->( GetArea() )

    SC7->( dbSetOrder(1) )
    If SC7->(dbSeek(xFilial("SC7")+cNumPedComp))
        While SC7->( !EOF() ) .And. AllTrim(SC7->C7_NUM) == AllTrim(cNumPedComp)
            RecLock("SC7", .F.)
            SC7->C7_NUMIMP := '1000' //Processo enviado
            SC7->C7_ACCNUM := cID    //Numero do processo
            MsUnLock()
            SC7->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaSC7)
Return

/*/{Protheus.doc} TotPedCp
Calcula totalizadores do pedido
@type Static Function
@author Marcos Natã Santos
@since 23/09/2019
@version 1.0
@param cNum, char
@return aRet, array, Totalizadores do pedido
/*/
Static Function TotPedCp(cNum)
    Local aRet := {0, 0, 0, 0, 0}
    Local cQry := ""
    Local nQtdReg := 0

    cQry := "SELECT SUM(C7_TOTAL) TOTAL, " + CRLF
    cQry += "    SUM(C7_FRETE) FRETE, " + CRLF
    cQry += "    SUM(C7_VLDESC) DESCONTO, " + CRLF
    cQry += "    SUM(C7_DESPESA) DESPESA, " + CRLF
    cQry += "    SUM(C7_SEGURO) SEGURO " + CRLF
    cQry += "FROM " + RetSqlName("SC7") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND C7_FILIAL = '"+ xFilial("SC7") +"' " + CRLF
    cQry += "AND C7_NUM = '"+ cNum +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TOTPEDCP") > 0
        TOTPEDCP->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TOTPEDCP"

    TOTPEDCP->(dbGoTop())
    COUNT TO nQtdReg
    TOTPEDCP->(dbGoTop())

    If nQtdReg > 0
        aRet := {TOTPEDCP->TOTAL, TOTPEDCP->FRETE, TOTPEDCP->DESCONTO, TOTPEDCP->DESPESA, TOTPEDCP->SEGURO}
    EndIf

    TOTPEDCP->(DbCloseArea())
    
Return aRet
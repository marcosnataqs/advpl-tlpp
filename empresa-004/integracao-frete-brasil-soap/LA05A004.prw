#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)
#DEFINE FB_TOKEN "19DE86CF-B805-4F6F-A3C5-0E254E609445"

/*/{Protheus.doc} LA05A004

Processo envia dados do pedido para Cotação Frete Brasil

@author 	Marcos Natã Santos
@since 		13/12/2018
@version 	12.1.17
/*/
User Function LA05A004(cParam1,cParam2,cParam3) //-- U_LA05A004('076342','000001','01')
    Local oWSDL
    Local oXML
    Local oFBCotInt
    Local lOk
    Local cXML
    Local cWSDL
    Local cFlErro
    Local cMsgProcess

    Default cParam1 := ""
    Default cParam2 := ""
    Default cParam3 := ""

    Private cNumPed := cParam1
    Private cCodCli := cParam2
    Private cLoja   := cParam3

    //-- Processa apenas na filial 0101 --//
    If FWCodFil() <> "0101"
        Return
    EndIf

    oWSDL     := TWSDLManager():New()
    oXML      := TXmlManager():New()
    oFBCotInt := FBCotacaoIntegrar():New()
    cWSDL     := SuperGetMV("MV_XFBWSDL", .F., "https://wsfretebrasil.activecorp.com.br/WSACTIVE/Service.svc?wsdl")

    oWSDL:lVerbose := .T.
    
    //-- Certificado deve estar na pasta protheus_data --//
    oWSDL:cSSLCACertFile := "\certificado\FreteBrasil\CA_FreteBrasil.pem"

    //-- WSDL do ambiente producao Frete Brasil --//
    lOk := oWSDL:ParseURL( cWSDL )
    If !lOk
        MsgStop( oWSDL:cError , "ParseURL() ERROR")
        Return
    EndIf

    lOk := oWSDL:SetOperation( "CotacaoIntegrar" )
    If !lOk
        MsgStop( oWSDL:cError , "SetOperation(CotacaoIntegrar) ERROR")
        Return
    EndIf

    //-- Cria e valida mensagem de requisição --//
    SetSoapMsg(@cXML, @oFBCotInt)

    //-- Parametro webservice --//
    oWSDL:SetFirst("xml", cXML)

    lOk := oWSDL:SendSoapMsg()
    If !lOk
        Sleep( 5100 ) //-- Espera 5 segundos para nova requisicao --//
        lOk := oWSDL:SendSoapMsg()
        If !lOk
            MsgStop( oWSDL:cError , "SendSoapMsg() ERROR")
            Return
        EndIf
    EndIf

    //-- maxStringSize=10 no appserver.ini --//
    cResp := oWSDL:GetSoapResponse()
    lOk := oXML:Parse( cResp )
    If !lOk
        MsgStop( "Error: " + oXML:Error() )
        Return
    EndIf

    lOk := oXML:Parse( EncodeUTF8(oXML:cText) )
    If !lOk
        MsgStop( "Error: " + oXML:Error() )
        Return
    EndIf

    cFlErro := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "FLERRO" ))

    If cFlErro == "N"
        oFBCotInt:cGuidProcess     := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "GUIDPROCESSAMENTO" ))
        oFBCotInt:nLinha           := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "LINHA" ))
        oFBCotInt:cRegistroChamada := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "REGISTRODACHAMADA" ))
        oFBCotInt:cCodProcess      := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "CODPROCESSAMENTO" ))
        oFBCotInt:cMsgProcess      := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "MSGPROCESSAMENTO" ))
        oFBCotInt:cMsgProcessCmp   := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "MSGPROCESSAMENTOCAMPO" ))
        oFBCotInt:cFlErro          := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "FLERRO" ))
        oFBCotInt:nCotCdItem       := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_CDITEM" ))
        oFBCotInt:dCotDtAprovacao  := oFBCotInt:ConvertDate(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_DTAPROVACAO" ))
        oFBCotInt:cUsrAprovacao    := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_USUARIOAPROVACAO" ))
        oFBCotInt:cTransCpnj       := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "TRANSP_CNPJ" ))
        oFBCotInt:cTransRzSocial   := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "TRANSP_RZSOCIAL" ))
        oFBCotInt:cCotRef          := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_REF" ))
        oFBCotInt:cNotaNum         := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "NOTA_NUMERO" ))
        oFBCotInt:cNotaSerie       := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "NOTA_SERIE" ))
        oFBCotInt:nCotValNota      := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_VALORNOTA" ))
        oFBCotInt:cCotTpCalculo    := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_TPCALCULO" ))
        oFBCotInt:nCotPrazo        := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_PRAZO" ))
        oFBCotInt:dCotPrevEntreg   := oFBCotInt:ConvertDate(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_PREVENTREGA" ))
        oFBCotInt:nCotFrete        := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_FRETE" ))
        oFBCotInt:nCotFreteValor   := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_FRETEVALOR" ))
        oFBCotInt:nCotFretePeso    := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_FRETEPESO" ))
        oFBCotInt:nCotPedagio      := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_PEDAGIO" ))
        oFBCotInt:nCotDespacho     := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_DESPACHO" ))
        oFBCotInt:nCotCAT          := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_CAT" ))
        oFBCotInt:nCotADEME        := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_ADEME" ))
        oFBCotInt:nCotOutrosVal    := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_OUTROSVALORES" ))
        oFBCotInt:nCotCubagem      := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_CUBAGEM" ))
        oFBCotInt:nCotSeguro       := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_SEGURO" ))
        oFBCotInt:nCotAdicional    := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_ADICIONAL" ))
        oFBCotInt:nCotGRIS         := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_GRIS" ))
        oFBCotInt:nCotTDA          := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_TDA" ))
        oFBCotInt:nCotBaseICMS     := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_BASEICMS" ))
        oFBCotInt:nCotBaseAliqICMS := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_BASEALIQICMS" ))
        oFBCotInt:nCotICMS         := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_ICMS" ))
        oFBCotInt:nCotBaseISS      := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_BASEISS" ))
        oFBCotInt:nCotAliqISS      := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_ALIQISS" ))
        oFBCotInt:nCotISS          := Val(oXML:XPathGetAtt( "/ROWDATA/ROW", "COT_ISS" ))

        SetTransp(cNumPed,cCodCli,cLoja,oFBCotInt:cTransCpnj)
    Else
        cMsgProcess := AllTrim(oXML:XPathGetAtt( "/ROWDATA/ROW", "MSGPROCESSAMENTO" ))
        MsgAlert("Cotação Frete Brasil: " + cMsgProcess)
    EndIf

Return

/*/{Protheus.doc} SetSoapMsg
Cria e valida mensagem de requisição
@author 	Marcos Natã Santos
@since 		02/01/2018
@version 	12.1.17
/*/
Static Function SetSoapMsg(cXML,oFBCotInt)
    Local lOk           := .T.
    Local aOrderTot     := {}
    Local aOrigDest     := {}
    Local cEmbarcCnpj   := "05207076000106"
    Local cCotRef       := ""
    Local cIBGECidOrig  := ""
    Local cCepOrig      := ""
    Local cIBGECidDest  := ""
    Local cCepDest      := ""
    Local cCotCliRetira := "N"
    Local cCotPeso      := "0"
    Local cCotMetragem  := "0"
    Local cCotVolume    := "0"
    Local cCotPesoTrans := "0"
    Local cCotValNf     := "0"
    Local cCotKM        := "0"
    Local cCotPrazo     := "24"
    Local cCotTPCalc    := "F" //-- F = Carga Fracionada
    Local cCotPriori    := "V" //-- Prioriza por Valor
    Local cCotObs       := ""
    Local lPedChoc      := IsPedChoc() //-- Para pedidos de chocolate e ovo de pascoa --//

    aOrderTot     := GetOrderTot(cNumPed,cCodCli,cLoja)
    cCotRef       := aOrderTot[1] + cNumPed
    cCotObs       := "PEDIDO FABRICA " + aOrderTot[1]
    cCotVolume    := cValToChar(aOrderTot[2])
    cCotPeso      := cValToChar(aOrderTot[3])
    cCotPesoTrans := cValToChar(aOrderTot[3])
    cCotValNf     := cValToChar(aOrderTot[4])

    aOrigDest := GetOrigDest(aOrderTot[5],aOrderTot[6],cEmbarcCnpj)
    If Len(aOrigDest) = 2
        cIBGECidDest := oFBCotInt:FormatIBGECod(aOrigDest[1,1], aOrigDest[1,2])
        cCepDest     := aOrigDest[1,3]
        If lPedChoc //-- .And. SubStr(cIBGECidDest,1,2) == "35" //-- Estado São Paulo
            cIBGECidOrig := "3550308" //-- SP Capital
            cCepOrig     := ""
        Else
            cIBGECidOrig := oFBCotInt:FormatIBGECod(aOrigDest[2,1], aOrigDest[2,2])
            cCepOrig     := aOrigDest[2,3]
        EndIf
    EndIf

    cXML := "<![CDATA["
    cXML += "<ROWDATA>"
    cXML += "<ROW TOKEN = '"+ FB_TOKEN +"' "
    cXML += "EMBARC_CNPJ = '"+ cEmbarcCnpj +"' "
    cXML += "COT_REF = '"+ cCotRef +"' "
    cXML += "IBGECIDADEORI = '"+ cIBGECidOrig +"' "
    cXML += "CEPORIGEM = '"+ cCepOrig +"' "
    cXML += "IBGECIDADEDEST = '"+ cIBGECidDest +"' "
    cXML += "CEPDESTINO = '"+ cCepDest +"' "
    cXML += "COT_CLIRETIRA = '"+ cCotCliRetira +"' "
    cXML += "COT_PESO = '"+ cCotPeso +"' "
    cXML += "COT_METRAGEM = '"+ cCotMetragem +"' "
    cXML += "COT_VOLUME = '"+ cCotVolume +"' "
    cXML += "COT_PESOTRANSP = '"+ cCotPesoTrans +"' "
    cXML += "COT_VALORNOTA = '"+ cCotValNf +"' "
    cXML += "COT_KM = '"+ cCotKM +"' "
    cXML += "COT_PRAZO = '"+ cCotPrazo +"' "
    cXML += "COT_TPCALCULO = '"+ cCotTPCalc +"' "
    If lPedChoc
        cXML += "COT_TPSERVICODESCRICAO = 'CHOCOLATE' "
    EndIf
    cXML += "COT_PRIORI = '"+ cCotPriori +"' "
    cXML += "COT_OBS = '"+ cCotObs +"'/>"
    cXML += "</ROWDATA>"
    cXML += "]]>"

Return lOk

/*/{Protheus.doc} GetOrderTot
Totaliza volume, peso, valor do pedido de venda
@author 	Marcos Natã Santos
@since 		03/01/2018
@version 	12.1.17
@return     aData
/*/
Static Function GetOrderTot(cNumPed,cCodCli,cLoja)
    Local cQry    := ""
    Local nQtdReg := 0
    Local aData   := {}

    cQry := "SELECT SUBSTR(SC5.C5_XPVORI,1,6) PEDIDO, " + CRLF
    cQry += "    SUM(SC6.C6_QTDVEN) VOLUMES, " + CRLF
    cQry += "    SUM(SC6.C6_QTDVEN * SB1.B1_PESO) PESO, " + CRLF
    cQry += "    SUM(SC6.C6_QTDVEN * SC6.C6_XPRCVEN) VALORNF, " + CRLF
    cQry += "    TRIM(SC5.C5_XCLIVEN) CLIENTE, " + CRLF
	cQry += "    TRIM(SC5.C5_XLJVEN) LOJA " + CRLF
    cQry += "FROM "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SB1") +" SB1 " + CRLF
    cQry += "    ON SB1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SB1.B1_COD = SC6.C6_PRODUTO " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
    cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
    cQry += "    AND SC5.C5_NUM = SC6.C6_NUM " + CRLF
    cQry += "    AND SC5.C5_CLIENTE = SC6.C6_CLI " + CRLF
    cQry += "    AND SC5.C5_LOJACLI = SC6.C6_LOJA " + CRLF
    cQry += "WHERE SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "    AND SC6.C6_NUM = '"+ cNumPed +"' " + CRLF
    cQry += "    AND SC6.C6_CLI = '"+ cCodCli +"' " + CRLF
    cQry += "    AND SC6.C6_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "GROUP BY SC5.C5_XPVORI, SC5.C5_XCLIVEN, SC5.C5_XLJVEN " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMPC6") > 0
        TMPC6->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMPC6"

    TMPC6->(dbGoTop())
    COUNT TO nQtdReg
    TMPC6->(dbGoTop())

    If nQtdReg > 0
        aAdd(aData, TMPC6->PEDIDO)
        aAdd(aData, TMPC6->VOLUMES)
        aAdd(aData, TMPC6->PESO)
        aAdd(aData, TMPC6->VALORNF)
        aAdd(aData, TMPC6->CLIENTE)
        aAdd(aData, TMPC6->LOJA)
    EndIf

    TMPC6->(DbCloseArea())

Return aData

/*/{Protheus.doc} GetOrigDest
Busca origem destino
@author 	Marcos Natã Santos
@since 		03/01/2018
@version 	12.1.17
@return     aData
/*/
Static Function GetOrigDest(cCodCli,cLoja,cEmbarcCnpj)
    Local aData   := {}
    Local cQry    := ""
    Local nQtdReg := 0

    cQry  := "SELECT SA1.A1_EST EST, " + CRLF
    cQry  += "    SA1.A1_COD_MUN CIDADE, " + CRLF
    cQry  += "    SA1.A1_CEP CEP " + CRLF
    cQry  += "FROM "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry  += "WHERE SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry  += "AND SA1.A1_COD = '"+ cCodCli +"' " + CRLF
    cQry  += "AND SA1.A1_LOJA = '"+ cLoja +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMPA1") > 0
        TMPA1->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMPA1"

    TMPA1->(dbGoTop())
    COUNT TO nQtdReg
    TMPA1->(dbGoTop())

    If nQtdReg > 0
        aAdd(aData, {TMPA1->EST, TMPA1->CIDADE, TMPA1->CEP} )

        cQry  := "SELECT SA2.A2_EST EST, " + CRLF
        cQry  += "    SA2.A2_COD_MUN CIDADE, " + CRLF
        cQry  += "    SA2.A2_CEP CEP " + CRLF
        cQry  += "FROM "+ RetSqlName("SA2") +" SA2 " + CRLF
        cQry  += "WHERE SA2.D_E_L_E_T_ <> '*' " + CRLF
        cQry  += "AND SA2.A2_CGC = '"+ cEmbarcCnpj +"' " + CRLF
        cQry := ChangeQuery(cQry)

        If Select("TMPA2") > 0
            TMPA2->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "TMPA2"

        TMPA2->(dbGoTop())
        COUNT TO nQtdReg
        TMPA2->(dbGoTop())

        If nQtdReg > 0
            aAdd(aData, {TMPA2->EST, TMPA2->CIDADE, TMPA2->CEP} )
        EndIf

        TMPA2->(DbCloseArea())
    EndIf

    TMPA1->(DbCloseArea())

Return aData

/*/{Protheus.doc} SetTransp
Grava transportadora cotada no Frete Brasil
@author 	Marcos Natã Santos
@since 		15/02/2019
@version 	12.1.17
/*/
Static Function SetTransp(cNumPed,cCodCli,cLoja,cTransCpnj)
    Local aAreaSC5   := SC5->( GetArea() )
    Local cCodTransp := Posicione("SA4", 3, xFilial("SA4")+cTransCpnj, "A4_COD")

    SC5->( dbSetOrder(3) )
    If SC5->( dbSeek(xFilial("SC5")+cCodCli+cLoja+cNumPed) )
        If !Empty(AllTrim(cCodTransp))
            RecLock("SC5", .F.)
            SC5->C5_XTRPCOT := cCodTransp
            SC5->( MsUnlock() )
        Else
            ConOut("LA05A004: Transportadora Nao Encontrada -> " + cTransCpnj)
        EndIf
    EndIf

    RestArea(aAreaSC5)
Return

/*/{Protheus.doc} IsPedChoc
Verifica se pedido chocolate
@author 	Marcos Natã Santos
@since 		21/02/2019
@version 	12.1.17
/*/
Static Function IsPedChoc()
    Local lRet     := .F.
    Local aAreaSC6 := SC6->( GetArea() )
    Local cGrpChoc := AllTrim(GetMV("MV_XGRCHOC"))
    Local cGrpOvo  := AllTrim(GetMV("MV_XGRPOVO"))
    Local cProdGrp := ""

    SC6->( dbSetOrder(1) )
    If SC6->( dbSeek(xFilial("SC6")+cNumPed) )
        cProdGrp := AllTrim(Posicione("SB1", 1, xFilial("SB1")+SC6->C6_PRODUTO, "B1_BASE3"))
        If cProdGrp $ (cGrpChoc+"/"+cGrpOvo)
            lRet := .T.
        EndIf
    EndIf

    RestArea( aAreaSC6 )

Return lRet
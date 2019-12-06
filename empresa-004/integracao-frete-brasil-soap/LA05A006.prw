#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)
#DEFINE FB_TOKEN "19DE86CF-B805-4F6F-A3C5-0E254E609445"

/*/{Protheus.doc} LA05A006

Busca resultado/aprovação da cotação Frete Brasil

@author 	Marcos Natã Santos
@since 		03/01/2018
@version 	12.1.17
/*/
User Function LA05A006(cDocNum,lManual) //-- U_LA05A006()
    Local oWSDL
    Local oXML
    Local oFBCotacao
    Local lOk
    Local cResp
    Local cWSDL
    Local cXMLRoot
    Local nX
    Local nCount
    Local aCotacoes
    Local oCotSelec

    Local cEmbarcCnpj
    Local cIntegraTipo
    Local cDocNum
    Local cRetrans

    Default cDocNum := ""
    Default lManual := .F.

    cEmbarcCnpj  := "05207076000106"
    cIntegraTipo := "5" //-- Cotação/Orçamento de frete
    cRetrans     := "N"
    cXMLRoot     := "/s:Envelope/s:Body/*/*/*/*/CotacaoConsulta"
    cXMLFailPath := "/s:Envelope/s:Body/*/*/*/*/RetornoGenerico"
    aCotacoes    := {}

    oWSDL := TWSDLManager():New()
    oXML  := TXmlManager():New()
    cWSDL := SuperGetMV("MV_XFBWSDL", .F., "https://wsfretebrasil.activecorp.com.br/WSACTIVE/Service.svc?wsdl")

    oWSDL:lVerbose := .T.
    
    //-- Certificado deve estar na pasta protheus_data --//
    oWSDL:cSSLCACertFile := "\certificado\FreteBrasil\CA_FreteBrasil.pem"

    //-- WSDL do ambiente producao Frete Brasil --//
    lOk := oWSDL:ParseURL( cWSDL )
    If !lOk 
        MsgStop( oWSDL:cError , "ParseURL() ERROR")
        Return
    EndIf

    lOk := oWSDL:SetOperation( "ConsultaDocumento" )
    If !lOk
        MsgStop( oWSDL:cError , "SetOperation(ConsultaDocumento) ERROR")
        Return
    EndIf

    //-- Parametro webservice --//
    oWSDL:SetFirst("token", FB_TOKEN)
    oWSDL:SetFirst("embarc_cnpj", cEmbarcCnpj)
    oWSDL:SetFirst("integracao_tipo", cIntegraTipo)
    oWSDL:SetFirst("documento_numero", cDocNum)
    oWSDL:SetFirst("retransmitir", cRetrans)
    oWSDL:SetFirst("pagina", "1")

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

    lOk := oXML:XPathRegisterNs( "s", "http://schemas.xmlsoap.org/soap/envelope/" )
    If !lOk
        MsgStop( "Error: " + oXML:Error() )
        Return
    EndIf

    If !Empty( AllTrim(oXML:XPathGetNodeValue( cXMLFailPath )) )
        cRetrans := "S"
        oWSDL:SetFirst("retransmitir", cRetrans)

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

        lOk := oXML:XPathRegisterNs( "s", "http://schemas.xmlsoap.org/soap/envelope/" )
        If !lOk
            MsgStop( "Error: " + oXML:Error() )
            Return
        EndIf
    EndIf

    nCount := oXML:XPathChildCount( cXMLRoot )
    For nX := 1 To nCount
        oFBCotacao := FBCotacao():New()
        oFBCotacao:cTransportador  := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/ENVOLVIDOS/TRANSPORTADOR" ))
        oFBCotacao:cTransRzSocial  := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/ENVOLVIDOS/TRANSPORTADOR_RAZAOSOCIAL" ))
        oFBCotacao:cContrato       := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/ENVOLVIDOS/CONTRATO_DESCRICAO" ))
        oFBCotacao:cOrcSelecionado := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/VALORES/ORCAMENTO_SELECIONADO" ))
        oFBCotacao:cAprovacao      := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/VALORES/APROVACAO" ))
        oFBCotacao:cAprovaUsuario  := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/VALORES/APROVACAO_USUARIO" ))
        oFBCotacao:cMelhorPreco    := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/VALORES/MELHOR_PRECO" ))
        oFBCotacao:cMelhorPrazo    := AllTrim(oXML:XPathGetNodeValue( cXMLRoot + "/ORCAMENTO["+ cValToChar(nX) +"]/VALORES/MELHOR_PRAZO" ))
        aAdd(aCotacoes, oFBCotacao)
    Next nX

    For nX := 1 To Len(aCotacoes)
        If aCotacoes[nX]:cOrcSelecionado == "SIM" .And. !Empty(aCotacoes[nX]:cAprovacao)
            oCotSelec := aCotacoes[nX]
        EndIf
    Next nX

    If !Empty(oCotSelec)
        SetTransp(cDocNum,oCotSelec)
    EndIf

    If lManual
        MsgInfo("Processamento concluído. Verifique a transportadora no pedido.")
    EndIf

Return

/*/{Protheus.doc} SetTransp

Adiciona transportadora selecionada no pedido

@author 	Marcos Natã Santos
@since 		04/01/2018
@version 	12.1.17
/*/
Static Function SetTransp(cDocNum,oCotSelec)
    Local aAreaSC5   := SC5->(GetArea())
    Local cNum       := SubStr(cDocNum,7,6)
    Local cCodTransp := Posicione("SA4", 3, xFilial("SA4") + oCotSelec:cTransportador, "A4_COD")

    If !Empty(AllTrim(cCodTransp))
        SC5->( dbSetOrder(1) )
        If SC5->( dbSeek(xFilial("SC5") + cNum) )
            RecLock("SC5", .F.)
            SC5->C5_XTRPCOT := cCodTransp
            SC5->( MsUnlock() )
        EndIf
    EndIf

    RestArea(aAreaSC5)

Return
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)
#DEFINE FB_TOKEN "19DE86CF-B805-4F6F-A3C5-0E254E609445"

/*/{Protheus.doc} LA05A007

Faturas Frete Brasil

@author 	Marcos Natã Santos
@since 		14/01/2018
@version 	12.1.17
/*/
User Function LA05A007 //-- U_LA05A007()
    Local oCancel
    Local oComboBo1
    Local cComboBo1 := "05207076000106 - LINEA GYN"
    Local oGet1
    Local cGet1     := Space(6)
    Local oGet2
    Local cGet2     := Space(15)
    Local oGroup1
    Local oProcess
    Local bProcess  := {|| Processa( {|| oDlg:End(), GetFatura(cGet1,AllTrim(cGet2),SubStr(cComboBo1,1,14)) }, "Aguarde", "Buscando fatura...", .F.) }
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Fatura Frete" STYLE DS_MODALFRAME FROM 000, 000  TO 250, 400 COLORS 0, 16777215 PIXEL

        @ 010, 015 GROUP oGroup1 TO 035, 185 PROMPT "Fatura de Frete" OF oDlg COLOR 0, 16777215 PIXEL
        @ 020, 020 SAY oSay1 PROMPT "Entrada de fatura de frete aprovada no sistema Frete Brasil." SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 045, 015 SAY oSay4 PROMPT "Selecione a filial:" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 055, 015 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"05207076000297 - LINEA ANPS","05207076000106 - LINEA GYN"} SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 070, 015 SAY oSay2 PROMPT "Transportador:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 080, 015 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "SA4" PIXEL
        @ 070, 070 SAY oSay3 PROMPT "Num Fatura:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 080, 070 MSGET oGet2 VAR cGet2 SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 107, 135 BUTTON oCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
        @ 107, 080 BUTTON oProcess PROMPT "Processar" SIZE 050, 012 OF oDlg ACTION Eval(bProcess) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} GetFatura

Busca faturas do Frete Brasil

@author 	Marcos Natã Santos
@since 		14/01/2018
@version 	12.1.17
/*/
Static Function GetFatura(cCodTransp,cDocNum,cEmbarcCnpj)
    Local oWSDL
    Local oXML
    Local lOk
    Local cResp
    Local cWSDL
    Local cXMLRoot
    Local nCount
    Local nX
    Local aFatura := {}

    Local cTranspCnpj
    Local cIntegraTipo
    Local cRetrans

    Default cCodTransp  := ""
    Default cDocNum     := ""
    Default cEmbarcCnpj := ""

    If Empty(cCodTransp)
        MsgAlert("Informe o transportador.")
        Return
    ElseIf Empty(cDocNum)
        MsgAlert("Informe o número da fatura.")
        Return
    EndIf

    ProcRegua(1)

    cTranspCnpj  := AllTrim( Posicione("SA4", 1, xFilial("SA4") + cCodTransp, "A4_CGC") )
    cIntegraTipo := "3" //-- Fatura Aprovada
    cRetrans     := "N"
    cXMLRoot     := "/s:Envelope/s:Body/*/*/*/*/FaturaConsulta"
    cXMLFailPath := "/s:Envelope/s:Body/*/*/*/*/RetornoGenerico"

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
    oWSDL:SetFirst("transp_cnpj", cTranspCnpj)
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
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/ENVOLVIDOS/TRANSPORTADOR" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/ENVOLVIDOS/TRANSPORTADOR_RAZAOSOCIAL" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/DOCUMENTO/NUMERO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/DOCUMENTO/SERIE" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/DOCUMENTO/EMISSAO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/DOCUMENTO/VENCIMENTO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_IMPOSTO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_ACRESCIMO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_DESCONTO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_PRESTACAO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_LIQUIDO" ) )
        aAdd(aFatura, oXML:XPathGetNodeValue( cXMLRoot + "/FATURA["+ cValToChar(nX) +"]/PRESTACAO/CTE_TRANSPORTADOR" ) )
    Next nX

    IncProc()
    If Len(aFatura) > 0
        ShowFat(aFatura)
    Else
        MsgAlert("Fatura não encontrada/aprovada.")
    EndIf

Return

/*/{Protheus.doc} ShowFat

Apresenta dados da fatura

@author 	Marcos Natã Santos
@since 		16/01/2018
@version 	12.1.17
/*/
Static Function ShowFat(aFatura)
    Local lOk       := .F.
    Local oCancel
    Local oGroup1
    Local oGroup2
    Local oMultiGe1
    Local cMultiGe1 := AllTrim( aFatura[12] )
    Local oProcess
    Local oSay1
    Local cSay1     := "Transportador: " + aFatura[2]
    Local oSay2
    Local cSay2     := "Número: " + aFatura[3]
    Local oSay3
    Local cSay3     := "Série: " + aFatura[4]
    Local oSay4
    Local cSay4     := "Emissão: " + aFatura[5]
    Local oSay5
    Local cSay5     := "Vencto: " + aFatura[6]
    Local oSay6
    Local cSay6     := "Imposto: R$ " + aFatura[7]
    Local oSay7
    Local cSay7     := "Acresc.: R$ " + aFatura[8]
    Local oSay8
    Local cSay8     := "Desconto: R$ " + aFatura[9]
    Local oSay9
    Local cSay9     := "Prestação: R$ " + aFatura[10]
    Local oSay10
    Local cSay10    := "Líquido: R$ " + aFatura[11]
    Local bOk       := {|| lOk:=.T., oDlg:End(), Processa( {|| ProcessCTE(cMultiGe1,aFatura[1],aFatura[3]) }, "Aguarde", "Processando CTEs...", .F.) }
    Static oDlg

    Private cLogMsg := ""
    Private dDtVencFat := CTOD(aFatura[6])

    cLogMsg += "Fatura " + aFatura[3] + " - " + aFatura[2] + CRLF + CRLF

    DEFINE MSDIALOG oDlg TITLE "Fatura" STYLE DS_MODALFRAME FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

        @ 015, 015 GROUP oGroup1 TO 067, 285 PROMPT "Fatura" OF oDlg COLOR 0, 16777215 PIXEL
        @ 070, 015 GROUP oGroup2 TO 122, 285 PROMPT "Docs Relacionados" OF oDlg COLOR 0, 16777215 PIXEL
        @ 025, 020 SAY oSay1 PROMPT  cSay1  SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 035, 020 SAY oSay2 PROMPT  cSay2  SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 035, 085 SAY oSay3 PROMPT  cSay3  SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 035, 130 SAY oSay4 PROMPT  cSay4  SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 035, 192 SAY oSay5 PROMPT  cSay5  SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 045, 020 SAY oSay6 PROMPT  cSay6  SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 045, 092 SAY oSay7 PROMPT  cSay7  SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 045, 165 SAY oSay8 PROMPT  cSay8  SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 055, 020 SAY oSay9 PROMPT  cSay9  SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 055, 105 SAY oSay10 PROMPT cSay10 SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 078, 020 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 260, 040 COLORS 0, 16777215 READONLY HSCROLL PIXEL
        @ 130, 235 BUTTON oCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
        @ 130, 182 BUTTON oProcess PROMPT "Processar" SIZE 050, 012 OF oDlg ACTION Eval(bOk) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOk
        //-- Gera arquivo log e abre notepad --//
        MemoWrite("C:\Windows\Temp\fatura-frete-log.txt", cLogMsg)
        ShellExecute( "Open", "C:\Windows\System32\notepad.exe", "fatura-frete-log.txt", "C:\Windows\Temp\", 1 )
    EndIf

Return

/*/{Protheus.doc} ProcessCTE

Cria documento de entrada para os CTE's

@author 	Marcos Natã Santos
@since 		16/01/2018
@version 	12.1.17
/*/
Static Function ProcessCTE(cCTE,cTransp,cFatura)
    Local aCTE  := StrTokArr( cCTE, "," )
    Local nX    := 0
    Local cPref := ""
    Local cNum  := ""
    Local aTit  := {}
    Local lOk   := .T.

    Private dDataIni := dDataBase

    ProcRegua(Len(aCTE)+1)
    For nX := 1 To Len(aCTE)
        IncProc("Cte " + aCTE[nX])
        If .Not. RegCTE( GetCTE( cTransp, aCTE[nX] ) )
            lOk := .F.
        Else
            cPref := PadR( Right(aCTE[nX],1), TamSX3("E2_PREFIXO")[1] )
            cNum  := PadL( AllTrim( Left(aCTE[nX], (Len(aCTE[nX]) - 2)) ), TamSX3("E2_NUM")[1], "0" )
            aAdd(aTit, { cPref, cNum, Space(TamSX3("E2_PARCELA")[1]), PadR( "NF", TamSX3("E2_TIPO")[1] ), .F. })
        EndIf
    Next nX

    //-- Cria fatura no financeiro --//
    If lOk
        IncProc("Gerando Fatura...")
        SelecFat(aTit,cTransp,cFatura)
    EndIf

Return

/*/{Protheus.doc} GetCTE

Busca CTE do Frete Brasil

@author 	Marcos Natã Santos
@since 		16/01/2018
@version 	12.1.17
@return     oFBCteFinan
/*/
Static Function GetCTE(cTransp,cDocNum)
    Local oWSDL
    Local oXML
    Local oFBCteFinan
    Local lOk
    Local cResp
    Local cWSDL
    Local cXMLRoot
    Local nCount
    Local nX
    Local aAreaSA2 := SA2->( GetArea() )
    Local aAreaSF1 := SF1->( GetArea() )
    Local cSerie
    Local cDoc

    Local cEmbarcCnpj
    Local cTranspCnpj
    Local cIntegraTipo
    Local cRetrans

    Default cDocNum := ""
    Default cTransp := ""

    cSerie  := PadR(Right(cDocNum,1), 3)
    cDocNum := AllTrim( Left(cDocNum, (Len(cDocNum) - 2) ) )
    cDoc    := PadL(cDocNum,9,"0")

    //-- Verifica se existe CTE --//
    SA2->( dbSetOrder(3) ) //-- A2_CGC
    If SA2->( dbSeek(xFilial("SA2") + cTransp) )
        SF1->( dbSetOrder(1) ) //-- F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
        If SF1->( dbSeek(xFilial("SF1") + cDoc + cSerie + SA2->A2_COD + SA2->A2_LOJA) )
            cLogMsg += "Cte " + cDoc + " Já Existe para Fornecedor. Verificar" + CRLF
            //-- Ajusta data para geracao da fatura --//
            If SF1->F1_EMISSAO < dDataIni
                dDataIni := SF1->F1_EMISSAO
            EndIf
            RestArea( aAreaSA2 )
            RestArea( aAreaSF1 )
            Return .T.
        EndIf
    EndIf

    cEmbarcCnpj  := "05207076000297"
    cTranspCnpj  := cTransp
    cIntegraTipo := "1" //-- CTE Aprovado
    cRetrans     := "N"
    cXMLRoot     := "/s:Envelope/s:Body/*/*/*/*/CteFinanceiroConsulta"
    cXMLFailPath := "/s:Envelope/s:Body/*/*/*/*/RetornoGenerico"

    oFBCteFinan := FBCteFinan():New()
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
    oWSDL:SetFirst("transp_cnpj", cTranspCnpj)
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
        oFBCteFinan:cTransportador := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/ENVOLVIDOS/TRANSPORTADOR" )
        oFBCteFinan:cDoc           := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/DOCUMENTO/NUMERO" )
        oFBCteFinan:cSerie         := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/DOCUMENTO/SERIE" )
        oFBCteFinan:dEmissao       := CTOD( oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/DOCUMENTO/EMISSAO" ) )
        oFBCteFinan:cChvNfe        := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/DOCUMENTO/CHAVE" )
        oFBCteFinan:nTotalFrete    := Val( StrTran( oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/PRESTACAO/TOTAL_FRETE" ), ",", "." ) )
        oFBCteFinan:nBaseIcm       := Val( StrTran( oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/PRESTACAO/IMPOSTO_BASE" ), ",", "." ) )
        oFBCteFinan:nValorIcm      := Val( StrTran( oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/PRESTACAO/IMPOSTO_VALOR" ), ",", "." ) )
        oFBCteFinan:nAliqIcm       := Val( StrTran( oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/PRESTACAO/IMPOSTO_ALIQUOTA" ), ",", "." ) )
        oFBCteFinan:cOrigIBGE      := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/ORIGEM_DESTINO/ORIGEM_IBGE" )
        oFBCteFinan:cDestIBGE      := oXML:XPathGetNodeValue( cXMLRoot + "/CTE["+ cValToChar(nX) +"]/ORIGEM_DESTINO/DESTINO_IBGE" )
    Next nX

    If Empty(AllTrim(oFBCteFinan:cDoc))
        cLogMsg += "Cte " + cDocNum + " Não Encontrado ou Não Aprovado no Frete Brasil" + CRLF
        Return Nil
    EndIf

    RestArea( aAreaSA2 )
    RestArea( aAreaSF1 )

Return oFBCteFinan

/*/{Protheus.doc} RegCTE

Grava documento de entrada para CTE

@author 	Marcos Natã Santos
@since 		16/01/2018
@version 	12.1.17
/*/
Static Function RegCTE(oFBCteFinan)
    Local aAreaSA2 := SA2->( GetArea() )
    Local aCabec   := {}
    Local aItens   := {}
    Local aLinha   := {}
    Local lIcms    := .T.
    Local cCodProd := ""
    Local cTES     := ""
    Local lOk      := .F.

    //-- Verifica criacao do objeto --//
    If ValType(oFBCteFinan) == "L"
        Return oFBCteFinan
    ElseIf ValType(oFBCteFinan) <> "O"
        Return lOk
    EndIf

    lIcms    := IIF(oFBCteFinan:nValorIcm > 0, .T., .F.)
    cCodProd := "701007"

    //-- Avalia ICMS --//
    If lIcms
        cTES := "008"
    Else
        cTES := "009"
    EndIf

    Private lMsErroAuto := .F.

    SA2->( dbSetOrder(3) ) //-- A2_CGC
    If SA2->( dbSeek(xFilial("SA2") + oFBCteFinan:cTransportador) )
        If !Empty(SA2->A2_COND)
            aAdd(aCabec,{"F1_TIPO",    "N",                          Nil})
            aAdd(aCabec,{"F1_FORMUL",  "N",                          Nil})
            aAdd(aCabec,{"F1_DOC",     PadL(oFBCteFinan:cDoc,9,"0"), Nil})
            aAdd(aCabec,{"F1_SERIE",   oFBCteFinan:cSerie,           Nil})
            aAdd(aCabec,{"F1_DTDIGIT", dDataBase,                    Nil})
            aAdd(aCabec,{"F1_EMISSAO", oFBCteFinan:dEmissao,         Nil})
            aAdd(aCabec,{"F1_FORNECE", SA2->A2_COD,                  Nil})
            aAdd(aCabec,{"F1_LOJA",    SA2->A2_LOJA,                 Nil})
            aAdd(aCabec,{"F1_ESPECIE", "CTE",                        Nil})
            aAdd(aCabec,{"F1_COND",    SA2->A2_COND,                 Nil})
            aAdd(aCabec,{"F1_NATUREZ", SA2->A2_NATUREZ,              Nil})
            aAdd(aCabec,{"F1_CHVNFE",  oFBCteFinan:cChvNfe,          Nil})

            aAdd(aLinha,{"D1_COD",     cCodProd,                Nil})
            aAdd(aLinha,{"D1_UM",      "UN",                    Nil})
            aAdd(aLinha,{"D1_LOCAL",   "05",                    Nil})
            aAdd(aLinha,{"D1_QUANT",   1,                       Nil})
            aAdd(aLinha,{"D1_VUNIT",   oFBCteFinan:nTotalFrete, Nil})
            aAdd(aLinha,{"D1_TOTAL",   oFBCteFinan:nTotalFrete, Nil})
            aAdd(aLinha,{"D1_TES",     cTES,                    Nil})
            aAdd(aLinha,{"D1_CC",      "17111",                 Nil})
            aAdd(aLinha,{"D1_BASEICM", oFBCteFinan:nBaseIcm,    Nil})
            aAdd(aLinha,{"D1_VALICM",  oFBCteFinan:nValorIcm,   Nil})
            aAdd(aLinha,{"D1_PICM",    oFBCteFinan:nAliqIcm,    Nil})
            aAdd(aItens, aLinha)

            MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCabec, aItens, 3)

            If lMsErroAuto
                cLogMsg += "Cte " + oFBCteFinan:cDoc + " Não Integrado. Verificar Erro" + CRLF
                MostraErro()
            Else
                cLogMsg += "Cte " + oFBCteFinan:cDoc + " Incluído com Sucesso" + CRLF
                lOk     := .T.

                //-- Ajusta data para geracao da fatura --//
                If SF1->F1_EMISSAO < dDataIni
                    dDataIni := SF1->F1_EMISSAO
                EndIf
            EndIf
        Else
            cLogMsg += "Cte " + oFBCteFinan:cDoc + " Fornecedor ";
                + SA2->A2_COD + "-" + SA2->A2_LOJA + " Sem Condição de Pagamento Cadastrada" + CRLF
        EndIf
    Else
        cLogMsg += "Cte " + oFBCteFinan:cDoc + " Fornecedor Não Encontrado" + CRLF
    EndIf

    RestArea( aAreaSA2 )

Return lOk

/*/{Protheus.doc} SelecFat

Monta fatura com CTE's agregados

@author 	Marcos Natã Santos
@since 		17/01/2018
@version 	12.1.17
/*/
Static Function SelecFat(aTit,cTransp,cFatura)
    Local aAreaSA2 := SA2->( GetArea() )
    Local aAreaSE2 := SE2->( GetArea() )
    Local aFatPag := {}

    Default aTit := {}

    Private lMsErroAuto := .F.

    SA2->( dbSetOrder(3) ) //-- A2_CGC
    If SA2->( dbSeek(xFilial("SA2") + cTransp) )
        aFatPag := { "REN", "FT ", PadL(cFatura, 9, "0"), SA2->A2_NATUREZ,;
            dDataIni, dDataBase, SA2->A2_COD, SA2->A2_LOJA, SA2->A2_COD, SA2->A2_LOJA, SA2->A2_COND, 01, aTit,,}

        SE2->( dbSetOrder(1) )
        If SE2->( dbSeek(xFilial("SE2") + aFatPag[1] + aFatPag[3] + "001" + aFatPag[2]) )
            cLogMsg += "Fatura "+ SE2->E2_NUM +" Já Existe para Fornecedor" + CRLF
            Return
        EndIf

        MsExecAuto({|x,y| FINA290(x,y)}, 3, aFatPag)

        If lMsErroAuto
            cLogMsg += "Erro ao Gerar Fatura. Verificar" + CRLF
            MostraErro()
        Else
            //-- Atualiza vencimento da fatura --//
            SE2->( dbSetOrder(1) )
            If SE2->( dbSeek(xFilial("SE2") + aFatPag[1] + aFatPag[3] + "001" + aFatPag[2]) )
                cLogMsg += "Fatura "+ SE2->E2_NUM +" Gerada com Sucesso" + CRLF
                RecLock("SE2", .F.)
                SE2->E2_VENCREA := dDtVencFat
                SE2->( MsUnlock() )
            Else
                cLogMsg += "Títulos Não Localizados para Gerar Fatura" + CRLF
            EndIf
        EndIf
    Else
        cLogMsg += "Fatura: Fornecedor Não Encontrado" + CRLF
    EndIf

    RestArea(aAreaSA2)
    RestArea(aAreaSE2)

Return
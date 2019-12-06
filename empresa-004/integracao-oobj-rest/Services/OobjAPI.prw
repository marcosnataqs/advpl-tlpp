#Include "Protheus.ch"
#Include "RestFul.ch"
#Include "XMLXFUN.ch"

#Define TOKEN "61c6c9caaa2ad83aae1a1249c67c10b6"
#Define SECRET "0501ab523cee38283f915bd829b58513"

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} OobjAPI
Classe OobjAPI

API REST OOBJ Produção
Token: 61c6c9caaa2ad83aae1a1249c67c10b6
Secret: 0501ab523cee38283f915bd829b58513
URL: http://rest.oobj-dfe.com.br
Docs: https://rest.oobj-dfe.com.br/swagger-ui.html#/

@type User Function
@author Marcos Natã Santos
@since 22/07/2019
@version 1.0
/*/
User Function OobjAPI
Return

/*/{Protheus.doc} OobjAPI
@author Marcos Natã Santos
@since 22/07/2019
@version 1.0
/*/
Class OobjAPI

    Data oobjRest as object
    Data basicAuth as character

    //-- Parâmetros --//
    Data empresa as character
    Data ambiente as character
    Data codModelo as character

    Method New() Constructor
    Method NewSession()
    Method DeleteSession(cXAuthToken)
    Method GetReceivedDocs(dEmiss)
    Method GetDocsByPeriod(dDtIni, dDtFin)
    Method GetDFeByKey(cKey)
    Method GetEventsByKey(cKey)
    Method EmitDFeEvent(cKey, cEmitYear, cTpEvent, cDescEvent)

EndClass

/*/{Protheus.doc} New
Inicializa Rest
Encode base 64 Basic Auth
@type Method
@author Marcos Natã Santos
@since 23/07/2019
@version 1.0
@return Self, object
/*/
Method New() Class OobjAPI
    Local cUrl := "http://rest.oobj-dfe.com.br"
    Local cEncodeString := TOKEN + ":" + SECRET

    ::oobjRest := FWRest():New(cUrl)
    ::basicAuth := Encode64(cEncodeString)
    ::empresa := "05207076000297"
    ::ambiente := "prod"
    ::codModelo := "55" //-- NFe

Return Self

/*/{Protheus.doc} NewSession
Cria nova sessão para consumo da API
@type Method
@author Marcos Natã Santos
@since 23/07/2019
@version 1.0
@return cXAuthToken, char
@example
http://rest.oobj-dfe.com.br/session
/*/
Method NewSession() Class OobjAPI
    Local cXAuthToken := ""
    Local aHeader := {}
    Local cResult := ""

    aAdd(aHeader, "Content-Type: application/json")
    aAdd(aHeader, "Authorization: Basic " + ::basicAuth)
    
    ::oobjRest:setPath("/session")

    If ::oobjRest:Post(aHeader)
        cResult := AllTrim(::oobjRest:GetResult())
        ConOut("Oobj NewSession: " + cResult)
        If SubStr(cResult,1,12) == "x-auth-token"
            cXAuthToken := SubStr(cResult,15,36)
        EndIf
    Else
        ConOut("Oobj NewSession Error: " + AllTrim(::oobjRest:GetLastError());
            + Space(1) + AllTrim(::oobjRest:GetResult()))
    EndIf
Return cXAuthToken

/*/{Protheus.doc} DeleteSession
Encerra sessão
@type Method
@author Marcos Natã Santos
@since 23/07/2019
@version 1.0
@param cXAuthToken, char
@example
http://rest.oobj-dfe.com.br/session
/*/
Method DeleteSession(cXAuthToken) Class OobjAPI
    Local aHeader := {}

    aAdd(aHeader, "x-auth-token: " + cXAuthToken)

    ::oobjRest:setPath("/session")

    If ::oobjRest:Delete(aHeader)
        ConOut("Oobj DeleteSession: " + AllTrim(::oobjRest:GetLastError()))
    Else
        ConOut("Oobj DeleteSession Error: " + AllTrim(::oobjRest:GetLastError()))
    EndIf
Return

/*/{Protheus.doc} GetReceivedDocs
Retorna um resumo dos documentos recebidos
@type Method
@author Marcos Natã Santos
@since 23/07/2019
@version 1.0
@param dEmiss, date, Data de Emissão
@return aReceivedDocs, array, Documentos Recebidos
@example
http://rest.oobj-dfe.com.br/api/empresas/{empresa}/docs/{ambiente}/{codModelo}/recebidos/{dataEmissao}
/*/
Method GetReceivedDocs(dEmiss) Class OobjAPI
    Local cXAuthToken := Self:NewSession()
    Local aHeader := {}
    Local cJSON := ""
    Local aReceivedDocs := {}
    Local aRegistros := {}
    Local nNumeroElementos := 20

    //-- Parâmetros --//
    Local cDataEmissao := Space(8)
    Local cPagina := "1"

    Private oReceivedDocs := Nil

    Default dEmiss := Date()

    cDataEmissao := SubStr(DTOS(dEmiss),1,4) + "-" + SubStr(DTOS(dEmiss),5,2) + "-" + SubStr(DTOS(dEmiss),7,2)

    If !Empty(cXAuthToken)

        aAdd(aHeader, "x-auth-token: " + cXAuthToken)

        //-- Realiza paginação da consulta --//
        While nNumeroElementos = 20
            ::oobjRest:setPath("/api/empresas/"+ ::empresa +"/docs/"+ ::ambiente +"/"+ ::codModelo;
                +"/recebidos/"+ cDataEmissao +"?pagina=" + AllTrim(cPagina))
            
            If ::oobjRest:Get(aHeader)
                ConOut("Oobj GetReceivedDocs: " + AllTrim(::oobjRest:GetLastError()))
                
                cJSON := ::oobjRest:GetResult()
                FWJsonDeserialize(DecodeUtf8(cJSON), @oReceivedDocs)
                nNumeroElementos := oReceivedDocs:NumeroElementos
                aRegistros := oReceivedDocs:Registros
                
                U_ArrConcat(aRegistros, @aReceivedDocs)
            Else
                ConOut("Oobj GetReceivedDocs Error: " + AllTrim(::oobjRest:GetLastError());
                    + Space(1) + AllTrim(::oobjRest:GetResult()))
                nNumeroElementos := 0
            EndIf
            
            cPagina := Str(Val(cPagina)+1) //-- Próxima página --//
        EndDo

        Self:DeleteSession(cXAuthToken)
    EndIf

Return aReceivedDocs

/*/{Protheus.doc} GetDocsByPeriod
Retorna um resumo dos documentos recebidos para o período informado
@type Method
@author Marcos Natã Santos
@since 05/08/2019
@version 1.0
@param dDtIni, date, Data Inicial
@param dDtFin, date, Data Final
@return aPeriodDocs, array, Documentos Fiscais do período
/*/
Method GetDocsByPeriod(dDtIni, dDtFin) Class OobjAPI
    Local aPeriodDocs := {}
    Local dDtAtual := dDtIni
    Local aRegistros := {}

    Default dDtIni := Date()
    Default dDtFin := Date()

    ProcRegua( DateDiffDay(dDtIni, dDtFin) )
    While dDtAtual <= dDtFin
        aRegistros := Self:GetReceivedDocs(dDtAtual)
        U_ArrConcat(aRegistros, @aPeriodDocs)
        dDtAtual := DaySum(dDtAtual, 1)
        IncProc()
    EndDo
Return aPeriodDocs

/*/{Protheus.doc} GetDFeByKey
Retornar um DFe por chave de acesso
@type Method
@author Marcos Natã Santos
@since 24/07/2019
@version 1.0
@param cKey, char, Chave de acesso nota fiscal
@return oDFe, object, DFe com XML
@example
http://rest.oobj-dfe.com.br/api/empresas/{empresa}/docs/{ambiente}/{codModelo}/{chaveAcesso}
/*/
Method GetDFeByKey(cKey) Class OobjAPI
    Local cXAuthToken := Self:NewSession()
    Local aHeader := {}
    Local cJSON := ""

    Local oXML := Nil
    Local cError := ""
    Local cWarning := ""
    
    Private oDFe := Nil

    If !Empty(cXAuthToken)

        aAdd(aHeader, "x-auth-token: " + cXAuthToken)

        ::oobjRest:setPath("/api/empresas/"+ ::empresa +"/docs/"+ ::ambiente +"/"+ ::codModelo +"/"+ cKey)

        If ::oobjRest:Get(aHeader)
            ConOut("Oobj GetDFeByKey: " + AllTrim(::oobjRest:GetLastError()))
            
            cJSON := ::oobjRest:GetResult()
            FWJsonDeserialize(DecodeUtf8(cJSON), @oDFe)

            //-- Criar objeto XML por meio do conteudo da consulta --//
            If oDFe <> Nil
                oXML := XmlParser(EncodeUtf8(oDFe:Conteudo), "_", @cError, @cWarning)
                If oXML == Nil
                    oDFe:Conteudo := "Falha ao gerar Objeto XML : "+ cError +" / "+ cWarning
                Else
                    oDFe:Conteudo := oXML
                EndIf
            EndIf
        Else
            ConOut("Oobj GetDFeByKey Error: " + AllTrim(::oobjRest:GetLastError());
                + Space(1) + AllTrim(::oobjRest:GetResult()))
        EndIf

        Self:DeleteSession(cXAuthToken)
    EndIf
Return oDFe

/*/{Protheus.doc} GetEventsByKey
Retornar detalhes do(s) evento(s) de uma determinada chave de acesso
@type Method
@author Marcos Natã Santos
@since 25/07/2019
@version 1.0
@param cKey, char, Chave de acesso nota fiscal
@return oEvents, object, Eventos do DFe
@example
http://rest.oobj-dfe.com.br/api/empresas/{empresa}/docs/{ambiente}/{chaveAcesso}/eventos
/*/
Method GetEventsByKey(cKey) Class OobjAPI
    Local cXAuthToken := Self:NewSession()
    Local aHeader := {}
    Local cJSON := ""

    Private oEvents := Nil

    If !Empty(cXAuthToken)

        aAdd(aHeader, "x-auth-token: " + cXAuthToken)

        ::oobjRest:setPath("/api/empresas/"+ ::empresa +"/docs/"+ ::ambiente +"/"+ cKey +"/eventos")

        If ::oobjRest:Get(aHeader)
            ConOut("Oobj GetEventsByKey: " + AllTrim(::oobjRest:GetLastError()))
            
            cJSON := ::oobjRest:GetResult()
            FWJsonDeserialize(DecodeUtf8(cJSON), @oEvents)
        Else
            ConOut("Oobj GetEventsByKey Error: " + AllTrim(::oobjRest:GetLastError());
                + Space(1) + AllTrim(::oobjRest:GetResult()))
        EndIf

        Self:DeleteSession(cXAuthToken)
    EndIf
Return oEvents

/*/{Protheus.doc} EmitDFeEvent
Emitir um evento para um DFe
@type Method
@author Marcos Natã Santos
@since 25/07/2019
@version 1.0
@param cKey, char, Chave de acesso nota fiscal
@param cEmitYear, char, Ano de emissão nota fiscal
@param cTpEvent, char, Tipo do Evento
@param cDescEvent, char, Descrição do Evento
@return lOk, logic, Resultado da Emissão
@example
http://rest.oobj-dfe.com.br/api/empresas/{empresa}/docs/{ambiente}/{codModelo}/{ano}/{serie}/{numero}/eventos
/*/
Method EmitDFeEvent(cKey, cEmitYear, cTpEvent, cDescEvent) Class OobjAPI
    Local cXAuthToken := Self:NewSession()
    Local aHeader := {}
    Local cContent := ""
    Local lOk := .F.

    Local cAno := cEmitYear
    Local cSerie :=  SubStr(cKey, 23, 3)
    Local cNumero := SubStr(cKey, 26, 9)

    Default cTpEvent := "210210"
    Default cDescEvent := "Ciencia da Operacao"

    If !Empty(cXAuthToken)

        aAdd(aHeader, "x-auth-token: " + cXAuthToken)
        aAdd(aHeader, "Content-Type: application/xml")

        ::oobjRest:setPath("/api/empresas/"+ ::empresa +"/docs/"+ ::ambiente +"/"+ ::codModelo;
            +"/"+ cAno +"/"+ cSerie +"/"+ cNumero +"/eventos?layout=oobj")

        cContent := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
        cContent += '<envEvento versao="1.00" xmlns="http://www.oobj.com.br/nfe">' + CRLF
        cContent += '    <idLote>1</idLote>' + CRLF
        cContent += '    <evento>' + CRLF
        cContent += '        <infEvento>' + CRLF
        cContent += '            <cOrgao>91</cOrgao>' + CRLF
        cContent += '            <tpAmb>1</tpAmb>' + CRLF
        cContent += '            <CNPJ>05207076000297</CNPJ>' + CRLF
        cContent += '            <chNFe>'+ cKey +'</chNFe>' + CRLF
        cContent += '            <tpEvento>'+ cTpEvent +'</tpEvento>' + CRLF
        cContent += '            <nSeqEvento>1</nSeqEvento>' + CRLF
        cContent += '            <verEvento>1.00</verEvento>' + CRLF
        cContent += '            <detEvento versao="1.00">' + CRLF
        cContent += '                <descEvento>'+ cDescEvent +'</descEvento>' + CRLF
        cContent += '            </detEvento>' + CRLF
        cContent += '        </infEvento>' + CRLF
        cContent += '    </evento>' + CRLF
        cContent += '</envEvento>' + CRLF

        ::oobjRest:SetPostParams(cContent)

        If ::oobjRest:Post(aHeader)
            ConOut("Oobj EmitDFeEvent: " + AllTrim(::oobjRest:GetLastError()))
            lOk := .T.
        Else
            ConOut("Oobj EmitDFeEvent Error: " + AllTrim(::oobjRest:GetLastError());
                + Space(1) + AllTrim(::oobjRest:GetResult()))
        EndIf

        Self:DeleteSession(cXAuthToken)
    EndIf
Return lOk
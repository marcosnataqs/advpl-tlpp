#Include "PROTHEUS.CH"
#Include "RESTFUL.CH"

/*/{Protheus.doc} SFMAINWS
API REST para StackFor Mobile App
@type  User Function
@author Marcos Natã Santos
@since 24/06/2019
@version 1.0
/*/
User Function SFMAINWS
Return

/*/{Protheus.doc} SFMAINWS
Estrutura REST API (StackFor)
@author Marcos Natã Santos
@since 24/06/2019
@type class
/*/
WSRESTFUL SFMAINWS DESCRIPTION "Serviços para aplicação mobile StackFor"
    WSDATA user as String
    WSDATA psw as String
    
    WSDATA filial as String
    WSDATA order as String

    WSMETHOD GET USER DESCRIPTION "Retorna os dados do usuário autenticado.";
        WSSYNTAX "/user/{user, psw}" PATH "/user"

    WSMETHOD GET ALLDOCS DESCRIPTION "Retorna documentos pendentes de aprovação.";
        WSSYNTAX "/alldocs" PATH "/alldocs"
    
    WSMETHOD GET DOCDETAIL DESCRIPTION "Retorna detalhes do documento pendente de aprovação.";
        WSSYNTAX "/doc/{filial, order}" PATH "/doc"

END WSRESTFUL

/*/{Protheus.doc} USER
Retorna os dados do usuário
@author Marcos Natã Santos
@since 24/06/2019
@version 1.0
@param oSelf, object
@return lRet, logic
@type Method
/*/
WSMETHOD GET USER QUERYPARAM user, psw WSRESTFUL SFMAINWS
    Local lRet        := .T.
    Local cUser       := Self:user
    Local cPsw        := Self:psw
    Local oSFResponse := Nil
    Local oSFUser     := Nil
    Local cJson		  := ""

    ::SetContentType("application/json")
    
    oSFUser := U_SFGET1(cUser, cPsw)

    If oSFUser <> Nil
        oSFResponse := SFResponse():New("ok", "autenticacao realizada com sucesso.", oSFUser)
    Else
        oSFResponse := SFResponse():New("error", "usuario ou senha invalidos.", Nil)
    EndIf

    cJson := LOWER(FWJsonSerialize(oSFResponse, .F.))

    ::SetResponse(cJson)

Return lRet

/*/{Protheus.doc} ALLDOCS
Retorna documentos pendentes de aprovação
@author Marcos Natã Santos
@since 25/11/2019
@version 1.0
@param oSelf, object
@return lRet, logic
@type Method
/*/
WSMETHOD GET ALLDOCS WSRESTFUL SFMAINWS
    Local lRet        := .T.
    Local oSFResponse := Nil
    Local aDocsAppr   := Nil
    Local cJson		  := ""

    ::SetContentType("application/json")
    
    aDocsAppr := U_SFGET2()

    If Len(aDocsAppr) > 0
        oSFResponse := SFResponse():New("ok", "documentos encontrados com sucesso.", aDocsAppr)
    Else
        oSFResponse := SFResponse():New("error", "documentos nao encontrados.", Nil)
    EndIf

    cJson := LOWER(FWJsonSerialize(oSFResponse, .F.))

    ::SetResponse(cJson)

Return lRet

/*/{Protheus.doc} DOCDETAIL
Retorna detalhes do documento pendente de aprovação
@author Marcos Natã Santos
@since 03/12/2019
@version 1.0
@param oSelf, object
@return lRet, logic
@type Method
/*/
WSMETHOD GET DOCDETAIL QUERYPARAM filial, order WSRESTFUL SFMAINWS
    Local lRet         := .T.
    Local cFil         := Self:filial
    Local cPedido      := Self:order
    Local oSFResponse  := Nil
    Local oSFDocDetail := Nil
    Local cJson		   := ""

    ::SetContentType("application/json")
    
    oSFDocDetail := U_SFGET3(cFil, cPedido)

    If oSFDocDetail <> Nil
        oSFResponse := SFResponse():New("ok", "Detalhes do documento encontrados com sucesso.", oSFDocDetail)
    Else
        oSFResponse := SFResponse():New("error", "Detalhes do documento nao encontrados.", Nil)
    EndIf

    cJson := LOWER(FWJsonSerialize(oSFResponse, .F.))

    ::SetResponse(cJson)

Return lRet
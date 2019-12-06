#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} SFGET2
Busca documentos pendentes de aprovação
@type User Function
@author Marcos Natã Santos
@since 25/11/2019
@version 1.0
@return aDocsAppr, array, Documentos pendente de aprovação
/*/
User Function SFGET2()
    Local oSFDocAppr := Nil
    Local aDocsAppr := {}
    Local cQry := ""
    Local nQtdReg := 0

    cQry := "SELECT CR_FILIAL FILIAL, " + CRLF
    cQry += "    CR_EMISSAO EMISSAO, " + CRLF
    cQry += "    CR_NUM PEDIDO, " + CRLF
    cQry += "    CR_NIVEL NIVEL, " + CRLF
    cQry += "    CR_TOTAL VALOR " + CRLF
    cQry += "FROM SCR010 " + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND CR_TIPO = 'PC' " + CRLF
    cQry += "AND CR_DATALIB = ' ' " + CRLF
    cQry += "AND CR_STATUS = '02' " + CRLF
    cQry += "AND CR_USER = '000300' " + CRLF
    cQry += "ORDER BY CR_FILIAL, CR_NUM " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("GET2") > 0
        GET2->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "GET2"

    GET2->(dbGoTop())
    COUNT TO nQtdReg
    GET2->(dbGoTop())

    If nQtdReg > 0
        While GET2->(!EOF())
            oSFDocAppr := SFDocAppr():New(GET2->FILIAL, GET2->EMISSAO, AllTrim(GET2->PEDIDO), GET2->NIVEL, GET2->VALOR)
            If oSFDocAppr <> Nil
                aAdd(aDocsAppr, oSFDocAppr)
                oSFDocAppr := Nil
            EndIf
            GET2->( dbSkip() )
        EndDo
    EndIf

    GET2->(DbCloseArea())

Return aDocsAppr
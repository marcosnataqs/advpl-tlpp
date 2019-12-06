#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} SFGET3
Busca detalhes do documento pendente de aprovação
@type User Function
@author Marcos Natã Santos
@since 03/12/2019
@version 1.0
@param cFil, char
@param cPedido, char
@return oDocDetail, array, Documentos pendente de aprovação
/*/
User Function SFGET3(cFil, cPedido)
    Local oDocDetail := Nil
    Local oDocItem := Nil
    Local aItems := {}
    Local cQry := ""
    Local nQtdReg := 0

    Default cFil := ""
    Default cPedido := ""

    cQry := "SELECT SC7.C7_NUM PEDIDO, " + CRLF
    cQry += "    SC7.C7_EMISSAO EMISSAO, " + CRLF
    cQry += "    SA2.A2_NOME FORNECEDOR, " + CRLF
    cQry += "    SE4.E4_DESCRI COND_PAGTO, " + CRLF
    cQry += "    CASE SC7.C7_MOEDA WHEN 1 THEN 'REAL' WHEN 2 THEN 'DOLAR' END MOEDA, " + CRLF
    cQry += "    (SELECT SUM(C7TOT.C7_TOTAL) FROM SC7010 C7TOT " + CRLF
    cQry += "        WHERE C7TOT.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "        AND C7TOT.C7_FILIAL = SC7.C7_FILIAL " + CRLF
    cQry += "        AND C7TOT.C7_NUM = SC7.C7_NUM) TOTAL_PEDIDO, " + CRLF
    cQry += "    SC7.C7_ITEM ITEM, " + CRLF
    cQry += "    SC7.C7_PRODUTO COD_PROD, " + CRLF
    cQry += "    SC7.C7_DESCRI DESCRI_PROD, " + CRLF
    cQry += "    SC7.C7_QUANT QUANT, " + CRLF
    cQry += "    SC7.C7_UM UNIDADE, " + CRLF
    cQry += "    SC7.C7_PRECO PRECO, " + CRLF
    cQry += "    SC7.C7_TOTAL TOTAL " + CRLF
    cQry += "FROM SC7010 SC7 " + CRLF
    cQry += "INNER JOIN SA2010 SA2 " + CRLF
    cQry += "    ON SA2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA2.A2_COD = SC7.C7_FORNECE " + CRLF
    cQry += "    AND SA2.A2_LOJA = SC7.C7_LOJA " + CRLF
    cQry += "INNER JOIN SE4010 SE4 " + CRLF
    cQry += "    ON SE4.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE4.E4_FILIAL = '"+ cFil +"' " + CRLF
    cQry += "    AND SE4.E4_CODIGO = SC7.C7_COND " + CRLF
    cQry += "WHERE SC7.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND C7_FILIAL = '"+ cFil +"' " + CRLF
    cQry += "AND C7_NUM = '"+ cPedido +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("GET3") > 0
        GET3->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "GET3"

    GET3->(dbGoTop())
    COUNT TO nQtdReg
    GET3->(dbGoTop())

    If nQtdReg > 0
        While GET3->(!EOF())
            oDocItem := SFDocItem():New(GET3->ITEM, AllTrim(GET3->COD_PROD), AllTrim(GET3->DESCRI_PROD),;
                GET3->QUANT, GET3->UNIDADE, GET3->PRECO, GET3->TOTAL)
            If oDocItem <> Nil
                aAdd(aItems, oDocItem)
                oDocItem := Nil
            EndIf
            GET3->( dbSkip() )
        EndDo

        GET3->(dbGoTop())
        oDocDetail := SFDocDetail():New(GET3->PEDIDO, GET3->EMISSAO, AllTrim(GET3->FORNECEDOR),;
            AllTrim(GET3->COND_PAGTO), AllTrim(GET3->MOEDA), GET3->TOTAL_PEDIDO, aItems)
    EndIf

    GET3->(DbCloseArea())

Return oDocDetail
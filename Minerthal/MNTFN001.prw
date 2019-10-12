#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} MNTFN001
Função para processar Campanha Comprou Ganhou
@type User Function
@author Marcos Natã Santos
@since 10/10/2019
@version 1.0
@param nOpc, numeric
@return lRet, logic
/*/
User Function MNTFN001(nOpc)
    Local lRet := .T.
    Local nX := 0
    Local nLenACols := 0
    Local aColsAux := Array(Len(aHeader)+1)
    Local nQtdGanha := 0
    
    Local nDELET := Len(aHeader)+1
    Local nC6ITEM := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
    Local nC6PRODUTO := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Local nC6QTDVEN := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
    Local nC6PRCVEN := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
    Local nC6VALOR := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})

    If INCLUI
        nLenACols := Len(aCols)
        For nX := 1 To nLenACols
            nQtdGanha := QtdGanha(aCols[nX][nC6PRODUTO], aCols[nX][nC6QTDVEN])

            If nQtdGanha > 0
                ACopy(aCols[nX], aColsAux)
                aColsAux[nC6ITEM] := PadL(Len(aCols)+1, 2, "0")
                aColsAux[nC6QTDVEN] := nQtdGanha
                aColsAux[nC6VALOR] := aColsAux[nC6QTDVEN] * aColsAux[nC6PRCVEN]

                AAdd(aCols, aColsAux)
                aColsAux := Array(Len(aHeader)+1)
            EndIf
        Next nX
    ElseIf ALTERA
        // TODO Criar processo na alteracao do pedido de venda
        // aCols[1][nDELET] := .T.
    EndIf
    
Return lRet

/*/{Protheus.doc} QtdGanha
Busca produto na campanha e calcula quantidade a bonificar
@type Static Function
@author Marcos Natã Santos
@since 11/10/2019
@version 1.0
@param cCodProd, char
@param nQtdVen, numeric
@return nQtdResult, numeric, Resultado do calculo da campanha
/*/
Static Function QtdGanha(cCodProd, nQtdVen)
    Local cQry := ""
    Local nQtdReg := 0
    Local nQtdResult := 0
    Local nMultiplo := 0
    Local nQtdGanha := 0
    Local nQtdReal := 0

    cQry := "SELECT ZA_COD, ZA_MULTIPL, ZA_QTDGAN " + CRLF
    cQry += "FROM " + RetSqlName("SZA") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZA_FILIAL = '"+ xFilial("SZA") +"' " + CRLF
    cQry += "AND ZA_COD = '"+ AllTrim(cCodProd) +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("CAMP") > 0
        CAMP->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "CAMP"

    CAMP->(dbGoTop())
    COUNT TO nQtdReg
    CAMP->(dbGoTop())

    If nQtdReg > 0
        //---------------------------------------------------------//
        //-- Analisa a quantidade que o cliente ganha no produto --//
        //---------------------------------------------------------//
        nMultiplo := CAMP->ZA_MULTIPL
        nQtdGanha := CAMP->ZA_QTDGAN
        nQtdReal := INT(nMultiplo / nQtdGanha)
        nQtdResult := INT(nQtdVen / nQtdReal)
    EndIf

    CAMP->(DbCloseArea())
    
Return nQtdResult
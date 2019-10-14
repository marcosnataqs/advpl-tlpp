#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} MNTFN001
Função para processar Campanha Comprou Ganhou
@type User Function
@author Marcos Natã Santos
@since 10/10/2019
@version 1.0
@return lRet, logic
/*/
User Function MNTFN001()
    Local lRet := .T.
    Local nX := 0
    Local aColsAux := Array(Len(aHeader)+1)
    Local nQtdGanha := 0
    Local lExecFun := ExecFunc()
    Local lReclAlt := SuperGetMv("XX_RECLALT", .F., .F.)
    Local cTES := ""
    Local cCF := ""

    Local nDELET := Len(aHeader)+1
    Local nC6ITEM := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
    Local nC6PRODUTO := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Local nC6QTDVEN := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
    Local nC6PRCVEN := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
    Local nC6VALOR := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
    Local nC6TES := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
    Local nC6CF := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"})
    Local nC6XCAMPAN := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_XCAMPAN"})

    If lExecFun
        //-- Busca o tipo de saída para bonificação --//
        cTES := TipoSaida(M->C5_CLIENTE, M->C5_LOJACLI)
        cCF := AllTrim(Posicione("SF4", 1, xFilial("SF4") + cTES, "F4_CF"))

        If !Empty(cTES) .And. !Empty(cCF)
            If INCLUI
                //-- calcula campanha e adiciona bonificação --//
                For nX := 1 To Len(aCols)
                    If !aCols[nX][nDELET]
                        nQtdGanha := QtdGanha(aCols[nX][nC6PRODUTO], aCols[nX][nC6QTDVEN])

                        If nQtdGanha > 0
                            ACopy(aCols[nX], aColsAux)
                            aColsAux[nC6ITEM] := PadL(Len(aCols)+1, 2, "0")
                            aColsAux[nC6QTDVEN] := nQtdGanha
                            aColsAux[nC6VALOR] := aColsAux[nC6QTDVEN] * aColsAux[nC6PRCVEN]
                            aColsAux[nC6TES] := cTES
                            aColsAux[nC6CF] := cCF
                            aColsAux[nC6XCAMPAN] := "S"

                            AAdd(aCols, aColsAux)
                            aColsAux := Array(Len(aHeader)+1)
                        EndIf
                    EndIf
                Next nX
            ElseIf ALTERA
                If lReclAlt
                    //-- Deleta itens gerado pela campanha anteriormente --//
                    For nX := 1 To Len(aCols)
                        If aCols[nX][nC6XCAMPAN] == "S"
                            aCols[nX][nDELET] := .T.
                        EndIf
                    Next nX

                    //-- Recalcula campanha e adiciona bonificação --//
                    For nX := 1 To Len(aCols)
                        If !aCols[nX][nDELET]
                            nQtdGanha := QtdGanha(aCols[nX][nC6PRODUTO], aCols[nX][nC6QTDVEN])

                            If nQtdGanha > 0
                                ACopy(aCols[nX], aColsAux)
                                aColsAux[nC6ITEM] := PadL(Len(aCols)+1, 2, "0")
                                aColsAux[nC6QTDVEN] := nQtdGanha
                                aColsAux[nC6VALOR] := aColsAux[nC6QTDVEN] * aColsAux[nC6PRCVEN]
                                aColsAux[nC6TES] := cTES
                                aColsAux[nC6CF] := cCF
                                aColsAux[nC6XCAMPAN] := "S"

                                AAdd(aCols, aColsAux)
                                aColsAux := Array(Len(aHeader)+1)
                            EndIf
                        EndIf
                    Next nX
                EndIf
            EndIf
        EndIf
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

/*/{Protheus.doc} ExecFunc
Avalia se deve executar a campanha de bonificação
@type Static Function
@author Marcos Natã Santos
@since 12/10/2019
@version 1.0
@return lRet, logic
/*/
Static Function ExecFunc()
    Local lRet := .F.
    Local cQry := ""
    Local nQtdReg := 0
    Local lAtiva := SuperGetMv("XX_ATVCAMP", .F., .F.)

    If lAtiva
        cQry := "SELECT ZA_COD " + CRLF
        cQry += "FROM " + RetSqlName("SZA") + CRLF
        cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "AND ZA_FILIAL = '"+ xFilial("SZA") +"' " + CRLF
        cQry := ChangeQuery(cQry)

        If Select("EXEC") > 0
            EXEC->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "EXEC"

        EXEC->(dbGoTop())
        COUNT TO nQtdReg
        EXEC->(dbGoTop())

        If nQtdReg > 0
            lRet := .T.
        EndIf

        EXEC->(DbCloseArea())
    EndIf

Return lRet

/*/{Protheus.doc} TipoSaida
Busca tipo de saída para pedido de venda
@type Static Function
@author Marcos Natã Santos
@since 13/10/2019
@version 1.0
@param cCodCli, char
@param cLojaCli, char
@return cTES, char
/*/
Static Function TipoSaida(cCodCli, cLojaCli)
    Local cTES := "583"
    Local cTESInt := SuperGetMv("XX_TESINT", .F., "583")
    Local cTESExt := SuperGetMv("XX_TESEXT", .F., "584")
    Local cUF := Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLojaCli, "A1_EST")

    If cUF == SM0->M0_ESTENT
        cTES := cTESInt
    Else
        cTES := cTESExt
    EndIf
Return cTES
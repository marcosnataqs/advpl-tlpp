#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} GP05R004

Pedidos Anual Clientes

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
User Function GP05R004() // U_GP05R004()
    Local cPerg := "GP05R004"

    AjustaSX1(cPerg)
	If Pergunte(cPerg, .T., "Pedidos Anual Clientes")
        ProcExport()
    EndIf

Return

/*/{Protheus.doc} ProcExport

ProcExport

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function ProcExport()
	Private cDataRec   := DTOC(Date())
	Private cDataRef   := SUBSTR(cDataRec, 7, 4) + SUBSTR(cDataRec, 4, 2) + SUBSTR(cDataRec, 1, 2)
	Private cTargetDir := "C:\Windows\Temp\"
    Private cWorkSheet := "PEDCLI" + MV_PAR01 + IIF(MV_PAR06 == MV_PAR07, "-" + MV_PAR06, "")
	Private cTableName := "Pedidos Anual Clientes " + MV_PAR01 + IIF(MV_PAR06 == MV_PAR07, " - " + MV_PAR06, "")

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")

Return

/*/{Protheus.doc} RunExport

RunExport

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function RunExport()
	Private oExcel    := FWMsExcel():New()
	Private oExcelApp := MsExcel():New()
	Private aHead     := {}
	Private aRow      := {}
	Private aRow1     := {}
	Private aRow2     := {}

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet, cTableName)
    oExcel:SetLineBgColor("#ffffff")
	oExcel:Set2LineBgColor("#ffffff")

	// Estrutura da exportação para excel
	Head()
	Body()

	oExcel:Activate()
	oExcel:GetXMLFile(cTargetDir + cWorkSheet + cDataRef + ".xls")
	oExcelApp:WorkBooks:Open(cTargetDir + cWorkSheet + cDataRef + ".xls")
	oExcelApp:SetVisible(.T.)

Return

/*/{Protheus.doc} Head

Head

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function Head()
    Local nX := 0

    aHead := {;
        "CODCLI",;
        "CLIENTE",;
        "COD",;
        "DESCRI",;
        "QTD_JANEIRO",;
        "PRC_MEDIO",;
        "VAL_JANEIRO",;
        "QTD_FEVEREIRO",;
        "PRC_MEDIO",;
        "VAL_FEVEREIRO",;
        "QTD_MARCO",;
        "PRC_MEDIO",;
        "VAL_MARCO",;
        "QTD_ABRIL",;
        "PRC_MEDIO",;
        "VAL_ABRIL",;
        "QTD_MAIO",;
        "PRC_MEDIO",;
        "VAL_MAIO",;
        "QTD_JUNHO",;
        "PRC_MEDIO",;
        "VAL_JUNHO",;
        "QTD_JULHO",;
        "PRC_MEDIO",;
        "VAL_JULHO",;
        "QTD_AGOSTO",;
        "PRC_MEDIO",;
        "VAL_AGOSTO",;
        "QTD_SETEMBRO",;
        "PRC_MEDIO",;
        "VAL_SETEMBRO",;
        "QTD_OUTUBRO",;
        "PRC_MEDIO",;
        "VAL_OUTUBRO",;
        "QTD_NOVEMBRO",;
        "PRC_MEDIO",;
        "VAL_NOVEMBRO",;
        "QTD_DEZEMBRO",;
        "PRC_MEDIO",;
        "VAL_DEZEMBRO",;
        "QTD_TOTAL",;
        "PRC_MEDIO",;
        "VAL_TOTAL",;
        "QTD_PED_PERIODO",;
        "QTD_MESES_PED",;
        "QTD_PED_MEDIO",;
        "VAL_PED_MEDIO";
    }

    For nX:= 1 to Len(aHead)
        If aHead[nX] $ "QTD_PED_PERIODO/QTD_MESES_PED"
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 2, 1)
        ElseIf SubStr(aHead[nX],1,3) $ "VAL"
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 3, 3)
        ElseIf SubStr(aHead[nX],1,3) $ "QTD"
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 3, 1)
        ElseIf SubStr(aHead[nX],1,3) $ "PRC"
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 2, 3)
        Else
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 1, 1)
        EndIf
    Next

Return

/*/{Protheus.doc} Body

Body

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function Body()
    Local i         := 0
    Local nMeses    := 0
    Local nSoma     := 0
    Local nQtdTotal := 0
    Local nX        := 0
    Local aDados    := {}
    Local nQtdPed   := 0
    Local cCodCli   := ""
    Local aTotal    := {}
    
    Private aTotGeral := {}
	Private nY
	
    aRow := Array(Len(aHead))

    //-----------------------------------------
    //-- Busca dados das notas fiscais de saída
    //-----------------------------------------
	If BuscaDados()

        While QRY->(!EOF())
            For i := 1 To (Len(aHead)-7)
                If .Not. (SubStr(aHead[i],1,3) $ "PRC")
                    nY := i
                    aRow[i] := &("QRY->" + &("aHead[nY]"))
                EndIf
            Next i

            aRow[41] := 0
            aRow[42] := 0
            aRow[43] := 0
            aRow[44] := 0
            aRow[45] := 0
            aRow[46] := 0
            aRow[47] := 0

            AADD(aDados, aRow)
            aRow := Array(Len(aHead))

            QRY->(DbSkip())
        EndDo

        QRY->(DbCloseArea())
    EndIf

    //---------------------------//
    //-- Calcula totalizadores --//
    //---------------------------//
    ProcRegua(Len(aDados))
    cCodCli   := AllTrim(aDados[1][1])
    aTotal    := Array(Len(aHead))
    aTotGeral := Array(Len(aHead))
    For i := 1 To Len(aDados)
        IncProc(aDados[i][1])
        For nX := 1 To Len(aDados[i])
            If SubStr(aHead[nX],1,3) == "QTD"
                If aDados[i][nX] > 0
                    nMeses++
                EndIf
                nQtdTotal += aDados[i][nX]
            EndIf
            If SubStr(aHead[nX],1,3) == "VAL"
                nSoma += aDados[i][nX]
            EndIf
            If SubStr(aHead[nX],1,3) == "PRC"
                aDados[i][nX] := aDados[i][nX+1] / aDados[i][nX-1]
            EndIf
        Next nX

        nQtdPed := BuscaPed(aDados[i][3],SubStr(aDados[i][1],1,6),SubStr(aDados[i][1],7,2))

        aDados[i][41] := nQtdTotal
        aDados[i][42] := nSoma / nQtdTotal
        aDados[i][43] := nSoma
        aDados[i][44] := nQtdPed
        aDados[i][45] := nMeses
        aDados[i][46] := nQtdTotal / nQtdPed
        aDados[i][47] := nSoma / nQtdPed

        If aDados[i][1] <> cCodCli
            oExcel:AddRow(cWorkSheet, cTableName, aTotal)
            cCodCli := AllTrim(aDados[i][1])
            CalcTot(aTotal) //-- Calcula total geral por coluna
            aTotal  := Array(Len(aHead))
            For nX := 1 To Len(aDados[i])
                If SubStr(aHead[nX],1,3) == "VAL" .And. .Not. (aHead[nX] $ "VAL_PED_MEDIO")
                	If Empty(aTotal[nX])
                		aTotal[nX] := aDados[i][nX]
                	Else
                		aTotal[nX] += aDados[i][nX]
                	EndIf
                EndIf
            Next nX
        Else
            cCodCli := AllTrim(aDados[i][1])
            For nX := 1 To Len(aDados[i])
                If SubStr(aHead[nX],1,3) == "VAL" .And. .Not. (aHead[nX] $ "VAL_PED_MEDIO")
                	If Empty(aTotal[nX])
                		aTotal[nX] := aDados[i][nX]
                	Else
                		aTotal[nX] += aDados[i][nX]
                	EndIf
                EndIf
            Next nX
        EndIf

        oExcel:AddRow(cWorkSheet, cTableName, aDados[i])

        nQtdTotal := nSoma := nMeses := 0

        //-------------------------//
        //-- Imprime total geral --//
        //-------------------------//
        If i = Len(aDados)
        	CalcTot(aTotal)
        	oExcel:AddRow(cWorkSheet, cTableName, aTotal)
        	oExcel:AddRow(cWorkSheet, cTableName, aTotGeral)
        EndIf

    Next i

Return

/*/{Protheus.doc} BuscaDados

Busca dados das notas de saída

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function BuscaDados()
    Local cQry := ""
    Local lRet := .F.

    cQry := "SELECT " + CRLF
    cQry += "    SA1.A1_COD || SA1.A1_LOJA CODCLI, " + CRLF
    cQry += "    SA1.A1_NREDUZ CLIENTE, " + CRLF
    cQry += "    SC6.C6_PRODUTO COD, " + CRLF
    cQry += "    SB1.B1_DESC DESCRI, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '01' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_JANEIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '01' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_JANEIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '02' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_FEVEREIRO,  " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '02' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_FEVEREIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '03' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_MARCO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '03' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_MARCO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '04' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_ABRIL, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '04' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_ABRIL, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '05' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_MAIO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '05' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_MAIO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '06' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_JUNHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '06' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_JUNHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '07' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_JULHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '07' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_JULHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '08' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_AGOSTO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '08' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_AGOSTO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '09' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_SETEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '09' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_SETEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '10' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_OUTUBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '10' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_OUTUBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '11' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_NOVEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '11' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_NOVEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '12' THEN (((SC6.C6_QTDVEN))) ELSE 0 END ), 4 ) QTD_DEZEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '12' THEN (((SC6.C6_VALOR))) ELSE 0 END ), 4 ) VAL_DEZEMBRO " + CRLF
    cQry += "FROM "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
    cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
    cQry += "    AND SC5.C5_NUM = SC6.C6_NUM " + CRLF
    cQry += "    AND SC5.C5_CLIENTE = SC6.C6_CLI " + CRLF
    cQry += "    AND SC5.C5_LOJACLI = SC6.C6_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SB1") +" SB1 " + CRLF
    cQry += "    ON SB1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' " + CRLF
    cQry += "    AND SB1.B1_COD = SC6.C6_PRODUTO " + CRLF
    cQry += "    AND SB1.B1_TIPO = 'PA' " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' " + CRLF
    cQry += "    AND SA1.A1_COD = SC5.C5_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SC5.C5_LOJACLI " + CRLF
    cQry += "WHERE SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "    AND SUBSTR( SC5.C5_EMISSAO, 1, 4 ) = '"+ MV_PAR01 +"' " + CRLF
    cQry += "    AND SC5.C5_CLIENTE BETWEEN '"+ MV_PAR02 +"' AND '"+ MV_PAR03 +"' " + CRLF
    cQry += "    AND SC6.C6_PRODUTO BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' " + CRLF
    cQry += "    AND SA1.A1_EST BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' " + CRLF
    cQry += "GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, SC6.C6_PRODUTO, SB1.B1_DESC " + CRLF
    cQry += "ORDER BY SA1.A1_NREDUZ, SC6.C6_PRODUTO " + CRLF
    cQry := ChangeQuery(cQry)

    MemoWrite("C:\Users\marcosnqs\Desktop\querys\GP05R004_BuscaDados.sql", cQry)
    
    If Select("QRY") > 0
        QRY->(DbCloseArea())
    EndIf
    
    TcQuery cQry New Alias "QRY"
    
    QRY->(dbGoTop())
    COUNT TO NQTREG
    QRY->(dbGoTop())

    If NQTREG > 0
        lRet := .T.
    Else
        lRet := .F.
        QRY->(DbCloseArea())
    EndIf

Return lRet

/*/{Protheus.doc} BuscaPed

Busca dados dos pedidos de venda

@author Marcos Natã Santos
@since 17/07/2018
@version 12.1.17
@type function
/*/
Static Function BuscaPed(cProd,cCodCli,cLoja)
    Local cQry := ""
    Local nRet := 0

    cQry := "SELECT DISTINCT SC6.C6_NUM " + CRLF
    cQry += "FROM "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
    cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
    cQry += "    AND SC5.C5_NUM = SC6.C6_NUM " + CRLF
    cQry += "    AND SC5.C5_CLIENTE = SC6.C6_CLI " + CRLF
    cQry += "    AND SC5.C5_LOJACLI = SC6.C6_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' " + CRLF
    cQry += "    AND SA1.A1_COD = SC5.C5_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SC5.C5_LOJACLI " + CRLF
    cQry += "WHERE SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "AND SC6.C6_PRODUTO = '"+ cProd +"' " + CRLF
    cQry += "AND SUBSTR(SC5.C5_EMISSAO,1,4) = '"+ MV_PAR01 +"' " + CRLF
    cQry += "AND SC6.C6_CLI = '"+ cCodCli +"' " + CRLF
    cQry += "AND SC6.C6_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "AND SA1.A1_EST BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' " + CRLF
    cQry := ChangeQuery(cQry)
    
    If Select("TMP1") > 0
        TMP1->(DbCloseArea())
    EndIf
    
    TcQuery cQry New Alias "TMP1"
    
    TMP1->(dbGoTop())
    COUNT TO NQTREG
    TMP1->(dbGoTop())

    If NQTREG > 0
        nRet := NQTREG
    EndIf

Return nRet

/*/{Protheus.doc} CalcTot

Calcula total do relatório

@author Marcos Natã Santos
@since 25/07/2018
@version 12.1.17
@type function
/*/
Static Function CalcTot(aTotal)
	Local nX := 0
	
	For nX := 1 To Len(aTotal)
		If Empty(aTotGeral[nX])
			aTotGeral[nX] := aTotal[nX]
		Else
			aTotGeral[nX] += aTotal[nX]
		EndIf
	Next nX
	
Return

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 12/07/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","Ano?"        ,"MV_CH1","C",04,0,0,"G","MV_PAR01","","","",""   ,""})
	aAdd(aRegs,{"02","De cliente?" ,"MV_CH2","C",06,0,0,"G","MV_PAR02","","","","SA1CLI",""})
    aAdd(aRegs,{"03","Até cliente?","MV_CH3","C",06,0,0,"G","MV_PAR03","","","","SA1CLI",""})
    aAdd(aRegs,{"04","De produto?" ,"MV_CH4","C",15,0,0,"G","MV_PAR04","","","","SB1",""})
    aAdd(aRegs,{"05","Até produto?","MV_CH5","C",15,0,0,"G","MV_PAR05","","","","SB1",""})
    aAdd(aRegs,{"06","De Estado?"  ,"MV_CH6","C",02,0,0,"G","MV_PAR06","","","",""   ,""})
    aAdd(aRegs,{"07","Até Estado?" ,"MV_CH7","C",02,0,0,"G","MV_PAR07","","","",""   ,""})

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		dbSeek(cPerg+aRegs[i][1])
		If !Found()
			RecLock("SX1",!Found())
			SX1->X1_GRUPO   := cPerg
			SX1->X1_ORDEM   := aRegs[i][01]
			SX1->X1_PERGUNT := aRegs[i][02]
			SX1->X1_VARIAVL := aRegs[i][03]
			SX1->X1_TIPO    := aRegs[i][04]
			SX1->X1_TAMANHO := aRegs[i][05]
			SX1->X1_DECIMAL := aRegs[i][06]
			SX1->X1_PRESEL  := aRegs[i][07]
			SX1->X1_GSC     := aRegs[i][08]
			SX1->X1_VAR01   := aRegs[i][09]
			SX1->X1_DEF01   := aRegs[i][10]
			SX1->X1_DEF02   := aRegs[i][11]
			SX1->X1_DEF03   := aRegs[i][12]
			SX1->X1_F3      := aRegs[i][13]
			SX1->X1_VALID   := aRegs[i][14]
			MsUnlock()
		Endif
	Next

	RestArea(aArea)

Return
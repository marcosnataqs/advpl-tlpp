#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} GP05R006

Pedidos x Faturamentos Analítico

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
User Function GP05R006() // U_GP05R006()
    Local cPerg := "GP05R006"

    AjustaSX1(cPerg)
	If Pergunte(cPerg, .T., "Pedidos x Faturamentos Analítico")
        ProcExport()
    EndIf

Return

/*/{Protheus.doc} ProcExport

ProcExport

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
Static Function ProcExport()
    Local cUF          := IIF(MV_PAR06 == MV_PAR07, " - " + MV_PAR06, "")
    Local cRepr        := IIF(MV_PAR08 == MV_PAR09, " - " + Posicione("SA3", 1, xFilial("SA3") + MV_PAR08, "A3_NOME"), "")

	Private cDataRec   := DTOC(Date())
	Private cDataRef   := SUBSTR(cDataRec, 7, 4) + SUBSTR(cDataRec, 4, 2) + SUBSTR(cDataRec, 1, 2)
	Private cTargetDir := "C:\Windows\Temp\"
    Private cWorkSheet := "PEDXFAT-ANL" + MV_PAR01
	Private cTableName := "Pedidos x Faturamentos Analítico " + MV_PAR01 + IIF(!Empty(cUF), cUF, "") + IIF(!Empty(cRepr), cRepr, "")

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")

Return

/*/{Protheus.doc} RunExport

RunExport

@author Marcos Natã Santos
@since 25/09/2018
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
@since 25/09/2018
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
        "PED_JANEIRO",;
        "DIFERENÇA",;
        "FAT_JANEIRO",;
        "PED_FEVEREIRO",;
        "DIFERENÇA",;
        "FAT_FEVEREIRO",;
        "PED_MARCO",;
        "DIFERENÇA",;
        "FAT_MARCO",;
        "PED_ABRIL",;
        "DIFERENÇA",;
        "FAT_ABRIL",;
        "PED_MAIO",;
        "DIFERENÇA",;
        "FAT_MAIO",;
        "PED_JUNHO",;
        "DIFERENÇA",;
        "FAT_JUNHO",;
        "PED_JULHO",;
        "DIFERENÇA",;
        "FAT_JULHO",;
        "PED_AGOSTO",;
        "DIFERENÇA",;
        "FAT_AGOSTO",;
        "PED_SETEMBRO",;
        "DIFERENÇA",;
        "FAT_SETEMBRO",;
        "PED_OUTUBRO",;
        "DIFERENÇA",;
        "FAT_OUTUBRO",;
        "PED_NOVEMBRO",;
        "DIFERENÇA",;
        "FAT_NOVEMBRO",;
        "PED_DEZEMBRO",;
        "DIFERENÇA",;
        "FAT_DEZEMBRO",;
        "PED_TOTAL",;
        "DIFERENÇA",;
        "FAT_TOTAL";
    }

    For nX:= 1 to Len(aHead)
        If SubStr(aHead[nX],1,3) $ "PED/FAT/DIF"
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 3, 2, .T.)
        Else
            oExcel:AddColumn(cWorkSheet, cTableName, aHead[nX], 1, 1)
        EndIf
    Next

Return

/*/{Protheus.doc} Body

Body

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
Static Function Body()
    Local i         := 0
    Local nX        := 0
    Local aDados    := {}
    Local aDev      := {}
    Local nCount    := 1
    Local nTotalPed := 0
    Local nTotalFat := 0

	Private nY
	
    aRow := Array(Len(aHead))

    //-----------------------------------------
    //-- Busca todos os pedidos
    //-----------------------------------------
	If BuscaPed()

        ProcRegua(QRY1->(RecCount()))
        While QRY1->(!EOF())
            IncProc(QRY1->CODCLI)
            For i := 1 To (Len(aHead)-3)
                If SubStr(aHead[i],1,3) $ "PED"
                    nY := i
                    aRow[i] := &("QRY1->" + &("aHead[nY]"))
                    nTotalPed += aRow[i]
                ElseIf SubStr(aHead[i],1,7) $ "CODCLI/CLIENTE/COD/DESCRI"
                    nY := i
                    aRow[i] := &("QRY1->" + &("aHead[nY]"))
                EndIf
            Next i

            aRow[41] := nTotalPed

            AADD(aDados, aRow)
            aDev := BuscaDev(SubStr(QRY1->CODCLI,1,6), SubStr(QRY1->CODCLI,7,2), QRY1->COD)
            If Len(aDev) > 0
                AADD(aDados, aDev)
                aDev := {}
            EndIf
            aRow      := Array(Len(aHead))
            nTotalPed := 0

            QRY1->(DbSkip())
        EndDo

        QRY1->(DbCloseArea())
    EndIf

    //-----------------------------------------
    //-- Busca todos os faturamentos
    //-----------------------------------------
	If BuscaFat()

        While QRY->(!EOF())
            For nH := 1 To Len(aDados)
                If QRY->CODCLI $ aDados[nH][1] .And. QRY->COD $ aDados[nH][3]
                    For i := 1 To (Len(aHead)-3)
                        If aDados[nH][4] <> "DEVOLUCOES"
                            If SubStr(aHead[i],1,3) $ "FAT"
                                nY := i
                                aDados[nH][i] := &("QRY->" + &("aHead[nY]"))
                                nTotalFat += aDados[nH][i]
                            EndIf
                        EndIf
                    Next i

                    aDados[nH][43] := nTotalFat
                    Exit
                EndIf
            Next nH

            QRY->(DbSkip())
            nTotalFat := 0
        EndDo

        QRY->(DbCloseArea())
    EndIf

    //------------------------
    //-- Imprimi linhas
    //------------------------
    For i := 1 To Len(aDados)
        For nX := 1 To (Len(aHead))
            If SubStr(aHead[nX],1,3) $ "DIF"
                If aDados[i][4] <> "DEVOLUCOES"
                    IIF(Empty(aDados[i][nX-1]), aDados[i][nX-1] := 0,)
                    IIF(Empty(aDados[i][nX+1]), aDados[i][nX+1] := 0,)
                    aDados[i][nX] := aDados[i][nX-1] - aDados[i][nX+1] // PED - FAT = DIFERENÇA
                EndIf
            EndIf
        Next nX
        oExcel:AddRow(cWorkSheet, cTableName, aDados[i])
    Next i

Return

/*/{Protheus.doc} BuscaFat

Busca todos faturamentos

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
Static Function BuscaFat()
    Local cQry := ""
    Local lRet := .F.

    cQry := "SELECT SA1.A1_COD || SA1.A1_LOJA CODCLI, " + CRLF
    cQry += "    SA1.A1_NREDUZ CLIENTE, " + CRLF
    cQry += "    SD2.D2_COD COD, " + CRLF
    cQry += "    SB1.B1_DESC DESCRI, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '01' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_JANEIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '02' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_FEVEREIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '03' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_MARCO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '04' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_ABRIL, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '05' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_MAIO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '06' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_JUNHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '07' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_JULHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '08' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_AGOSTO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '09' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_SETEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '10' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_OUTUBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '11' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_NOVEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D2_EMISSAO, 5, 2 ) = '12' THEN ( D2_QUANT ) ELSE 0 END ), 4 ) FAT_DEZEMBRO " + CRLF
    cQry += "FROM "+ RetSqlName("SD2") +" SD2 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SB1") +" SB1 " + CRLF
    cQry += "    ON SB1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' " + CRLF
    cQry += "    AND SB1.B1_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SB1.B1_TIPO = 'PA' " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SF2") +" SF2 " + CRLF
    cQry += "    ON SF2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"' " + CRLF
    cQry += "    AND SF2.F2_DOC = SD2.D2_DOC " + CRLF
    cQry += "    AND SF2.F2_SERIE = SD2.D2_SERIE " + CRLF
    cQry += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SF2.F2_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' " + CRLF
    cQry += "    AND SA1.A1_COD = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
    cQry += "    AND SD2.D2_TIPO <> 'D' " + CRLF
    cQry += "    AND SUBSTR( SD2.D2_EMISSAO, 1, 4 ) = '"+ MV_PAR01 +"' " + CRLF
    cQry += "    AND SA1.A1_COD BETWEEN '"+ MV_PAR02 +"' AND '"+ MV_PAR03 +"' " + CRLF
    cQry += "    AND SD2.D2_COD BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' " + CRLF
    cQry += "    AND SD2.D2_EST BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' " + CRLF
    cQry += "    AND SF2.F2_VEND1 BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR09 +"' " + CRLF
    cQry += "GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, D2_COD, SB1.B1_DESC " + CRLF
    cQry += "ORDER BY SA1.A1_NREDUZ, SD2.D2_COD " + CRLF
    cQry := ChangeQuery(cQry)
    
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

/*/{Protheus.doc} BuscaDev

Busca devoluções no período

@author Marcos Natã Santos
@since 04/10/2018
@version 12.1.17
@type function
/*/
Static Function BuscaDev(cCli,cLoja,cProduto)
    Local cQry
    Local aDev := {}

    cQry := "SELECT SA1.A1_COD || SA1.A1_LOJA CODCLI, " + CRLF
    cQry += "    SA1.A1_NREDUZ CLIENTE, " + CRLF
    cQry += "    SD2.D2_COD COD, " + CRLF
    cQry += "    SB1.B1_DESC DESCRI, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '01' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_JANEIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '02' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_FEVEREIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '03' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_MARCO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '04' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_ABRIL, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '05' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_MAIO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '06' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_JUNHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '07' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_JULHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '08' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_AGOSTO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '09' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_SETEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '10' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_OUTUBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '11' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_NOVEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( D1_EMISSAO, 5, 2 ) = '12' THEN ( NVL(D1_QUANT, 0) ) ELSE 0 END ), 4 ) DEV_DEZEMBRO " + CRLF
    cQry += "FROM "+ RetSqlName("SD2") +" SD2 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SB1") +" SB1 " + CRLF
    cQry += "    ON SB1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' " + CRLF
    cQry += "    AND SB1.B1_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SB1.B1_TIPO = 'PA' " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SF2") +" SF2 " + CRLF
    cQry += "    ON SF2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"' " + CRLF
    cQry += "    AND SF2.F2_DOC = SD2.D2_DOC " + CRLF
    cQry += "    AND SF2.F2_SERIE = SD2.D2_SERIE " + CRLF
    cQry += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SF2.F2_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' " + CRLF
    cQry += "    AND SA1.A1_COD = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SD1") +" SD1 " + CRLF
    cQry += "    ON SD1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD1.D1_FILIAL = '"+ xFilial("SD1") +"' " + CRLF
    cQry += "    AND SD1.D1_TIPO = 'D' " + CRLF
    cQry += "    AND SD1.D1_NFORI = D2_DOC " + CRLF
    cQry += "    AND SD1.D1_SERIORI = D2_SERIE " + CRLF
    cQry += "    AND SD1.D1_FORNECE = D2_CLIENTE " + CRLF
    cQry += "    AND SD1.D1_LOJA = D2_LOJA " + CRLF
    cQry += "    AND SD1.D1_COD = D2_COD " + CRLF
    cQry += "    AND SD1.D1_LOTECTL = D2_LOTECTL " + CRLF
    cQry += "    AND SD1.D1_QUANT = D2_QUANT " + CRLF
    cQry += "    AND SD1.D1_TOTAL = D2_TOTAL " + CRLF
    cQry += "WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
    cQry += "    AND SD2.D2_TIPO <> 'D' " + CRLF
    cQry += "    AND SUBSTR( SD2.D2_EMISSAO, 1, 4 ) = '2018' " + CRLF
    cQry += "    AND SA1.A1_COD = '"+ cCli +"' " + CRLF
    cQry += "    AND SA1.A1_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "    AND SD2.D2_COD = '"+ cProduto +"' " + CRLF
    cQry += "    AND SF2.F2_VEND1 BETWEEN ' ' AND 'ZZZZZZ' " + CRLF
    cQry += "GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, D2_COD, SB1.B1_DESC " + CRLF
    cQry += "ORDER BY SA1.A1_NREDUZ, SD2.D2_COD " + CRLF
    cQry := ChangeQuery(cQry)
    
    If Select("QRYDEV") > 0
        QRYDEV->(DbCloseArea())
    EndIf
    
    TcQuery cQry New Alias "QRYDEV"
    
    QRYDEV->(dbGoTop())
    COUNT TO NQTREG
    QRYDEV->(dbGoTop())

    If NQTREG > 0
        AADD(aDev, QRYDEV->CODCLI)
        AADD(aDev, QRYDEV->CLIENTE)
        AADD(aDev, QRYDEV->COD)
        AADD(aDev, "DEVOLUCOES")
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_JANEIRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_FEVEREIRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_MARCO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_ABRIL * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_MAIO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_JUNHO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_JULHO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_AGOSTO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_SETEMBRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_OUTUBRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_NOVEMBRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, QRYDEV->DEV_DEZEMBRO * -1)
        AADD(aDev, 0)
        AADD(aDev, 0)
        AADD(aDev, 0)
    EndIf

    QRYDEV->(DbCloseArea())
    
Return aDev

/*/{Protheus.doc} BuscaPed

Busca todos os pedidos

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
Static Function BuscaPed()
    Local cQry := ""
    Local lRet := .F.

    cQry := "SELECT " + CRLF
    cQry += "    SA1.A1_COD || SA1.A1_LOJA CODCLI, " + CRLF
    cQry += "    SA1.A1_NREDUZ CLIENTE, " + CRLF
    cQry += "    SC6.C6_PRODUTO COD, " + CRLF
    cQry += "    SB1.B1_DESC DESCRI, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '01' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_JANEIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '02' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_FEVEREIRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '03' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_MARCO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '04' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_ABRIL, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '05' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_MAIO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '06' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_JUNHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '07' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_JULHO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '08' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_AGOSTO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '09' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_SETEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '10' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_OUTUBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '11' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_NOVEMBRO, " + CRLF
    cQry += "    ROUND( SUM ( CASE WHEN SUBSTR( SC5.C5_EMISSAO, 5, 2 ) = '12' THEN (SC6.C6_QTDVEN) ELSE 0 END ), 4 ) PED_DEZEMBRO " + CRLF
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
    cQry += "    AND SC5.C5_VEND1 BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR09 +"' " + CRLF
    cQry += "GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, SC6.C6_PRODUTO, SB1.B1_DESC " + CRLF
    cQry += "ORDER BY SA1.A1_NREDUZ, SC6.C6_PRODUTO " + CRLF
    cQry := ChangeQuery(cQry)
    
    If Select("QRY1") > 0
        QRY1->(DbCloseArea())
    EndIf
    
    TcQuery cQry New Alias "QRY1"
    
    QRY1->(dbGoTop())
    COUNT TO NQTREG
    QRY1->(dbGoTop())

    If NQTREG > 0
        lRet := .T.
    Else
        lRet := .F.
        QRY1->(DbCloseArea())
    EndIf

Return lRet

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 25/09/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","Ano?"               ,"MV_CH1","C",04,0,0,"G","MV_PAR01","","","",""   ,""})
    aAdd(aRegs,{"02","De cliente?"        ,"MV_CH2","C",06,0,0,"G","MV_PAR02","","","","SA1CLI",""})
    aAdd(aRegs,{"03","Até cliente?"       ,"MV_CH3","C",06,0,0,"G","MV_PAR03","","","","SA1CLI",""})
    aAdd(aRegs,{"04","De produto?"        ,"MV_CH4","C",15,0,0,"G","MV_PAR04","","","","SB1",""})
    aAdd(aRegs,{"05","Até produto?"       ,"MV_CH5","C",15,0,0,"G","MV_PAR05","","","","SB1",""})
    aAdd(aRegs,{"06","De Estado?"         ,"MV_CH6","C",02,0,0,"G","MV_PAR06","","","",""   ,""})
    aAdd(aRegs,{"07","Até Estado?"        ,"MV_CH7","C",02,0,0,"G","MV_PAR07","","","",""   ,""})
    aAdd(aRegs,{"08","De representante?"  ,"MV_CH8","C",06,0,0,"G","MV_PAR08","","","","SA3",""})
    aAdd(aRegs,{"09","Até representante?" ,"MV_CH9","C",06,0,0,"G","MV_PAR09","","","","SA3",""})

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
#Include "PROTHEUS.CH"
#Include 'TBICONN.CH'
#Include 'TOPCONN.CH'

/*/{Protheus.doc} RCOMR001

Relatório de Despesas para Setor Compras
Cópia do fonte RFINR001

@author Marcos Natã Santos
@since 22/11/2018
@version 12.1.17
@type function
/*/
User Function RCOMR001()
	Local oReport
	Local cPerg  := 'RCOMR001'
	
	AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)
	
	oReport := ReportDef(cPerg)
	oReport:printDialog()

Return

/*/{Protheus.doc} ReportDef

ReportDef

@author Marcos Natã Santos
@since 22/11/2018
@version 12.1.17
@type function
/*/
Static Function ReportDef(cPerg)
	Local cTitle  := "Relatório de Despesas Compras"
	Local cHelp   := "Permite gerar relatório de posição financeira do Contas a Pagar (Compras)"
	
	Local oReport
	Local oSection1
	
	oReport	:= TReport():New('RCOMR001',cTitle,cPerg,{|oReport| ReportPrint(oReport)},cHelp)

	oSection1 := TRSection():New(oReport,"Despesas Compras")
    TRCell():New(oSection1,"C7_EMISSAO","", "Emissao", PesqPict("SC7", "C7_EMISSAO") , TamSX3("C7_EMISSAO")[1] , NIL)
	TRCell():New(oSection1,"E2_VENCREA","", "Vencto", PesqPict("SE2", "E2_VENCREA") , TamSX3("E2_VENCREA")[1] , NIL)
	TRCell():New(oSection1,"C1_SOLICIT","", "Solicitante", PesqPict("SC1", "C1_SOLICIT") , TamSX3("C1_SOLICIT")[1] , NIL)
	TRCell():New(oSection1,"C7_XUSERNO","", "Comprador", PesqPict("SC7", "C7_XUSERNO") , TamSX3("C7_XUSERNO")[1] , NIL)
    TRCell():New(oSection1,"CTT_DESC01","", "Centro Custo", PesqPict("CTT", "CTT_DESC01") , TamSX3("CTT_DESC01")[1] , NIL)
	TRCell():New(oSection1,"E2_NUM","", "Ped Compra", PesqPict("SE2", "E2_NUM") , TamSX3("E2_NUM")[1] , NIL)
	TRCell():New(oSection1,"E2_PARCELA","", "Parc.", PesqPict("SE2", "E2_PARCELA") , TamSX3("E2_PARCELA")[1] , NIL)
    TRCell():New(oSection1,"C7_ITEM","", "Item PC", PesqPict("SC7", "C7_ITEM") , TamSX3("C7_ITEM")[1] , NIL)
    TRCell():New(oSection1,"B1_DESC","", "Produto", PesqPict("SB1", "B1_DESC") , TamSX3("B1_DESC")[1] , NIL)
    TRCell():New(oSection1,"E4_DESCRI","", "Cond. Pag.", PesqPict("SE4", "E4_DESCRI") , TamSX3("E4_DESCRI")[1] , NIL)
	TRCell():New(oSection1,"A2_COD","", "Cod Forn", PesqPict("SA2", "A2_COD") , TamSX3("A2_COD")[1] , NIL)
	TRCell():New(oSection1,"A2_LOJA","", "Loja", PesqPict("SA2", "A2_LOJA") , TamSX3("A2_LOJA")[1] , NIL)
	TRCell():New(oSection1,"A2_NOME","", "Fornecedor", PesqPict("SA2", "A2_NOME") , TamSX3("A2_NOME")[1] , NIL)
	TRCell():New(oSection1,"E1_SALDO","", "Previsto", PesqPict("SE1", "E1_SALDO") , TamSX3("E1_SALDO")[1] , NIL)
	TRCell():New(oSection1,"E2_SALDO","", "Real", PesqPict("SE2", "E2_SALDO") , TamSX3("E2_SALDO")[1] , NIL)
	TRCell():New(oSection1,"TOTAL","", "Total", "@E 99,999,999.99", 13, NIL)

Return oReport

/*/{Protheus.doc} ReportPrint

ReportPrint

@author Marcos Natã Santos
@since 22/11/2018
@version 12.1.17
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""
	Local dData     := date(), dDataTx := date(), aVenc := {}, ix := 0
	Local lF021DtFl := Existblock("FC021DTF")
    Local aDados    := {}
    Local nI        := 0

    //-----------------------//
    //-- Pedidos de Compra --//
    //-----------------------//
    cQuery := " SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_CC, C7_COND, CTT_DESC01, A2_NOME, C7_FORNECE, C7_LOJA, C7_DATPRF, C7_XDTCX, C7_MOEDA, C7_TXMOEDA, C7_QUANT, C7_QUJE, C7_TES, C7_EMISSAO, "
    cQuery += "  C7_NUMSC, C7_ITEMSC, C7_XUSERNO, "
    cQuery += "  SUM( ROUND ((C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_VALIPI)-C7_VLDESC,2)) E1_SALDO "
    cQuery += "	FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("CTT") + " CTT, " + RetSqlName("SE4") + " SE4, " + RetSqlName("SC7") + " SC7 "
    cQuery += "	WHERE "
    cQuery += " SA2.D_E_L_E_T_ = ' ' AND CTT.D_E_L_E_T_ = ' ' AND SE4.D_E_L_E_T_ = ' ' AND SC7.D_E_L_E_T_ = ' ' "
    cQuery += " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
    cQuery += " AND SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQuery += " AND SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA "
    cQuery += " AND (SC7.C7_QUANT-SC7.C7_QUJE) > 0 AND SC7.C7_FLUXO  <> 'N' "
    cQuery += " AND SC7.C7_COND = SE4.E4_CODIGO AND ( (CTT.CTT_CUSTO = SC7.C7_CC) OR (SC7.C7_CC = '' AND CTT.CTT_CUSTO = '999999') ) "
    cQuery += " AND C7_CONAPRO = 'L' "
    cQuery += " AND SC7.C7_QUJE < SC7.C7_QUANT AND SC7.C7_RESIDUO <> 'S' "
    cQuery += " GROUP BY C7_NUM, C7_ITEM, C7_PRODUTO, C7_CC, C7_COND, CTT_DESC01, A2_NOME,C7_FORNECE, C7_LOJA, C7_DATPRF, C7_XDTCX, C7_MOEDA, C7_TXMOEDA, C7_QUANT, C7_QUJE, C7_TES, C7_EMISSAO, C7_NUMSC, C7_ITEMSC, C7_XUSERNO "
    cQuery += " ORDER BY C7_NUM, C7_ITEM "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XPED",.T.,.T.)
    MemoWrite("C:\Users\Marcos\Desktop\Querys\RCOMR001.sql", cQuery)

    _cNumero   := ''
    _cPrefixo  := ''
    _cParcela  := ''
    _cFornece  := ''
    _cLoja     := ''
    _cNatur    := ''

    while !XPED->( Eof() )
        
        if RetField("SF4", 1, xFilial("SF4") + XPED->C7_TES,"F4_DUPLIC") == 'N'
            XPED->( DbSkip() )
            Loop
        endif
        
        If ALLtRIM(XPED->C7_NUM)=='003769'
            _NXZ:=1
        ENDIF
        
        If lF021DtFl
            dData := stod( Execblock("FC021DTF",.F.,.F.,{"SC7","XPED"}) )
        Else
            Do case
            case !empty(XPED->C7_XDTCX)  //AJUSTANDO INFORMACAO DA DATA DO PEDIDO TRATANDO OU NAO O CAMPO CUSTOMIZADO C7_XDTCX
                dData	:= Iif( Stod(XPED->C7_XDTCX) < dDataBase, dDataBase, DataValida( stod(XPED->C7_XDTCX) ) )
            case empty(XPED->C7_XDTCX)
                dData	:= Iif( Stod(XPED->C7_DATPRF) < dDataBase, dDataBase, DataValida( stod(XPED->C7_DATPRF) ) )
            Endcase
        Endif
        
        
        //Saldo do pedido
        nVlrUnit  := XPED->E1_SALDO	/ XPED->C7_QUANT
        
        //sera considerado a taxa da moeda da data de emissao do pedido de compras
        dDataTx := stod(XPED->C7_EMISSAO)
        
        nTaxaMoed   := RecMoeda(dDataTx,XPED->C7_MOEDA)
        nVlrUnit 	:= xMoeda(nVlrUnit,XPED->C7_MOEDA,1,dDataTx,2,Iif(nTaxaMoed==0,XPED->C7_TXMOEDA,nTaxaMoed))
        
        nValTot	:= ((XPED->C7_QUANT-XPED->C7_QUJE) * nVlrUnit )
        aVenc	:= Condicao(nValTot, XPED->C7_COND, 0, dData, 0)  //MONTA VETOR COM OS VENCIMENTOS DO PED COMPRA DE ACORDO COM DATA FLUXO COMO DATA INICIAL
        
        for ix:=1 to len(aVenc)
            
            if !(dataValida(aVenc[ix][01]) >= MV_PAR01 .AND. dataValida(aVenc[ix][01]) <= MV_PAR02)
                Loop
            endif

            AADD(aDados, {;
                STOD(XPED->C7_EMISSAO),;
                DataValida( aVenc[ix][01] ),;
                Posicione("SC1", 1, xFilial("SC1") + XPED->C7_NUMSC + XPED->C7_ITEMSC, "C1_SOLICIT"),;
                AllTrim(XPED->C7_XUSERNO),;
                AllTrim(XPED->CTT_DESC01),;
                XPED->C7_NUM,;
                StrZero(ix,3),;
                XPED->C7_ITEM,;
                Posicione("SB1", 1, xFilial("SB1") + XPED->C7_PRODUTO, "B1_DESC"),;
                Posicione("SE4", 1, xFilial("SE4") + XPED->C7_COND, "E4_DESCRI"),;
                XPED->C7_FORNECE,;
                XPED->C7_LOJA,;
                XPED->A2_NOME,;
                Round(aVenc[ix][02],2),;
                0;
            })
            
        next ix

        XPED->( DbSkip() )
    enddo

    XPED->( DbCloseArea() )

    oSection1:Init()
    oReport:SetMeter(Len(aDados))
    For nI := 1 To Len(aDados)

        If oReport:Cancel()
            Return
        EndIf

        oReport:IncMeter()

        oSection1:Cell("C7_EMISSAO"):SetValue(aDados[nI][1])
        oSection1:Cell("E2_VENCREA"):SetValue(aDados[nI][2])
        oSection1:Cell("C1_SOLICIT"):SetValue(aDados[nI][3])
        oSection1:Cell("C7_XUSERNO"):SetValue(aDados[nI][4])
        oSection1:Cell("CTT_DESC01"):SetValue(aDados[nI][5])
        oSection1:Cell("E2_NUM"):SetValue(aDados[nI][6])
        oSection1:Cell("E2_PARCELA"):SetValue(aDados[nI][7])
        oSection1:Cell("C7_ITEM"):SetValue(aDados[nI][8])
        oSection1:Cell("B1_DESC"):SetValue(aDados[nI][9])
        oSection1:Cell("E4_DESCRI"):SetValue(aDados[nI][10])
        oSection1:Cell("A2_COD"):SetValue(aDados[nI][11])
        oSection1:Cell("A2_LOJA"):SetValue(aDados[nI][12])
        oSection1:Cell("A2_NOME"):SetValue(aDados[nI][13])
        oSection1:Cell("E1_SALDO"):SetValue(aDados[nI][14])
        oSection1:Cell("E2_SALDO"):SetValue(aDados[nI][15])
        oSection1:Cell("TOTAL"):SetValue(aDados[nI][14] + aDados[nI][15])

        oSection1:PrintLine()

    Next nI

    oSection1:Finish()

Return

/*/{Protheus.doc} AjustaSX1

Ajusta tabela de perguntas SX1

@author Marcos Natã Santos
@since 05/07/2018
@version 12.1.17
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
    Local i

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","Dt. Venc de?","MV_CH1","D",8,0,0,"G","MV_PAR01","","","","",""})
	aAdd(aRegs,{"02","Dt. Venc ate?","MV_CH2","D",8,0,0,"G","MV_PAR02","","","","",""})

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
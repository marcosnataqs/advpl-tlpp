#Include "Protheus.ch"
#Include "TopConn.ch"

#DEFINE CRLF Chr(13) + Chr(10)

/*
* Travar o valor total do pedido pra consultas
* ponto de entrada do pedido de venda.
*/
User Function M410STTS()
	Local aArea		:= GetArea()
	Local nValor	:= 0
	Local nVolume := 0
	Local nVolume2 := 0
	Local cEspec 	:= ""
	Local nValorVenda := 0
	
	If Inclui .Or. Altera
		CalcValPed(SC5->C5_NUM, @nValor, @nVolume, @nVolume2, @cEspec, @nValorVenda)

		If nValor <> 0//SC5->C5_XTOTAL
			RecLock("SC5", .F.)
			SC5->C5_XTOTAL	:= nValor
			SC5->C5_VOLUME1	:= nVolume
			IF(FWCodFil() == "0104")
                SC5->C5_ESPECI2	:= "UN"
                SC5->C5_ESPECI3	:= "DP"
				SC5->C5_VOLUME2	:= nVolume2    
			EndIf
            SC5->C5_ESPECI1	:= cEspec
			SC5->C5_XTOTPV := nValorVenda
			SC5->(MsUnLock())
		EndIf
		
		
	EndIf
	RestArea(aArea)

    //----------------------------------------------
    //-- Chama função de correção de saldos LA05A001
    //----------------------------------------------
    LA05EXC()
	
Return


/*
* Calcula valor total do pedido e quantidade
*/
Static Function CalcValPed(cNumPed, nValor, nVolume, nVolume2, cEspec, nValorVenda)
	Local aArea		:= GetArea()
	Local cSQL		:= ""
	
	cSQL	:= " SELECT SUM(C6_VALOR) VALOR, SUM(C6_QTDVEN) VOLUME, SUM(C6_UNSVEN) VOLUME2, SUM(C6_XPRCVEN * C6_QTDVEN) VALOR_VENDA, "
	cSQL	+= " (SELECT C6_UM ESP "
	cSQL	+= " FROM "
	cSQL	+= " (SELECT C6_UM "
	cSQL	+= " FROM " + RetSQLName("SC6") + " SC6 "
	cSQL	+= " WHERE SC6.D_E_L_E_T_ = ' ' "
	cSQL	+= " AND C6_FILIAL        = '" + xFilial("SC6") + "' "
	cSQL	+= " AND C6_NUM           = '" + cNumPed + "' "
	cSQL	+= " GROUP BY C6_UM "
	cSQL	+= " ORDER BY COUNT(1) DESC "
	cSQL	+= " ) "
	cSQL	+= " WHERE ROWNUM =1 "
	cSQL	+= " ) ESP "
	cSQL	+= " FROM " + RetSQLName("SC6") + " SC6 "
	cSQL	+= " WHERE SC6.D_E_L_E_T_ = ' ' "
	cSQL	+= " AND C6_FILIAL        = '" + xFilial("SC6") + "' "
	cSQL	+= " AND C6_NUM           = '" + cNumPed + "' "
	cSQL	+= " GROUP BY C6_NUM "
	
	//memowrite("c:\LINEA\M410STTS-CALCULO-VOLUME.SQL",cSQL)
	
	dbUseArea(.T., "TOPCONN", tcGenQry(,, cSQL), "TMPSC6", .F., .T.)
	
	If !EOF()
		nValor	:= TMPSC6->VALOR
		nVolume := TMPSC6->VOLUME
		nVolume2 := TMPSC6->VOLUME2
		cEspec := TMPSC6->ESP
		nValorVenda := TMPSC6->VALOR_VENDA
	EndIf
	
	dbCloseArea()
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} LA05EXC

Custom LA05A001:
Realiza o ajuste do saldo liberado na rotina Automação de Pedido de Venda

@author Marcos Natã Santos
@since 02/07/2018
@version 12.1.17
@type function
/*/
Static Function LA05EXC()
    Local lRet     := .T.
    Local cQry     := ""
    Local aAreaSZL
    Local aAreaSZM
    Local aAreaSZN
    Local aProds
    Local aRegPed
    Local nI
    Local cStatus  := "6"

    If IsInCallStack( "A410Deleta" ) .And. .Not. IsInCallStack( "A410Altera" )

        aAreaSZL := SZL->(GetArea())
        aAreaSZM := SZM->(GetArea())
        aAreaSZN := SZN->(GetArea())
        aProds   := {}
        aRegPed  := {}
        nI       := 0

        If !Empty(SC5->C5_XPEDPAI) //.And. !Empty(SC5->C5_XPVCD)

            cQry := "SELECT C6_XPEDPAI, C6_CLI, C6_LOJA, C6_PRODUTO, C6_QTDVEN " + CRLF
            cQry += "FROM " + RetSqlName("SC6") + CRLF
            cQry += "WHERE D_E_L_E_T_ = '*' " + CRLF // Itens deletados
            cQry += "AND C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
            cQry += "AND C6_NUM = '"+ SC5->C5_NUM +"' " + CRLF
            cQry := ChangeQuery(cQry)

            If Select("TMP1") > 0
                TMP1->(DbCloseArea())
            EndIf

            TcQuery cQry New Alias "TMP1"

            TMP1->(dbGoTop())
            COUNT TO NQTREG
            TMP1->(dbGoTop())

            If NQTREG > 0
                While TMP1->( !EOF() )
                    AADD(aProds, {TMP1->C6_XPEDPAI, TMP1->C6_CLI, TMP1->C6_LOJA, TMP1->C6_PRODUTO, TMP1->C6_QTDVEN} )
                    TMP1->( dbSkip() )
                EndDo
            EndIf

            If Len(aProds) > 0
                //-----------------------------------
                //-- aProds[nI][1] = Pedido Principal
                //-- aProds[nI][2] = Cliente
                //-- aProds[nI][3] = Loja
                //-- aProds[nI][4] = Produto
                //-- aProds[nI][5] = Quantidade
                //-----------------------------------
                SZM->( dbSetOrder(4) ) //-- ZM_FILIAL+ZM_NUM+ZM_CLIENTE+ZM_LOJA+ZM_PRODUTO
                For nI := 1 To Len(aProds)
                    If SZM->( dbSeek(xFilial("SZM") + aProds[nI][1] + aProds[nI][2] + aProds[nI][3] + aProds[nI][4]) )
                        RecLock("SZM", .F.)
                        SZM->ZM_QTDLIB -= aProds[nI][5]
                        SZM->(MsUnlock())
                    EndIf
                Next nI
            
                //-------------------------------------------//
                //-- Estorna resíduos eliminados no pedido --//
                //-------------------------------------------//
                SZM->( dbSetOrder(1) )
                SZM->( dbGoTop() )
                If SZM->( dbSeek(xFilial("SZM") + aProds[1][1] + aProds[1][2] + aProds[1][3]) )
                    While SZM->( !EOF() );
                        .And. SZM->ZM_NUM = aProds[1][1];
                        .And. SZM->ZM_CLIENTE = aProds[1][2];
                        .And. SZM->ZM_LOJA = aProds[1][3]

                        RecLock("SZM", .F.)
                        SZM->ZM_QTDCORT := 0
                        SZM->ZM_MOTIVO := Space(2)
                        SZM->(MsUnLock())

                        SZM->( dbSkip() )
                    EndDo
                EndIf

                If StaticCall(LA05A002, ValRastro, aProds[1][1])
                    cStatus := "5" //-- Bloqueio Saldo Estoque
                Else
                    cStatus := "6" //-- Pedido Parcialmente Liberado
                EndIf

                SZL->( dbSetOrder(1) )
                If SZL->( dbSeek(xFilial("SZL") + aProds[1][1] + aProds[1][2] + aProds[1][3]) )
                    RecLock("SZL", .F.)
                    SZL->ZL_STATUS := cStatus
                    SZL->ZL_FATNF := "N"
                    SZL->(MsUnlock())
                EndIf

                SZN->( dbSetOrder(1) )
                If SZN->( dbSeek(xFilial("SZN") + aProds[1][1] + aProds[1][2] + aProds[1][3]) )
                    RecLock("SZN", .F.)
                    SZN->ZN_STATUS := cStatus
                    SZN->ZN_BLEST  := "2"
                    SZN->ZN_FATNF := "N"
                    SZN->(MsUnlock())
                EndIf

                AADD(aRegPed,{ 	aProds[1][1],;
                                aProds[1][2],;
                                aProds[1][3],;
                                "3",; // 1=Bloqueio 2=Liberação 3=Exclusão
                                Date(),;
                                Time(),;
                                RetCodUsr(),;
                                CUSERNAME,;
                                "11",; // Status
                                "Exclusão - Pedido " + AllTrim(SC5->C5_NUM) + " excluído"}) // Obs
                
                StaticCall( LA05A001 , PUT_HIST , aRegPed )

                //-------------------------
                //-- Workflow Status Pedido
                //-------------------------
                U_LA05W001(aRegPed[1][1],aRegPed[1][2],aRegPed[1][3],aRegPed[1][4],aRegPed[1][9])
            EndIf

        EndIf

        RestArea(aAreaSZL)
        RestArea(aAreaSZM)
        RestArea(aAreaSZN)

    EndIf

Return lRet
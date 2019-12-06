#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} CalcSld

Processo ajuste dos saldos em processo

@type User Function
@author marcos.santos
@since 26/02/2018
@version 1.0

/*/
User Function CalcSld()
    // Atualiza tabela espelho Z51
    Processa( {|| AtuEmpZ51() }, "Aguarde...", "Atualizando tabela espelho de saldos...", .F.)
    // Atualiza tabela de saldos SB2
    Processa( {|| AtuEmpWMS() }, "Aguarde...", "Atualizando tabela de saldos...", .F.)

    MsgInfo("Saldos atualizados com sucesso!")
Return

/*/{Protheus.doc} AtuEmpWMS

Atualiza saldos empenhos OPs anteriores ao GO Live

@author marcos.santos
@since 22/02/2018
@version 1.0

@type function
/*/
Static Function AtuEmpWMS()
	Local aAreaSB2 := SB2->(GetArea())

	cQry :=  "SELECT "
	cQry +=  "  Z51.Z51_PRODUT     PRODUTO, "
	cQry +=  "  Z51.Z51_LOCAL      LOCAL, "
	cQry +=  "  SUM(Z51.Z51_QTD)   QTD "
	cQry +=  "FROM " + RetSqlName("SC2") + " SC2 "
	cQry +=  "  INNER JOIN Z51010 Z51 "
	cQry +=  "    ON Z51.D_E_L_E_T_ <> '*' "
    cQry +=  "       AND Z51.Z51_FILIAL = '" + xFilial("Z51") + "' "
	cQry +=  "       AND Z51.Z51_OP = (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN) "
	cQry +=  "WHERE SC2.D_E_L_E_T_ <> '*' "
    cQry +=  "      AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQry +=  "      AND SC2.C2_DATRF = ' ' "
	cQry +=  "      AND SC2.C2_EMISSAO >= '" + GetMV("MV_XSC2COP") + "' "
	cQry +=  "GROUP BY Z51.Z51_PRODUT, Z51.Z51_LOCAL "
	cQry := ChangeQuery(cQry)

	If Select("QRY2") > 0
		QRY2->(dbCloseArea())
	EndIf

	TCQuery cQry New Alias "QRY2"

    ProcRegua(QRY2->(RecCount()))

	SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
	QRY2->(dbGoTop())
	While QRY2->(!EOF())
		If SB2->(dbSeek(xFilial("SB2")+QRY2->PRODUTO+QRY2->LOCAL))
			SB2->(RecLock("SB2", .F.))
			SB2->B2_XEMPWMS += QRY2->QTD
			SB2->(MsUnLock())
		EndIf
        IncProc()
		QRY2->(dbSkip())
	EndDo

	RestArea(aAreaSB2)
	QRY2->(dbCloseArea())

Return

/*/{Protheus.doc} AtuEmpZ51

Atualiza saldos empenhos OPs anteriores ao GO Live

@author marcos.santos
@since 21/02/2018
@version 1.0

@type function
/*/
Static Function AtuEmpZ51()

	cQry :=  "SELECT DISTINCT "
	cQry +=  "  SD4.D4_OP, "
	cQry +=  "  SD4.D4_COD, "
	cQry +=  "  SD4.D4_LOCAL "
	cQry +=  "FROM " + RetSqlName("SC2") + " SC2 "
	cQry +=  "  INNER JOIN SD4010 SD4 "
	cQry +=  "    ON SD4.D4_OP = (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN) "
	cQry +=  "       AND SD4.D_E_L_E_T_ <> '*' "
	cQry +=  "WHERE SC2.D_E_L_E_T_ <> '*' "
    cQry +=  "      AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQry +=  "      AND SC2.C2_DATRF = ' ' "
	cQry +=  "      AND SC2.C2_EMISSAO >= '" + GetMV("MV_XSC2COP") + "' "
	cQry +=  "ORDER BY SD4.D4_OP "
	cQry := ChangeQuery(cQry)

	If Select("QRY1") > 0
		QRY1->(dbCloseArea())
	EndIf

	TCQuery cQry New Alias "QRY1"

    ProcRegua(QRY1->(RecCount()))

	QRY1->(dbGoTop())
	While QRY1->(!EOF())
		BaixaEmp(QRY1->D4_OP, QRY1->D4_COD, QRY1->D4_LOCAL)
        IncProc()

		QRY1->(dbSkip())
	EndDo

Return

/*/{Protheus.doc} BaixaEmp

Tratativa para controle de empenhos em processo

@author marcos.santos
@since 21/02/2018
@version 1.0

@type function
/*/
Static Function BaixaEmp(cOp, cProduto, cLocal)
	Local aAreaZ51 := Z51->(GetArea())

	cQry :=  "SELECT R_E_C_N_O_ RECNO "
	cQry +=  "FROM " + RetSqlName("Z51") + " "
	cQry +=  "WHERE D_E_L_E_T_ <> '*' "
	cQry +=  "      AND Z51_FILIAL = '" + xFilial("Z51") + "' "
	cQry +=  "      AND Z51_OP = '" + cOp + "' "
	cQry +=  "      AND Z51_PRODUT = '" + cProduto + "' "
	cQry +=  "      AND Z51_LOCAL = '" + cLocal + "' "
	cQry +=  "      AND Z51_QTD <> 0 "
	cQry := ChangeQuery(cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQuery cQry New Alias "QRY"

	QRY->(dbGoTop())
	While QRY->(!EOF())
		Z51->(dbGoTo(QRY->RECNO))
		If Z51->(RecLock("Z51", .F.))
			Z51->Z51_QTD := 0
			Z51->(MsUnLock())
		endif

		QRY->(dbSkip())
	EndDo

	RestArea(aAreaZ51)
	QRY->(dbCloseArea())

Return

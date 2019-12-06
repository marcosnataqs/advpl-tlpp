#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} MT390DTV
Atualiza data de validade na revalidação de um lote
para todos locais na SB8, SD2, SD1 ou SC2.

EM QUE PONTO: Após a alteração da data de validade.

@author marcos.santos
@since 19/12/2017
@version 1.0

@type function
/*/
User Function MT390DTV()
	//	WorkflowVld() //-- Workflow Revalidação de Lotes

	aAreaSB8 := SB8->(GetArea())
	aAreaSD1 := SD1->(GetArea())
	aAreaSD2 := SD2->(GetArea())
	aAreaSC2 := SC2->(GetArea())
	dDataValid := SB8->B8_DTVALID

	BEGIN TRANSACTION

		//---------
		//-- SB8 --
		//---------

		cQry :=  "SELECT R_E_C_N_O_ RECNO " + CRLF
		cQry +=  "FROM "+ RetSqlName("SB8") +" " + CRLF
		cQry +=  "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry +=  "      AND B8_FILIAL = '"+ xFilial("SB8") +"' " + CRLF
		cQry +=  "      AND B8_PRODUTO = '"+ SB8->B8_PRODUTO +"' " + CRLF
		cQry +=  "      AND B8_LOTECTL = '"+ SB8->B8_LOTECTL +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "QRY"

		QRY->(DbGoTop())
		While QRY->(!EOF())
			SB8->(DbGoTo(QRY->RECNO))

			RecLock("SB8", .F.)
			SB8->B8_DTVALID := dDataValid
			SB8->(MsUnlock())

			QRY->(DbSkip())
		EndDo

		//---------
		//-- SD1 --
		//---------

		cQry :=  "SELECT R_E_C_N_O_ RECNO " + CRLF
		cQry +=  "FROM "+ RetSqlName("SD1") +" " + CRLF
		cQry +=  "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry +=  "      AND D1_FILIAL = '"+ xFilial("SD1") +"' " + CRLF
		cQry +=  "      AND D1_COD = '"+ SB8->B8_PRODUTO +"' " + CRLF
		cQry +=  "      AND D1_LOTECTL = '"+ SB8->B8_LOTECTL +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "QRY"

		QRY->(DbGoTop())
		While QRY->(!EOF())
			SD1->(DbGoTo(QRY->RECNO))

			RecLock("SD1", .F.)
			SD1->D1_DTVALID := dDataValid
			SD1->(MsUnlock())

			QRY->(DbSkip())
		EndDo

		//---------
		//-- SD2 --
		//---------

		cQry :=  "SELECT R_E_C_N_O_ RECNO " + CRLF
		cQry +=  "FROM "+ RetSqlName("SD2") +" " + CRLF
		cQry +=  "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry +=  "      AND D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
		cQry +=  "      AND D2_COD = '"+ SB8->B8_PRODUTO +"' " + CRLF
		cQry +=  "      AND D2_LOTECTL = '"+ SB8->B8_LOTECTL +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "QRY"

		QRY->(DbGoTop())
		While QRY->(!EOF())
			SD2->(DbGoTo(QRY->RECNO))

			RecLock("SD2", .F.)
			SD2->D2_DTVALID := dDataValid
			SD2->(MsUnlock())

			QRY->(DbSkip())
		EndDo

		//---------
		//-- SC2 --
		//---------

		SC2->(DbSetOrder(12)) //-- C2_FILIAL+C2_PRODUTO+C2_LOTECTL
		If SC2->(DbSeek(xFilial("SC2")+SB8->B8_PRODUTO+SB8->B8_LOTECTL))
			RecLock("SC2", .F.)
			SC2->C2_DTVALID := dDataValid
			SC2->(MsUnlock())
		EndIf

	END TRANSACTION

	RestArea(aAreaSB8)
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSC2)

Return

Static Function WorkflowVld()
	If sm0->m0_codigo=="01"
		_cfilsb1:=xfilial("SB1")

		_nordsb1:=sb1->(indexord())
		_nregsb1:=sb1->(recno())

		sb1->(dbsetorder(1))
		sb1->(dbseek(_cfilsb1+sb8->b8_produto))

		_cde      :="Servidor Protheus - Aviso <"+getmv("MV_WFMAIL")+">"
		_cconta   :=getmv("MV_WFACC")
		_csenha   :=getmv("MV_WFPASSW")
		_cpara    :="pcp@vitapan.com.br;adm@vitapan.com.br;gti@vitapan.com.br;custos@vitapan.com.br;"
		_cpara    +="logistica@vitapan.com.br;almoxarifado@vitapan.com.br;controle@vitapan.com.br;"
		_cpara    +="controle2@vitapan.com.br;glogistica@vitapan.com.br"
		_ccc      :="presidente@vitapan.com.br" // com copia
		_ccco     :="" // com copia oculta
		_cassunto :="Alteração na dt.validade do prod.:"+alltrim(sb8->b8_produto)+" lote: "+sb8->b8_lotectl
		_cmensagem:="Produto: "+alltrim(sb8->b8_produto)+" - "+alltrim(sb1->b1_desc)+"<P>"
		_cmensagem+="Armazém: "+sb8->b8_local+"<P>"
		_cmensagem+="Lote: "+sb8->b8_lotectl+"<P>"
		_cmensagem+="Validade: "+dtoc(sb8->b8_dtvalid)+"<P>"
		_cmensagem+="Saldo: "+transform(sb8->b8_saldo,"@E 99,999,999,999.99")+"<P>"
		_cmensagem+="Usuario: "+cusername+"<P>"
		_cmensagem+="Data: "+dtoc(date())+"<P>"
		_cmensagem+="Hora: "+time()+"<P>"

		_canexos  :="" // caminho completo dos arquivos a serem anexados, separados por ;
		_lavisa   :=.f.
		u_envemail(_cde,_cconta,_csenha,_cpara,_ccc,_ccco,_cassunto,_cmensagem,_canexos,_lavisa)

		sb1->(dbsetorder(_nordsb1))
		sb1->(dbgoto(_nregsb1))
	EndIf

Return
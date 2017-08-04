#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} B8TOZ1

Importa os dados do campo B8_XENDERE PARA Z1_ENDERE.

@author Marcos Natã Santos
@since 05/07/2016
@version undefined

@type function
/*/

User Function B8TOZ1()
	cQuery := "SELECT * FROM "+RetSqlName("SB8")+" SB8 "
	cQuery += "WHERE B8_XENDERE != ' ' "
	cQuery += "AND B8_SALDO > 0 "
	cQuery += "AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	If Select("SB8T") > 0
    	SB8T->(dbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "SB8T"

	SB8T->(dbGoTop())

	While SB8T->(!EOF())
		SZ1->(dbSetOrder(8)) //Produto+Lote

		If SZ1->(dbSeek(SB8T->B8_FILIAL+SB8T->B8_PRODUTO+SB8T->B8_LOTECTL))
			If ApMsgYesNo(ALLTRIM(SZ1->Z1_CODPRO) + " : " + SZ1->Z1_DESCPRO, "Produto")
				Return
			EndIf
			//RecLock("SZ1", .F.)
			//SZ1->Z1_ENDERE := SB8T->B8_XENDERE
			//SZ1->(MsUnlock())
		EndIf
		SB8T->(dbSkip())
	EndDo
	SB8T->(dbCloseArea())
Return
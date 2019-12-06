#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} nomeFunction

Localizado na Solicitação de Compras, este ponto de entrada
é responsável em validar o registro posicionado da Solicitação
de Compras antes de executar as operações de inclusão, alteração,
exclusão e cópia. Se retornar .T., deve executar as operações de
inclusão, alteração, exclusão e cópia ou .F. para interromper o processo.

@type User Function
@author Marcos Natã Santos
@since 07/11/2019
@version 1.0
@return lRet, logic
/*/
User Function MT110VLD()
	Local lRet := .T.
	Local nOper :=  PARAMIXB[1]
	Local cUsuario := SC1->C1_USER

	If nOper = 4 .Or. nOper = 6 // 4 = Alteração | 6 = Exclusão
		If .Not. FwIsAdmin()
			If cUsuario <> __cUserID
				lRet := .F.
				MsgAlert("Somente o solicitante pode redefinir ou excluir esta solicitação.", "ATENÇÃO")
			EndIf
		EndIf
	EndIf
Return lRet
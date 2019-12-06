#Include "Protheus.ch"

/*/{Protheus.doc} MT110VLD
Valida o registro na solicitação de compras
@author Marcos Natã Santos
@since 03/10/2017
@version 1.0
@return lógico, ExpL1

@type function
/*/
User Function MT110VLD()
	Local ExpN1 := Paramixb[1] // 3-Inclusão | 4-Alteração | 8-Cópia | 6-Exclusão
	Local ExpL1 := .T.
	Local nUsuario := SC1->C1_USER
	Local aRetUser := PswRet()

	/*
	* Somente o solicitante pode alterar/excluir sua solicitação,
	* exceção apenas para os usuários do departamento GTI
	* que podem alterar qualquer solicitação.
	*/

	If ExpN1 = 4 .Or. ExpN1 = 6
		If nUsuario = aRetUser[1][1] .Or. "GTI" $ aRetUser[1][12]
			ExpL1 := .T.
		Else
			ExpL1 := .F.
			MsgAlert("Somente o Solicitante pode redefinir ou excluir esta solicitação.")
		EndIf
	EndIf

Return ExpL1
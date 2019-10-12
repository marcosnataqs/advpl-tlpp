#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT410TOK

Este ponto de entrada é executado ao clicar no botão OK e pode ser usado para
validar a confirmação das operações: incluir,  alterar, copiar e excluir.
Se o ponto de entrada retorna o conteúdo .T., o sistema continua a operação,
caso contrário, volta para a tela do pedido.

@type User Function
@author Marcos NatÃ£ Santos
@since 10/10/2019
@version 1.0
@return lRet, logic
/*/
User Function MT410TOK()
    Local lRet := .T.
    Local nOpc := PARAMIXB[1]

    lRet := U_MNTFN001(nOpc)

Return lRet
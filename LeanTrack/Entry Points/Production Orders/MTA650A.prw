#Include "Protheus.ch"

/*/{Protheus.doc} MTA650A

A650Altera() - Programa de alteração de O.P.s
É executado após a gravação de todos os registros de alteração realizado
na função A650Altera(rotina de alteração do cadastramento de Ordens de Produção).

@author 	Marcos Natã Santos
@since 		19/05/2019
@version 	12.1.17
/*/
User Function MTA650A
    Local cProduto := SC2->C2_PRODUTO
    Local cOP      := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
    Local nQtd     := SC2->C2_QUANT
    Local dDtIni   := SC2->C2_DATPRI
    Local dDtFim   := SC2->C2_DATPRF
    Local dDtEmis  := SC2->C2_EMISSAO

    U_LTPostOrder(cProduto, cOP, nQtd, dDtIni, dDtFim, dDtEmis)

Return
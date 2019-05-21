#Include "Protheus.ch"

/*/{Protheus.doc} MTA650I

Geração de Ordens de Produção
Este ponto de entrada é chamado nas funções: A650Inclui (Inclusão de OP's)
A650GeraC2 (Gera Op para Produto/Quantidade Informados nos parâmetros).

@author 	Marcos Natã Santos
@since 		19/05/2019
@version 	12.1.17
/*/
User Function MTA650I
    Local cProduto := SC2->C2_PRODUTO
    Local cOP      := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
    Local nQtd     := SC2->C2_QUANT
    Local dDtIni   := SC2->C2_DATPRI
    Local dDtFim   := SC2->C2_DATPRF
    Local dDtEmis  := SC2->C2_EMISSAO

    U_LTPostOrder(cProduto, cOP, nQtd, dDtIni, dDtFim, dDtEmis)

Return
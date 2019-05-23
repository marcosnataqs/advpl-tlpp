#Include "Protheus.ch"

/*/{Protheus.doc} MTA650AE

Funções A650Deleta() e A650DelOp()
O Ponto de Entrada 'MTA650AE' é executado após a exclusão da Op e está localizado
na função A650Deleta (Deleta Op's).

@author 	Marcos Natã Santos
@since 		19/05/2019
@version 	12.1.17
/*/
User Function MTA650AE
    Local aAreaSC2 := SC2->( GetArea() )
    Local cNum     := PARAMIXB[1]
    Local cItem    := PARAMIXB[2]
    Local cSeq     := PARAMIXB[3]

    Local cProduto := ""
    Local cOP      := ""
    Local nQtd     := 0
    Local dDtIni   := Space(8)
    Local dDtFim   := Space(8)
    Local dDtEmis  := Space(8)
    
    SC2->( dbSetOrder(1) )
    SET DELETED OFF
    If SC2->( dbSeek(xFilial("SC2")+cNum+cItem+cSeq) )
        cProduto := SC2->C2_PRODUTO
        cOP      := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
        nQtd     := SC2->C2_QUANT
        dDtIni   := SC2->C2_DATPRI
        dDtFim   := SC2->C2_DATPRF
        dDtEmis  := SC2->C2_EMISSAO

        // U_LTPostOrder(cProduto, cOP, nQtd, dDtIni, dDtFim, dDtEmis)
    EndIf
    SET DELETED ON

    RestArea( aAreaSC2 )
Return
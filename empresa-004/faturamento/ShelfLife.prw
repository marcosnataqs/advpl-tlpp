#Include "Protheus.ch"

/*/{Protheus.doc} ShelfLife

Shelf Life do Cliente Linea

@author 	Marcos Natã Santos
@since 		27/02/2019
@version 	12.1.17
@return 	Lógico
/*/
User Function ShelfLife(cCodCli,cLoja,cProduto,cLote,cLocal)
    Local lRet         := .T.
    Local aAreaSA1     := SA1->( GetArea() )
    Local aAreaSB8     := SB8->( GetArea() )
    Local nLeadTime    := 0
    Local nShelfLife   := 0
    Local dEmissao     := dDataBase
    Local dDtFabric    := STOD(Space(8))
    Local nQtdDiasSL   := 0
    Local nQtdDiasVenc := 0
    Local cFilialCD    := "0101"

    cCodCli  := PadR(cCodCli, TamSx3("A1_COD")[1])
    cLoja    := PadR(cLoja, TamSx3("A1_LOJA")[1])
    cProduto := PadR(cProduto, TamSx3("B8_PRODUTO")[1])
    cLocal   := PadR(cLocal, TamSx3("B8_LOCAL")[1])
    cLote    := PadR(cLote, TamSx3("B8_LOTECTL")[1])

    SA1->( dbSetOrder(1) )
    If SA1->( dbSeek(xFilial("SA1") + cCodCli + cLoja) )
        //-- Acréscimo do lead time ao cálculo --//
        nLeadTime  := SA1->A1_LEADTM
        nShelfLife := Posicione("SA7", 1, xFilial("SA7") + cCodCli + cLoja + cProduto, "A7_XSHELFL")

        If nShelfLife > 0
            SB8->( dbSetOrder(3) ) //-- Produto + Local + Lote
            If SB8->( dbSeek(cFilialCD + cProduto + cLocal + cLote) )
                dDtFabric  := IIF(!Empty(SB8->B8_DFABRIC), SB8->B8_DFABRIC, SB8->B8_DATA)
                nQtdDiasSL := Ceiling((DateDiffDay(dDtFabric,SB8->B8_DTVALID) * nShelfLife / 100) + nLeadTime)
                nQtdDiasVenc := (SB8->B8_DTVALID - dEmissao)

                If nQtdDiasVenc < nQtdDiasSL
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aAreaSA1)
    RestArea(aAreaSB8)

Return lRet
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} A140EXC
Localizado na função A140NFiscal - Interface do pre-documento de entrada,
este Ponto de entrada tem por objetivo validar a exclusão de uma pre-nota.
@type User Function
@author Marcos Natã Santos
@since 03/09/2019
@version 1.0
@return ExpL1, logic
/*/
User Function A140EXC
    Local ExpL1 := .T.
    Local aAreaZB0 := ZB0->( GetArea() )
    Local cDoc := PadR(U_zTiraZeros(SF1->F1_DOC), TamSX3("ZB0_NUMERO")[1])
    Local cSerie := AllTrim(SF1->F1_SERIE)

    //-----------------------------------------------------//
    //-- Estorna status de processamento no monitor Oobj --//
    //-----------------------------------------------------//
    ZB0->( dbSetOrder(1) )
    If ZB0->( dbSeek(xFilial("ZB0") + cDoc + cSerie) )
        If ZB0->ZB0_PROC == "S"
            RecLock("ZB0", .F.)
            ZB0->ZB0_PROC := Space(1)
            ZB0->( MsUnlock() )

            MsgInfo("Processamento estornado no monitor Oobj.", "Oobj")
        EndIf
    EndIf

    RestArea(aAreaZB0)
Return ExpL1
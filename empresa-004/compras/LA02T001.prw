#Include "Protheus.ch"

/*/{Protheus.doc} LA02T001

Tela Ocorrências do Pedido de Compras

@author 	Marcos Natã Santos
@since 		10/12/2018
@version 	12.1.17
/*/
User Function LA02T001()
    Local aAreaSC7   := SC7->(GetArea())
    Local cNumPed    := SC7->C7_NUM
    Local cFornece   := SC7->C7_FORNECE
    Local cLoja      := SC7->C7_LOJA
    Local aFieldFill := {}
    Local aColsEx    := {}
    Static oDlg

    Private oMSGet

    SC7->( dbGoTop() )
    SC7->( dbSetOrder(1) ) //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    If SC7->( dbSeek(xFilial("SC7") + cNumPed) )
        While SC7->( !EOF() ) .And. SC7->C7_FILIAL == xFilial("SC7") .And. ;
                                    SC7->C7_NUM == cNumPed .And. ;
                                    SC7->C7_FORNECE == cFornece .And. ;
                                    SC7->C7_LOJA == cLoja .And. ;
                                    SC7->C7_QUJE < SC7->C7_QUANT

            Aadd(aFieldFill, SC7->C7_NUM)
            Aadd(aFieldFill, SC7->C7_ITEM)
            Aadd(aFieldFill, SC7->C7_PRODUTO)
            Aadd(aFieldFill, SC7->C7_DESCRI)
            Aadd(aFieldFill, SC7->C7_XOCORRE)
            Aadd(aFieldFill, SC7->C7_XCAUSA)
            Aadd(aFieldFill, SC7->C7_XENTREG)
            Aadd(aFieldFill, .F.)
            Aadd(aColsEx, aFieldFill)
            aFieldFill := {}

            SC7->(dbSkip())
        EndDo
    EndIf

    If Len(aColsEx) = 0
        MsgInfo("Pedido totalmente entregue")
        RestArea(aAreaSC7)
        Return
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Cadastro de Ocorrências" FROM 000, 000  TO 300, 800 COLORS 0, 16777215 PIXEL

        oMSGet := fMSNewGet(aColsEx)

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| RegData(), oDlg:End() }, {|| oDlg:End() })

    RestArea(aAreaSC7)

Return

/*/{Protheus.doc} fMSNewGet
fMSNewGet
@author 	Marcos Natã Santos
@since 		10/12/2018
@version 	12.1.17
/*/
Static Function fMSNewGet(aColsEx)
    Local nX
    Local aHeaderEx    := {}
    Local aFields      := {"C7_NUM","C7_ITEM","C7_PRODUTO","C7_DESCRI","C7_XOCORRE","C7_XCAUSA","C7_XENTREG"}
    Local aAlterFields := {"C7_XOCORRE","C7_XCAUSA","C7_XENTREG"}
    
    Static oMSNewGet

    Default aColsEx    := {}

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    For nX := 1 to Len(aFields)
        If SX3->(DbSeek(aFields[nX]))
        Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                        SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
        Endif
    Next nX

    oMSNewGet := MsNewGetDados():New( 030, 002, 150, 402, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", /*+Field1+Field2*/, aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return oMSNewGet

/*/{Protheus.doc} RegData
RegData
@author 	Marcos Natã Santos
@since 		10/12/2018
@version 	12.1.17
/*/
Static Function RegData()
    Local aAreaSC7 := SC7->(GetArea())
    Local nX

    SC7->( dbGoTop() )
    SC7->( dbSetOrder(4) ) //-- C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
    For nX := 1 To Len(oMSGet:aCols)
        If SC7->( dbSeek(xFilial("SC7") + oMSGet:aCols[nX][3] + oMSGet:aCols[nX][1] + oMSGet:aCols[nX][2]) )
            RecLock("SC7", .F.)
            SC7->C7_XOCORRE := AllTrim(oMSGet:aCols[nX][5])
            SC7->C7_XCAUSA  := AllTrim(oMSGet:aCols[nX][6])
            SC7->C7_XENTREG := AllTrim(oMSGet:aCols[nX][7])
            SC7->( MsUnlock() )
        EndIf
    Next nX

    RestArea(aAreaSC7)

Return
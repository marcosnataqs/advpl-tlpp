#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} LA05A013
Importar mix dos clientes (Shelf Life)
@type User Function
@author Marcos Natã Santos
@since 10/10/2019
@version 1.0
/*/
User Function LA05A013
    GetDocFromPC()
Return

/*/{Protheus.doc} GetDocFromPC
Busca dados (documento) do computador
@author Marcos Natã Santos
@since 10/10/2019
@version 1.0
/*/
Static Function GetDocFromPC()
    Local cPathArq   := ""
    Local cText      := ""
	Local nHandle    := 0
    Local nQtdBytes  := 1000000
    Local aDocs      := {}
	Local aDocsItens := {}
	Local nX         := 0

    cPathArq := cGetFile('Arquivos CSV|*.csv','Selecione um documento de mix de produtos',0,'C:\',.T.,,.F.)
	If Empty(cPathArq)
		MsgAlert("Documento não selecionado.", "GetDocFromPC")
        Return
	EndIf

    nHandle := FOpen(cPathArq , FO_READWRITE + FO_SHARED )
    If nHandle == -1
        MsgStop("Erro de abertura do arquivo: FERROR " + STR(FError(),4))
        Return
    Else
		cText := FReadStr(nHandle, nQtdBytes)
        aDocs := StrTokArr(cText, CHR(10)+CHR(13))

        If Len(aDocs) <= 0
            MsgStop("Arquivo informado está vazio.")
            FClose(nHandle)
            Return
        Else
            For nX := 1 To Len(aDocs)
				AADD(aDocsItens, StrTokArr2(aDocs[nX], ";", .T.) )
			Next nX

			FClose(nHandle)

			//-- Verifica padrão do layout do arquivo --//
            If aDocsItens[1][1] == "CLIENTE" .And. aDocsItens[1][2] == "LOJA" .And. aDocsItens[1][3] == "PRODUTO"
				Processa( {|| ProcessDoc(aDocsItens) }, "Aguarde...", "Importando arquivo...", .F.)
			Else
				MsgAlert("Selecione um arquivo válido de mix de produtos.", "GetDocFromPC")
				Return
			EndIf
        EndIf
	EndIf

Return

/*/{Protheus.doc} ProcessDoc
Processa importação do documento
@type Static Function
@author Marcos Natã Santos
@since 10/10/2019
@version 1.0
@param aMix, array, Mix de Produtos
/*/
Static Function ProcessDoc(aMix)
	Local aAreaSA7 := SA7->( GetArea() )
	Local nX := 0
	Local cCodCli := ""
	Local cLoja := ""
    Local cProduto := ""
    Local nShelfLife := 0
    Local cElimina := ""

	ProcRegua(Len(aMix)-1)
	For nX := 2 To Len(aMix)
		cCodCli    := PadL(aMix[nX][1], TamSX3("A7_CLIENTE")[1], "0")
		cLoja      := PadL(aMix[nX][2], TamSX3("A7_LOJA")[1], "0")
        cProduto   := PadR(aMix[nX][3], TamSX3("A7_PRODUTO")[1])
        nShelfLife := Val(aMix[nX][4])
        cElimina   := AllTrim(aMix[nX][5])

        IncProc( AllTrim(cCodCli) + " " + AllTrim(cLoja) + " " + AllTrim(cProduto) )

        If UPPER(cElimina) == "SIM"
            //-- Elimina itens do mix do cliente --//
            SA7->( dbSetOrder(1) )
            If SA7->( dbSeek(xFilial("SA7") + cCodCli + cLoja + cProduto) )
                RecLock("SA7", .F.)
                    SA7->( dbDelete() )
                SA7->( MsUnlock() )
            EndIf
        ElseIf cLoja == "00"
            //-- Atualiza mix e shelf life do cliente --//
            //-- Linha do arquivo sem loja do cliente --//
            SA7->( dbSetOrder(2) )
            If SA7->( dbSeek(xFilial("SA7") + cProduto + cCodCli) )
                While SA7->( !EOF() );
                    .And. SA7->A7_PRODUTO = cProduto;
                    .And. SA7->A7_CLIENTE = cCodCli

                    RecLock("SA7", .F.)
                        SA7->A7_XSHELFL := nShelfLife
                    SA7->( MsUnlock() )

                    SA7->( dbSkip() )
                EndDo
            Else
                RecLock("SA7", .T.)
                    SA7->A7_FILIAL  := xFilial("SA7")
                    SA7->A7_CLIENTE := cCodCli
                    SA7->A7_LOJA    := "01"
                    SA7->A7_PRODUTO := cProduto
                    SA7->A7_XSHELFL := nShelfLife
                SA7->( MsUnlock() )
            EndIf
        Else
            //-- Atualiza mix e shelf life do cliente --//
            //-- Linha do arquivo com loja do cliente --//
            SA7->( dbSetOrder(1) )
            If SA7->( dbSeek(xFilial("SA7") + cCodCli + cLoja + cProduto) )
                RecLock("SA7", .F.)
                    SA7->A7_XSHELFL := nShelfLife
                SA7->( MsUnlock() )
            Else
                RecLock("SA7", .T.)
                    SA7->A7_FILIAL  := xFilial("SA7")
                    SA7->A7_CLIENTE := cCodCli
                    SA7->A7_LOJA    := cLoja
                    SA7->A7_PRODUTO := cProduto
                    SA7->A7_XSHELFL := nShelfLife
                SA7->( MsUnlock() )
            EndIf
        EndIf
	Next nX

	RestArea(aAreaSA7)
Return
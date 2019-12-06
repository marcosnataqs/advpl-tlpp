#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} LA05A009

Importação de pedidos de venda (Layout ATACADÃO S.A.)
Arquivo CSV (Separado por ponto e vírgula)

@author 	Marcos Natã Santos
@since 		09/04/2019
@version 	12.1.17
/*/
User Function LA05A009() //-- U_LA05A009()
    Local oCancel
    Local oGroup
    Local oProcess
    Local oSay
    Static oDlg

    //--------------------------------------------------------//
	//-- Verifica horário para permitir inclusão de pedidos --//
	//--------------------------------------------------------//
    If .Not. U_VefHrPrc()
        Return
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Importação de Pedidos" FROM 000, 000  TO 180, 500 COLORS 0, 16777215 PIXEL

        @ 015, 010 GROUP oGroup TO 060, 240 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
        @ 030, 020 SAY oSay PROMPT "Realiza a importação de pedido de venda. Layout disponível: ATACADÃO" SIZE 210, 017 OF oDlg COLORS 0, 16777215 PIXEL
        @ 067, 135 BUTTON oProcess PROMPT "Buscar Arquivo" SIZE 050, 012 OF oDlg ACTION {|| GetDocFromPC() } PIXEL
        @ 067, 190 BUTTON oCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} GetDocFromPC

Busca dados (documento) do computador

@author 	Marcos Natã Santos
@since 		09/04/2019
@version 	12.1.17
/*/
Static Function GetDocFromPC()
    Local cPathArq  := ""
    Local cArquivo  := ""
    Local nHandle   := 0
    Local nQtdBytes := 1000000
    Local aLinhas   := {}
    Local aPedidos  := {}
    Local oProcess  := Nil

    cPathArq := cGetFile("Arquivo de Pedidos|*.*","Selecione um documento de pedidos",0,"C:\",.T.,,.F.)
	If Empty(cPathArq)
		MsgAlert("Documento não selecionado.")
        Return
	EndIf

    nHandle := FOpen(cPathArq , FO_READWRITE + FO_SHARED )
    If nHandle == -1
        MsgStop("Erro de abertura do arquivo: FERROR " + STR(FError(),4))
        Return
    Else
        cArquivo := FReadStr(nHandle, nQtdBytes)
        aLinhas  := StrTokArr(cArquivo, CHR(13)+CHR(10))
        
        //-- Verifica padrão do layout do arquivo --//
        If Len(aLinhas) <= 0
            MsgStop("Arquivo informado está vazio.")
            FClose(nHandle)
            Return
        Else
            If Len( StrTokArr(aLinhas[1], ";") ) <> 13
                MsgStop("Layout do arquivo divergente. Padrão ATACADÃO S.A.")
                FClose(nHandle)
                Return
            EndIf
        EndIf

        aPedidos := RetPdds(aLinhas)
        FClose(nHandle)
        oDlg:End()

        oProcess := MsNewProcess():New({|lEnd| ProcessDoc(@oProcess, @lEnd, aPedidos) },;
            "Importação de Pedidos", "Lendo Arquivo", .T.)
        oProcess:Activate()
    EndIf

Return

/*/{Protheus.doc} RetPdds
Monta array de pedidos de venda
@author 	Marcos Natã Santos
@since 		10/04/2019
@version 	12.1.17
/*/
Static Function RetPdds(aLinhas)
    Local nX       := 0
    Local aPedido  := {}
    Local aPedidos := {}
    Local cNumNov  := ""
    Local cNumAnt  := ""

    cNumAnt := SubStr(aLinhas[1],17,6)
    For nX := 1 To Len(aLinhas)
        cNumNov := SubStr(aLinhas[nX],17,6)
        If cNumNov == cNumAnt
            AADD(aPedido, aLinhas[nX])
        Else
            AADD(aPedidos, aPedido)
            aPedido := {}
            AADD(aPedido, aLinhas[nX])
        EndIf
        If nX == Len(aLinhas)
            AADD(aPedidos, aPedido)
        EndIf
        cNumAnt := SubStr(aLinhas[nX],17,6)
    Next nX

Return aPedidos

/*/{Protheus.doc} ProcessDoc

Processa documento para importação do pedidos

@author 	Marcos Natã Santos
@since 		10/04/2019
@version 	12.1.17
/*/
Static Function ProcessDoc(oProcess, lEnd, aDocs)
    Local nX, nI, nY
    Local nQtdLinhas
    Local aCab := {}, aItens := {}, aItensChoc := {}, aItensOvo := {}, aItensPntt := {}
    Local oModel      := Nil
    Local aErro       := {}

    Private nItemSeq     := 0
    Private nItemSeqChoc := 0
    Private nItemSeqOvo  := 0
    Private nItemSeqPntt := 0
    Private cProcessLog  := ""
    Private cMsgNumPed   := ""

    Private cCodCli      := ""
    Private cLoja        := ""

    oProcess:SetRegua1(Len(aDocs))
    For nI := 1 To Len(aDocs)
        If lEnd
            Exit
        EndIf
        oProcess:IncRegua1("Lendo Documento "+ cValToChar(nI) +" de "+ cValToChar(Len(aDocs)) + ": " + AllTrim( SubStr(aDocs[nI][1],16,6) ))
        
        //-- Cabeçalho Pedido --//
        PutPvHead(aDocs[nI][1], @aCab)

        nQtdLinhas := Len(aDocs[nI])
        oProcess:SetRegua2(nQtdLinhas)
        For nX := 1 To nQtdLinhas
            If lEnd
                Exit
            EndIf

            oProcess:IncRegua2( SubStr(aDocs[nI][nX],47,35) )
            
            If Len(aCab) > 0
                If !Empty(aCab[5][2]) .And. !Empty(aCab[8][2])
                    PutPvItem(aDocs[nI][nX], nX, @aItens, @aItensChoc, @aItensOvo, @aItensPntt, aCab[5][2], aCab[8][2])
                EndIf
            EndIf
        Next nX

        BEGIN TRANSACTION

            //-------------------------------------------------------------------------//
            //-- Verifica se todos os itens do pedido foram corretamente processados --//
            //-------------------------------------------------------------------------//
            If Len(aCab) > 0 .And. Len(aItens) = nItemSeq .And.;
                Len(aItensChoc) = nItemSeqChoc .And.;
                Len(aItensOvo) = nItemSeqOvo .And. Len(aItensPntt) = nItemSeqPntt
                //-------------------------//
                //-- Pedido Itens do Mix --//
                //-------------------------//
                If Len(aCab) > 0 .And. Len(aItens) > 0
                    oModel := FWLoadModel("LA05A001")
                    oModel:SetOperation(3) //-- Inclusão --//
                    oModel:Activate()

                    For nX := 1 To (Len(aCab)-1)
                        oModel:SetValue("M_SZL", aCab[nX][1], aCab[nX][2])
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.F.)

                    For nX := 1 To Len(aItens)
                        For nY := 1 To Len(aItens[nX])
                            If aItens[nX][nY][1] == "ZM_VEND"
                                oModel:SetValue("M_ITM", aItens[nX][nY][1], oModel:GetValue("M_SZL","ZL_VEND"))
                            ElseIf aItens[nX][nY][1] == "ZM_EMISSAO"
                                oModel:SetValue("M_ITM", aItens[nX][nY][1], oModel:GetValue("M_SZL","ZL_EMISSAO"))
                            ElseIf aItens[nX][nY][1] == "ZM_CLIENTE"
                                oModel:SetValue("M_ITM", aItens[nX][nY][1], oModel:GetValue("M_SZL","ZL_CLIENTE"))
                            ElseIf aItens[nX][nY][1] == "ZM_LOJA"
                                oModel:SetValue("M_ITM", aItens[nX][nY][1], oModel:GetValue("M_SZL","ZL_LOJA"))
                            Else
                                oModel:SetValue("M_ITM", aItens[nX][nY][1], aItens[nX][nY][2])
                            EndIf
                        Next nY
                        If (nX+1) <= Len(aItens)
                            oModel:GetModel("M_ITM"):AddLine()
                        EndIf
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.T.)

                    If oModel:VldData()
                        oModel:CommitData()
                        cProcessLog += "Ped Cliente " + aCab[5][2] + " -> Integrado com sucesso." + CRLF
                    Else
                        aErro := oModel:GetErrorMessage()
                        AutoGrLog( "-----------------------------------------------------------------" )
                        AutoGrLog( "IMPORTAÇÃO EDI (AUTO COMERCIAL) LA05A005 -> PEDIDO " + aCab[5][2]  )
                        AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
                        AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
                        AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
                        AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
                        AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
                        AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
                        AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
                        AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
                        AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
                        AutoGrLog( "-----------------------------------------------------------------" )
                        cProcessLog += "Ped Cliente " + aCab[5][2] + " -> Não integrado. Verificar e importar novamente." + CRLF
                        DisarmTransaction()
                    EndIf

                    oModel:DeActivate()
                EndIf

                //----------------------------//
                //-- Pedido Itens Chocolate --//
                //----------------------------//
                If Len(aCab) > 0 .And. Len(aItensChoc) > 0
                    oModel := FWLoadModel("LA05A001")
                    oModel:SetOperation(3) //-- Inclusão --//
                    oModel:Activate()

                    For nX := 1 To (Len(aCab)-1)
                        oModel:SetValue("M_SZL", aCab[nX][1], aCab[nX][2])
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.F.)

                    For nX := 1 To Len(aItensChoc)
                        For nY := 1 To Len(aItensChoc[nX])
                            If aItensChoc[nX][nY][1] == "ZM_VEND"
                                oModel:SetValue("M_ITM", aItensChoc[nX][nY][1], oModel:GetValue("M_SZL","ZL_VEND"))
                            ElseIf aItensChoc[nX][nY][1] == "ZM_EMISSAO"
                                oModel:SetValue("M_ITM", aItensChoc[nX][nY][1], oModel:GetValue("M_SZL","ZL_EMISSAO"))
                            ElseIf aItensChoc[nX][nY][1] == "ZM_CLIENTE"
                                oModel:SetValue("M_ITM", aItensChoc[nX][nY][1], oModel:GetValue("M_SZL","ZL_CLIENTE"))
                            ElseIf aItensChoc[nX][nY][1] == "ZM_LOJA"
                                oModel:SetValue("M_ITM", aItensChoc[nX][nY][1], oModel:GetValue("M_SZL","ZL_LOJA"))
                            Else
                                oModel:SetValue("M_ITM", aItensChoc[nX][nY][1], aItensChoc[nX][nY][2])
                            EndIf
                        Next nY
                        If (nX+1) <= Len(aItensChoc)
                            oModel:GetModel("M_ITM"):AddLine()
                        EndIf
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.T.)

                    If oModel:VldData()
                        oModel:CommitData()
                        cProcessLog += "Ped Cliente Chocolate " + aCab[5][2] + " -> Integrado com sucesso." + CRLF
                    Else
                        aErro := oModel:GetErrorMessage()
                        AutoGrLog( "-----------------------------------------------------------------" )
                        AutoGrLog( "IMPORTAÇÃO EDI (AUTO COMERCIAL) LA05A005 -> PEDIDO " + aCab[5][2]  )
                        AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
                        AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
                        AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
                        AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
                        AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
                        AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
                        AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
                        AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
                        AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
                        AutoGrLog( "-----------------------------------------------------------------" )
                        cProcessLog += "Ped Cliente Chocolate " + aCab[5][2] + " -> Não integrado. Verificar e importar novamente." + CRLF
                        DisarmTransaction()
                    EndIf

                    oModel:DeActivate()
                EndIf

                //-----------------------------//
                //-- Pedido Itens Ovo Pascoa --//
                //-----------------------------//
                If Len(aCab) > 0 .And. Len(aItensOvo) > 0
                    oModel := FWLoadModel("LA05A001")
                    oModel:SetOperation(3) //-- Inclusão --//
                    oModel:Activate()

                    For nX := 1 To (Len(aCab)-1)
                        oModel:SetValue("M_SZL", aCab[nX][1], aCab[nX][2])
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.F.)

                    For nX := 1 To Len(aItensOvo)
                        For nY := 1 To Len(aItensOvo[nX])
                            If aItensOvo[nX][nY][1] == "ZM_VEND"
                                oModel:SetValue("M_ITM", aItensOvo[nX][nY][1], oModel:GetValue("M_SZL","ZL_VEND"))
                            ElseIf aItensOvo[nX][nY][1] == "ZM_EMISSAO"
                                oModel:SetValue("M_ITM", aItensOvo[nX][nY][1], oModel:GetValue("M_SZL","ZL_EMISSAO"))
                            ElseIf aItensOvo[nX][nY][1] == "ZM_CLIENTE"
                                oModel:SetValue("M_ITM", aItensOvo[nX][nY][1], oModel:GetValue("M_SZL","ZL_CLIENTE"))
                            ElseIf aItensOvo[nX][nY][1] == "ZM_LOJA"
                                oModel:SetValue("M_ITM", aItensOvo[nX][nY][1], oModel:GetValue("M_SZL","ZL_LOJA"))
                            Else
                                oModel:SetValue("M_ITM", aItensOvo[nX][nY][1], aItensOvo[nX][nY][2])
                            EndIf
                        Next nY
                        If (nX+1) <= Len(aItensOvo)
                            oModel:GetModel("M_ITM"):AddLine()
                        EndIf
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.T.)

                    If oModel:VldData()
                        oModel:CommitData()
                        cProcessLog += "Ped Cliente Ovo Pascoa " + aCab[5][2] + " -> Integrado com sucesso." + CRLF
                    Else
                        aErro := oModel:GetErrorMessage()
                        AutoGrLog( "-----------------------------------------------------------------" )
                        AutoGrLog( "IMPORTAÇÃO EDI (AUTO COMERCIAL) LA05A005 -> PEDIDO " + aCab[5][2]  )
                        AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
                        AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
                        AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
                        AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
                        AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
                        AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
                        AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
                        AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
                        AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
                        AutoGrLog( "-----------------------------------------------------------------" )
                        cProcessLog += "Ped Cliente Ovo Pascoa " + aCab[5][2] + " -> Não integrado. Verificar e importar novamente." + CRLF
                        DisarmTransaction()
                    EndIf

                    oModel:DeActivate()
                EndIf

                //-----------------------------//
                //-- Pedido Itens Panettones --//
                //-----------------------------//
                If Len(aCab) > 0 .And. Len(aItensPntt) > 0
                    oModel := FWLoadModel("LA05A001")
                    oModel:SetOperation(3) //-- Inclusão --//
                    oModel:Activate()

                    For nX := 1 To (Len(aCab)-1)
                        oModel:SetValue("M_SZL", aCab[nX][1], aCab[nX][2])
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.F.)

                    For nX := 1 To Len(aItensPntt)
                        For nY := 1 To Len(aItensPntt[nX])
                            If aItensPntt[nX][nY][1] == "ZM_VEND"
                                oModel:SetValue("M_ITM", aItensPntt[nX][nY][1], oModel:GetValue("M_SZL","ZL_VEND"))
                            ElseIf aItensPntt[nX][nY][1] == "ZM_EMISSAO"
                                oModel:SetValue("M_ITM", aItensPntt[nX][nY][1], oModel:GetValue("M_SZL","ZL_EMISSAO"))
                            ElseIf aItensPntt[nX][nY][1] == "ZM_CLIENTE"
                                oModel:SetValue("M_ITM", aItensPntt[nX][nY][1], oModel:GetValue("M_SZL","ZL_CLIENTE"))
                            ElseIf aItensPntt[nX][nY][1] == "ZM_LOJA"
                                oModel:SetValue("M_ITM", aItensPntt[nX][nY][1], oModel:GetValue("M_SZL","ZL_LOJA"))
                            Else
                                oModel:SetValue("M_ITM", aItensPntt[nX][nY][1], aItensPntt[nX][nY][2])
                            EndIf
                        Next nY
                        If (nX+1) <= Len(aItensPntt)
                            oModel:GetModel("M_ITM"):AddLine()
                        EndIf
                    Next nX

                    oModel:GetModel("M_ITM"):SetNoInsertLine(.T.)

                    If oModel:VldData()
                        oModel:CommitData()
                        cProcessLog += "Ped Cliente Panettones " + aCab[5][2] + " -> Integrado com sucesso." + CRLF
                    Else
                        aErro := oModel:GetErrorMessage()
                        AutoGrLog( "-----------------------------------------------------------------" )
                        AutoGrLog( "IMPORTAÇÃO EDI (AUTO COMERCIAL) LA05A005 -> PEDIDO " + aCab[5][2]  )
                        AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
                        AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
                        AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
                        AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
                        AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
                        AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
                        AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
                        AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
                        AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
                        AutoGrLog( "-----------------------------------------------------------------" )
                        cProcessLog += "Ped Cliente Panettones " + aCab[5][2] + " -> Não integrado. Verificar e importar novamente." + CRLF
                        DisarmTransaction()
                    EndIf

                    oModel:DeActivate()
                EndIf

            EndIf

        END TRANSACTION

        //-- Limpa dados para próximo pedido --//
        aCab         := {}
        aItens       := {}
        aItensChoc   := {}
        aItensOvo    := {}
        aItensPntt   := {}
        nItemSeq     := 0
        nItemSeqChoc := 0
        nItemSeqOvo  := 0
        nItemSeqPntt := 0

    Next nI

    //-- Logs para servidor --//
    ConOut("LOG INTEGRATION ATACADAO LA05A009 - INICIO " + DTOC(Date()) + " " + Time())
    ConOut(cProcessLog)
    ConOut("LOG INTEGRATION ATACADAO LA05A009 - FIM " + DTOC(Date()) + " " + Time())

    //-- Workflow de logs --//
    SendLogWF(cProcessLog)

    //-- Gera arquivo log e abre notepad --//
    MemoWrite("C:\Windows\Temp\atacadao-process-log.txt", cProcessLog)
    ShellExecute( "Open", "C:\Windows\System32\notepad.exe", "atacadao-process-log.txt", "C:\Windows\Temp\", 1 )

Return

/*/{Protheus.doc} PutPvHead

Cabeçalho Pedido de Venda

@author 	Marcos Natã Santos
@since 		10/04/2019
@version 	12.1.17
/*/
Static Function PutPvHead(aLinha,aCab)
    Local aPedido    := StrTokArr(aLinha, ";")
    Local lRet       := .T.
    Local aAreaSA1   := SA1->( GetArea() )
    Local cCnpj      := AllTrim(aPedido[1])
    Local cPedCli    := AllTrim(aPedido[2])
    Local dDtEntrega := STOD( Space(8) )
    Local cTabAtiva
	Local dTabDtAte
	Local cTabHrAte
	
    SA1->( dbSetOrder(3) )
    If SA1->( dbSeek( xFilial("SA1") + cCnpj ) )
        If SA1->A1_MSBLQL <> "1" //-- Cliente bloqueado para uso --//
            If !Empty(SA1->A1_TABELA)
                cTabAtiva := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_ATIVO")
                dTabDtAte := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_DATATE")
                cTabHrAte := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_HORATE")

                cCodCli := SA1->A1_COD
                cLoja := SA1->A1_LOJA

                //-- Data entrega pelo Lead Time --//
                dDtEntrega := DaySum(Date(), SA1->A1_LEADTM)

                If cTabAtiva == "1" //-- 1=Sim 2=Nao
                    If !Empty(dTabDtAte) .And. dTabDtAte < Date()
                        cProcessLog += "Ped Cliente " + cPedCli + " -> Tabela de preço do cliente fora de vigência." + CRLF
                        lRet := .F.
                    ElseIf !Empty(dTabDtAte) .And. dTabDtAte = Date()
                        If !Empty(cTabHrAte) .And. cTabHrAte < Time()
                            cProcessLog += "Ped Cliente " + cPedCli + " -> Tabela de preço do cliente fora de vigência." + CRLF
                            lRet := .F.
                        EndIf
                    EndIf
                Else
                    cProcessLog += "Ped Cliente " + cPedCli + " -> Tabela de preço do cliente não ativa." + CRLF
                    lRet := .F.
                EndIf

                If lRet
                    aAdd( aCab, { "ZL_CLIENTE", SA1->A1_COD } )
                    aAdd( aCab, { "ZL_LOJA",    SA1->A1_LOJA } )
                    aAdd( aCab, { "ZL_TPVEND",  "1" } )
                    aAdd( aCab, { "ZL_CONDPAD", SA1->A1_COND } )
                    aAdd( aCab, { "ZL_PEDCLI",  Right(AllTrim(cPedCli),15) } )
                    aAdd( aCab, { "ZL_DATENTR", dDtEntrega } )
                    aAdd( aCab, { "ZL_ORIGEM",  "IMPORT" } )
                    aAdd( aCab, { "TABPRECO",   SA1->A1_TABELA } )
                EndIf
            Else
                cProcessLog += "Ped Cliente " + cPedCli + " -> Cliente sem tabela de preço cadastrada." + CRLF
            EndIf
        Else
            cProcessLog += "Ped Cliente " + cPedCli + " -> Cliente "+ SA1->A1_COD +"-"+ SA1->A1_LOJA +" bloqueado para uso." + CRLF
        EndIf
    Else
        cProcessLog += "Ped Cliente " + cPedCli + " -> CNPJ do cliente não encontrado na base do Protheus." + CRLF
    EndIf

    RestArea(aAreaSA1)

Return

/*/{Protheus.doc} PutPvItem

Itens Pedido de Venda

@author 	Marcos Natã Santos
@since 		10/04/2019
@version 	12.1.17
/*/
Static Function PutPvItem(aLinha,nItem,aItens,aItensChoc,aItensOvo,aItensPntt,cPedCli,cTbPreco)
    Local aLinItem    := StrTokArr(aLinha, ";")
	Local aItem       := {}
    Local cCodBarra   := AllTrim(aLinItem[4])
    Local aProdInfo   := StaticCall(LA05A005, GetProd, cCodBarra)
	Local cCodProd    := aProdInfo[1]
    Local cMsBlql     := aProdInfo[2]
    Local cProdGroup  := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProd, "B1_BASE3"))
    Local cBlqVenda   := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProd, "B1_BLQVEND"))
    Local nPrecoProd  := Posicione("DA1", 7, xFilial("DA1") + cTbPreco + cCodProd, "DA1_PRCVEN")
    Local nPrecoItem  := 0
    Local nQtdVen     := Val( aLinItem[7]  )
    Local nPrecoLiq   := Val( SubStr(aLinItem[8],1,8) + '.' + SubStr(aLinItem[8],9,2)  )
    Local nValorTot   := Val( SubStr(aLinItem[9],1,8) + '.' + SubStr(aLinItem[9],9,2)  )
    Local cItemSeq    := 0
    Local cItemSeqPC  := PadL(cValToChar(nItem), 4, "0")
    Local cGrpChoc    := GetMV("MV_XGRCHOC")
    Local cGrpOvo     := GetMV("MV_XGRPOVO")
    Local cGrpPntt    := GetMv("MV_XGRPNTT")
    Local cPedImp     := ""

    //-- Verifica se o item já foi importado --//
    If ItemJaImport(cPedCli,cCodProd,@cPedImp)
        cProcessLog += "Ped Cliente " + cPedCli + " Produto " + cCodProd + " já importado. Ped Auto " + cPedImp + CRLF
        Return
    EndIf

    //-- Avalia estado do produto  --//
    //-- Realiza corte de item     --//
    If Empty(cCodProd)
        cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeqPC;
            +" -> Produto não encontrado. Item cortado do pedido. Cod Barra: " + cCodBarra + CRLF
        Return
    ElseIf cMsBlql == '1'
        cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeqPC;
            +" -> Produto "+ cCodProd + " bloqueado para uso. Item cortado do pedido." + CRLF
        Return
    ElseIf cBlqVenda == '1'
        cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeqPC;
            +" -> Produto "+ cCodProd + " bloqueado para Venda. Item cortado do pedido." + CRLF
        Return
    ElseIf StaticCall(LA05A005, AvalCliCot, cPedCli, cCodCli, , cCodProd, nQtdVen) //-- Campanha Panettones --//
        cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeqPC;
        +" -> Produto "+ cCodProd + " não atende a cota da campanha. Item cortado do pedido." + CRLF
        Return
    EndIf

    //-- Avalia preços no documento --//
    If nPrecoLiq > 0
        nPrecoItem := nPrecoLiq
    Else
        nPrecoItem := (nValorTot / nQtdVen)
    EndIf

    //-- Segrega itens do grupo chocolate ou ovo pascoa --//
    If cProdGroup $ cGrpChoc
        nItemSeqChoc++
        cItemSeq := PadL(nItemSeqChoc, 2, "0")
    ElseIf cProdGroup $ cGrpOvo
        nItemSeqOvo++
        cItemSeq := PadL(nItemSeqOvo, 2, "0")
    ElseIf cProdGroup $ cGrpPntt
        nItemSeqPntt++
        cItemSeq := PadL(nItemSeqPntt, 2, "0")
    Else
        nItemSeq++
        cItemSeq := PadL(nItemSeq, 2, "0")
    EndIf

    If !Empty(nPrecoItem) .And. !Empty(nPrecoProd)
        aAdd( aItem , { "ZM_ITEM",    cItemSeq } )
        aAdd( aItem , { "ZM_PRODUTO", cCodProd } )
        aAdd( aItem , { "ZM_LOCAL",   "90" } )
        aAdd( aItem , { "ZM_QTD",     nQtdVen } )
        aAdd( aItem , { "ZM_TABPRE",  cTbPreco } )
        aAdd( aItem , { "ZM_PRCTAB",  nPrecoProd } )
        aAdd( aItem , { "ZM_VALOR",   nPrecoItem } )
        aAdd( aItem , { "ZM_TOTAL",   nQtdVen*nPrecoItem } )
        aAdd( aItem , { "ZM_TPOPER",  "50" } )
        aAdd( aItem , { "ZM_PESOLIQ", Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_PESO") } )
        aAdd( aItem , { "ZM_PESOBR",  Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_PESBRU") } )
        aAdd( aItem , { "ZM_VEND",    "" } )
        aAdd( aItem , { "ZM_EMISSAO", "" } )
        aAdd( aItem , { "ZM_CLIENTE", "" } )
        aAdd( aItem , { "ZM_LOJA", "" } )
        aAdd( aItem , { "ZM_LIBER",   "1" } )
        
        //-- Segrega itens do grupo chocolate, ovo pascoa e panettones --//
        If cProdGroup $ cGrpChoc
            aAdd( aItensChoc , aItem )
        ElseIf cProdGroup $ cGrpOvo
            aAdd( aItensOvo , aItem )
        ElseIf cProdGroup $ cGrpPntt
            aAdd( aItensPntt , aItem )
        Else
            aAdd( aItens , aItem )
        EndIf

        If nPrecoProd > nPrecoItem
            cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeq +" Produto "+ cCodProd;
                + " -> Preço divergente: Tabela = R$" + cValToChar(nPrecoProd);
                + " Importado = R$" + cValToChar(nPrecoItem) + CRLF
        EndIf
    Else
        cProcessLog += "Ped Cliente " + cPedCli + " Item "+ cItemSeqPC +" Produto "+ cCodProd;
                +" -> Preço não encontrado na tabela de preço. Cod Tab: " + cTbPreco + CRLF
    EndIf

Return

/*/{Protheus.doc} SendLogWF

Envia workflow com logs de processamento

@author 	Marcos Natã Santos
@since 		16/04/2019
@version 	12.1.17
/*/
Static Function SendLogWF(cLog)
    Local oServer
    Local oMessage
    Local xRet

    Local cSendSrv := StrTran( GETMV('MV_RELSERV'), ":587")
    Local cUser    := GETMV('MV_RELACNT')
    Local cPass    := GETMV('MV_RELAPSW')
    Local nPort    := 587
    Local cFrom    := GETMV('MV_RELACNT')
    Local cTo      := ""
    Local cCc      := ""
    Local cBcc     := ""
    Local cSubject := ""
    Local cBody    := ""

    Default cLog := ""

    //Cria a conexão com o server STMP ( Envio de e-mail )
    oServer := TMailManager():New()
    oServer:Init( "", cSendSrv, cUser, cPass, , nPort )

    //Seta um tempo de time out com servidor de 1min
    xRet := oServer:SetSmtpTimeOut( 60 )
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Falha ao setar o time out -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Setou o time out" )
    EndIf
    
    //Realiza a conexão SMTP
    xRet := oServer:SmtpConnect()
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Falha ao conectar -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Conectou com Sucesso" )
    EndIf

    // Autenticação no servidor SMTP
    xRet := oServer:SmtpAuth( cUser, cPass )
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Não conseguiu autenticar no servidor SMTP -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Autenticação realizada com Sucesso" )
    EndIf
    
    //Apos a conexão, cria o objeto da mensagem
    oMessage := TMailMessage():New()
    
    //Limpa o objeto
    oMessage:Clear()

    cSubject := "ATACADÃO: LOGS INTEGRAÇÃO PEDIDOS " + DTOC(Date()) + " " + Time()
    cBody    := GetHtmlMsg(cLog)

    cTo      := UsrRetMail(__cUserID) + ";"
    cTo      += "customer@lineaalimentos.com.br"

    //Popula com os dados de envio
    oMessage:cFrom    := cFrom
    oMessage:cTo      := cTo
    oMessage:cCc      := cCc
    oMessage:cBcc     := cBcc
    oMessage:cSubject := cSubject
    oMessage:cBody    := cBody

    //Envia o e-mail
    xRet := oMessage:Send( oServer )
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Erro ao enviar o e-mail -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: E-mail enviado com sucesso" )
    EndIf

    //Desconecta do servidor
    xRet := oServer:SmtpDisconnect()
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Erro ao disconectar do servidor SMTP -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A009: Disconectou do servidor SMTP" )
    EndIf

Return .T.

/*/{Protheus.doc} GetHtmlMsg

Monta mensagem em html

@author 	Marcos Natã Santos
@since 		20/12/2018
@version 	12.1.17
/*/
Static Function GetHtmlMsg(cLog)
    Local cMsg := ""
    Local aLog := StrTokArr(cLog, CHR(13) + CHR(10))
    Local nX

    cMsg := "<!DOCTYPE html> " + CRLF
    cMsg += "<html lang='en'> " + CRLF
    cMsg += "<head> " + CRLF
    cMsg += "<title>Atacadão Logs</title> " + CRLF
    cMsg += "<meta charset='utf-8'> " + CRLF
    cMsg += "<meta name='viewport' content='width=device-width, initial-scale=1'> " + CRLF
    cMsg += "<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'> " + CRLF
    cMsg += "<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script> " + CRLF
    cMsg += "<script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js'></script> " + CRLF
    cMsg += "  <style> " + CRLF
    cMsg += "    table, th, td { " + CRLF
    cMsg += "        border: 1px solid black; " + CRLF
    cMsg += "        border-collapse: collapse; " + CRLF
    cMsg += "    } " + CRLF
    cMsg += "  </style> " + CRLF
    cMsg += "</head> " + CRLF
    cMsg += "<body> " + CRLF
    cMsg += "<div class='container'> " + CRLF
    cMsg += "<div class='jumbotron'> " + CRLF
    cMsg += "    <h1>ATACADÃO: LOGS INTEGRAÇÃO PEDIDOS</h1> " + CRLF
    cMsg += "    </div> " + CRLF
    cMsg += "</div> " + CRLF
    cMsg += "<table class='table table-bordered'> " + CRLF
    cMsg += "    <thead> " + CRLF
    cMsg += "        <tr> " + CRLF
    cMsg += "        <th>Log Processamento</th> " + CRLF
    cMsg += "        </tr> " + CRLF
    cMsg += "    </thead> " + CRLF
    cMsg += "    <tbody> " + CRLF

    For nX := 1 To Len(aLog)
        cMsg += "        <tr> " + CRLF
        cMsg += "            <td>"+ AllTrim(aLog[nX]) +"</td> " + CRLF
        cMsg += "        </tr> " + CRLF
    Next nX
    
    cMsg += "    </tbody> " + CRLF
    cMsg += "</table> " + CRLF
    cMsg += "</body> " + CRLF
    cMsg += "</html> " + CRLF

Return cMsg

/*/{Protheus.doc} ItemJaImport

Valida se o item do pedido já foi importado

@author 	Marcos Natã Santos
@since 		24/04/2019
@version 	12.1.17
/*/
Static Function ItemJaImport(cPedCli,cCodProd,cPedImp)
    Local lRet     := .F.
	Local cQry     := ""
	Local nQtdReg  := 0

	cQry := "SELECT SZL.ZL_PEDCLI, SZM.ZM_NUM, SZM.ZM_PRODUTO " + CRLF
    cQry += "FROM SZL010 SZL " + CRLF
    cQry += "INNER JOIN SZM010 SZM " + CRLF
    cQry += "    ON SZM.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SZM.ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
    cQry += "    AND SZM.ZM_NUM = SZL.ZL_NUM " + CRLF
    cQry += "    AND SZM.ZM_CLIENTE = SZL.ZL_CLIENTE " + CRLF
    cQry += "    AND SZM.ZM_LOJA = SZL.ZL_LOJA " + CRLF
    cQry += "WHERE SZL.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SZL.ZL_FILIAL = '"+ xFilial("SZL") +"' " + CRLF
    cQry += "    AND SZL.ZL_PEDCLI = '"+ cPedCli +"' " + CRLF
    cQry += "    AND SZM.ZM_PRODUTO = '"+ cCodProd +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("ITMJAIMP") > 0
		ITMJAIMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "ITMJAIMP"

	ITMJAIMP->(dbGoTop())
	COUNT TO nQtdReg
	ITMJAIMP->(dbGoTop())

	If nQtdReg > 0
		lRet := .T.
        cPedImp := AllTrim(ITMJAIMP->ZM_NUM)
	EndIf

	ITMJAIMP->( dbCloseArea() )
Return lRet
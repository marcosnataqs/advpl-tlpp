#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE CABECALHO    "01" //-- cabecalho
#DEFINE PAGAMENTO    "02" //-- pagamento
#DEFINE DESCONTOS    "03" //-- descontos e encargos do pedido
#DEFINE ITENS        "04" //-- itens
#DEFINE GRADE        "05" //-- grade
#DEFINE CROSSDOCKING "06" //-- crossdocking
#DEFINE SUMARIO      "09" //-- sumario unica ocorrencia

/*/{Protheus.doc} LA05A005

Integração Documentos (Pedidos) NeoGrid EDI

@author 	Marcos Natã Santos
@since 		18/12/2018
@version 	12.1.17
/*/
User Function LA05A005() //-- U_LA05A005()
    Local lOk      := .F.
    Local oCancel
    Local oGroup
    Local oProcess
    Local oRadMenu
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Static oDlg

    Private nRadMenu  := 1

    //--------------------------------------------------------//
	//-- Verifica horário para permitir inclusão de pedidos --//
	//--------------------------------------------------------//
    If .Not. U_VefHrPrc()
        Return
    EndIf

    If !LockByName("LA05A005",.F.,.F.,.T.)
        MsgAlert("Rotina está sendo executada por outro usuário.")
        Return
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Importação NeoGrid" FROM 000, 000  TO 220, 500 COLORS 0, 16777215 PIXEL

        @ 015, 015 GROUP oGroup TO 075, 235 PROMPT "Importação NeoGrid" OF oDlg COLOR 0, 16777215 PIXEL
        @ 030, 020 SAY oSay1 PROMPT "Realize a importação de documentos da NeoGrid." SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 037, 020 SAY oSay2 PROMPT "Opções:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 047, 030 SAY oSay3 PROMPT "Manual: Importe um documento do seu computador." SIZE 130, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 057, 030 SAY oSay4 PROMPT "Webservice: Importe automaticamente os documentos na base da NeoGrid." SIZE 190, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 085, 015 RADIO oRadMenu VAR nRadMenu ITEMS "Manual","Webservice" SIZE 092, 017 OF oDlg COLOR 0, 16777215 PIXEL
        @ 090, 130 BUTTON oProcess PROMPT "Processar" SIZE 050, 012 OF oDlg ACTION {|| lOk:=.T., oDlg:End() } PIXEL
        @ 090, 185 BUTTON oCancel PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOk
        Do Case
            Case nRadMenu = 1 //-- Importação Manual
                GetDocFromPC()
            Case nRadMenu = 2 //-- Importação Webservice
                GetDocsFromEDI()
        EndCase
    EndIf

    UnLockByName("LA05A005",.F.,.F.,.T.)

Return

/*/{Protheus.doc} GetDocsFromEDI

Busca dados (documentos) na base da NeoGrid

@author 	Marcos Natã Santos
@since 		14/12/2018
@version 	12.1.17
/*/
Static Function GetDocsFromEDI()
    Local lOk
    Local xRet
    Local nQtdReg
    Local nX
    Local cContent := ""
    Local aDocs    := {}
    Local aDoc     := {}
    Local oProcess := Nil

    Local cWSDL    := SuperGetMV("MV_XNGWSDL", .F., "https://as2edi.neogrid.com/ws/neogrid.webedi.Neogrid.webservice3:neogrid?WSDL")
    Local cUser    := SuperGetMV("MV_XNGUSER", .F., "05207076000106#eicdobrasilws")
    Local cPass    := SuperGetMV("MV_XNGPASS", .F., "eicws@@2018")

    Local cDocType := "5" //-- 5 = Pedidos --//
    Local cDocsQty := "50" //-- valor maximo = 50 --//
    Local cZip     := "false"

    Private oWSDL
    Private oXML
    Private cCnpj  := "05207076000297"

    oWSDL := TWSDLManager():New()
    oXML  := TXmlManager():New()

    oWSDL:lVerbose := .T.
    
    //-- Certificado deve estar na pasta protheus_data --//
    oWSDL:cSSLCACertFile := "\certificado\NeoGrid\CA_NeoGrid.pem"
    oWSDL:SetAuthentication(cUser, cPass)

    //-- Força a utilização do SSLv3 --//
    oWsdl:nSSLVersion := 3

    //-- WSDL do ambiente produção NeoGrid --//
    lOk := oWSDL:ParseURL( cWSDL )
    If !lOk 
        MsgStop( oWSDL:cError , "ParseURL() ERROR")
        Return
    EndIf

    lOk := oWSDL:SetOperation( "getDocsFromEDI" )
    If !lOk
        MsgStop( oWSDL:cError , "SetOperation(getDocsFromEDI) ERROR")
        Return
    EndIf

    //---------------------------//
    //-- Parametros webservice --//
    //---------------------------//
    oWSDL:SetFirst("docType", cDocType)
    oWSDL:SetFirst("cnpj", cCnpj)
    oWSDL:SetFirst("docsQty", cDocsQty)
    oWSDL:SetFirst("zip", cZip)

    lOk := oWSDL:SendSoapMsg()
    If !lOk
        MsgStop( oWSDL:cError , "SendSoapMsg() ERROR")
        Return
    EndIf

    //----------------------------------------------------------//
    //-- No mínimo maxStringSize=10 no appserver.ini          --//
    //-- para conseguir receber a resposta completa do server --//
    //----------------------------------------------------------//
    cResp := oWSDL:GetSoapResponse()
    xRet := oXML:Parse( cResp )
    If xRet == .F.
        MsgStop( "Error: " + oXML:Error() )
        Return
    EndIf

    oXML:DOMChildNode() //-- Header --//
    oXML:DOMNextNode() //-- Body --//

    If oXML:cName == "Fault"
        MsgStop( "Error getDocsFromEDI: SOAP request fault" )
        Return
    EndIf

    oXML:DOMChildNode() //--getDocsFromEDIResponse --//
    oXML:DOMChildNode() //-- Document --//
    oXML:Parse( oXML:cText ) //-- Parse no resultado da chamada --//

    If oXML:cName == "files"
        nQtdReg := oXML:DOMChildCount()

        If nQtdReg > 0
            For nX := 1 To nQtdReg
                cContent := oXML:XPathGetNodeValue( "/files/document["+ cValToChar(nX) +"]/content" )
                aDoc     := StrTokArr(cContent, CHR(10))
                AADD(aDoc, oXML:XPathGetNodeValue( "/files/document["+ cValToChar(nX) +"]/docNum" ))
                AADD(aDocs, aDoc)
            Next nX
            oProcess := MsNewProcess():New({|lEnd| ProcessDoc(@oProcess, @lEnd, aDocs) }, "Importação Pedidos NeoGrid EDI",;
                "Lendo Arquivos da Base de Pedidos", .T.)
            oProcess:Activate()
        Else
            MsgInfo("Não existem documentos para importação.")
        EndIf
    EndIf

Return

/*/{Protheus.doc} GetDocFromPC

Busca dados (documento) do computador

@author 	Marcos Natã Santos
@since 		19/12/2018
@version 	12.1.17
/*/
Static Function GetDocFromPC()
    Local lOk      := .T.
    Local cPathArq := ""
    Local cText    := ""
    Local aDoc     := {}
    Local aDocs    := {}
    Local oProcess := Nil

    cPathArq := cGetFile('Arquivo *|*.*|Arquivo TXT|*.txt','Selecione um documento NeoGrid',0,'C:\',.T.,,.F.)
	If Empty(cPathArq)
		MsgAlert("Documento não selecionado.")
        Return
	EndIf

    cText := MemoRead(cPathArq)
    If !Empty(cText)
        aDoc  := StrTokArr(cText, CHR(10))
        AADD(aDoc, AllTrim(SubStr(aDoc[1], 9, 20)) )
        AADD(aDocs, aDoc)

        If IsImported( AllTrim(SubStr(aDoc[1], 9, 20)) )
            lOk := MsgYesNo("Pedido já importado. Deseja continuar?", "Importação")
        EndIf

        If lOk
            If SubStr(aDocs[1][1], 1, 2) == "01" //-- Verificação do padrão NeoGrid
                oProcess := MsNewProcess():New({|lEnd| ProcessDoc(@oProcess, @lEnd, aDocs) },;
                    "Importação Pedido NeoGrid", "Lendo Arquivo", .T.)
                oProcess:Activate()
            Else
                MsgAlert("Selecione um arquivo válido da NeoGrid.")
                Return
            EndIf
        EndIf
    Else
        MsgAlert("Documento vazio.")
        Return
    EndIf

Return

/*/{Protheus.doc} ProcessDoc

Processa documentos para importação do pedidos

@author 	Marcos Natã Santos
@since 		17/12/2018
@version 	12.1.17
/*/
Static Function ProcessDoc(oProcess, lEnd, aDocs)
    Local nX, nI, nY
    Local nQtdLinhas
    Local cLinha
    Local aCab := {}, aItens := {}, aItensChoc := {}, aItensOvo := {}, aItensPntt := {}
    Local oModel      := Nil
    Local aErro       := {}
    Local lCommitData := .F.

    Private nItemSeq     := 0
    Private nItemSeqChoc := 0
    Private nItemSeqOvo  := 0
    Private nItemSeqPntt := 0
    Private cProcessLog  := ""

    Private cCodCli      := ""
    Private cLoja        := ""
    Private cNReduz      := ""
    Private cMsgCli      := ""
    Private cMsgNumPed   := ""

    oProcess:SetRegua1(Len(aDocs))
    For nI := 1 To Len(aDocs)
        If lEnd
            Exit
        EndIf
        oProcess:IncRegua1("Lendo Documento "+ cValToChar(nI) +" de "+ cValToChar(Len(aDocs)) + ": " + AllTrim( aDocs[nI][Len(aDocs[nI])] ))
        
        //-- Desconsidera numero do documento na Neogrid --//
        nQtdLinhas := (Len(aDocs[nI]) - 1)
        oProcess:SetRegua2(nQtdLinhas)
        For nX := 1 To nQtdLinhas
            If lEnd
                Exit
            EndIf
            cLinha := aDocs[nI][nX]
            Do Case
                Case SubStr(cLinha, 1, 2) == CABECALHO
                    oProcess:IncRegua2("Processando: Cabeçalho")
                    PutPvHead(cLinha, @aCab)
                
                Case SubStr(cLinha, 1, 2) == PAGAMENTO
                    oProcess:IncRegua2("Processando: Pagamento")

                Case SubStr(cLinha, 1, 2) == DESCONTOS
                    oProcess:IncRegua2("Processando: Descontos")

                Case SubStr(cLinha, 1, 2) == ITENS
                    oProcess:IncRegua2("Processando: Itens")
                    If Len(aCab) > 0
                        If !Empty(aCab[5][2]) .And. !Empty(aCab[8][2])
                            PutPvItem(cLinha, @aItens, @aItensChoc, @aItensOvo, @aItensPntt, aCab[5][2], aCab[8][2])
                        EndIf
                    EndIf
                
                Case SubStr(cLinha, 1, 2) == GRADE
                    oProcess:IncRegua2("Processando: Grade")

                Case SubStr(cLinha, 1, 2) == CROSSDOCKING
                    oProcess:IncRegua2("Processando: CrossDocking")

                Case SubStr(cLinha, 1, 2) == SUMARIO
                    oProcess:IncRegua2("Processando: Sumário")

            EndCase
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
                        lCommitData := oModel:CommitData()
                        cMsgNumPed  := " Ped Auto " + oModel:GetModel("M_SZL"):GetValue("ZL_NUM")
                        cProcessLog += "Ped Cliente " + aCab[5][2] + cMsgCli + cMsgNumPed + " -> Integrado com sucesso." + CRLF
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
                        cProcessLog += "Ped Cliente " + aCab[5][2] + cMsgCli + " -> Não integrado. Verificar e importar novamente." + CRLF
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
                        lCommitData := oModel:CommitData()
                        cMsgNumPed  := " Ped Auto " + oModel:GetModel("M_SZL"):GetValue("ZL_NUM")
                        cProcessLog += "Ped Cliente Chocolate " + aCab[5][2] + cMsgCli + cMsgNumPed + " -> Integrado com sucesso." + CRLF
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
                        cProcessLog += "Ped Cliente Chocolate " + aCab[5][2] + cMsgCli + " -> Não integrado. Verificar e importar novamente." + CRLF
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
                        lCommitData := oModel:CommitData()
                        cMsgNumPed  := " Ped Auto " + oModel:GetModel("M_SZL"):GetValue("ZL_NUM")
                        cProcessLog += "Ped Cliente Ovo Pascoa " + aCab[5][2] + cMsgCli + cMsgNumPed + " -> Integrado com sucesso." + CRLF
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
                        cProcessLog += "Ped Cliente Ovo Pascoa " + aCab[5][2] + cMsgCli + " -> Não integrado. Verificar e importar novamente." + CRLF
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
                        lCommitData := oModel:CommitData()
                        cMsgNumPed  := " Ped Auto " + oModel:GetModel("M_SZL"):GetValue("ZL_NUM")
                        cProcessLog += "Ped Cliente Panettones " + aCab[5][2] + cMsgCli + cMsgNumPed + " -> Integrado com sucesso." + CRLF
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
                        cProcessLog += "Ped Cliente Panettones " + aCab[5][2] + cMsgCli + " -> Não integrado. Verificar e importar novamente." + CRLF
                        DisarmTransaction()
                    EndIf

                    oModel:DeActivate()
                EndIf

                If lCommitData .And. nRadMenu = 2
                    SetStatusDoc(aDocs[nI][Len(aDocs[nI])], cCnpj, AllTrim(SZL->ZL_NUM))
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
    ConOut("LOG INTEGRATION NEOGRID LA05A005 - INICIO " + DTOC(Date()) + " " + Time())
    ConOut(cProcessLog)
    ConOut("LOG INTEGRATION NEOGRID LA05A005 - FIM " + DTOC(Date()) + " " + Time())

    //-- Workflow de logs --//
    SendLogWF(cProcessLog)

    //-- Gera arquivo log e abre notepad --//
    MemoWrite("C:\Windows\Temp\neogrid-process-log.txt", cProcessLog)
    ShellExecute( "Open", "C:\Windows\System32\notepad.exe", "neogrid-process-log.txt", "C:\Windows\Temp\", 1 )

Return

/*/{Protheus.doc} PutPvHead

Cabeçalho Pedido de Venda

@author 	Marcos Natã Santos
@since 		17/12/2018
@version 	12.1.17
/*/
Static Function PutPvHead(cLinha,aCab)
    Local lRet       := .T.
    Local aAreaSA1   := SA1->( GetArea() )
    Local cCnpj      := AllTrim(SubStr(cLinha, 209, 14))
    Local cPedCli    := AllTrim(SubStr(cLinha, 9, 20))
    Local dDtEntrega := STOD(AllTrim(SubStr(cLinha, 73, 8)))
    Local cObs       := AllTrim(SubStr(cLinha, 276, 40))
    Local cTipoPed   := SubStr(cLinha, 6, 3)
    Local cTabAtiva
	Local dTabDtAte
	Local cTabHrAte
	
    If cTipoPed == "001" //-- Pedido Normal
        SA1->( dbSetOrder(3) )
        If SA1->( dbSeek( xFilial("SA1") + cCnpj ) )

            cCodCli := SA1->A1_COD
            cLoja   := SA1->A1_LOJA
            cNReduz := AllTrim(SA1->A1_NREDUZ)
            cMsgCli := " Cliente " + cCodCli + "-" + cLoja + " " + cNReduz

            //-- Bloqueia importação de lojas do CARREFOUR --//
            If SA1->A1_COD == "000024" .And. ( Val(SA1->A1_LOJA) >= 10 .And. Val(SA1->A1_LOJA) <= 48 )
                cProcessLog += "Cliente " + AllTrim(SA1->A1_NREDUZ) + " Não Importa via NeoGrid." + CRLF
                Return
            EndIf
            If SA1->A1_MSBLQL <> "1" //-- Cliente bloqueado para uso --//
                If !Empty(SA1->A1_TABELA)
                    cTabAtiva := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_ATIVO")
                    dTabDtAte := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_DATATE")
                    cTabHrAte := Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_HORATE")

                    If cTabAtiva == "1" //-- 1=Sim 2=Nao
                        If !Empty(dTabDtAte) .And. dTabDtAte < Date()
                            cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " -> Tabela de preço do cliente fora de vigência." + CRLF
                            lRet := .F.
                        ElseIf !Empty(dTabDtAte) .And. dTabDtAte = Date()
                            If !Empty(cTabHrAte) .And. cTabHrAte < Time()
                                cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " -> Tabela de preço do cliente fora de vigência." + CRLF
                                lRet := .F.
                            EndIf
                        EndIf
                    Else
                        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " -> Tabela de preço do cliente não ativa." + CRLF
                        lRet := .F.
                    EndIf

                    If lRet
                        aAdd( aCab, { "ZL_CLIENTE", SA1->A1_COD } )
                        aAdd( aCab, { "ZL_LOJA",    SA1->A1_LOJA } )
                        aAdd( aCab, { "ZL_TPVEND",  "1" } )
                        aAdd( aCab, { "ZL_CONDPAD", SA1->A1_COND } )
                        aAdd( aCab, { "ZL_PEDCLI",  Right(AllTrim(cPedCli),15) } )
                        aAdd( aCab, { "ZL_DATENTR", dDtEntrega } )
                        aAdd( aCab, { "ZL_ORIGEM",  "NEOGRID" } )
                        aAdd( aCab, { "TABPRECO",   SA1->A1_TABELA } )
                    EndIf
                Else
                    cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " -> Cliente sem tabela de preço cadastrada." + CRLF
                EndIf
            Else
                cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " bloqueado para uso." + CRLF
            EndIf
        Else
            cProcessLog += "Ped Cliente " + cPedCli + " -> CNPJ do cliente não encontrado na base do Protheus." + CRLF
        EndIf
    ElseIf cTipoPed == "002" //-- Pedido Bonificação
        cProcessLog += "Ped Cliente " + cPedCli + " -> Pedido de Mercadorias Bonificadas. Não Integrado." + CRLF
    Else
        cProcessLog += "Ped Cliente " + cPedCli + " -> Pedido Especial, Consignação, Vendor, Compror ou Demonstração. Não Integrado." + CRLF
    EndIf

    RestArea( aAreaSA1 )

Return

/*/{Protheus.doc} PutPvItem

Itens Pedido de Venda

@author 	Marcos Natã Santos
@since 		17/12/2018
@version 	12.1.17
/*/
Static Function PutPvItem(cLinha,aItens,aItensChoc,aItensOvo,aItensPntt,cPedCli,cTbPreco)
	Local aItem       := {}
    Local cCodBarra   := AllTrim(SubStr(cLinha, 18, 14))
    Local aProdInfo   := GetProd(cCodBarra)
	Local cCodProd    := aProdInfo[1]
    Local cMsBlql     := aProdInfo[2]
    Local cProdGroup  := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProd, "B1_BASE3"))
    Local cBlqVenda   := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProd, "B1_BLQVEND"))
    Local cProdDesc   := Space(1) + AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProd, "B1_DESC"))
    Local cBlqTabPrc  := Posicione("DA1", 7, xFilial("DA1") + cTbPreco + cCodProd, "DA1_ATIVO")
    Local nPrecoProd  := Posicione("DA1", 7, xFilial("DA1") + cTbPreco + cCodProd, "DA1_PRCVEN")
    Local nPrecoItem  := 0
    Local nPrecoBruto := Val(SubStr(cLinha, 183, 13)) + Val('0.'+SubStr(cLinha, 196, 2))
    Local nPrecoLiq   := Val(SubStr(cLinha, 198, 13)) + Val('0.'+SubStr(cLinha, 211, 2))
    Local nQtdVen     := Val(SubStr(cLinha, 100, 13)) + Val('0.'+SubStr(cLinha, 113, 2))
    Local nQtdTroca   := Val(SubStr(cLinha, 130, 13)) + Val('0.'+SubStr(cLinha, 143, 2))
    Local nValorTot   := Val(SubStr(cLinha, 168, 13)) + Val('0.'+SubStr(cLinha, 181, 2))
    Local cItemSeq    := 0
    Local cItemSeqPC  := PadL(AllTrim(SubStr(cLinha, 3, 4)), 4, "0")
    Local nPercTolera := SuperGetMV("MV_XNGPRTL", .F., 0) //-- Percentual de tolerancia preço --//
    Local cGrpChoc    := GetMV("MV_XGRCHOC")
    Local cGrpOvo     := GetMV("MV_XGRPOVO")
    Local cGrpPntt    := GetMv("MV_XGRPNTT")

    //-------------------------------//
    //-- Avalia estado do produto  --//
    //-- Realiza corte de item     --//
    //-------------------------------//
    If Empty(cCodProd)
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC;
            +" -> Produto não encontrado. Item cortado do pedido. Cod Barra: " + cCodBarra + CRLF
        Return
    ElseIf cMsBlql == '1'
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC;
            +" -> Produto "+ cCodProd + " bloqueado para uso. Item cortado do pedido." + CRLF
        Return
    ElseIf cBlqVenda == '1'
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC;
            +" -> Produto "+ cCodProd + " bloqueado para Venda. Item cortado do pedido." + CRLF
        Return
    ElseIf cBlqTabPrc == '2'
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC;
        +" -> Produto "+ cCodProd + " inativo na tabela de preço. Item cortado do pedido." + CRLF
        Return
    ElseIf AvalCliCot(cPedCli, cCodCli, , cCodProd, nQtdVen) //-- Campanha Panettones --//
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC;
        +" -> Produto "+ cCodProd + " não atende a cota da campanha. Item cortado do pedido." + CRLF
        Return
    EndIf

    //-- Avalia preços no documento --//
    If nPrecoLiq > 0
        nPrecoItem := nPrecoLiq
    ElseIf nPrecoBruto > 0
        nPrecoItem := nPrecoBruto
    Else
        nPrecoItem := (nValorTot / nQtdVen)
    EndIf

    //-- Segrega itens do grupo chocolate, ovo pascoa e panettones --//
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

    //-- Avalia percentual de tolerancia para preço --//
    If nPercTolera > 0
        nPercTolera := (nPercTolera / 100)
        If nPrecoProd > nPrecoItem
            If (1 - (nPrecoItem/nPrecoProd)) <= nPercTolera
                nPrecoProd := nPrecoItem
            EndIf
        EndIf
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
            cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeq +" Produto "+ cCodProd + cProdDesc;
                + " -> Preço divergente: Tabela = R$" + cValToChar(nPrecoProd);
                + " NeoGrid = R$" + cValToChar(nPrecoItem) + CRLF
        EndIf
        If nQtdVen <= 0
            If nQtdTroca > 0
                cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeq +" Produto "+ cCodProd + cProdDesc;
                    + " -> Troca de Mercadoria. Verificar na NeoGrid." + CRLF
            EndIf
        EndIf
    Else
        cProcessLog += "Ped Cliente " + cPedCli + cMsgCli + " Item "+ cItemSeqPC +" Produto "+ cCodProd + cProdDesc;
                +" -> Preço não encontrado na tabela de preço. Cod Tab: " + cTbPreco + CRLF
    EndIf

Return

/*/{Protheus.doc} SetStatusDoc

Seta status do documento no webEdi para Transferido,
desta forma não sendo enviado novamente em chamadas posteriores.

@author 	Marcos Natã Santos
@since 		18/12/2018
@version 	12.1.17
/*/
Static Function SetStatusDoc(cDocNum,cCnpj,cClientIdentifier)
    Local lOk   := .F.
    Local cResp := ""

    Default cDocNum           := ""
    Default cCnpj             := ""
    Default cClientIdentifier := ""

    lOk := oWSDL:SetOperation( "setStatusDoc" )
    If !lOk
        cProcessLog += "Error setStatusDoc: DocNum "+ AllTrim(cDocNum);
            + " " + AllTrim(oWSDL:cError) + CRLF
    EndIf

    //---------------------------//
    //-- Parametros webservice --//
    //---------------------------//
    oWSDL:SetFirst("docNum", cDocNum)
    oWSDL:SetFirst("cnpj", cCnpj)
    oWSDL:SetFirst("clientIdentifier", cClientIdentifier)

    lOk := oWSDL:SendSoapMsg()
    If !lOk
        MsgStop( oWSDL:cError , "SendSoapMsg() ERROR")
        cProcessLog += "Error setStatusDoc: DocNum "+ AllTrim(cDocNum);
            + " " + AllTrim(oWSDL:cError) + CRLF
    EndIf

    cResp := oWSDL:GetSoapResponse()
    lOk   := oXML:Parse( cResp )
    If lOk == .F.
        cProcessLog += "Error setStatusDoc: DocNum "+ AllTrim(cDocNum) + " ";
             + AllTrim(oXML:Error()) + CRLF
    EndIf

    oXML:DOMChildNode() //-- Header --//
    oXML:DOMNextNode() //-- Body --//

    If oXML:cName == "Fault"
        cProcessLog += "Error setStatusDoc: DocNum "+ AllTrim(cDocNum) + " SOAP request fault" + CRLF
        Return
    EndIf

    oXML:DOMChildNode() //-- setStatusDocResponse --//
    oXML:DOMChildNode() //-- status --//

    // If oXML:cName == "status"
    //     cProcessLog += AllTrim(oXML:cText) + CRLF
    // EndIf

Return

/*/{Protheus.doc} GetProd

Busca produto pelo código de barras

@author 	Marcos Natã Santos
@since 		19/12/2018
@version 	12.1.17
/*/
Static Function GetProd(cCodBarra)
    Local cQry     := ""
    Local nQtdReg  := 0
    Local cProduct := ""
    Local cMsBlql  := ""

    cQry := "SELECT B1_COD, B1_MSBLQL FROM " + RetSqlName("SB1") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND (B1_CODBAR = '"+ cCodBarra +"' " + CRLF
    cQry += "OR B1_XBARCLI = '"+ cCodBarra +"') " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMPSB1") > 0
        TMPSB1->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMPSB1"

    TMPSB1->(dbGoTop())
    COUNT TO nQtdReg
    TMPSB1->(dbGoTop())

    cProduct := AllTrim(TMPSB1->B1_COD)
    cMsBlql  := AllTrim(TMPSB1->B1_MSBLQL)

    TMPSB1->(DbCloseArea())

Return {cProduct, cMsBlql}

/*/{Protheus.doc} IsImported

Verifica se o pedido já foi importado

@author 	Marcos Natã Santos
@since 		20/12/2018
@version 	12.1.17
/*/
Static Function IsImported(cDoc)
    Local cQry    := ""
    Local nQtdReg := 0
    Local lRet    := .F.

    Default cDoc := ""

    cQry := "SELECT ZL_NUM FROM " + RetSqlName("SZL") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZL_FILIAL = '"+ xFilial("SZL") +"' " + CRLF
    cQry += "AND TRIM(ZL_ORIGEM) = TRIM('NEOGRID') " + CRLF
    cQry += "AND TRIM(ZL_PEDCLI) = TRIM('"+ cDoc +"') " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMPSZL") > 0
        TMPSZL->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMPSZL"

    TMPSZL->(dbGoTop())
    COUNT TO nQtdReg
    
    If nQtdReg > 0
        lRet := .T.
    EndIf
    
    TMPSZL->(DbCloseArea())

Return lRet

/*/{Protheus.doc} SendLogWF

Envia workflow com logs de processamento

@author 	Marcos Natã Santos
@since 		20/12/2018
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
    Local cTo      := SuperGetMV("MV_XNGMAIL", .F., "customer@lineaalimentos.com.br")
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
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Falha ao setar o time out -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Setou o time out" )
    EndIf
    
    //Realiza a conexão SMTP
    xRet := oServer:SmtpConnect()
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Falha ao conectar -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Conectou com Sucesso" )
    EndIf

    // Autenticação no servidor SMTP
    xRet := oServer:SmtpAuth( cUser, cPass )
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Não conseguiu autenticar no servidor SMTP -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Autenticação realizada com Sucesso" )
    EndIf
    
    //Apos a conexão, cria o objeto da mensagem
    oMessage := TMailMessage():New()
    
    //Limpa o objeto
    oMessage:Clear()

    cSubject := "NEOGRID: LOGS INTEGRAÇÃO PEDIDOS " + DTOC(Date()) + " " + Time()
    cBody    := GetHtmlMsg(cLog)

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
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Erro ao enviar o e-mail -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: E-mail enviado com sucesso" )
    EndIf

    //Desconecta do servidor
    xRet := oServer:SmtpDisconnect()
    If xRet != 0
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Erro ao disconectar do servidor SMTP -> " + oServer:GetErrorString( xRet ) )
        Return .F.
    Else
        Conout( DTOC(Date()) + " " + Time() + " LA05A005: Disconectou do servidor SMTP" )
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
    cMsg += "<title>NeoGrid Logs</title> " + CRLF
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
    cMsg += "    <h1>NEOGRID: LOGS INTEGRAÇÃO PEDIDOS</h1> " + CRLF
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

/*/{Protheus.doc} AvalCliCot
Avalia cota da campanha para cliente
@type Static Function
@author Marcos Natã Santos
@since 30/08/2019
@version 1.0
@param cCodCli, char
@param cLoja, char
@param cProduto, char
@param nQtd, numeric
@return lRet, logic
/*/
Static Function AvalCliCot(cPedCli, cCodCli, cLoja, cProduto, nQtd)
    Local lRet := .F.
    Local nSaldoCota := 0

    Default cLoja := ""

    If AllTrim(cProduto) $ "410292861/410290261" //-- Campanha Panettones --//
        nSaldoCota := StaticCall(LA05A012, SaldoCota, cCodCli, , cProduto)

        If nQtd > nSaldoCota
            RecLock("ZCO", .T.)
                ZCO->ZCO_FILIAL := xFilial("ZCO")
                ZCO->ZCO_PEDCLI := cPedCli
                ZCO->ZCO_CLIENT := cCodCli
                ZCO->ZCO_LOJA := cLoja
                ZCO->ZCO_PROD := cProduto
                ZCO->ZCO_QTD := nQtd
                ZCO->ZCO_SALDO := nSaldoCota
            ZCO->( MsUnlock() )

            lRet := .T.
        EndIf
    EndIf
Return lRet
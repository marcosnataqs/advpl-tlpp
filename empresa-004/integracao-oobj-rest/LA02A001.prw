#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

#DEFINE MODEL_OPERATION_VIEW       1
#DEFINE MODEL_OPERATION_INSERT     3
#DEFINE MODEL_OPERATION_UPDATE     4
#DEFINE MODEL_OPERATION_DELETE     5
#DEFINE MODEL_OPERATION_ONLYUPDATE 6
#DEFINE MODEL_OPERATION_IMPR       8
#DEFINE MODEL_OPERATION_COPY       9

/*/{Protheus.doc} LA02A001

Browse para Monitor Oobj

@author 	Marcos Natã Santos
@since 		29/07/2019
@version 	1.0
@return 	oDlg
/*/
User Function LA02A001()
    Local oFWLayer := Nil
    Local oWin01 := Nil
    Local oWin02 := Nil
    Local oBrowse := Nil
    Local cTitulo := "Monitor Oobj"
    Local aSize := MsAdvSize(,.F.,400)

    Local bAction := {|| oBrowse:SetFilterDefault("ZB0_STATUS <> ' '") }
    Local bAction1 := {|| oBrowse:SetFilterDefault("ZB0_STATUS == 'X'") }
    Local bAction2 := {|| oBrowse:SetFilterDefault("ZB0_STATUS == 'C'") }
    Local bAction3 := {|| oBrowse:SetFilterDefault("ZB0_STATUS == 'R'") }
    Local bAction4 := {|| oBrowse:SetFilterDefault("ZB0_STATUS == 'D'") }

    Local bLDblClick := {|| VisualNFe(ZB0->ZB0_CHVNFE) }

    Static oDlgMain
    
    Private oTree := Nil

    DEFINE DIALOG oDlgMain TITLE cTitulo FROM aSize[7],0 to aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

        oFWLayer := FWLayer():New()

        //-----------------------------------------------
        // Inicializa componente passa a Dialog criada,
        // o segundo parametro é para criação de um botao
        // de fechar utilizado para Dlg sem cabeçalho.
        //-----------------------------------------------
        oFWLayer:Init( oDlgMain, .T. )

        //----------------------------------------
        // Efetua a montagem das colunas das telas
        //----------------------------------------
        oFWLayer:AddCollumn( "Col01", 20, .T. )
        oFWLayer:AddCollumn( "Col02", 80, .F. )

        //--------------------------
        // Habilita a opção de Split
        //--------------------------
        oFWLayer:SetColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| .T. } )

        //-------------------------------------------------------------------------------------
        // Cria windows passando, nome da coluna onde sera criada, nome da window
        // titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
        // se é redimensionada em caso de minimizar outras janelas e a ação no click do split
        //-------------------------------------------------------------------------------------
        oFWLayer:AddWindow( "Col01", "Win01",, 100, .F., .F., ,,)
        oFWLayer:AddWindow( "Col02", "Win02",, 100 , .F., .T., {|| .T. },,) //-- Tela Principal

        //---------------------------------------
        // Painel 1
        //---------------------------------------
        oWin01	:= oFWLayer:GetWinPanel('Col01','Win01')
        oTree	:= Xtree():New(00,00,oWin01:nClientHeight,oWin01:nClientWidth*.50, oWin01)

        oTree:AddTree("Docs Recebidos","folder5.png","folder6.png","0101",bAction,/*bRClick*/,/*bDblClick*/)
            oTree:AddTreeItem("XML Não Recebido (" + CountZB0("X") + ")","qmt_cond.png","0102",bAction1,/*bRClick*/,/*bDblClick*/)
            oTree:AddTreeItem("CNPJ Não Cadastrado (" + CountZB0("C") + ")","qmt_no.png","0103",bAction2,/*bRClick*/,/*bDblClick*/)
            oTree:AddTreeItem("Notas Recebimentos (" + CountZB0("R") + ")","qmt_ok.png","0104",bAction3,/*bRClick*/,/*bDblClick*/)
            oTree:AddTreeItem("Notas Devoluções (" + CountZB0("D") + ")","devolnf.png","0105",bAction4,/*bRClick*/,/*bDblClick*/)
        oTree:EndTree()

        //---------------------------------------
        // Painel 2
        //---------------------------------------
        oWin02	:= oFWLayer:GetWinPanel('Col02','Win02')
	
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("ZB0")
        oBrowse:AddLegend("Empty(ZB0_PROC)", "BR_VERDE", "Pendente")
        oBrowse:AddLegend("ZB0_PROC == 'S'", "BR_VERMELHO", "Processado")
        oBrowse:SetMenuDef("LA02A001")
        oBrowse:SetDoubleClick(bLDblClick)
        oBrowse:Activate(oWin02)
    
    ACTIVATE DIALOG oDlgMain CENTERED

Return oDlgMain

/*/{Protheus.doc} ModelDef

ModelDef da Monitor Oobj

@author 	Marcos Natã Santos
@since 		29/07/2019
@version 	1.0
@return 	oModel
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrZB0	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("LA2A1MOD")
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZB0 := FWFormStruct(1, "ZB0")
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZB0",/*cOwner*/,oStrZB0)

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZB0_FILIAL", "ZB0_NUMERO", "ZB0_SERIE"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_ZB0"):SetDescription(OemToAnsi("Monitor Oobj"))

Return oModel

/*/{Protheus.doc} ViewDef

ViewDef da Monitor Oobj

@author 	Marcos Natã Santos
@since 		29/07/2019
@version 	1.0
@return 	oView
/*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("LA02A001")
	Local oStrZB0	:= Nil
																																				
	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZB0 := FWFormStruct(2, "ZB0")
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZB0",oStrZB0,"M_ZB0")

    // Cria box horizontal
	oView:CreateHorizontalBox("V_BOX",100)
	
	// Relaciona o identificador (ID) da View com o box
	oView:SetOwnerView("V_ZB0","V_BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZB0",OemtoAnsi("Monitor Oobj"))
	
Return oView

/*/{Protheus.doc} MenuDef

MenuDef para Monitor Oobj

@author 	Marcos Natã Santos
@since 		29/07/2019
@version 	1.0
@return 	aRotina
/*/
Static Function MenuDef()
	Local aRotina as array
    Local aSub as array

    aRotina := {}
    aSub := {}

    aAdd(aSub, {"Sincronizar Oobj", "StaticCall(LA02A001, BuscaDocs)", 0, 3})
    aAdd(aSub, {"Eventos Fiscais", "StaticCall(LA02A001, VisualEvent, ZB0->ZB0_CHVNFE)", 0, 2})
    aAdd(aSub, {"Manifestar", "StaticCall(LA02A001, MftSefaz)", 0, 2})
    aAdd(aSub, {"Importar DFe", "StaticCall(LA02A001, DFeImport, ZB0->ZB0_CHVNFE)", 0, 2})
    
    aAdd(aRotina, {"Ações Monitor", aSub, 0, 3})

Return aRotina

/*/{Protheus.doc} BuscaDocs
Busca documentos recebidos Oobj
@type  Static Function
@author Marcos Natã Santos
@since 29/07/2019
@version 1.0
/*/
Static Function BuscaDocs
    Local lOk := .F.
    Local cTitle := "Sincronizar Documentos Fiscais"
    Local oBuscar
    Local oCancel
    Local oGet1
    Local dGet1 := Date()
    Local oGet2
    Local dGet2 := Date()
    Local oSay1
    Local oSay2
    Static oDlg

    Private oAPI := OobjAPI():New()

    DEFINE MSDIALOG oDlg TITLE cTitle STYLE 128 FROM 000, 000 TO 170, 480 COLORS 0, 16777215 PIXEL

        @ 025, 065 SAY oSay1 PROMPT "De Emissão:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 024, 105 MSGET oGet1 VAR dGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 045, 065 SAY oSay2 PROMPT "Até Emissão:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 044, 105 MSGET oGet2 VAR dGet2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 067, 195 BUTTON oCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
        @ 067, 155 BUTTON oBuscar PROMPT "Buscar" SIZE 037, 012 OF oDlg ACTION {|| lOk := .T., oDlg:End() } PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOk
        If !Empty(dGet1) .And. !Empty(dGet2)
            If dGet1 > dGet2
                MsgAlert("Data final deve ser maior que a data inicial. Por favor informe um período válido.", "BuscaDocs")
            Else
                Processa({|| Process1(dGet1, dGet2)}, "Buscando", "Buscando documentos recebidos Oobj", .F.)
            EndIf
        EndIf
    EndIf

    TreeRefresh() //-- Atualiza Tree --//
Return

/*/{Protheus.doc} Process1
Realiza busca e processamento dos dados
@type  Static Function
@author Marcos Natã Santos
@since 05/08/2019
@version 1.0
@param dGet1, date, Data inicial
@param dGet2, date, Data final
/*/
Static Function Process1(dGet1, dGet2)
    Local aReceivedDocs := {}

    aReceivedDocs := oAPI:GetDocsByPeriod(dGet1, dGet2)
    Processa({|| GravaDocs(aReceivedDocs)}, "Sincronizando", "Processando documentos XML/Sefaz", .F.)
Return

/*/{Protheus.doc} GravaDocs
Grava documento na tabela ZB0
@type  Static Function
@author Marcos Natã Santos
@since 29/07/2019
@version 1.0
/*/
Static Function GravaDocs(aReceivedDocs)
    Local nX := 0
    Local oDFe := Nil

    Local dData := Space(8)
    Local cHora := Space(8)
    Local cEmitente := ""
    Local cNomeEmit := ""
    Local nValor := 0
    Local cChvNfe := ""
    Local cStatus := "X"

    Default aReceivedDocs := {}

    ProcRegua(Len(aReceivedDocs))
    For nX := 1 To Len(aReceivedDocs)
        IncProc("Documento " + cValToChar(nX) + " de " + cValToChar(Len(aReceivedDocs)))
        
        If AllTrim(aReceivedDocs[nX]:sitDF) == "AUTORIZADA"
            dData := STOD(StrTran(SubStr(aReceivedDocs[nX]:dhEmi, 1, 10), "-"))
            cHora := SubStr(aReceivedDocs[nX]:dhEmi, 12, 8)
            cEmitente := AllTrim(aReceivedDocs[nX]:DocEmit)
            cNomeEmit := AllTrim(aReceivedDocs[nX]:NomeEmit)
            nValor := aReceivedDocs[nX]:vDF
            cChvNfe := aReceivedDocs[nX]:chDFe
            cStatus := AvaliaStts( oAPI:GetDFeByKey(cChvNfe) )

            GrvZB0(dData, cHora, cEmitente, cNomeEmit, nValor, cChvNfe, cStatus)
        EndIf
    Next nX
Return

/*/{Protheus.doc} GrvZB0
Grava dados na tabela ZB0
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param dData, date
@param cHora, char
@param cEmitente, char
@param cNomeEmit, char
@param nValor, numeric
@param cChvNfe, char
@param cStatus, char
/*/
Static Function GrvZB0(dData, cHora, cEmitente, cNomeEmit, nValor, cChvNfe, cStatus)
    Local aAreaZB0 := ZB0->( GetArea() )
    Local aAreaSF1 := SF1->( GetArea() )
    Local cSerie := ""
    Local cNumero := ""
    Local cCodForn := ""
    Local cLojaForn := ""
    Local lExiste := .F.
    Local lDocEnt := .F.

    cSerie := U_zTiraZeros(SubStr(cChvNfe, 23, 3))
    cSerie := IIF(Empty(cSerie), "0", cSerie)
    cNumero := U_zTiraZeros(SubStr(cChvNfe, 26, 9))
    cCodForn := Posicione("SA2", 3, xFilial("SA2") + cEmitente, "A2_COD")
    cLojaForn := Posicione("SA2", 3, xFilial("SA2") + cEmitente, "A2_LOJA")

    SF1->( dbSetOrder(1) )
    lDocEnt := SF1->( MsSeek(xFilial("SF1") + PadL(cNumero, 9, "0") + PadR(cSerie, 3) + cCodForn + cLojaForn) )

    ZB0->( dbSetOrder(2) )
    lExiste := ZB0->( MsSeek(xFilial("ZB0") + cChvNfe) )
        
    If !lExiste .Or. (lExiste .And. ZB0->ZB0_STATUS <> cStatus)
        RecLock("ZB0", !lExiste)
            ZB0->ZB0_FILIAL := xFilial("ZB0")
            ZB0->ZB0_DATA := dData
            ZB0->ZB0_HORA := cHora
            ZB0->ZB0_SERIE := cSerie
            ZB0->ZB0_NUMERO := cNumero
            ZB0->ZB0_EMITEN := cEmitente
            ZB0->ZB0_NEMITE := cNomeEmit
            ZB0->ZB0_VALOR := nValor
            ZB0->ZB0_CHVNFE := cChvNfe
            ZB0->ZB0_STATUS := cStatus
            If lDocEnt
                ZB0->ZB0_PROC := "S"
            EndIf
        ZB0->( MsUnlock() )
    ElseIf lDocEnt
        RecLock("ZB0", .F.)
        ZB0->ZB0_PROC := "S"
        ZB0->( MsUnlock() )
    EndIf

    RestArea(aAreaZB0)
    RestArea(aAreaSF1)
Return

/*/{Protheus.doc} AvaliaStts
Avalia status do documento fiscal
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param oDFe, object, Documento Fiscal Oobj
@return cStatus, char, Status do documento fiscal
/*/
Static Function AvaliaStts(oDFe)
    Local cStatus := "X"

    If oDFe == Nil
        cStatus := "X" //-- Sem XML na Oobj --//
    ElseIf DevolucNFe(oDFe:Conteudo)
        cStatus := "D" //-- Nota de Devolução --//
    ElseIf CNPJNaoCadastr(oDFe:Conteudo)
        cStatus := "C" //-- CNPJ do fornecedor não cadastrado --//
    Else
        cStatus := "R" //-- Nota Fiscal de Recebimento --//
    EndIf
Return cStatus

/*/{Protheus.doc} CNPJNaoCadastr
Verifica cadastro do fornecedor
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param oXML, object, XML da Nota Fiscal
@return lOk, logic
/*/
Static Function CNPJNaoCadastr(oXML)
    Local lOk := .F.
    Local aAreaSA2 := SA2->( GetArea() )
    Local cCnpj := ""

    If ValType(oXML) == "O"
        cCnpj := oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT

        //-- Verifica cadastro do fornecedor --//
        SA2->( dbSetOrder(3) )
        If .Not. SA2->( dbSeek(xFilial("SA2") + cCnpj) )
            lOk := .T.
        EndIf
    EndIf

    RestArea(aAreaSA2)
Return lOk

/*/{Protheus.doc} DevolucNFe
Verifica se é uma nota de devolução
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param oXML, object, XML da Nota Fiscal
@return lOk, logic
/*/
Static Function DevolucNFe(oXML)
    Local lOk := .F.
    Local cFinNFe := ""

    If ValType(oXML) == "O"
        cFinNFe := oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_FINNFE:TEXT
        
        //-- 1 = NF-e normal.
        //-- 2 = NF-e complementar.
        //-- 3 = NF-e de ajuste.
        //-- 4 = Devolução de mercadoria.
        If cFinNFe == "4"
            lOk := .T.
        EndIf
    EndIf
Return lOk

/*/{Protheus.doc} CountZB0
Contador de documentos por status
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param cStatus, char, Status do Documento
@return cQtdRegs, char, Quantidade de Docs
/*/
Static Function CountZB0(cStatus)
    Local cQtdRegs := "0"
    Local cQry := ""

    cQry := "SELECT COUNT(ZB0_CHVNFE) QTDREGS " + CRLF
    cQry += "FROM " + RetSqlName("ZB0") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZB0_FILIAL = '"+ xFilial("ZB0") +"' " + CRLF
    cQry += "AND ZB0_STATUS = '"+ cStatus +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("COUNTZB0") > 0
        COUNTZB0->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "COUNTZB0"
    
    cQtdRegs := cValToChar(COUNTZB0->QTDREGS)

    COUNTZB0->(DbCloseArea())
Return cQtdRegs

/*/{Protheus.doc} TreeRefresh
Atualiza a aba tree principal
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
/*/
Static Function TreeRefresh()
    oTree:ChangePrompt("XML Não Recebido (" + CountZB0("X") + ")", "0102")
    oTree:ChangePrompt("CNPJ Não Cadastrado (" + CountZB0("C") + ")", "0103")
    oTree:ChangePrompt("Notas Recebimentos (" + CountZB0("R") + ")", "0104")
    oTree:ChangePrompt("Notas Devoluções (" + CountZB0("D") + ")", "0105")
Return

/*/{Protheus.doc} VisualNFe
Detalhes da Nota Fiscal
@type  Static Function
@author Marcos Natã Santos
@since 06/08/2019
@version 1.0
@param cChvNfe, char, Chave Nota Fiscal
/*/
Static Function VisualNFe(cChvNfe)
    Local lXmlIndisp := .T.
    Local oAPI := OobjAPI():New()
    Local oDFe := oAPI:GetDFeByKey(cChvNfe)

    Local oFolder1
    Local oMultiGe1
    Local cMultiGe1 := ""
    Local oSay1
    Local oSay10
    Local oSay11
    Local oSay12
    Local oSay13
    Local oSay14
    Local oSay15
    Local oSay16
    Local oSay17
    Local oSay18
    Local oSay19
    Local oSay2
    Local oSay20
    Local oSay21
    Local oSay22
    Local oSay23
    Local oSay24
    Local oSay25
    Local oSay26
    Local oSay3
    Local oSay4
    Local oSay5
    Local oSay6
    Local oSay7
    Local oSay8
    Local oSay9

    Local cSerie := ""
    Local cNumero := ""
    Local cDataHoraEmiss := ""
    Local cValorTotal := ""
    Local cCNPJ := ""
    Local cRzSocial := ""
    Local cIE := "" 
    Local cUF := ""
    Local cTOp := ""
    Local cNaturez := ""
    Local aNFItens := {}
    Local cNvStts := ""
    
    Static oDlg

    If oDFe <> Nil
        If ValType(oDFe:Conteudo) == "O"
            cSerie := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
            cNumero := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
            cDataHoraEmiss := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
            cDataHoraEmiss := SubStr(cDataHoraEmiss, 1, 10) + " " + SubStr(cDataHoraEmiss, 12, 8)
            cValorTotal := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT
            cValorTotal := "R$ " + AllTrim(TRANSFORM(Val(cValorTotal), PesqPict("SD1", "D1_TOTAL")))
            cCNPJ := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
            cCNPJ := AllTrim(TRANSFORM(cCNPJ, PesqPict("SA1", "A1_CGC")))
            cRzSocial := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT
            cIE := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT
            cUF := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
            cTOp := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_TPNF:TEXT
            cNaturez := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
            
            If XmlChildEx(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE, "_INFADIC") <> Nil
                If XmlChildEx(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_INFADIC, "_INFCPL") <> Nil
                    cMultiGe1 := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT
                EndIf
            EndIf
            
            aNFItens := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_DET

            lXmlIndisp := .F.
        EndIf
    EndIf

    If lXmlIndisp
        MsgAlert("XML não disponível. Por favor aguarde a disponibilidade do documento.", "XmlIndisp")
        Return
    Else
        //-- Reavalia status do documento --//
        If ZB0->ZB0_STATUS $ "X/C"
            cNvStts := AvaliaStts(oDFe)

            RecLock("ZB0", .F.)
            ZB0->ZB0_STATUS := cNvStts
            ZB0->(MsUnlock())

            TreeRefresh()
        EndIf
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Detalhes NF-e" FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL

        @ 002, 002 FOLDER oFolder1 SIZE 345, 245 OF oDlg ITEMS "NF-e","Produtos e Serviços","Informações Adicionais" COLORS 0, 16777215 PIXEL
        @ 005, 005 SAY oSay1 PROMPT "Dados da NF-e" SIZE 040, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 015, 005 SAY oSay2 PROMPT "Série" SIZE 025, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 022, 005 SAY oSay3 PROMPT cSerie SIZE 010, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 015, 030 SAY oSay4 PROMPT "Número" SIZE 025, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 022, 030 SAY oSay5 PROMPT cNumero SIZE 035, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 015, 070 SAY oSay6 PROMPT "Data/Hora Emissão" SIZE 050, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 022, 070 SAY oSay7 PROMPT cDataHoraEmiss SIZE 060, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 015, 140 SAY oSay8 PROMPT "Valor Total " SIZE 030, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 022, 140 SAY oSay9 PROMPT cValorTotal SIZE 055, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 040, 005 SAY oSay10 PROMPT "Emitente" SIZE 025, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 050, 005 SAY oSay11 PROMPT "CNPJ" SIZE 020, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 057, 005 SAY oSay12 PROMPT cCNPJ SIZE 055, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 050, 075 SAY oSay13 PROMPT "Nome / Razão Social " SIZE 060, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 057, 075 SAY oSay14 PROMPT cRzSocial SIZE 105, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 050, 190 SAY oSay15 PROMPT "Inscrição Estadual " SIZE 055, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 057, 190 SAY oSay16 PROMPT cIE SIZE 050, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 050, 265 SAY oSay17 PROMPT "UF" SIZE 020, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 057, 265 SAY oSay18 PROMPT cUF SIZE 020, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 080, 005 SAY oSay19 PROMPT "Emissão" SIZE 025, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 090, 005 SAY oSay20 PROMPT "Tipo de Operação" SIZE 050, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 097, 005 SAY oSay21 PROMPT cTOp SIZE 030, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 090, 075 SAY oSay22 PROMPT "Natureza da Operação" SIZE 025, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 097, 075 SAY oSay23 PROMPT cNaturez SIZE 150, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 125, 005 SAY oSay25 PROMPT "Chave de Acesso" SIZE 050, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 132, 005 SAY oSay26 PROMPT cChvNfe SIZE 155, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        fMSNewGe1(@oFolder1, aNFItens)
        @ 007, 005 SAY oSay24 PROMPT "Informações Complementares de Interesse do Contribuinte" SIZE 160, 007 OF oFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
        @ 020, 005 GET oMultiGe1 VAR cMultiGe1 OF oFolder1:aDialogs[3] MULTILINE SIZE 332, 100 COLORS 0, 16777215 READONLY HSCROLL PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} fMSNewGe1
Itens da Nota Fiscal
@type  Static Function
@author Marcos Natã Santos
@since 08/08/2019
@version 1.0
@param oFolder1, object
@param aNFItens, array, Itens da Nota Fiscal
/*/
Static Function fMSNewGe1(oFolder1, aNFItens)
    Local nX
    Local aHeaderEx := {}
    Local aColsEx := {}
    Local aFieldFill := {}
    Local aFields := {"D1_ITEM","D1_COD","D1_XDESCRI","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL"}
    Local aAlterFields := {}
    Static oMSNewGe1

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    For nX := 1 to Len(aFields)
        If SX3->(DbSeek(aFields[nX]))
            Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                    SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
        Endif
    Next nX

    If ValType(aNFItens) == "O"
        Aadd(aFieldFill, PadL(aNFItens:_NITEM:TEXT, 4, "0"))
        Aadd(aFieldFill, aNFItens:_PROD:_CPROD:TEXT)
        Aadd(aFieldFill, aNFItens:_PROD:_XPROD:TEXT)
        Aadd(aFieldFill, aNFItens:_PROD:_UTRIB:TEXT)
        Aadd(aFieldFill, Val(aNFItens:_PROD:_QCOM:TEXT))
        Aadd(aFieldFill, Val(aNFItens:_PROD:_VUNCOM:TEXT))
        Aadd(aFieldFill, Val(aNFItens:_PROD:_VPROD:TEXT))
        Aadd(aFieldFill, .F.)
        Aadd(aColsEx, aFieldFill)
        aFieldFill := {}
    ElseIf ValType(aNFItens) == "A"
        For nX := 1 To Len(aNFItens)
            Aadd(aFieldFill, PadL(aNFItens[nX]:_NITEM:TEXT, 4, "0"))
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_CPROD:TEXT)
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_XPROD:TEXT)
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_UTRIB:TEXT)
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_QCOM:TEXT))
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_VUNCOM:TEXT))
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_VPROD:TEXT))
            Aadd(aFieldFill, .F.)
            Aadd(aColsEx, aFieldFill)
            aFieldFill := {}
        Next nX
    EndIf

    oMSNewGe1 := MsNewGetDados():New( 000, 000, 232, 342, , "AllwaysTrue", "AllwaysTrue",, aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder1:aDialogs[2], aHeaderEx, aColsEx)

Return

/*/{Protheus.doc} VisualEvent
Eventos Fiscais
@type  Static Function
@author Marcos Natã Santos
@since 14/08/2019
@version 1.0
@param cChvNfe, char, Chave Nota Fiscal
/*/
Static Function VisualEvent(cChvNfe)
    Local cTitle := "Eventos Fiscais"
    Local oAPI := OobjAPI():New()
    Local aEvents := oAPI:GetEventsByKey(cChvNfe)

    Static oDlg

    DEFINE MSDIALOG oDlg TITLE cTitle FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

        fMSNewGe2(aEvents)

    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} fMSNewGe2
Lista Eventos Fiscais
@type  Static Function
@author Marcos Natã Santos
@since 14/08/2019
@version 1.0
@param aEvents, array, Lista de Eventos
/*/
Static Function fMSNewGe2(aEvents)
    Local nX
    Local aHeaderEx := {}
    Local aColsEx := {}
    Local aFieldFill := {}
    Local aFields := {"ZO_DATA","ZO_HORA","B1_COD","B1_DESC"}
    Local aAlterFields := {}
    Static oMSNewGe2

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    For nX := 1 to Len(aFields)
        If SX3->(DbSeek(aFields[nX]))
            If nX = 3 //-- Cod Evento --//
                Aadd(aHeaderEx, {"Cod Evento",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                                SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
            ElseIf nX = 4 //-- Desc Evento --//
                Aadd(aHeaderEx, {"Evento",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                    SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
            Else
                Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                    SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
            EndIf
        EndIf
    Next nX

    If ValType(aEvents) == "A"
        For nX := 1 to Len(aEvents)
            Aadd(aFieldFill, STOD(StrTran(SubStr(aEvents[nX]:DataEvento, 1, 10), "-")))
            Aadd(aFieldFill, SubStr(aEvents[nX]:DataEvento, 12, 8))
            Aadd(aFieldFill, AllTrim(Str(aEvents[nX]:CodigoEvento)))
            Aadd(aFieldFill, AllTrim(aEvents[nX]:DescricaoEvento))
            Aadd(aFieldFill, .F.)
            Aadd(aColsEx, aFieldFill)
        Next nX
    Else
        Aadd(aFieldFill, STOD(Space(8)))
        Aadd(aFieldFill, Space(8))
        Aadd(aFieldFill, Space(10))
        Aadd(aFieldFill, "SEM EVENTOS REGISTRADOS")
        Aadd(aFieldFill, .F.)
        Aadd(aColsEx, aFieldFill)
    EndIf

    oMSNewGe2 := MsNewGetDados():New( 000, 000, 150, 253, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
Return

/*/{Protheus.doc} MftSefaz
Manifestação Destinatário
@type Static Function
@author Marcos Natã
@since 14/08/2019
@version 1.0
/*/
Static Function MftSefaz()
    Local cTitle := "Manifestação"
    Local oCancel
    Local oComboBo1
    Local cComboBo1 := "Ciência da Operação"
    Local aComboBo1 := {"Ciência da Operação","Confirmação da Operação","Desconhecimento da Operação","Operação não Realizada"}
    Local oGroup1
    Local oManifest
    Local oSay1
    Local oSay2

    Static oDlg

    DEFINE MSDIALOG oDlg TITLE cTitle FROM 000, 000 TO 200, 400 COLORS 0, 16777215 PIXEL

        @ 002, 002 GROUP oGroup1 TO 032, 200 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
        @ 015, 010 SAY oSay1 PROMPT "Realize a manifestação da nota fiscal." SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 060, 032 SAY oSay2 PROMPT "Manifestação:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 059, 070 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS aComboBo1 SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 082, 157 BUTTON oCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
        @ 082, 117 BUTTON oManifest PROMPT "Manifestar" SIZE 037, 012 OF oDlg ACTION {|| MftEmit(ZB0->ZB0_CHVNFE, Str(Year(ZB0->ZB0_DATA)), cComboBo1), oDlg:End() } PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} MftEmit
Emitir manifestação Destinatário
@type Static Function
@author Marcos Natã
@since 19/08/2019
@version 1.0
@param cChvNfe, char, Chave da NFe
@param cAno, char, Ano da NFe
@param cDescEvent, char, Descricao do Evento
/*/
Static Function MftEmit(cChvNfe, cAno, cDescEvent)
    Local lRet := .F.
    Local oAPI := OobjAPI():New()
    Local cTpEvent := ""
    Local cStatus := ZB0->ZB0_STATUS

    Do Case
        Case cDescEvent == "Ciência da Operação"
            cTpEvent := "210210"
        Case cDescEvent == "Confirmação da Operação"
            cTpEvent := "210200"
        Case cDescEvent == "Desconhecimento da Operação"
            cTpEvent := "210220"
        Case cDescEvent == "Operação não Realizada"
            cTpEvent := "210240"
    EndCase

    //-- Evento já transmitido | XML baixado --//
    If cStatus <> "X" .And. cTpEvent == "210210"
        MsgAlert("Ciência da Operação já homologado na Sefaz.", "MftEmit")
        Return
    EndIf
    
    lRet := oAPI:EmitDFeEvent(cChvNfe, AllTrim(cAno), cTpEvent, FwCutOff(cDescEvent, .T.))

    If lRet
        MsgInfo("Evento transmitido com sucesso!", "MftEmit")
    Else
        MsgInfo("Evento não transmitido! Por favor verificar!", "MftEmit")
    EndIf
Return

/*/{Protheus.doc} DFeImport
Realiza importação de nota fiscal Oobj
@type Static Function
@author Marcos Natã Santos
@since 22/08/2019
@version 1.0
@param cChvNfe, char, Chave da NFe
/*/
Static Function DFeImport(cChvNfe)
    Local lXmlIndisp := .T.
    Local oAPI := OobjAPI():New()
    Local oDFe := oAPI:GetDFeByKey(cChvNfe)
    Local lOk := .T.

    Local cTitulo := "Importar Nota Fiscal"
    Local aSize := MsAdvSize(,.F.,)
    Local aButtons := {}

    Local oGet1
    Local cGet1 := Space(TamSX3("D1_DOC")[1])
    Local oGet2
    Local cGet2 := Space(TamSX3("D1_SERIE")[1])
    Local oGet3
    Local nGet3 := 0
    Local oGet4
    Local oGet5
    Local oGet6
    Local cGet6 := Space(TamSX3("A2_NOME")[1])
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Local oSay5
    Local oSay6

    Local cCNPJ := ""
    Local aNFItens := {}

    Private cGet4 := Space(TamSX3("D1_FORNECE")[1])
    Private cGet5 := Space(TamSX3("D1_LOJA")[1])

    Static oDlgImpt

    Aadd( aButtons, {"Item Pedido", {|| ItemPed()}, "Item Pedido", "Item Pedido" , {|| .T.}} )

    //------------------------------------------------//
    //-- Verifica processamento do documento fiscal --//
    //------------------------------------------------//
    If ZB0->ZB0_PROC == "S"
        MsgInfo("Documento fiscal já foi processado.", "DFeImport")
        Return
    EndIf

    If ZB0->ZB0_STATUS <> "R"
        MsgAlert("Documento fiscal não pode ser processado.", "DFeImport")
        Return
    EndIf

    If .Not. MsgYesNo("Deseja processar importação da nota fiscal?", "Importação Nota Fiscal")
        Return lOk
    EndIf

    If oDFe <> Nil
        If ValType(oDFe:Conteudo) == "O"
            cCNPJ := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT

            cGet1 := PadL(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT, TamSX3("D1_DOC")[1], "0")
            cGet2 := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
            nGet3 := Val(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)
            cGet4 := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_COD")
            cGet5 := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_LOJA")
            cGet6 := AllTrim(Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_NOME"))

            aNFItens := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_DET

            lXmlIndisp := .F.
        EndIf
    EndIf

    If lXmlIndisp
        MsgAlert("XML não disponível. Por favor aguarde a disponibilidade do documento.", "XmlIndisp")
        Return
    EndIf

    //-- Importação do DFe Automática --//
    lOk := ImportNFAuto(oDFe)

    If !lOk

        DEFINE DIALOG oDlgImpt TITLE cTitulo FROM aSize[7],0 to aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

            @ 035, 015 SAY oSay1 PROMPT "Doc" SIZE 025, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 045, 015 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgImpt COLORS 0, 16777215 READONLY PIXEL
            @ 035, 085 SAY oSay2 PROMPT "Serie" SIZE 025, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 045, 085 MSGET oGet2 VAR cGet2 SIZE 030, 010 OF oDlgImpt COLORS 0, 16777215 READONLY PIXEL
            @ 035, 122 SAY oSay3 PROMPT "Valor" SIZE 025, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 045, 122 MSGET oGet3 VAR nGet3 SIZE 060, 010 OF oDlgImpt PICTURE PesqPict("SD1", "D1_TOTAL") COLORS 0, 16777215 READONLY PIXEL
            @ 065, 015 SAY oSay4 PROMPT "Fornecedor" SIZE 030, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 075, 015 MSGET oGet4 VAR cGet4 SIZE 060, 010 OF oDlgImpt COLORS 0, 16777215 READONLY PIXEL
            @ 065, 085 SAY oSay5 PROMPT "Loja" SIZE 025, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 075, 085 MSGET oGet5 VAR cGet5 SIZE 030, 010 OF oDlgImpt COLORS 0, 16777215 READONLY PIXEL
            @ 065, 122 SAY oSay6 PROMPT "Razão Social" SIZE 040, 007 OF oDlgImpt COLORS 0, 16777215 PIXEL
            @ 075, 122 MSGET oGet6 VAR cGet6 SIZE 150, 010 OF oDlgImpt COLORS 0, 16777215 READONLY PIXEL
            fMSNewGe3(aNFItens)

        ACTIVATE DIALOG oDlgImpt CENTERED ON INIT EnchoiceBar(oDlgImpt, {|| ImportNfPed(oDFe, cGet4, cGet5) }, {|| oDlgImpt:End() },, @aButtons)

    EndIf

Return

/*/{Protheus.doc} fMSNewGe3
Itens para importação da Nota Fiscal
@type Static Function
@author Marcos Natã Santos
@since 22/08/2019
@version 1.0
@param aNFItens, array, Itens da NFe
/*/
Static Function fMSNewGe3(aNFItens)
    Local nX
    Local aHeaderEx := {}
    Local aColsEx := {}
    Local aFieldFill := {}
    Local aFields := {"D1_ITEM","D1_COD","D1_XDESCRI","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_PEDIDO","D1_ITEMPC"}
    Local aAlterFields := {}
    Static oMSNewGe3

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    For nX := 1 to Len(aFields)
        If SX3->(DbSeek(aFields[nX]))
            Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
        EndIf
    Next nX

    If ValType(aNFItens) == "O"
        Aadd(aFieldFill, PadL(aNFItens:_NITEM:TEXT, 4, "0"))
        Aadd(aFieldFill, aNFItens:_PROD:_CPROD:TEXT)
        Aadd(aFieldFill, aNFItens:_PROD:_XPROD:TEXT)
        Aadd(aFieldFill, aNFItens:_PROD:_UTRIB:TEXT)
        Aadd(aFieldFill, Val(aNFItens:_PROD:_QCOM:TEXT))
        Aadd(aFieldFill, Val(aNFItens:_PROD:_VUNCOM:TEXT))
        Aadd(aFieldFill, Val(aNFItens:_PROD:_VPROD:TEXT))
        Aadd(aFieldFill, Space(TamSX3("D1_PEDIDO")[1]))
        Aadd(aFieldFill, Space(TamSX3("D1_ITEMPC")[1]))
        Aadd(aFieldFill, .F.)
        Aadd(aColsEx, aFieldFill)
        aFieldFill := {}
    ElseIf ValType(aNFItens) == "A"
        For nX := 1 To Len(aNFItens)
            Aadd(aFieldFill, PadL(aNFItens[nX]:_NITEM:TEXT, 4, "0"))
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_CPROD:TEXT)
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_XPROD:TEXT)
            Aadd(aFieldFill, aNFItens[nX]:_PROD:_UTRIB:TEXT)
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_QCOM:TEXT))
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_VUNCOM:TEXT))
            Aadd(aFieldFill, Val(aNFItens[nX]:_PROD:_VPROD:TEXT))
            Aadd(aFieldFill, Space(TamSX3("D1_PEDIDO")[1]))
            Aadd(aFieldFill, Space(TamSX3("D1_ITEMPC")[1]))
            Aadd(aFieldFill, .F.)
            Aadd(aColsEx, aFieldFill)
            aFieldFill := {}
        Next nX
    EndIf

    oMSNewGe3 := MsNewGetDados():New( 100, 000, 300, 637, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
Return

/*/{Protheus.doc} ImportNFAuto
Importação Automática da Nota Fiscal
@type Static Function
@author Marcos Natã Santos
@since 02/09/2019
@version 1.0
@param oDFe, object, Documento Fiscal
@return lOk, logic
/*/
Static Function ImportNFAuto(oDFe)
    Local lOk := .T.
    Local nX := 0
    Local cCNPJ := ""
    Local cCodForn := ""
    Local cLojaForn := ""
    Local aNFItens := Nil
    Local cPedComp := ""
    Local cItemPC := ""
    Local cCodProdForn := ""

    cCNPJ := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
    cCodForn := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_COD")
    cLojaForn := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_LOJA")
    aNFItens := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_DET

    //------------------------------------------//
    //-- Verifica se existe a tag XPED no XML --//
    //-- Amarração Produto x Fornecedor       --//
    //------------------------------------------//
    If ValType(aNFItens) == "O"
        If XmlChildEx(aNFItens:_PROD, "_XPED") == Nil
            lOk := .F.
            Return lOk
        Else
            cPedComp := AvalNumPC(aNFItens:_PROD:_XPED:TEXT)
            cItemPC := AvalItemPC(aNFItens:_PROD:_XPED:TEXT)
            cCodProdForn := AllTrim(aNFItens:_PROD:_CPROD:TEXT)
            lOk := ProdxForn(cCodForn, cLojaForn, cPedComp, cItemPC, cCodProdForn)

            If !lOk
                Return lOk
            EndIf
        EndIf
    ElseIf ValType(aNFItens) == "A"
        For nX := 1 To Len(aNFItens)
            If XmlChildEx(aNFItens[nX]:_PROD, "_XPED") == Nil
                lOk := .F.
                Return lOk
            Else
                cPedComp := AvalNumPC(aNFItens[nX]:_PROD:_XPED:TEXT)
                cItemPC := AvalItemPC(aNFItens[nX]:_PROD:_XPED:TEXT)
                cCodProdForn := AllTrim(aNFItens[nX]:_PROD:_CPROD:TEXT)
                lOk := ProdxForn(cCodForn, cLojaForn, cPedComp, cItemPC, cCodProdForn)

                If !lOk
                    Return lOk
                EndIf
            EndIf

            cPedComp := ""
            cItemPC := ""
        Next nX
    EndIf

    If lOk
        Processa({|| IncPreDoc(oDFe)}, "Importando Nota Fiscal", "Processando documento...", .F.)
    EndIf

Return lOk

/*/{Protheus.doc} ProdxForn
Cadastro Produto x Fornecedor
@type Static Function
@author Marcos Natã Santos
@since 02/09/2019
@version 1.0
@param cCodForn, char, Código Fornecedor
@param cLojaForn, char, Loja Fornecedor
@param cPedComp, char, Pedido Compra
@param cItemPC, char, Item pedido
@param cCodProdForn, char, Código Produto Fornecedor
@return lOk, logic
/*/
Static Function ProdxForn(cCodForn, cLojaForn, cPedComp, cItemPC, cCodProdForn)
    Local aAreaSA5 := SA5->( GetArea() )
    Local lOk := .T.
    Local cProduto := Posicione("SC7", 1, xFilial("SC7") + cPedComp + cItemPC, "C7_PRODUTO")

    If !Empty(cProduto)
        SA5->( dbSetOrder(1) )
        If SA5->( dbSeek(xFilial("SA5") + cCodForn + cLojaForn + cProduto) )
            RecLock("SA5", .F.)
            SA5->A5_CODPRF := cCodProdForn
            SA5->( MsUnlock() )
        Else
            lOk := .F.
        EndIf
    Else
        lOk := .F.
    EndIf

    RestArea(aAreaSA5)
Return lOk

/*/{Protheus.doc} IncPreDoc
Inclui Pre-Nota de Entrada
@type Static Function
@author Marcos Natã Santos
@since 02/09/2019
@version 1.0
@param oDFe, object, Documento Fiscal
@param lManual, logic, Inclusão tela manual
/*/
Static Function IncPreDoc(oDFe, lManual)
    Local aNFItens := {}
    Local nOpc := 3
    Local aCabec := {}
    Local aItens := {}
    Local aLinha := {}
    Local lSimula := .F. // .T. para habilitar simulação / .F. para desabilitar a simulação
    Local nTelaAuto := 1 // 0 - Não mostra tela, 1 - Mostra tela e valida tudo, 2 - Mostra tela e valida somente cabeçalho
    Local nX := 0
    Local aAreaSF1 := SF1->( GetArea() )

    Local cCNPJ := ""
    Local cDoc := ""
    Local cSerie := ""
    Local dEmissao := Date()
    Local cCodForn := ""
    Local cLojaForn := ""
    Local cEspecie := "NFE"
    Local cCondPag := ""
    Local cChvNfe := ""
    Local cPedComp := ""
    Local cItemPC := ""
    Local cCodProdForn := ""
    Local cProdSB1 := ""
    Local cB1_SEGUM := ""

    Private lMsErroAuto := .F.

    Default lManual := .F.

    cCNPJ := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
    cDoc := PadL(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT, TamSX3("D1_DOC")[1], "0")
    cSerie := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
    dEmissao := STOD(StrTran(SubStr(oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT, 1, 10), "-"))
    cCodForn := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_COD")
    cLojaForn := Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_LOJA")
    cEspecie := "NFE"
    cCondPag := AllTrim(Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_COND"))
    cChvNfe := oDFe:ChaveAcesso
    aNFItens := oDFe:Conteudo:_NFEPROC:_NFE:_INFNFE:_DET

    //-- Cabeçalho Nota Fiscal --//
    aAdd(aCabec,{'F1_TIPO','N',NIL})
    aAdd(aCabec,{'F1_FORMUL','N',NIL})
    aAdd(aCabec,{'F1_DOC',cDoc,NIL})
    aAdd(aCabec,{"F1_SERIE",cSerie,NIL})
    aAdd(aCabec,{"F1_EMISSAO",dEmissao,NIL})
    aAdd(aCabec,{'F1_FORNECE',cCodForn,NIL})
    aAdd(aCabec,{'F1_LOJA',cLojaForn,NIL})
    aAdd(aCabec,{"F1_ESPECIE",cEspecie,NIL})
    If !Empty(cCondPag)
        aAdd(aCabec,{"F1_COND",cCondPag,NIL})
    EndIf
    aAdd(aCabec,{"F1_STATUS",'',NIL})
    aAdd(aCabec,{"F1_CHVNFE",cChvNfe,NIL})

    //-- Itens Nota Fiscal --//
    If lManual //-- Tela Manual --//
        ProcRegua(Len(oMSNewGe3:aCols))
        For nX := 1 To Len(oMSNewGe3:aCols)
            cCodProdForn := AllTrim(oMSNewGe3:aCols[nX][2])
            cProdSB1 := Posicione("SA5", 14, xFilial("SA5") + cCodForn + cLojaForn + cCodProdForn, "A5_PRODUTO")
            cB1_SEGUM := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cProdSB1, "B1_SEGUM"))
            If !Empty(cProdSB1)
                aAdd(aItens,{"D1_ITEM",oMSNewGe3:aCols[nX][1],NIL})
                aAdd(aItens,{"D1_COD",cProdSB1,NIL})
                If SubStr(oMSNewGe3:aCols[nX][4], 1, 2) == cB1_SEGUM
                    aAdd(aItens,{"D1_QTSEGUM",oMSNewGe3:aCols[nX][5],Nil})
                Else
                    aAdd(aItens,{"D1_QUANT",oMSNewGe3:aCols[nX][5],Nil})
                EndIf
                aAdd(aItens,{"D1_VUNIT",oMSNewGe3:aCols[nX][6],Nil})
                aAdd(aItens,{"D1_TOTAL",oMSNewGe3:aCols[nX][7],Nil})
                aAdd(aItens,{"D1_TES",'',NIL})
                aAdd(aItens,{"D1_PEDIDO",oMSNewGe3:aCols[nX][8],NIL})
                aAdd(aItens,{"D1_ITEMPC",oMSNewGe3:aCols[nX][9],NIL})
                aAdd(aLinha, aItens)
                IncProc()
            EndIf
            aItens := {}
            cCodProdForn := ""
            cProdSB1 := ""
            cB1_SEGUM := ""
        Next nX
    Else
        If ValType(aNFItens) == "O"
            ProcRegua(1)

            cCodProdForn := AllTrim(aNFItens:_PROD:_CPROD:TEXT)
            cProdSB1 := Posicione("SA5", 14, xFilial("SA5") + cCodForn + cLojaForn + cCodProdForn, "A5_PRODUTO")
            cPedComp := AvalNumPC(aNFItens:_PROD:_XPED:TEXT)
            cItemPC := AvalItemPC(aNFItens:_PROD:_XPED:TEXT)
            cB1_SEGUM := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cProdSB1, "B1_SEGUM"))
            If !Empty(cProdSB1)
                aAdd(aItens,{"D1_ITEM",PadL(aNFItens:_NITEM:TEXT, 4, "0"),NIL})
                aAdd(aItens,{"D1_COD",cProdSB1,NIL})
                If SubStr(aNFItens:_PROD:_UTRIB:TEXT, 1, 2) == cB1_SEGUM
                    aAdd(aItens,{"D1_QTSEGUM",Val(aNFItens:_PROD:_QCOM:TEXT),Nil})
                Else
                    aAdd(aItens,{"D1_QUANT",Val(aNFItens:_PROD:_QCOM:TEXT),Nil})
                EndIf
                aAdd(aItens,{"D1_VUNIT",Val(aNFItens:_PROD:_VUNCOM:TEXT),Nil})
                aAdd(aItens,{"D1_TOTAL",Val(aNFItens:_PROD:_VPROD:TEXT),Nil})
                aAdd(aItens,{"D1_TES",'',NIL})
                aAdd(aItens,{"D1_PEDIDO",cPedComp,NIL})
                aAdd(aItens,{"D1_ITEMPC",cItemPC,NIL})
                aAdd(aLinha, aItens)
                IncProc()
            EndIf
            aItens := {}
            cCodProdForn := ""
            cProdSB1 := ""
            cPedComp := ""
            cItemPC := ""
            cB1_SEGUM := ""
        ElseIf ValType(aNFItens) == "A"
            ProcRegua(Len(aNFItens))

            For nX := 1 To Len(aNFItens)
                cCodProdForn := AllTrim(aNFItens[nX]:_PROD:_CPROD:TEXT)
                cProdSB1 := Posicione("SA5", 14, xFilial("SA5") + cCodForn + cLojaForn + cCodProdForn, "A5_PRODUTO")
                cPedComp := AvalNumPC(aNFItens[nX]:_PROD:_XPED:TEXT)
                cItemPC := AvalItemPC(aNFItens[nX]:_PROD:_XPED:TEXT)
                cB1_SEGUM := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cProdSB1, "B1_SEGUM"))
                If !Empty(cProdSB1)
                    aAdd(aItens,{"D1_ITEM",PadL(aNFItens[nX]:_NITEM:TEXT, 4, "0"),NIL})
                    aAdd(aItens,{"D1_COD",cProdSB1,NIL})
                    If SubStr(aNFItens[nX]:_PROD:_UTRIB:TEXT, 1, 2) == cB1_SEGUM
                        aAdd(aItens,{"D1_QTSEGUM",Val(aNFItens[nX]:_PROD:_QCOM:TEXT),Nil})
                    Else
                        aAdd(aItens,{"D1_QUANT",Val(aNFItens[nX]:_PROD:_QCOM:TEXT),Nil})
                    EndIf
                    aAdd(aItens,{"D1_VUNIT",Val(aNFItens[nX]:_PROD:_VUNCOM:TEXT),Nil})
                    aAdd(aItens,{"D1_TOTAL",Val(aNFItens[nX]:_PROD:_VPROD:TEXT),Nil})
                    aAdd(aItens,{"D1_TES",'',NIL})
                    aAdd(aItens,{"D1_PEDIDO",cPedComp,NIL})
                    aAdd(aItens,{"D1_ITEMPC",cItemPC,NIL})
                    aAdd(aLinha, aItens)
                    IncProc()
                EndIf
                aItens := {}
                cCodProdForn := ""
                cProdSB1 := ""
                cPedComp := ""
                cItemPC := ""
                cB1_SEGUM := ""
            Next nX
        EndIf
    EndIf
      
    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc, lSimula, nTelaAuto)

    If lMsErroAuto
        MsgAlert("Erro ao processar documento fiscal.", "IncPreDoc")
        MostraErro()
    Else
        SF1->( dbSetOrder(1) )
        If SF1->( dbSeek(xFilial("SF1") + cDoc + PadR(cSerie, TamSX3("F1_SERIE")[1]) + cCodForn + cLojaForn) )
            MsgInfo("Documento fiscal importado com sucesso.", "IncPreDoc")
            
            RecLock("ZB0", .F.)
                ZB0->ZB0_PROC = "S" //-- Documento Processado --// 
            ZB0->( MsUnlock() )
        Else
            MsgAlert("Documento fiscal pendente de processamento.", "IncPreDoc")
        EndIf
    EndIf

    RestArea(aAreaSF1)
Return

/*/{Protheus.doc} AvalNumPC
Avalia tag XPED para buscar o numero do pedido
@type Static Function
@author Marcos Natã Santos
@since 04/09/2019
@version 1.0
@param cPedComp, char
@return cNumPC, char
/*/
Static Function AvalNumPC(cPedComp)
    Local cNumPC := ""

    If "-" $ cPedComp
        cNumPC := PadL(SubStr(cPedComp, 1, At("-", cPedComp)-1), TamSX3("D1_PEDIDO")[1], "0")
    ElseIf "/" $ cPedComp
        cNumPC := PadL(SubStr(cPedComp, 1, At("/", cPedComp)-1), TamSX3("D1_PEDIDO")[1], "0")
    EndIf
Return cNumPC

/*/{Protheus.doc} AvalItemPC
Avalia tag XPED para buscar o item do pedido
@type Static Function
@author Marcos Natã Santos
@since 04/09/2019
@version 1.0
@param cPedComp, char
@return cItemPC, char
/*/
Static Function AvalItemPC(cPedComp)
    Local cItemPC := ""
    
    If "-" $ cPedComp
        cItemPC := PadL(SubStr(cPedComp, At("-", cPedComp)+1), TamSX3("C7_ITEM")[1], "0")
    ElseIf "/" $ cPedComp
        cItemPC := PadL(SubStr(cPedComp, At("/", cPedComp)+1), TamSX3("C7_ITEM")[1], "0")
    EndIf
Return cItemPC

/*/{Protheus.doc} ImportNfPed
Importação de nota fiscal informando pedido
@type Static Function
@author Marcos Natã Santos
@since 05/09/2019
@version 1.0
@param oDFe, object, Documento Fiscal
@param cCodForn, char
@param cLojaForn, char
/*/
Static Function ImportNfPed(oDFe, cCodForn, cLojaForn)
    Local lOk := .T.
    Local nX := 0
    // Local nI := 0
    Local cHelp := ""
    Local cSoluc := ""
    Local aNFItens := {}

    //----------------------------------------------------------//
    //-- Verifica itens/pedidos selecionados para nota fiscal --//
    //----------------------------------------------------------//
    For nX := 1 To Len(oMSNewGe3:aCols)
        If Empty(oMSNewGe3:aCols[nX][8]) .Or. Empty(oMSNewGe3:aCols[nX][9])
            cHelp := "Pedido/Itens não informados para nota fiscal."
            cSoluc := "Informe um pedido/item para cada item da nota fiscal."
            Help(Nil,Nil,"PEDVAZIO",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
            Return
        EndIf
        // For nI := 1 To Len(oMSNewGe3:aCols)
        //     If nX <> nI .And. oMSNewGe3:aCols[nX][8] == oMSNewGe3:aCols[nI][8];
        //         .And. oMSNewGe3:aCols[nX][9] == oMSNewGe3:aCols[nI][9]

        //         cHelp := "Item da nota fiscal com item/pedido duplicado."
        //         cSoluc := "Selecione apenas um pedido/item por item da nota fiscal."
        //         Help(Nil,Nil,"ITEMDUPL",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
        //         Return
        //     EndIf
        // Next nI
    Next nX
    
    //--------------------------------------------------------//
    //-- Verifica/Atualiza cadastro de Produto x Fornecedor --//
    //--------------------------------------------------------//
    For nX := 1 To Len(oMSNewGe3:aCols)
        cPedComp := oMSNewGe3:aCols[nX][8]
        cItemPC := oMSNewGe3:aCols[nX][9]
        cCodProdForn := AllTrim(oMSNewGe3:aCols[nX][2])
        lOk := ProdxForn(cCodForn, cLojaForn, cPedComp, cItemPC, cCodProdForn)

        If !lOk
            cHelp := "Existe itens não encontrados no cadastro de Produto x Fornecedor."
            cSoluc := "Por favor verifica a amarração dos produtos com este fornecedor."
            Help(Nil,Nil,"NOTPRDXFOR",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
            Return
        EndIf
    Next nX

    Processa({|| IncPreDoc(oDFe, .T.)}, "Importando Nota Fiscal", "Processando documento...", .F.)

    oDlgImpt:End()
Return

/*/{Protheus.doc} ItemPed
Seleção de Pedido/Item para nota fiscal
@type Static Function
@author Marcos Natã Santos
@since 05/09/2019
@version 1.0
/*/
Static Function ItemPed()
    Local cTitle := "Item Pedido"
    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := Space(TamSX3("D1_PEDIDO")[1])
    Local oGet2
    Local cGet2 := Space(TamSX3("D1_ITEMPC")[1])
    Local oSay1
    Local oSay2

    Static oDlgItem

    DEFINE MSDIALOG oDlgItem TITLE cTitle STYLE 128 FROM 000, 000 TO 150, 400 COLORS 0, 16777215 PIXEL

        @ 020, 025 SAY oSay1 PROMPT "Pedido" SIZE 025, 007 OF oDlgItem COLORS 0, 16777215 PIXEL
        @ 032, 025 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgItem COLORS 0, 16777215 F3 "SC7OBJ" PIXEL
        @ 020, 100 SAY oSay2 PROMPT "Item" SIZE 025, 007 OF oDlgItem COLORS 0, 16777215 PIXEL
        @ 032, 100 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlgItem COLORS 0, 16777215 PIXEL
        @ 057, 155 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlgItem ACTION {|| GrvItemPed(cGet1, cGet2) } PIXEL
        @ 057, 115 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgItem ACTION {|| oDlgItem:End() } PIXEL

    ACTIVATE MSDIALOG oDlgItem CENTERED
Return

/*/{Protheus.doc} GrvItemPed
Grava pedido/item nos itens da nota fiscal
@type Static Function
@author Marcos Natã Santos
@since 05/09/2019
@version 1.0
@param cPedido, char
@param cItemPC, char
/*/
Static Function GrvItemPed(cPedido, cItemPC)
    Local nLinha := oMSNewGe3:nAt

    If !Empty(cPedido) .And. !Empty(cItemPC)
        oMSNewGe3:aCols[nLinha][8] := cPedido
        oMSNewGe3:aCols[nLinha][9] := cItemPC
    EndIf

    oDlgItem:End()
Return
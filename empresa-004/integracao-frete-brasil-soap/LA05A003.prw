#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF Chr(13) + Chr(10)

#DEFINE MODEL_OPERATION_VIEW       1
#DEFINE MODEL_OPERATION_INSERT     3
#DEFINE MODEL_OPERATION_UPDATE     4
#DEFINE MODEL_OPERATION_DELETE     5
#DEFINE MODEL_OPERATION_ONLYUPDATE 6
#DEFINE MODEL_OPERATION_IMPR       8
#DEFINE MODEL_OPERATION_COPY       9

#DEFINE FB_TOKEN "19DE86CF-B805-4F6F-A3C5-0E254E609445"

/*/{Protheus.doc} LA05A003

Browse para Ocorrências Frete Brasil

@author 	Marcos Natã Santos
@since 		27/11/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Marcos Natã Santos - Construção
/*/
User Function LA05A003() //-- U_LA05A003()
	Local oBrowse	:= Nil
    Local aUserGrp  := UsrRetGrp()
    Local nX        := 0
    Local cFilter   := ""
    Local cMVCoServ	:= AllTrim(GetMV("MV_XCOSERV"))
    Local cMVFBOutr := AllTrim(GetMV("MV_XFBOUTR"))
    Local lAdm      := .F.

	Private cTitulo	:= OemtoAnsi("Ocorrências Frete Brasil")
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZS")

	oBrowse:AddLegend("ZS_STATUS == '0'", "BR_VERDE"		, "Entrega Em Processo")
	oBrowse:AddLegend("ZS_STATUS == '1'", "BR_VERMELHO"		, "Entrega Finalizada")

	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A003")

    For nX:= 1 to Len(aUserGrp)
		If aUserGrp[nX] == "000000" .Or. aUserGrp[nX] $ cMVCoServ .Or. aUserGrp[nX] $ cMVFBOutr
			lAdm := .T.
		EndIf
	Next nX

    If .Not. lAdm
        cFilter := GetFilter()
        oBrowse:SetFilterDefault("ZS_CLILOJ $ '"+ cFilter +"'")
    EndIf

	oBrowse:Activate()
	
Return oBrowse

/*/{Protheus.doc} ModelDef

Modelo de Dados das Ocorrências Frete Brasil

@author 	Marcos Natã Santos
@since 		27/11/2018
@version 	12.1.17
@return 	oModel
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStrSZS	:= Nil
	Local oStrSZT	:= Nil

	oModel 	:= MPFormModel():New('LA053MOD')
	oStrSZS	:= FWFormStruct(1, 'SZS')
	oStrSZT	:= FWFormStruct(1, 'SZT')

	oModel:AddFields('SZS_MASTER', /*cOwner*/, oStrSZS)
	
	oModel:AddGrid("SZT_DETAIL","SZS_MASTER",oStrSZT)
	oModel:SetRelation("SZT_DETAIL",;
	{{"ZT_FILIAL","xFilial('SZT')"},;
	{"ZT_CHAVENF","ZS_CHAVENF"}},;
	SZT->(IndexKey(1)))

	//-- Seta a chave primaria
	oModel:SetPrimaryKey({"ZS_FILIAL","ZS_CHAVENF"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("SZS_MASTER"):SetDescription(OemToAnsi("Nota Fiscal"))
	oModel:GetModel("SZT_DETAIL"):SetDescription(OemToAnsi("Ocorrências"))

Return oModel

/*/{Protheus.doc} ViewDef

Define visualização das Ocorrências Frete Brasil

@author 	Marcos Natã Santos
@since 		27/11/2018
@version 	12.1.17
@return 	oView
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ViewDef()
	Local oModel	:= FWLoadModel("LA05A003")
	Local oView		:= Nil
	Local oStrSZS	:= Nil
	Local oStrSZT	:= Nil
	
	oView 	:= FWFormView():New()
	oStrSZS	:= FWFormStruct(2, 'SZS')
	oStrSZT	:= FWFormStruct(2, 'SZT')
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("VIEW_SZS", oStrSZS, "SZS_MASTER")
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("VIEW_SZT", oStrSZT, "SZT_DETAIL")

	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("BOX_SUP",30)
	oView:CreateHorizontalBox("BOX_INF",70)
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("VIEW_SZS","BOX_SUP")
	oView:SetOwnerView("VIEW_SZT","BOX_INF")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("VIEW_SZS",OemtoAnsi("Nota Fiscal"))
	oView:EnableTitleView("VIEW_SZT",OemtoAnsi("Ocorrências"))
	
Return oView

/*/{Protheus.doc} MenuDef

Funcao que cria o menu principal do Browse do Pedido de Venda.

@author 	Marcos Natã Santos
@since 		27/11/2018
@version 	12.1.17
@return 	aRotina
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function MenuDef()
	Local aRotina	:= {}
    Local aUserGrp  := UsrRetGrp()
    Local nX        := 0
    Local cMVCoServ	:= AllTrim(GetMV("MV_XCOSERV"))
    Local lAdm      := .F.

    For nX:= 1 to Len(aUserGrp)
		If aUserGrp[nX] == "000000" .Or. aUserGrp[nX] $ cMVCoServ
			lAdm := .T.
		EndIf
	Next nX
	
	ADD OPTION aRotina Title "Visualizar"	         ACTION "VIEWDEF.LA05A003" 				    OPERATION MODEL_OPERATION_VIEW	ACCESS 0
	ADD OPTION aRotina Title "Sincronizar"	         ACTION "StaticCall(LA05A003, ProcNota)"	OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    ADD OPTION aRotina Title "Sincronizar Base"      ACTION "StaticCall(LA05A003, ProcSync)"	OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    ADD OPTION aRotina Title "Ocorrências Analítico" ACTION "U_LA05R005()"	                    OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    ADD OPTION aRotina Title "Ocorrências Sintético" ACTION "U_LA05R006()"	                    OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    ADD OPTION aRotina Title "Ocorrências Extensivo" ACTION "U_LA05R007()"	                    OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    ADD OPTION aRotina Title "Buscar Ocorrências NF"  ACTION "StaticCall(LA05A003, BscOcorrNF)"  OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    If lAdm
        ADD OPTION aRotina Title "Agendar Entrega"       ACTION "StaticCall(LA05A003, SetAgenda)"   OPERATION MODEL_OPERATION_VIEW	ACCESS 0
    EndIf

Return aRotina

/*/{Protheus.doc} ProcSync
ProcSync
@author 	Marcos Natã Santos
@since		27/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function ProcSync()
    Local oComboBox
    Local cComboBox  := "05207076000297 - LINEA SUCRALOSE"
    Local oGroup
    Local oSay1
    Local lOk        := .F.
    Local cFilSelect := ""
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Sincronização" FROM 000, 000  TO 220, 500 COLORS 0, 16777215 PIXEL

        @ 045, 025 GROUP oGroup TO 070, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
        @ 055, 065 SAY oSay1 PROMPT "Selecione a filial para sincronização dos dados." SIZE 115, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 082, 025 MSCOMBOBOX oComboBox VAR cComboBox ITEMS {"05207076000297 - LINEA SUCRALOSE","05207076000106 - LINEA ALIMENTOS"} SIZE 200, 010 OF oDlg COLORS 0, 16777215 PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||lOk:=.T.,oDlg:End()}, {||oDlg:End()})

    If lOk
        cFilSelect := SubStr(cComboBox,1,14)
	    Processa({|| SyncData(cFilSelect)}, "Sincronizando base", "Buscando ocorrências...")
    EndIf

Return

/*/{Protheus.doc} SyncData
SyncData
@author 	Marcos Natã Santos
@since		27/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function SyncData(cEmbarcCnpj,lSched)
	Local aOcorrencias  := {}
	Local nX            := 0
	Local cIntegraTipo  := ""
    Local cRetrans      := ""
    Local dDtIni        := DaySub(Date(), 60) //-- Busca 60 dias anteriores a data atual --//
    Local dDtFim        := Date()
    Local nPagina       := 1

    Default cEmbarcCnpj := "05207076000297"
    Default lSched      := .F.

    //--------------------------------------//
    //-- Ocorrências Diversas | Não Lidas --//
    //--------------------------------------//
    cRetrans      := "N" //-- N=Não lidos | S=Lidos
	cIntegraTipo  := "8" //-- 8=Diversas | 7=Entregas
	aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)

    While Len(aOcorrencias) > 0
        SaveOcorrencias(aOcorrencias)

        nPagina++
        aOcorrencias  := {}
        aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)
    EndDo

    //----------------------------------------------------//
    //-- Aguarda 5 segundos devido ao servidor suportar --//
    //-- apenas consultas de 5 em 5 segundos            --//
    //----------------------------------------------------//
    Sleep(5000)

    //--------------------------------------//
    //-- Ocorrências Diversas | Lidas     --//
    //--------------------------------------//
    nPagina       := 1
    cRetrans      := "S" //-- N=Não lidos | S=Lidos
    cIntegraTipo  := "8" //-- 8=Diversas | 7=Entregas
    aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)

    While Len(aOcorrencias) > 0
        SaveOcorrencias(aOcorrencias)

        nPagina++
        aOcorrencias  := {}
        aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)
    EndDo

    Sleep(5000)

    //--------------------------------------//
    //-- Ocorrências Entregas | Não Lidas --//
    //--------------------------------------//
    nPagina       := 1
    cRetrans      := "N" //-- N=Não lidos | S=Lidos
    cIntegraTipo  := "7" //-- 8=Diversas | 7=Entregas
    aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)

    While Len(aOcorrencias) > 0
        SaveOcorrencias(aOcorrencias)

        nPagina++
        aOcorrencias  := {}
        aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)
    EndDo

    Sleep(5000)

    //--------------------------------------//
    //-- Ocorrências Entregas | Lidas     --//
    //--------------------------------------//
    nPagina       := 1
    cRetrans      := "S" //-- N=Não lidos | S=Lidos
    cIntegraTipo  := "7" //-- 8=Diversas | 7=Entregas
    aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)

    While Len(aOcorrencias) > 0
        SaveOcorrencias(aOcorrencias)

        nPagina++
        aOcorrencias  := {}
        aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,,cRetrans,dDtIni,dDtFim,nPagina)
    EndDo

    If lSched
        //-- Realiza sincronização nota a nota (20 a 28 segundos por nota) --//
        SyncAllToItem(dDtIni)
    EndIf

Return

/*/{Protheus.doc} SaveOcorrencias
Inclui/Altera ocorrências de entrega/diversa
@type  Static Function
@author Marcos Natã Santos
@since 08/07/2019
@version 12.1.17
@param aOcorrencias, array, Ocorrencias de entrega
/*/
Static Function SaveOcorrencias(aOcorrencias)
    Local aAreaSZS      := SZS->(GetArea())
    Local aAreaSZT      := SZT->(GetArea())
    Local nX            := 0
    Local oFBOcorrencia := Nil
    Local aCliData      := {}
    Local dDtEmbarq

    Default aOcorrencias := {}

    ProcRegua(Len(aOcorrencias))
    For nX := 1 To Len(aOcorrencias)
        IncProc()
        oFBOcorrencia := aOcorrencias[nX]

        SZS->( dbSetOrder(1) ) //-- ZS_CHAVENF
        SZT->( dbSetOrder(2) ) //-- ZT_CHAVENF + ZT_OCORREN
        SZS->( dbGoTop() )
        SZT->( dbGoTop() )
        If .Not. SZS->(dbSeek( xFilial("SZS") + oFBOcorrencia:cChave ))
            aCliData  := GetCliData(PADL(oFBOcorrencia:cNumero,9,"0"), oFBOcorrencia:cSerie)
            dDtEmbarq := GetNFData(oFBOcorrencia:cChave)
            RecLock("SZS", .T.)
            SZS->ZS_FILIAL  := xFilial("SZS")
            SZS->ZS_REMETEN := oFBOcorrencia:cRemetente
            SZS->ZS_RMTTRS  := oFBOcorrencia:cRemRazaoSocial
            SZS->ZS_NUMNF   := PADL(oFBOcorrencia:cNumero,9,"0")
            SZS->ZS_SERIE   := oFBOcorrencia:cSerie
            SZS->ZS_CHAVENF := oFBOcorrencia:cChave
            SZS->ZS_EMISSAO := oFBOcorrencia:dEmissao
            If Len(aCliData) > 0
                SZS->ZS_PEDIDO  := aCliData[1]
                SZS->ZS_CLILOJ  := AllTrim(aCliData[2] + aCliData[3])
                SZS->ZS_CLINOME := aCliData[4]
                SZS->ZS_PEDCLI  := aCliData[5]
                SZS->ZS_ENTREG  := aCliData[6]
            EndIf
            If !Empty(dDtEmbarq)
                SZS->ZS_EMBARQ := dDtEmbarq
            EndIf
            SZS->ZS_STATUS  := "0" //-- Entrega Em Processo
            SZS->( MsUnlock() )
            RecLock("SZT", .T.)
            SZT->ZT_FILIAL  := xFilial("SZT")
            SZT->ZT_OCORREN := oFBOcorrencia:cRegistro
            SZT->ZT_TRANSPO := oFBOcorrencia:cTransportador
            SZT->ZT_TRANSRS := oFBOcorrencia:cTranRazaoSocial
            SZT->ZT_CODIGO  := oFBOcorrencia:cCodigo
            SZT->ZT_DESCRI  := oFBOcorrencia:cDescricao
            SZT->ZT_OCORDAT := oFBOcorrencia:dOcorreuData
            SZT->ZT_OCORHR  := oFBOcorrencia:cOcorreuHora
            SZT->ZT_RSPNOME := oFBOcorrencia:cResponsavelNome
            SZT->ZT_RSPDOC  := oFBOcorrencia:cResponsavelDocumento
            SZT->ZT_RSPCONT := oFBOcorrencia:cResponsavelContato
            SZT->ZT_SOLUDAT := oFBOcorrencia:dSolucaoData
            SZT->ZT_SOLUHR  := oFBOcorrencia:cSolucaoHora
            SZT->ZT_SOLURSP := oFBOcorrencia:cSolucaoResponsavel
            SZT->ZT_CANCDAT := oFBOcorrencia:dCancelaData
            SZT->ZT_CHAVENF := oFBOcorrencia:cChave
            SZT->( MsUnlock() )

            ConOut(DTOC(Date()) + " " + Time() + " Frete Brasil - Nota " + AllTrim(oFBOcorrencia:cNumero);
                + " Ocorrência " + AllTrim(oFBOcorrencia:cRegistro) + " Incluída com Sucesso!")
        ElseIf .Not. SZT->(dbSeek( xFilial("SZT") + oFBOcorrencia:cChave + oFBOcorrencia:cRegistro ))
            RecLock("SZT", .T.)
            SZT->ZT_FILIAL  := xFilial("SZT")
            SZT->ZT_OCORREN := oFBOcorrencia:cRegistro
            SZT->ZT_TRANSPO := oFBOcorrencia:cTransportador
            SZT->ZT_TRANSRS := oFBOcorrencia:cTranRazaoSocial
            SZT->ZT_CODIGO  := oFBOcorrencia:cCodigo
            SZT->ZT_DESCRI  := oFBOcorrencia:cDescricao
            SZT->ZT_OCORDAT := oFBOcorrencia:dOcorreuData
            SZT->ZT_OCORHR  := oFBOcorrencia:cOcorreuHora
            SZT->ZT_RSPNOME := oFBOcorrencia:cResponsavelNome
            SZT->ZT_RSPDOC  := oFBOcorrencia:cResponsavelDocumento
            SZT->ZT_RSPCONT := oFBOcorrencia:cResponsavelContato
            SZT->ZT_SOLUDAT := oFBOcorrencia:dSolucaoData
            SZT->ZT_SOLUHR  := oFBOcorrencia:cSolucaoHora
            SZT->ZT_SOLURSP := oFBOcorrencia:cSolucaoResponsavel
            SZT->ZT_CANCDAT := oFBOcorrencia:dCancelaData
            SZT->ZT_CHAVENF := oFBOcorrencia:cChave
            SZT->( MsUnlock() )

            ConOut(DTOC(Date()) + " " + Time() + " Frete Brasil - Nota " + AllTrim(oFBOcorrencia:cNumero);
                + " Ocorrência " + AllTrim(oFBOcorrencia:cRegistro) + " Incluída com Sucesso!")
        EndIf

        If AllTrim(oFBOcorrencia:cCodigo) $ "01/02/24/31"
            RecLock("SZS", .F.)
            SZS->ZS_STATUS := "1"
            SZS->( MsUnlock() )
        EndIf

        If Empty(SZS->ZS_EMBARQ) .And. IsInCallStack("SyncNota")
            dDtEmbarq := GetNFData(SZS->ZS_CHAVENF)
            RecLock("SZS", .F.)
            SZS->ZS_EMBARQ := dDtEmbarq
            SZS->( MsUnlock() )
        EndIf
        
    Next nX

    RestArea(aAreaSZS)
    RestArea(aAreaSZT)

Return

/*/{Protheus.doc} ProcNota
ProcNota
@author 	Marcos Natã Santos
@since		28/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function ProcNota()
    Local cDocNum     := SZS->ZS_CHAVENF
    Local cEmbarcCnpj := SZS->ZS_REMETEN
	Processa({|| SyncNota(cEmbarcCnpj,cDocNum)}, "Sincronizando NF", "Buscando ocorrências...")
Return

/*/{Protheus.doc} SyncNota
SyncNota
@author 	Marcos Natã Santos
@since		28/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function SyncNota(cEmbarcCnpj,cDocNum)
	Local aOcorrencias  := {}
	Local aDiversas     := {}
	Local nX            := 0
	Local cIntegraTipo  := ""
    Local cRetrans      := ""

    Default cEmbarcCnpj := ""
    Default cDocNum     := ""

    cRetrans      := "N"
	cIntegraTipo  := "8"
	aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,cDocNum,cRetrans)

	cIntegraTipo  := "7"
	aDiversas	  := GetWSData(cEmbarcCnpj,cIntegraTipo,cDocNum,cRetrans)

	For nX := 1 To Len(aDiversas)
		AADD(aOcorrencias, aDiversas[nX])
	Next nX

    //-------------------------------------------------//
    //-- Muda flag do parametro cRetrans para S->SIM --//
    //-------------------------------------------------//
    If Len(aOcorrencias) = 0
        cRetrans      := "S"
        cIntegraTipo  := "8"
        aOcorrencias  := GetWSData(cEmbarcCnpj,cIntegraTipo,cDocNum,cRetrans)

        cIntegraTipo  := "7"
        aDiversas	  := GetWSData(cEmbarcCnpj,cIntegraTipo,cDocNum,cRetrans)

        For nX := 1 To Len(aDiversas)
            AADD(aOcorrencias, aDiversas[nX])
        Next nX
    EndIf

    If Len(aOcorrencias) = 0
        // MsgInfo("Não existem ocorrências a sincronizar.")
        Return
    EndIf

    SaveOcorrencias(aOcorrencias)

Return

/*/{Protheus.doc} GetWSData

GetWSData
Servidor do FreteBrasil aceita requisicoes apenas de 5 em 5 segundos

@author 	Marcos Natã Santos
@since		26/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function GetWSData(cEmbarcCnpj,cIntegraTipo,cDocNum,cRetrans,dDtIni,dDtFim,nPagina)
    Local oWSDL
    Local lOk
    Local cResp
    Local aOcorrencias  := {}
    Local oXML
    Local xRet
    Local nQtdReg       := 0
    Local nX            := 0
    Local oFBOcorrencia := Nil

    Local cWSDL         := SuperGetMV("MV_XFBWSDL", .F., "https://wsfretebrasil.activecorp.com.br/WSACTIVE/Service.svc?wsdl")

    Default cEmbarcCnpj  := "05207076000297"
	Default cIntegraTipo := ""
    Default cDocNum      := ""
	Default cRetrans     := ""
	Default dDtIni       := Space(8)
	Default dDtFim       := Space(8)
	Default nPagina      := 1

    oWSDL := TWSDLManager():New()
    oXML  := TXmlManager():New()

    oWSDL:lVerbose := .T.
    
    //-- Certificado deve estar na pasta protheus_data --//
    oWSDL:cSSLCACertFile := "\certificado\FreteBrasil\CA_FreteBrasil.pem"

    //-- WSDL do ambiente producao Frete Brasil --//
    lOk := oWSDL:ParseURL( cWSDL )
    If !lOk 
        MsgStop( oWSDL:cError , "ParseURL() ERROR")
        Return aOcorrencias
    EndIf

    lOk := oWSDL:SetOperation( "ConsultaDocumento" )
    If !lOk
        MsgStop( oWSDL:cError , "SetOperation(ConsultaDocumento) ERROR")
        Return aOcorrencias
    EndIf

    oWSDL:SetFirst("token", FB_TOKEN)
    oWSDL:SetFirst("embarc_cnpj", cEmbarcCnpj)
    oWSDL:SetFirst("integracao_tipo", cIntegraTipo)
    If !Empty(cDocNum)
        oWSDL:SetFirst("documento_numero", cDocNum)
    EndIf
    oWSDL:SetFirst("retransmitir", cRetrans)
    If !Empty(dDtIni) .And. !Empty(dDtFim)
        oWSDL:SetFirst("data_inicial", FormatWsDate(dDtIni))
        oWSDL:SetFirst("data_final", FormatWsDate(dDtFim))
    EndIf
    oWSDL:SetFirst("pagina", cValToChar(nPagina))

    lOk := oWSDL:SendSoapMsg()
    If !lOk
        Sleep( 5100 ) //-- Espera 5 segundos para nova requisicao
        lOk := oWSDL:SendSoapMsg()
        If !lOk
            MsgStop( oWSDL:cError , "SendSoapMsg() ERROR")
            Return aOcorrencias
        EndIf
    EndIf

    //----------------------------------------------------------//
    //-- maxStringSize=10 no appserver.ini                    --//
    //-- para conseguir receber a resposta completa do server --//
    //----------------------------------------------------------//
    cResp := oWSDL:GetSoapResponse()
    xRet := oXML:Parse( cResp )
    If xRet == .F.
        MsgStop( "Error: " + oXML:Error() )
        Return aOcorrencias
    EndIf

    While oXML:DOMHasChildNode() .And. oXML:cName != "OcorrenciaConsulta"
        oXML:DOMChildNode()
        If oXML:cName == "Fault"
            Return aOcorrencias
		ElseIf oXML:cName == "RetornoGenerico"
			Return aOcorrencias
        EndIf
    EndDo

    nQtdReg := oXML:DOMChildCount()

    If oXML:cName != "OCORRENCIA"
        oXML:DOMChildNode() //-- OCORRENCIA --//
    EndIf

    //-------------------------------//
    //-- Cria array de ocorrencias --//
    //-------------------------------//
    For nX := 1 To nQtdReg
        oFBOcorrencia := FBOcorrencia():New()

        xRet := oXML:DOMHasAtt()
        If xRet
            xRet := oXML:DOMGetAttArray()
            If xRet[1][1] == "REGISTRO"
                oFBOcorrencia:cRegistro := xRet[1][2]
            EndIf
        EndIf
        
        oXML:DOMChildNode() //-- NOTA_FISCAL --//
        oXML:DOMChildNode() //-- REMETENTE --//

        If oXML:cName == "REMETENTE"
            oFBOcorrencia:cRemetente := oXML:cText
        EndIf

        While oXML:DOMHasNextNode()
            oXML:DOMNextNode()
            If oXML:cName == "REMETENTE_RAZAOSOCIAL"
                oFBOcorrencia:cRemRazaoSocial := oXML:cText
                Loop
            EndIf
            If oXML:cName == "NUMERO"
                oFBOcorrencia:cNumero := oXML:cText
                Loop
            EndIf
            If oXML:cName == "SERIE"
                oFBOcorrencia:cSerie := oXML:cText
                Loop
            EndIf
            If oXML:cName == "CHAVE"
                oFBOcorrencia:cChave := oXML:cText
                Loop
            EndIf
            If oXML:cName == "EMISSAO"
                oFBOcorrencia:dEmissao := CTOD(oXML:cText)
                Loop
            EndIf
        EndDo

        oXML:DOMParentNode() //-- NOTA_FISCAL --//
        oXML:DOMNextNode() //-- DETALHE --//
        oXML:DOMChildNode() //-- TRANSPORTADOR --//

        If oXML:cName == "TRANSPORTADOR"
            oFBOcorrencia:cTransportador := oXML:cText
        EndIf

        While oXML:DOMHasNextNode()
            oXML:DOMNextNode()
            If oXML:cName == "TRANSPORTADOR_RAZAOSOCIAL"
                oFBOcorrencia:cTranRazaoSocial := oXML:cText
                Loop
            EndIf
            If oXML:cName == "CODIGO"
                oFBOcorrencia:cCodigo := oXML:cText
                Loop
            EndIf
            If oXML:cName == "DESCRICAO"
                oFBOcorrencia:cDescricao := oXML:cText
                Loop
            EndIf
            If oXML:cName == "OCORREU_DATA"
                oFBOcorrencia:dOcorreuData := CTOD(oXML:cText)
                Loop
            EndIf
            If oXML:cName == "OCORREU_HORA"
                oFBOcorrencia:cOcorreuHora := oXML:cText
                Loop
            EndIf
            If oXML:cName == "RESPONSAVEL_NOME"
                oFBOcorrencia:cResponsavelNome := oXML:cText
                Loop
            EndIf
            If oXML:cName == "RESPONSAVEL_DOCUMENTO"
                oFBOcorrencia:cResponsavelDocumento := oXML:cText
                Loop
            EndIf
            If oXML:cName == "RESPONSAVEL_CONTATO"
                oFBOcorrencia:cResponsavelContato := oXML:cText
                Loop
            EndIf
            If oXML:cName == "SOLUCAO_DATA"
                oFBOcorrencia:dSolucaoData := CTOD(oXML:cText)
                Loop
            EndIf
            If oXML:cName == "SOLUCAO_HORA"
                oFBOcorrencia:cSolucaoHora := oXML:cText
                Loop
            EndIf
            If oXML:cName == "SOLUCAO_RESPONSAVEL"
                oFBOcorrencia:cSolucaoResponsavel := oXML:cText
                Loop
            EndIf
            If oXML:cName == "CANCELADA"
                oFBOcorrencia:dCancelaData := CTOD(oXML:cText)
                Loop
            EndIf
        EndDo

        oXML:DOMParentNode() //-- DETALHE --//
        oXML:DOMParentNode() //-- OCORRENCIA ATUAL --//

        If oXML:DOMHasNextNode()
            oXML:DOMNextNode() //-- PROXIMA OCORRENCIA --//
        EndIf

        //-- Adiciona ocorrencia ao array --//
        AADD(aOcorrencias, oFBOcorrencia)

    Next nX

Return aOcorrencias

/*/{Protheus.doc}  GetCliData
GetCliData
@author 	Marcos Natã Santos
@since		29/11/2018
@version 	12.1.17
@type 		function
/*/
Static Function GetCliData(cDoc,cSerie)
    Local cQry     := ""
    Local nQtdReg  := 0
    Local aDados   := {}

    cQry := "SELECT SD2.D2_PEDIDO, SD2.D2_CLIENTE, " + CRLF
    cQry += "       SD2.D2_LOJA, SA1.A1_NOME, SC6.C6_PEDCLI, SC5.C5_FECENT " + CRLF
    cQry += "FROM "+ RetSqlName("SD2") +" SD2 " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_COD = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "    ON SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "    AND SC6.C6_NUM = SD2.D2_PEDIDO " + CRLF
    cQry += "    AND SC6.C6_CLI = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SC6.C6_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "    AND SC6.C6_PEDCLI <> ' ' " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
    cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
    cQry += "    AND SC5.C5_NUM = SD2.D2_PEDIDO " + CRLF
    cQry += "    AND SC5.C5_CLIENTE = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SC5.C5_LOJACLI = SD2.D2_LOJA " + CRLF
    cQry += "WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
    cQry += "    AND ROWNUM = 1 " + CRLF
    cQry += "    AND SD2.D2_DOC = '"+ cDoc +"' " + CRLF
    cQry += "	 AND SD2.D2_SERIE = '"+ cSerie +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
    COUNT TO nQtdReg
    TMP1->(dbGoTop())

    If nQtdReg > 0
        AADD(aDados, TMP1->D2_PEDIDO)
        AADD(aDados, TMP1->D2_CLIENTE)
        AADD(aDados, TMP1->D2_LOJA)
        AADD(aDados, TMP1->A1_NOME)
        AADD(aDados, TMP1->C6_PEDCLI)
        AADD(aDados, STOD(TMP1->C5_FECENT))
    EndIf

    TMP1->(DbCloseArea())

Return aDados

/*/{Protheus.doc}  GetFilter

GetFilter
Gera filtro baseado no vendedor/repesentante conectado

@author 	Marcos Natã Santos
@since		03/12/2018
@version 	12.1.17
@type 		function
/*/
Static Function GetFilter()
    Local cQry      := ""
    Local cFilter   := ""
    Local cCodUser  := RetCodUsr()
    Local cVendedor := ""
    Local nQtdReg   := 0

    cVendedor := Posicione("SA3", 7, xFilial("SA3") + cCodUser, "A3_COD")

    If !Empty(cVendedor)
        cQry := "SELECT A1_COD || A1_LOJA CLILOJ " + CRLF
        cQry += "FROM " + RetSqlName("SA1") + CRLF
        cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "AND A1_VEND = '"+ cVendedor +"' " + CRLF
        cQry := ChangeQuery(cQry)

        If Select("TMPSA1") > 0
            TMPSA1->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "TMPSA1"

        TMPSA1->(dbGoTop())
        COUNT TO nQtdReg
        TMPSA1->(dbGoTop())

        If nQtdReg > 0
            While TMPSA1->( !EOF() )
                cFilter += "/" + AllTrim(TMPSA1->CLILOJ)
                TMPSA1->( dbSkip() )
            EndDo
        EndIf
        
        TMPSA1->(DbCloseArea())
    EndIf

Return cFilter

/*/{Protheus.doc}  SetAgenda

SetAgenda
Cadastro ocorrencia de agendamento de entregas

@author 	Marcos Natã Santos
@since		04/12/2018
@version 	12.1.17
@type 		function
/*/
Static Function SetAgenda()
    Local lOk     := .F.
    Local oButton
    Local oGet1
    Local oGet2
    Local oGet4
    Local oGet5
    Local oGet6
    Local oGroup1
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Local oSay5
    Local oSay6
    Local oSay7
    Local oSay8
    Local oSay9
    Local oSay10
    Local oSay11
    Local oSay12
    Local oSay13
    Local oSay14
    Local oSay15
    Local oSay16
    Local oSay17
    Local oComboBo1
    Local oComboBo2
    Local bActionInfo := {|| Processa( {|| GetInfoAgenda() }, "Buscando dados...",/*cMsg*/,.F.) }

    Private cGet1     := SubStr(SZS->ZS_CLILOJ,1,6)
    Private cGet2     := SubStr(SZS->ZS_CLILOJ,7,2)
    Private cGet4     := AllTrim(SZS->ZS_NUMNF)
    Private dGet5     := Date()
    Private cGet6     := Time()
    Private cChaveNfe := ""
    Private cComboBo1 := "Agenda"
    Private cComboBo2 := "Não"

    //-- Filtra clientes por vendedor/representante conectado --//
    Private cCliFilter := GetFilter()

    Private cRazaoSocial   := "Razao Social: RAZAO SOCIAL CLIENTE"
    Private cLeadTime      := "Lead Time: XXX dias"
    Private cNumPed        := "Pedido: XXXXXX"
    Private cNumPedCli     := "Ped. Cliente: XXXXXXXXX"
    Private cEmissaoPedido := "Emissao Pedido: XX/XX/XXXX"
    Private cEmissaoNota   := "Emissao Nota: XX/XX/XXXX"
    Private cDtEntrega     := "Dt Entrega: XX/XX/XXXX"
    Private cDtEmbarq      := "Dt Embarque: XX/XX/XXXX"
    Private cCodTransp     := "Cod. Transp.: XXXXXXXXX"
    Private cRSTransp      := "Razao Social Transp.: RAZAO SOCIAL TRANSPORTADORA"

    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Agendamento de Entrega" FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

        @ 040, 015 SAY oSay1 PROMPT "Cliente" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 050, 015 MSGET oGet1 VAR cGet1 SIZE 050, 010 OF oDlg COLORS 0, 16777215 F3 "SA1" PIXEL
        @ 040, 075 SAY oSay2 PROMPT "Loja" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 050, 075 MSGET oGet2 VAR cGet2 SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 040, 112 SAY oSay4 PROMPT "Nota Fiscal" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 050, 112 MSGET oGet4 VAR cGet4 SIZE 060, 010 OF oDlg VALID {|| GatCliLj(), cChaveNfe := "", oDlg:Refresh() } COLORS 0, 16777215 F3 "SF2" PIXEL
        @ 050, 185 BUTTON oButton PROMPT "Analisar" SIZE 050, 012 OF oDlg ACTION Eval(bActionInfo) PIXEL
        @ 075, 015 GROUP oGroup1 TO 150, 235 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
        @ 085, 020 SAY oSay6  PROMPT cRazaoSocial   SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 085, 175 SAY oSay12 PROMPT cLeadTime      SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 097, 020 SAY oSay3  PROMPT cNumPed        SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 097, 070 SAY oSay14 PROMPT cNumPedCli     SIZE 075, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 097, 150 SAY oSay7  PROMPT cEmissaoPedido SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 110, 020 SAY oSay8  PROMPT cEmissaoNota   SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 110, 117 SAY oSay11 PROMPT cDtEntrega     SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 122, 117 SAY oSay17 PROMPT cDtEmbarq      SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 122, 020 SAY oSay9  PROMPT cCodTransp     SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 135, 020 SAY oSay10 PROMPT cRSTransp      SIZE 195, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 155, 015 SAY oSay5 PROMPT "Data Agendamento" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 162, 015 MSGET oGet5 VAR dGet5 SIZE 060, 010 OF oDlg VALID {|| VldDtAgenda() } COLORS 0, 16777215 PIXEL
        @ 155, 085 SAY oSay13 PROMPT "Hora Agendamento" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 162, 085 MSGET oGet6 VAR cGet6 SIZE 025, 010 OF oDlg PICTURE "99:99:99" COLORS 0, 16777215 PIXEL
        @ 155, 145 SAY oSay15 PROMPT "Tipo" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 162, 145 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"Agenda","Solicitação"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
        @ 177, 015 SAY oSay16 PROMPT "Fora do Lead Time" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 185, 015 MSCOMBOBOX oComboBo2 VAR cComboBo2 ITEMS {"Não","Sim"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||lOk:=.T.,oDlg:End()}, {||oDlg:End()})

    If lOk .And. !Empty(cChaveNfe)
        If dGet5 >= Date()
            GrvAgenda(cChaveNfe,dGet5,cGet6)
        Else
            MsgAlert("Agendamento não realizado. Informe uma data válida.")
        EndIf
    ElseIf lOk
        MsgAlert("Agendamento não realizado. Clique para analisar a nota fiscal.")
    EndIf

Return

/*/{Protheus.doc} GatCliLj
Gatilha cliente e loja pela nota fiscal
@type  Function
@author Marcos Natã Santos
@since 17/06/2019
@version 12.1.17
/*/
Static Function GatCliLj
    cGet1 := ""
    cGet2 := ""
    If !Empty(cGet4)
        cGet1 := Posicione("SF2", 1, xFilial("SF2") + cGet4, "F2_CLIENTE")
        cGet2 := Posicione("SF2", 1, xFilial("SF2") + cGet4, "F2_LOJA")
    EndIf
Return

/*/{Protheus.doc}  VldDtAgenda
VldDtAgenda
@author 	Marcos Natã Santos
@since		05/12/2018
@version 	12.1.17
@type 		function
/*/
Static Function VldDtAgenda()
    If dGet5 < Date()
        MsgAlert("Informe uma data válida.")
        Return .F.
    EndIf
Return .T.

/*/{Protheus.doc}  GetInfoAgenda

GetInfoAgenda
Busca informacoes da agendamento

@author 	Marcos Natã Santos
@since		04/12/2018
@version 	12.1.17
@type 		function
/*/
Static Function GetInfoAgenda()
    Local cQry    := ""
    Local nQtdReg := 0
    Local cCodCli := cGet1
    Local cLoja   := cGet2
    Local cDoc    := cGet4

    If Empty(cCodCli) .Or. Empty(cLoja) .Or. Empty(cDoc)
        MsgAlert("Informe cliente, loja e nota fiscal.")
        Return
    EndIf

    ProcRegua(1)

    cQry := "SELECT SA1.A1_NOME, SC5.C5_EMISSAO, SF2.F2_EMISSAO, SF2.F2_TRANSP, " + CRLF
	cQry += "   SC5.C5_FECENT, SA1.A1_LEADTM, SC5.C5_NUM, SC6.C6_PEDCLI, SF2.F2_CHVNFE " + CRLF
    cQry += "FROM "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SF2") +" SF2 " + CRLF
    cQry += "    ON SF2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"' " + CRLF
    cQry += "    AND SF2.F2_CLIENTE = SA1.A1_COD " + CRLF
    cQry += "    AND SF2.F2_LOJA = SA1.A1_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SD2") +" SD2 " + CRLF
    cQry += "    ON SD2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
    cQry += "    AND SD2.D2_DOC = SF2.F2_DOC " + CRLF
    cQry += "    AND SD2.D2_SERIE = SF2.F2_SERIE " + CRLF
    cQry += "    AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " + CRLF
    cQry += "    AND SD2.D2_LOJA = SF2.F2_LOJA " + CRLF
    cQry += "    AND ROWNUM = 1 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
    cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
    cQry += "    AND SC5.C5_NUM = SD2.D2_PEDIDO " + CRLF
    cQry += "    AND SC5.C5_CLIENTE = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SC5.C5_LOJACLI = SD2.D2_LOJA " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "    ON SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "    AND SC6.C6_NUM = SD2.D2_PEDIDO " + CRLF
    cQry += "    AND SC6.C6_CLI = SD2.D2_CLIENTE " + CRLF
    cQry += "    AND SC6.C6_LOJA = SD2.D2_LOJA " + CRLF
    cQry += "    AND SC6.C6_PEDCLI <> ' ' " + CRLF
    cQry += "WHERE SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_COD = '"+ cCodCli +"' " + CRLF
    cQry += "    AND SA1.A1_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "    AND SF2.F2_DOC = '"+ cDoc +"' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("TMPAG") > 0
        TMPAG->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "TMPAG"

    TMPAG->(dbGoTop())
    COUNT TO nQtdReg
    TMPAG->(dbGoTop())

    If nQtdReg > 0
        cChaveNfe      := AllTrim(TMPAG->F2_CHVNFE)
        cRazaoSocial   := "Razao Social: " + AllTrim(TMPAG->A1_NOME)
        cLeadTime      := "Lead Time: " + AllTrim(TMPAG->A1_LEADTM) + " dias"
        cNumPed        := "Pedido: " + AllTrim(TMPAG->C5_NUM)
        cNumPedCli     := "Ped. Cliente: " + AllTrim(TMPAG->C6_PEDCLI)
        cEmissaoPedido := "Emissao Pedido: " + DTOC(STOD(TMPAG->C5_EMISSAO))
        cEmissaoNota   := "Emissao Nota: " + DTOC(STOD(TMPAG->F2_EMISSAO))
        cDtEntrega     := "Dt Entrega: " + DTOC(STOD(TMPAG->C5_FECENT))
        cDtEmbarq      := "Dt Embarque: " + DTOC(GetNFData(AllTrim(TMPAG->F2_CHVNFE)))
        cCodTransp     := "Cod. Transp.: " + AllTrim(TMPAG->F2_TRANSP)
        cRSTransp      := "Razao Social Transp.: " + AllTrim(Posicione("SA4", 1, xFilial("SA4") + AllTrim(TMPAG->F2_TRANSP), "A4_NOME"))

        oDlg:Refresh()
    Else
        MsgAlert("Dados não encontrados. Verifique cliente, loja e nota fiscal.")
    EndIf

    IncProc()
    TMPAG->(DbCloseArea())

Return

/*/{Protheus.doc}  GrvAgenda

GrvAgenda
Grava registro de agendamento na nota fiscal

@author 	Marcos Natã Santos
@since		05/12/2018
@version 	12.1.17
@type 		function
/*/
Static Function GrvAgenda(cChaveNfe,dDtAgenda,cHrAgenda)
    Local aAreaSZS        := SZS->(GetArea())
    Local aAreaSZT        := SZT->(GetArea())
    Local aAreaSF2        := SF2->(GetArea())
    Local aCliData        := {}
    Local cRemetente      := "05207076000297"
    Local cRemRazaoSocial := "EIC DO BRASIL INDUSTRIA E COMERCIO DE ALIMENTOS S.A."
    Local dDtEmbarq

    Default cChaveNfe := ""
    Default dDtAgenda := Date()
    Default cHrAgenda := "00:00:00"

    SF2->( dbSetOrder(17) ) //-- F2_CHVNFE
    SF2->( dbGoTop() )
    If SF2->( dbSeek( xFilial("SF2") + cChaveNfe ) )

        SZS->( dbSetOrder(1) ) //-- ZS_CHAVENF
        SZT->( dbSetOrder(2) ) //-- ZT_CHAVENF + ZT_OCORREN
        SZS->( dbGoTop() )
        SZT->( dbGoTop() )
        If .Not. SZS->(dbSeek( xFilial("SZS") + SF2->F2_CHVNFE ))
            aCliData  := GetCliData(SF2->F2_DOC, SF2->F2_SERIE)
            dDtEmbarq := GetNFData(SF2->F2_CHVNFE)
            RecLock("SZS", .T.)
            SZS->ZS_FILIAL  := xFilial("SZS")
            SZS->ZS_REMETEN := cRemetente
            SZS->ZS_RMTTRS  := cRemRazaoSocial
            SZS->ZS_NUMNF   := SF2->F2_DOC
            SZS->ZS_SERIE   := SF2->F2_SERIE
            SZS->ZS_CHAVENF := SF2->F2_CHVNFE
            SZS->ZS_EMISSAO := SF2->F2_EMISSAO
            If Len(aCliData) > 0
                SZS->ZS_PEDIDO  := aCliData[1]
                SZS->ZS_CLILOJ  := AllTrim(aCliData[2] + aCliData[3])
                SZS->ZS_CLINOME := aCliData[4]
                SZS->ZS_PEDCLI  := aCliData[5]
                SZS->ZS_ENTREG  := aCliData[6]
            EndIf
            If !Empty(dDtEmbarq)
                SZS->ZS_EMBARQ := dDtEmbarq
            EndIf
            SZS->ZS_STATUS  := "0" //-- Entrega Em Processo
            SZS->( MsUnlock() )
            RecLock("SZT", .T.)
            SZT->ZT_FILIAL  := xFilial("SZT")
            If cComboBo1 == "Agenda"
                SZT->ZT_OCORREN := "AGENDA"
                SZT->ZT_CODIGO  := "AG"
                If cComboBo2 == "Sim"
                    SZT->ZT_DESCRI  := "AGENDA DE ENTREGA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda + " (FORA LEAD TIME)"
                Else
                    SZT->ZT_DESCRI  := "AGENDA DE ENTREGA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda
                EndIf
            Else
                SZT->ZT_OCORREN := "SOLAGD"
                SZT->ZT_CODIGO  := "SA"
                SZT->ZT_DESCRI  := "SOLICITAÇÃO DE AGENDA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda
            EndIf
            SZT->ZT_AGNDATA := dDtAgenda
            SZT->ZT_AGNHORA := SubStr(cHrAgenda,1,5)
            SZT->ZT_TRANSPO := AllTrim(Posicione("SA4", 1, xFilial("SA4") + SF2->F2_TRANSP, "A4_CGC"))
            SZT->ZT_TRANSRS := AllTrim(Posicione("SA4", 1, xFilial("SA4") + SF2->F2_TRANSP, "A4_NOME"))
            SZT->ZT_OCORDAT := Date()
            SZT->ZT_OCORHR  := SubStr(Time(),1,5)
            SZT->ZT_SOLUDAT := Date()
            SZT->ZT_SOLUHR  := SubStr(Time(),1,5)
            SZT->ZT_SOLURSP := Upper(UsrFullName(RetCodUsr()))
            SZT->ZT_CHAVENF := SF2->F2_CHVNFE
            SZT->( MsUnlock() )
        Else
            If SZS->ZS_STATUS == "0"
                RecLock("SZT", .T.)
                SZT->ZT_FILIAL  := xFilial("SZT")
                If cComboBo1 == "Agenda"
                    SZT->ZT_OCORREN := "AGENDA"
                    SZT->ZT_CODIGO  := "AG"
                    If cComboBo2 == "Sim"
                        SZT->ZT_DESCRI  := "AGENDA DE ENTREGA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda + " (FORA LEAD TIME)"
                    Else
                        SZT->ZT_DESCRI  := "AGENDA DE ENTREGA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda
                    EndIf
                Else
                    SZT->ZT_OCORREN := "SOLAGD"
                    SZT->ZT_CODIGO  := "SA"
                    SZT->ZT_DESCRI  := "SOLICITAÇÃO DE AGENDA -> " + DTOC(dDtAgenda) + " - " + cHrAgenda
                EndIf
                SZT->ZT_AGNDATA := dDtAgenda
                SZT->ZT_AGNHORA := SubStr(cHrAgenda,1,5)
                SZT->ZT_TRANSPO := AllTrim(Posicione("SA4", 1, xFilial("SA4") + SF2->F2_TRANSP, "A4_CGC"))
                SZT->ZT_TRANSRS := AllTrim(Posicione("SA4", 1, xFilial("SA4") + SF2->F2_TRANSP, "A4_NOME"))
                SZT->ZT_OCORDAT := Date()
                SZT->ZT_OCORHR  := SubStr(Time(),1,5)
                SZT->ZT_SOLUDAT := Date()
                SZT->ZT_SOLUHR  := SubStr(Time(),1,5)
                SZT->ZT_SOLURSP := Upper(UsrFullName(RetCodUsr()))
                SZT->ZT_CHAVENF := SF2->F2_CHVNFE
                SZT->( MsUnlock() )
            Else
                MsgAlert("Agendamento não permitido. Nota fiscal com entrega finalizada.")
                RestArea(aAreaSZS)
                RestArea(aAreaSZT)
                RestArea(aAreaSF2)
                Return
            EndIf
        EndIf

        If cComboBo1 == "Agenda"
            MsgInfo("Agendamento realizado com sucesso.")
        Else
            MsgInfo("Solicitação de agenda realizada com sucesso.")
        EndIf
    
    Else
        MsgInfo("Erro ao processar agendamento. Entrar em contato com setor de tecnologia.")
    EndIf

    RestArea(aAreaSZS)
    RestArea(aAreaSZT)
    RestArea(aAreaSF2)

Return

/*/{Protheus.doc} GetNFData

Busca dados da Nota Fiscal Frete Brasil
Busca data de embarque

@author 	Marcos Natã Santos
@since		12/02/2019
@version 	12.1.17
@type 		function
/*/
Static Function GetNFData(cDocNum)
    Local oWSDL
    Local lOk
    Local cResp
    Local oXML
    Local xRet
    Local nQtdReg        := 0
    Local nX             := 0
    Local cWSDL          := SuperGetMV("MV_XFBWSDL", .F., "https://wsfretebrasil.activecorp.com.br/WSACTIVE/Service.svc?wsdl")
    Local cXMLRoot       := "/s:Envelope/s:Body/*/*/*/*/NotaFiscalConsulta"
    Local cXMLFailPath   := "/s:Envelope/s:Body/*/*/*/*/RetornoGenerico"
    Local dDtEmbarq      := STOD(Space(8))

    Local cEmbarcCnpj  := "05207076000297"
	Local cIntegraTipo := "4" //-- Nota Fiscal
	Local cRetrans     := "N"

    Default cDocNum    := ""

    oWSDL := TWSDLManager():New()
    oXML  := TXmlManager():New()

    oWSDL:lVerbose := .T.
    
    //-- Certificado deve estar na pasta protheus_data --//
    oWSDL:cSSLCACertFile := "\certificado\FreteBrasil\CA_FreteBrasil.pem"

    //-- WSDL do ambiente producao Frete Brasil --//
    lOk := oWSDL:ParseURL( cWSDL )
    If !lOk
        Return dDtEmbarq
    EndIf

    lOk := oWSDL:SetOperation( "ConsultaDocumento" )
    If !lOk
        Return dDtEmbarq
    EndIf

    oWSDL:SetFirst("token", FB_TOKEN)
    oWSDL:SetFirst("embarc_cnpj", cEmbarcCnpj)
    oWSDL:SetFirst("integracao_tipo", cIntegraTipo)
    oWSDL:SetFirst("documento_numero", cDocNum)
    oWSDL:SetFirst("retransmitir", cRetrans)
    oWSDL:SetFirst("pagina", "1")

    lOk := oWSDL:SendSoapMsg()
    If !lOk
        Sleep( 5100 ) //-- Espera 5 segundos para nova requisicao
        lOk := oWSDL:SendSoapMsg()
        If !lOk
            Return dDtEmbarq
        EndIf
    EndIf

    //----------------------------------------------------------//
    //-- maxStringSize=10 no appserver.ini                    --//
    //-- para conseguir receber a resposta completa do server --//
    //----------------------------------------------------------//
    cResp := oWSDL:GetSoapResponse()
    xRet := oXML:Parse( cResp )
    If xRet == .F.
        Return dDtEmbarq
    EndIf

    lOk := oXML:XPathRegisterNs( "s", "http://schemas.xmlsoap.org/soap/envelope/" )
    If !lOk
        Return dDtEmbarq
    EndIf

    If !Empty( AllTrim(oXML:XPathGetNodeValue( cXMLFailPath )) )
        cRetrans := "S"
        oWSDL:SetFirst("retransmitir", cRetrans)

        lOk := oWSDL:SendSoapMsg()
        If !lOk
            Sleep( 5100 ) //-- Espera 5 segundos para nova requisicao --//
            lOk := oWSDL:SendSoapMsg()
            If !lOk
                Return dDtEmbarq
            EndIf
        EndIf

        //-- maxStringSize=10 no appserver.ini --//
        cResp := oWSDL:GetSoapResponse()
        lOk := oXML:Parse( cResp )
        If !lOk
            Return dDtEmbarq
        EndIf

        lOk := oXML:XPathRegisterNs( "s", "http://schemas.xmlsoap.org/soap/envelope/" )
        If !lOk
            Return dDtEmbarq
        EndIf
    EndIf

    nQtdReg := oXML:XPathChildCount( cXMLRoot )

    For nX := 1 To nQtdReg
        dDtEmbarq := CTOD( oXML:XPathGetNodeValue( cXMLRoot + "/NOTAFISCAL["+ cValToChar(nX) +"]/TRANSPORTE/EMBARQUE" ) )
    Next nX

Return dDtEmbarq

/*/{Protheus.doc} LA05SYNC

Schedule Sincronização de Ocorrências

@author 	Marcos Natã Santos
@since		10/05/2019
@version 	12.1.17
@type 		function
/*/
User Function LA05SYNC() //-- U_LA05SYNC
    Local cRemetente

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0102" MODULO "FAT"

        ConOut("Início LA05SYNC - " + DTOC(Date()) + " - " + Time())

        cRemetente := "05207076000297"

        SyncData(cRemetente, .T.)

        ConOut("Fim LA05SYNC - " + DTOC(Date()) + " - " + Time())
    
    RESET ENVIRONMENT

Return

/*/{Protheus.doc} BscOcorrNF

Busca ocorrências para nf imformada

@author 	Marcos Natã Santos
@since		09/05/2019
@version 	12.1.17
/*/
Static Function BscOcorrNF()
    Local lOk        := .F.
    Local oBuscar
    Local oGet1
    Local cGet1      := Space(9)
    Local oGroup1
    Local oSay1
    Local cChaveNfe
    Local cRemetente := "05207076000297"

    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Buscar Ocorrências NF" FROM 000, 000  TO 150, 400 COLORS 0, 16777215 PIXEL

        @ 008, 015 GROUP oGroup1 TO 033, 185 PROMPT "Nota Fiscal" OF oDlg COLOR 0, 16777215 PIXEL
        @ 019, 017 SAY oSay1 PROMPT "Informe a nota fiscal para buscar as ocorrências no Frete Brasil." SIZE 162, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 050, 030 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SF2" PIXEL
        @ 050, 105 BUTTON oBuscar PROMPT "Buscar" SIZE 060, 012 OF oDlg ACTION {|| lOk:=.T., oDlg:End() } PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOk .And. !Empty(AllTrim(cGet1))
        cChaveNfe := AllTrim( Posicione("SF2", 1, xFilial("SF2") + AllTrim(cGet1), "F2_CHVNFE") )

        If !Empty(cChaveNfe)
            Processa({|| SyncNota(cRemetente, cChaveNfe)}, "Sincronizando NF", "Buscando ocorrências...")
        EndIf
    EndIf

Return

/*/{Protheus.doc} FBEmbarq

Busca notas sem data de embarque/coleta

@author 	Marcos Natã Santos
@since		23/05/2019
@version 	12.1.17
/*/
User Function FBEmbarq //-- U_FBEmbarq
    Local cQry      := ""
    Local nQtdReg   := 0
    Local dDtEmbarq := Space(8)
    Local cDtFiltro := DTOS( FirstDate( MonthSub(Date(),2) ) )

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0102" MODULO "FAT"

        ConOut("Início FBEmbarq - " + DTOC(Date()) + " - " + Time())

        cQry := "SELECT SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CHVNFE, SF2.F2_TRANSP " + CRLF
        cQry += "FROM "+ RetSqlName("SF2") +" SF2 " + CRLF
        cQry += "LEFT JOIN "+ RetSqlName("SZS") +" SZS " + CRLF
        cQry += "    ON SZS.D_E_L_E_T_ <> '*' " + CRLF
        cQry += "    AND SZS.ZS_CHAVENF = SF2.F2_CHVNFE " + CRLF
        cQry += "WHERE SF2.D_E_L_E_T_ <> '*' " + CRLF
        cQry += "    AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"' " + CRLF
        cQry += "    AND SF2.F2_EMISSAO >= '"+ cDtFiltro +"' " + CRLF
        cQry += "    AND SF2.F2_CLIENTE <> '000001' " + CRLF
        cQry += "    AND SF2.F2_TIPO = 'N' " + CRLF
        cQry += "    AND (SELECT E1_NATUREZ FROM SE1010 " + CRLF
        cQry += "        WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "        AND E1_FILIAL = '"+ xFilial("SE1") +"' " + CRLF
        cQry += "        AND E1_NUM = SF2.F2_DUPL " + CRLF
        cQry += "        AND E1_NATUREZ = '101010001' " + CRLF
        cQry += "        AND ROWNUM = 1) = '101010001' " + CRLF //-- Vendas --//
        cQry += "   AND (SZS.ZS_EMBARQ = ' ' OR SZS.ZS_CHAVENF IS NULL) " + CRLF
        cQry += "ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC " + CRLF

        If Select("FBEMBARQ") > 0
            FBEMBARQ->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "FBEMBARQ"

        FBEMBARQ->(dbGoTop())
        COUNT TO nQtdReg
        FBEMBARQ->(dbGoTop())

        If nQtdReg > 0
            While FBEMBARQ->( !EOF() )
                dDtEmbarq := GetNFData(FBEMBARQ->F2_CHVNFE)
                If !Empty(dDtEmbarq)
                    GravEmbarq(STOD(FBEMBARQ->F2_EMISSAO), FBEMBARQ->F2_DOC, FBEMBARQ->F2_SERIE, FBEMBARQ->F2_CHVNFE, dDtEmbarq, FBEMBARQ->F2_TRANSP)
                EndIf
                FBEMBARQ->( dbSkip() )
            EndDo
        EndIf

        FBEMBARQ->(DbCloseArea())

        ConOut("Fim FBEmbarq - " + DTOC(Date()) + " - " + Time())

    RESET ENVIRONMENT
Return

/*/{Protheus.doc} GravEmbarq

Grava ocorrência de embarque/coleta

@author 	Marcos Natã Santos
@since		23/05/2019
@version 	12.1.17
/*/
Static Function GravEmbarq(dEmissao, cDoc, cSerie, cChaveNfe, dDtEmbarq, cCodTransp)
    Local aAreaSZS        := SZS->(GetArea())
    Local aAreaSZT        := SZT->(GetArea())
    Local aCliData        := {}
    Local cRemetente      := "05207076000297"
    Local cRemRazaoSocial := "EIC DO BRASIL INDUSTRIA E COMERCIO DE ALIMENTOS S.A."

    Default dEmissao   := Space(8)
    Default cDoc       := ""
    Default cSerie     := ""
    Default cChaveNfe  := ""
    Default dDtEmbarq  := Space(8)
    Default cCodTransp := ""

    SZS->( dbSetOrder(1) ) //-- ZS_CHAVENF
    SZT->( dbSetOrder(2) ) //-- ZT_CHAVENF + ZT_OCORREN
    SZS->( dbGoTop() )
    SZT->( dbGoTop() )
    If .Not. SZS->(dbSeek( xFilial("SZS") + cChaveNfe ))
        aCliData  := GetCliData(cDoc, cSerie)

        RecLock("SZS", .T.)
        SZS->ZS_FILIAL  := xFilial("SZS")
        SZS->ZS_REMETEN := cRemetente
        SZS->ZS_RMTTRS  := cRemRazaoSocial
        SZS->ZS_NUMNF   := cDoc
        SZS->ZS_SERIE   := cSerie
        SZS->ZS_CHAVENF := cChaveNfe
        SZS->ZS_EMISSAO := dEmissao
        If Len(aCliData) > 0
            SZS->ZS_PEDIDO  := aCliData[1]
            SZS->ZS_CLILOJ  := AllTrim(aCliData[2] + aCliData[3])
            SZS->ZS_CLINOME := aCliData[4]
            SZS->ZS_PEDCLI  := aCliData[5]
            SZS->ZS_ENTREG  := aCliData[6]
        EndIf
        SZS->ZS_EMBARQ := dDtEmbarq
        SZS->ZS_STATUS  := "0" //-- Entrega Em Processo
        SZS->( MsUnlock() )

        RecLock("SZT", .T.)
        SZT->ZT_FILIAL  := xFilial("SZT")
        SZT->ZT_OCORREN := "EMBARQ"
        SZT->ZT_CODIGO  := "EB"
        SZT->ZT_DESCRI  := "EMBARQUE/COLETA -> " + DTOC(dDtEmbarq)
        SZT->ZT_TRANSPO := AllTrim(Posicione("SA4", 1, xFilial("SA4") + cCodTransp, "A4_CGC"))
        SZT->ZT_TRANSRS := AllTrim(Posicione("SA4", 1, xFilial("SA4") + cCodTransp, "A4_NOME"))
        SZT->ZT_OCORDAT := dDtEmbarq
        SZT->ZT_OCORHR  := "00:00"
        SZT->ZT_SOLUDAT := Date()
        SZT->ZT_SOLUHR  := SubStr(Time(),1,5)
        // SZT->ZT_SOLURSP := Upper(UsrFullName(RetCodUsr()))
        SZT->ZT_SOLURSP := Upper("JOB PROTHEUS")
        SZT->ZT_CHAVENF := cChaveNfe
        SZT->( MsUnlock() )
    Else
        RecLock("SZS", .F.)
        SZS->ZS_EMBARQ := dDtEmbarq
        SZT->( MsUnlock() )

        RecLock("SZT", .T.)
        SZT->ZT_FILIAL  := xFilial("SZT")
        SZT->ZT_OCORREN := "EMBARQ"
        SZT->ZT_CODIGO  := "EB"
        SZT->ZT_DESCRI  := "EMBARQUE/COLETA -> " + DTOC(dDtEmbarq)
        SZT->ZT_TRANSPO := AllTrim(Posicione("SA4", 1, xFilial("SA4") + cCodTransp, "A4_CGC"))
        SZT->ZT_TRANSRS := AllTrim(Posicione("SA4", 1, xFilial("SA4") + cCodTransp, "A4_NOME"))
        SZT->ZT_OCORDAT := dDtEmbarq
        SZT->ZT_OCORHR  := "00:00"
        SZT->ZT_SOLUDAT := Date()
        SZT->ZT_SOLUHR  := SubStr(Time(),1,5)
        // SZT->ZT_SOLURSP := Upper(UsrFullName(RetCodUsr()))
        SZT->ZT_SOLURSP := Upper("JOB PROTHEUS")
        SZT->ZT_CHAVENF := cChaveNfe
        SZT->( MsUnlock() )
    EndIf

    RestArea(aAreaSZS)
    RestArea(aAreaSZT)
Return

/*/{Protheus.doc} FormatWsDate
Formata data para string
@type  Static Function
@author Marcos Natã Santos
@since 08/07/2019
@version 12.1.17
@param dData, Date, Uma data
@return cData, Date, Data formatada
/*/
Static Function FormatWsDate(dData)
    Local cData := Space(8)

    cData := DTOS(dData)
    cData := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)

Return cData

/*/{Protheus.doc} SyncAllToItem
Sincroniza as ocorrências nota a nota
@type  Static Function
@author Marcos Natã Santos
@since 08/07/2019
@version 12.1.17
@param dEmissao, Date, Emissao da nota
/*/
Static Function SyncAllToItem(dEmissao)
    Local cRemetente := "05207076000297"
    Local cQry       := ""
    Local nQtdReg    := 0

    cQry := "SELECT ZS_CHAVENF " + CRLF
    cQry += "FROM " + RetSqlName("SZS") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND ZS_FILIAL = '"+ xFilial("SZS") +"' " + CRLF
    cQry += "AND ZS_STATUS = '0' " + CRLF //-- Entrega Em Processo
    cQry += "AND ZS_EMISSAO >= '"+ DTOS(dEmissao) +"' " + CRLF

    If Select("SYNCALL") > 0
        SYNCALL->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "SYNCALL"

    SYNCALL->(dbGoTop())
    COUNT TO nQtdReg
    SYNCALL->(dbGoTop())

    If nQtdReg > 0
        While SYNCALL->( !EOF() )
            SyncNota(cRemetente, AllTrim(SYNCALL->ZS_CHAVENF))
            SYNCALL->( dbSkip() )
        EndDo
    EndIf

    SYNCALL->(DbCloseArea())
Return

/*/{Protheus.doc} SYNC2P
Sincroniza notas fiscais pendentes no GoBetech (GOBE_TOTIF)
@type User Function
@author Marcos Natã Santos
@since 02/10/2019
@version 1.0
/*/
User Function SYNC2P() //-- U_SYNC2P
    Local cRemetente := "05207076000297"
    Local cQry       := ""
    Local nQtdReg    := 0
    Local cChaveNfe  := ""

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0102" MODULO "FAT"

        cQry := "SELECT NOTA_NF, " + CRLF
        cQry += "    PEDIDO_PED, " + CRLF
        cQry += "    REPLACE(VALOR_NF,'.',',') VALOR_NF, " + CRLF
        cQry += "    DTINCLUSAO_PED, " + CRLF
        cQry += "    DTENTREGA_PED, " + CRLF
        cQry += "    DTENTREGA_MAIS_LEAD_PED, " + CRLF
        cQry += "    DTENTREGA_REAL " + CRLF
        cQry += "FROM USR_X3AFMZH.GOBE_TOTIF " + CRLF
        cQry += "WHERE DTENTREGA_REAL IS NULL " + CRLF
        cQry += "    AND NOTA_NF IS NOT NULL " + CRLF
        cQry += "    AND LOCAL = '90' " + CRLF
        cQry += "ORDER BY DTINCLUSAO_PED " + CRLF
        cQry := ChangeQuery(cQry)

        If Select("SYNC2P") > 0
            SYNC2P->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "SYNC2P"

        SYNC2P->(dbGoTop())
        COUNT TO nQtdReg
        SYNC2P->(dbGoTop())

        If nQtdReg > 0
            While SYNC2P->( !EOF() )
                cChaveNfe := ""
                cChaveNfe := AllTrim( Posicione("SF2", 1, xFilial("SF2") + AllTrim(SYNC2P->NOTA_NF), "F2_CHVNFE") )
                SyncNota(cRemetente, cChaveNfe)
                SYNC2P->( dbSkip() )
            EndDo
        EndIf

        SYNC2P->(DbCloseArea())

    RESET ENVIRONMENT
Return
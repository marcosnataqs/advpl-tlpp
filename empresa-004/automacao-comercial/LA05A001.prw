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

/*/{Protheus.doc} LA05A001

Browse para Automação do Pedido de Venda

@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	oBrowse
@Obs 		Marcos Natã Santos - Construção
/*/
User Function LA05A001()

	Local oBrowse 		:= Nil
	Local nX			:= 0
	Local lAdm          := .F.
	Local aUserGrp      := UsrRetGrp()
	Local cMVCoServ	    := AllTrim(GetMV("MV_XCOSERV"))
	Local cMVStat3      := AllTrim(GetMV("MV_XSTAT3"))

	Private cTitulo		:= OemtoAnsi("Pedidos de Venda")
	Private lLiberado	:= .T.
	Private lParcial	:= .F.
	Private aRegPed		:= {}
	Private cVend		:= Posicione("SA3",7,xFilial("SA3")+RetCodUsr(),"A3_COD")
	Private cCondPag    := "001"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZL")
	oBrowse:AddLegend("ZL_STATUS == '0' ","BR_PINK"			,"EDI - Divergência de Preços")
	oBrowse:AddLegend("ZL_STATUS == '1' ","BR_BRANCO"		,"Faturamento Programado")
	oBrowse:AddLegend("ZL_STATUS == '2' ","BR_LARANJA"		,"Bloqueio - Prazo Adicional")
	oBrowse:AddLegend("ZL_STATUS == '3' .AND. ZL_REJEITA == 'S' ","BR_AZUL_CLARO"	,"Rejeitado - Regra de Negócio")
	oBrowse:AddLegend("ZL_STATUS == '3' ","BR_AZUL"			,"Bloqueio - Regra de Negócio")
	oBrowse:AddLegend("ZL_STATUS == '4' ","BR_VIOLETA"		,"Bloqueio - Limite de Crédito")
	oBrowse:AddLegend("ZL_STATUS == '5' .AND. ZL_PEDMIN == 'S' ","BR_MARROM_OCEAN" ,"Bloqueio - Pedido Abaixo Mínimo")
	oBrowse:AddLegend("ZL_STATUS == '5' ","BR_PRETO"		,"Bloqueio - Saldos em Estoque")
	oBrowse:AddLegend("ZL_STATUS == '6' ","BR_AMARELO"		,"Liberaçao - Liberado Parcialmente")
	oBrowse:AddLegend("ZL_STATUS == '7' .AND. ZL_FATNF == 'N' ","BR_VERDE_ESCURO"	,"Faturamento Pendente")
	oBrowse:AddLegend("ZL_STATUS == '7' ","BR_VERMELHO"		,"Liberação - Liberado Totalmente")
	oBrowse:AddLegend("ZL_STATUS == '8' ","BR_CANCEL"		,"Erro - Pedido não Integrado")
	oBrowse:AddLegend("ZL_STATUS == '9' ","BR_MARRON"		,"Fracionamento de Carga")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A001")
	For nX:= 1 to Len(aUserGrp)
		If aUserGrp[nX] == "000000"
			lAdm := .T.
		EndIf 
	Next nX
	For nX:= 1 to Len(aUserGrp)
		If .Not. aUserGrp[nX] $ cMVCoServ .And. .Not. lAdm //-- Visão de administrator (Controladoria)
			If aUserGrp[nX] $ cMVStat3 //-- Visualiza bonificação (Controladoria)
				oBrowse:SetFilterDefault("ZL_TPVEND = '2'")
			Else //-- Visualiza apenas seus pedidos
				oBrowse:SetFilterDefault("ZL_VEND = '"+ cVend +"'")
			EndIf
		EndIf
	Next nX
	oBrowse:Activate()
	
Return oBrowse

/*/{Protheus.doc} ModelDef

Modelo de Dados do Pedido de Venda

@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	oModel
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ModelDef()
	Local n
	Local oModel	:= Nil
	Local oStrSZL	:= Nil
	Local oStrPRD	:= Nil
	Local oStrITM	:= Nil
	Local oStrPSQ	:= Nil

	Local aCampos		:= Nil
	Private cCamposSZL	:= ""	
	Private cCamposSZM	:= ""	
	Private cCamposTMP	:= "ZM_SALDO;ZM_DESCRI;ZM_PRODUTO"
	Private cCamposPSQ	:= "ZL_PESQ"

	DbSelectArea("SZL")
	
	aCampos := SZL->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZL += aCampos[n][1]
		cCamposSZL += iif((n) < Len(aCampos),";","")
	Next

	DbSelectArea("SZM")
	
	aCampos	:= Nil
	aCampos := SZM->(DBSTRUCT())
	
	For n := 1 To Len(aCampos)
		cCamposSZM += aCampos[n][1]
		cCamposSZM += iif((n) < Len(aCampos),";","")
	Next
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("LA051MOD",{|| .T.},{|oModel| PosValida(oModel)},{|oModel| GravaDados( oModel )}) 
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZL := FWFormStruct(1,"SZL",{|cCampo| ( Alltrim(cCampo) $ cCamposSZL )})
	oStrPSQ := FWFormStruct(1,"SZL",{|cCampo| ( Alltrim(cCampo) $ cCamposPSQ )})
	oStrPRD := FWFormStruct(1,"SZM",{|cCampo| ( Alltrim(cCampo) $ cCamposTMP )})
	oStrITM := FWFormStruct(1,"SZM",{|cCampo| ( Alltrim(cCampo) $ cCamposSZM )})
		
	// Funcao que executa o gatilho de preenchimento da descricao dos campos
	oStrSZL:AddTrigger("ZL_CONDPAD","ZL_DESCOND",{ || .T. },{|| oModel := FwModelActive(),;
	AllTrim(Posicione("SE4",1,xFilial("SE4")+oModel:GetModel("M_SZL"):GetValue("ZL_CONDPAD"),"E4_DESCRI"))})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_MENPAD",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_MENSAGE")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_NOMECLI",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_NOME")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_VEND",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_VEND")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_CONDPAD",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_COND")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_MODALID",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_XMODALI")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_SEGMENT",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_XSEGMEN")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_REGNL",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_XREGNL")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_CANAL",{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_XCANAL")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_DATENTR",{ || .T. },{|| oModel := FwModelActive(),;
	SugEntrega(oModel)})

	oStrSZL:AddTrigger("ZL_PEDCLI","ZL_MENNOTA",{ || .T. },{|| oModel := FwModelActive(),;
	"PED CLIENTE " + oModel:GetValue("M_SZL","ZL_PEDCLI")})

	oStrSZL:AddTrigger("ZL_LOJA","ZL_FATCPLT",{ || .T. },{|| oModel := FwModelActive(),;
	IIF(AllTrim(Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"),6);
	+oModel:GetModel("M_SZL"):GetValue("ZL_LOJA"),"A1_XPENDC")) == "2", .T., .F.) })

	oStrITM:AddTrigger("ZM_PRODUTO","ZM_DESCRI" ,{ || .T. },{|| oModel := FwModelActive(),;
	Posicione("SB1",1,xFilial("SB1")+oModel:GetModel("M_ITM"):GetValue("ZM_PRODUTO"),"B1_DESC")})

	oStrITM:AddTrigger("ZM_QTD","ZM_TOTAL" ,{ || .T. },{|| oModel := FwModelActive(),;
	oModel:GetModel("M_ITM"):GetValue("ZM_QTD") * oModel:GetModel("M_ITM"):GetValue("ZM_VALOR")})

	oStrITM:AddTrigger("ZM_VALOR","ZM_TOTAL" ,{ || .T. },{|| oModel := FwModelActive(),;
	oModel:GetModel("M_ITM"):GetValue("ZM_QTD") * oModel:GetModel("M_ITM"):GetValue("ZM_VALOR")})

	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZL",/*cOwner*/,oStrSZL, { |oModelSZL,cAction,cField| PreValida(oModelSZL,cAction,cField) })
	oModel:AddFields("M_PSQ","M_SZL",oStrPSQ)
	
	oModel:AddGrid("M_PRD","M_SZL",oStrPRD)
	oModel:SetRelation("M_PRD",;
	{{"ZM_FILIAL","xFilial('SZM')"},;
	{"ZM_NUM","ZL_NUM"},;
	{"ZM_CLIENTE","ZL_CLIENTE"},;
	{"ZM_LOJA","ZL_LOJA"}},;
	SZM->(IndexKey(1)))// Faz relacionamento entre os componentes do model 
	
	oModel:AddGrid("M_ITM","M_SZL",oStrITM)
	oModel:SetRelation("M_ITM",;
	{{"ZM_FILIAL","xFilial('SZM')"},;
	{"ZM_NUM","ZL_NUM"},;
	{"ZM_CLIENTE","ZL_CLIENTE"},;
	{"ZM_LOJA","ZL_LOJA"}},;
	SZM->(IndexKey(1)))// Faz relacionamento entre os componentes do model 

	// Totalizador do Pedido
	oModel:AddCalc( 'LA051CALC', 'M_SZL', 'M_ITM', 'ZM_TOTAL', 'ZM_TOT', 'SUM',/*bCond*/,/*bInitValue*/,'Total do Pedido' )

	 // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZL_FILIAL","ZL_NUM","ZL_CLIENTE","ZL_LOJA"})
	
	oModel:GetModel("M_PRD"):SetOnlyQuery(.T.)
	oModel:GetModel("M_PSQ"):SetOnlyQuery(.T.)
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_SZL"):SetDescription(OemToAnsi("Pedido de Vendas"))
	oModel:GetModel("M_PSQ"):SetDescription(OemToAnsi("Pesquisar"))
	oModel:GetModel("M_PRD"):SetDescription(OemToAnsi("Produtos"))
	oModel:GetModel("M_ITM"):SetDescription(OemToAnsi("Itens do Pedido"))
	
	// Coloco uma regra para nao duplicar os itens contabeis na inclusao	
	oModel:GetModel("M_ITM"):SetUniqueLine({"ZM_PRODUTO"})
	
	// Seto o Conteudo no campo para colocar o registro inicialmente como Ativo
	oStrSZL:SetProperty("ZL_CLIENTE",MODEL_FIELD_WHEN	,{|| Iif(Inclui,.T.,.F.)})
	oStrSZL:SetProperty("ZL_LOJA"   ,MODEL_FIELD_WHEN	,{|| Iif(Inclui,.T.,.F.)})
	oStrSZL:SetProperty("ZL_FATCPLT",MODEL_FIELD_WHEN	,{|| .F.})
	oStrSZL:SetProperty("ZL_LOJA"   ,MODEL_FIELD_VALID	,{|| PreVLD(oModel,"M_SZL")})
	oStrSZL:SetProperty("ZL_TPVEND" ,MODEL_FIELD_VALID	,{|| AtuOper()})
	oStrSZL:SetProperty("ZL_PEDCLI" ,MODEL_FIELD_VALID	,{|| NumPedCli()})
	oStrPSQ:SetProperty("ZL_PESQ"	,MODEL_FIELD_VALID	,{|| PreVLD(oModel,"M_PSQ")})
	oStrITM:SetProperty("ZM_VALOR"	,MODEL_FIELD_VALID	,{|| GatPerDesc()})
	oStrITM:SetProperty("ZM_QTD"	,MODEL_FIELD_VALID	,{|| GatPerDesc()})

	// Não pode incluir linhas nos itens
	oModel:GetModel("M_ITM"):SetNoInsertLine(.T.)

	oModel:GetModel("M_PRD"):SetNoInsertLine(.T.)
	oModel:GetModel("M_PRD"):SetNoDeleteLine(.T.)

Return oModel

/*/{Protheus.doc} ViewDef

Funcao que cria a tela de visualização do modelo de dados do Pedido de Venda.

@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	oView
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ViewDef()
	Local n
	Local oView			:= Nil
	Local oModel		:= FWLoadModel("LA05A001")
	Local oStrSZL		:= Nil
	Local oStrPRD		:= Nil
	Local oStrITM		:= Nil
	Local oStrPSQ		:= Nil
	Local oCalc			:= Nil
	Local nX            := 0
	Local lAdm          := .F.
	Local aUserGrp      := UsrRetGrp()
	Local cMVCoServ	    := AllTrim(GetMV("MV_XCOSERV"))

	Local aCampos		:= Nil
	Local cCamposSZL	:= ""	
	Local cCamposSZM	:= ""	
	Local cCamposTMP	:= "ZM_SALDO;ZM_DESCRI;ZM_PRODUTO"
	Local cCamposPSQ	:= "ZL_PESQ"

	DbSelectArea("SZL")
	
	aCampos := SZL->(DBSTRUCT())
	
	For n := 2 To Len(aCampos)
		cCamposSZL += aCampos[n][1]
		cCamposSZL += iif((n) < Len(aCampos),";","")
	Next

	DbSelectArea("SZM")
	
	aCampos	:= Nil
	aCampos := SZM->(DBSTRUCT())
	
	For n := 1 To Len(aCampos)
		cCamposSZM += aCampos[n][1]
		cCamposSZM += iif((n) < Len(aCampos),";","")
	Next
																																				
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZL := FWFormStruct(2,"SZL",{|cCampo| ( Alltrim(cCampo) $ cCamposSZL )})
	oStrPSQ := FWFormStruct(2,"SZL",{|cCampo| ( Alltrim(cCampo) $ cCamposPSQ )})
	oStrPRD := FWFormStruct(2,"SZM",{|cCampo| ( Alltrim(cCampo) $ cCamposTMP )})
	oStrITM := FWFormStruct(2,"SZM",{|cCampo| ( Alltrim(cCampo) $ cCamposSZM )})

	oCalc := FWCalcStruct( oModel:GetModel( 'LA051CALC') )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZL",oStrSZL,"M_SZL")
	oView:AddField('V_PSQ',oStrPSQ,"M_PSQ")
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid("V_PRD",oStrPRD,"M_PRD")
	oView:AddGrid("V_ITM",oStrITM,"M_ITM")

	// Adiciona Totalizador
	oView:AddField( 'V_CALC', oCalc, 'LA051CALC' )

	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("V_SUP",25)
	oView:CreateHorizontalBox("V_MEI",13)
	oView:CreateHorizontalBox("V_INF",62)
	
	oView:CreateVerticalBox("V_PSQ",35,"V_MEI")
	oView:CreateVerticalBox("V_CALC",65,"V_MEI")
	oView:CreateVerticalBox("V_PRD",35,"V_INF")
 	oView:CreateVerticalBox("V_ITM",65,"V_INF")
 	
 	oStrPSQ:SetNoFolder()
	
	// Campos removidos da View
	oStrITM:RemoveField("ZM_SALDO")
	oStrSZL:RemoveField("ZL_MODALID")
	oStrSZL:RemoveField("ZL_SEGMENT")
	oStrSZL:RemoveField("ZL_REGNL")
	oStrSZL:RemoveField("ZL_CANAL")
	oStrSZL:RemoveField("ZL_STATUS")
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("V_SZL","V_SUP")
	oView:SetOwnerView("V_PSQ","V_PSQ")
	oView:SetOwnerView("V_CALC","V_CALC")
	oView:SetOwnerView("V_PRD","V_PRD")
	oView:SetOwnerView("V_ITM","V_ITM")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_PRD",OemtoAnsi("Produtos"))
	oView:EnableTitleView("V_ITM",OemtoAnsi("Itens do Pedido"))
	
	// Aplico o autoincremento no campo de itens da grid
	oView:AddIncrementField("V_ITM","ZM_ITEM")

	// Duplo clique para adicionar produtos a lista aos itens
	oView:SetViewProperty("V_PRD", "GRIDDOUBLECLICK", {{|| LA05A001A()}})

	For nX:= 1 to Len(aUserGrp)
		If aUserGrp[nX] == "000000"
			lAdm := .T.
		EndIf 
	Next nX
	For nX:= 1 to Len(aUserGrp)
		If .Not. aUserGrp[nX] $ cMVCoServ .And. .Not. lAdm
			oStrSZL:SetProperty("ZL_CLIENTE" , MVC_VIEW_LOOKUP, "A1VEND")
			oStrSZL:SetProperty("ZL_CONDPAD" , MVC_VIEW_LOOKUP, "SE4A")
		Else
			oStrSZL:SetProperty("ZL_CLIENTE" , MVC_VIEW_LOOKUP, "SA1")
			oStrSZL:SetProperty("ZL_CONDPAD" , MVC_VIEW_LOOKUP, "SE4")
		EndIf
	Next nX
	
Return oView

/*/{Protheus.doc} MenuDef

Funcao que cria o menu principal do Browse do Pedido de Venda.

@author 	Ricardo Tavares Ferreira
@since 		14/03/2018
@version 	12.1.17
@return 	aRotina
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function MenuDef()
	Local aRotina	:= {}
	Local aUserGrp  := UsrRetGrp()
	Local cMVCoServ	:= AllTrim(GetMV("MV_XCOSERV"))
	Local nX
	
	ADD OPTION aRotina Title "Visualizar"			ACTION "VIEWDEF.LA05A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Incluir" 				ACTION "VIEWDEF.LA05A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 				ACTION "U_LA051ALT()" 	  OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Imprimir" 			ACTION "U_LA05R001()" 	  OPERATION MODEL_OPERATION_IMPR		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 				ACTION "VIEWDEF.LA05A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
	ADD OPTION aRotina Title "Rastro"		    	ACTION 'U_LA05RAST()'     OPERATION MODEL_OPERATION_VIEW 		ACCESS 0
	ADD OPTION aRotina Title "Importar Pedidos"  	ACTION 'U_LA05A009()'     OPERATION MODEL_OPERATION_VIEW 		ACCESS 0

	For nX := 1 To Len(aUserGrp)
		If aUserGrp[nX] == "000000" .Or. aUserGrp[nX] $ cMVCoServ
			ADD OPTION aRotina Title "Importação NeoGrid"	ACTION 'U_LA05A005()'     OPERATION MODEL_OPERATION_VIEW 		ACCESS 0
			Exit
		EndIf 
	Next nX

Return aRotina

/*/{Protheus.doc} PreValida

Pré validação do modelo field M_SZL

@author 	Marcos Natã Santos
@since 		24/04/2019
@version 	12.1.17
@return 	Logico
/*/
Static Function PreValida(oModelSZL,cAction,cField)
	Local lRet 	:= .T.

	If cField == "ZL_CONDPAD" .And. cAction == "SETVALUE"
		If !Empty(oModelSZL:GetValue("ZL_CLIENTE")) .And. !Empty(oModelSZL:GetValue("ZL_LOJA"))
			cCondPag := "001/" + Posicione("SA1",1,xFilial("SA1")+PadR(oModelSZL:GetValue("ZL_CLIENTE"),6);
				+oModelSZL:GetValue("ZL_LOJA"),"A1_COND")
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PosValida

Funcao que realiza a pos validacao dos dados antes de aparecer a tela de inclusao ou alteracao dos dados a serem cadastrados.

@author 	Ricardo Tavares Ferreira
@since 		14/08/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function PosValida(oModel)
	
	Local lRet 			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oModelPSQ		:= oModel:GetModel("M_PSQ")
	Local oModelSZL     := oModel:GetModel("M_SZL")
	Local oModelITM		:= oModel:GetModel("M_ITM")
	Local oModelCalc	:= oModel:GetModel("LA051CALC")
	Local nVlrPedMin	:= VlrPedMin(oModel:GetValue("M_SZL","ZL_CLIENTE"), oModel:GetValue("M_SZL","ZL_LOJA"))
	Local cTabPrc		:= Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetValue("M_SZL","ZL_CLIENTE"),6)+oModel:GetValue("M_SZL","ZL_LOJA"),"A1_TABELA")
	Local cTabAtiva		:= Posicione("DA0",1,xFilial("DA0")+cTabPrc, "DA0_ATIVO")
	Local dTabDtAte		:= Posicione("DA0",1,xFilial("DA0")+cTabPrc, "DA0_DATATE")
	Local cTabHrAte		:= Posicione("DA0",1,xFilial("DA0")+cTabPrc, "DA0_HORATE")
	Local cGrpChoc      := GetMV("MV_XGRCHOC")
	Local cGrpOvo       := GetMV("MV_XGRPOVO")
	Local cGrpPntt      := GetMv("MV_XGRPNTT")
	Local cGrupo        := ""
	Local lComum		:= .F.
	Local lChoco		:= .F.
	Local lOvo          := .F.
	Local lPntt         := .F.
	Local nI			:= 0
	Local aSaveLines 	:= FWSaveRows()

	//--------------------------------------------------------//
	//-- Verifica horário para permitir inclusão de pedidos --//
	//--------------------------------------------------------//
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_COPY
		If .Not. U_VefHrPrc()
			Return .F.
		EndIf
	EndIf

	If nOperation <> MODEL_OPERATION_DELETE

		If .Not. IsInCallStack("U_LA05A005"); //-- Importação NeoGrid --//
			.And. .Not. IsInCallStack("U_LA05A009") //-- Importação Pedidos --//
			If AllTrim(FunName()) $ "LA05A001/LA05A002"
				If oModel:GetValue("M_SZL","ZL_TPVEND") == "2"
					If .Not. ValVerba(oModel:GetValue("M_SZL","ZL_CLIENTE"), oModelCalc:GetValue("ZM_TOT"))
						Help(Nil,Nil,"LA05A001",Nil,"Não existe verba para esta bonificação.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar a verba disponível para este cliente."})
						Return .F.
					EndIf
				EndIf
			EndIf

			If oModel:GetValue("M_SZL","ZL_PRZADC")
				If Empty(oModel:GetValue("M_SZL","ZL_OBSPRZ"))
					Help(Nil,Nil,"LA05A001",Nil,"Obs. de Prazo Adicional não preenchido.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor preencha a observação do prazo adicional."})
					Return .F.
				EndIf
			EndIf

			If oModel:GetValue("M_SZL","ZL_FATPROG")
				If oModel:GetValue("M_SZL","ZL_DTFATPR") <= Date()
					Help(Nil,Nil,"LA05A001",Nil,"Data de programação do faturamento é inválida.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor informe uma data da programação válida."})
					Return .F.
				EndIf
			EndIf

			If oModelCalc:GetValue("ZM_TOT") < nVlrPedMin
				lRet := MsgNoYes("Total do pedido é menor que valor mínimo de R$ "+ AllTrim(TRANSFORM(nVlrPedMin,PesqPict("SZM", "ZM_TOTAL"))) +". Deseja continuar?","Pedido Mínimo")
			EndIf

			If !Empty(dTabDtAte) .And. dTabDtAte < Date()
				Help(Nil,Nil,"LA05A001",Nil,"Tabela de preço do cliente fora de vigência.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar tabela de preço do cliente."})
				Return .F.
			ElseIf !Empty(dTabDtAte) .And. dTabDtAte = Date()
				If !Empty(cTabHrAte) .And. cTabHrAte < Time()
					Help(Nil,Nil,"LA05A001",Nil,"Tabela de preço do cliente fora de vigência.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar tabela de preço do cliente."})
					Return .F.
				EndIf
			EndIf

			If cTabAtiva == "2" // 1=Sim 2=Não
				Help(Nil,Nil,"LA05A001",Nil,"Tabela de preço do cliente não ativa.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar tabela de preço do cliente."})
				Return .F.
			EndIf

			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If cGrupo $ cGrpChoc .And. !Empty(cGrupo)
						lChoco := .T.
					ElseIf cGrupo $ cGrpOvo .And. !Empty(cGrupo)
						lOvo   := .T.
					ElseIf cGrupo $ cGrpPntt .And. !Empty(cGrupo)
						lPntt := .T.
					Else
						lComum := .T.
					EndIf
				EndIf
			Next

			FWRestRows(aSaveLines)

			If lChoco .And. lComum
				Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo chocolate não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de chocolate."})
				Return .F.
			EndIf

			If (lOvo .And. lComum) .Or. (lOvo .And. lChoco)
				Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo ovo pascoa não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de ovo pascoa."})
				Return .F.
			EndIf

			If (lPntt .And. lComum) .Or. (lPntt .And. lChoco) .And. (lPntt .And. lOvo)
				Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo panettones não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de panettones."})
				Return .F.
			EndIf
		EndIf

		oModelPSQ:SetValue("ZL_PESQ","")

	EndIf
	
Return lRet

/*/{Protheus.doc} PreVLD

Pre validação dos dados antes de aparecer a tela de inclusão ou alteração dos dados a serem cadastrados.

@author 	Ricardo Tavares Ferreira
@since 		14/08/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function PreVLD(oModel,cModel)
	
	Local lRet 			:= .T.
	Local oModel		:= FWModelActive()
	Local oView         := FWViewActive()
	Local nOperation	:= oModel:GetOperation()
	Local oModelPRD 	:= oModel:GetModel("M_PRD")
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local oModelPSQ		:= oModel:GetModel("M_PSQ")
	Local aDados		:= {}
	Local nItem			:= 1
	Local nX			:= 0
	Local nY            := 0
	Local cCont			:= oModelPSQ:GetValue("ZL_PESQ")
	Local cNumPed		:= oModel:GetValue("M_SZL","ZL_NUM")
	Local cCodVend		:= oModel:GetValue("M_SZL","ZL_VEND")
	Local cCodCli		:= oModel:GetValue("M_SZL","ZL_CLIENTE")
	Local cLoja			:= oModel:GetValue("M_SZL","ZL_LOJA")
	Local cBloq			:= Alltrim(Posicione("SA1",1,xFilial("SA1")+PadR(cCodCli,6)+cLoja,"A1_MSBLQL"))
	
	Default cModel 		:= "M_PSQ"

	If cModel == "M_SZL"
		If cBloq == "1"
			Help(Nil,Nil,"PreVLD",Nil,"Cliente bloqueado para vendas.",1,0,Nil,Nil,Nil,Nil,Nil,{"Verifique com setor financeiro sobre a situação do cliente."})
			Return .F.
		EndIf
	EndIf

	oModelPRD:SetNoInsertLine(.F.)
	oModelPRD:SetNoDeleteLine(.F.)
	
	If nOperation == MODEL_OPERATION_INSERT
		If oModelPRD:Length() >= 1
			For nX := 1 To oModelPRD:Length(.T.)
				oModelPRD:GoLine(nX)
				oModelPRD:DeleteLine()
			Next nX
		EndIf

		If oModelPRD:CanClearData()
			oModelPRD:ClearData(.T.,.T.)
		EndIf
	EndIf
	
	If GET_SB1(cCont,cModel,cCodCli,cLoja)
		While ! TMP1->(EOF())
			AADD(aDados, {StrZero(nItem,3),;
						Alltrim(TMP1->COD),;
						TMP1->DESCR,;	
						TMP1->SALDO,;
						TMP1->PRECO,;
						TMP1->TES,;
						TMP1->PESOLIQ,;
						TMP1->PESOBRT})
			TMP1->(DBSKIP())
			nItem++
		End
		TMP1->(DBCLOSEAREA())
		
		If nOperation == MODEL_OPERATION_INSERT
			For nX := 1 To Len(aDados)
				oModelPRD:GoLine(nX)
				oModelPRD:AddLine()
				oModelPRD:SetValue("ZM_PRODUTO"	,Alltrim(aDados[nX][2]))
				oModelPRD:SetValue("ZM_DESCRI"	,aDados[nX][3])
				oModelPRD:SetValue("ZM_SALDO"	,aDados[nX][4])
			Next nX
		ElseIf nOperation == MODEL_OPERATION_UPDATE
			For nX := 1 To Len(aDados)
				For nY := 1 To oModelPRD:Length()
					oModelPRD:GoLine(nY)
					If aDados[nX] <> Nil
						If Alltrim(aDados[nX][2]) == AllTrim(oModelPRD:GetValue("ZM_PRODUTO"))
							oModelPRD:SetValue("ZM_PRODUTO"	,Alltrim(aDados[nX][2]))
							oModelPRD:SetValue("ZM_DESCRI"	,aDados[nX][3])
							oModelPRD:SetValue("ZM_SALDO"	,aDados[nX][4])
							aDel(aDados, nX)
						EndIf
					EndIf
				Next nY
			Next nX
			For nX := 1 To Len(aDados)
				If aDados[nX] <> Nil
					oModelPRD:AddLine()
					oModelPRD:SetValue("ZM_PRODUTO"	,Alltrim(aDados[nX][2]))
					oModelPRD:SetValue("ZM_DESCRI"	,aDados[nX][3])
					oModelPRD:SetValue("ZM_SALDO"	,aDados[nX][4])
				EndIf
			Next nX
		EndIf
		
		oModelPRD:GoLine(1)
	Else
		lRet := .F.
		Help(Nil,Nil,"LA05A001",Nil,"Produtos não encontrados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Verifique se existem produtos cadastrados no mix do cliente."})
	EndIf

	oModelPRD:SetNoInsertLine(.T.)
	oModelPRD:SetNoDeleteLine(.T.)

	If AllTrim(FunName()) $ "LA05A001/LA05A002";
		.And. .Not. IsInCallStack("U_LA05A005"); //-- Importação NeoGrid --//
		.And. .Not. IsInCallStack("U_LA05A009") //-- Importação Pedidos --//
		oView:Refresh()
	EndIf
	
Return lRet

/*/{Protheus.doc} GravaDados

Função: 
Gera pedido de venda nas tabelas SC5/SC6
Realiza as liberações do pedido para SC9
Gera pedido de venda no Centro de Distribuição

@author 	Marcos Natã Santos
@since 		25/05/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function GravaDados(oModel)
	Local lRet 			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oModelSZL     := oModel:GetModel("M_SZL")
	Local oModelITM     := oModel:GetModel("M_ITM")
	Local aAreaSZN     	:= SZN->( GetArea() )
	Local aAreaSZO     	:= SZO->( GetArea() )
	Local aRegPed       := {}

	Local cNumPed		:= AllTrim(oModelSZL:GetValue("ZL_NUM"))
	Local cCodCli		:= AllTrim(oModelSZL:GetValue("ZL_CLIENTE"))
	Local cLoja		    := AllTrim(oModelSZL:GetValue("ZL_LOJA"))
	Local cNomeCli      := AllTrim(oModelSZL:GetValue("ZL_NOMECLI"))
	Local cCodVend      := AllTrim(oModelSZL:GetValue("ZL_VEND"))
	Local cOpc			:= ""
	
	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_COPY
		//-- Campanha com Cota de Produto --//
		If SuperGetMV("XX_PROCCOT", .F., .F.)
			//-- Desconsidera clientes no processamento de campanha (Cota de Produtos) --//
			If !(cCodCli $ SuperGetMV("XX_CANCCLI", .F., ""))
				//-- Desconsidera pedidos de bonificação (Liberação de verbas) --//
				If FunName() <> "ZVS001"
					U_ProcCota(@oModelITM)
				EndIf
			EndIf
		EndIf

		//-- Avalia pedido e adiciona no monitor com status adequado --//
		GET_STATUS()
	EndIf
	
	If FWFormCommit(oModel)
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_COPY
			
			//-- Caso o pedido não seja enviado ao monitor --//
			//-- Enviamos sem status para reprocessamento  --/
			SZN->( dbSetOrder(1) )
			If .Not. SZN->( dbSeek(xFilial("SZN") + oModel:GetValue("M_SZL","ZL_NUM")) )
				aRegPed	  := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								cNomeCli,;
								cOpc,;
								Date(),;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								cCodVend,;
								"3",; // Prazo Adicional
								"3",; // Regra de Negócio
								"3",; // Crédito
								"3",; // Estoque
								Space(1)})
				
				PUT_MONITOR(aRegPed)
			EndIf

			If lLiberado
				Processa( {|| ProcPed(oModel) }, "Processando Pedido de Venda",/*cMsg*/,.F.)
			EndIf
		EndIf
	Else
		SZN->( dbSetOrder(1) )
		If SZN->( dbSeek(xFilial("SZN") + oModel:GetValue("M_SZL","ZL_NUM")) )

			SZO->( dbSetOrder(1) )
			If SZO->( dbSeek(xFilial("SZO") + SZN->ZN_NUM + PadR(SZN->ZN_CLIENTE,6) + SZN->ZN_LOJA) )
				While SZO->( !EOF() ) .And. SZO->ZO_FILIAL  = xFilial("SZO");
										.And. SZO->ZO_NUM     = SZN->ZN_NUM;
										.And. SZO->ZO_CLIENTE = PadR(SZN->ZN_CLIENTE,6);
										.And. SZO->ZO_LOJA    = SZN->ZN_LOJA

					RecLock("SZO", .F.)
					SZO->( dbDelete() )
					SZO->( MsUnlock() )

					SZO->( dbSkip() )
				EndDo
			EndIf

			RecLock("SZN", .F.)
			SZN->( dbDelete() )
			SZN->( MsUnlock() )
		EndIf
	EndIf

	RestArea( aAreaSZN )
	RestArea( aAreaSZO )
	
Return lRet

/*/{Protheus.doc} LA05A001A

Funcao que valida o doubleclick no produto.

@author 	Ricardo Tavares Ferreira
@since 		23/03/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function LA05A001A()

	Local lRet 			:= .F.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()
	Local oModelPRD 	:= oModel:GetModel("M_PRD")
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local oBtnConf		:= Nil
	Local oBtnCanc		:= Nil
	Local cCodCli       := PadR(oModel:GetValue("M_SZL","ZL_CLIENTE"),6)
	Local cLoja         := oModel:GetValue("M_SZL","ZL_LOJA")
	Local cProd			:= Alltrim(oModelPRD:GetValue("ZM_PRODUTO"))
	Local cDescr		:= Alltrim(oModelPRD:GetValue("ZM_DESCRI"))
	Local nSaldo		:= Transform(oModelPRD:GetValue("ZM_SALDO"),PesqPict("SZM","ZM_SALDO"))
	Local nSldShelfLife := Transform(ValSaldoEstoque(cProd,cCodCli,cLoja),PesqPict("SZM","ZM_SALDO"))
	Local cTabPrc		:= Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_TABELA")
	Local cArmz			:= Alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCPAD"))
	Local cDescArmz		:= Alltrim(Posicione("NNR",1,xFilial("NNR")+cArmz,"NNR_DESCRI"))
	Local nPeso			:= Transform(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_PESBRU"),PesqPict("SB1","B1_PESBRU"))
	Local nI			:= 0
	Local aSaveLines 	:= FWSaveRows()
	Local cGrpChoc		:= GetMV("MV_XGRCHOC")
	Local cGrpOvo       := GetMV("MV_XGRPOVO")
	Local cGrpPntt      := GetMv("MV_XGRPNTT")
	Local cGrupo		:= ""
	
	Private Odlg		:= Nil
	Private nValor		:= 0
	Private nValorTab	:= 0
	Private nQtd		:= 0
	Private nTotal		:= 0
	Private nPerDesc    := 0
	Private lNaLista	:= .F.
	Private nLinITM		:= 0
	Private nUltPrc     := BscUltPrc(cCodCli,cLoja,cProd)
	Private nQtdMedHist := HistQtdCli(cCodCli,cLoja,cProd)

	If nOperation = MODEL_OPERATION_INSERT .Or. nOperation = MODEL_OPERATION_COPY .Or. nOperation = MODEL_OPERATION_UPDATE

		If Empty(oModel:GetModel("M_SZL"):GetValue("ZL_CLIENTE"))
			Help(Nil,Nil,"LA05A001A",Nil,"Cliente não informado.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor informar o cliente para adicionar produtos ao pedido."})
			Return lRet
		EndIf

		cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_BASE3"))
		If cGrupo $ cGrpChoc
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If .Not. (cGrupo $ cGrpChoc) .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo chocolate não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de chocolate."})
						Return lRet
					EndIf
				EndIf
			Next
		Else
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If cGrupo $ cGrpChoc .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo chocolate não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de chocolate."})
						Return lRet
					EndIf
				EndIf
			Next
		EndIf

		cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_BASE3"))
		If cGrupo $ cGrpOvo
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If .Not. (cGrupo $ cGrpOvo) .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo ovo pascoa não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de ovo pascoa."})
						Return lRet
					EndIf
				EndIf
			Next
		Else
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If cGrupo $ cGrpOvo .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo ovo pascoa não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de ovo pascoa."})
						Return lRet
					EndIf
				EndIf
			Next
		EndIf

		cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_BASE3"))
		If cGrupo $ cGrpPntt
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If .Not. (cGrupo $ cGrpPntt) .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo panettones não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de panettones."})
						Return lRet
					EndIf
				EndIf
			Next
		Else
			For nI := 1 To oModelITM:Length()
				oModelITM:GoLine(nI)
				If .Not. oModelITM:IsDeleted()
					cGrupo := Alltrim(Posicione("SB1",1,xFilial("SB1")+oModelITM:GetValue("ZM_PRODUTO"),"B1_BASE3"))
					If cGrupo $ cGrpPntt .And. !Empty(cGrupo)
						Help(Nil,Nil,"LA05A001A",Nil,"Produtos do grupo panettones não podem ser mixados.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor realize um pedido apenas com itens do grupo de panettones."})
						Return lRet
					EndIf
				EndIf
			Next
		EndIf

		nValorTab := Posicione("DA1",7,xFilial("DA1")+cTabPrc+cProd,"DA1_PRCVEN")

		For nI := 1 To oModelITM:Length()
			oModelITM:GoLine(nI)
			If AllTrim(oModelITM:GetValue("ZM_PRODUTO")) == cProd
				If .Not. oModelITM:IsDeleted()
					nValor 	 := oModelITM:GetValue("ZM_VALOR")
					nQtd 	 := oModelITM:GetValue("ZM_QTD")
					nTotal 	 := oModelITM:GetValue("ZM_VALOR") * oModelITM:GetValue("ZM_QTD")
					nPerDesc := IIF((100 - ((nValor / nValorTab) * 100)) > 99.99, 99.99, (100 - ((nValor / nValorTab) * 100)))
					lNaLista := .T.
					nLinITM  := oModelITM:GetLine()
				Else
					Help(Nil,Nil,"LA05A001A",Nil,"Item deletado no pedido de venda.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor restaure o item para realizar alterações."})
					Return lRet
				EndIf
			EndIf
		Next

		FWRestRows(aSaveLines)

		If ! lNaLista
			If !Empty(cTabPrc)
				nValor 	  := Posicione("DA1",7,xFilial("DA1")+cTabPrc+cProd,"DA1_PRCVEN")
				If Empty(nValor) .Or. nValor <= 0
					nValor := BscUltPrc(cCodCli,cLoja,cProd)
					If nValor <= 0
						Help(Nil,Nil,"LA05A001A",Nil,"Produto sem histórico de venda para este cliente.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor cadatrar produto na Tabela de Preço."})
						Return .F.
					EndIf
				EndIf
			Else 
				Help(Nil,Nil,"LA05A001A",Nil,"Tabela de Preço não cadastrada.",1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor amarrar Tabela de Preço no cadastro do cliente."})
				Return .F.
			EndIf
		EndIf

		Define MsDialog Odlg Title OemToAnsi("Valores Pedido de Venda") style 128 From 000 , 000 To 320 , 290 Pixel
		
		@ 006 , 005 Say "Produto: "+cProd+" - "+cDescr  	COLOR CLR_BLUE 		Of Odlg Pixel
		@ 016 , 005 Say "Armazem: "+ cArmz+" - "+cDescArmz	COLOR CLR_BLUE 		Of Odlg Pixel
		@ 026 , 005 Say "Peso: "+ nPeso						COLOR CLR_BLUE 		Of Odlg Pixel
		@ 036 , 005 Say "Qtd em Estoque: "+ nSaldo			COLOR CLR_BLUE 		Of Odlg Pixel
		@ 046 , 005 Say "Qtd Shelf Life: "+ IIF(nSaldo < nSldShelfLife, nSaldo, nSldShelfLife) COLOR CLR_BLUE Of Odlg Pixel
		@ 056 , 005 Say "Último Preço: "+ TRANSFORM(nUltPrc, PesqPict("SZM","ZM_VALOR")) COLOR CLR_BLUE Of Odlg Pixel
		@ 066 , 005 Say "Qtd Média Hist. Mês: "+ TRANSFORM(nQtdMedHist, PesqPict("SZM","ZM_QTD")) COLOR CLR_BLUE Of Odlg Pixel
		
		@ 080 , 005 Say "Valor: " 							COLOR CLR_BLACK 	Of Odlg Pixel
		@ 078 , 080 MsGet nValor	 						Size 50,10 			Of Odlg Pixel HASBUTTON Picture PesqPict("SZM","ZM_VALOR") //Valid NaoVazio()
		@ 094 , 005 Say "Quantidade: " 						COLOR CLR_HRED 		Of Odlg Pixel
		@ 092 , 080 MsGet nQtd	 							Size 50,10 			Of Odlg Pixel HASBUTTON Picture PesqPict("SZM","ZM_QTD") Valid VLMSD_01()
		@ 108 , 005 Say "Total: " 							COLOR CLR_BLACK		Of Odlg Pixel
		@ 106 , 080 MsGet nTotal 							Size 50,10 			Of Odlg Pixel HASBUTTON Picture PesqPict("SZM","ZM_TOTAL") When .F. 
		@ 122 , 005 Say "Desconto %: "						COLOR CLR_BLACK		Of Odlg Pixel
		@ 120 , 080 MsGet nPerDesc							Size 50,10 			Of Odlg Pixel HASBUTTON Picture PesqPict("SZM","ZM_PERDESC") When .F. 
				
		@ 138 , 080 BUTTON oBtnConf PROMPT "Confirmar"		Size 50,013 		OF Odlg ACTION(VLMSD_02())  Pixel
		@ 138 , 020 BUTTON oBtnCanc PROMPT "Cancelar" 		Size 50,013 		OF Odlg ACTION(Odlg:End())  Pixel
			
		Activate MsDialog Odlg Centered

	EndIf
	
Return lRet

/*/{Protheus.doc} VLMSD_01

Função que calcula o total na tela do MsDialog.

@author 	Ricardo Tavares Ferreira
@since 		06/04/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function VLMSD_01()

	Local lRet := .T.
	
	If nQtd <= 0
		lRet := .F.
		Aviso("VLMSD_01","Quantidade Inválida.",{"Fechar"},1)
	Else
		nTotal 	 := nValor * nQtd
		nPerDesc := 0

		If nValorTab <= 0 .And. nValor > 0
			nPerDesc := 99.99
		ElseIf (nValor / nValorTab) < 1
			nPerDesc := 100 - ((nValor / nValorTab) * 100)
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} VLMSD_02

Função que Grava os dados na tabela de itens complementares do pedido de venda.

@author 	Ricardo Tavares Ferreira
@since 		06/04/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function VLMSD_02()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local nOperation	:= oModel:GetOperation()
	Local oModelPRD 	:= oModel:GetModel("M_PRD")
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local cNumPed		:= oModel:GetValue("M_SZL","ZL_NUM")
	Local cCodVend		:= oModel:GetValue("M_SZL","ZL_VEND")
	Local cCodCli		:= oModel:GetValue("M_SZL","ZL_CLIENTE")
	Local cLoja			:= oModel:GetValue("M_SZL","ZL_LOJA")
	Local cTpVenda		:= oModel:GetValue("M_SZL","ZL_TPVEND")
	Local cProd			:= Alltrim(oModelPRD:GetValue("ZM_PRODUTO"))	
	Local cTabPrc		:= Posicione("SA1",1,xFilial("SA1")+PadR(oModel:GetValue("M_SZL","ZL_CLIENTE"),6)+oModel:GetValue("M_SZL","ZL_LOJA"),"A1_TABELA")
	Local nValDesc		:= 0
	Local nSaldoCota	:= 0

	If nQtd <= 0
		Aviso("VLMSD_02","Quantidade Inválida.",{"Fechar"},1)
		Return .F.
	EndIf

	//-- Campanha com Cota de Produto --//
	//-- Ajuste técnico temporário    --//
	If SuperGetMV("XX_PROCCOT", .F., .F.)
		If cProd $ "414010021/414020009/414014792/414014793" //-- Outubro Rosa --//
			nSaldoCota := StaticCall(LA05A012, SaldoCota, cCodCli, cLoja, cProd)
			If nSaldoCota < nQtd
				Help(Nil,Nil,"OutubroRosa",Nil,"Cota da campanha insuficiente. Saldo disponível: " + cValToChar(nSaldoCota),1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar cota do produto para o cliente."})
				Return .F.
			EndIf
		ElseIf cProd $ "410292861/410290261" //-- Panettones --//
			nSaldoCota := StaticCall(LA05A012, SaldoCota, cCodCli, , cProd)
			If nSaldoCota < nQtd
				Help(Nil,Nil,"Panettones",Nil,"Cota da campanha insuficiente. Saldo disponível: " + cValToChar(nSaldoCota),1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar cota do produto para o cliente."})
				Return .F.
			EndIf
		EndIf
	EndIf

	If nPerDesc > 0
		If nPerDesc = 99.99
			nValDesc := nValor
		Else
			nValDesc := ((nQtd * nValorTab) * (nPerDesc / 100))
		EndIf
	EndIf

	If nQtd > nQtdMedHist
		If .Not. MsgNoYes("Quantidade maior que a média histórica do cliente. Deseja continuar?", "Quantidade Média Venda")
			Return .F.
		EndIf
	EndIf

	If nValor > nUltPrc
		If .Not. MsgNoYes("Preço/Valor do produto maior que a última venda. Deseja continuar?", "Valor Última Venda")
			Return .F.
		EndIf
	EndIf

	oModelITM:SetNoInsertLine(.F.)

	If lNaLista
		oModelITM:GoLine(nLinITM)
	Else
		oModelITM:AddLine()
	EndIf

	oModelITM:SetValue("ZM_PRODUTO"	,Alltrim(oModelPRD:GetValue("ZM_PRODUTO")))
	oModelITM:SetValue("ZM_DESCRI"	,oModelPRD:GetValue("ZM_DESCRI"))
	oModelITM:SetValue("ZM_SALDO"	,oModelPRD:GetValue("ZM_SALDO"))
	oModelITM:SetValue("ZM_LOCAL"	,"90") // Armazém definido pela gestão
	oModelITM:SetValue("ZM_QTD"		,nQtd)
	oModelITM:SetValue("ZM_PRCTAB"	,nValorTab)
	oModelITM:SetValue("ZM_VALOR"	,nValor)
	oModelITM:SetValue("ZM_TOTAL"	,nTotal)
	
	If cTpVenda == "1"
		oModelITM:SetValue("ZM_TPOPER"	,"50")
	Else
		oModelITM:SetValue("ZM_TPOPER"	,"51")
	EndIf
	
	oModelITM:SetValue("ZM_PESOLIQ"	,Posicione("SB1",1,xFilial("SB1")+Alltrim(oModelPRD:GetValue("ZM_PRODUTO")),"B1_PESO"))
	oModelITM:SetValue("ZM_PESOBR"	,Posicione("SB1",1,xFilial("SB1")+Alltrim(oModelPRD:GetValue("ZM_PRODUTO")),"B1_PESBRU"))				
	oModelITM:SetValue("ZM_CLIENTE"	,cCodCli)
	oModelITM:SetValue("ZM_TABPRE"	,cTabPrc)
	oModelITM:SetValue("ZM_LIBER"	,"1")
	oModelITM:SetValue("ZM_PERDESC"	,nPerDesc)
	oModelITM:SetValue("ZM_VALDESC"	,nValDesc)
	oModelITM:SetValue("ZM_LOJA"	,cLoja)
	oModelITM:SetValue("ZM_VEND"	,cCodVend)
	oModelITM:SetValue("ZM_EMISSAO"	,Date())
	oModelITM:SetValue("ZM_NUM"		,cNumPed)
	
	oModelITM:GoLine(1)
	
	Odlg:End()

	oView:Refresh()

	oModelITM:SetNoInsertLine(.T.)
	
Return

/*/{Protheus.doc} GET_SB1

Funcao que Busca os dados da Tabela SB1.

@author 	Ricardo Tavares Ferreira
@since 		30/03/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function GET_SB1(cCont,cModel,cCodCli,cLoja)
	
	Local cQuery 		:= ""
	Local QBLINHA		:= chr(13)+chr(10)
	Local lMVBscMix     := SUPERGETMV("MV_XBSCMIX", .F., .T.)
	
	Default cCont 		:= "*"
	Default cModel		:= "M_PSQ"
	Default cCodCli     := ""
	Default	cLoja		:= ""
	
	cQuery := "SELECT DISTINCT "+QBLINHA 
	cQuery += "B1_COD COD "+QBLINHA
	cQuery += ", B1_DESC DESCR "+QBLINHA
	cQuery += ", (B2_QATU - B2_QEMP - B2_RESERVA - B2_QACLASS) SALDO "+QBLINHA
	cQuery += ", B1_PRV1 PRECO "+QBLINHA
	cQuery += ", B1_TS TES "+QBLINHA
	cQuery += ", B1_PESO PESOLIQ "+QBLINHA
	cQuery += ", B1_PESBRU PESOBRT "+QBLINHA
	
	cQuery += "FROM "
	cQuery += RetSqlName("SB1") + " SB1 "+QBLINHA
	
	cQuery += "INNER JOIN "
	cQuery += RetSqlName("SB2") + " SB2 "+QBLINHA
	cQuery += "ON B2_COD = B1_COD "+QBLINHA
	cQuery += "AND B2_LOCAL = '05' "+QBLINHA // Armazém definido pela gestão
	cQuery += "AND B2_FILIAL = '0101' "+QBLINHA // Centro de Distribuição
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' "+QBLINHA

	//--------------------------------------------------//
	//-- Ignora o mix do cliente na importação do EDI --//
	//--------------------------------------------------//
	If lMVBscMix .And. .Not. IsInCallStack("U_LA05A005"); //-- Importação NeoGrid --//
		.And. .Not. IsInCallStack("U_LA05A009") //-- Importação Pedidos --//
		cQuery += "INNER JOIN SA7010 SA7 "+QBLINHA
		cQuery += "ON SA7.D_E_L_E_T_ <> '*' "+QBLINHA
		cQuery += "AND A7_CLIENTE = '"+ cCodCli +"' "+QBLINHA
		// cQuery += "AND A7_LOJA = '"+ cLoja +"' "+QBLINHA
		cQuery += "AND A7_PRODUTO = B1_COD "+QBLINHA
	EndIf
	
	cQuery += "WHERE "+QBLINHA 
	cQuery += "SB1.D_E_L_E_T_ = ' ' "+QBLINHA 
	cQuery += "AND B1_TIPO IN ('PA','ME') "+QBLINHA
	cQuery += "AND B1_MSBLQL = '2' "+QBLINHA
	cQuery += "AND B1_BLQVEND = '2' "+QBLINHA
	
	If cModel == "M_PSQ"
		If IsNumeric(cCont)
			cQuery += "AND B1_COD LIKE('"+Alltrim(cCont)+"%') "+QBLINHA
		Else
			cQuery += "AND B1_DESC LIKE('%"+Alltrim(cCont)+"%') "+QBLINHA
		EndIf
	EndIf

	cQuery += "ORDER BY (B2_QATU - B2_QEMP - B2_RESERVA - B2_QACLASS) DESC "+QBLINHA
	cQuery := ChangeQuery(cQuery)

	If Select("TMP1") > 0
		TMP1->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT TO NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Return .F.
	EndIf 
	
Return .T.

/*/{Protheus.doc} GET_STATUS

Funcao que Busca os Status Para gravação do Pedido.

@author 	Ricardo Tavares Ferreira
@since 		15/04/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function GET_STATUS()
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local oModelPRD 	:= oModel:GetModel("M_PRD")
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local lRet			:= .F.

	Private cNumPed		:= AllTrim(oModelSZL:GetValue("ZL_NUM"))
	Private cCodCli		:= AllTrim(oModelSZL:GetValue("ZL_CLIENTE"))
	Private cLoja		:= AllTrim(oModelSZL:GetValue("ZL_LOJA"))
	Private cNomeCli    := AllTrim(oModelSZL:GetValue("ZL_NOMECLI"))
	Private cCodVend    := AllTrim(oModelSZL:GetValue("ZL_VEND"))
	Private lPedMax     := .F.

	If ValidEDI() // Valida Importação EDI
		oModelSZL:SetValue("ZL_STATUS","0")
		lRet := .T.
	ElseIf GETST1() // Valida Faturamento Programado
		oModelSZL:SetValue("ZL_STATUS","1")
		lRet := .T.
	ElseIf GETST2() // Valida Prazo Adicional
		oModelSZL:SetValue("ZL_STATUS","2")
		lRet := .T.
	ElseIf GETST3() // Valida Regras de Negócio
		oModelSZL:SetValue("ZL_STATUS","3")
		lRet := .T.
	ElseIf GETST4() // Valida Limite de Crédito
		oModelSZL:SetValue("ZL_STATUS","4")
		lRet := .T.
	ElseIf GETST5() // Valida Saldos em Estoque
		oModelSZL:SetValue("ZL_STATUS","5")
		lRet := .T.
	ElseIf lPedMax // Fracionamento de Carga
		oModelSZL:SetValue("ZL_STATUS","9")
		lRet := .T.
	EndIf

	//-------------------------
	//-- Workflow Status Pedido
	//-------------------------
	If lRet
		U_LA05W001(cNumPed,cCodCli,cLoja,"1",oModelSZL:GetValue("ZL_STATUS"))
	EndIf
	
Return

/*/{Protheus.doc} GETST1

Valida Faturamento Programado

@author 	Marcos Natã Santos
@since 		25/04/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function GETST1()
	
	Local lRet 			:= .F.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()	
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local cOpc			:= ""
	
	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf
	
	If oModelSZL:GetValue("ZL_FATPROG")
		lRet      := .T.
		lLiberado := .F.
		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"3",; // Prazo Adicional
						"3",; // Regra de Negócio
						"3",; // Crédito
						"3",; // Estoque
						"1"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"1",; // Status
						"Bloqueio - Faturamento Programado"}) // Obs
		
		PUT_HIST(aRegPed)
	EndIf

Return lRet

/*/{Protheus.doc} GETST2

Valida Prazo Adicional

@author 	Marcos Natã Santos
@since 		25/05/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function GETST2()
	
	Local lRet 			:= .F.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()	
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local cOpc			:= ""
	Local cCondCli      := Posicione("SA1",1,xFilial("SA1")+PadR(oModelSZL:GetValue("ZL_CLIENTE"),6);
							+oModelSZL:GetValue("ZL_LOJA"), "A1_COND")
	
	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf
	
	If oModelSZL:GetValue("ZL_TPVEND") == "1" //-- Apenas Vendas
		If oModelSZL:GetValue("ZL_PRZADC");
			.Or. .Not. ( AllTrim(oModelSZL:GetValue("ZL_CONDPAD")) $ "001/"+cCondCli )
			lRet 		:= .T.
			lLiberado	:= .F.
			aRegPed		:= {}
			
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							cNomeCli,;
							cOpc,;
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							cCodVend,;
							"2",; // Prazo Adicional
							"3",; // Regra de Negócio
							"3",; // Crédito
							"3",; // Estoque
							"2"})
			
			PUT_MONITOR(aRegPed)

			aRegPed   := {}
				
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"2",; // Status
							"Bloqueio - Prazo Adicional"}) // Obs
			
			PUT_HIST(aRegPed)
			
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} GETST3

Valida Regras de Negócio

Considerar: Tabela de Preço e Descontos

@author 	Ricardo Tavares Ferreira
@since 		15/04/2018
@version 	12.1.17
@return 	Logico
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function GETST3()
	Local lRet 			:= .F.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()	
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local cOpc			:= ""
	Local nPerDesc		:= 0
	Local nI

	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf

	For nI := 1 To oModelITM:Length()
		oModelITM:GoLine(nI)
		If .Not. oModelITM:IsDeleted()
			nPerDesc := ValDesconto( oModel, AllTrim(oModelITM:GetValue("ZM_PRODUTO")) )
			If nPerDesc > 0 .And. oModelITM:GetValue("ZM_PERDESC") > 0
				If oModelITM:GetValue("ZM_PERDESC") > nPerDesc
					lRet := .T.
				EndIf
			ElseIf oModelITM:GetValue("ZM_PERDESC") > 0
				lRet := .T.
			EndIf
		EndIf
	Next

	If lRet
		lLiberado := .F.
		aRegPed   := {}

		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"1",; // Prazo Adicional
						"2",; // Regra de Negócio
						"3",; // Crédito
						"3",; // Estoque
						"3"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"3",; // Status
						"Bloqueio - Regra de Negócio"}) // Obs
		
		PUT_HIST(aRegPed)
	EndIf
	
Return lRet

/*/{Protheus.doc} GETST4

Valida Limite de Crédito

@author 	Marcos Natã Santos
@since 		25/05/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function GETST4()
	
	Local lRet 			:= .F.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()	
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local cRisco		:= Alltrim(Posicione("SA1",1,xFilial("SA1")+PadR(cCodCli,6)+cLoja,"A1_RISCO"))
	Local cBloq			:= Alltrim(Posicione("SA1",1,xFilial("SA1")+PadR(cCodCli,6)+cLoja,"A1_MSBLQL"))
	Local cOpc			:= ""
	Local cTpVenda      := AllTrim(oModelSZL:GetValue("ZL_TPVEND"))
	
	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf
	
	If cTpVenda == "1"
		If cBloq <> "1" // 1=Inativo ; 2=Ativo
			If cRisco <> "A" 
				lRet 		:= .T.
				lLiberado	:= .F.
			EndIf
		Else
			lRet 		:= .T.
			lLiberado	:= .F.
		EndIf
	EndIf

	If lRet
		aRegPed		:= {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"1",; // Prazo Adicional
						"1",; // Regra de Negócio
						"2",; // Crédito
						"3",; // Estoque
						"4"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"4",; // Status
						"Bloqueio - Limite de Crédito"}) // Obs
		
		PUT_HIST(aRegPed)
	EndIf

Return lRet

/*/{Protheus.doc} GETST5

Valida Saldos em Estoque

@author 	Marcos Natã Santos
@since 		25/05/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function GETST5()
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()
	Local oModelITM 	:= oModel:GetModel("M_ITM")
	Local oModelSZL 	:= oModel:GetModel("M_SZL")
	Local lFatCompleto	:= oModelSZL:GetValue("ZL_FATCPLT")
	Local cOpc			:= ""
	Local lRet 			:= .F.
	Local nI			:= 1
	Local nValTotal		:= 0
	Local nVlrPedMin	:= VlrPedMin(oModelSZL:GetValue("ZL_CLIENTE"), oModelSZL:GetValue("ZL_LOJA"))
	Local nMVPedMax		:= SUPERGETMV("MV_XPEDMAX", .F., 150000)
	Local lMVBlqEst		:= SUPERGETMV("MV_XBLQEST", .F., .T.)
	Local nSaldoAtu		:= 0
	Local nValMax       := 0
	Local lNaoPedBoni   := StaticCall( LA05A002, NaoPedBoni, oModelSZL:GetValue("ZL_NUM") )

	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf
	
	For nI := 1 To oModelITM:Length()
		oModelITM:GoLine(nI)

		If .Not. oModelITM:IsDeleted()

			nValMax += oModelITM:GetValue("ZM_TOTAL")

			nSaldoAtu := ValSaldoEstoque(AllTrim(oModelITM:GetValue("ZM_PRODUTO")),;
				oModelITM:GetValue("ZM_CLIENTE"), oModelITM:GetValue("ZM_LOJA"), oModelITM:GetValue("ZM_QTD"))

			If nSaldoAtu < oModelITM:GetValue("ZM_QTD") .And. nSaldoAtu > 0
				oModelITM:SetValue("ZM_QTDLIB", nSaldoAtu )
				oModelITM:SetValue("ZM_QTDPROC", nSaldoAtu )
				nValTotal += ( nSaldoAtu * oModelITM:GetValue("ZM_VALOR") )
				lParcial := .T.
			ElseIf nSaldoAtu <= 0
				oModelITM:SetValue("ZM_LIBER", "2" )
				lParcial := .T.
			EndIf
			
			If oModelITM:GetValue("ZM_LIBER") == "1" .And. oModelITM:GetValue("ZM_QTDLIB") = 0
				oModelITM:SetValue("ZM_QTDLIB", oModelITM:GetValue("ZM_QTD") )
				oModelITM:SetValue("ZM_QTDPROC", oModelITM:GetValue("ZM_QTD") )
				nValTotal += oModelITM:GetValue("ZM_TOTAL")
			EndIf
		EndIf
	Next nI

	//-- Limpa status de pedido mínimo --//
	oModelSZL:SetValue("ZL_PEDMIN", Space(1))

	//----------------------------------------------------------------------
	//-- Verifica se é um pedido de venda com faturamento completo
	//-- Verifica bloqueio de estoque parâmetro MV_XBLQEST
	//-- Verifica valor do pedido mínimo no parametro MV_XPEDMIN
	//-- Verifica se pedido é bonificação
	//-- Verifica itens campanha outubro rosa
	//-- Verifica exceção para processamento automático. Parametro MV_XCLINAO
	//-----------------------------------------------------------------------
	If (lFatCompleto .And. lParcial) .Or. lMVBlqEst;
		.Or. (nValTotal < nVlrPedMin) .Or. !lNaoPedBoni;
		.Or. ContemOutRosa(oModelITM) .Or. CliNaoProc(cCodCli)
		lRet := .T.

		If (nValTotal < nVlrPedMin)
			oModelSZL:SetValue("ZL_PEDMIN", "S")
		EndIf

		For nI := 1 To oModelITM:Length()
			oModelITM:GoLine(nI)
			oModelITM:SetValue("ZM_LIBER", "2")
			oModelITM:SetValue("ZM_QTDLIB", 0 )
			oModelITM:SetValue("ZM_QTDPROC", 0 )
		Next nI
	EndIf

	//----------------------------------------------------------
	//-- Verifica se existe bloqueio para fracionamento de carga
	//----------------------------------------------------------
	If nValMax >= nMVPedMax
		lPedMax := .T.
		For nI := 1 To oModelITM:Length()
			oModelITM:GoLine(nI)
			oModelITM:SetValue("ZM_LIBER", "2")
			oModelITM:SetValue("ZM_QTDLIB", 0 )
			oModelITM:SetValue("ZM_QTDPROC", 0 )
		Next nI
	EndIf
	
	If lRet .And. !lPedMax
		lLiberado := .F.
		aRegPed	  := {}

		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"1",; // Prazo Adicional
						"1",; // Regra de Negócio
						"1",; // Crédito
						"2",; // Estoque
						"5"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"5",; // Status
						"Bloqueio - Saldos em Estoque"}) // Obs
		
		PUT_HIST(aRegPed)
	ElseIf lPedMax
		lLiberado := .F.
		aRegPed	  := {}

		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"1",; // Prazo Adicional
						"1",; // Regra de Negócio
						"1",; // Crédito
						"2",; // Estoque
						"9"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}
			
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"9",; // Status
						"Bloqueio - Fracionamento de Carga"}) // Obs
		
		PUT_HIST(aRegPed)
	EndIf
		
Return lRet

/*/{Protheus.doc} ValDesconto

Valida descontos das Regras de Negócio

@author 	Marcos Natã Santos
@since 		11/06/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function ValDesconto(oModel, cProduto)
	Local lRet 			:= .T.
	Local cCliente      := PadR(oModel:GetValue("M_SZL","ZL_CLIENTE"),6)
	Local cLoja			:= oModel:GetValue("M_SZL","ZL_LOJA")
	Local cGrpVen       := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_GRPVEN")
	Local nPerDesc		:= 0
	Local cGrpProd      := Posicione("SB1",1,xFilial("SB1") + cProduto, "B1_GRUPO")
	Local cEst          := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_EST")
	Local cModalidade   := oModel:GetValue("M_SZL","ZL_MODALID")
	Local cSegmento     := oModel:GetValue("M_SZL","ZL_SEGMENT")
	Local cRegional     := oModel:GetValue("M_SZL","ZL_REGNL")
	Local cCanal        := oModel:GetValue("M_SZL","ZL_CANAL")

	Default cProduto := ""

	cQuery := "SELECT ACN_CODPRO CODPRO, ACN.ACN_DESCON DESCON " + CRLF
	cQuery += "FROM "+ RetSqlName("ACS") +" ACS " + CRLF
	cQuery += "INNER JOIN "+ RetSqlName("ACN") +" ACN " + CRLF
	cQuery += "ON ACN.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "AND ACN.ACN_FILIAL = '"+ xFilial("ACN") +"' " + CRLF
	cQuery += "AND ACN.ACN_CODREG = ACS.ACS_CODREG " + CRLF
	cQuery += "WHERE ACS.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "AND ACS.ACS_FILIAL = '"+ xFilial("ACS") +"' " + CRLF
	cQuery += "AND (ACS.ACS_DATDE >= '"+ DTOS(Date()) +"' AND ACS.ACS_DATATE <= '"+ DTOS(Date()) +"') " + CRLF
	cQuery += "AND ((ACS.ACS_CODCLI = '"+ cCliente +"' AND ACS.ACS_LOJA = '"+ cLoja +"') OR ACS.ACS_GRPVEN = '"+ cGrpVen +"') " + CRLF
	cQuery += "AND ACN.ACN_CODPRO = '"+ cProduto +"' " + CRLF
	cQuery := ChangeQuery(cQuery)

	If Select("TMP1") > 0
		TMP1->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT TO NQTREG
	
	If NQTREG > 0
		TMP1->(DBGOTOP())
		nPerDesc := TMP1->DESCON
		TMP1->(dbSkip())

		While TMP1->(!EOF())
			If nPerDesc < TMP1->DESCON
				nPerDesc := TMP1->DESCON
			EndIf
			TMP1->(dbSkip())
		EndDo
	EndIf

	TMP1->(dbCloseArea())

	//--------------------------------------------------------------//
	//-- Busca Campanha de Descontos                              --//
	//-- SZP -> Cabeçalho Campanha                                --//
	//-- SZQ -> Itens Campanha                                    --//
	//--														  --//
	//-- Realiza combinações para acumular descontos corretamente --//
	//--------------------------------------------------------------//
	// cQuery := "SELECT SUM(SZQ.ZQ_DESCON) DESCON " + CRLF
	// cQuery += "FROM "+ RetSqlName("SZP") +" SZP " + CRLF
	// cQuery += "INNER JOIN "+ RetSqlName("SZQ") +" SZQ " + CRLF
	// cQuery += "	ON SZQ.D_E_L_E_T_ <> '*' " + CRLF
	// cQuery += "	AND SZQ.ZQ_FILIAL = '"+ xFilial("SZQ") +"' " + CRLF
	// cQuery += "	AND SZQ.ZQ_CODCAMP = SZP.ZP_CODCAMP " + CRLF
	// cQuery += "WHERE SZP.D_E_L_E_T_ <> '*' " + CRLF
	// cQuery += "	AND SZP.ZP_FILIAL = '"+ xFilial("SZP") +"' " + CRLF
	// cQuery += "	AND SZP.ZP_DATATE >= '"+ DTOS(Date()) +"' " + CRLF
	// cQuery += "	AND (SZQ.ZQ_GRPPRO = '"+ cGrpProd +"' OR SZQ.ZQ_CODPRO = '"+ cProduto +"') " + CRLF
	// cQuery += "	AND (  (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"')) " + CRLF
	// cQuery += "ORDER BY SZP.ZP_CODCAMP " + CRLF
	// cQuery := ChangeQuery(cQuery)

	// If Select("TMP2") > 0
	// 	TMP2->(DbCloseArea())
	// EndIf

	// TcQuery cQuery New Alias "TMP2"

	// TMP2->(dbGoTop())
	// COUNT TO NQTREG
	// TMP2->(dbGoTop())

	// If NQTREG > 0
	// 	nPerDesc += TMP2->DESCON
	// EndIf

	// TMP2->(DbCloseArea())
	
Return nPerDesc

/*/{Protheus.doc} ValSaldoEstoque

Valida Saldo em Estoque por Produto

@author 	Marcos Natã Santos
@since 		15/04/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function ValSaldoEstoque(cProduto,cCodCli,cLoja,nQtdVend)
	Local nQtd      := 0
	Local cFracion  := ""
	Local aLotesQtd := {}
	Local nX        := 0

	Default cProduto := ""
	Default cCodCli  := ""
	Default cLoja    := ""
	Default nQtdVend := 0

	If nQtdVend > 0
		cFracion := Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_XFRACIO")
	EndIf

	cQuery := "SELECT B8_PRODUTO, "
	cQuery += "	B8_LOTECTL, "
	cQuery += "	(B8_SALDO - B8_EMPENHO - B8_QACLASS) B8_SALDO "
	cQuery += "FROM SB8010 "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND B8_FILIAL = '0101' "
	cQuery += "AND B8_LOCAL = '05' "
	cQuery += "AND (B8_SALDO - B8_EMPENHO - B8_QACLASS) > 0 "
	cQuery += "AND B8_PRODUTO = '"+ cProduto +"' "
	cQuery := ChangeQuery(cQuery)

	If Select("VALSLD") > 0
		VALSLD->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"VALSLD",.F.,.T.)
		
	dbSelectArea("VALSLD")

	If cFracion == "N"
		VALSLD->(dbGoTop())
		While VALSLD->( !EOF() )
			If U_ShelfLife(cCodCli,cLoja,cProduto,VALSLD->B8_LOTECTL,"05")
				AADD(aLotesQtd, VALSLD->B8_SALDO)
			EndIf
			VALSLD->( dbSkip() )
		EndDo

		If Len(aLotesQtd) > 0
			//-- Verifica lotes que atendem a necessidade --//
			For nX := 1 To Len(aLotesQtd)
				If aLotesQtd[nX] >= nQtdVend
					nQtd += aLotesQtd[nX]
				EndIf
			Next nX

			//------------------------------------------------//
			//-- Caso nenhum lote atenda a quantidade total --//
			//-- seleciona o maior lote                     --//
			//------------------------------------------------//
			If nQtd = 0
				ASort(aLotesQtd)
				nQtd := ATail(aLotesQtd)
			EndIf
		EndIf
	Else
		VALSLD->(dbGoTop())
		While VALSLD->( !EOF() )
			If U_ShelfLife(cCodCli,cLoja,cProduto,VALSLD->B8_LOTECTL,"05")
				nQtd += VALSLD->B8_SALDO
			EndIf
			VALSLD->( dbSkip() )
		EndDo
	EndIf

	VALSLD->(dbCloseArea())

Return nQtd

/*/{Protheus.doc} PED_CAB

Funcao que Busca os dados do cabeçalho do pedido de venda customizado para posterior gravação na SC5.

@author 	Ricardo Tavares Ferreira
@since 		19/04/2018
@version 	12.1.17
@return 	Caracter
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function PED_CAB(cNumPed,cCodCli,cLoja)
	
	Local aCabec 		:= {}
	Local cQuery		:= ""
	Local QBLINHA		:= chr(13)+chr(10)
	// Local cDoc 			:= GetSxeNum("SC5","C5_NUM")
	Local nIDSZL		:= 0
	Local aCompl		:= {}
	Local nPriori       := Val( Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_PRIORI") )
	Local nLeadTime     := Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_LEADTM")
	
	Default cNumPed		:= ""
	Default cCodCli		:= ""
	Default cLoja		:= ""
	
	cQuery := "SELECT "+QBLINHA
	cQuery += "ZL_FILIAL FILIAL "+QBLINHA
	cQuery += ", ZL_NUM PEDIDO "+QBLINHA
	cQuery += ", ZL_EMISSAO EMISSAO "+QBLINHA
	cQuery += ", ZL_CONDPAD CONDPAD "+QBLINHA
	cQuery += ", ZL_CLIENTE CLIENTE "+QBLINHA
	cQuery += ", ZL_LOJA LOJA "+QBLINHA
	cQuery += ", CASE "+QBLINHA 
	cQuery += "  WHEN ZL_TPVEND = '1' THEN '50' "+QBLINHA
	cQuery += "  WHEN ZL_TPVEND = '2' THEN '51' "+QBLINHA
	cQuery += "END TPVEND "+QBLINHA
	cQuery += ", ZL_MENNOTA MENNOTA "+QBLINHA
	cQuery += ", ZL_MSGINT MSGINT "+QBLINHA
	cQuery += ", ZL_MENPAD MENPAD "+QBLINHA
	cQuery += ", ZL_VEND VEND "+QBLINHA
	cQuery += ", ZL_DATENTR DATENTR "+QBLINHA
	cQuery += ", SZL.R_E_C_N_O_ IDSZL "+QBLINHA
	cQuery += ", TRIM(ZL_PEDCLI) PEDCLI "+QBLINHA
	cQuery += ", ZL_ORIGEM ORIGEM "+QBLINHA
	
	cQuery += "FROM "
	cQuery +=  RetSqlName("SZL") + " SZL "+QBLINHA
	
	cQuery += "WHERE
	cQuery += "SZL.D_E_L_E_T_ = ' '
	cQuery += "AND ZL_NUM = '"+cNumPed+"' "+QBLINHA
	cQuery += "AND ZL_CLIENTE = '"+cCodCli+"' "+QBLINHA
	cQuery += "AND ZL_LOJA = '"+cLoja+"' "+QBLINHA
	cQuery := ChangeQuery(cQuery)

	If Select("TMP1") > 0
		TMP1->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Return aCabec
	Else
		While ! TMP1->(EOF())
			
			nIDSZL  := TMP1->IDSZL
			aCompl  := {FwCutOff(AllTrim(TMP1->PEDCLI), .T.), StoD(TMP1->DATENTR)}
			
			aAdd(aCabec,{"C5_FILIAL" 	,xFilial("SC5")				,NIL})
			// aAdd(aCabec,{"C5_NUM" 		,cDoc 						,NIL})
			aAdd(aCabec,{"C5_EMISSAO" 	,Date() 					,NIL})
			aAdd(aCabec,{"C5_TIPO" 		,"N" 						,NIL})
			aAdd(aCabec,{"C5_CLIENTE" 	,Alltrim(TMP1->CLIENTE) 	,NIL})
			aAdd(aCabec,{"C5_LOJACLI" 	,Alltrim(TMP1->LOJA) 		,NIL})
			aAdd(aCabec,{"C5_CONDPAG" 	,Alltrim(TMP1->CONDPAD)		,NIL})
			aAdd(aCabec,{"C5_XOPER" 	,Alltrim(TMP1->TPVEND) 		,NIL})
			aAdd(aCabec,{"C5_XORIGCD" 	,"S" 						,NIL})
			aAdd(aCabec,{"C5_MENNOTA" 	,Alltrim(TMP1->MENNOTA) 	,NIL})
			aAdd(aCabec,{"C5_XMSG" 	    ,Alltrim(TMP1->MSGINT) 	    ,NIL})
			aAdd(aCabec,{"C5_MENPAD" 	,Alltrim(TMP1->MENPAD) 	    ,NIL})
			aAdd(aCabec,{"C5_XPEDPAI" 	,AllTrim(TMP1->PEDIDO) 		,NIL})
			If AllTrim(TMP1->ORIGEM) == "NEOGRID"
				aAdd(aCabec,{"C5_XORIGEN" 	,"AUTONEOGRID"			,NIL})
			Else
				aAdd(aCabec,{"C5_XORIGEN" 	,"AUTOMACAO"			,NIL})
			EndIf
			aAdd(aCabec,{"C5_VEND1" 	,AllTrim(TMP1->VEND)		,NIL})
			aAdd(aCabec,{"C5_FECENT" 	,StoD(TMP1->DATENTR)		,NIL})
			aAdd(aCabec,{"C5_SUGENT" 	,StoD(TMP1->DATENTR)		,NIL})
			aAdd(aCabec,{"C5_XPRICLI" 	,nPriori             		,NIL})
			aAdd(aCabec,{"C5_XLDTIME" 	,nLeadTime             		,NIL})
			
			TMP1->(DbSkip())
		End
		TMP1->(DBCLOSEAREA())
	EndIf

Return ({nIDSZL,aCabec,aCompl})

/*/{Protheus.doc} PED_ITM

Funcao que Busca os dados dos itens do pedido de venda customizado para posterior gravação na SC6.

@author 	Ricardo Tavares Ferreira
@since 		19/04/2018
@version 	12.1.17
@return 	Caracter
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function PED_ITM(cNumPed,cCodCli,cLoja,aCompl)

	Local aItens 		:= {}
	Local aLinha		:= {}
	Local cQuery		:= ""
	Local QBLINHA		:= chr(13)+chr(10)
	
	Default cNumPed		:= ""
	Default cCodCli		:= ""
	Default cLoja		:= ""
	Default aCompl		:= {}
	
	cQuery := "SELECT "+QBLINHA 
	cQuery += "ZM_FILIAL FILIAL "+QBLINHA
	cQuery += ", ZM_ITEM ITEM "+QBLINHA
	cQuery += ", ZM_PRODUTO PROD "+QBLINHA
	cQuery += ", ZM_DESCRI DESCR "+QBLINHA
	cQuery += ", ZM_QTDPROC QTD "+QBLINHA
	cQuery += ", ZM_VALOR PRECO "+QBLINHA
	cQuery += ", ZM_VALDESC DESCONTO "+QBLINHA
	cQuery += ", ZM_TOTAL VALOR "+QBLINHA
	cQuery += ", ZM_TPOPER TPOPER "+QBLINHA
	cQuery += ", ZM_NUM NUM "+QBLINHA
	cQuery += ", ZM_CLIENTE CLIENTE "+QBLINHA
	cQuery += ", ZM_LOJA LOJA "+QBLINHA
	cQuery += ", ZM_VEND VEND "+QBLINHA
	
	cQuery += "FROM "
	cQuery +=  RetSqlName("SZM") + " SZM "+QBLINHA
	
	cQuery += "WHERE "+QBLINHA
	cQuery += "SZM.D_E_L_E_T_ = ' ' "+QBLINHA
	cQuery += "AND ZM_NUM = '"+cNumPed+"' "+QBLINHA
	cQuery += "AND ZM_CLIENTE = '"+cCodCli+"' "+QBLINHA
	cQuery += "AND ZM_LOJA = '"+cLoja+"' "+QBLINHA
	cQuery += "AND ZM_LIBER = '1' "+QBLINHA
	cQuery += "AND ZM_QTDPROC > 0 "+QBLINHA
	cQuery := ChangeQuery(cQuery)

	If Select("TMP1") > 0
		TMP1->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT To NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Return aItens
	Else
		While ! TMP1->(EOF())
			aLinha := {}
			
			AADD(aLinha,{"C6_FILIAL"	,xFilial("SC5") 		,NIL})
			AADD(aLinha,{"C6_ITEM" 		,Alltrim(TMP1->ITEM) 	,NIL})
			AADD(aLinha,{"C6_PRODUTO" 	,Alltrim(TMP1->PROD)  	,NIL})
			AADD(aLinha,{"C6_QTDVEN" 	,TMP1->QTD 				,NIL})
			// AADD(aLinha,{"C6_QTDLIB" 	,TMP1->QTD 				,NIL})
			AADD(aLinha,{"C6_PRCVEN" 	,TMP1->PRECO			,NIL})
			AADD(aLinha,{"C6_VALOR" 	,TMP1->QTD * TMP1->PRECO,NIL})
			AADD(aLinha,{"C6_OPER" 		,Alltrim(TMP1->TPOPER)	,NIL})
			AADD(aLinha,{"C6_NUMPCOM" 	,Alltrim(aCompl[1])		,NIL})
			AADD(aLinha,{"C6_ITEMPC" 	,TMP1->ITEM				,NIL})
			AADD(aLinha,{"C6_XPEDPAI" 	,Alltrim(TMP1->NUM) 	,NIL})
			AADD(aLinha,{"C6_ENTREG" 	,aCompl[2] 				,NIL})
			AADD(aLinha,{"C6_SUGENTR" 	,aCompl[2] 				,NIL})

			AADD(aItens,aLinha)
			TMP1->(DbSkip())
		End
		TMP1->(DBCLOSEAREA())
	EndIf 
	
Return aItens

/*/{Protheus.doc} PUT_MONITOR

Função realiza a gravação dos dados no Monitor de Pedidos

@author 	Marcos Natã Santos
@since 		20/06/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function PUT_MONITOR(aRegPed)
	
	Local nX		:= 0
	Local oModel    := FWModelActive()
	Local oModelSZL := oModel:GetModel("M_SZL")
	
	Default aRegPed	:= {}
	
	DbSelectArea("SZN")
	DBSetOrder(1)

	If DBSeek(PadR(xFilial("SZN"),4)+PadR(aRegPed[1][1],6)+PadR(aRegPed[1][2],6)+PadR(aRegPed[1][3],2))
		For nX := 1 To Len(aRegPed)
		
			RecLock("SZN",.F.)
				SZN->ZN_FILIAL		:= xFilial("SZN")
				SZN->ZN_NUM			:= aRegPed[nX][1]
				SZN->ZN_CLIENTE		:= aRegPed[nX][2]
				SZN->ZN_LOJA		:= aRegPed[nX][3]
				SZN->ZN_NOMECLI		:= aRegPed[nX][4]
				SZN->ZN_TIPO		:= aRegPed[nX][5]
				SZN->ZN_DATA		:= aRegPed[nX][6]
				SZN->ZN_HORA		:= aRegPed[nX][7]
				SZN->ZN_CODUSER		:= aRegPed[nX][8]
				SZN->ZN_USRNAME		:= aRegPed[nX][9]
				SZN->ZN_VEND        := aRegPed[nX][10]
				SZN->ZN_BLPRADC		:= aRegPed[nX][11]
				SZN->ZN_BLNEGOC		:= aRegPed[nX][12]
				SZN->ZN_BLCRED		:= aRegPed[nX][13]
				SZN->ZN_BLEST		:= aRegPed[nX][14]
				SZN->ZN_STATUS		:= aRegPed[nX][15]
				SZN->ZN_PEDMIN      := oModelSZL:GetValue("ZL_PEDMIN")
				SZN->ZN_FATNF       := "N"
			SZN->(MsUnLock())
			
		Next nX
	Else
		For nX := 1 To Len(aRegPed)
		
			RecLock("SZN",.T.)
				SZN->ZN_FILIAL		:= xFilial("SZN")
				SZN->ZN_NUM			:= aRegPed[nX][1]
				SZN->ZN_CLIENTE		:= aRegPed[nX][2]
				SZN->ZN_LOJA		:= aRegPed[nX][3]
				SZN->ZN_NOMECLI		:= aRegPed[nX][4]
				SZN->ZN_TIPO		:= aRegPed[nX][5]
				SZN->ZN_DATA		:= aRegPed[nX][6]
				SZN->ZN_HORA		:= aRegPed[nX][7]
				SZN->ZN_CODUSER		:= aRegPed[nX][8]
				SZN->ZN_USRNAME		:= aRegPed[nX][9]
				SZN->ZN_VEND        := aRegPed[nX][10]
				SZN->ZN_BLPRADC		:= aRegPed[nX][11]
				SZN->ZN_BLNEGOC		:= aRegPed[nX][12]
				SZN->ZN_BLCRED		:= aRegPed[nX][13]
				SZN->ZN_BLEST		:= aRegPed[nX][14]
				SZN->ZN_STATUS		:= aRegPed[nX][15]
				SZN->ZN_PEDMIN      := oModelSZL:GetValue("ZL_PEDMIN")
				SZN->ZN_FATNF       := "N"
			SZN->(MsUnLock())
			
		Next nX
	EndIf

Return

/*/{Protheus.doc} PUT_HIST

Função realiza a gravação das movimentações do Pedido de Venda

@author 	Marcos Natã Santos
@since 		20/06/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function PUT_HIST(aRegPed)
	
	Local nX		:= 0
	
	Default aRegPed	:= {}
	
	DbSelectArea("SZO")
	DBSetOrder(1)

	For nX := 1 To Len(aRegPed)
	
		RecLock("SZO", .T.)
			SZO->ZO_FILIAL		:= xFilial("SZO")
			SZO->ZO_NUM			:= aRegPed[nX][1]
			SZO->ZO_CLIENTE		:= aRegPed[nX][2]
			SZO->ZO_LOJA		:= aRegPed[nX][3]
			SZO->ZO_TIPO		:= aRegPed[nX][4]
			SZO->ZO_DATA		:= aRegPed[nX][5]
			SZO->ZO_HORA		:= aRegPed[nX][6]
			SZO->ZO_CODUSER		:= aRegPed[nX][7]
			SZO->ZO_USRNAME		:= aRegPed[nX][8]
			SZO->ZO_STATUS		:= aRegPed[nX][9]
			SZO->ZO_OBS			:= aRegPed[nX][10]
		SZO->(MsUnLock())
		
	Next nX

Return

/*/{Protheus.doc} LibSC9

Libera Pedido na tabela SC9

@author 	Marcos Natã Santos
@since 		09/06/2019
@version 	12.1.17
/*/
Static Function LibSC9(cPedido)
	Local aAreaSC6 := SC6->(GetArea())

	cQuery := "SELECT SC6.R_E_C_N_O_ RECNO, SC6.C6_NUM NUM, SC6.C6_QTDVEN QTDALIB " + CRLF
	cQuery += "FROM "+ RetSqlName("SC6") +" SC6 " + CRLF
	cQuery += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
	cQuery += "ON SC5.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
	cQuery += "AND SC5.C5_NUM = SC6.C6_NUM " + CRLF
	cQuery += "AND SC5.C5_LIBEROK <> 'S' " + CRLF
	cQuery += "WHERE SC6.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
	cQuery += "AND SC6.C6_NUM = '"+ cPedido +"' " + CRLF
	cQuery += "ORDER BY SC6.C6_NUM DESC " + CRLF
	cQuery := ChangeQuery(cQuery)

	If Select("TMPSC6") > 0
		TMPSC6->(dbCloseArea())
	EndIf

	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMPSC6",.F.,.T.)
		
	dbSelectArea("TMPSC6")
	TMPSC6->(dbGoTop())

	BEGIN TRANSACTION

		//-------------------------------------
		// Realiza liberação de regras/verbas |
		//-------------------------------------
		SC5->(dbSetOrder(1)) // C5_FILIAL+C5_NUM
		If SC5->(DBSeek("0102"+cPedido))
			SC6->(dbSetOrder(1))
			If SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
				While SC6->( !Eof() ) .And. SC6->C6_FILIAL == xFilial("SC6") .And. ;
												SC6->C6_NUM == SC5->C5_NUM

					RecLock("SC6",.F.)
					SC6->C6_BLOQUEI := Space(Len(SC6->C6_BLOQUEI))
					MsUnlock()

					SC6->(dbSkip())

				EndDo

			Endif

			Reclock("SC5",.F.)
			SC5->C5_BLQ := Space(Len(SC5->C5_BLQ))
			MsUnlock()
		EndIf

		While TMPSC6->(!EOF())
			//------------------------------------------------------------
			//-- Parametros
			//------------------------------------------------------------
			//nRegSC6: Registro do SC6                                     
			//nQtdaLib: Quantidade a Liberar                                
			//lCredito: Bloqueio de Credito                                 
			//lEstoque: Bloqueio de Estoque                                 
			//lAvCred: Avaliacao de Credito                                
			//lAvEst: Avaliacao de Estoque                                
			//lLibPar: Permite Liberacao Parcial                           
			//lTrfLocal: Tranfere Locais automaticamente                     
			//aEmpenho: Empenhos ( Caso seja informado nao efetua a gravacao
			//       apenas avalia ).                                    
			//bBlock: CodBlock a ser avaliado na gravacao do SC9          
			//aEmpPronto: Array com Empenhos previamente escolhidos           
			//       (impede selecao dos empenhos pelas rotinas)         
			//lTrocaLot	: Indica se apenas esta trocando lotes do SC9         
			//nVlrCred: Valor a ser adicionado ao limite de credito         
			//nQtdalib2: Quantidade a Liberar - segunda UM                   
			MaLibDoFat(TMPSC6->RECNO,TMPSC6->QTDALIB,.T.,.F.,.F.,.F.,.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lGeraDCF*/,/*nVlrCred*/,/*nQtdalib2*/)

			TMPSC6->(dbSkip())
		EndDo

		//--------------------------------------
		//-- Atualiza status do pedido de vendas
		//--------------------------------------
		SC5->(dbSetOrder(1)) // C5_FILIAL+C5_NUM
		If SC5->(DBSeek("0102"+cPedido))

			RecLock("SC5", .F.)
				SC5->C5_LIBEROK := "S"
			SC5->(MsUnlock())
		EndIf

	END TRANSACTION

	TMPSC6->(dbCloseArea())
	RestArea(aAreaSC6)
Return

/*/{Protheus.doc} GeraPVCD

Gera Pedido de Venda no Centro de Distribuição

@author 	Marcos Natã Santos
@since 		24/05/2018
@version 	12.1.17
/*/
Static Function GeraPVCD(cPedAuto, lJob)
	Default cPedAuto := ""
	// Default lJob     := .T.

	cQuery := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI FROM " + RetSqlName("SC5")
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND C5_FILIAL = '"+ xFilial("SC5") +"' "
	cQuery += "AND C5_XPEDPAI = '"+ cPedAuto +"' "
	cQuery += "AND C5_XPVCD = ' ' "
	cQuery += "ORDER BY C5_NUM DESC "
	cQuery := ChangeQuery(cQuery)

	If Select("LNPV") > 0
		LNPV->(dbCloseArea())
	EndIf

	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"LNPV",.F.,.T.)
		
	dbSelectArea("LNPV")
	LNPV->(dbGoTop())

	U_LA05A010(LNPV->C5_NUM, LNPV->C5_CLIENTE, LNPV->C5_LOJACLI)

	// If lJob
	// 	//----------------------------------------
	// 	//-- Abre processamento em THREAD paralela
	// 	//----------------------------------------
	// 	StartJob("U_PEDAUTCD()", GetEnvServer(), .F., AllTrim(LNPV->PEDIDO))
	// Else
	// 	U_PEDAUTCD(AllTrim(LNPV->PEDIDO), .F.)
	// EndIf

	LNPV->(dbCloseArea())

Return

/*/{Protheus.doc} ProcPed

Gera pedido de venda nas tabelas SC5/SC6
Realiza as liberações do pedido para SC9
Gera pedido de venda no Centro de Distribuição

@author 	Marcos Natã Santos
@since 		24/05/2018
@version 	12.1.17
/*/
Static Function ProcPed(oModel)
	Local nProcCount := 4
	Local nOperation := oModel:GetOperation()
	Local cNumPed	 := oModel:GetValue("M_SZL","ZL_NUM")
	Local cCodVend	 := oModel:GetValue("M_SZL","ZL_VEND")
	Local cCodCli	 := oModel:GetValue("M_SZL","ZL_CLIENTE")
	Local cLoja		 := oModel:GetValue("M_SZL","ZL_LOJA")
	Local cNomeCli	 := oModel:GetValue("M_SZL","ZL_NOMECLI")
	Local dEmissao	 := oModel:GetValue("M_SZL","ZL_EMISSAO")
	Local cOpc		 := ""
	Local nIDSZL	 := 0
	Local aCab	   	 := {}
	Local aCabec	 := {}
	Local aItens	 := {}
	Local aAreaSZL   := SZL->(GetArea())
	Local aAreaSZM   := SZM->(GetArea())
	Local cLog       := ""

	Private lMsHelpAuto := .T.
	Private lMSErroAuto := .F.

	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf

	ProcRegua(nProcCount)

	aCab	:= PED_CAB(cNumPed,cCodCli,cLoja)
	nIDSZL	:= aCab[1]
	aCabec	:= aCab[2]
	aItens	:= PED_ITM(cNumPed,cCodCli,cLoja,aCab[3])
	
	If Len(aCabec) > 0 .and. Len(aItens) > 0
		IncProc("Processando Pedido na Fábrica...")
		MATA410(aCabec,aItens,3)
		
		If !lMsErroAuto
			
			// ConfirmSX8() // Confirma numeração sequencial

			DbSelectArea("SZL")
			DbGOTO(nIDSZL)

			If lParcial
				RecLock("SZL",.F.)
					SZL->ZL_STATUS := "6" // Faturamento Parcial
				SZL->(MsUnlock())
			Else
				RecLock("SZL",.F.)
					SZL->ZL_STATUS := "7" // Faturamento Total
				SZL->(MsUnlock())
			EndIf
			
			Conout("--------------------------------------------------------------------------------------")
			Conout("")
			Conout("LA05A001 - ( " +	Dtoc(DATE()) +" as "+ Time()+ " ) -  Pedido de Venda "+ AllTrim(cNumPed) +" Incluido com Sucesso...")
			Conout("")
			Conout("--------------------------------------------------------------------------------------")
			
			If lParcial
				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							cNomeCli,;
							cOpc,;
							dEmissao,;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							cCodVend,;
							"1",; // Prazo Adicional
							"1",; // Regra de Negócio
							"1",; // Crédito
							"2",; // Estoque
							"6"})
				
				PUT_MONITOR(aRegPed)

				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								dEmissao,;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"6",; // Status
								"Liberação - Pedido liberado parcialmente"}) // Obs
				
				PUT_HIST(aRegPed)

				//-------------------------
				//-- Workflow Status Pedido
				//-------------------------
				U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
			Else
				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							cNomeCli,;
							cOpc,;
							dEmissao,;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							cCodVend,;
							"1",; // Prazo Adicional
							"1",; // Regra de Negócio
							"1",; // Crédito
							"1",; // Estoque
							"7"})
				
				PUT_MONITOR(aRegPed)

				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								dEmissao,;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"7",; // Status
								"Liberação - Pedido liberado totalmente"}) // Obs
				
				PUT_HIST(aRegPed)

				//-------------------------
				//-- Workflow Status Pedido
				//-------------------------
				U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
			EndIf

			//-----------------------------
			// Limpa quantidade em processo
			//-----------------------------
			SZM->(dbSetOrder(1))
			If SZM->( dbSeek(xFilial("SZM") + SZL->ZL_NUM + SZL->ZL_CLIENTE + SZL->ZL_LOJA) )
				While SZM->(!EOF()) .And. SZM->ZM_FILIAL = xFilial("SZM");
									.And. SZM->ZM_NUM = SZL->ZL_NUM;
									.And. SZM->ZM_CLIENTE = SZL->ZL_CLIENTE;
									.And. SZM->ZM_LOJA = SZL->ZL_LOJA
				
					RecLock("SZM", .F.)
					SZM->ZM_QTDPROC := 0
					SZM->(MsUnlock())

					SZM->(dbSkip())
				EndDo
			EndIf

			IncProc("Processando Liberações...")
			LibSC9(AllTrim(SC5->C5_NUM))

			IncProc("Processando Pedido no Centro de Distribuição...")
			GeraPVCD(AllTrim(SZL->ZL_NUM))
			IncProc()
		Else
			
			DbSelectArea("SZL")
			DbGoTo(nIDSZL)

			RecLock("SZL",.F.)
				SZL->ZL_STATUS := "8"
			SZL->(MsUnlock())
			
			Conout("-------------------------------------------------------------------------------")
			Conout("")
			Conout("LA05A001 - ( " +	Dtoc(DATE()) +" as "+ Time()+ " ) -  Falha na Inclusao do Pedido de Venda "+ AllTrim(cNumPed) +" ...")
			Conout("")
			Conout("-------------------------------------------------------------------------------")
			
			cLog := SubStr( MostraErro(), 1, 1200)
			
			aRegPed		:= {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							cNomeCli,;
							cOpc,;
							dEmissao,;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							cCodVend,;
							"3",; // Prazo Adicional
							"3",; // Regra de Negócio
							"3",; // Crédito
							"3",; // Estoque
							"8"})
			
			PUT_MONITOR(aRegPed)

			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							dEmissao,;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"8",; // Status
							"Erro - Pedido não integrado"}) // Obs
			
			PUT_HIST(aRegPed)

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9],,,cLog)
		EndIf
	EndIf

	StaticCall( LA05A002 , PosicPed , cNumPed, cCodCli, cLoja )

	RestArea(aAreaSZL)
	RestArea(aAreaSZM)

Return

/*/{Protheus.doc} AtuOper

Atualiza operação dos itens do pedido de venda

@author 	Marcos Natã Santos
@since 		28/06/2018
@version 	12.1.17
/*/
Static Function AtuOper()
	Local oModel	 := FWModelActive()
	Local oView      := FWViewActive()
	Local nOperation := oModel:GetOperation()
	Local oModelITM  := oModel:GetModel("M_ITM")
	Local oModelSZL  := oModel:GetModel("M_SZL")
	Local aSaveLines := FWSaveRows()
	Local nI         := 0
	Local cOper      := IIF(oModelSZL:GetValue("ZL_TPVEND") == "1", "50", "51")

	For nI := 1 To oModelITM:Length()
		oModelITM:GoLine(nI)
		If !Empty(oModelITM:GetValue("ZM_PRODUTO"))
			oModelITM:SetValue("ZM_TPOPER", cOper)
		EndIf
	Next

	oModelITM:GoLine(1)

	If AllTrim(FunName()) $ "LA05A001/LA05A002";
		.And. .Not. IsInCallStack("U_LA05A005"); //-- Importação NeoGrid --//
		.And. .Not. IsInCallStack("U_LA05A009") //-- Importação Pedidos --//
		oView:Refresh()
	EndIf

	FWRestRows(aSaveLines)

Return .T.

/*/{Protheus.doc} ValVerba

Verifica se existe verba disponível para bonificação de cliente

@author 	Marcos Natã Santos
@since 		29/06/2018
@version 	12.1.17
/*/
Static Function ValVerba(cCodCli, nValor)
	Local cQry
	Local lRet := .T.

	Default cCodCli := ""
	Default nValor  := 0

	cQry := "SELECT SUM(ZMV_VALOR) VERBA " + CRLF
	cQry += "FROM " + RetSqlName("ZMV") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZMV_FILIAL = '"+ xFilial("ZMV") +"' " + CRLF
	cQry += "AND ZMV_TIPO IN ('BON', 'BCO', 'BTD', 'BTI', 'BMA', 'BMP', 'BMC') " + CRLF
	cQry += "AND ZMV_ANO = TO_CHAR(SYSDATE, 'YYYY') " + CRLF
	cQry += "AND SUBSTR(ZMV_DATA,5,2) = TO_CHAR(SYSDATE, 'MM') " + CRLF
	cQry += "AND ZMV_CLIENT = '"+ cCodCli +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
	COUNT TO NQTREG
	TMP1->(dbGoTop())

	If NQTREG > 0
		If nValor > TMP1->VERBA
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

	TMP1->(DbCloseArea())

Return lRet

/*/{Protheus.doc} GatPerDesc

Gatilha valor/percentual de desconto

@author 	Marcos Natã Santos
@since 		09/07/2018
@version 	12.1.17
/*/
Static Function GatPerDesc()
	Local lRet       := .T.
	Local oModel	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local oModelITM  := oModel:GetModel("M_ITM")
	Local cTabPrc    := AllTrim(oModelITM:GetValue("ZM_TABPRE"))
	Local cProd      := AllTrim(oModelITM:GetValue("ZM_PRODUTO"))
	Local nValor     := oModelITM:GetValue("ZM_VALOR")
	Local nQtd       := oModelITM:GetValue("ZM_QTD")
	Local nValorTab  := 0
	Local nPerDesc   := 0
	Local nValDesc   := 0

	nValorTab := Posicione("DA1",7,xFilial("DA1")+cTabPrc+cProd,"DA1_PRCVEN")

	If nValorTab > 0 .And. nValor > 0
		nPerDesc := 100 - ((nValor / nValorTab) * 100)
	EndIf

	If nPerDesc > 0 .And. nQtd > 0
		nValDesc := ((nQtd * nValorTab) * (nPerDesc / 100))
	EndIf

	If nPerDesc > 0 .And. nValDesc > 0
		oModelITM:SetValue("ZM_PERDESC", nPerDesc)
		oModelITM:SetValue("ZM_VALDESC", nValDesc)
	ElseIf nValorTab <= 0 .And. nValor > 0
		oModelITM:SetValue("ZM_PERDESC", 99.99)
		oModelITM:SetValue("ZM_VALDESC", nValor)
	Else
		oModelITM:SetValue("ZM_PERDESC", 0)
		oModelITM:SetValue("ZM_VALDESC", 0)
	EndIf

Return lRet

/*/{Protheus.doc} VlrPedMin

Busca valor mínimo para pedido do cliente

@author 	Marcos Natã Santos
@since 		26/02/2019
@version 	12.1.17
/*/
Static Function VlrPedMin(cCodCli,cLoja)
	Local nValorMin := SUPERGETMV("MV_XPEDMIN", .F., "1500")
	Local aAreaSZU  := SZU->( GetArea() )
	Local cEst      := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_EST")
	Local cNvlEntr  := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_XNVLENT")

	If !Empty(cEst)
		SZU->( dbSetOrder(1) )
		If SZU->( dbSeek(xFilial("SZU") + cEst) )
			If cNvlEntr == "1"
				nValorMin := SZU->ZU_NVL1
			ElseIf cNvlEntr == "2"
				nValorMin := SZU->ZU_NVL2
			ElseIf cNvlEntr == "3"
				nValorMin := SZU->ZU_NVL3
			Else
				nValorMin := SZU->ZU_NVL1
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSZU)
	
Return nValorMin

/*/{Protheus.doc} ValidEDI

Valida diferenças de preço para entrada EDI (NeoGrid/Import)

@author 	Marcos Natã Santos
@since 		06/03/2019
@version 	12.1.17
/*/
Static Function ValidEDI()
	Local lRet       := .F.
	Local oModel	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local oModelSZL  := oModel:GetModel("M_SZL")
	Local oModelITM  := oModel:GetModel("M_ITM")
	Local cOpc		 := ""
	Local nX         := 0

	If nOperation == 3
		cOpc := "1"
	ElseIf nOperation == 4
		cOpc := "2"
	ElseIf nOperation == 5
		cOpc := "4"
	EndIf

	If AllTrim(oModelSZL:GetValue("ZL_ORIGEM")) $ "NEOGRID/IMPORT"
		For nX := 1 To oModelITM:Length()
			oModelITM:GoLine(nX)
			If .Not. oModelITM:IsDeleted()
				If oModelITM:GetValue("ZM_PRCTAB") <> oModelITM:GetValue("ZM_VALOR")
					lRet := .T.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

	If lRet
		lLiberado := .F.
		aRegPed   := {}
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						cNomeCli,;
						cOpc,;
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						cCodVend,;
						"3",; // Prazo Adicional
						"3",; // Regra de Negócio
						"3",; // Crédito
						"3",; // Estoque
						"0"})
		
		PUT_MONITOR(aRegPed)

		aRegPed   := {}	
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"0",; // Status
						"EDI - Divergência de Preços"}) // Obs
		
		PUT_HIST(aRegPed)
	EndIf

Return lRet

/*/{Protheus.doc} SugEntrega

Sugere data de entrega baseado no Lead Time

@author 	Marcos Natã Santos
@since 		11/03/2019
@version 	12.1.17
/*/
Static Function SugEntrega(oModel)
	Local dEntrega  := dDataBase
	Local oModelSZL := oModel:GetModel("M_SZL")
	Local nLeadTime := Posicione("SA1",1,xFilial("SA1")+PadR(oModelSZL:GetValue("ZL_CLIENTE"),6)+oModelSZL:GetValue("ZL_LOJA"),"A1_LEADTM")

	If nLeadTime > 0
		dEntrega := DataValida(DaySum(dDataBase, nLeadTime))
	EndIf

Return dEntrega

/*/{Protheus.doc} LA051ALT

Alterar Pedido de Venda

@author 	Marcos Natã Santos
@since 		12/03/2019
@version 	12.1.17
/*/
User Function LA051ALT()
	Local aAreaSZN := SZN->(GetArea())
	
	Private cStatus  := SZL->ZL_STATUS
	Private cNumPed  := SZL->ZL_NUM
	Private cCodCli  := SZL->ZL_CLIENTE
	Private cLoja    := SZL->ZL_LOJA
	Private lPedMax  := .F.

	SZN->( dbSetOrder(1) )
	If SZN->( dbSeek(xFilial("SZN")+SZL->ZL_NUM+SZL->ZL_CLIENTE+SZL->ZL_LOJA) )
		If SZL->ZL_STATUS == "3" .And. SZL->ZL_REJEITA == "S"
			If FWExecView( 'Alterar','LA05A001', MODEL_OPERATION_UPDATE,,{ || .T. } ) = 0
				
				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"4",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								Date(),;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"12",; // Status
								"Alteração - Pedido alterado"}) // Obs
				
				PUT_HIST(aRegPed)

				//-------------------------
				//-- Workflow Status Pedido
				//-------------------------
				U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])

				RecLock("SZN", .F.)
				SZN->ZN_REJEITA := Space(1)
				SZN->(MsUnlock())
				RecLock("SZL", .F.)
				SZL->ZL_REJEITA := Space(1)
				SZL->(MsUnlock())
				
				StaticCall(LA05A002, LIBST3, .T.)
			EndIf
		Else
			MsgAlert("Pedido de venda não pode ser alterado.")
		EndIf
	EndIf

	RestArea( aAreaSZN )

Return

/*/{Protheus.doc} BscUltPrc

Busca último preço de venda produto versus cliente

@author 	Marcos Natã Santos
@since 		02/04/2019
@version 	12.1.17
/*/
Static Function BscUltPrc(cCodCli,cLoja,cProduto)
	Local nPrc    := 0
	Local cQry    := ""
	Local nQtdReg := 0

	cQry := "SELECT D2_PRCVEN PRCVEN " + CRLF
	cQry += "FROM " + RetSqlName("SD2") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
	cQry += "	AND D2_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "	AND D2_LOJA = '"+ cLoja +"' " + CRLF
	cQry += "	AND D2_COD = '"+ cProduto +"' " + CRLF
	cQry += "ORDER BY D2_EMISSAO DESC " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("BSCPRC") > 0
		BSCPRC->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "BSCPRC"

	BSCPRC->(dbGoTop())
	COUNT TO nQtdReg
	BSCPRC->(dbGoTop())

	If nQtdReg > 0
		nPrc := BSCPRC->PRCVEN
	EndIf

	BSCPRC->(DbCloseArea())

Return nPrc

/*/{Protheus.doc} HistQtdCli

Histórico de compras do cliente por produto

@author 	Marcos Natã Santos
@since 		26/04/2019
@version 	12.1.17
/*/
Static Function HistQtdCli(cCodCli,cLoja,cProduto)
	Local nQtdProd := 0
	Local cQry     := ""
	Local nQtdReg  := 0

	cQry := "SELECT AVG(D2_QUANT) QTD FROM SD2010 " + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND D2_FILIAL = '"+ xFilial("SD2") +"' " + CRLF
	cQry += "	AND D2_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "	AND D2_LOJA = '"+ cLoja +"' " + CRLF
	cQry += "	AND D2_COD = '"+ cProduto +"' " + CRLF
	cQry += "	AND D2_EMISSAO BETWEEN '"+ DTOS(MonthSub(Date(),6)) +"' AND '"+ DTOS(Date()) +"' " + CRLF
	cQry += "ORDER BY D2_EMISSAO " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("HSTCLI") > 0
		HSTCLI->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "HSTCLI"

	HSTCLI->(dbGoTop())
	COUNT TO nQtdReg
	HSTCLI->(dbGoTop())

	If nQtdReg > 0
		nQtdProd := HSTCLI->QTD
	EndIf

	HSTCLI->(DbCloseArea())
Return nQtdProd

/*/{Protheus.doc} User Function VefHrPrc
Verifica horário para permitir inclusão de pedidos
@type  Function
@author Marcos Natã Santos
@since 14/06/2019
@version 12.1.17
@return lRet, lógico
/*/
User Function VefHrPrc
	Local lRet      := .T.
	Local cHrBlqInc := SuperGetMV("MV_XHRBLQI", .F., "")

    If !Empty(cHrBlqInc)
        If SubStr(Time(),1,2) <= SubStr(cHrBlqInc,1,2)
            If SubStr(Time(),4,2) > SubStr(cHrBlqInc,4,2)
                MsgAlert("Inclusão de pedidos bloqueada para o horário vigente.", "Horário Bloqueado para Inclusão")
                lRet := .F.
            EndIf
        Else
            MsgAlert("Inclusão de pedidos bloqueada para o horário vigente.", "Horário Bloqueado para Inclusão")
            lRet := .F.
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} NumPedCli
Verifica se pedido cliente já foi inserido anteriormente
@type  Function
@author Marcos Natã Santos
@since 17/06/2019
@version 12.1.17
@param cPedCli, string, Número pedido cliente
@return lRet, lógico
/*/
Static Function NumPedCli()
	Local oModel	 := FWModelActive()
	Local oModelSZL  := oModel:GetModel("M_SZL")
	Local cPedCli    := AllTrim( oModelSZL:GetValue("ZL_PEDCLI") )
	Local lRet       := .T.
	Local cQry       := ""
	Local nQtdReg    := 0

	If .Not. IsInCallStack("U_LA05A005"); //-- Importação NeoGrid --//
				.And. .Not. IsInCallStack("U_LA05A009"); //-- Importação Pedidos --//
				.And. AllTrim(FunName()) $ "LA05A001/LA05A002" //-- Rotinas Principais --//

		If !Empty(cPedCli)
			cQry := "SELECT ZL_NUM " + CRLF
			cQry += "FROM " + RetSqlName("SZL") + CRLF
			cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
			cQry += "AND ZL_FILIAL = '"+ xFilial("SZL") +"' " + CRLF
			cQry += "AND ZL_PEDCLI LIKE '%"+ cPedCli +"%' " + CRLF
			cQry := ChangeQuery(cQry)

			If Select("PEDCLI") > 0
				PEDCLI->(DbCloseArea())
			EndIf

			TcQuery cQry New Alias "PEDCLI"

			PEDCLI->(dbGoTop())
			COUNT TO nQtdReg
			PEDCLI->(dbGoTop())

			If nQtdReg > 0
				MsgAlert("Número de pedido cliente já foi inserido anteriomente. Por favor verifique.", "Pedido do Cliente")
			EndIf

			PEDCLI->(DbCloseArea())
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} ContemOutRosa
Verifica se o pedido tem itens da campanha outubro rosa
@type Static Function
@author Marcos Natã Santos
@since 19/08/2019
@version 1.0
@param oModelITM, object, Itens do pedido
@return lRet, logic
/*/
Static Function ContemOutRosa(oModelITM)
	Local lRet := .F.
	Local nX := 0

	For nX := 1 To oModelITM:Length()
		oModelITM:GoLine(nX)
		If .Not. oModelITM:IsDeleted()
			If AllTrim(oModelITM:GetValue("ZM_PRODUTO")) $ "414010021/414020009/414014792/414014793"
				lRet := .T.
			EndIf
		EndIf
	Next
Return lRet

/*/{Protheus.doc} CliNaoProc
Verifica se deve processar o pedido automático para centro de distribuição
@type Static Function
@author Marcos Natã Santos
@since 17/09/2019
@version 1.0
@param cCodCli, char
@return lRet, logic
/*/
Static Function CliNaoProc(cCodCli)
	Local lRet := .F.
	Local cMVCliNao := SuperGetMV("MV_XCLINAO", .F., "")

	//-------------------------------------------------------------------//
	//-- Se grupo do cliente estiver contido no parametro              --//
	//-- o pedido ficará pendente para envio ao centro de distribuição --//
	//-- Exemplo: MV_XCLINAO = 000060/003050/000003                    --//
	//-------------------------------------------------------------------//
	If cCodCli $ cMVCliNao
		lRet := .T.
	EndIf
Return lRet
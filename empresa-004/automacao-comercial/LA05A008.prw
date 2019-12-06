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

/*/{Protheus.doc} LA05A008

Browse para Pedido Valor Mínimo

@author 	Marcos Natã Santos
@since 		26/02/2019
@version 	12.1.17
@return 	oBrowse
@Obs 		Marcos Natã Santos - Construção
/*/
User Function LA05A008() //-- U_LA05A008()
	Local oBrowse	:= Nil

	Private cTitulo	:= OemtoAnsi("Pedido Valor Mínimo")
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZU")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A008")
	oBrowse:Activate()
	
Return oBrowse

/*/{Protheus.doc} ModelDef

Modelo de Dados da tela Pedido Valor Mínimo

@author 	Marcos Natã Santos
@since 		26/02/2019
@version 	12.1.17
@return 	oModel
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStrSZU	:= Nil

	oModel 	:= MPFormModel():New('LA058MOD')
	oStrSZU	:= FWFormStruct(1, 'SZU')

	oModel:AddFields('SZU_MASTER', /*cOwner*/, oStrSZU)

	//-- Seta a chave primaria
	oModel:SetPrimaryKey({"ZU_FILIAL","ZU_EST"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("SZU_MASTER"):SetDescription(OemToAnsi("Pedido Valor Mínimo"))

    oStrSZU:SetProperty("ZU_EST", MODEL_FIELD_WHEN, {|| Iif(Inclui,.T.,.F.)})
    oStrSZU:SetProperty("ZU_EST", MODEL_FIELD_VALID, {|| ValZuEst(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef

Define visualização da tela Pedido Valor Mínimo

@author 	Marcos Natã Santos
@since 		26/02/2019
@version 	12.1.17
@return 	oView
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function ViewDef()
	Local oModel	:= FWLoadModel("LA05A008")
	Local oView		:= Nil
	Local oStrSZU	:= Nil
	
	oView 	:= FWFormView():New()
	oStrSZU	:= FWFormStruct(2, 'SZU')
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("VIEW_SZU", oStrSZU, "SZU_MASTER")

	// Cria um "box" horizontal para receber cada elemento da view Pai
	oView:CreateHorizontalBox("BOX", 100)
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao Pai
	oView:SetOwnerView("VIEW_SZU","BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("VIEW_SZU",OemtoAnsi("Pedido Valor Mínimo"))
	
Return oView

/*/{Protheus.doc} MenuDef

Funcao que cria o menu principal do Browse do Pedido Valor Mínimo

@author 	Marcos Natã Santos
@since 		26/02/2019
@version 	12.1.17
@return 	aRotina
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function MenuDef()
	Local aRotina	:= {}
	
    ADD OPTION aRotina Title "Incluir" 		ACTION "VIEWDEF.LA05A008"   OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina Title "Visualizar"   ACTION "VIEWDEF.LA05A008"   OPERATION MODEL_OPERATION_VIEW      ACCESS 0
    ADD OPTION aRotina Title "Alterar" 		ACTION "VIEWDEF.LA05A008"   OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
    ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.LA05A008"   OPERATION MODEL_OPERATION_DELETE    ACCESS 0

Return aRotina

/*/{Protheus.doc} ValZuEst

Valida campo ZU_EST

@author 	Marcos Natã Santos
@since 		27/02/2019
@version 	12.1.17
@return     Lógico
/*/
Static Function ValZuEst(oModel)
    Local lRet      := .T.
    Local aAreaSZU  := SZU->( GetArea() )
    Local oModelSZU := oModel:GetModel("SZU_MASTER")

    SZU->( dbSetOrder(1) )
    If SZU->( dbSeek(xFilial("SZU") + oModelSZU:GetValue("ZU_EST")) )
        Help(Nil,Nil,"ValZuEst",Nil,"Estado/UF já Cadastrado",1,0,Nil,Nil,Nil,Nil,Nil,{"Já existe valores cadastrados para este Estado/UF."})
        lRet := .F.
    EndIf

    RestArea(aAreaSZU)

Return lRet
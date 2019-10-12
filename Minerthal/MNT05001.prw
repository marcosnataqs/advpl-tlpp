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

/*/{Protheus.doc} MNT05001
Browse para Campanha Comprou Ganhou
@author 	Marcos Natã Santos
@since 		10/10/2019
@version 	1.0
@return 	oBrowse
/*/
User Function MNT05001() //-- U_MNT05001()

	Local oBrowse := Nil
    Local cTitulo := "Campanha Comprou Ganhou"  
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZA")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("MNT05001")
	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} ModelDef
ModelDef da Campanha Comprou Ganhou
@author 	Marcos Natã Santos
@since 		10/10/2019
@version 	1.0
@return 	oModel
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrSZA	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTFAT001")
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZA := FWFormStruct(1, "SZA")

	// Funcao que executa o gatilho de preenchimento da descricao dos campos
	oStrSZA:AddTrigger("ZA_COD","ZA_GRUPO",{ || .T. },{|| oModel := FwModelActive(),;
	AllTrim(Posicione("SB1",1,xFilial("SB1")+oModel:GetValue("M_SZA", "ZA_COD"), "B1_GRUPO"))})
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZA",/*cOwner*/,oStrSZA)

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZA_FILIAL", "ZA_ID", "ZA_COD"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_SZA"):SetDescription(OemToAnsi("Campanha Comprou Ganhou"))

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef da Campanha Comprou Ganhou
@author 	Marcos Natã Santos
@since 		10/10/2019
@version 	1.0
@return 	oView
/*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("MNT05001")
	Local oStrSZA	:= Nil
																																				
	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZA := FWFormStruct(2, "SZA")
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZA",oStrSZA,"M_SZA")

    // Cria box horizontal
	oView:CreateHorizontalBox("V_BOX",100)
	
	// Relaciona o identificador (ID) da View com o box
	oView:SetOwnerView("V_SZA","V_BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZA",OemtoAnsi("Campanha Comprou Ganhou"))
	
Return oView

/*/{Protheus.doc} MenuDef
MenuDef para Campanha Comprou Ganhou
@author 	Marcos Natã Santos
@since 		10/10/2019
@version 	1.0
@return 	aRotina
/*/
Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Incluir" 		ACTION "VIEWDEF.MNT05001" OPERATION MODEL_OPERATION_INSERT	ACCESS 0
    ADD OPTION aRotina Title "Visualizar"	ACTION "VIEWDEF.MNT05001" OPERATION MODEL_OPERATION_VIEW	ACCESS 0
	ADD OPTION aRotina Title "Alterar" 		ACTION "VIEWDEF.MNT05001" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0
	ADD OPTION aRotina Title "Copiar" 		ACTION "VIEWDEF.MNT05001" OPERATION MODEL_OPERATION_COPY	ACCESS 0
    ADD OPTION aRotina Title "Excluir" 		ACTION "VIEWDEF.MNT05001" OPERATION MODEL_OPERATION_DELETE	ACCESS 0

Return aRotina
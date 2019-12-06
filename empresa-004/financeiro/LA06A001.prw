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

/*/{Protheus.doc} LA06A001

Browse para Fechamento de Caixa

@author 	Marcos Natã Santos
@since 		23/08/2018
@version 	12.1.17
@return 	oBrowse
/*/
User Function LA06A001()

	Local oBrowse := Nil
    Local cTitulo := "Fechamento de Caixa Pagar"  
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZR")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA06A001")
	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} ModelDef

ModelDef da Fechamento de Caixa

@author 	Marcos Natã Santos
@since 		23/08/2018
@version 	12.1.17
@return 	oModel
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrSZR	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("LA061MOD",,{|oModel| PosValida(oModel)})
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrSZR := FWFormStruct(1, "SZR")
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SZR",/*cOwner*/,oStrSZR)

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZR_FILIAL","ZR_DATFECH"})

    oStrSZR:SetProperty("ZR_CODUSR", MODEL_FIELD_INIT, {|| RetCodUsr() })
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_SZR"):SetDescription(OemToAnsi("Fechamento de Caixa Pagar"))

Return oModel

/*/{Protheus.doc} ViewDef

ViewDef da Fechamento de Caixa

@author 	Marcos Natã Santos
@since 		23/08/2018
@version 	12.1.17
@return 	oView
/*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("LA06A001")
	Local oStrSZR	:= Nil
																																				
	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrSZR := FWFormStruct(2, "SZR")
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_SZR",oStrSZR,"M_SZR")

    // Cria box horizontal
	oView:CreateHorizontalBox("V_BOX",100)
	
	// Relaciona o identificador (ID) da View com o box
	oView:SetOwnerView("V_SZR","V_BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_SZR",OemtoAnsi("Fechamento de Caixa Pagar"))
	
Return oView

/*/{Protheus.doc} MenuDef

MenuDef para Fechamento de Caixa

@author 	Marcos Natã Santos
@since 		23/08/2018
@version 	12.1.17
@return 	aRotina
/*/
Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.LA06A001" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
    ADD OPTION aRotina Title "Oscilação Caixa"  ACTION "U_LA06R001()"     OPERATION MODEL_OPERATION_VIEW	 	ACCESS 0
    ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.LA06A001" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 		    ACTION "VIEWDEF.LA06A001" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.LA06A001" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
    ADD OPTION aRotina Title "Excluir" 		    ACTION "VIEWDEF.LA06A001" OPERATION MODEL_OPERATION_DELETE		ACCESS 0

Return aRotina

/*/{Protheus.doc} PosValida

PosValida para Fechamento de Caixa

@author 	Marcos Natã Santos
@since 		23/08/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function PosValida(oModel)
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()
	
Return lRet
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

/*/{Protheus.doc} LA05A012

Browse para Cota de Produto

@author 	Marcos Natã Santos
@since 		09/07/2019
@version 	12.1.17
@return 	oBrowse
/*/
User Function LA05A012()

	Local oBrowse := Nil
    Local cTitulo := "Cota de Produto"  
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCP")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A012")
	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} ModelDef

ModelDef da Cota de Produto

@author 	Marcos Natã Santos
@since 		09/07/2019
@version 	12.1.17
@return 	oModel
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrZCP	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("LA0512MOD", {|| .T.}, {|oModel| PosValida(oModel)})
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZCP := FWFormStruct(1, "ZCP")
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZCP",/*cOwner*/,oStrZCP)

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZCP_FILIAL","ZCP_CLIENT","ZCP_VEND","ZCP_PROD","ZCP_DTINI","ZCP_DTFIN"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_ZCP"):SetDescription(OemToAnsi("Cota de Produto"))

Return oModel

/*/{Protheus.doc} ViewDef

ViewDef da Cota de Produto

@author 	Marcos Natã Santos
@since 		09/07/2019
@version 	12.1.17
@return 	oView
/*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("LA05A012")
	Local oStrZCP	:= Nil
																																				
	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZCP := FWFormStruct(2, "ZCP")
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZCP",oStrZCP,"M_ZCP")

    // Cria box horizontal
	oView:CreateHorizontalBox("V_BOX",100)
	
	// Relaciona o identificador (ID) da View com o box
	oView:SetOwnerView("V_ZCP","V_BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZCP",OemtoAnsi("Cota de Produto"))
	
Return oView

/*/{Protheus.doc} PosValida
@type Static Function
@author Marcos Natã Santos
@since 22/10/2019
@version 1.0
@param oModel, object
@return lRet, logic
/*/
Static Function PosValida(oModel)
	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelZCP := oModel:GetModel("M_ZCP")

	Local cDtIni := DTOS(oModelZCP:GetValue("ZCP_DTINI"))
	Local cDtFin := DTOS(oModelZCP:GetValue("ZCP_DTFIN"))
	Local cCodCli := oModelZCP:GetValue("ZCP_CLIENT")
	Local cLoja := oModelZCP:GetValue("ZCP_LOJA")
	Local cProduto := oModelZCP:GetValue("ZCP_PROD")
	Local nQtd := oModelZCP:GetValue("ZCP_QTD")

	lRet := SldUtil(cDtIni, cDtFin, cCodCli, cLoja, cProduto, nQtd, nOperation)

Return lRet

/*/{Protheus.doc} MenuDef

MenuDef para Cota de Produto

@author 	Marcos Natã Santos
@since 		09/07/2019
@version 	12.1.17
@return 	aRotina
/*/
Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.LA05A012" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
    ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.LA05A012" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 		    ACTION "VIEWDEF.LA05A012" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.LA05A012" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
    ADD OPTION aRotina Title "Excluir" 		    ACTION "VIEWDEF.LA05A012" OPERATION MODEL_OPERATION_DELETE		ACCESS 0

Return aRotina

/*/{Protheus.doc} ProcCota
Processa cota de produto para campanhas
@type  User Function
@author Marcos Natã Santos
@since 10/07/2019
@version 12.1.17
/*/
User Function ProcCota(oModel)
	Local nX := 0
	Local cProdOutRosa := ""
	Local nSaldo := 0
	Local cCodCli := ""
	Local cLoja := ""
	Local cProduto := ""
	Local nQtdVend := 0

	Default oModel := Nil

	For nX := 1 To oModel:Length()
		oModel:GoLine(nX)

		cCodCli := AllTrim(oModel:GetValue("ZM_CLIENTE"))
		cLoja := AllTrim(oModel:GetValue("ZM_LOJA"))
		cProduto := AllTrim(oModel:GetValue("ZM_PRODUTO"))
		nQtdVend := oModel:GetValue("ZM_QTD")
		
		cProdOutRosa := OutubroRosa(cProduto)

		If !Empty(cProdOutRosa)
			nSaldo := SaldoCota(cCodCli,cLoja,cProdOutRosa)
			If nSaldo > 0
				If nSaldo >= nQtdVend
					AltItemPedido(@oModel,nX,cProdOutRosa,nQtdVend)
				Else
					AltItemPedido(@oModel,nX,cProdOutRosa,nQtdVend,.T.,nSaldo)
				EndIf
			EndIf
		EndIf
	Next nX
	
	//-- Início --//
	oModel:GoLine(1)

Return

/*/{Protheus.doc} OutubroRosa
Realiza o DE-PARA da campanha Outubro Rosa
@type  Static Function
@author Marcos Natã Santos
@since 10/07/2019
@version 12.1.17
@param cProduto, char, Código do produto
@return cProdOutRosa, char, Código do produto outubro rosa
/*/
Static Function OutubroRosa(cProduto)
	Local cProdOutRosa := ""

	Default cProduto := ""

	Do Case
		Case cProduto == "410010021" //-- ADOC LIQUIDO LINEA 24X75ML
			cProdOutRosa := "414010021" //-- ADOC LIQUIDO OUT ROSA LINEA 24X75ML
		Case cProduto == "410020009" //-- ADOCANTE PO LINEA 24X50X0,8G
			cProdOutRosa := "414020009" //-- ADOCANTE PO OUT ROSA LINEA 24X50X0,8G
		Case cProduto == "410014792" //-- ADOC STEVIA LIQ LINEA 12X60ML
			cProdOutRosa := "414014792" //-- ADOC STEVIA LIQ OUT ROSA LINEA 12X60ML
		Case cProduto == "410014793" //-- ADOC STEVIA PO LINEA 12X50X0,6G
			cProdOutRosa := "414014793" //-- ADOC STEVIA PO OUT ROSA LINEA 12X50X0,6G
	EndCase
	
Return cProdOutRosa

/*/{Protheus.doc} SaldoCota
Verifica saldo da cota para cliente/produto
@type  Static Function
@author Marcos Natã Santos
@since 10/07/2019
@version 12.1.17
@param cCodCli, char, Código do cliente
@param cLoja, char, Código da loja
@param cProduto, char, Código do produto
@return nSaldo, numerico, Saldo disponível
/*/
Static Function SaldoCota(cCodCli,cLoja,cProduto)
	Local nSaldo := 0
	Local cQry := ""
	Local nQtdReg := 0

	Default cLoja := ""

	cQry := "SELECT ZCP_DTINI, ZCP_DTFIN, SUM(ZCP_QTD) ZCP_QTD " + CRLF
	cQry += "FROM " + RetSqlName("ZCP") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZCP_CLIENT = '"+ cCodCli +"' " + CRLF
	If !Empty(cLoja)
		cQry += "AND ZCP_LOJA = '"+ cLoja +"' " + CRLF
	EndIf
	cQry += "AND ZCP_PROD = '"+ cProduto +"' " + CRLF
	cQry += "AND '"+ DTOS( Date() ) +"' >= ZCP_DTINI " + CRLF
	cQry += "AND '"+ DTOS( Date() ) +"' <= ZCP_DTFIN " + CRLF
	cQry += "GROUP BY ZCP_DTINI, ZCP_DTFIN " + CRLF
	cQry := ChangeQuery(cQry)

    If Select("QTDCOTA") > 0
        QTDCOTA->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "QTDCOTA"

    QTDCOTA->(dbGoTop())
    COUNT TO nQtdReg
    QTDCOTA->(dbGoTop())

	If nQtdReg > 0
		cQry := "SELECT SUM(ZM_QTD-ZM_QTDCORT) QUANT FROM " + RetSqlName("SZM") + CRLF
		cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
		cQry += "AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
		If !Empty(cLoja)
			cQry += "AND ZM_LOJA = '"+ cLoja +"' " + CRLF
		EndIf
		cQry += "AND ZM_PRODUTO = '"+ cProduto +"' " + CRLF
		cQry += "AND ZM_EMISSAO BETWEEN '"+ QTDCOTA->ZCP_DTINI +"' AND '"+ QTDCOTA->ZCP_DTFIN +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("SLDPED") > 0
			SLDPED->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "SLDPED"

		SLDPED->(dbGoTop())
		COUNT TO nQtdReg
		SLDPED->(dbGoTop())

		If nQtdReg > 0
			nSaldo := (QTDCOTA->ZCP_QTD - SLDPED->QUANT)
			nSaldo := IIF(nSaldo < 0, 0, nSaldo)
		EndIf

		SLDPED->(DbCloseArea())
	EndIf

	QTDCOTA->(DbCloseArea())
Return nSaldo

/*/{Protheus.doc} AltItemPedido
Atualiza itens do pedido para campanha
@type  Static Function
@author Marcos Natã Santos
@since 10/07/2019
@version 12.1.17
@param oModel, objeto, Modelo Grid
@param nItem, numerico, Item
@param cProduto, char, Código do produto
@param nQtd, numerico, Quantidade venda
@param lNovo, logico, Adicionar nova linha
@param nSaldo, numerico, Saldo pendente
/*/
Static Function AltItemPedido(oModel,nItem,cProduto,nQtd,lNovo,nSaldo)
	Local nX := 0
	Local cProdDesc := ""
	Local nQtdVend := 0
	Local nNovoItem := 0
	Local cNovoItem := ""

	Local cLocal,nValorTab,nValor,cTpOper,nPesoLiq,nPesoBr,cCodCli,cLoja
	Local cTabPrc,cLiber,nPerDesc,nValDesc,cCodVend,dEmissao,cNumPed

	Default oModel := Nil
	Default nItem := 0
	Default cProduto := ""
	Default nQtd := 0
	Default lNovo := .F.
	Default nSaldo := 0

	cProdDesc := AllTrim( Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC") )

	If .Not. lNovo
		oModel:GoLine(nItem)
		oModel:SetValue("ZM_PRODUTO", cProduto)
		oModel:SetValue("ZM_DESCRI", cProdDesc)
	Else
		//-- Altera quantidade do produto regular
		oModel:GoLine(nItem)
		nQtdVend := oModel:GetValue("ZM_QTD")
		oModel:SetValue("ZM_QTD", nQtdVend - nSaldo)

		cLocal := oModel:GetValue("ZM_LOCAL")
		nValorTab := oModel:GetValue("ZM_PRCTAB")
		nValor := oModel:GetValue("ZM_VALOR")
		cTpOper := oModel:GetValue("ZM_TPOPER")
		nPesoLiq := oModel:GetValue("ZM_PESOLIQ")
		nPesoBr := oModel:GetValue("ZM_PESOBR")
		cCodCli := oModel:GetValue("ZM_CLIENTE")
		cLoja := oModel:GetValue("ZM_LOJA")
		cTabPrc := oModel:GetValue("ZM_TABPRE")
		cLiber := oModel:GetValue("ZM_LIBER")
		nPerDesc := oModel:GetValue("ZM_PERDESC")
		nValDesc := oModel:GetValue("ZM_VALDESC")
		cCodVend := oModel:GetValue("ZM_VEND")
		dEmissao := oModel:GetValue("ZM_EMISSAO")
		cNumPed := oModel:GetValue("ZM_NUM")

		oModel:SetNoInsertLine(.F.)

		//-- Adiciona o produto da campanha
		nNovoItem := oModel:AddLine()
		cNovoItem := PadL(cValToChar(nNovoItem),2,"0")
		oModel:SetValue("ZM_ITEM"   , cNovoItem)
		oModel:SetValue("ZM_PRODUTO", cProduto)
		oModel:SetValue("ZM_DESCRI" , cProdDesc)
		oModel:SetValue("ZM_LOCAL"	, cLocal)
		oModel:SetValue("ZM_QTD"	, nSaldo)
		oModel:SetValue("ZM_PRCTAB"	, nValorTab)
		oModel:SetValue("ZM_VALOR"	, nValor)
		oModel:SetValue("ZM_TPOPER"	, cTpOper)
		oModel:SetValue("ZM_PESOLIQ", nPesoLiq)
		oModel:SetValue("ZM_PESOBR"	, nPesoBr)
		oModel:SetValue("ZM_CLIENTE", cCodCli)
		oModel:SetValue("ZM_LOJA"	, cLoja)
		oModel:SetValue("ZM_TABPRE"	, cTabPrc)
		oModel:SetValue("ZM_LIBER"	, cLiber)
		oModel:SetValue("ZM_PERDESC", nPerDesc)
		oModel:SetValue("ZM_VALDESC", nValDesc)
		oModel:SetValue("ZM_VEND"	, cCodVend)
		oModel:SetValue("ZM_EMISSAO", dEmissao)
		oModel:SetValue("ZM_NUM"	, cNumPed)

		oModel:SetNoInsertLine(.T.)
	EndIf

Return

/*/{Protheus.doc} SldUtil
Verifica se a cota cadastrada já foi utilizada/consumida
@type Static Function
@author Marcos Natã Santos
@since 22/10/2019
@version 1.0
@param cDtIni, char
@param cDtFin, char
@param cCodCli, char
@param cLoja, char
@param cProduto, char
@param nQtd, numeric
@param nOperation, numeric
@return lRet, logic
/*/
Static Function SldUtil(cDtIni, cDtFin, cCodCli, cLoja, cProduto, nQtd, nOperation)
	Local lRet := .T.
	Local cQry := ""
	Local nQtdReg := 0
	Local nSaldo := 0

	cQry := "SELECT SUM(ZM_QTD-ZM_QTDCORT) QUANT FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
	If !Empty(cLoja)
		cQry += "AND ZM_LOJA = '"+ cLoja +"' " + CRLF
	EndIf
	cQry += "AND ZM_PRODUTO = '"+ cProduto +"' " + CRLF
	cQry += "AND ZM_EMISSAO BETWEEN '"+ cDtIni +"' AND '"+ cDtFin +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("SLDUTIL") > 0
		SLDUTIL->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "SLDUTIL"

	SLDUTIL->(dbGoTop())
	COUNT TO nQtdReg
	SLDUTIL->(dbGoTop())

	If nQtdReg > 0
		nSaldo := (nQtd - SLDUTIL->QUANT)

		If nOperation == MODEL_OPERATION_UPDATE
			If nSaldo < 0
				lRet := .F.
				Help(Nil,Nil,"SldUtil",Nil,"Quantidade da cota já consumido.",;
					1,0,Nil,Nil,Nil,Nil,Nil,{"Quantidade da cota não pode ser menor do que o já utilizado."})
			EndIf
		EndIf

		If nOperation == MODEL_OPERATION_DELETE
			lRet := .F.
			Help(Nil,Nil,"SldUtil",Nil,"Quantidade da cota já consumido.",;
				1,0,Nil,Nil,Nil,Nil,Nil,{"Este item não pode ser excluído."})
		EndIf
	EndIf

	SLDUTIL->(DbCloseArea())
Return lRet
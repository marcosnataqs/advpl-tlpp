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

/*/{Protheus.doc} LA05A011

Browse para Metas de Vendas

@author 	Marcos Natã Santos
@since 		21/06/2019
@version 	12.1.17
@return 	oBrowse
/*/
User Function LA05A011()

	Local oBrowse := Nil
    Local cTitulo := "Metas de Vendas"  
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZMT")

	//Legendas
	oBrowse:AddLegend("SUBSTR(ZMT->ZMT_COMERC,1,1) == 'S'", "BR_VERDE",   "Comercializa" )
	oBrowse:AddLegend("SUBSTR(ZMT->ZMT_COMERC,1,1) == 'N'", "BR_AMARELO", "Não Comercializa" )

	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A011")
	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} ModelDef

ModelDef da Metas de Vendas

@author 	Marcos Natã Santos
@since 		21/06/2019
@version 	12.1.17
@return 	oModel
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrZMT	:= Nil
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("LA0511MOD",,{|oModel| PosValida(oModel)})
	
	// Cria o Objeto da Estrutura dos Campos da tabela
	oStrZMT := FWFormStruct(1, "ZMT")

	// Gatilhos
	oStrZMT:AddTrigger("ZMT_CODPRD","ZMT_DSCPRD",{ || .T. },{|| oModel := FwModelActive(),;
	AllTrim(Posicione("SB1",1,xFilial("SB1")+oModel:GetModel("M_ZMT"):GetValue("ZMT_CODPRD"),"B1_DESC"))})

	oStrZMT:AddTrigger("ZMT_CODVEN","ZMT_DESCVE",{ || .T. },{|| oModel := FwModelActive(),;
	AllTrim(Posicione("SA3",1,xFilial("SA3")+oModel:GetModel("M_ZMT"):GetValue("ZMT_CODVEN"),"A3_NOME"))})
		
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_ZMT",/*cOwner*/,oStrZMT)

	// Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"ZMT_FILIAL","ZMT_ANO","ZMT_MES","ZMT_REGION","ZMT_CODVEN","ZMT_CODPRD"})
	
	// Seta a descricao do modelo de dados no cabecalho
	oModel:GetModel("M_ZMT"):SetDescription(OemToAnsi("Metas de Vendas"))

Return oModel

/*/{Protheus.doc} ViewDef

ViewDef da Metas de Vendas

@author 	Marcos Natã Santos
@since 		21/06/2019
@version 	12.1.17
@return 	oView
/*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("LA05A011")
	Local oStrZMT	:= Nil
																																				
	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oStrZMT := FWFormStruct(2, "ZMT")
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado na View
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo formulario
	oView:AddField("V_ZMT",oStrZMT,"M_ZMT")

    // Cria box horizontal
	oView:CreateHorizontalBox("V_BOX",100)
	
	// Relaciona o identificador (ID) da View com o box
	oView:SetOwnerView("V_ZMT","V_BOX")
	
	// Seta o Titulo no cabecalho do cadastro
	oView:EnableTitleView("V_ZMT",OemtoAnsi("Metas de Vendas"))
	
Return oView

/*/{Protheus.doc} MenuDef

MenuDef para Metas de Vendas

@author 	Marcos Natã Santos
@since 		21/06/2019
@version 	12.1.17
@return 	aRotina
/*/
Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina Title "Incluir" 			ACTION "VIEWDEF.LA05A011" OPERATION MODEL_OPERATION_INSERT		ACCESS 0
    ADD OPTION aRotina Title "Visualizar"		ACTION "VIEWDEF.LA05A011" OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRotina Title "Alterar" 		    ACTION "VIEWDEF.LA05A011" OPERATION MODEL_OPERATION_UPDATE		ACCESS 0
	ADD OPTION aRotina Title "Copiar" 			ACTION "VIEWDEF.LA05A011" OPERATION MODEL_OPERATION_COPY	 	ACCESS 0
    ADD OPTION aRotina Title "Excluir" 		    ACTION "VIEWDEF.LA05A011" OPERATION MODEL_OPERATION_DELETE		ACCESS 0
    ADD OPTION aRotina Title "Importar Metas"   ACTION "StaticCall(LA05A011, GetDocFromPC)" OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina

/*/{Protheus.doc} PosValida

PosValida para Metas de Vendas

@author 	Marcos Natã Santos
@since 		21/06/2019
@version 	12.1.17
@return 	Logico
/*/
Static Function PosValida(oModel)
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()
	
Return lRet

/*/{Protheus.doc} GetDocFromPC

Busca dados (documento) do computador

@author 	Marcos Natã Santos
@since 		24/06/2019
@version 	12.1.17
/*/
Static Function GetDocFromPC()
    Local cPathArq   := ""
    Local cText      := ""
	Local nHandle    := 0
    Local nQtdBytes  := 1000000
    Local aDocs      := {}
	Local aDocsItens := {}
	Local nX         := 0

    cPathArq := cGetFile('Arquivos CSV|*.csv','Selecione um documento de metas de vendas',0,'C:\',.T.,,.F.)
	If Empty(cPathArq)
		MsgAlert("Documento não selecionado.")
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
				AADD(aDocsItens, StrTokArr(aDocs[nX], ";") )
			Next nX

			FClose(nHandle)

			//-- Verifica padrão do layout do arquivo --//
			If aDocsItens[1][1] == "ANO" .And. aDocsItens[1][2] == "MES" .And. aDocsItens[1][3] == "REGIONAL"
				Processa( {|| ProcessDoc(aDocsItens) }, "Aguarde...", "Importando arquivo...", .F.)
			Else
				MsgAlert("Selecione um arquivo válido de metas de vendas.")
				Return
			EndIf
        EndIf
	EndIf

Return

/*/{Protheus.doc} ProcessDoc
Processa importação do documento
@type  Function
@author Marcos Natã Santos
@since 24/06/2019
@version 12.1.17
@param aMetas, array, Metas de Vendas
/*/
Static Function ProcessDoc(aMetas)
	Local aAreaZMT := ZMT->( GetArea() )
	Local nX       := 0
	Local cAno     := ""
	Local cMes     := ""
	Local cRegion  := ""
	Local cVend    := ""
	Local cProduto := ""

	ProcRegua(Len(aMetas)-1)
	For nX := 2 To Len(aMetas) Step 1
		cAno     := PadR(aMetas[nX][1], TamSX3("ZMT_ANO")[1])
		cMes     := PadR(aMetas[nX][2], TamSX3("ZMT_MES")[1])
		cRegion  := PadR(aMetas[nX][3], TamSX3("ZMT_REGION")[1])
		cVend    := PadR(aMetas[nX][4], TamSX3("ZMT_CODVEN")[1])
		cProduto := PadR(aMetas[nX][7], TamSX3("ZMT_CODPRD")[1])

		IncProc( AllTrim(cAno) + " " + AllTrim(cMes) + " " + AllTrim(cRegion) + " " + AllTrim(cVend) )

		ZMT->( dbSetOrder(1) )
		If ZMT->( dbSeek(xFilial("ZMT") + cAno + cMes + cRegion + cVend + cProduto) )
			RecLock("ZMT", .F.)
				ZMT->ZMT_FILIAL := xFilial("ZMT")
				ZMT->ZMT_ANO    := aMetas[nX][1]
				ZMT->ZMT_MES    := aMetas[nX][2]
				ZMT->ZMT_REGION := UPPER( AllTrim(aMetas[nX][3]) )
				ZMT->ZMT_CODVEN := aMetas[nX][4]
				ZMT->ZMT_DESCVE := UPPER( AllTrim(aMetas[nX][5]) )
				ZMT->ZMT_COMERC := StrTran( UPPER(aMetas[nX][6]), "Ã", "A" )
				ZMT->ZMT_CODPRD := aMetas[nX][7]
				ZMT->ZMT_DSCPRD := UPPER( AllTrim(aMetas[nX][8]) )
				ZMT->ZMT_METACX := RealToNum(aMetas[nX][9])
				ZMT->ZMT_METARS := RealToNum(aMetas[nX][10])
			ZMT->( MsUnlock() )
		Else
			RecLock("ZMT", .T.)
				ZMT->ZMT_FILIAL := xFilial("ZMT")
				ZMT->ZMT_ANO    := aMetas[nX][1]
				ZMT->ZMT_MES    := aMetas[nX][2]
				ZMT->ZMT_REGION := UPPER( AllTrim(aMetas[nX][3]) )
				ZMT->ZMT_CODVEN := aMetas[nX][4]
				ZMT->ZMT_DESCVE := UPPER( AllTrim(aMetas[nX][5]) )
				ZMT->ZMT_COMERC := StrTran( UPPER(aMetas[nX][6]), "Ã", "A" )
				ZMT->ZMT_CODPRD := aMetas[nX][7]
				ZMT->ZMT_DSCPRD := UPPER( AllTrim(aMetas[nX][8]) )
				ZMT->ZMT_METACX := RealToNum(aMetas[nX][9])
				ZMT->ZMT_METARS := RealToNum(aMetas[nX][10])
			ZMT->( MsUnlock() )
		EndIf
	Next nX

	RestArea(aAreaZMT)
Return

/*/{Protheus.doc} RealToNum
Converte valor R$ para numérico
@type  Static Function
@author Marcos Natã Santos
@since 24/06/2019
@version 12.1.17
@param cReal, string, Valor em Real
@return nNum, numerico, Valor numerico
/*/
Static Function RealToNum(cReal)
	Local nNum := 0

	cReal := StrTran(cReal, ".")
	cReal := StrTran(cReal, ",", ".")
	nNum  := Val(cReal)
Return nNum
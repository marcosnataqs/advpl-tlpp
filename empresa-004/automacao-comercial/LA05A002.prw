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

/*/{Protheus.doc} LA05A002

Browse para Monitor de Pedidos de Venda

@author 	Marcos Natã Santos
@since 		10/05/2018
@version 	12.1.17
@return 	oBrowse
/*/
User Function LA05A002()
    Local oBrowse   := Nil
	Local cTitulo   :=  "Monitor de Pedidos"
	Local aUserGrp  := UsrRetGrp()
	Local cMVCoServ	:= AllTrim(GetMV("MV_XCOSERV"))
	Local cMVStat3  := AllTrim(GetMV("MV_XSTAT3"))
	Local cMVStat4  := AllTrim(GetMV("MV_XSTAT4"))
	Local nX		:= 0
	Local lFilter	:= .T.

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZN")
	oBrowse:AddLegend("ZN_STATUS == '0' ","BR_PINK"			,"EDI - Divergência de Preços")
	oBrowse:AddLegend("ZN_STATUS == '1' ","BR_BRANCO"		,"Faturamento Programado")
	oBrowse:AddLegend("ZN_STATUS == '2' ","BR_LARANJA"		,"Bloqueio - Prazo Adicional")
	oBrowse:AddLegend("ZN_STATUS == '3' .AND. ZN_REJEITA == 'S' ","BR_AZUL_CLARO"	,"Rejeitado - Regra de Negócio")
	oBrowse:AddLegend("ZN_STATUS == '3' ","BR_AZUL"			,"Bloqueio - Regra de Negócio")
	oBrowse:AddLegend("ZN_STATUS == '4' ","BR_VIOLETA"		,"Bloqueio - Limite de Crédito")
	oBrowse:AddLegend("ZN_STATUS == '5' .AND. ZN_PEDMIN == 'S' ","BR_MARROM_OCEAN" ,"Bloqueio - Pedido Abaixo Mínimo")
	oBrowse:AddLegend("ZN_STATUS == '5' ","BR_PRETO"		,"Bloqueio - Saldos em Estoque")
	oBrowse:AddLegend("ZN_STATUS == '6' ","BR_AMARELO"		,"Liberacao - Liberado Parcialmente")
	oBrowse:AddLegend("ZN_STATUS == '7' .AND. ZN_FATNF == 'N' ","BR_VERDE_ESCURO"	,"Faturamento Pendente")
	oBrowse:AddLegend("ZN_STATUS == '7' ","BR_VERMELHO"		,"Liberacao - Liberado Totalmente")
	oBrowse:AddLegend("ZN_STATUS == '8' ","BR_CANCEL"		,"Erro - Pedido não Integrado")
	oBrowse:AddLegend("ZN_STATUS == '9' ","BR_MARRON"		,"Fracionamento de Carga")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LA05A002")

	For nX:= 1 to Len(aUserGrp)
		If aUserGrp[nX] == "000000" .Or. aUserGrp[nX] $ cMVCoServ
			oBrowse:SetFilterDefault("ZN_STATUS $ '0/1/2/3/4/5/6/7/8/9' .OR. EMPTY(ZN_STATUS) ")
			lFilter := .F.
			Exit
		ElseIf aUserGrp[nX] $ cMVStat3
			oBrowse:SetFilterDefault("ZN_STATUS $ '3' .AND. ZN_REJEITA == ' ' ")
			lFilter := .F.
			Exit
		ElseIf aUserGrp[nX] $ cMVStat4
			oBrowse:SetFilterDefault("ZN_STATUS $ '4' ")
			lFilter := .F.
			Exit
		EndIf
	Next nX
	
	If lFilter
		oBrowse:SetFilterDefault("ZN_STATUS $ '7' ")
	EndIf
	oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef

ModelDef para Monitor de Pedidos de Venda

@author 	Marcos Natã Santos
@since 		10/05/2018
@version 	12.1.17
@return 	oBrowse
/*/
Static Function ModelDef()
	Local oStruSZN := FWFormStruct(1, 'SZN')
	Local oModel
	
	oModel := MPFormModel():New('LA052MOD')
	
	oModel:AddFields('SZNMASTER', /*cOwner*/, oStruSZN)

	oModel:SetPrimaryKey({"ZN_FILIAL","ZN_NUM","ZN_CLIENTE","ZN_LOJA"})

Return oModel

/*/{Protheus.doc} ViewDef

ViewDef

@author 	Marcos Natã Santos
@since 		10/05/2018
@version 	12.1.17
@return 	oView
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel('LA05A002')
	Local oStruSZN := FWFormStruct(2, 'SZN')
	Local oView

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField( 'VIEW_SZN', oStruSZN, 'SZNMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SZN', 'TELA' )

Return oView

/*/{Protheus.doc} MenuDef

MenuDef

@author 	Marcos Natã Santos
@since 		10/05/2018
@version 	12.1.17
@return 	aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Rastro'		     ACTION 'U_LA05RAST()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Liberar'  	     ACTION 'U_LA05LIB()'    OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Reprocessar'       ACTION 'U_LA05PROC()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Histórico'         ACTION 'U_LA05R002()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Rastro Sintético'  ACTION 'U_LA05R004()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Rastro Analítico'  ACTION 'U_LA05R003()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Visualizar Pedido' ACTION 'U_LA05VIS()'    OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Alterar Pedido'    ACTION 'U_LA05ALT()'    OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Excluir Pedido'    ACTION 'U_LA05DEL()'    OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Eliminar/Cortar'   ACTION 'U_LA05ELIM()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Estornar Resíduos' ACTION 'U_LA05RESI()'   OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

/*/{Protheus.doc} LA05RAST

Rastro de Pedidos

@author 	Marcos Natã Santos
@since 		10/05/2018
@version 	12.1.17
/*/
User Function LA05RAST()
	Local cPedido
	Local cCliente
	Local cUserName
	Local cDtEmissao
	Local cItemPai
	Local nCount
	Local aAreaSZN := SZN->(GetArea())
	Local aNota    := {}
	Local cPedCD   := ""
	
	Private aSize := MsAdvSize()

	If FunName() == "LA05A001"
		SZN->( dbSetOrder(1) )
		SZN->( dbSeek(xFilial("SZN") + SZL->ZL_NUM + SZL->ZL_CLIENTE + SZL->ZL_LOJA) )
	EndIf

	cPedido    := AllTrim(SZN->ZN_NUM)
	cCliente   := AllTrim(Posicione("SA1", 1, xFilial("SA1")+PadR(SZN->ZN_CLIENTE,6)+PadR(SZN->ZN_LOJA,2), "A1_NOME"))
	cUserName  := AllTrim(SZN->ZN_USRNAME)
	cDtEmissao := AllTrim(DTOC(SZN->ZN_DATA))
	cItemPai   := "Num Pedido Principal: " + cPedido + "   Cliente: " + cCliente + "   Dt Emissão: " + cDtEmissao
	nCount     := 1

	cQuery := "SELECT C5_NUM NUM, C5_XPVCD PVCD, C5_EMISSAO EMISSAO FROM " + RetSqlName("SC5")
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND C5_FILIAL = '"+ xFilial("SC5") +"' "
	cQuery += "AND C5_XPEDPAI = '"+ cPedido +"' "
	cQuery += "ORDER BY C5_EMISSAO "
	cQuery := ChangeQuery(cQuery)

	If Select("TMP1") > 0
		TMP1->(dbCloseArea())
	EndIf

	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	dbSelectArea("TMP1")
	TMP1->(dbGoTop())

	DEFINE MSDIALOG oDlg TITLE "Rastro de Pedidos" FROM 000,000 TO 600,900 PIXEL
	
		// Cria a Tree
		oTree := DbTree():New(0,0,600,900,oDlg,,,.T.)
			
		// Insere itens
		oTree:AddItem(cItemPai, "001", "FOLDER5", "FOLDER6",,,1)
		While TMP1->(!EOF())
			If oTree:TreeSeek("001")
				nCount++
				oTree:AddItem("Num Pedido Fábrica: " + TMP1->NUM + "   Cliente: " + cCliente + "   Dt Emissão: " + AllTrim(DTOC(STOD(TMP1->EMISSAO))), STRZERO(nCount, 3), "FOLDER5", "FOLDER6",,,2)
				VerPedCD(TMP1->NUM, @cPedCD)
				If oTree:TreeSeek(STRZERO(nCount, 3)) .And. !Empty(cPedCD)
					nCount++
					oTree:AddItem("Num Pedido C.D.: " + cPedCD + "   Cliente: " + cCliente, STRZERO(nCount, 3), "FOLDER5", "FOLDER6",,,2)
					aNota := BuscaNota("0101", AllTrim(cPedCD))
					If Len(aNota) >= 2
						nCount++
						oTree:AddItem("NF C.D.: " + aNota[1] + "   Emissão: " + aNota[2], STRZERO(nCount, 3), "FOLDER5", "FOLDER6",,,2)
					EndIf
					aNota := BuscaNota("0102", AllTrim(TMP1->NUM))
					If Len(aNota) >= 2
						nCount++
						oTree:AddItem("NF Fábrica: " + aNota[1] + "   Emissão: " + aNota[2], STRZERO(nCount, 3), "FOLDER5", "FOLDER6",,,2)
					EndIf
				EndIf
				cPedCD := Space(0)
			EndIf
			TMP1->(dbSkip())
		EndDo
	
		// Indica o término da contrução da Tree
		oTree:EndTree()
 
  	ACTIVATE MSDIALOG oDlg CENTERED

	TMP1->(dbCloseArea())
	RestArea(aAreaSZN)

Return

/*/{Protheus.doc} LA05LIB

Liberação de Bloqueios

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
User Function LA05LIB()
	Local aUserGrp  := UsrRetGrp()
	Local cMVStat4  := AllTrim(GetMV("MV_XSTAT4"))
	Local nX		:= 0
	Local cCode     := ""

	Private cStatus := ""
	Private cNumPed := AllTrim(SZN->ZN_NUM)
	Private cCodCli := AllTrim(SZN->ZN_CLIENTE)
	Private cLoja	:= AllTrim(SZN->ZN_LOJA)
	Private lPedMax := .F.

	cCode := cNumPed + cCodCli + cLoja

	If .Not. MayIUseCode(cCode, RetCodUsr() )
		MsgAlert("Pedido já está sendo liberado por outro usuário. Por favor aguarde.")
		Return
	EndIf

	cStatus := Posicione("SZL", 1, xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA, "ZL_STATUS")

	If !Empty(cStatus)
		If cStatus == "0"
			LIBEDI()
		ElseIf cStatus == "1"
			LIBST1()
		ElseIf cStatus == "2"
			LIBST2()
		ElseIf cStatus == "3"
			If SZN->ZN_REJEITA == "S"
				MsgAlert("Pedido pendente de correção de preços. Por favor aguarde.")
			Else
				LIBST3()
			EndIf
		ElseIf cStatus == "4"
			For nX := 1 To Len(aUserGrp)
				If aUserGrp[nX] $ cMVStat4 .Or. aUserGrp[nX] == "000000"
					LIBST4()
					Exit
				ElseIf nX = Len(aUserGrp)
					MsgAlert("Usuário não autorizado a realizar esta operação.")
				EndIf
			Next nX
		ElseIf cStatus $ "5/6/9"
			LIBST5()
		ElseIf cStatus == "8"
			MsgAlert("Pedido não integrado. Por favor reprocessar pedido.")
		Else
			MsgAlert("Pedido de venda totalmente liberado.")
		EndIf
	Else
		MsgAlert("Status do pedido de venda não encontrado. Favor verificar com Administrador.")
	EndIf

	Leave1Code(cCode)

Return

/*/{Protheus.doc} LA05PROC

Reprocessa Pedido de Venda

@author 	Marcos Natã Santos
@since 		07/06/2018
@version 	12.1.17
/*/
User Function LA05PROC()
	Local lRet := .T.
	Local cQry
	Local nQtdReg

	Private cStatus
	Private cNumPed := AllTrim(SZN->ZN_NUM)
	Private cCodCli := AllTrim(SZN->ZN_CLIENTE)
	Private cLoja	:= AllTrim(SZN->ZN_LOJA)
	Private lPedMax := .F.

	cStatus := Posicione("SZL", 1, xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA, "ZL_STATUS")

	If cStatus $ "6/7/8/9"
		cQry := "SELECT C5_NUM PV, C5_XPVCD PVCD " + CRLF
		cQry += "FROM "+ RetSqlName("SC5") + CRLF
		cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry += "AND C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
		cQry += "AND C5_XPEDPAI = '"+ SZN->ZN_NUM +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("TMPRPROC") > 0
			TMPRPROC->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "TMPRPROC"

		TMPRPROC->(dbGoTop())
		COUNT TO nQtdReg
		TMPRPROC->(dbGoTop())

		If nQtdReg > 0
			While TMPRPROC->(!EOF())
				If VerPedCD( AllTrim(TMPRPROC->PV) )
					If MsgNoYes("Deseja Reprocessar o Pedido "+ AllTrim(TMPRPROC->PV) +" ?", "Reprocessamento de Pedido")
						lRet := .F.
						Processa( {|| ProcCD() }, "Reprocessando Pedido de Venda",/*cMsg*/,.F.)
					EndIf
				EndIf
				TMPRPROC->(dbSkip())
			EndDo
		EndIf

		TMPRPROC->(DbCloseArea())

		If cStatus <> "7"
			If SldAProcess(SZN->ZN_NUM, SZN->ZN_CLIENTE, SZN->ZN_LOJA)
				If MsgNoYes("Deseja Reprocessar o Pedido?", "Reprocessamento de Pedido")
					lRet := .F.
					Processa( {|| ProcPed() }, "Processando Pedido de Venda",/*cMsg*/,.F.)
				EndIf
			EndIf
		EndIf

		If lRet
			MsgAlert("Pedido de venda totalmente processado.")
		EndIf
	ElseIf cStatus $ "1/2/3/4/5"
		MsgAlert("Pedido de venda com liberações pendentes.")
	ElseIf Empty( AllTrim(cStatus) ) //-- Sem Legenda --//
		LIBST3(.T.) // Reprocessa validações
	Else
		MsgAlert("Pedido de venda totalmente processado.")
	EndIf

Return

/*/{Protheus.doc} LIBEDI

Liberar Divergência de Preços para EDI

@author 	Marcos Natã Santos
@since 		07/03/2019
@version 	12.1.17
@return     lRet, Lógico
/*/
Static Function LIBEDI()
	Local lRet       := .F.
	Local cTabPrc    := AllTrim( Posicione("SA1",1,xFilial("SA1")+SZN->ZN_CLIENTE+SZN->ZN_LOJA,"A1_TABELA") )
	Local cNumPedido := ""
	Local cTabela    := ""
	Local cCliente   := ""

	Local oCancel
	Local oGroup1
	Local oLiberar
	Local oSay1
	Local oSay2
	Local oSay3
	Static oDlg

	cNumPedido := "Num. Pedido: " + AllTrim(SZN->ZN_NUM)
	cTabela    := "Tabela Preço: " + cTabPrc + " - " + AllTrim( Posicione("DA0",1,xFilial("DA0")+cTabPrc, "DA0_DESCRI") )
	cCliente   := "Cliente: " + SZN->ZN_CLIENTE + "-" + SZN->ZN_LOJA + "   " + AllTrim(SZN->ZN_NOMECLI)

	DEFINE MSDIALOG oDlg TITLE "Liberação Divergência de Preços" FROM 000, 000  TO 300, 800 COLORS 0, 16777215 PIXEL

		@ 002, 015 GROUP oGroup1 TO 042, 385 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
		@ 015, 025 SAY oSay1 PROMPT cNumPedido SIZE 075, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 025, 025 SAY oSay2 PROMPT cTabela    SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 015, 165 SAY oSay3 PROMPT cCliente   SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
		fMSNewGe2()
		@ 130, 340 BUTTON oCancel  PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
		@ 130, 282 BUTTON oLiberar PROMPT "Liberar"  SIZE 050, 012 OF oDlg ACTION {|| oDlg:End(), lRet := .T. } PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
		aRegPed   := {}
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"0",; // Status
						"Liberação - Divergência de Preços"}) // Obs
		
		StaticCall( LA05A001 , PUT_HIST , aRegPed )

		LIBST3()
	Else
		AltStatus("0") // EDI - Divergência de Preços
	EndIf

Return lRet

/*/{Protheus.doc} LIBST1

Liberar Pedido Programado

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
Static Function LIBST1()
	Local lRet     := .F.
	Local aAreaSZL := SZL->(GetArea())

	SZL->(dbSetOrder(1))
	If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
		lRet := MsgNoYes("Pedido Programado para "+ AllTrim(DTOC(SZL->ZL_DTFATPR)) +". Deseja Processar Pedido?")
	EndIf

	RestArea(aAreaSZL)

	If lRet
		aRegPed   := {}
		AADD(aRegPed,{ 	cNumPed,;
						cCodCli,;
						cLoja,;
						"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
						Date(),;
						Time(),;
						RetCodUsr(),;
						CUSERNAME,;
						"1",; // Status
						"Liberação - Faturamento Programado"}) // Obs
		
		StaticCall( LA05A001 , PUT_HIST , aRegPed )

		LIBST2()
	Else
		AltStatus("1") // Faturamento Programado
	EndIf

Return lRet

/*/{Protheus.doc} LIBST2

Liberar Prazo Adicional

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
Static Function LIBST2()
	Local lRet      := .F.
	Local aAreaSZL  := SZL->(GetArea())
	Local cVendedor := ""
	Local cSolicita := ""
	Local cCondPag  := AllTrim(Posicione("SA1",1,xFilial("SA1")+PadR(SZL->ZL_CLIENTE,6)+SZL->ZL_LOJA, "A1_COND"))
	Local cCondCli  := ""
	Local cCondSel	:= ""

	If cStatus == "2"
		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			cVendedor := "Vendedor: " + AllTrim(Posicione("SA3",1,xFilial("SA3")+SZL->ZL_VEND, "A3_NOME"))
			cSolicita := "Solicitação: " + AllTrim(SZL->ZL_OBSPRZ)
			cCondCli  := "Cond. Pag. Cliente: " + AllTrim(Posicione("SE4",1,xFilial("SE4")+cCondPag, "E4_DESCRI"))
			cCondSel  := "Cond. Pag. Selecionada: " + AllTrim(SZL->ZL_DESCOND)
			lRet := MsgNoYes(cVendedor + CRLF + cSolicita + CRLF + cCondCli + CRLF + cCondSel + CRLF + CRLF + "Confirmar Liberação?")
		EndIf

		If lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"2",; // Status
							"Liberação - Prazo Adicional"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )
		EndIf
	Else
		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			If SZL->ZL_TPVEND == "1" //-- Apenas Vendas
				If SZL->ZL_PRZADC = .F.
					lRet := .T.
				EndIf
				If .Not. (AllTrim(SZL->ZL_CONDPAD) $ "001/" + cCondPag)
					lRet := .F.
				EndIf
			Else
				lRet := .T.
			EndIf
		EndIf

		If .Not. lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							"000000",;
							"SISTEMA",;
							"2",; // Status
							"Bloqueio - Prazo Adicional"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf
	EndIf

	RestArea(aAreaSZL)

	If lRet
		LIBST3()
	Else
		AltStatus("2") // Bloqueio - Prazo Adicional
	EndIf

Return lRet

/*/{Protheus.doc} LIBST3

Liberar Regra de Negócio

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
@param      lProc, lógico, Processa na alteração de pedido
/*/
Static Function LIBST3(lProc)
	Local lRet     := .T.
	Local nPerDesc := 0
	Local cQry     := ""
	Local aAreaSZL := SZL->(GetArea())
	Local cNomeCli
	Local cVendedor
	Local cModalidade
	Local cSegmento
	Local cCanal
	Local cRegional
	Local cTotalPed
	Local cTotalItens
	Local cTotalBloq
	Local aUserGrp  := UsrRetGrp()
	Local cMVStat3  := AllTrim(GetMV("MV_XSTAT3"))
	Local nX        := 0
	Local lRej      := .F.
	
	Local oButton1
	Local oButton2
	Local oGroup
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Static oDlg

	Private nTotItens := 0
	Private nTotBloq  := 0

	Default lProc := .F.

	If cStatus == "3" .And. .Not. lProc

		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			cNomeCli	:= "Cliente: " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + PadR(SZN->ZN_CLIENTE,6) + SZN->ZN_LOJA, "A1_NREDUZ")) + " - "
			cNomeCli    += AllTrim(Posicione("SA1",1,xFilial("SA1")+PadR(SZL->ZL_CLIENTE,6)+SZL->ZL_LOJA, "A1_EST"))
			cModalidade := "Modalidade: " + IIF(SZL->ZL_MODALID == "1","DIRETO","INDIRETO")
			cSegmento   := "Segmento: " + AllTrim(Posicione("SX5",1,xFilial("SX5")+"Z6"+SZL->ZL_SEGMENT, "X5_DESCRI"))
			cCanal		:= "Canal: " + AllTrim(Posicione("SX5",1,xFilial("SX5")+"Z8"+SZL->ZL_CANAL, "X5_DESCRI"))
			cRegional   := "Regional: " + AllTrim(Posicione("SX5",1,xFilial("SX5")+"Z7"+SZL->ZL_REGNL, "X5_DESCRI"))
			cVendedor   := "Vendedor: " + AllTrim(Posicione("SA3",1,xFilial("SA3")+SZL->ZL_VEND, "A3_NOME"))
			cTotalPed   := "Total Pedido: " + AllTrim(TRANSFORM(TotPed(), PesqPict("SZM", "ZM_TOTAL")))
		EndIf

		RestArea(aAreaSZL)

		DEFINE MSDIALOG oDlg TITLE "Liberação Regra de Negócio" STYLE 128 FROM 000, 000  TO 400, 1000 COLORS 0, 16777215 PIXEL

			@ 011, 010 GROUP oGroup TO 066, 485 PROMPT "Dados do Cliente" OF oDlg COLOR 0, 16777215 PIXEL
			@ 022, 015 SAY oSay1 PROMPT cNomeCli 	SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 015 SAY oSay2 PROMPT cModalidade SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 175 SAY oSay3 PROMPT cSegmento 	SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 042, 015 SAY oSay4 PROMPT cCanal 		SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 042, 175 SAY oSay5 PROMPT cRegional 	SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 052, 015 SAY oSay6 PROMPT cVendedor 	SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 325 SAY oSay7 PROMPT cTotalPed   SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL

			fMSNewGet()

			cTotalItens := "Total Itens: " + cValToChar(nTotItens)
			cTotalBloq := "Total Bloq.: " + AllTrim(TRANSFORM(nTotBloq, PesqPict("SZM", "ZM_TOTAL")))
			@ 042, 325 SAY oSay8 PROMPT cTotalItens SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 052, 325 SAY oSay9 PROMPT cTotalBloq  SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL

			For nX := 1 To Len(aUserGrp)
				If aUserGrp[nX] $ cMVStat3 .Or. aUserGrp[nX] == "000000"
					@ 181, 435 BUTTON oButton1 PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| lRet := .F., oDlg:End()} PIXEL
					@ 181, 375 BUTTON oButton2 PROMPT "Liberar"  SIZE 050, 012 OF oDlg ACTION {|| lRet := .T., oDlg:End()} PIXEL
					@ 181, 315 BUTTON oButton2 PROMPT "Rejeitar" SIZE 050, 012 OF oDlg ACTION {|| lRet := .F., lRej := .T., oDlg:End()} PIXEL
					Exit
				ElseIf nX = Len(aUserGrp)
					@ 181, 435 BUTTON oButton1 PROMPT "Fechar" SIZE 050, 012 OF oDlg ACTION {|| lRet := .F., oDlg:End()} PIXEL
				EndIf
			Next nX

		ACTIVATE MSDIALOG oDlg CENTERED

		If lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"3",; // Status
							"Liberação - Regra de Negócio"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

		ElseIf lRej
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
							"Rejeitado - Regra de Negócio"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf

	Else
		cQry := "SELECT ZM_PRODUTO, ZM_PERDESC FROM "+ RetSqlName("SZM") + CRLF
		cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
		cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
		cQry += "AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
		cQry += "AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
		cQry += "AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
		cQry := ChangeQuery(cQry)

		If Select("TMP1") > 0
			TMP1->(DbCloseArea())
		EndIf

		TcQuery cQry New Alias "TMP1"

		TMP1->(dbGoTop())

		While TMP1->(!EOF())
			nPerDesc := ValDesconto(AllTrim(TMP1->ZM_PRODUTO))
			If nPerDesc > 0 .And. TMP1->ZM_PERDESC > 0
				If TMP1->ZM_PERDESC > nPerDesc
					lRet := .F.
				EndIf
			ElseIf TMP1->ZM_PERDESC > 0
				lRet := .F.
			EndIf

			TMP1->(dbSkip())
		EndDo

		TMP1->(DbCloseArea())

		If .Not. lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							"000000",;
							"SISTEMA",;
							"3",; // Status
							"Bloqueio - Regra de Negócio"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf
		
	EndIf

	If lRet
		LIBST4(lProc)
	Else
		AltStatus("3", lRej) // Bloqueio - Regra de Negócio
	EndIf

Return lRet

/*/{Protheus.doc} LIBST4

Liberar Limite de Crédito

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
Static Function LIBST4(lProc)
	Local lRet     := .T.
	Local cRisco   := AllTrim(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_RISCO"))
	Local cBloq	   := AllTrim(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_MSBLQL"))
	Local cCodCP   := AllTrim(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_COND"))
	Local cTpVenda := AllTrim(Posicione("SZL",1,xFilial("SZL")+cNumPed+cCodCli+cLoja,"ZL_TPVEND"))
	Local aAreaSZL := SZL->(GetArea())
	Local cCondPed := ""
	Local cCondCli := ""
	Local cCliRisco:= ""
	Local cLtCred  := ""
	Local cPedido  := ""
	Local cTotalPed:= ""

	Local oCancelar
	Local oCliente
	Local oGroup1
	Local oGroup2
	Local oLiberar
	Local oPedido
	Local oPosicao
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local bPed := {|| FWExecView( 'Visualização','LA05A001', MODEL_OPERATION_VIEW,,{ || .T. } ) }
	Static oDlg

	//------------------------------------------
	// Necessário para chamada de rotinas padrão
	//------------------------------------------
	Private cCadastro := "Cliente - Visualização"
	Private	aRotina := {{"","PesqBrw"	, 0 , 1,0,.F.},;// "Pesquisar"
						{"","A450LibAut", 0 , 2,0,NIL},;// "Automática"
						{"","A450LibMan", 0 , 4,0,NIL},;// "Manual"
						{"","A450Legend", 0 , 3,0,.F.}}	// "Legenda"

	Default lProc := .F.

	If cStatus == "4" .And. .Not. lProc

		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			cNomeCli	:= "Cliente: " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + PadR(SZN->ZN_CLIENTE,6) + SZN->ZN_LOJA, "A1_NREDUZ")) + " - "
			cNomeCli    += AllTrim(Posicione("SA1",1,xFilial("SA1")+PadR(SZL->ZL_CLIENTE,6)+SZL->ZL_LOJA, "A1_EST"))
			cCondPed    := "Cond. Pedido: " + AllTrim(SZL->ZL_DESCOND)
			cCondCli    := "Cond. Cliente: " + AllTrim(Posicione("SE4",1,xFilial("SE4")+cCodCP, "E4_DESCRI"))
			cCliRisco   := "Risco: " + AllTrim(cRisco)
			cLtCred     := "Limite Crédito: " + AllTrim(TRANSFORM(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_LC"), PesqPict("SA1", "A1_LC")))
			cPedido     := "Pedido: " + AllTrim(SZN->ZN_NUM)
			cTotalPed	:= "Total Pedido: " + AllTrim(TRANSFORM(TotPed(), PesqPict("SZM", "ZM_TOTAL")))
		EndIf

		SA1->(dbSetOrder(1))
		SA1->( dbSeek(xFilial("SA1")+cCodCli+cLoja) )

		DEFINE MSDIALOG oDlg TITLE "Liberação de Crédito" STYLE 128 FROM 000, 000 TO 215, 520 COLORS 0, 16777215 PIXEL

			@ 010, 010 GROUP oGroup1 TO 075, 250 OF oDlg COLOR 0, 16777215 PIXEL
			@ 025, 015 SAY oSay1 PROMPT cNomeCli  SIZE 125, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 035, 015 SAY oSay2 PROMPT cCondPed  SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 045, 015 SAY oSay3 PROMPT cCliRisco SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 025, 140 SAY oSay4 PROMPT cLtCred   SIZE 085, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 035, 140 SAY oSay7 PROMPT cCondCli  SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 055, 015 SAY oSay5 PROMPT cPedido   SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 055, 140 SAY oSay6 PROMPT cTotalPed SIZE 075, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 077, 010 GROUP oGroup2 TO 100, 148 OF oDlg COLOR 0, 16777215 PIXEL
			@ 083, 015 BUTTON oPosicao  PROMPT "Posicao" SIZE 037, 012 OF oDlg ACTION IIF( Pergunte("FIC010",.T.), Fc010Con(), ) PIXEL
			@ 083, 060 BUTTON oCliente  PROMPT "Cliente" SIZE 037, 012 OF oDlg ACTION A030Visual("SA1",SA1->(RecNo()),1) PIXEL
			@ 083, 105 BUTTON oPedido   PROMPT "Pedido" SIZE 037, 012 OF oDlg ACTION Eval(bPed) PIXEL
			@ 083, 155 BUTTON oLiberar  PROMPT "Liberar" SIZE 045, 012 OF oDlg ACTION {|| oDlg:End(), lRet := .T. } PIXEL
			@ 083, 205 BUTTON oCancelar PROMPT "Cancelar" SIZE 045, 012 OF oDlg ACTION {|| oDlg:End(), lRet := .F. } PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

		If lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"4",; // Status
							"Liberação - Limite de Crédito"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

		EndIf

		RestArea(aAreaSZL)

	Else

		If cTpVenda == "1"
			If cBloq <> "1" // 1=Inativo ; 2=Ativo
				If cRisco <> "A"
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf

		If .Not. lRet
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							"000000",;
							"SISTEMA",;
							"4",; // Status
							"Bloqueio - Limite de Crédito"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf

	EndIf

	If lRet
		LIBST5(lProc)
	Else
		AltStatus("4") // Bloqueio - Limite de Crédito
	EndIf

Return lRet

/*/{Protheus.doc} LIBST5

Liberar Saldo em Estoque

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
Static Function LIBST5(lProc)
	Local lRet         := .T.
	Local aAreaSZM     := SZM->(GetArea())
	Local aAreaSZL     := SZL->(GetArea())
	Local cPedido      := ""
	Local nVlrPedMin   := StaticCall( LA05A001 , VlrPedMin , SZN->ZN_CLIENTE, SZN->ZN_LOJA )
	Local nMVPedMax	   := SUPERGETMV("MV_XPEDMAX", .F., 150000)
	Local lMVBlqEst	   := SUPERGETMV("MV_XBLQEST", .F., .T.)
	Local cValPed      := ""
	Local cPedMin      := ""
	Local cPedMax	   := ""
	Local cFatCom      := ""
	Local cDescTipo    := ""
	Local cAceitaFrac  := ""
	Local lParcial     := .F.
	Local nValTotal    := 0
	Local lFatCompleto := Posicione("SZL",1,xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA, "ZL_FATCPLT")
	Local nSaldoAtu	   := 0
	Local nValMax	   := 0
	Local lNaoPedBoni  := NaoPedBoni(SZN->ZN_NUM)

	Local oCancel
	Local oGroup1
	Local oLiberar
	Local oPedido
	Local oCalcLib
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local bPed := {|| FWExecView( 'Visualização','LA05A001', MODEL_OPERATION_VIEW,,{ || .T. } ) }
	Static oDlg

	Private oGet
	Private lApenasCorte := .F.
	Private cValLib

	Default lProc := .F.

	If cStatus $ "5/6/9" .And. .Not. lProc

		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			cPedido     := "Num. Pedido: " + AllTrim(SZN->ZN_NUM)
			cValPed     := "Valor Pedido: " + AllTrim(TRANSFORM(TotPed(), PesqPict("SZM", "ZM_TOTAL")))
			cValLib     := "Valor Liberação: " + AllTrim(TRANSFORM(0, PesqPict("SZM", "ZM_TOTAL")))
			cPedMin     := "Pedido Min.: " + AllTrim(TRANSFORM(nVlrPedMin, PesqPict("SZM", "ZM_TOTAL")))
			cPedMax     := "Pedido Max.: " + AllTrim(TRANSFORM(nMVPedMax, PesqPict("SZM", "ZM_TOTAL")))
			cDescTipo   := "Tipo: " + IIF(SZL->ZL_TPVEND == "1", "Venda", "Bonificação")
			cFatCom     := "Fat. Completo: " + IIF(SZL->ZL_FATCPLT, "Sim", "Não")
			cAceitaFrac := "Aceita Fracion.: ";
				+ IIF(POSICIONE("SA1",1,xFilial("SA1")+SZL->ZL_CLIENTE+SZL->ZL_LOJA,"A1_XFRACIO") == "S", "Sim", "Não")
		EndIf

		DEFINE MSDIALOG oDlg TITLE "Liberação de Estoque" STYLE 128 FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL

			@ 010, 010 GROUP oGroup1 TO 060, 390 OF oDlg COLOR 0, 16777215 PIXEL
			@ 020, 015 SAY oSay1 PROMPT cPedido     SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 020, 130 SAY oSay2 PROMPT cValPed     SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 020, 245 SAY oSay3 PROMPT cPedMin     SIZE 110, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 245 SAY oSay5 PROMPT cPedMax     SIZE 110, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 130 SAY oSay6 PROMPT cValLib     SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 032, 015 SAY oSay7 PROMPT cDescTipo   SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 045, 015 SAY oSay4 PROMPT cFatCom     SIZE 090, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 045, 085 SAY oSay8 PROMPT cAceitaFrac SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL

			oGet := fMSNewGe1()

			@ 182, 339 BUTTON oCancel  PROMPT "Cancelar" SIZE 050, 012 OF oDlg ACTION {|| lRet := .F., oDlg:End()} PIXEL
			@ 182, 282 BUTTON oLiberar PROMPT "Liberar"  SIZE 050, 012 OF oDlg ACTION {|| lRet := LibEst()} PIXEL
			@ 182, 010 BUTTON oPedido  PROMPT "Pedido"   SIZE 050, 012 OF oDlg ACTION Eval(bPed) PIXEL
			@ 182, 065 BUTTON oCalcLib PROMPT "Calcular Liberação" SIZE 050, 012 OF oDlg ACTION {||CalcLib()} PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

		If cStatus == "5" .And. lRet .And. !lApenasCorte
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"5",; // Status
							"Liberação - Saldos em Estoque"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

		EndIf

	Else

		SZM->(dbSetOrder(1))
		SZM->(dbGoTop())
		If SZM->( dbSeek(xFilial("SZM")+SZN->ZN_NUM+SZN->ZN_CLIENTE+SZN->ZN_LOJA) )
			While SZM->(!EOF()) .And. SZM->ZM_FILIAL  = xFilial("SZM");
								.And. SZM->ZM_NUM     = SZN->ZN_NUM;
								.And. SZM->ZM_CLIENTE = SZN->ZN_CLIENTE;
								.And. SZM->ZM_LOJA    = SZN->ZN_LOJA

				RecLock("SZM", .F.)
				SZM->ZM_LIBER := "1" //-- Prepara status para reavaliação --//
				SZM->(MsUnlock())
				
				nValMax += SZM->ZM_TOTAL

				nSaldoAtu := StaticCall( LA05A001 , ValSaldoEstoque ,;
					AllTrim(SZM->ZM_PRODUTO) , SZM->ZM_CLIENTE , SZM->ZM_LOJA, SZM->ZM_QTD )

				If nSaldoAtu < SZM->ZM_QTD .And. nSaldoAtu > 0
					RecLock("SZM", .F.)
					SZM->ZM_QTDLIB  := nSaldoAtu
					SZM->ZM_QTDPROC := nSaldoAtu
					SZM->(MsUnlock())
					nValTotal += ( nSaldoAtu * SZM->ZM_VALOR )
					lParcial := .T.
				ElseIf nSaldoAtu <= 0
					RecLock("SZM", .F.)
					SZM->ZM_LIBER := "2"
					SZM->(MsUnlock())
					lParcial := .T.
				EndIf

				If SZM->ZM_LIBER == "1" .And. SZM->ZM_QTDLIB = 0
					RecLock("SZM", .F.)
					SZM->ZM_QTDLIB  := SZM->ZM_QTD
					SZM->ZM_QTDPROC := SZM->ZM_QTD
					SZM->(MsUnlock())
					nValTotal += SZM->ZM_TOTAL
				EndIf

				SZM->(dbSkip())
			EndDo
		EndIf


		//-- Limpa status de pedido mínimo --//
		If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
			RecLock("SZL", .F.)
			SZL->ZL_PEDMIN := Space(1)
			SZL->( MsUnlock() )
			RecLock("SZN", .F.)
			SZN->ZN_PEDMIN := Space(1)
			SZN->( MsUnlock() )
		EndIf

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
			.Or. ContemOutRosa() .Or. StaticCall(LA05A001, CliNaoProc, cCodCli)

			If (nValTotal < nVlrPedMin)
				If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
					RecLock("SZL", .F.)
					SZL->ZL_PEDMIN := "S"
					SZL->( MsUnlock() )
					RecLock("SZN", .F.)
					SZN->ZN_PEDMIN := "S"
					SZN->( MsUnlock() )
				EndIf
			EndIf

			SZM->(dbGoTop())
			If SZM->( dbSeek(xFilial("SZM")+SZN->ZN_NUM+SZN->ZN_CLIENTE+SZN->ZN_LOJA) )
				While SZM->(!EOF()) .And. SZM->ZM_FILIAL  = xFilial("SZM");
									.And. SZM->ZM_NUM     = SZN->ZN_NUM;
									.And. SZM->ZM_CLIENTE = SZN->ZN_CLIENTE;
									.And. SZM->ZM_LOJA    = SZN->ZN_LOJA
					
					RecLock("SZM", .F.)
					SZM->ZM_LIBER   := "2"
					SZM->ZM_QTDLIB  := 0
					SZM->ZM_QTDPROC := 0
					SZM->(MsUnlock())

					SZM->(dbSkip())
				EndDo
			EndIf
		EndIf

		//----------------------------------------------------------
		//-- Verifica se existe bloqueio para fracionamento de carga
		//----------------------------------------------------------
		If nValMax >= nMVPedMax
			lPedMax := .T.

			SZM->(dbGoTop())
			If SZM->( dbSeek(xFilial("SZM")+SZN->ZN_NUM+SZN->ZN_CLIENTE+SZN->ZN_LOJA) )
				While SZM->(!EOF()) .And. SZM->ZM_FILIAL  = xFilial("SZM");
									.And. SZM->ZM_NUM     = SZN->ZN_NUM;
									.And. SZM->ZM_CLIENTE = SZN->ZN_CLIENTE;
									.And. SZM->ZM_LOJA    = SZN->ZN_LOJA
					
					RecLock("SZM", .F.)
					SZM->ZM_LIBER   := "2"
					SZM->ZM_QTDLIB  := 0
					SZM->ZM_QTDPROC := 0
					SZM->(MsUnlock())

					SZM->(dbSkip())
				EndDo
			EndIf
		EndIf

		lRet := StatEst("1")

		If .Not. lRet .And. .Not. lPedMax
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							"000000",;
							"SISTEMA",;
							"5",; // Status
							"Bloqueio - Saldos em Estoque"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		ElseIf lPedMax
			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"1",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							"000000",;
							"SISTEMA",;
							"9",; // Status
							"Bloqueio - Fracionamento de Carga"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf
	EndIf

	If lRet .And. cStatus == "9"
		Processa( {|| ProcPed(.T.) }, "Processando Pedido de Venda",/*cMsg*/,.F.)
	ElseIf lRet
		Processa( {|| ProcPed() }, "Processando Pedido de Venda",/*cMsg*/,.F.)
	Else
		If cStatus == "6"
			AltStatus(cStatus) // Liberacao - Liberado Parcialmente
		ElseIf cStatus == "9"
			AltStatus("9") // Fracionamento de Carga
		ElseIf lPedMax
			AltStatus("9") // Fracionamento de Carga
		Else
			AltStatus("5") // Bloqueio - Saldos em Estoque
		EndIf
	EndIf

	RestArea(aAreaSZM)
	RestArea(aAreaSZL)

Return lRet

/*/{Protheus.doc} AltStatus

Alterar Status do Pedido de Venda

@author 	Marcos Natã Santos
@since 		30/05/2018
@version 	12.1.17
/*/
Static Function AltStatus(cStPed,lRejeita)
	Local aAreaSZL := SZL->(GetArea())
	Local aAreaSZN := SZN->(GetArea())

	Default lRejeita := .F.

	SZL->(dbSetOrder(1))
	If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
		RecLock("SZL", .F.)
		SZL->ZL_STATUS := cStPed
		SZL->(MsUnlock())

		RecLock("SZN", .F.)
		SZN->ZN_STATUS := cStPed
		SZN->(MsUnlock())

		//------------------------------------
		// Status
		// 1=Liberado 2=Bloqueado 3=Aguardando
		//------------------------------------
		If cStPed == "2"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "2"
			SZN->(MsUnlock())
		ElseIf cStPed == "3"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "1"
			SZN->ZN_BLNEGOC := "2"
			SZN->(MsUnlock())
			If lRejeita
				RecLock("SZN", .F.)
				SZN->ZN_REJEITA := "S"
				SZN->(MsUnlock())
				RecLock("SZL", .F.)
				SZL->ZL_REJEITA := "S"
				SZL->(MsUnlock())
			Else
				RecLock("SZN", .F.)
				SZN->ZN_REJEITA := Space(1)
				SZN->(MsUnlock())
				RecLock("SZL", .F.)
				SZL->ZL_REJEITA := Space(1)
				SZL->(MsUnlock())
			EndIf
		ElseIf cStPed == "4"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "1"
			SZN->ZN_BLNEGOC := "1"
			SZN->ZN_BLCRED  := "2"
			SZN->(MsUnlock())
		ElseIf cStPed == "5" .Or. cStPed == "6"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "1"
			SZN->ZN_BLNEGOC := "1"
			SZN->ZN_BLCRED  := "1"
			SZN->ZN_BLEST   := "2"
			SZN->(MsUnlock())
		ElseIf cStPed == "7"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "1"
			SZN->ZN_BLNEGOC := "1"
			SZN->ZN_BLCRED  := "1"
			SZN->ZN_BLEST   := "1"
			SZN->(MsUnlock())
		ElseIf cStPed == "9"
			RecLock("SZN", .F.)
			SZN->ZN_BLPRADC := "1"
			SZN->ZN_BLNEGOC := "1"
			SZN->ZN_BLCRED  := "1"
			SZN->ZN_BLEST   := "2"
			SZN->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaSZL)
	RestArea(aAreaSZN)
Return

/*/{Protheus.doc} ProcPed

Gera pedido de venda nas tabelas SC5/SC6
Realiza as liberações do pedido para SC9
Gera pedido de venda no Centro de Distribuição

@author 	Marcos Natã Santos
@since 		06/06/2018
@version 	12.1.17
/*/
Static Function ProcPed(lPedMax)
	Local nProcCount := 4
	Local cNumPed	 := AllTrim(SZN->ZN_NUM)
	Local cCodCli	 := AllTrim(SZN->ZN_CLIENTE)
	Local cLoja		 := AllTrim(SZN->ZN_LOJA)
	Local nIDSZL	 := 0
	Local aAreaSZL   := SZL->(GetArea())
	Local aAreaSZM   := SZM->(GetArea())
	Local aCab	   	 := {}
	Local aCabec	 := {}
	Local aItens	 := {}
	Local cLog       := ""

	Private lMsHelpAuto := .T.
	Private lMSErroAuto := .F.

	Default lPedMax := .F.

	ConOut("LA05A002 LIBERAÇÃO PEDIDO " + cNumPed + ": Início " + DTOC(Date()) + " - " + Time())

	ProcRegua(nProcCount)

	aCab	:= StaticCall( LA05A001 , PED_CAB , cNumPed ,  cCodCli , cLoja )
	nIDSZL	:= aCab[1]
	aCabec	:= aCab[2]
	aItens	:= StaticCall( LA05A001 , PED_ITM , cNumPed ,  cCodCli , cLoja, aCab[3] )
	
	If Len(aCabec) > 0 .and. Len(aItens) > 0
		IncProc("Processando Pedido na Fábrica...")
		MATA410(aCabec,aItens,3)
		
		If !lMsErroAuto
			
			// ConfirmSX8() // Confirma numeração sequencial

			DbSelectArea("SZL")
			DbGOTO(nIDSZL)

			If StatEst("2") .And. lPedMax
				RecLock("SZL",.F.)
					SZL->ZL_STATUS := "9" // Fracionamento de Carga
				SZL->(MsUnlock())

				RecLock("SZN",.F.)
					SZN->ZN_STATUS  := "9" // Fracionamento de Carga
					SZN->ZN_BLPRADC := "1"
					SZN->ZN_BLNEGOC := "1"
					SZN->ZN_BLCRED  := "1"
					SZN->ZN_BLEST   := "2"
				SZN->(MsUnlock())

				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								Date(),;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"9",; // Status
								"Liberação - Fracionamento de Carga"}) // Obs
				
				StaticCall( LA05A001 , PUT_HIST , aRegPed )

			ElseIf StatEst("2")
				RecLock("SZL",.F.)
					SZL->ZL_STATUS := "6" // Faturamento Parcial
				SZL->(MsUnlock())

				RecLock("SZN",.F.)
					SZN->ZN_STATUS  := "6" // Faturamento Parcial
					SZN->ZN_BLPRADC := "1"
					SZN->ZN_BLNEGOC := "1"
					SZN->ZN_BLCRED  := "1"
					SZN->ZN_BLEST   := "2"
				SZN->(MsUnlock())

				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								Date(),;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"6",; // Status
								"Liberação - Pedido liberado parcialmente"}) // Obs
				
				StaticCall( LA05A001 , PUT_HIST , aRegPed )

				//-------------------------
				//-- Workflow Status Pedido
				//-------------------------
				U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])

			Else
				RecLock("SZL",.F.)
					SZL->ZL_STATUS := "7" // Faturamento Total
				SZL->(MsUnlock())

				RecLock("SZN",.F.)
					SZN->ZN_STATUS  := "7" // Faturamento Total
					SZN->ZN_BLPRADC := "1"
					SZN->ZN_BLNEGOC := "1"
					SZN->ZN_BLCRED  := "1"
					SZN->ZN_BLEST   := "1"
				SZN->(MsUnlock())

				aRegPed   := {}
				AADD(aRegPed,{ 	cNumPed,;
								cCodCli,;
								cLoja,;
								"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
								Date(),;
								Time(),;
								RetCodUsr(),;
								CUSERNAME,;
								"7",; // Status
								"Liberação - Pedido liberado totalmente"}) // Obs
				
				StaticCall( LA05A001 , PUT_HIST , aRegPed )

				//-------------------------
				//-- Workflow Status Pedido
				//-------------------------
				U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
			EndIf
			
			Conout("--------------------------------------------------------------------------------------")
			Conout("")
			Conout("LA05A002 - ( " +	Dtoc(DATE()) +" as "+ Time()+ " ) -  Pedido de Venda "+ AllTrim(cNumPed) +" Incluido com Sucesso...")
			Conout("")
			Conout("--------------------------------------------------------------------------------------")

			//-----------------------------
			// Limpa quantidade em processo
			//-----------------------------
			SZM->(dbSetOrder(1))
			If SZM->( dbSeek(xFilial("SZM") + SZL->ZL_NUM + SZL->ZL_CLIENTE + SZL->ZL_LOJA) )
				While SZM->(!EOF()) .And. SZM->ZM_FILIAL  = xFilial("SZM");
									.And. SZM->ZM_NUM     = SZL->ZL_NUM;
									.And. SZM->ZM_CLIENTE = SZL->ZL_CLIENTE;
									.And. SZM->ZM_LOJA    = SZL->ZL_LOJA
				
					RecLock("SZM", .F.)
					SZM->ZM_QTDPROC := 0
					SZM->(MsUnlock())

					SZM->(dbSkip())
				EndDo
			EndIf

			IncProc("Processando Liberações...")
			StaticCall( LA05A001 , LibSC9 , AllTrim(SC5->C5_NUM) )

			IncProc("Processando Pedido no Centro de Distribuição...")
			StaticCall( LA05A001 , GeraPVCD , AllTrim(SZL->ZL_NUM) , .F. )
			IncProc()
		Else
			
			DbSelectArea("SZL")
			DbGoTo(nIDSZL)

			RecLock("SZL",.F.)
				SZL->ZL_STATUS := "8" // Erro - Pedido não Integrado
			SZL->(MsUnlock())
			
			Conout("-------------------------------------------------------------------------------")
			Conout("")
			Conout("LA05A002 - ( " +	Dtoc(DATE()) +" as "+ Time()+ " ) -  Falha na Inclusao do Pedido de Venda "+ AllTrim(cNumPed) +" ...")
			Conout("")
			Conout("-------------------------------------------------------------------------------")
			
			cLog := SubStr( MostraErro(), 1, 1200)

			RecLock("SZN",.F.)
				SZN->ZN_STATUS := "8" // Erro - Pedido não Integrado
				SZN->ZN_BLPRADC := "3"
				SZN->ZN_BLNEGOC := "3"
				SZN->ZN_BLCRED  := "3"
				SZN->ZN_BLEST   := "3"
			SZN->(MsUnlock())

			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"8",; // Status
							"Erro - Pedido não integrado"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9],,,cLog)
			
		EndIf
	Else
		DbSelectArea("SZL")
		DbGOTO(nIDSZL)

		If StatEst("2")
			RecLock("SZL",.F.)
				SZL->ZL_STATUS := "6" // Faturamento Parcial
			SZL->(MsUnlock())

			RecLock("SZN",.F.)
				SZN->ZN_STATUS  := "6" // Faturamento Parcial
				SZN->ZN_BLPRADC := "1"
				SZN->ZN_BLNEGOC := "1"
				SZN->ZN_BLCRED  := "1"
				SZN->ZN_BLEST   := "2"
			SZN->(MsUnlock())
		Else
			RecLock("SZL",.F.)
				SZL->ZL_STATUS := "7" // Faturamento Total
			SZL->(MsUnlock())

			RecLock("SZN",.F.)
				SZN->ZN_STATUS  := "7" // Faturamento Total
				SZN->ZN_BLPRADC := "1"
				SZN->ZN_BLNEGOC := "1"
				SZN->ZN_BLCRED  := "1"
				SZN->ZN_BLEST   := "1"
			SZN->(MsUnlock())

			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"7",; // Status
							"Liberação - Pedido liberado totalmente"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9])
		EndIf
	EndIf

	//-- Workflow Posição do Pedido --//
	PosicPed(cNumPed, cCodCli, cLoja)

	ConOut("LA05A002 LIBERAÇÃO PEDIDO " + cNumPed + ": Fim " + DTOC(Date()) + " - " + Time())

	RestArea(aAreaSZL)
	RestArea(aAreaSZM)

Return

/*/{Protheus.doc} ProcCD

Gera pedido de venda no Centro de Distribuição

@author 	Marcos Natã Santos
@since 		07/06/2018
@version 	12.1.17
/*/
Static Function ProcCD()
	Local nProcCount := 3

	ProcRegua(nProcCount)

	IncProc()
	IncProc("Processando Pedido no Centro de Distribuição...")
	StaticCall( LA05A001 , GeraPVCD , AllTrim(SZL->ZL_NUM) , .F. )
	IncProc()

	//-- Verifica status do estoque liberado --//
	If StatEst("2")
		AltStatus("6") //-- Pedido Liberado Parcialmente
	Else
		AltStatus("7") //-- Pedido Liberado Totalmente
	EndIf

Return

/*/{Protheus.doc} LA05VIS

Visualizar Pedido de Venda

@author 	Marcos Natã Santos
@since 		22/03/2019
@version 	12.1.17
/*/
User Function LA05VIS()
	Local aAreaSZL := SZL->(GetArea())

	SZL->(dbSetOrder(1))
	If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
		FWExecView( 'Visualizar','LA05A001', MODEL_OPERATION_VIEW,,{ || .T. } )
	EndIf

	RestArea(aAreaSZL)

Return

/*/{Protheus.doc} LA05ALT

Alterar Pedido de Venda

@author 	Marcos Natã Santos
@since 		11/06/2018
@version 	12.1.17
/*/
User Function LA05ALT()
	Local aAreaSZL := SZL->(GetArea())

	Private cStatus  := SZN->ZN_STATUS
	Private cNumPed  := SZN->ZN_NUM
	Private cCodCli  := SZN->ZN_CLIENTE
	Private cLoja    := SZN->ZN_LOJA
	Private lPedMax  := .F.

	SZL->(dbSetOrder(1))
	If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
		If SZL->ZL_STATUS $ "0/1/2/3/4/5/9" .And. NaoPedBoni(SZN->ZN_NUM)
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
				
				StaticCall( LA05A001 , PUT_HIST , aRegPed )

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
				
				If SZL->ZL_STATUS $ "0/3/4/5/9"
					If .Not. ValidEDI() // Validação Importação EDI
						LIBST3(.T.) // Reprocessa validações
					EndIf
				EndIf
			EndIf
		Else
			MsgAlert("Pedido de venda não pode ser alterado.")
		EndIf
	Else
		MsgAlert("Pedido de venda não encontrado. Favor verificar com Administrador.")
	EndIf

	RestArea(aAreaSZL)

Return

/*/{Protheus.doc} NaoPedBoni
Verifica se o pedido é uma bonificação
@type  Function
@author Marcos Natã Santos
@since 17/06/2019
@version 12.1.17
@param cNumPed, string, Numero do pedido
@return lRet, logico
/*/
Static Function NaoPedBoni(cNumPed)
	Local lRet     := .T.
	Local aAreaSZL := SZL->( GetArea() )

	SZL->( dbSetOrder(1) )
	If SZL->( dbSeek(xFilial("SZL") + cNumPed) )
		If SZL->ZL_TPVEND == "2"
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSZL)
Return lRet

/*/{Protheus.doc} LA05DEL

Excluir Pedido de Venda

@author 	Marcos Natã Santos
@since 		18/06/2018
@version 	12.1.17
/*/
User Function LA05DEL()
	Local nValor
	Local aAreaSZL := SZL->(GetArea())
	Local aAreaSZO := SZO->(GetArea())

	BEGIN TRANSACTION

		If .Not. (SZN->ZN_STATUS $ "6/7/8/9") .Or. ValRastro(AllTrim(SZN->ZN_NUM))
			SZL->(dbSetOrder(1))
			If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )

				nValor := FWExecView( 'Excluir','LA05A001', MODEL_OPERATION_DELETE,,{ || .T. } )

				If nValor = 0
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
			Else
				MsgAlert("Pedido de venda não encontrado. Favor verificar com Administrador.")
			EndIf
		Else
			MsgAlert("Pedido de venda não pode ser excluído.")
		EndIf

	END TRANSACTION

	RestArea(aAreaSZL)
	RestArea(aAreaSZO)

Return

/*/{Protheus.doc} ValDesconto

Valida descontos das Regras de Negócio

@author 	Marcos Natã Santos
@since 		11/06/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function ValDesconto(cProduto)
	Local lRet 			:= .T.
	Local aAreaSZL      := SZL->(GetArea())
	Local cCliente      := PadR(SZN->ZN_CLIENTE,6)
	Local cLoja			:= SZN->ZN_LOJA
	Local cGrpVen       := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_GRPVEN")
	Local nPerDesc		:= 0
	Local cGrpProd      := Posicione("SB1",1,xFilial("SB1") + cProduto, "B1_GRUPO")
	Local cEst          := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_EST")
	Local cModalidade
	Local cSegmento
	Local cRegional
	Local cCanal

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

	If Select("TMP2") > 0
		TMP2->(dbCloseArea())
	EndIf

	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP2",.F.,.T.)
		
	DBSELECTAREA("TMP2")
	TMP2->(DBGOTOP())
	COUNT TO NQTREG

	If NQTREG > 0
		TMP2->(DBGOTOP())
		nPerDesc := TMP2->DESCON
		TMP2->(dbSkip())

		While TMP2->(!EOF())
			If nPerDesc < TMP2->DESCON
				nPerDesc := TMP2->DESCON
			EndIf
			TMP2->(dbSkip())
		EndDo
	EndIf

	TMP2->(dbCloseArea())

	// SZL->( dbSetOrder(1) )
	// If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
	// 	cModalidade := SZL->ZL_MODALID
	// 	cSegmento   := SZL->ZL_SEGMENT
	// 	cRegional   := SZL->ZL_REGNL
	// 	cCanal      := SZL->ZL_CANAL

	// 	//--------------------------------------------------------------//
	// 	//-- Busca Campanha de Descontos                              --//
	// 	//-- SZP -> Cabeçalho Campanha                                --//
	// 	//-- SZQ -> Itens Campanha                                    --//
	// 	//--														  --//
	// 	//-- Realiza combinações para acumular descontos corretamente --//
	// 	//--------------------------------------------------------------//
	// 	cQuery := "SELECT SUM(SZQ.ZQ_DESCON) DESCON " + CRLF
	// 	cQuery += "FROM "+ RetSqlName("SZP") +" SZP " + CRLF
	// 	cQuery += "INNER JOIN "+ RetSqlName("SZQ") +" SZQ " + CRLF
	// 	cQuery += "	ON SZQ.D_E_L_E_T_ <> '*' " + CRLF
	// 	cQuery += "	AND SZQ.ZQ_FILIAL = '"+ xFilial("SZQ") +"' " + CRLF
	// 	cQuery += "	AND SZQ.ZQ_CODCAMP = SZP.ZP_CODCAMP " + CRLF
	// 	cQuery += "WHERE SZP.D_E_L_E_T_ <> '*' " + CRLF
	// 	cQuery += "	AND SZP.ZP_FILIAL = '"+ xFilial("SZP") +"' " + CRLF
	// 	cQuery += "	AND SZP.ZP_DATATE >= '"+ DTOS(Date()) +"' " + CRLF
	// 	cQuery += "	AND (SZQ.ZQ_GRPPRO = '"+ cGrpProd +"' OR SZQ.ZQ_CODPRO = '"+ cProduto +"') " + CRLF
	// 	cQuery += "	AND (  (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"') " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '  '         AND SZP.ZP_MODALID = ' '                 AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '   '             AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '   '             AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '   '         ) " + CRLF
	// 	cQuery += "		OR (SZP.ZP_EST = '"+ cEst +"' AND SZP.ZP_MODALID = '"+ cModalidade +"' AND SZP.ZP_SEGMENT = '"+ cSegmento +"' AND SZP.ZP_REGNL = '"+ cRegional +"' AND SZP.ZP_CANAL = '"+ cCanal +"')) " + CRLF
	// 	cQuery += "ORDER BY SZP.ZP_CODCAMP " + CRLF
	// 	cQuery := ChangeQuery(cQuery)

	// 	If Select("TMP3") > 0
	// 		TMP3->(DbCloseArea())
	// 	EndIf

	// 	TcQuery cQuery New Alias "TMP3"

	// 	TMP3->(dbGoTop())
	// 	COUNT TO NQTREG
	// 	TMP3->(dbGoTop())

	// 	If NQTREG > 0
	// 		nPerDesc += TMP3->DESCON
	// 	EndIf

	// 	TMP3->(DbCloseArea())
	// EndIf

	RestArea(aAreaSZL)
	
Return nPerDesc

/*/{Protheus.doc} fMSNewGet

Monta dados para liberação do bloqueio de Regra

@author 	Marcos Natã Santos
@since 		11/06/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function fMSNewGet()
	Local nX
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"ZM_PRODUTO","ZM_DESCRI","ZM_QTD","ZM_VALOR","ZM_TOTAL","ZM_PERDESC","ACN_DESCON","ZM_PERDESC"}
	Local aAlterFields 	:= {}
	Local nPerDesc 		:= 0
	Static oMSNewGet

	// Define propriedades dos campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If nX = 8
			If SX3->(DbSeek(aFields[nX]))
				Aadd(aHeaderEx, {"% Diferença",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
								SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		Else
			If SX3->(DbSeek(aFields[nX]))
				Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
								SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		EndIf
	Next nX

	cQry := "SELECT ZM_PRODUTO, ZM_DESCRI, ZM_QTD, ZM_VALOR, ZM_TOTAL, ZM_PERDESC FROM " +  RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())

	// Define valores dos campos
	While TMP1->(!EOF())
		nTotItens++
		nPerDesc := ValDesconto(AllTrim(TMP1->ZM_PRODUTO))
		If nPerDesc > 0 .And. TMP1->ZM_PERDESC > 0
			If TMP1->ZM_PERDESC > nPerDesc
				Aadd(aFieldFill, AllTrim(TMP1->ZM_PRODUTO))
				Aadd(aFieldFill, AllTrim(TMP1->ZM_DESCRI))
				Aadd(aFieldFill, TMP1->ZM_QTD)
				Aadd(aFieldFill, TMP1->ZM_VALOR)
				Aadd(aFieldFill, TMP1->ZM_TOTAL)
				Aadd(aFieldFill, TMP1->ZM_PERDESC)
				Aadd(aFieldFill, nPerDesc)
				Aadd(aFieldFill, TMP1->ZM_PERDESC - nPerDesc)
				Aadd(aFieldFill, .F.)
				Aadd(aColsEx, aFieldFill)
				aFieldFill := {}
				nTotBloq += TMP1->ZM_TOTAL
			EndIf
		ElseIf TMP1->ZM_PERDESC > 0
			Aadd(aFieldFill, AllTrim(TMP1->ZM_PRODUTO))
			Aadd(aFieldFill, AllTrim(TMP1->ZM_DESCRI))
			Aadd(aFieldFill, TMP1->ZM_QTD)
			Aadd(aFieldFill, TMP1->ZM_VALOR)
			Aadd(aFieldFill, TMP1->ZM_TOTAL)
			Aadd(aFieldFill, TMP1->ZM_PERDESC)
			Aadd(aFieldFill, nPerDesc)
			Aadd(aFieldFill, TMP1->ZM_PERDESC - nPerDesc)
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aFieldFill := {}
			nTotBloq += TMP1->ZM_TOTAL
		EndIf

		TMP1->(dbSkip())
	EndDo

	TMP1->(DbCloseArea())

	oMSNewGet := MsNewGetDados():New( 075, 010, 175, 485, , "AllwaysTrue", "AllwaysTrue", , aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

/*/{Protheus.doc} TotPed

Calcula valor total do pedido

@author 	Marcos Natã Santos
@since 		13/06/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function TotPed()
	Local nTotal := 0

	cQry := "SELECT SUM(ZM_TOTAL) TOTAL FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
	nTotal := TMP1->TOTAL
	TMP1->(DbCloseArea())

Return nTotal

/*/{Protheus.doc} StatEst

Busca status do estoque do pedido de venda

@author 	Marcos Natã Santos
@since 		14/06/2018
@version 	12.1.17
@return 	Logico
/*/
Static Function StatEst(cTipo)
	Local cQry := ""
	Local lStatus := .F.

	Default cTipo := ""

	cQry := "SELECT ZM_PRODUTO " + CRLF
	cQry += "FROM "+ RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
	If cTipo == "2"
		cQry += "AND (ZM_LIBER = '"+ cTipo +"' OR (ZM_LIBER = '1' AND (ZM_QTDLIB + ZM_QTDCORT) < ZM_QTD)) " + CRLF
	Else
		cQry += "AND ZM_LIBER = '"+ cTipo +"' " + CRLF
		cQry += "AND ZM_QTDPROC > 0 " + CRLF
	EndIf
	cQry := ChangeQuery(cQry)

	If Select("STATEST") > 0
		STATEST->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "STATEST"

	STATEST->(dbGoTop())
	COUNT TO NQTREG

	If NQTREG > 0
		lStatus := .T.
	EndIf

	STATEST->(DbCloseArea())

Return lStatus

/*/{Protheus.doc} fMSNewGe1

Monta dados para liberação de estoque

@author 	Marcos Natã Santos
@since 		14/06/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function fMSNewGe1()
	Local nX
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"ZM_ITEM","ZM_PRODUTO","ZM_DESCRI","ZM_VALOR","B2_QATU","ZM_QTDLIB","ZM_QTD","B2_QATU","B2_QATU","ZL_STATUS","ZM_MOTIVO"}
	Local aAlterFields 	:= {"ZM_QTD","ZL_STATUS","ZM_MOTIVO"}
	Local cQry
	Local nSaldoEst 	:= 0
	Local nSaldoCmplt   := 0
	Static oMSNewGet

	// Define propriedades dos campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If nX = 2
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,10,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 3
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,24,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 5
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Quantidade",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 6
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Qtd Atendida",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 7
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Atender Qtd",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 8
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Saldo Shelf",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 9
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Saldo Completo",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		ElseIf nX = 10
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {"Cortar item?",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		Else
			If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		EndIf
	Next nX

	cQry := "SELECT R_E_C_N_O_, ZM_ITEM, ZM_PRODUTO, ZM_DESCRI, ZM_QTD, ZM_QTDLIB, ZM_QTDCORT, ZM_VALOR, ZM_TOTAL, ZM_MOTIVO " + CRLF
	cQry += "FROM "+ RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
	cQry += "AND (ZM_LIBER = '2' OR  (ZM_LIBER = '1' AND (ZM_QTDLIB + ZM_QTDCORT) < ZM_QTD)) " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMP5") > 0
		TMP5->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP5"

	TMP5->(dbGoTop())

	// Define valores dos campos
	While TMP5->(!EOF())
		nSaldoEst := StaticCall( LA05A001 , ValSaldoEstoque ,;
			AllTrim(TMP5->ZM_PRODUTO) , SZN->ZN_CLIENTE , SZN->ZN_LOJA, TMP5->ZM_QTD )

		nSaldoCmplt := SldSimples(AllTrim(TMP5->ZM_PRODUTO))

		Aadd(aFieldFill, TMP5->ZM_ITEM)
		Aadd(aFieldFill, AllTrim(TMP5->ZM_PRODUTO))
		Aadd(aFieldFill, AllTrim(TMP5->ZM_DESCRI))
		Aadd(aFieldFill, TMP5->ZM_VALOR)
		Aadd(aFieldFill, TMP5->ZM_QTD)
		Aadd(aFieldFill, TMP5->ZM_QTDLIB)
		If nSaldoEst < (TMP5->ZM_QTD - TMP5->ZM_QTDLIB - TMP5->ZM_QTDCORT)
			Aadd(aFieldFill, nSaldoEst)
		Else
			Aadd(aFieldFill, TMP5->ZM_QTD - TMP5->ZM_QTDLIB - TMP5->ZM_QTDCORT)
		EndIf
		Aadd(aFieldFill, nSaldoEst)
		Aadd(aFieldFill, nSaldoCmplt)
		Aadd(aFieldFill, "N")
		Aadd(aFieldFill, TMP5->ZM_MOTIVO)
		Aadd(aFieldFill, TMP5->R_E_C_N_O_)
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
		aFieldFill := {}

		TMP5->(dbSkip())
	EndDo

	TMP5->(DbCloseArea())

	oMSNewGet := MsNewGetDados():New( 065, 010, 177, 390, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return oMSNewGet

/*/{Protheus.doc} LibEst

Realiza as liberações de estoque conforme informado na grid

@author 	Marcos Natã Santos
@since 		14/06/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function LibEst()
	Local nI
	Local lRet       := .T.
	Local cHelp      := ""
	Local cSoluc     := ""
	Local aAreaSZL   := SZL->(GetArea())
	Local aAreaSZM   := SZM->(GetArea())
	Local nVlrPedMin := StaticCall( LA05A001 , VlrPedMin , SZN->ZN_CLIENTE, SZN->ZN_LOJA )
	Local nMVPedMax	 := SUPERGETMV("MV_XPEDMAX", .F., 150000)
	Local nTotPed    := 0
	Local aRecno     := {}
	Local aCorte	 := {}
	Local aWFCorte	 := {}
	Local lParcial   := .F.

	For nI := 1 To Len(oGet:aCols)
		If .Not. (oGet:aCols[nI][10] $ "S/N") .And. lRet
			cHelp := "Opção informada para corte de saldo é inválida."
			cSoluc := "Informe 'S' para sim e 'N' para Não."
			Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
			lRet := .F.
		ElseIf oGet:aCols[nI][10] == "S" .And. lRet
			If !Empty(AllTrim(oGet:aCols[nI][11]))
				If ExistCpo("SX5","Z9"+AllTrim(oGet:aCols[nI][11]))
					aAdd(aCorte, {oGet:aCols[nI][12], oGet:aCols[nI][5] - oGet:aCols[nI][6], AllTrim(oGet:aCols[nI][11])})
				Else
					cHelp := "Motivo de corte " + AllTrim(oGet:aCols[nI][11]) + " inválido."
					cSoluc := "Selecione um motivo para o corte válido."
					Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
					lRet := .F.
				EndIf
			Else
				cHelp := "Motivo de corte para o item " + AllTrim(oGet:aCols[nI][1]) + " produto " + AllTrim(oGet:aCols[nI][2]) + " não informado."
				cSoluc := "Informe um motivo para o corte."
				Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
				lRet := .F.
			EndIf
		ElseIf oGet:aCols[nI][7] > oGet:aCols[nI][8] .And. lRet
			cHelp := "Quantidade informada para produto " + AllTrim(oGet:aCols[nI][2]) + " é maior que o saldo atual."
			cSoluc := "Informe uma quantidade válida."
			Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
			lRet := .F.
		ElseIf oGet:aCols[nI][7] < 0 .And. lRet
			cHelp := "Quantidade informada para produto " + AllTrim(oGet:aCols[nI][2]) + " é inválida."
			cSoluc := "Informe uma quantidade válida."
			Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
			lRet := .F.
		ElseIf oGet:aCols[nI][7] > (oGet:aCols[nI][5] - oGet:aCols[nI][6]) .And. lRet
			cHelp := "Quantidade informada para produto " + AllTrim(oGet:aCols[nI][2]) + " é maior que a quantidade do pedido."
			cSoluc := "Informe uma quantidade válida."
			Help(Nil,Nil,"LibEst",Nil,cHelp,1,0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
			lRet := .F.
		ElseIf oGet:aCols[nI][7] > 0 .And. lRet
			SZM->( dbGoTo(oGet:aCols[nI][12]) )
			nTotPed += oGet:aCols[nI][7] * SZM->ZM_VALOR
			aAdd(aRecno, {oGet:aCols[nI][12], oGet:aCols[nI][7]})
		EndIf
	Next nI

	If nTotPed > nMVPedMax
		lRet := .F.
		MsgAlert("Total do pedido é maior que valor máximo de R$ "+ AllTrim(TRANSFORM(nMVPedMax,PesqPict("SZM", "ZM_TOTAL"))) +". Por favor fracione o pedido.")
	EndIf

	If nTotPed < nVlrPedMin .And. lRet
		lRet := MsgNoYes("Total do pedido é menor que valor mínimo de R$ "+ AllTrim(TRANSFORM(nVlrPedMin,PesqPict("SZM", "ZM_TOTAL"))) +". Deseja continuar?","Pedido Mínimo")
	EndIf

	If lRet .And. ( Len(aRecno) > 0 .Or. Len(aCorte) > 0 )

		If Len(aRecno) > 0
			For nI := 1 To Len(aRecno)
				SZM->( dbGoTo(aRecno[nI][1]) )
				RecLock("SZM", .F.)
				SZM->ZM_LIBER := "1"
				SZM->ZM_QTDLIB += aRecno[nI][2]
				SZM->ZM_QTDPROC := aRecno[nI][2]
				SZM->(MsUnlock())
			Next nI
		EndIf

		If Len(aCorte) > 0
			For nI := 1 To Len(aCorte)
				SZM->( dbGoTo(aCorte[nI][1]) )
				RecLock("SZM", .F.)
				SZM->ZM_LIBER   := "1"
				SZM->ZM_QTDCORT := aCorte[nI][2]
				SZM->ZM_MOTIVO  := aCorte[nI][3]
				SZM->(MsUnlock())

				AADD(aWFCorte, {SZM->ZM_PRODUTO,SZM->ZM_DESCRI,SZM->ZM_QTDCORT,SZM->ZM_VALOR,(SZM->ZM_QTDCORT * SZM->ZM_VALOR),SZM->ZM_MOTIVO} )
			Next

			//-- Verifica status do estoque liberado --//
			//-- Atualiza legenda de faturamento     --//
			If .Not. StatEst("2")
				If StaticCall(M460FIM, ExistNF, SZN->ZN_NUM)
					SZL->( dbSetOrder(1) )
					If SZL->( dbSeek(xFilial("SZL") + SZN->ZN_NUM + SZN->ZN_CLIENTE + SZN->ZN_LOJA) )
						RecLock("SZL", .F.)
						SZL->ZL_FATNF := "S"
						SZL->( MsUnLock() )
						RecLock("SZN", .F.)
						SZN->ZN_FATNF := "S"
						SZN->( MsUnLock() )
					EndIf
				EndIf
			EndIf
			
			If Len(aRecno) <= 0
				lApenasCorte := .T.
			EndIf

			aRegPed   := {}
			AADD(aRegPed,{ 	cNumPed,;
							cCodCli,;
							cLoja,;
							"2",; // 1=Bloqueio 2=Liberação 3=Exclusão 4=Alteração
							Date(),;
							Time(),;
							RetCodUsr(),;
							CUSERNAME,;
							"10",; // Status
							"Resíduo - Corte de Pedido de Venda"}) // Obs
			
			StaticCall( LA05A001 , PUT_HIST , aRegPed )

			//-------------------------
			//-- Workflow Status Pedido
			//-------------------------
			U_LA05W001(cNumPed,cCodCli,cLoja,aRegPed[1][4],aRegPed[1][9],aWFCorte)
		EndIf

		oDlg:End()

	Else
		lRet := .F.
	EndIf

	RestArea(aAreaSZL)
	RestArea(aAreaSZM)

Return lRet

/*/{Protheus.doc} fMSNewGe2

Monta dados para liberação de divergência de preços

@author 	Marcos Natã Santos
@since 		24/05/2019
@version 	12.1.17
/*/
Static Function fMSNewGe2()
	Local nX
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"ZM_ITEM","ZM_PRODUTO","ZM_DESCRI","ZM_QTD","ZM_PRCTAB","ZM_VALOR"}
	Local aAlterFields := {}
	Local cQry         := ""
	Static oMSNewGe2

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	cQry := "SELECT ZM_ITEM, ZM_PRODUTO, ZM_DESCRI, ZM_QTD, ZM_PRCTAB, ZM_VALOR " + CRLF
	cQry += "FROM " + RetSqlName("SZM") + CRLF
	cQry += "	WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND ZM_NUM = '"+ SZN->ZN_NUM +"' " + CRLF
	cQry += "	AND ZM_CLIENTE = '"+ SZN->ZN_CLIENTE +"' " + CRLF
	cQry += "	AND ZM_LOJA = '"+ SZN->ZN_LOJA +"' " + CRLF
	cQry += "	AND ZM_VALOR <> ZM_PRCTAB " + CRLF
	cQry += "ORDER BY ZM_ITEM " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TMPSZM") > 0
		TMPSZM->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSZM"

	TMPSZM->(dbGoTop())

	// Define valores dos campos
	While TMPSZM->(!EOF())
		Aadd(aFieldFill, TMPSZM->ZM_ITEM)
		Aadd(aFieldFill, TMPSZM->ZM_PRODUTO)
		Aadd(aFieldFill, TMPSZM->ZM_DESCRI)
		Aadd(aFieldFill, TMPSZM->ZM_QTD)
		Aadd(aFieldFill, TMPSZM->ZM_PRCTAB)
		Aadd(aFieldFill, TMPSZM->ZM_VALOR)
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
		aFieldFill := {}

		TMPSZM->(dbSkip())
	EndDo

	TMPSZM->(DbCloseArea())

	oMSNewGe2 := MsNewGetDados():New( 045, 002, 120, 402, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

/*/{Protheus.doc} CalcLib

Calcula valor pedido a enviar para centro distribuição

@author 	Marcos Natã Santos
@since 		08/04/2019
@version 	12.1.17
/*/
Static Function CalcLib()
	Local nValLib := 0
	Local nX      := 0

	For nX := 1 To Len(oGet:aCols)
		nValLib += (oGet:aCols[nX][7] * oGet:aCols[nX][4])
	Next nX

	cValLib := "Valor Liberação: " + AllTrim(TRANSFORM(nValLib, PesqPict("SZM", "ZM_TOTAL")))

	MsgInfo(cValLib)

	oDlg:Refresh()

Return

/*/{Protheus.doc} ValRastro

Busca o rastro do pedido de venda antes de realizar a exclusão

@author 	Marcos Natã Santos
@since 		04/07/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function ValRastro(cPed)
	Local lRet := .F.
	Local cQry := ""

	Default cPed := ""

	cQry := "SELECT C5_NUM FROM " + RetSqlName("SC5") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
	cQry += "AND C5_XPEDPAI = '"+ cPed +"' " + CRLF
	cQry := ChangeQuery(cQry)
	
	If Select("TMPR") > 0
		TMPR->(DbCloseArea())
	EndIf
	
	TcQuery cQry New Alias "TMPR"
	
	TMPR->(dbGoTop())
	COUNT TO NQTREG
	TMPR->(dbGoTop())

	If NQTREG <= 0
		lRet := .T.
	EndIf

	TMPR->(DbCloseArea())

Return lRet

/*/{Protheus.doc} BuscaNota

Busca notas fiscais amarradas aos pedidos de venda

@author 	Marcos Natã Santos
@since 		04/07/2018
@version 	12.1.17
@return 	Nil
/*/
Static Function BuscaNota(cFil,cPed)
	Local cQry
	Local aRet := {}

	cQry := "SELECT SF2.F2_DOC, SF2.F2_EMISSAO " + CRLF
	cQry += "FROM "+ RetSqlName("SD2") +" SD2 " + CRLF
	cQry += "INNER JOIN SF2010 SF2 " + CRLF
	cQry += "ON SF2.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SF2.F2_FILIAL = '"+ cFil +"' " + CRLF
	cQry += "AND SF2.F2_DOC = SD2.D2_DOC " + CRLF
	cQry += "AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + CRLF
	cQry += "AND SF2.F2_LOJA = SD2.D2_LOJA " + CRLF
	cQry += "WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND SD2.D2_FILIAL = '"+ cFil +"' " + CRLF
	cQry += "AND SD2.D2_PEDIDO = '"+ cPed +"' " + CRLF
	cQry += "AND ROWNUM = 1 " + CRLF
	cQry := ChangeQuery(cQry)
	
	If Select("NOTA") > 0
		NOTA->(DbCloseArea())
	EndIf
	
	TcQuery cQry New Alias "NOTA"
	
	NOTA->(dbGoTop())
	COUNT TO NQTREG
	NOTA->(dbGoTop())

	If NQTREG > 0
		AADD(aRet, AllTrim(NOTA->F2_DOC))
		AADD(aRet, DTOC(STOD(NOTA->F2_EMISSAO)))
	EndIf

	NOTA->(DbCloseArea())

Return aRet

/*/{Protheus.doc} PosicPed

Lista itens para Posição do Pedido

@author 	Marcos Natã Santos
@since 		31/05/2019
@version 	12.1.17
@return 	Nil
/*/
Static Function PosicPed(cNumPed,cCodCli,cLoja)
	Local cQry
	Local aPosicao := {}

	Default cNumPed := ""
	Default cCodCli := ""
	Default cLoja 	:= ""

	cQry := "SELECT ZM_ITEM ITEM, " + CRLF
	cQry += "	ZM_PRODUTO PRODUTO, " + CRLF
	cQry += "	ZM_DESCRI DESCRI, " + CRLF
	cQry += "	ZM_VALOR VALOR, " + CRLF
	cQry += "	ZM_QTD QUANTIDADE, " + CRLF
	cQry += "	ZM_QTDLIB LIBERADO, " + CRLF
	cQry += "	ZM_QTDCORT CORTE, " + CRLF
	cQry += "	(ZM_QTD-ZM_QTDLIB-ZM_QTDCORT) PENDENTE " + CRLF
	cQry += "FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_NUM = '"+ cNumPed +"' " + CRLF
	cQry += "AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "AND ZM_LOJA = '"+ cLoja +"' " + CRLF
	cQry := ChangeQuery(cQry)
	
	If Select("LSTPOSIC") > 0
		LSTPOSIC->(DbCloseArea())
	EndIf
	
	TcQuery cQry New Alias "LSTPOSIC"
	
	LSTPOSIC->(dbGoTop())
	COUNT TO NQTREG
	LSTPOSIC->(dbGoTop())

	If NQTREG > 0
		While LSTPOSIC->( !EOF() )
			AADD(aPosicao, {LSTPOSIC->ITEM,;
							LSTPOSIC->PRODUTO,;
							LSTPOSIC->DESCRI,;
							LSTPOSIC->VALOR,;
							LSTPOSIC->QUANTIDADE,;
							LSTPOSIC->LIBERADO,;
							LSTPOSIC->CORTE,;
							LSTPOSIC->PENDENTE} )
			LSTPOSIC->(dbSkip())
		EndDo
	EndIf

	LSTPOSIC->(DbCloseArea())

	//--------------//
	//-- Worklfow --//
	//--------------//
	If Len(aPosicao) > 0
		U_LA05W001(cNumPed,cCodCli,cLoja,/*cTipo*/,/*cStatus*/,/*aWFCorte*/,aPosicao)
	EndIf

Return

/*/{Protheus.doc} ValidEDI

Valida diferenças de preço para entrada EDI (NeoGrid)

@author 	Marcos Natã Santos
@since 		06/03/2019
@version 	12.1.17
/*/
Static Function ValidEDI()
	Local lRet     := .F.
	Local aAreaSZM := SZM->( GetArea() )

	If AllTrim(SZL->ZL_ORIGEM) $ "NEOGRID/IMPORT"
		SZM->( dbSetOrder(1) )
		If SZM->( dbSeek(xFilial("SZM") + SZL->ZL_NUM + SZL->ZL_CLIENTE + SZL->ZL_LOJA) )
			While SZM->( !EOF() ) .And. SZM->ZM_FILIAL == xFilial("SZM");
				.And. SZM->ZM_NUM == SZL->ZL_NUM;
				.And. SZM->ZM_CLIENTE == SZL->ZL_CLIENTE;
				.And. SZM->ZM_LOJA == SZL->ZL_LOJA

				If SZM->ZM_PRCTAB <> SZM->ZM_VALOR
					lRet := .T.
					Exit
				EndIf

				SZM->( dbSkip() )
			EndDo
		EndIf
	EndIf

	RestArea( aAreaSZM )

Return lRet

/*/{Protheus.doc} SldAProcess

Verifica se existe saldo a processar

@author 	Marcos Natã Santos
@since 		15/03/2019
@version 	12.1.17
/*/
Static Function SldAProcess(cNumPed,cCodCli,cLoja)
	Local lRet := .F.
	Local cQry := ""

	//-- Avalia saldos enviados a fábrica --//
	AvalSldFab(cNumPed,cCodCli,cLoja)

	cQry := "SELECT SUM(ZM_QTDPROC) QTDPROC " + CRLF
	cQry += "FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "	AND ZM_NUM = '"+ cNumPed +"' " + CRLF
	cQry += "	AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "	AND ZM_LOJA = '"+ cLoja +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("SLDPROC") > 0
		SLDPROC->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "SLDPROC"

	SLDPROC->(dbGoTop())

	If SLDPROC->QTDPROC > 0
		lRet := .T.
	EndIf

	SLDPROC->( dbCloseArea() )

Return lRet

/*/{Protheus.doc} AvalSldFab

Avalia saldo já liberado para fábrica
Evitar duplicidade de envio de pedido

@author 	Marcos Natã Santos
@since 		22/04/2019
@version 	12.1.17
/*/
Static Function AvalSldFab(cNumPed,cCodCli,cLoja)
	Local cQry := ""
	Local aAreaSZM := SZM->( GetArea() )

	cQry := "WITH " + CRLF
	cQry += "PEDFAB AS ( " + CRLF
	cQry += "	SELECT SUM(C6_QTDVEN) QTDFAB FROM SC6010 " + CRLF
	cQry += "	WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
	cQry += "	AND C6_XPEDPAI = '"+ cNumPed +"' " + CRLF
	cQry += "	AND C6_CLI = '"+ cCodCli +"' " + CRLF
	cQry += "	AND C6_LOJA = '"+ cLoja +"'), " + CRLF
	cQry += "PEDAUTO AS ( " + CRLF
	cQry += "	SELECT SUM(ZM_QTD-ZM_QTDCORT) QTDAUTO FROM SZM010 " + CRLF
	cQry += "	WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "	AND ZM_NUM = '"+ cNumPed +"' " + CRLF
	cQry += "	AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "	AND ZM_LOJA = '"+ cLoja +"'), " + CRLF
	cQry += "PROC AS ( " + CRLF
	cQry += "	SELECT SUM(ZM_QTDPROC) QTDPROC FROM SZM010 " + CRLF
	cQry += "	WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "	AND ZM_NUM = '"+ cNumPed +"' " + CRLF
	cQry += "	AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
	cQry += "	AND ZM_LOJA = '"+ cLoja +"') " + CRLF
	cQry += "SELECT (PEDAUTO.QTDAUTO-PEDFAB.QTDFAB) ALIBERAR, PROC.QTDPROC " + CRLF
	cQry += "FROM PEDAUTO, PEDFAB, PROC " + CRLF
	cQry += "WHERE PEDFAB.QTDFAB IS NOT NULL " + CRLF

	If Select("AVALSLD") > 0
		AVALSLD->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "AVALSLD"

	AVALSLD->(dbGoTop())

	If AVALSLD->ALIBERAR < AVALSLD->QTDPROC
		//-----------------------------
		// Limpa quantidade em processo
		//-----------------------------
		SZM->(dbSetOrder(1))
		If SZM->( dbSeek(xFilial("SZM") + cNumPed + cCodCli + cLoja) )
			While SZM->(!EOF()) .And. SZM->ZM_FILIAL = xFilial("SZM");
								.And. SZM->ZM_NUM = cNumPed;
								.And. SZM->ZM_CLIENTE = cCodCli;
								.And. SZM->ZM_LOJA = cLoja
			
				RecLock("SZM", .F.)
				SZM->ZM_QTDPROC := 0
				SZM->(MsUnlock())

				SZM->(dbSkip())
			EndDo
		EndIf

		//-- Atualiza saldo liberado do pedido auto --//
		AtuLibAuto(cNumPed,cCodCli,cLoja)

		//-- Verifica status do estoque liberado --//
		If StatEst("2")
			AltStatus("6") //-- Pedido Liberado Parcialmente
		Else
			AltStatus("7") //-- Pedido Liberado Totalmente
		EndIf
	EndIf

	AVALSLD->( dbCloseArea() )
	RestArea(aAreaSZM)
Return

/*/{Protheus.doc} AtuLibAuto

Atualiza saldo liberado analisando pedidos na fábrica

@author 	Marcos Natã Santos
@since 		22/04/2019
@version 	12.1.17
/*/
Static Function AtuLibAuto(cNumPed,cCodCli,cLoja)
	Local cQry     := ""
	Local nQtdReg  := 0
	Local aAreaSZM := SZM->( GetArea() )

	cQry := "SELECT C6_PRODUTO PRODUTO, " + CRLF
	cQry += "	SUM(C6_QTDVEN) QTDVEN " + CRLF
	cQry += "FROM SC6010 " + CRLF
	cQry += "	WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "	AND C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
	cQry += "	AND C6_XPEDPAI = '"+ cNumPed +"' " + CRLF
	cQry += "	AND C6_CLI = '"+ cCodCli +"' " + CRLF
	cQry += "	AND C6_LOJA = '"+ cLoja +"' " + CRLF
	cQry += "GROUP BY C6_PRODUTO " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("ATULIB") > 0
		ATULIB->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "ATULIB"

	ATULIB->(dbGoTop())
	COUNT TO nQtdReg
	ATULIB->(dbGoTop())

	If nQtdReg > 0
		SZM->(dbSetOrder(4))
		While ATULIB->( !EOF() )
			If SZM->( dbSeek(xFilial("SZM") + cNumPed + cCodCli + cLoja + ATULIB->PRODUTO) )
				RecLock("SZM", .F.)
				SZM->ZM_QTDLIB := ATULIB->QTDVEN
				SZM->(MsUnlock())
			EndIf
			ATULIB->( dbSkip() )
		EndDo
	EndIf

	ATULIB->( dbCloseArea() )
	RestArea(aAreaSZM)
Return

/*/{Protheus.doc} TotPedMn

Calcula total do pedido de venda
Campo browse ZN_TOTAL

@author 	Marcos Natã Santos
@since 		02/04/2019
@version 	12.1.17
/*/
User Function TotPedMn(cNumPed) //-- U_TOTPEDMN(SZN->ZN_NUM)
	Local nTot    := 0
	Local cQry    := ""
	Local nQtdReg := 0

	cQry := "SELECT SUM(ZM_TOTAL) TOTAL " + CRLF
	cQry += "FROM " + RetSqlName("SZM") + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
	cQry += "AND ZM_NUM = '"+ cNumPed +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("TOTM") > 0
		TOTM->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TOTM"

	TOTM->(dbGoTop())
	COUNT TO nQtdReg
	TOTM->(dbGoTop())

	If nQtdReg > 0
		nTot := TOTM->TOTAL
	EndIf

	TOTM->(DbCloseArea())

Return nTot

/*/{Protheus.doc} BscTpVend

Busca tipo do pedido (Venda ou Bonificação)
Campo browse ZN_TPVEND

@author 	Marcos Natã Santos
@since 		16/04/2019
@version 	12.1.17
/*/
User Function BscTpVend(cNumPed) //-- U_BscTpVend(SZN->ZN_NUM)
	Local cTpVenda  := POSICIONE("SZL",1,XFILIAL("SZL")+cNumPed,"ZL_TPVEND")
	Local cDescTipo := IIF(cTpVenda == "1", "VENDA", "BONIFICACAO")
Return cDescTipo

/*/{Protheus.doc} VerPedCD

Verifica se pedido foi enviado para Centro Distribuição

@author 	Marcos Natã Santos
@since 		18/04/2019
@version 	12.1.17
/*/
Static Function VerPedCD(cPedido,cPedCD)
	Local lRet    := .T.
	Local cQry    := ""
	Local nQtdReg := 0

	Default cPedido := ""
	Default cPedCD  := ""

	cQry := "SELECT C5_NUM, C5_XPVORI FROM SC5010 " + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND C5_FILIAL = '0101' " + CRLF //-- Centro Distribuição
	cQry += "AND SUBSTR(C5_XPVORI,1,6) = '"+ cPedido +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("VERPCD") > 0
		VERPCD->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "VERPCD"

	VERPCD->(dbGoTop())
	COUNT TO nQtdReg
	VERPCD->(dbGoTop())

	If nQtdReg > 0
		lRet := .F.
		cPedCD := AllTrim(VERPCD->C5_NUM)
	EndIf

	VERPCD->(DbCloseArea())

Return lRet

/*/{Protheus.doc} ContemOutRosa
Verifica se o pedido tem itens da campanha outubro rosa
@type Static Function
@author Marcos Natã Santos
@since 19/08/2019
@version 1.0
@return lRet, logic
/*/
Static Function ContemOutRosa()
	Local lRet := .F.
	Local aAreaSZM := SZM->( GetArea() )

	SZM->(dbGoTop())
	If SZM->( dbSeek(xFilial("SZM")+SZN->ZN_NUM+SZN->ZN_CLIENTE+SZN->ZN_LOJA) )
		While SZM->(!EOF()) .And. SZM->ZM_FILIAL  = xFilial("SZM");
							.And. SZM->ZM_NUM     = SZN->ZN_NUM;
							.And. SZM->ZM_CLIENTE = SZN->ZN_CLIENTE;
							.And. SZM->ZM_LOJA    = SZN->ZN_LOJA
			
			If AllTrim(SZM->ZM_PRODUTO) $ "414010021/414020009/414014792/414014793"
				lRet := .T.
			EndIf

			SZM->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaSZM)
Return lRet

/*/{Protheus.doc} LA05RESI
Verifica se existe itens eliminados para estornar
@type User Function
@author Marcos Natã Santos
@since 02/10/2019
@version 1.0
/*/
User Function LA05RESI()
	Local aAreaSZM := SZM->( GetArea() )
	Local cQry := ""
	Local nQtdReg := 0
	Local cNumPed := SZN->ZN_NUM
	Local cCodCli := SZN->ZN_CLIENTE
	Local cLoja := SZN->ZN_LOJA
	Local cStatus := SZN->ZN_STATUS

	If AllTrim(cStatus) $ "5/6/7/9" //-- Pedidos => estoque | enviados | Finalizados --//
		//-- Apenas pedidos totalmente aprovados podem ter resíduos estornados --//
		If SZN->ZN_BLPRADC == "1" .And. SZN->ZN_BLNEGOC == "1" .And. SZN->ZN_BLCRED == "1"
			cQry := "SELECT ZM_NUM, ZM_ITEM FROM SZM010 " + CRLF
			cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
			cQry += "AND ZM_FILIAL = '"+ xFilial("SZM") +"' " + CRLF
			cQry += "AND ZM_NUM = '"+ cNumPed +"' " + CRLF
			cQry += "AND ZM_CLIENTE = '"+ cCodCli +"' " + CRLF
			cQry += "AND ZM_LOJA = '"+ cLoja +"' " + CRLF
			cQry += "AND ZM_QTDCORT > 0 " + CRLF
			cQry := ChangeQuery(cQry)

			If Select("ESTRESI") > 0
				ESTRESI->(DbCloseArea())
			EndIf

			TcQuery cQry New Alias "ESTRESI"

			ESTRESI->(dbGoTop())
			COUNT TO nQtdReg
			ESTRESI->(dbGoTop())

			If nQtdReg > 0
				If MsgNoYes("Deseja continuar com estorno da eliminação resíduos?", "Estornar Resíduos") 
					EstornRsd(cNumPed, cCodCli, cLoja)
				EndIf
			Else
				MsgAlert("Pedido não contém itens cortados/eliminados.", "Estornar Resíduos")
			EndIf

			ESTRESI->(DbCloseArea())
		Else
			MsgAlert("Apenas pedidos totalmente aprovados podem ter resíduos estornados", "Estornar Resíduos")
		EndIf
	Else
		MsgAlert("Pedido sem liberações de saldo estoque.", "Estornar Resíduos")
	EndIf

	RestArea(aAreaSZM)
Return

/*/{Protheus.doc} EstornRsd
Estorna resíduos eliminados do pedido
@type Static Function
@author Marcos Natã Santos
@since 02/10/2019
@version 1.0
@param cNumPed, char
@param cCodCli, char
@param cLoja, char
/*/
Static Function EstornRsd(cNumPed, cCodCli, cLoja)
	Local aAreaSZL := SZL->( GetArea() )
	Local aAreaSZM := SZM->( GetArea() )
	Local aAreaSZN := SZN->( GetArea() )
	Local cStatus := ""
	Local aRegPed := {}

	Default cNumPed := ""
	Default cCodCli := ""
	Default cLoja := ""

	//-------------------------------------------//
	//-- Estorna resíduos eliminados no pedido --//
	//-------------------------------------------//
	SZM->( dbSetOrder(1) )
	SZM->( dbGoTop() )
	If SZM->( dbSeek(xFilial("SZM") + cNumPed + cCodCli + cLoja) )
		While SZM->( !EOF() );
			.And. SZM->ZM_NUM = cNumPed;
			.And. SZM->ZM_CLIENTE = cCodCli;
			.And. SZM->ZM_LOJA = cLoja

			RecLock("SZM", .F.)
			SZM->ZM_QTDCORT := 0
			SZM->ZM_MOTIVO := Space(2)
			SZM->(MsUnLock())

			SZM->( dbSkip() )
		EndDo
	EndIf

	If ValRastro(cNumPed)
		cStatus := "5" //-- Bloqueio Saldo Estoque
	Else
		cStatus := "6" //-- Pedido Parcialmente Liberado
	EndIf

	SZL->( dbSetOrder(1) )
	If SZL->( dbSeek(xFilial("SZL") + cNumPed + cCodCli + cLoja) )
		RecLock("SZL", .F.)
		SZL->ZL_STATUS := cStatus
		SZL->ZL_FATNF := "N"
		SZL->(MsUnlock())
	EndIf

	SZN->( dbSetOrder(1) )
	If SZN->( dbSeek(xFilial("SZN") + cNumPed + cCodCli + cLoja) )
		RecLock("SZN", .F.)
		SZN->ZN_STATUS := cStatus
		SZN->ZN_BLEST  := "2"
		SZN->ZN_FATNF := "N"
		SZN->(MsUnlock())
	EndIf

	AADD(aRegPed,{ 	cNumPed,;
					cCodCli,;
					cLoja,;
					"2",; // 1=Bloqueio 2=Liberação 3=Exclusão
					Date(),;
					Time(),;
					RetCodUsr(),;
					CUSERNAME,;
					"14",; // Status
					"Estorno - Eliminação de Resíduos estornados"}) // Obs
	
	StaticCall( LA05A001 , PUT_HIST , aRegPed )

	//-------------------------
	//-- Workflow Status Pedido
	//-------------------------
	U_LA05W001(aRegPed[1][1],aRegPed[1][2],aRegPed[1][3],aRegPed[1][4],aRegPed[1][9])

	MsgInfo("Resíduos estornados com sucesso.", "Estornar Resíduos")

	RestArea(aAreaSZL)
	RestArea(aAreaSZM)
	RestArea(aAreaSZN)
Return

/*/{Protheus.doc} LA05ELIM
Eliminar/cortar pedido de venda
@type User Function
@author Marcos Natã Santos
@since 02/10/2019
@version 1.0
/*/
User Function LA05ELIM()
	Local cTitulo := "Eliminar/Cortar Pedido"
	Local cNumPed := SZN->ZN_NUM
	Local cCodCli := SZN->ZN_CLIENTE
	Local cLoja := SZN->ZN_LOJA
	Local cStatus := SZN->ZN_STATUS

	Local oCancel
	Local oConfirm
	Local oGet1
	Local cGet1 := Space(TamSX3("ZM_MOTIVO")[1])
	Local oGroup1
	Local oSay1
	Local oSay2
	Static oDlg

	If AllTrim(cStatus) $ "0/1/2/3/4" //-- Pedidos => Não liberados para envio ao centro de distribuição --//
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

			@ 008, 014 GROUP oGroup1 TO 043, 234 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
			@ 023, 023 SAY oSay1 PROMPT "Informe o motivo para o corte/eliminação do pedido de venda." SIZE 175, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 050, 015 SAY oSay2 PROMPT "Codigo Motivo" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 060, 015 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "Z9" PIXEL
			@ 082, 205 BUTTON oCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
			@ 082, 162 BUTTON oConfirm PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION {|| oDlg:End(), CortePed(cNumPed, cCodCli, cLoja, cGet1) } PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgAlert("Pedido não pode mais ser eliminado por completo. Por favor realize a análise dos itens pendentes.", cTitulo)
	EndIf
Return

/*/{Protheus.doc} CortePed
Eliminar/cortar pedido de venda por completo
@type Static Function
@author Marcos Natã Santos
@since 02/10/2019
@version 1.0
@param cNumPed, char
@param cCodCli, char
@param cLoja, char
/*/
Static Function CortePed(cNumPed, cCodCli, cLoja, cMotivo)
	Local aAreaSZL := SZL->( GetArea() )
	Local aAreaSZM := SZM->( GetArea() )
	Local aAreaSZN := SZN->( GetArea() )
	Local cStatus := "7" //-- Pedido Encerrado --//
	Local aRegPed := {}

	Default cNumPed := ""
	Default cCodCli := ""
	Default cLoja := ""
	Default cMotivo := "01"

	//--------------------------------------------//
	//-- Elimina/Corta todos os itens do pedido --//
	//--------------------------------------------//
	SZM->( dbSetOrder(1) )
	SZM->( dbGoTop() )
	If SZM->( dbSeek(xFilial("SZM") + cNumPed + cCodCli + cLoja) )
		While SZM->( !EOF() );
			.And. SZM->ZM_NUM = cNumPed;
			.And. SZM->ZM_CLIENTE = cCodCli;
			.And. SZM->ZM_LOJA = cLoja

			RecLock("SZM", .F.)
			SZM->ZM_QTDCORT := SZM->ZM_QTD
			SZM->ZM_MOTIVO := AllTrim(cMotivo)
			SZM->(MsUnLock())

			SZM->( dbSkip() )
		EndDo
	EndIf

	SZL->( dbSetOrder(1) )
	If SZL->( dbSeek(xFilial("SZL") + cNumPed + cCodCli + cLoja) )
		RecLock("SZL", .F.)
		SZL->ZL_STATUS := cStatus
		SZL->ZL_FATNF := Space(1)
		SZL->(MsUnlock())
	EndIf

	SZN->( dbSetOrder(1) )
	If SZN->( dbSeek(xFilial("SZN") + cNumPed + cCodCli + cLoja) )
		RecLock("SZN", .F.)
		SZN->ZN_STATUS := cStatus
		SZN->ZN_FATNF := Space(1)
		SZN->(MsUnlock())
	EndIf

	AADD(aRegPed,{ 	cNumPed,;
					cCodCli,;
					cLoja,;
					"2",; // 1=Bloqueio 2=Liberação 3=Exclusão
					Date(),;
					Time(),;
					RetCodUsr(),;
					CUSERNAME,;
					"13",; // Status
					"Eliminação - Corte/Eliminação de resíduos "}) // Obs
	
	StaticCall( LA05A001 , PUT_HIST , aRegPed )

	//-------------------------
	//-- Workflow Status Pedido
	//-------------------------
	U_LA05W001(aRegPed[1][1],aRegPed[1][2],aRegPed[1][3],aRegPed[1][4],aRegPed[1][9])

	MsgInfo("Pedido eliminado/cortado com sucesso.", "Eliminar/Cortar Pedido")

	RestArea(aAreaSZL)
	RestArea(aAreaSZM)
	RestArea(aAreaSZN)
Return

/*/{Protheus.doc} SldSimples
Busca saldo simples pela tabela SB8 (Não considera regras de negócio Linea)
@type Static Function
@author Marcos Natã Santos
@since 07/10/2019
@version 1.0
@param cProduto, char
@return nSaldo, numeric
/*/
Static Function SldSimples(cProduto)
	Local cQry := ""
	Local nQtdReg := 0
	Local nSaldo := 0

	cQry := "SELECT SUM(B8_SALDO - B8_EMPENHO - B8_QACLASS) B8_SALDO " + CRLF
	cQry += "FROM SB8010 " + CRLF
	cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQry += "AND B8_FILIAL = '0101' " + CRLF //-- Centro de Distribuição --//
	cQry += "AND B8_LOCAL = '05' " + CRLF
	cQry += "AND (B8_SALDO - B8_EMPENHO - B8_QACLASS) > 0 " + CRLF
	cQry += "AND B8_PRODUTO = '"+ cProduto +"' " + CRLF
	cQry := ChangeQuery(cQry)

	If Select("SLDSIMP") > 0
		SLDSIMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "SLDSIMP"

	SLDSIMP->(dbGoTop())
	COUNT TO nQtdReg
	SLDSIMP->(dbGoTop())

	If nQtdReg > 0
		nSaldo := SLDSIMP->B8_SALDO
	EndIf

	SLDSIMP->(DbCloseArea())
Return nSaldo
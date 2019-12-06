#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| P.E. | MT103FIM | Autor | Marcos Natã | Data | 28.07.2016 	       |
//+--------------------------------------------------------------------+
//| Descr. | Preenche campos na SF9 (Manutenção CIAP)                  |
//+--------------------------------------------------------------------+
//| Uso | Departamento de Tecnologia da Informação                     |
//+--------------------------------------------------------------------+

User Function MT103FIM()

	Local nOpcao := PARAMIXB[1] //3 = Incluir | 4 = Classificar
	Local nConfirma := PARAMIXB[2] //1 = Confirmar | 0 = Cancelar
	Local aAreaSF9 := SF9->(GetArea()) //Manutenção CIAP
	Local cTipo_Doc := SF1->F1_TIPO //Tipo Devolução

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Correção da SD7, para que quando for devolução                      ³
	//³o sistema altere o D7_TIPOCQ para M.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcao = 4) .And. (nConfirma = 1) .And. (cTipo_Doc = 'D')
		U_CORRSD7()
		U_EMLNCC()
	EndIf

	//+--------------------------------------------------------------------+
	//| Preenche campos na SF9 (Manutenção CIAP)                           |
	//+--------------------------------------------------------------------+
	If (nOpcao = 3 .Or. nOpcao = 4) .And. nConfirma = 1
		Private oDlg
		Private oSay
		Private cBem := Space(Len(SF9->F9_FUNCIT)) //Descrição da função do Ativo Imobilizado
		Private aButtons := {}

		cQry:="SELECT D1_DTDIGIT, D1_DOC, D1_SERIE, D1_ITEM, D1_FORNECE, D1_CF, D1_LOJA, D1_TIPO, D1_CC, D1_COD, D1_XDESC, D1_TP "
		cQry+="FROM SD1010 "
		cQry+="WHERE D1_DTDIGIT = '"+DTOS(SD1->D1_DTDIGIT)+"' "
		cQry+="AND D1_DOC = '"+SD1->D1_DOC+"' "
		cQry+="AND D1_SERIE = '"+SD1->D1_SERIE+"' "
		cQry+="AND D1_FORNECE = '"+SD1->D1_FORNECE+"' "
		cQry+="AND D1_LOJA = '"+SD1->D1_LOJA+"' "
		cQry+="AND D1_EMISSAO = '"+DTOS(SD1->D1_EMISSAO)+"' "
		cQry+="AND D_E_L_E_T_ = ' '"

		cQry:= ChangeQuery(cQry)
		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS "QRY"

		DbSelectArea("SF9")
		DbSetOrder(3) //Dt. Digit + NFe + Serie + Item + Fornec + Cfo
		DbGoTop()
		QRY->(DbGoTop())

		While QRY->(!EOF())
			If QRY->D1_TP == 'AI'
				If SF9->(DbSeek(xFilial("SF9") + QRY->D1_DTDIGIT + QRY->D1_DOC + QRY->D1_SERIE + QRY->D1_ITEM + QRY->D1_FORNECE + QRY->D1_CF))
					RecLock("SF9", .F.)
					SF9->F9_ITEMNF2 := SF9->F9_ITEMNFE
					SF9->F9_CC := QRY->D1_CC
					SF9->F9_CODPROD := QRY->D1_COD
					SF9->F9_PL := Posicione("SB1", 1, xFilial("SB1") + QRY->D1_COD, "B1_XCTAI")
					SF9->F9_CHVNFE := Posicione("SF1", 1, xFilial("SF1") + QRY->D1_DOC + QRY->D1_SERIE + QRY->D1_FORNECE + QRY->D1_LOJA + QRY->D1_TIPO, "F1_CHVNFE")
					SF9->F9_ESPNF := Posicione("SF1", 1, xFilial("SF1") + QRY->D1_DOC + QRY->D1_SERIE + QRY->D1_FORNECE + QRY->D1_LOJA + QRY->D1_TIPO, "F1_ESPECIE")

					DEFINE DIALOG oDlg TITLE "Informe a função do Bem" FROM 000,000 TO 200, 400 PIXEL
					@ 030, 035 SAY oSay PROMPT "Ativo: " + QRY->D1_XDESC SIZE 100, 012 OF oDlg PIXEL
					@ 045, 035 MSGET cBem SIZE 150, 012 OF oDlg PIXEL VALID NAOVAZIO()
					ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| },, aButtons)

					SF9->F9_FUNCIT := cBem
					cBem := Space(Len(SF9->F9_FUNCIT))
					SF9->(MsUnlock())
				EndIf
			EndIf
			QRY->(DbSkip(1))
		EndDo

		RestArea(aAreaSF9)
	EndIf
Return
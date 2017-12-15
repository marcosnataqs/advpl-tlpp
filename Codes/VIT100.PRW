#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} VIT100
Manutenção de Responsáveis

@author marcos.santos
@since 01/12/2017
@version 1.0

@type function
/*/
User Function VIT100() //-- U_VIT100()
	Local oButton1
	Local oButton2
	Local oComboBo1
	Local oGet1
	Local oGet2
	Local oGet3
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Private aButtons := {}
	Private cGet1 := Space(16)
	Private cGet2 := Space(3)
	Private cGet3 := Space(6)
	Private nComboBo1 := Space(1)
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Manutenção de Responsáveis" FROM 000, 000  TO 400, 410 COLORS 0, 16777215 PIXEL

	fMSNewGet()
	@ 022, 007 SAY oSay1 PROMPT "Doc.:" SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 025 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg VALID NAOVAZIO() COLORS 0, 16777215 F3 "QDH" PIXEL
	@ 022, 085 SAY oSay2 PROMPT "Rev.:" SIZE 015, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 102 MSGET oGet2 VAR cGet2 SIZE 045, 010 OF oDlg VALID NAOVAZIO() COLORS 0, 16777215 READONLY PIXEL
	@ 020, 162 BUTTON oButton1 PROMPT "Buscar" SIZE 032, 010 OF oDlg ACTION fMSNewGet() PIXEL
	@ 145, 007 SAY oSay3 PROMPT "Usuário:" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 155, 007 MSGET oGet3 VAR cGet3 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "MATR" PIXEL
	@ 145, 065 SAY oSay4 PROMPT "Responsabilidade:" SIZE 044, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 155, 065 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1 = Elaborador","2 = Revisor","3 = Aprovador","4 = Homologador"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 155, 150 BUTTON oButton2 PROMPT "Deletar" SIZE 032, 010 OF oDlg ACTION fDeleteReg() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()},, aButtons)

Return

/*/{Protheus.doc} fMSNewGet
NewGetDados com as responsabilidades do documento

@author marcos.santos
@since 01/12/2017
@version 1.0

@type function
/*/
Static Function fMSNewGet()
	Local nX
	Local aHeaderEx := {}
	Local aFieldFill := {}
	Local aFields := {"QD0_DOCTO","QD0_RV","QD0_AUT","QD0_ORDEM","QD0_MAT"}
	Local aAlterFields := {}
	Private aColsEx := {}
	Static oMSNewGet

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Carrega todos os dados
	fLoadData()

	oMSNewGet := MsNewGetDados():New(042, 000, 122, 210,, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 99, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

/*/{Protheus.doc} fLoadData
Carrega dados na NewGetDados

@author marcos.santos
@since 01/12/2017
@version 1.0

@type function
/*/
Static Function fLoadData()
	Local aAux := {}

	cQry :=  "SELECT QD0_DOCTO, QD0_RV, QD0_AUT, QD0_ORDEM, QD0_MAT FROM "+RetSqlName("QD0")+" "
	cQry +=  "WHERE D_E_L_E_T_ <> '*' "
	cQry +=  "AND QD0_DOCTO = '"+cGet1+"' "
	cQry +=  "AND QD0_RV = '"+cGet2+"' "
	cQry +=  "ORDER BY QD0_ORDEM "
	cQry := ChangeQuery(cQry)

	If(Select("QRY") > 0)
		QRY->(DBCloseArea())
	EndIf

	TCQUERY cQry ALIAS QRY NEW

	QRY->(DbGoTop())
	While QRY->(!EOF())
		Aadd(aAux, QRY->QD0_DOCTO)
		Aadd(aAux, QRY->QD0_RV)
		Aadd(aAux, QD0_AUT)
		Aadd(aAux, QD0_ORDEM)
		Aadd(aAux, QD0_MAT)
		Aadd(aAux, .F.)
		Aadd(aColsEx, aClone(aAux))
		QRY->(DbSkip())
		aAux := {}
	EndDo

Return

/*/{Protheus.doc} fDeleteReg
Deleta registros na NewGetDados

@author marcos.santos
@since 01/12/2017
@version 1.0

@type function
/*/
Static Function fDeleteReg()
	Local aAreaQD0 := QD0->(GetArea())
	Local aAreaQD1 := QD1->(GetArea())
	Local aResp := {'E', 'R', 'A', 'H'}
	Local nItem := Val(nComboBo1)
	Local cCodUsr := "0101" + cGet3

	If MsgYesNo("Deseja realmente deletar o responsável?", "Atenção")
		BEGIN TRANSACTION

			DbSelectArea("QD0")
			DbSetOrder(4) //-- QD0_FILIAL+QD0_DOCTO+QD0_RV+QD0_AUT+QD0_MAT

			If DbSeek(xFilial("QD0")+cGet1+cGet2+aResp[nItem]+cCodUsr)
				RecLock("QD0", .F.)
				DbDelete()
				MsUnLock()
			Else
				MsgAlert("Usuário/Responsabilidade não encontrado nas responsabilidades!")
				DisarmTransaction()
				RestArea(aAreaQD0)
				Return
			EndIf

			DbSelectArea("QD1")
			DbSetOrder(9) //-- QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1_TPPEND+QD1_MAT

			If DbSeek(xFilial("QD1")+cGet1+cGet2+PadR(aResp[nItem],Len(QD1->QD1_TPPEND))+cCodUsr)
				RecLock("QD1", .F.)
				DbDelete()
				MsUnLock()
			Else
				MsgAlert("Usuário/Responsabilidade não encontrado nas distribuições!")
				DisarmTransaction()
				RestArea(aAreaQD1)
				Return
			EndIf

		END TRANSACTION
		
		MsgInfo("Usuário deletado com sucesso!")
		fMSNewGet() //-- Refresh
	EndIf

	RestArea(aAreaQD0)
	RestArea(aAreaQD1)

Return
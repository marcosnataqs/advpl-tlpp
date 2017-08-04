#Include "Protheus.ch"

/*/{Protheus.doc} REABOP

Reabre uma ordem de produção selecionada.

@author Marcos Natã Santos
@since 31/03/2017
@version undefined

@type function
/*/

User Function REABOP()
	Local cAlias := "SC2"
	Private cCpo := "C2_DATRF"
	Private cCadastro := "Reabre Ordem de Produção"

	Private aRotina := {}
	aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
	aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
	aAdd(aRotina, {"Reabrir", "U_REORP", 0, 3})
	aAdd(aRotina, {"Legenda", "U_REORPLEG", 0, 5})

	dbSelectArea(cAlias)
	dbSetOrder(1)

	mBrowse(6, 1, 22, 75, cAlias,,cCpo)

Return Nil

//Legendas
User Function REORPLEG()
	Local aLegenda := {}
	aAdd(aLegenda, {"BR_VERDE", "Aberta" })
	aAdd(aLegenda, {"BR_VERMELHO", "Encerrada" })
	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil

//Altera o campo de encerramento da ordem de produção
User Function REORP()
	If ApMsgYesNo("Deseja realmente reabrir esta ordem de produção?")
		RecLock("SC2", .F.)
		SC2->C2_DATRF := CTOD("")
		MsUnlock()
	EndIf

Return
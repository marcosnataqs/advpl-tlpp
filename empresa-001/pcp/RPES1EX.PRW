#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | RPES1EX | Autor | Marcos Natã | Data | 30/06/2017         |
//+--------------------------------------------------------------------+
//| Descr. | Exporta Pesagem por Usuário em formato planilha.          |
//+--------------------------------------------------------------------+
//| Uso | Genix Qualicaps                                              |
//+--------------------------------------------------------------------+

User Function RPES1EX()
	Private cPerg := "RPES1EX"
	Private dDeData
	Private dAteData
	Private cUsuario

	AjustaSX1()

	//Tela de Parametros
	Pergunte(cPerg, .T.)

	dDeData := MV_PAR01
	dAteData := MV_PAR02
	cUsuario := MV_PAR03

	ProcExport()

Return

// Seleciona local para exportação
Static Function ProcExport()
	Private targetDir := "C:\Windows\Temp\"

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")

Return

// Estrutura do arquivo excel
Static Function RunExport()
	Private oExcel := FWMsExcel():New()
	Private oExcelApp := MsExcel():New()
	Private aHead := {}
	Private aRow := {}

	oExcel:AddworkSheet("rpes1ex")
	oExcel:AddTable("rpes1ex", "Pesagem por Usuário")

	HeadEx()
	BodyEx()

	oExcel:Activate()
	oExcel:GetXMLFile(targetDir + "rpes1ex.xls")
	oExcelApp:WorkBooks:Open(targetDir + "rpes1ex.xls")
	oExcelApp:SetVisible(.T.)

Return

// Cria cabeçalho
Static Function HeadEx()
	aHead := {;
	"DT_PESAGEM",;
	"OP",;
	"PRODUTO",;
	"DESCRICAO",;
	"LOTE",;
	"QTD",;
	"VOLUMES",;
	"USUARIO";
	}

	For i = 1 To Len(aHead)
		oExcel:AddColumn("rpes1ex", "Pesagem por Usuário", aHead[i], 2, 1, .F.)
	Next

Return

// Gera corpo de dados
Static Function BodyEx()
	Local cTmp1
	Local cTmp2
	Private i
	Private cQry := ""
	aRow := Array(Len(aHead))

	cQry +=  "SELECT "
	cQry +=  "  Z1_DATAPES      DT_PESAGEM, "
	cQry +=  "  Z1_ORDPROD      OP, "
	cQry +=  "  Z1_CODPRO       PRODUTO, "
	cQry +=  "  Z1_DESCPRO      DESCRICAO, "
	cQry +=  "  Z1_LOTE         LOTE, "
	cQry +=  "  SUM(Z1_QUANT)   QTD, "
	cQry +=  "  SUM(Z1_QTDVOLU) VOLUMES, "
	cQry +=  "  Z1_USUARIO      USUARIO "
	cQry +=  "FROM SZ1010 "
	cQry +=  "WHERE D_E_L_E_T_ = ' ' "
	cQry +=  "      AND Z1_DATAPES BETWEEN '"+DTOS(dDeData)+"' AND '"+DTOS(dAteData)+"' "
	If Empty(cUsuario)
		cQry +=  "      AND Z1_USUARIO != ' ' "
	Else
		cQry +=  "      AND Z1_USUARIO = '"+cUsuario+"' "
	EndIf
	cQry +=  "GROUP BY Z1_DATAPES, Z1_ORDPROD, Z1_CODPRO, Z1_DESCPRO, Z1_LOTE, Z1_USUARIO "
	cQry +=  "ORDER BY Z1_DATAPES, Z1_ORDPROD, Z1_LOTE "

	cQry:= ChangeQuery(cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	cTmp1 := QRY->OP
	cTmp2 := QRY->USUARIO

	While QRY->(!EOF())
		IncProc(ALLTRIM(QRY->OP) + " - " + ALLTRIM(QRY->USUARIO))
		If cTmp1 = QRY->OP .And. cTmp2 = QRY->USUARIO
			For i := 1 To Len(aHead)
				If aHead[i] == "DT_PESAGEM"
					aRow[i] := DTOC(SToD(&("QRY->" + &("aHead[i]"))))
				Else
					aRow[i] := &("QRY->" + &("aHead[i]"))
				EndIf
			Next
			cTmp1 := QRY->OP
			cTmp2 := QRY->USUARIO
		Else
			oExcel:AddRow("rpes1ex", "Pesagem por Usuário", aRow)
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				For i := 1 To Len(aHead)
					If aHead[i] == "DT_PESAGEM"
						aRow[i] := DTOC(SToD(&("QRY->" + &("aHead[i]"))))
					Else
						aRow[i] := &("QRY->" + &("aHead[i]"))
					EndIf
				Next
			Next
			cTmp1 := QRY->OP
			cTmp2 := QRY->USUARIO
		EndIf
		QRY->(DbSkip())
		If QRY->(EOF())
			oExcel:AddRow("rpes1ex", "Pesagem por Usuário", aRow)
		EndIf
	EndDo

Return

Static Function AjustaSX1()
	PutSx1(cPerg,"01","De data?","","","MV_CH1","D",8,0,0,"G","",,"","",;
	"MV_PAR01","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"02","Até data?","","","MV_CH2","D",8,0,0,"G","",,"","",;
	"MV_PAR02","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"03","Usuário?","","","MV_CH3","C",20,0,0,"G","","US3","","",;
	"MV_PAR03","","","","","","","","","","","","","","","","",{},{},{},"")

Return
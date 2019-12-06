#Include 'Protheus.ch'
#Include 'Topconn.ch'


/*/{Protheus.doc} VIT061
Inicializa relatório de Entrada de Notas Fiscais por Usuário
@author marcos.santos
@since 31/10/2017
@version 1.0

@type function
/*/
User Function VIT061()
	Local cPerg := "VIT061"
	Private oReport

	AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
Define estrutura do relatório
@author marcos.santos
@since 31/10/2017
@version 1.0
@return oReport

@type function
/*/
Static Function ReportDef()
	Local oReport, oSection, oSectionInfo
	Local cTitulo := "ENTRADA DE NOTAS FISCAIS POR USUÁRIO"
	Local cDescricao := "Imprime relatório de entrada de notas fiscais por usuário."

	oReport := TReport():New("VIT061",cTitulo,"VIT061", {|oReport| PrintReport(oReport)}, cDescricao)
	oReport:SetLandsCape()

	oSectionInfo := TRSection():New(oReport, "PARAMETROS")
	TRCell():New(oSectionInfo,"CEL01_DETADA","","De Data",,20,/*lPixel*/,/* Formula*/)
	TRCell():New(oSectionInfo,"CEL02_ATETADA","","Até Data",,20,/*lPixel*/,/* Formula*/)
	TRCell():New(oSectionInfo,"CEL03_USUARIO","","Usuário",,40,/*lPixel*/,/* Formula*/)

	oSection := TRSection():New(oReport, cTitulo)
	TRCell():New(oSection,"CEL01_USRINC","SF1",RetTitle("F1_USERLGI"),PesqPict("SF1","F1_USERLGI"),70,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL02_DOC","SF1",RetTitle("F1_DOC"),PesqPict("SF1","F1_DOC"),30,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL03_SERIE","SF1",RetTitle("F1_SERIE"),PesqPict("SF1","F1_SERIE"),30,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL04_ESPECIE","SF1",RetTitle("F1_ESPECIE"),PesqPict("SF1","F1_ESPECIE"),30,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL05_FORNECE","SF1",RetTitle("F1_FORNECE"),PesqPict("SF1","F1_FORNECE"),30,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL06_LOJA","SF1",RetTitle("F1_LOJA"),PesqPict("SF1","F1_LOJA"),30,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL07_NOME","SA2",RetTitle("A2_NOME"),PesqPict("SA2","A2_NOME"),100,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL08_VALBRUT","SF1",RetTitle("F1_VALBRUT"),PesqPict("SF1","F1_VALBRUT"),40,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL09_DTDIGIT","SF1",RetTitle("F1_DTDIGIT"),PesqPict("SF1","F1_DTDIGIT"),25,/*lPixel*/,/* Formula*/)
	TRCell():New(oSection,"CEL10_EMISSAO","SF1",RetTitle("F1_EMISSAO"),PesqPict("SF1","F1_EMISSAO"),25,/*lPixel*/,/* Formula*/)

	TRFunction():New(oSection:Cell("CEL01_USRINC"),NIL,"COUNT",,,,,.F.,.T.)
	TRFunction():SetEndReport()

	oReport:SetTotalInLine(.T.)

Return oReport

/*/{Protheus.doc} PrintReport
Trata os dados e executa a impressão do relatório
@author marcos.santos
@since 31/10/2017
@version 1.0
@param oReport, object, description
@type function
/*/
Static Function PrintReport(oReport)
	Local oSectionInfo := oReport:Section(1)
	Local oSection := oReport:Section(2)
	Local cQry
	Local cUsr
	Private aDados[10]
	Private MvUsuario
	Private DeData
	Private AteData
	
	// Atribuindo paramentros a variáveis
	DeData := MV_PAR01
	AteData := MV_PAR02
	MvUsuario := MV_PAR03

	oSection:Cell("CEL01_USRINC"):SetBlock({|| aDados[01]})
	oSection:Cell("CEL02_DOC"):SetBlock({|| aDados[02]})
	oSection:Cell("CEL03_SERIE"):SetBlock({|| aDados[03]})
	oSection:Cell("CEL04_ESPECIE"):SetBlock({|| aDados[04]})
	oSection:Cell("CEL05_FORNECE"):SetBlock({|| aDados[05]})
	oSection:Cell("CEL06_LOJA"):SetBlock({|| aDados[06]})
	oSection:Cell("CEL07_NOME"):SetBlock({|| aDados[07]})
	oSection:Cell("CEL08_VALBRUT"):SetBlock({|| aDados[08]})
	oSection:Cell("CEL09_DTDIGIT"):SetBlock({|| aDados[09]})
	oSection:Cell("CEL10_EMISSAO"):SetBlock({|| aDados[10]})
	oSection:Cell("CEL08_VALBRUT"):SetAlign("LEFT")

	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf

	cQry :=  "SELECT "
	cQry +=  "  SF1.F1_USERLGI USRINC, "
	cQry +=  "  SF1.F1_DOC     DOC, "
	cQry +=  "  SF1.F1_SERIE   SERIE, "
	cQry +=  "  SF1.F1_ESPECIE ESPECIE, "
	cQry +=  "  SF1.F1_FORNECE FORNECE, "
	cQry +=  "  SF1.F1_LOJA LOJA, "
	cQry +=  "  SF1.F1_VALBRUT VALBRUT, "
	cQry +=  "  SF1.F1_DTDIGIT DTDIGIT, "
	cQry +=  "  SF1.F1_EMISSAO EMISSAO "
	cQry +=  "FROM "+RetSqlName("SF1")+" SF1 "
	cQry +=  "WHERE SF1.D_E_L_E_T_ <> '*' "
	cQry +=  "AND SF1.F1_FILIAL = '"+xFilial("SF1")+"' "
	cQry +=  "AND SF1.F1_DTDIGIT >= '"+DToS(DeData)+"' "
	cQry +=  "AND SF1.F1_DTDIGIT <= '"+DToS(AteData)+"' "
	cQry +=  "ORDER BY SF1.F1_DTDIGIT, SF1.F1_DOC "

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "TMP"

	oReport:NoUserFilter()

	oSectionInfo:Init()
	oSectionInfo:Cell("CEL01_DETADA"):SetValue(DToC(DeData))
	oSectionInfo:Cell("CEL02_ATETADA"):SetValue(DToC(AteData))
	If Empty(MvUsuario)
		oSectionInfo:Cell("CEL03_USUARIO"):SetValue("Todos")
	Else
		oSectionInfo:Cell("CEL03_USUARIO"):SetValue(UsrFullName(MvUsuario))
	EndIf
	oSectionInfo:PrintLine()
	oSectionInfo:Finish()

	oReport:SetMeter(TMP->(RecCount()))
	oSection:Init()

	TMP->(DbGoTop())
	If !Empty(MvUsuario) // Se o parametro usuário não for preenchido, busca por todos usuários
		While TMP->(!EOF())
			If oReport:Cancel()
				Exit
			EndIf

			If MvUsuario = SUBSTR(Embaralha(TMP->USRINC,1),3,6)

				cUsr := UsrFullName(SUBSTR(AllTrim(Left(Embaralha(TMP->USRINC,1),15)),3,6))

				aDados[1] := cUsr
				aDados[2] := TMP->DOC
				aDados[3] := TMP->SERIE
				aDados[4] := TMP->ESPECIE
				aDados[5] := TMP->FORNECE
				aDados[6] := TMP->LOJA
				aDados[7] := Posicione("SA2",1,xFilial("SA2")+TMP->FORNECE+TMP->LOJA,"A2_NOME")
				aDados[8] := TMP->VALBRUT
				aDados[9] := cValToChar(SToD(TMP->DTDIGIT))
				aDados[10] := cValToChar(SToD(TMP->EMISSAO))

				oSection:PrintLine()
				oReport:SkipLine()
				oReport:IncMeter()
				aFill(aDados,Nil)
			EndIf

			TMP->(DbSkip())
		EndDo
	Else
		While TMP->(!EOF())
			If oReport:Cancel()
				Exit
			EndIf

			cUsr := UsrFullName(SUBSTR(AllTrim(Left(Embaralha(TMP->USRINC,1),15)),3,6))

			aDados[1] := cUsr
			aDados[2] := TMP->DOC
			aDados[3] := TMP->SERIE
			aDados[4] := TMP->ESPECIE
			aDados[5] := TMP->FORNECE
			aDados[6] := TMP->LOJA
			aDados[7] := Posicione("SA2",1,xFilial("SA2")+TMP->FORNECE+TMP->LOJA,"A2_NOME")
			aDados[8] := TMP->VALBRUT
			aDados[9] := cValToChar(SToD(TMP->DTDIGIT))
			aDados[10] := cValToChar(SToD(TMP->EMISSAO))

			oSection:PrintLine()
			oReport:SkipLine()
			oReport:IncMeter()
			aFill(aDados,nil)

			TMP->(DbSkip())
		EndDo
	EndIf

	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf

	oSection:Finish()
	MS_FLUSH()

Return


/*/{Protheus.doc} AjustaSX1
Incluí/Ajusta perguntas na tabela SX1
@author marcos.santos
@since 31/10/2017
@version 1.0
@param cPerg, characters, description
@type function
/*/
Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","De data?","mv_ch1","D",8,0,0,"G","mv_par01","","","","","NAOVAZIO()"})
	aAdd(aRegs,{"02","Até data?","mv_ch2","D",8,0,0,"G","mv_par02","","","","","NAOVAZIO()"})
	aAdd(aRegs,{"03","Usuário?","mv_ch3","C",20,0,0,"G","mv_par03","","","","US4",""})

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i:=1 to Len(aRegs)
		dbSeek(cPerg+aRegs[i][1])
		If !Found()
			RecLock("SX1",!Found())
			SX1->X1_GRUPO := cPerg
			SX1->X1_ORDEM := aRegs[i][01]
			SX1->X1_PERGUNT := aRegs[i][02]
			SX1->X1_VARIAVL := aRegs[i][03]
			SX1->X1_TIPO := aRegs[i][04]
			SX1->X1_TAMANHO := aRegs[i][05]
			SX1->X1_DECIMAL := aRegs[i][06]
			SX1->X1_PRESEL := aRegs[i][07]
			SX1->X1_GSC := aRegs[i][08]
			SX1->X1_VAR01 := aRegs[i][09]
			SX1->X1_DEF01 := aRegs[i][10]
			SX1->X1_DEF02 := aRegs[i][11]
			SX1->X1_DEF03 := aRegs[i][12]
			SX1->X1_F3 := aRegs[i][13]
			SX1->X1_VALID := aRegs[i][14]
			MsUnlock()
		Endif
	Next

	RestArea(aArea)

Return
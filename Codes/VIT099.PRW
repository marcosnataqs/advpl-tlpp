#Include "Protheus.ch"
#Include "Topconn.ch"

#Define CRLF Chr(13) + Chr(10) // Nova linha
#Define PV ";" // Separação

/*/{Protheus.doc} VIT099
Parametros para geração do arquivo para importação FPW
@author marcos.santos
@since 23/11/2017
@version 1.0

@type function
/*/
User Function VIT099()
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Private aButtons := {}
	Private cGet1 := Space(6)
	Private cGet2 := "ZZZZZZ"
	Private dGet3 := FirstDate(Date())
	Private dGet4 := LastDate(Date())
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Exportação Resultados Periodo" FROM 000, 000  TO 210, 400 COLORS 0, 16777215 PIXEL

	@ 007, 025 GROUP oGroup1 TO 032, 175 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
	@ 019, 029 SAY oSay1 PROMPT "Informe os parametros para geração do arquivo TXT." SIZE 128, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 025 SAY oSay2 PROMPT "De matrícula:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 052, 025 SAY oSay3 PROMPT "Até matrícula:" SIZE 034, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 025 SAY oSay4 PROMPT "De data:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 077, 025 SAY oSay5 PROMPT "Até data:" SIZE 026, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 085 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "MATR" PIXEL
	@ 050, 085 MSGET oGet2 VAR cGet2 SIZE 045, 010 OF oDlg VALID NAOVAZIO() COLORS 0, 16777215 F3 "MATR" PIXEL
	@ 062, 085 MSGET oGet3 VAR dGet3 SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 085 MSGET oGet4 VAR dGet4 SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End(), ImportarSPB()} , {|| oDlg:End()},, aButtons)

Return

/*/{Protheus.doc} ImportarSPB
Montagem do dados para importação
@author marcos.santos
@since 23/11/2017
@version 1.0

@type function
/*/
Static Function ImportarSPB()
	Local cDados := ""
	Local aDados := Array(8)
	Local cEmpresa := "15"
	Local cMat
	Local cVerba
	Local nValor

	cQry :=  "SELECT "
	cQry +=  "  SUBSTR(SPB.PB_MAT, 3) AS MAT, "
	cQry +=  "  CASE SPB.PB_PD "
	cQry +=  "  WHEN '141' "
	cQry +=  "    THEN '24585' "
	cQry +=  "  WHEN '311' "
	cQry +=  "    THEN '22570' "
	cQry +=  "  WHEN '403' "
	cQry +=  "    THEN '22570' "
	cQry +=  "  WHEN '314' "
	cQry +=  "    THEN '22570' "
	cQry +=  "  WHEN '148' "
	cQry +=  "    THEN '24505' "
	cQry +=  "  WHEN '147' "
	cQry +=  "    THEN '20230' "
	cQry +=  "  WHEN '259' "
	cQry +=  "    THEN '20060' "
	cQry +=  "  WHEN '400' "
	cQry +=  "    THEN '23641' "
	cQry +=  "  ELSE SPB.PB_PD END    AS VERBA, "
	cQry +=  "  (SPB.PB_HORAS * 100)  AS VALOR, "
	cQry +=  "  SPB.PB_PARCELA        AS PARCELA_DE, "
	cQry +=  "  SPB.PB_PARCELA        AS PARCELA_ATE "
	cQry +=  "FROM " + RetSqlName("SPB") + " SPB "
	cQry +=  "WHERE SPB.D_E_L_E_T_ <> '*' "
	cQry +=  "      AND SPB.PB_FILIAL = '" + xFilial("SPB") + "' "
	cQry +=  "      AND SPB.PB_MAT >= '"+cGet1+"' "
	cQry +=  "      AND SPB.PB_MAT <= '"+cGet2+"' "
	cQry +=  "      AND SPB.PB_DATA >= '"+DToS(dGet3)+"' "
	cQry +=  "      AND SPB.PB_DATA <= '"+DToS(dGet4)+"' "
	cQry +=  "ORDER BY SPB.PB_MAT, SPB.PB_DATA, VERBA "
	cQry := ChangeQuery(cQry)

	If(Select("QRY") > 0)
		QRY->(DBCloseArea())
	EndIf

	TCQUERY cQry ALIAS QRY NEW

	QRY->(DbGoTop())
	cMat := QRY->MAT
	cVerba := QRY->VERBA
	nValor := 0 // Soma valor quando MAT/VERBA forem iguais

	While QRY->(!EOF())
		If QRY->MAT = cMat .And. QRY->VERBA = cVerba
			nValor += QRY->VALOR
			aDados[1] := cEmpresa
			aDados[2] := QRY->MAT
			aDados[3] := QRY->VERBA
			aDados[4] := nValor
			aDados[5] := QRY->PARCELA_DE
			aDados[6] := QRY->PARCELA_ATE
		Else
			cDados += aDados[1] + PV + AllTrim(aDados[2]) + PV + AllTrim(aDados[3]) + PV + SUBSTR(DToS(dGet3),1,6) + PV
			cDados += SUBSTR(DToS(dGet4),1,6) + PV + AllTrim(cValToChar(aDados[4])) + PV + AllTrim(cValToChar(aDados[5]))
			cDados += PV + AllTrim(cValToChar(aDados[6])) + CRLF
			nValor := QRY->VALOR
			aDados[1] := cEmpresa
			aDados[2] := QRY->MAT
			aDados[3] := QRY->VERBA
			aDados[4] := nValor
			aDados[5] := QRY->PARCELA_DE
			aDados[6] := QRY->PARCELA_ATE
		EndIf
		cMat := QRY->MAT
		cVerba := QRY->VERBA
		QRY->(DbSkip())
		
		If QRY->(EOF())
			nValor += QRY->VALOR
			aDados[1] := cEmpresa
			aDados[2] := cMat
			aDados[3] := cVerba
			aDados[4] := nValor
			aDados[5] := QRY->PARCELA_DE
			aDados[6] := QRY->PARCELA_ATE
			cDados += aDados[1] + PV + AllTrim(aDados[2]) + PV + AllTrim(aDados[3]) + PV + SUBSTR(DToS(dGet3),1,6) + PV
			cDados += SUBSTR(DToS(dGet4),1,6) + PV + AllTrim(cValToChar(aDados[4])) + PV + AllTrim(cValToChar(aDados[5]))
			cDados += PV + AllTrim(cValToChar(aDados[6])) + CRLF
		EndIf
	EndDo
	
	QRY->(DBCloseArea())

	MemoWrite("C:\Windows\Temp\fpwimport"+DToS(Date())+".txt", cDados)
	ShellExecute("Open", "C:\Windows\Temp\fpwimport"+DToS(Date())+".txt", "", "C:\", 1)

Return
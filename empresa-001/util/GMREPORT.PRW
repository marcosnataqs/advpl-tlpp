#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Fileio.ch"
#Define CRLF CHR(13)+CHR(10)

//+--------------------------------------------------------------------+
//| Rotina | GMREPORT | Autor | Marcos Natã | Data | 20/09/2016 	   |
//+--------------------------------------------------------------------+
//| Descr. | Gera relatório referente ao GoldMine		               |
//+--------------------------------------------------------------------+
//| Uso | Departamento de Tecnologia da Informação                     |
//+--------------------------------------------------------------------+

User Function GMREPORT()
	Local oComboBo1
	Local oGet1
	Local oGroup1
	Local oGroup2
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local aButtons := {}
	Static oDlg
	Private nComboBo1 := "Select"
	Private cGet1 := Year(Date())

  DEFINE MSDIALOG oDlg TITLE "GoldMine" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 007, 025 GROUP oGroup1 TO 032, 225 PROMPT "Report" OF oDlg COLOR 0, 16777215 PIXEL
    @ 017, 030 SAY oSay1 PROMPT "Choose a report type for cvs export" SIZE 187, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 025 GROUP oGroup2 TO 177, 225 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
    @ 060, 037 SAY oSay2 PROMPT "Reports:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 070, 037 SAY oSay3 PROMPT "Number of Capsules: Amount of orders in number of capsules." SIZE 122, 015 OF oDlg COLORS 0, 16777215 PIXEL
    @ 090, 037 SAY oSay4 PROMPT "Value Euro Currency: Amount of orders in euro currency." SIZE 122, 015 OF oDlg COLORS 0, 16777215 PIXEL
    @ 110, 037 SAY oSay5 PROMPT "Number of Orders: Ammount of orders in quantity." SIZE 122, 015 OF oDlg COLORS 0, 16777215 PIXEL
    @ 130, 037 SAY oSay6 PROMPT "Different Products: Ammount of different products." SIZE 122, 015 OF oDlg COLORS 0, 16777215 PIXEL
    @ 195, 025 SAY oSay7 PROMPT "Choose a report:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 207, 025 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"Select","Number of Capsules","Value Euro Currency","Number of Orders","Different Products", "Client Contacts"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 195, 155 SAY oSay8 PROMPT "Choose year of report:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 207, 155 MSGET oGet1 VAR cGet1 SIZE 020, 010 OF oDlg PICTURE "@! 9999"  VALID NAOVAZIO() COLORS 0, 16777215 PIXEL
    
  ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| ProcReport()} , {|| oDlg:End()},, aButtons)

Return

// Régua para processamento
Static Function ProcReport()
	Private targetDir := ""
	Private cRepName := "DefaultReport.csv"
	Private cYear := cGet1
	Private cYear1 := cYear-1
	Private cYear2 := cYear-2
	
	If nComboBo1 = "Select"
		MsgAlert("Select a report!")
		Return
	EndIf
	
	targetDir := cGetFile( '*.csv' , 'Save in', 1, 'C:\', .F., nOR(GETF_LOCALHARD, GETF_RETDIRECTORY),.F., .F. )
	If Empty(targetDir)
		Return
	EndIf
	
	Processa({||RunReport()}, "Creating report", "Wait a moment...")
	
Return

// Seleciona relatório
Static Function RunReport()
	If nComboBo1 = "Number of Orders"
		NOReport()
		cRepName := UPPER("QBR-GM-01.csv")
	ElseIf nComboBo1 = "Number of Capsules"
		NCReport()
		cRepName := UPPER("QBR-GM-03.csv")
	ElseIf nComboBo1 = "Value Euro Currency"
		VCReport()
		cRepName := UPPER("QBR-GM-02.csv")
	ElseIf nComboBo1 = "Different Products"
		DPReport()
		cRepName := UPPER("QBR-GM-04.csv")
	EndIf
	
	If nComboBo1 = "Client Contacts"
		CCReport()
		cRepName := UPPER("QBR-GM-CLIEN.csv")
	Else
		FinalReport()
	EndIf
	
Return

// Cria arquivo CSV no local selecionado
Static Function CreateCSV()
	nHandle := FCreate(targetDir + cRepName, FC_NORMAL)
	If nHandle = -1
		MsgAlert("File was not created! " + STR(FERROR()))
		Break
	Else
		FWrite(nHandle, cReportTxt)
		FClose(nHandle)
		MsgInfo("Report saved: " + targetDir + cRepName)
	EndIf
	
return

// Monta relatório final
Static Function FinalReport()	
	Private cReportTxt := ""
	
	cQry := "SELECT YTD.CODE, YTD.CUSTOMER, YTD.SALES, OIH.OIH, YR1.SALES SL1, YR2.SALES SL2 FROM YTD "
	cQry += "LEFT JOIN OIH ON YTD.CODE = OIH.CODE "
	cQry += "LEFT JOIN YR1 ON YTD.CODE = YR1.CODE "
	cQry += "LEFT JOIN YR2 ON YTD.CODE = YR2.CODE "
	cQry += "ORDER BY YTD.CODE "
	
	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0 
    	QRY->(dbCloseArea()) 
	EndIf
	
	TCQUERY cQry NEW ALIAS "QRY"
	
	ProcRegua(QRY->(RecCount()))
	
	While QRY->(!EOF())
		IncProc()
		cReportTxt += "BZ;"
		cReportTxt += QRY->CODE + ";"
		cReportTxt += "0;"
		cReportTxt += QRY->CUSTOMER + ";"
		cReportTxt += "HGC;"
		cReportTxt += cValToChar(QRY->SALES) + ";"
		cReportTxt += cValToChar(QRY->OIH) + ";"
		cReportTxt += cValToChar(QRY->SALES+QRY->OIH) + ";"
		cReportTxt += "0;"
		cReportTxt += "0;"
		cReportTxt += cValToChar(QRY->SL1) + ";"
		cReportTxt += cValToChar(QRY->SL2) + CRLF
		QRY->(DbSkip())
	EndDo
	
	CreateCSV()
	
Return

// Cria views para o relatório 'Number of Orders'
Static Function NOReport()
	cQry := "CREATE OR REPLACE VIEW YTD AS "
	cQry +=	"SELECT SA1.A1_COD CODE, SA1.A1_NOME CUSTOMER, NVL(COUNT(SC5.C5_NUM),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC5010 SC5 ON SA1.A1_COD = SC5.C5_CLIENTE " 
	cQry +=	"AND SC5.C5_EMISSAO >= '"+cValToChar(cYear)+"0401' "
	cQry +=	"AND SC5.C5_EMISSAO <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"AND SC5.C5_NOTA != ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
  
	cQry :=	"CREATE OR REPLACE VIEW OIH AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(SC5.C5_NUM),0) OIH "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC5010 SC5 ON SA1.A1_COD = SC5.C5_CLIENTE "
	cQry +=	"AND SC5.C5_EMISSAO >= '"+cValToChar(cYear)+"0401' "
	cQry +=	"AND SC5.C5_EMISSAO <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"AND SC5.C5_NOTA = ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
  
	cQry :=	"CREATE OR REPLACE VIEW YR1 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(SC5.C5_NUM),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC5010 SC5 ON SA1.A1_COD = SC5.C5_CLIENTE "
	cQry +=	"AND SC5.C5_EMISSAO >= '"+cValToChar(cYear1)+"0401' "
	cQry +=	"AND SC5.C5_EMISSAO <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"AND SC5.C5_NOTA != ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR2 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(SC5.C5_NUM),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC5010 SC5 ON SA1.A1_COD = SC5.C5_CLIENTE " 
	cQry +=	"AND SC5.C5_EMISSAO >= '"+cValToChar(cYear2)+"0401' "
	cQry +=	"AND SC5.C5_EMISSAO <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"AND SC5.C5_NOTA != ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Return

// Cria views para o relatório 'Number of Capsules'
Static Function NCReport()
	cQry :=	"CREATE OR REPLACE VIEW YTD AS "
	cQry +=	"SELECT SA1.A1_COD CODE, SA1.A1_NOME CUSTOMER, NVL(SUM(SC6.C6_QTDENT),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW OIH AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_QTDVEN),0) OIH "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT = ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR1 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_QTDENT),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear1)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR2 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_QTDENT),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear2)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Return

// Cria views para o relatório 'Value Euro Currency'
Static Function VCReport()
	cQry :=	"CREATE OR REPLACE VIEW YTD AS "
	cQry +=	"SELECT SA1.A1_COD CODE, SA1.A1_NOME CUSTOMER, NVL(SUM(SC6.C6_VALOR),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW OIH AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_VALOR),0) OIH "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT = ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR1 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_VALOR),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear1)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR2 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(SUM(SC6.C6_VALOR),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear2)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Return

// Cria views para o relatório 'Different Products'
Static Function DPReport()
	cQry :=	"CREATE OR REPLACE VIEW YTD AS "
	cQry +=	"SELECT SA1.A1_COD CODE, SA1.A1_NOME CUSTOMER, NVL(COUNT(DISTINCT SC6.C6_PRODUTO),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW OIH AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(DISTINCT SC6.C6_PRODUTO),0) OIH "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT = ' ' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR1 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(DISTINCT SC6.C6_PRODUTO),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear1)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	cQry :=	"CREATE OR REPLACE VIEW YR2 AS "
	cQry +=	"SELECT SA1.A1_COD CODE, NVL(COUNT(DISTINCT SC6.C6_PRODUTO),0) SALES "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SC6010 SC6 ON SA1.A1_COD = SC6.C6_CLI "
	cQry +=	"AND SC6.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SC6.C6_DATFAT >= '"+cValToChar(cYear2)+"0401' "
	cQry +=	"AND SC6.C6_DATFAT <= '"+cValToChar(cYear+1)+"0331' "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"GROUP BY SA1.A1_COD, SA1.A1_NOME "
	cQry +=	"ORDER BY SA1.A1_COD WITH READ ONLY "
	
	If (TCSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Return

// Busca dados para o relatório "Client Contacts"
Static Function CCReport()
	Private cReportTxt := ""
	
	cQry :=	"SELECT SA1.A1_CONTATO CONTACT, SA1.A1_EMAIL EMAIL, "
	cQry +=	"CASE (TRIM(SA1.A1_DDI) || TRIM(SA1.A1_DDD) || TRIM(SA1.A1_TEL)) WHEN '0' THEN ' ' ELSE (TRIM(SA1.A1_DDI) || TRIM(SA1.A1_DDD) || TRIM(SA1.A1_TEL)) END PHONE1, "
	cQry +=	"CASE SA1.A1_FAX WHEN '0' THEN ' ' ELSE SA1.A1_FAX END FAX, SA1.A1_NOME COMPANY, SA1.A1_END ADDRESS1, SA1.A1_BAIRRO ADDRESS2, "
	cQry +=	"SA1.A1_CEP ZIP, SA1.A1_EST ZONE, SA1.A1_MUN CITY, NVL(YA_DESCR, ' ') COUNTRY "
	cQry +=	"FROM SA1010 SA1 "
	cQry +=	"LEFT JOIN SYA010 SYA ON SYA.YA_CODGI = SA1.A1_PAIS "
	cQry +=	"WHERE SA1.D_E_L_E_T_ = ' ' "
	cQry +=	"AND SA1.A1_MSBLQL != ' ' "
	cQry +=	"ORDER BY SA1.A1_COD "
	
	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0 
    	QRY->(dbCloseArea()) 
	EndIf
	
	TCQUERY cQry NEW ALIAS "QRY"
	
	ProcRegua(QRY->(RecCount()))
	
	While QRY->(!EOF()) .And. Len(cReportTxt) < 1000000
		IncProc()
		cReportTxt += ALLTRIM(QRY->CONTACT) + ";"
		cReportTxt += ALLTRIM(QRY->EMAIL) + ";"
		cReportTxt += ALLTRIM(QRY->PHONE1) + ";"
		cReportTxt += ALLTRIM(QRY->COMPANY) + ";"
		cReportTxt += ALLTRIM(QRY->ADDRESS1) + ";"
		cReportTxt += ALLTRIM(QRY->ADDRESS2) + ";"
		cReportTxt += ALLTRIM(QRY->ZIP) + ";"
		cReportTxt += ALLTRIM(QRY->ZONE) + ";"
		cReportTxt += ALLTRIM(QRY->CITY) + ";"
		cReportTxt += ALLTRIM(QRY->COUNTRY) + CRLF
		QRY->(DbSkip())
	EndDo
	
	CreateCSV()
	
Return
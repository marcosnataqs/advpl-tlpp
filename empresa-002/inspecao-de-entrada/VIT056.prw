#include 'Protheus.ch'

/*/{Protheus.doc} VIT056
Laudo Técnico Analítico para Produtos Acabados (PA)
@author Marcos Natã Santos
@since 06/10/2017
@version 1.0
@return Nil

@type function
/*/
User Function VIT056() // U_VIT056()
	Local wnrel
	Local cString  := "QEK"
	Local titulo   := "LAUDO TÉCNICO ANALÍTICO"
	Local NomeProg := "vit056"+AllTrim(cUserName)
	Local Tamanho := "P"
	Local cDesc1 := "Emissão de laudo técnico analítico para produtos acabados (PA)"
	Local cPerg := "VIT056"
	Private aReturn := {"Zebrado", 1,"Administracao", 2, 2, "", "", 1}
	Private m_pag := 1
	Private nLastKey := 0
	Private cLaudo := ""
	Private cDoc := ""

	// Ajusta perguntas de usuário
	AjustaSX1(cPerg)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,/*cDesc2*/,/*cDesc3*/,.F.,.F.,.F.,Tamanho,/*uParm12*/,.F.)
	SetDefault(aReturn, cString)

	// "Esc" para sair
	If nLastKey = 27
		SET FILTER TO
		Return
	EndIf

	RptStatus({|| Report()}, @titulo)

Return

Static Function Report()
	cLaudo +=  "<html> "
	cLaudo +=  "<head><title>Laudo Técnico</title> "
	cLaudo +=  "    <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'> "
	cLaudo +=  "</head> "
	cLaudo +=  "<body> "
	cLaudo +=  "<table width='700' height='44' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#000000' "
	cLaudo +=  "       style='border-collapse: collapse'> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td width='150' height='44'><center><img src='http://10.1.1.40/laudo0101.png' width='140' height='41'></center></td> "
	cLaudo +=  "        <td width='548' align='center' valign='middle'><font face=arial,verdana size=4> "
	If MV_PAR03 = 1
		cLaudo +=  "            <b>LAUDO TÉCNICO ANALÍTICO</b></font> "
	Else
		cLaudo +=  "            <b>LAUDO TÉCNICO REANÁLISE</b></font> "
	EndIf
	cLaudo +=  "        </td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "    <td colspan='2'> "
	cLaudo +=  "        <table width='698' align='center' cellpadding='0' cellspacing='0'> "
	cLaudo +=  "            <tr> "
	cLaudo +=  "                <td width='175'> &nbsp;</td> "
	cLaudo +=  "                <td colspan='3'> &nbsp;</td> "
	cLaudo +=  "            </tr> "
	cLaudo +=  "            <tr> "
	cLaudo +=  "                <td width='175'><font face=arial,verdana size=2><b>Código: </b> </font></td> "
	cLaudo +=  "                <td colspan='3'><font face=arial,verdana size=2><b>Descrição: </b> </font></td> "
	cLaudo +=  "            </tr> "
	cLaudo +=  "            <tr> "
	cLaudo +=  "                <td width='175'><font face=arial,verdana size=2><b>Dt. Entrada: </b> / / </font></td> "
	cLaudo +=  "                <td width='174'><font face=arial,verdana size=2><b>Lote: </b> </font></td> "
	cLaudo +=  "                <td width='179'><font face=arial,verdana size=2><b>Nº Análise: </b> </font></td> "
	cLaudo +=  "                <td width='170'><font face=arial,verdana size=2><b>Dt. Análise: </b> / / </font></td> "
	cLaudo +=  "            </tr> "
	cLaudo +=  "        </table> "
	cLaudo +=  "        <table width='698' align='center' cellpadding='0' cellspacing='0'> "
	cLaudo +=  "            <tr> "
	cLaudo +=  "                <td width='155'><font face=arial,verdana size=2><b>Qtde.: </b> 0,00 </font></td> "
	cLaudo +=  "                <td width='233'><font face=arial,verdana size=2><b>Fabricação: </b> / / </font></td> "
	cLaudo +=  "                <td width='233'><font face=arial,verdana size=2><b>Validade: </b> / / </font></td> "
	cLaudo +=  "                <td width='232'>&nbsp;</td> "
	cLaudo +=  "            </tr> "
	cLaudo +=  "            <tr> "
	cLaudo +=  "                <td width='233'>&nbsp;</td> "
	cLaudo +=  "                <td width='233'>&nbsp;</td> "
	cLaudo +=  "                <td width='232'>&nbsp;</td> "
	cLaudo +=  "            </tr> "
	cLaudo +=  "        </table> "
	cLaudo +=  "    </td> "
	cLaudo +=  "</table> "
	cLaudo +=  "<table width='700' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#000000' "
	cLaudo +=  "       style='border-collapse: collapse'> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td height='22' width='200' align='center' bgcolor='#E9E9E9'><font face=arial,verdana size=2><b>TESTE</b></font></td> "
	cLaudo +=  "        <td width='325' align='center' bgcolor='#E9E9E9'><font face=arial,verdana size=2><b>ESPECIFICAÇÃO</b></font></td> "
	cLaudo +=  "        <td width='175' align='center' bgcolor='#E9E9E9'><font face=arial,verdana size=2><b>RESULTADO</b></font></td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "</table> "
	cLaudo +=  "<table width='700' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#000000' "
	cLaudo +=  "       style='border-collapse: collapse'> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td height='22' align='center' bgcolor='#E9E9E9'><font face=arial,verdana size=2><b>REFERÊNCIA</b></font></td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td height='18' align='left'> "
	cLaudo +=  "            <table width='690' border='0' align='left' cellpadding='0' cellspacing='0'></table> "
	cLaudo +=  "        </td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td height='22' align='center' bgcolor='#E9E9E9'><font face=arial,verdana size=2><b>AVALIAÇÃO FINAL</b></font></td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td height='80' valign='top'> "
	cLaudo +=  "            <table width='690' cellpadding='0' cellspacing='0'> "
	cLaudo +=  "                <tr valign='middle'> "
	cLaudo +=  "                    <td width='80' height='30'>&nbsp;</td> "
	cLaudo +=  "                    <td width='160'><font face=arial,verdana size=2>(&nbsp; &nbsp; ) Aprovado</font></td> "
	cLaudo +=  "                    <td width='200'><font face=arial,verdana size=2>(&nbsp; &nbsp; ) Aprovado com Restrição</font></td> "
	cLaudo +=  "                    <td width='170'><font face=arial,verdana size=2>(&nbsp; &nbsp; ) Reprovado</font></td> "
	cLaudo +=  "                    <td width='80'>&nbsp;</td> "
	cLaudo +=  "                </tr> "
	cLaudo +=  "            </table> "
	cLaudo +=  "            <font face='arial,verdana' size='1'>OBS.: </font><br> "
	cLaudo +=  "            <font face='arial,verdana' size='2'>Data de Liberação e/ou Rejeição: / / &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; "
	cLaudo +=  "            &nbsp; &nbsp; &nbsp; Hora: </font> "
	cLaudo +=  "        </td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "    <tr valign='middle'> "
	cLaudo +=  "        <td><br> "
	cLaudo +=  "            <table cellpadding='0' cellspacing='0' width='690'> "
	cLaudo +=  "                <tr> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td>________________________________________</td> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td>________________________________________</td> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                </tr> "
	cLaudo +=  "                <tr valign='top'> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td align='center' valign='top'><font face='arial,verdana' size='2'>Analista do Controle de Qualidade</font></td> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td align='center' valign='top'><font face='arial,verdana' size='2'>Responsável do Controle de Qualidade</font></td> "
	cLaudo +=  "                    <td width='30' height='30'>&nbsp;</td> "
	cLaudo +=  "                </tr> "
	cLaudo +=  "                <tr> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td>________________________________________</td> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                </tr> "
	cLaudo +=  "                <tr valign='top'> "
	cLaudo +=  "                    <td width='30'>&nbsp;</td> "
	cLaudo +=  "                    <td align='center' valign='top'><font face='arial,verdana' size='2'>Garantia da Qualidade</font></td> "
	cLaudo +=  "                    <td width='30' height='30'>&nbsp;</td> "
	cLaudo +=  "                </tr> "
	cLaudo +=  "            </table> "
	cLaudo +=  "            <br> "
	cLaudo +=  "        </td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "</table> "
	cLaudo +=  "<table cellpadding='0' cellspacing='0' width='700' border='0' align='center'> "
	cLaudo +=  "    <tr> "
	cLaudo +=  "        <td align='right'> "
	cLaudo +=  "            <font face='arial,verdana' size='1'>Rev.: - / / </font> "
	cLaudo +=  "            <font face='arial,verdana' size='1'><br><br>Impressão: "+DToC(Date())+"  "+Time()+"</font> "
	cLaudo +=  "        </td> "
	cLaudo +=  "    </tr> "
	cLaudo +=  "</table> "
	cLaudo +=  "</body> "
	cLaudo +=  "</html> "

	cDoc := "C:\WINDOWS\TEMP\LAUDOTECNICO_PA.HTML"
	nHdl := fCreate(cDoc)
	fWrite(nHdl,cLaudo,Len(cLaudo))
	fClose(nHdl)
	ExecDoc(cDoc)

	SET DEVICE TO SCREEN
	MS_FLUSH()

Return

Static Function AjustaSX1(cPerg)
	Local aArea := GetArea()
	Local aRegs := {}
	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{"01","Produto?","mv_ch1","C",06,0,0,"G","mv_par01","","","","SB1",""})
	aAdd(aRegs,{"02","Lote?","mv_ch2","C",10,0,0,"G","mv_par02","","","","SB8LOT",""})
	aAdd(aRegs,{"03","Tipo?","mv_ch3","C",09,0,0,"C","mv_par03","Análise","Reanálise","","",""})

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

Static Function ExecDoc(cDoc)
	Local cDrive     := ""
	Local cDir       := ""
	Local cPathFile  := ""
	Local cCompl     := ""
	Local nRet       := 0

	// Retira a ultima barra invertida (se houver)
	cPathFile := cDoc

	SplitPath(cPathFile, @cDrive, @cDir )
	cDir := Alltrim(cDrive) + Alltrim(cDir)

	// Faz a chamada do aplicativo associado
	cRet := ShellExecute("Open", cPathFile,"",cDir, 1)

	If cRet <= 32
		cCompl := ""
		If cRet == 31
			cCompl := " Não existe aplicativo associado a este tipo de arquivo!"
		EndIf
		Aviso( "Atenção !", "Não foi possível abrir o objeto '" + AllTrim(cPathFile) + "'." + cCompl, { "Ok" }, 2 )
	EndIf

Return
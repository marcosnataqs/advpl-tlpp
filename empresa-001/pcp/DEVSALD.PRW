#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | DEVSALD | Autor | Marcos Natã | Data | 07.03.2017	 	   |
//+--------------------------------------------------------------------+
//| Descr. | Relatório de devoluções em estoque.		               |
//+--------------------------------------------------------------------+
//| Uso | PCP, Controladoria					                       |
//+--------------------------------------------------------------------+

User Function DEVSALD()
	Private oFont10 := TFont():New("ARIAL",9,10,.T.,.F.,5,.T.,5,.T.,.F.) //Fonte 10 Normal
	Private oFont16N := TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.F.) ///Fonte 16 Negrito
	Private oFont12N := TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.F.) ///Fonte 12 Negrito
	Private oFont8 := TFont():New("ARIAL",9,8,.T.,.F.,5,.T.,5,.T.,.F.) //Fonte 8 Normal
	Private oFont10N := TFont():New("ARIAL",9,10,,.T.,,,,.T.,.F.) //Fonte 10 Negrito

	Private oPrint
	Private cStartPath
	Private nLin := 0
	Private nPag := 1

	oPrint := FWMsPrinter():New("")
	oPrint:SetPortrait()
	oPrint:Setup()
	ProcReport()
Return

//Régua para processamento
Static Function ProcReport()
	//Query buscando e somando resultados de produto/lote iguais
	cQry := "WITH A AS(SELECT DISTINCT SD1.D1_COD, SD1.D1_XDESC, SB8.B8_LOTECTL, SB8.B8_LOCAL, SB8.B8_SALDO "
	cQry += "FROM SD1010 SD1 "
	cQry += "INNER JOIN SB8010 SB8 "
	cQry += "ON SB8.B8_PRODUTO = SD1.D1_COD AND SB8.B8_LOTECTL = SD1.D1_LOTECTL "
	cQry += "WHERE SD1.D_E_L_E_T_ = ' ' "
	cQry += "AND SD1.D1_TIPO = 'D' "
	cQry += "AND SB8.B8_SALDO > 0 "
	cQry += "ORDER BY SD1.D1_COD, SB8.B8_LOTECTL) "
	cQry += "SELECT A.D1_COD, A.D1_XDESC, A.B8_LOTECTL, A.B8_LOCAL, SUM(A.B8_SALDO) B8_SALDO "
	cQry += "FROM A GROUP BY A.D1_COD, A.D1_XDESC, A.B8_LOTECTL, A.B8_LOCAL "
	cQry += "ORDER BY A.D1_COD, A.B8_LOTECTL "

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	//Não utiliza o "ChangeQry()" devido a clausula "WITH" no SQL
	TCQUERY cQry NEW ALIAS "QRY"

	RptStatus({||RunReport()}, "Consultando dados", "Aguarde...")
Return

//Processamento e validações do relatório
Static Function RunReport()
	SetRegua(QRY->(RECCOUNT()))

	While QRY->(!EOF())
		If nLin >= 3000
			Roda()
			Loop //Pula para próxima página
		ElseIf nLin == 0
			Cabec()
		EndIf

		oPrint:Say(nLin, 150, QRY->D1_COD, oFont10)
		oPrint:Say(nLin, 350, QRY->D1_XDESC, oFont10)
		oPrint:Say(nLin, 1250, QRY->B8_LOTECTL, oFont10)
		oPrint:Say(nLin, 1665, cValToChar(QRY->B8_LOCAL), oFont10)
		oPrint:Say(nLin, 1930, cValToChar(QRY->B8_SALDO), oFont10)
		nLin += 50 //Espaço entre resultados
		IncRegua() //Incrementação da régua de processamento
		QRY->(DbSkip())
		If QRY->(EOF())
			Roda()
		EndIf
	EndDo

	oPrint:Preview()
Return

Static Function Cabec()
	Local nI := 1

	nLin := 50
	oPrint:StartPage() //Inicia uma nova página

	//Buscando endereço da logo no servidor
	cStartPath := GetPvProfString(GetEnvServer(), "StartPath", "ERROR", GetAdv97())
	cStartPath += IIF(Right(cStartPath, 1) <> "\", "\", "")

	oPrint:SayBitmap(90, 60, cStartPath + "logorel.bmp", 270, 90) //Impressão da logo
	oPrint:Say(nLin+10, 2100, "Página " + cValToChar(nPag), oFont10)
	oPrint:Say(nLin+50, 2100, Time(), oFont10)
	oPrint:Say(nLin+85, 2100, DTOC(dDatabase), oFont10)

	nLin += 100
	oPrint:Say(nLin+0, 850, "DEVOLUÇÕES EM ESTOQUE", oFont16N)
	oPrint:Line(nLin+200, 50, nLin+200, 2400)

	//Define onde começará a impressão dos dados no relatório
	nLin := 400

	//Cabeçalho
	oPrint:Say(nLin, 150, "CÓDIGO", oFont12N)
	oPrint:Say(nLin, 350, "DESCRIÇÃO", oFont12N)
	oPrint:Say(nLin, 1250, "LOTE", oFont12N)
	oPrint:Say(nLin, 1600, "ARMAZÉM", oFont12N)
	oPrint:Say(nLin, 1900, "SALDO", oFont12N)

	nLin += 60 //Aumentar o espaço entre o cabeçalho dos campos e os resultados
Return

Static Function Roda()
	nLin := 3150 //Posiciona o início da impressão na linha apontada

	oPrint:Line(nLin, 50, nLin, 2400)
	nLin += 20
	oPrint:Say(nLin, 150, "Emitido por: " + UsrFullName(__cUserId), oFont8)
	oPrint:Say(nLin, 1950, DTOC(dDatabase) + " / " + Time(), oFont8)
	nLin += 50
	oPrint:Line(nLin, 50, nLin, 2400)

	nLin := 0
	nPag++

	oPrint:EndPage() //Fim página
Return
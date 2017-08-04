#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "AP5MAIL.CH"

/*/{Protheus.doc} EMLEST98

Email enviado com dados de estornos para o armazém 98.

@author Marcos Natã Santos
@since 02/05/2017
@version undefined

@type function
/*/

User Function EMLEST98()

	Local oServer := Nil
	Local oMessage := Nil
	Local nErr := 0
	Local cPopAddr  := "pop.genix.ind.br"      // Endereco do servidor POP3
	Local cSMTPAddr := "smtp.genix.ind.br"     // Endereco do servidor SMTP
	Local cPOPPort  := 110                    // Porta do servidor POP
	Local cSMTPPort := 587                    // Porta do servidor SMTP
	Local cUser     := "protheus@genix.ind.br"     // Usuario que ira realizar a autenticacao
	Local cPass     := "senha@prot"             // Senha do usuario
	Local nSMTPTime := 60                     // Timeout SMTP
	Local cQL       := Chr(13)+Chr(10)
	Local cRemoteip :=  Getclientip()
	Local cRemoteComputer :=  GetComputerName()

	Local cCod := SH6->H6_PRODUTO
	Local cDesc := SH6->H6_XDESC
	Local cLote := SH6->H6_LOTECTL
	Local cOp := SH6->H6_OP
	Local dDtFab := Posicione("SZ1", 3, xFilial("SZ1") + SH6->H6_OP, "Z1_DTFAB")
	Local dDtVal := Posicione("SZ1", 3, xFilial("SZ1") + SH6->H6_OP, "Z1_DTVALID")
	Local nQtdProd := SH6->H6_QTDPROD
	Local cMotivo := SH6->H6_XMTVEST

	// Query que realiza a contagem de caixas produzidas pela ordem de produção
	cQry := "SELECT COUNT(Z1_VOLUME) VOLUMES FROM SZ1010 "
	cQry += "WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND Z1_ORDPROD = '"+M->H6_OP+"' "

	cQry:= ChangeQuery(cQry)
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	// Instancia um novo TMailManager
	oServer := tMailManager():New()

	// Usa SSL na conexao
	oServer:setUseSSL(.F.)

	// Inicializa
	oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, cPOPPort, cSMTPPort)

	// Define o Timeout SMTP
	If oServer:SetSMTPTimeout(nSMTPTime) != 0
		conout("[ERROR]Falha ao definir timeout")
		Return .F.
	EndIf

	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0
		conOut("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
		oServer:smtpDisconnect()
		Return .F.
	EndIf

	// Realiza autenticacao no servidor
	nErr := oServer:smtpAuth(cUser, cPass)
	If nErr <> 0
		conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
		oServer:smtpDisconnect()
		Return .F.
	EndIf

	// Cria uma nova mensagem (TMailMessage)
	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom    := "protheus@genix.ind.br"
	oMessage:cTo      := getMV('MV_EMLEST9')
	oMessage:cCC      := ""
	oMessage:cBCC     := "logs@genix.ind.br"
	oMessage:cSubject := "..::Notificação Automática - Protheus - Estorno de Apontamento para Qualidade::.."

	// cBody com o corpo do e-mail
	cBody :=	'<html>'
	cBody +=	'<head>'
	cBody +=	'<meta http-equiv="Content-Type" content="text/html charset=ISO-8859-1">'
	cBody +=	'</head>'
	cBody +=	'<body>'
	cBody +=	'<div marginheight="0" marginwidth="0">'
	cBody +=	'<table border="0" cellpadding="0" cellspacing="0">'
	cBody +=	'<tbody>'
	cBody +=	'<tr><td><font face="arial" size="2"><center><b><u>NOTIFICAÇÃO AUTOMÁTICA</u></b><br><br><br></center></font></td></tr>'
	cBody +=	'<tr><td><font face="arial" size="2">Prezado Colaborador.<br><br>'
	cBody +=	'Este e-mail tem o intuito de avisá-lo que um apontamento para Qualidade foi estornado.<br><br><br>'
	cBody +=	'<b>INFORMAÇÕES:</b><br><br>'
	cBody +=	'<b>Produto: </b>' + cCod + '<br><br>'
	cBody +=	'<b>Descrição: </b>' + cDesc + '<br><br>'
	cBody +=	'<b>Lote: </b>' + cLote + '<br><br>'
	cBody +=	'<b>O.P.: </b>' + cOp + '<br><br>'
	cBody +=	'<b>Data Fabricação: </b>' + DTOC(dDtFab) + '<br><br>'
	cBody +=	'<b>Data Validade: </b>' + DTOC(dDtVal) + '<br><br>'
	cBody +=	'<b>Data Estorno: </b>' + DTOC(dDataBase) + '<br><br>'
	cBody +=	'<b>Hora Estorno: </b>' + Time() + '<br><br>'
	cBody +=	'<b>Quantidade: </b>' + cValToChar(nQtdProd) + '<br><br>'
	cBody +=	'<b>Volumes: </b>' + cValToChar(QRY->VOLUMES) + '<br><br>'
	cBody +=	'<b>Motivo Estorno: </b>' + cMotivo + '<br><br></font>'
	cBody += 	'<tr><td><hr></td></tr>'
	cBody +=   	'<tr><td><font face = "arial" size="2" color="#D3D3D3">Estornado por: </font>' + cUsername + '</td></tr><br>'
	cBody +=   	'<tr><td><font face = "arial" size="2" color="#D3D3D3">Enviado do Computador: </font>' + cRemoteComputer + '</td></tr><br>'
	cBody +=   	'<tr><td><font face = "arial" size="2" color="#D3D3D3">Com endereço IP: </font>' + cRemoteip + '</td></tr><br>'
	cBody +=   	'<tr><td><font face = "arial" size="2" color="#D3D3D3">Enviado Dia: </font>'  + DtoC(dDataBase) + ' as ' + Time() + '  horas. </td></tr><br>'
	cBody +=   	'<tr><td><hr></td></tr>'
	cBody +=	'<tr><td><font face="arial" size="2"><center>***Este é um e-mail automático, favor não responder.***</center></font></td></tr>'
	cBody +=	'</table><br>'
	cBody +=	'<hr />'
	cBody +=	'<br>'
	cBody +=	'<td><img src="http://200.233.202.193/meioambiente.png"><font color = "green">   Antes de imprimir pense em seu compromisso com o Meio Ambiente.</font></td>'
	cBody +=	'</body>'
	cBody +=	'</html>'
	oMessage:cBody := cBody

	// Envia a mensagem
	nErr := oMessage:send(oServer)
	If nErr <> 0
		conout("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
		oServer:smtpDisconnect()
		Return .F.
	EndIf

	// Disconecta do Servidor
	oServer:smtpDisconnect()

Return .T.
#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "AP5MAIL.CH"

/*/{Protheus.doc} EMLPRMIN

Email para liberação de pedido por preço minímo.

@author Marcos Natã Santos
@since 01/06/2017
@version undefined

@type function
/*/

User Function EMLPRMIN()

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

	Local cPedido := SC9->C9_PEDIDO
	Local cProduto := SC9->C9_PRODUTO + " - " + Posicione("SB1", 1, xFilial("SB1") + SC9->C9_PRODUTO, "B1_DESC")
	Local nPrecoVen := SC9->C9_PRCVEN
	Local cCliente := SC9->C9_CLIENTE + " - " + Posicione("SA1", 1, xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA, "A1_NOME")
	Local nQtdLib := SC9->C9_QTDLIB

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
	oMessage:cTo      := "pvalente@genix.ind.br"//getMV('MV_EMLPRMN')
	oMessage:cCC      := ""
	oMessage:cBCC     := "logs@genix.ind.br"
	oMessage:cSubject := "..::Workflow - Solicitação de Liberação de Preço::.."

	// Corpo da mensagem
	cBody := '<html>'
	cBody += '<head>'
	cBody += '<meta http-equiv="Content-Type" content="text/html charset=ISO-8859-1">'
	cBody += '</head>'
	cBody += '<body>'
	cBody += '<center><b>LIBERAÇÃO DE PEDIDO</b></center><br><br><br>'
	cBody += 'Prezado Presidente.<br><br>'
	cBody += 'O pedido abaixo encontra-se bloqueado por preço mínimo aguardando liberação.<br><br><br>'
	cBody += '<b>INFORMAÇÕES:</b><br><br>'
	cBody += '<b>Pedido: </b>' + cPedido + '<br><br>'
	cBody += '<b>Produto: </b>' + cProduto + '<br><br>'
	cBody += '<b>Cliente: </b>' + cCliente + '<br><br>'
	cBody += '<b>Preço Venda: </b>R$ ' + cValToChar(nPrecoVen) + '<br><br>'
	cBody += '<b>Quantidade: </b>' + cValToChar(nQtdLib) + '<br><br>'
	cBody += '<b>Preço Mínimo: </b>R$ ' + cValToChar(_valor) + '<br><br><br><br>'
	cBody += '<center>***E-mail automático, favor não responder.***</center>'
	cBody += '</body>'
	cBody += '</html>'

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
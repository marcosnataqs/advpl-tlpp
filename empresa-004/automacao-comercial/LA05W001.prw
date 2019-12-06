#Include "TOTVS.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} LA05W001

Workflow Status do Pedido de Venda

@author Marcos Natã Santos
@since 25/06/2018
@version 12.1.17
@type function
/*/
User Function LA05W001(cPed,cCodCli,cLoja,cTipo,cStatus,aWFCorte,aPosicao,cLog)
  Local oServer
  Local oMessage
  Local xRet

  Local cSendSrv := StrTran( GETMV('MV_RELSERV'), ":587")
  Local cUser    := GETMV('MV_RELACNT')
  Local cPass    := GETMV('MV_RELAPSW')
  Local nPort    := 587
  Local cFrom    := GETMV('MV_RELACNT')
  Local cTo      := ""
  Local cCc      := ""
  Local cBcc     := ""
  Local cSubject := ""
  Local cBody    := ""
  Local aStat    := {}

  Local cVend     := ""
  Local cVendMail := ""
  Local cTime     := ""
  Local cData     := ""

  Default cPed     := ""
  Default cCodCli  := ""
  Default cLoja    := ""
  Default cTipo    := ""
  Default cStatus  := ""
  Default aWFCorte := {}
  Default aPosicao := {}
  Default cLog     := ""

  Private cMailsAdd := ""

  cVend := Posicione("SA1",1,xFilial("SA1") + cCodCli + cLoja, "A1_VEND")
  cVendMail := AllTrim(Posicione("SA3",1,xFilial("SA3") + cVend, "A3_EMAIL"))
   
  //Cria a conexão com o server STMP ( Envio de e-mail )
  oServer := TMailManager():New()
  oServer:Init( "", cSendSrv, cUser, cPass, , nPort )
  
  //Seta um tempo de time out com servidor de 1min
  xRet  := oServer:SetSmtpTimeOut( 60 )
  cData := DTOC(Date())
  cTime := Time()
  If xRet != 0
    Conout( cData + " " + cTime + " LA05W001: Falha ao setar o time out -> " + oServer:GetErrorString( xRet ) )
    Return .F.
  Else
    Conout( cData + " " + cTime + " LA05W001: Setou o time out" )
  EndIf
   
  //Realiza a conexão SMTP
  xRet  := oServer:SmtpConnect()
  cData := DTOC(Date())
  cTime := Time()
  If xRet != 0
    Conout( cData + " " + cTime + " LA05W001: Falha ao conectar -> " + oServer:GetErrorString( xRet ) )
    Return .F.
  Else
    Conout( cData + " " + cTime + " LA05W001: Conectou com Sucesso" )
  EndIf

  // Autenticação no servidor SMTP
  xRet  := oServer:SmtpAuth( cUser, cPass )
  cData := DTOC(Date())
  cTime := Time()
  If xRet != 0
    Conout( cData + " " + cTime + " LA05W001: No conseguiu autenticar no servidor SMTP -> " + oServer:GetErrorString( xRet ) )
    Return .F.
  Else
    Conout( cData + " " + cTime + " LA05W001: Autentio realizada com Sucesso" )
  EndIf
   
  //Apos a conexão, cria o objeto da mensagem
  oMessage := TMailMessage():New()
   
  //Limpa o objeto
  oMessage:Clear()

  If Len(aPosicao) > 0
    aStat := GetPosic(cPed,cCodCli,cLoja,aPosicao)
  Else
    aStat := GetStatus(cPed,cCodCli,cLoja,cTipo,cStatus,aWFCorte,cLog)
  EndIf
  cSubject := aStat[1]
  cBody    := aStat[2]
  cTo      += IIF( !Empty(cVendMail), cVendMail + ";", "" )
  cTo      += "customer@lineaalimentos.com.br;"
  cTo      += IIF( !Empty(cMailsAdd), cMailsAdd, "" )
   
  //Popula com os dados de envio
  oMessage:cFrom              := cFrom
  oMessage:cTo                := cTo
  oMessage:cCc                := cCc
  oMessage:cBcc               := cBcc
  oMessage:cSubject           := cSubject
  oMessage:cBody              := cBody

  //Envia o e-mail
  xRet  := oMessage:Send( oServer )
  cData := DTOC(Date())
  cTime := Time()
  If xRet != 0
    Conout( cData + " " + cTime + " LA05W001: Erro ao enviar o e-mail -> " + oServer:GetErrorString( xRet ) )
    Return .F.
  Else
    Conout( cData + " " + cTime + " LA05W001: E-mail enviado com sucesso" )
  EndIf

  //Desconecta do servidor
  xRet  := oServer:SmtpDisconnect()
  cData := DTOC(Date())
  cTime := Time()
  If xRet != 0
    Conout( cData + " " + cTime + " LA05W001: Erro ao disconectar do servidor SMTP -> " + oServer:GetErrorString( xRet ) )
    Return .F.
  Else
    Conout( cData + " " + cTime + " LA05W001: Disconectou do servidor SMTP" )
  EndIf

Return .T.

/*/{Protheus.doc} GetStatus

Obtém status do Pedido de Venda
Cria mensagem HTML

@author Marcos Natã Santos
@since 25/06/2018
@version 12.1.17
@type function
/*/
Static Function GetStatus(cPed,cCodCli,cLoja,cTipo,cStatus,aWFCorte,cLog)
  Local cMessage  := ""
  Local aRet      := {}
  Local aAreaSZO  := SZO->(GetArea())
  Local aAreaSA1  := SA1->(GetArea())
  Local nI        := 0
  Local cCli      := ""
  Local cPedCli   := ""
  Local nTotalQtd := 0
  Local nTotalVal := 0

  SZO->( dbSetOrder(2) )
  SZO->( dbSeek(xFilial("SZO") + cPed + cCodCli + cLoja + cTipo + cStatus) )

  cCli := AllTrim(SZO->ZO_CLIENTE) + "/" + AllTrim(SZO->ZO_LOJA) + " - "
  cCli += AllTrim(Posicione("SA1", 1, xFilial("SA1") + SZO->ZO_CLIENTE + SZO->ZO_LOJA, "A1_NREDUZ")) + " - "
  cCli += AllTrim(Posicione("SA1", 1, xFilial("SA1") + SZO->ZO_CLIENTE + SZO->ZO_LOJA, "A1_EST"))

  cPedCli := AllTrim(Posicione("SZL", 1, xFilial("SZL") + SZO->ZO_NUM + SZO->ZO_CLIENTE + SZO->ZO_LOJA, "ZL_PEDCLI"))

  If cTipo == "2"
    PswOrder(1) // 1 - ID do usuário/grupo
    If PswSeek( SZO->ZO_CODUSER, .T. )
      cMailsAdd += AllTrim(PswRet()[1][14]) + ";" // Retorna e-mail do usuário
    EndIf
  EndIf

  If Len(aWFCorte) > 0

    // SA1->( dbSetOrder(1) )
    // If SA1->( dbSeek(xFilial("SA1") + cCodCli + cLoja) )
    //   cMailsAdd += AllTrim(SA1->A1_EMAIL)
    // EndIf

    cMessage := "<!DOCTYPE html> " + CRLF
    cMessage += "<html lang='en'> " + CRLF
    cMessage += "<head> " + CRLF
    cMessage += "  <title>Workflow Linea</title> " + CRLF
    cMessage += "  <meta charset='utf-8'> " + CRLF
    cMessage += "  <meta name='viewport' content='width=device-width, initial-scale=1'> " + CRLF
    cMessage += "  <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css'> " + CRLF
    cMessage += "  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script> " + CRLF
    cMessage += "  <script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js'></script> " + CRLF
    cMessage += "  <script src='https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js'></script> " + CRLF
    cMessage += "  <style> " + CRLF
    cMessage += "    table, th, td { " + CRLF
    cMessage += "        border: 1px solid black; " + CRLF
    cMessage += "        border-collapse: collapse; " + CRLF
    cMessage += "    } " + CRLF
    cMessage += "  </style> " + CRLF
    cMessage += "</head> " + CRLF
    cMessage += "<body> " + CRLF
    cMessage += "<div class='container'> " + CRLF
    cMessage += "  <div class='jumbotron'> " + CRLF
    cMessage += "    <h2>"+ AllTrim(SZO->ZO_OBS) +"</h2> " + CRLF
    cMessage += "  </div> " + CRLF
    cMessage += "  <p><b>Número Pedido:</b> "+ AllTrim(SZO->ZO_NUM) +"</p> " + CRLF
    cMessage += "  <p><b>Número Pedido Cliente:</b> "+ IIF(Empty(cPedCli), "S/N", cPedCli) +"</p> " + CRLF
    cMessage += "  <p><b>Cliente:</b> "+ cCli +"</p> " + CRLF
    cMessage += "  <p><b>Data/Hora:</b> "+ DTOC(SZO->ZO_DATA) + "  " + AllTrim(SZO->ZO_HORA) +"</p> " + CRLF
    cMessage += "  <p><b>Responsável:</b> "+ AllTrim(SZO->ZO_USRNAME) +"</p> " + CRLF
    cMessage += "  <table> " + CRLF
    cMessage += "    <thead> " + CRLF
    cMessage += "      <tr> " + CRLF
    cMessage += "        <th>Produto</th> " + CRLF
    cMessage += "        <th>Descrição</th> " + CRLF
    cMessage += "        <th>Qtd. Corte</th> " + CRLF
    cMessage += "        <th>Vlr. Uni.</th> " + CRLF
    cMessage += "        <th>Vlr. Total</th> " + CRLF
    cMessage += "        <th>Motivo</th> " + CRLF
    cMessage += "      </tr> " + CRLF
    cMessage += "    </thead> " + CRLF
    cMessage += "    <tbody> " + CRLF

    For nI := 1 To Len(aWFCorte)
      cMessage += "      <tr> " + CRLF
      cMessage += "        <td>"+ AllTrim(aWFCorte[nI][1]) +"</td> " + CRLF
      cMessage += "        <td>"+ AllTrim(aWFCorte[nI][2]) +"</td> " + CRLF
      cMessage += "        <td>"+ TRANSFORM(aWFCorte[nI][3], "@ 999,999,999") +"</td> " + CRLF
      cMessage += "        <td>"+ TRANSFORM(aWFCorte[nI][4], PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
      cMessage += "        <td>"+ TRANSFORM(aWFCorte[nI][5], PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
      cMessage += "        <td>"+ AllTrim(POSICIONE("SX5", 1, xFilial("SX5")+"Z9"+aWFCorte[nI][6], "X5_DESCRI")) +"</td> " + CRLF
      cMessage += "      </tr> " + CRLF
    Next nI

    //-- Calcula totalizadores
    For nI := 1 To Len(aWFCorte)
      nTotalQtd += aWFCorte[nI][3] //-- Qtd. Corte
      nTotalVal += aWFCorte[nI][5] //-- Valor Corte
    Next nI

    //-- Totalizador
    cMessage += "      <tr> " + CRLF
    cMessage += "        <td></td> " + CRLF
    cMessage += "        <td>Total Qtd.:</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalQtd, "@ 999,999,999") +"</td> " + CRLF
    cMessage += "        <td>Total Valor:</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalVal, PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
    cMessage += "      </tr> " + CRLF

    cMessage += "    </tbody> " + CRLF
    cMessage += "  </table> " + CRLF
    cMessage += "</div> " + CRLF
    cMessage += "</body> " + CRLF
    cMessage += "</html> " + CRLF
  Else
    cMessage := "<!DOCTYPE html> " + CRLF
    cMessage += "<html lang='en'> " + CRLF
    cMessage += "<head> " + CRLF
    cMessage += "<meta charset='utf-8'> " + CRLF
    cMessage += "<meta name='viewport' content='width=device-width, initial-scale=1'> " + CRLF
    cMessage += "<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'> " + CRLF
    cMessage += "<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script> " + CRLF
    cMessage += "<script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js'></script> " + CRLF
    cMessage += "</head> " + CRLF
    cMessage += "<body> " + CRLF
    cMessage += "<div class='container'> " + CRLF
    cMessage += "<div class='jumbotron'> " + CRLF
    cMessage += "    <h2>"+ AllTrim(SZO->ZO_OBS) +"</h2> " + CRLF
    cMessage += "</div> " + CRLF
    cMessage += "<p><b>Número Pedido:</b> "+ AllTrim(SZO->ZO_NUM) +"</p> " + CRLF
		cMessage += "<p><b>Número Pedido Cliente:</b> "+ IIF(Empty(cPedCli), "S/N", cPedCli) +"</p> " + CRLF
    cMessage += "<p><b>Cliente:</b> "+ cCli +"</p> " + CRLF
    cMessage += "<p><b>Data/Hora:</b> "+ DTOC(SZO->ZO_DATA) + "  " + AllTrim(SZO->ZO_HORA) +"</p> " + CRLF
    cMessage += "<p><b>Responsável:</b> "+ AllTrim(SZO->ZO_USRNAME) +"</p><br/> " + CRLF

    If !Empty(cLog)
      cMessage += "<p><b>Log:</b></p> " + CRLF
      cMessage += "<p>"+ cLog +"</p> " + CRLF
    EndIf
    
    cMessage += "</div> " + CRLF
    cMessage += "</body> " + CRLF
    cMessage += "</html> " + CRLF
  EndIf

  MEMOWRITE("C:\Users\Marcos\Desktop\querys\LA05W001.html", cMessage)

  AADD(aRet, "Pedido " + AllTrim(SZO->ZO_NUM) + " -> " + AllTrim(SZO->ZO_OBS))
  AADD(aRet, cMessage)

  RestArea(aAreaSZO)
	RestArea(aAreaSA1)

Return aRet

/*/{Protheus.doc} GetPosic

Monta workflow de Posição do Pedido

@author   Marcos Natã Santos
@since    31/05/2019
@version  12.1.17
@type     function
/*/
Static Function GetPosic(cPed,cCodCli,cLoja,aPosicao)
	Local cMessage  := ""
	Local cCli      := ""
	Local cPedCli   := ""
	Local nI        := 0
	Local aRet      := {}

	Local nTotalQtd  := 0
  Local nTotalLib  := 0
  Local nTotalCort := 0
  Local nTotalPend := 0

	cCli := AllTrim(cCodCli) + "/" + AllTrim(cLoja) + " - "
	cCli += AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_NREDUZ")) + " - "
	cCli += AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_EST"))

	cPedCli := AllTrim(Posicione("SZL", 1, xFilial("SZL") + cPed + cCodCli + cLoja, "ZL_PEDCLI"))

	If Len(aPosicao) > 0
		cMessage := "<!DOCTYPE html> " + CRLF
		cMessage += "<html lang='en'>" + CRLF
		cMessage += "<head>" + CRLF
		cMessage += "	<title>Posição do Pedido</title>" + CRLF
		cMessage += "	<meta charset='utf-8'>" + CRLF
		cMessage += "	<meta name='viewport' content='width=device-width, initial-scale=1'>" + CRLF
		cMessage += "	<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css'>" + CRLF
		cMessage += "	<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script>" + CRLF
		cMessage += "	<script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js'></script>" + CRLF
		cMessage += "	<script src='https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js'></script>" + CRLF
		cMessage += "	<style>" + CRLF
		cMessage += "		table, th, td {" + CRLF
		cMessage += "				border: 1px solid black;" + CRLF
		cMessage += "				border-collapse: collapse;" + CRLF
		cMessage += "		}" + CRLF
		cMessage += "	</style>" + CRLF
		cMessage += "</head>" + CRLF
		cMessage += "<body>" + CRLF
		cMessage += "<div class='container'>" + CRLF
		cMessage += "	<div class='jumbotron'>" + CRLF
		cMessage += "		<h2>POSIÇÃO DO PEDIDO</h2>" + CRLF
		cMessage += "	</div>" + CRLF
		cMessage += "	<p><b>Número Pedido:</b> "+ cPed +"</p>" + CRLF
		cMessage += "	<p><b>Número Pedido Cliente:</b> "+ IIF(Empty(cPedCli), "S/N", cPedCli) +"</p>" + CRLF
		cMessage += "	<p><b>Cliente:</b> "+ cCli +"</p>" + CRLF
		cMessage += "	<table>" + CRLF
		cMessage += "		<thead>" + CRLF
		cMessage += "			<tr>" + CRLF
    cMessage += "				<th>Item</th>" + CRLF
    cMessage += "				<th>Produto</th>" + CRLF
    cMessage += "				<th>Descrição</th>" + CRLF
    cMessage += "				<th>Vlr. Uni.</th>" + CRLF
    cMessage += "				<th>Quantidade</th>" + CRLF
    cMessage += "				<th>Liberado</th>" + CRLF
    cMessage += "				<th>Corte</th>" + CRLF
    cMessage += "				<th>Pendente</th>" + CRLF
		cMessage += "			</tr>" + CRLF
		cMessage += "		</thead>" + CRLF
		cMessage += "		<tbody>" + CRLF

		For nI := 1 To Len(aPosicao)
			cMessage += "			<tr>" + CRLF
			cMessage += "				<td>"+ AllTrim(aPosicao[nI][1]) +"</td>" + CRLF
			cMessage += "				<td>"+ AllTrim(aPosicao[nI][2]) +"</td>" + CRLF
			cMessage += "				<td>"+ AllTrim(aPosicao[nI][3]) +"</td>" + CRLF
			cMessage += "				<td>"+ TRANSFORM(aPosicao[nI][4], PesqPict("SZM","ZM_VALOR")) +"</td>" + CRLF
			cMessage += "				<td>"+ TRANSFORM(aPosicao[nI][5], "@ 999,999,999") +"</td>" + CRLF
			cMessage += "				<td>"+ TRANSFORM(aPosicao[nI][6], "@ 999,999,999") +"</td>" + CRLF
			cMessage += "				<td>"+ TRANSFORM(aPosicao[nI][7], "@ 999,999,999") +"</td>" + CRLF
			cMessage += "				<td>"+ TRANSFORM(aPosicao[nI][8], "@ 999,999,999") +"</td>" + CRLF
			cMessage += "			</tr>" + CRLF
		Next nI

		//-- Calcula totalizadores
    For nI := 1 To Len(aPosicao)
      nTotalQtd  += (aPosicao[nI][5] * aPosicao[nI][4])
      nTotalLib  += (aPosicao[nI][6] * aPosicao[nI][4])
      nTotalCort += (aPosicao[nI][7] * aPosicao[nI][4])
      nTotalPend += (aPosicao[nI][8] * aPosicao[nI][4])
    Next nI

		//-- Totalizador
    cMessage += "      <tr> " + CRLF
    cMessage += "        <td></td> " + CRLF
    cMessage += "        <td></td> " + CRLF
    cMessage += "        <td></td> " + CRLF
    cMessage += "        <td>Totais (R$):</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalQtd, PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalLib, PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalCort, PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
    cMessage += "        <td>"+ TRANSFORM(nTotalPend, PesqPict("SZM","ZM_TOTAL")) +"</td> " + CRLF
    cMessage += "      </tr> " + CRLF

		cMessage += "		</tbody>" + CRLF
		cMessage += "	</table>" + CRLF
		cMessage += "</div>" + CRLF
		cMessage += "</body>" + CRLF
		cMessage += "</html>" + CRLF

		AADD(aRet, "Pedido " + AllTrim(cPed) + " -> Posição")
  	AADD(aRet, cMessage)

    MemoWrite("C:\Users\marcos.santos\Desktop\querys\getposic.html", cMessage)
	Else
		AADD(aRet, "")
  	AADD(aRet, "")
	EndIf

Return aRet
#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QIEAR215  º Autor ³ Microsiga         º Data ³  19/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Laudo de inspeção de processos		                	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterado por Clistenis Batista em 30/12/2106 para novo modelo solicita-º±±
±±ºpor Qualicaps.                                                         º±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PergLaudo()
	//Private cPerg 		:= "QIPAR215"
	//AjustaSx1()
	//pergunte(cPerg,.T.) //Chama a tela de parametros
	//private NOTA:=MV_PAR02
	private FILIAL := "0101"
	private NOTA := SC5->C5_NOTA
	//Private SERIE :=MV_PAR03
	Private SERIE := SC5->C5_SERIE
	Private _cCliente := Posicione("SF2",1,xFilial("SF2")+NOTA+SERIE,"F2_CLIENTE")
	Private _cLoja := Posicione("SF2",1,xFilial("SF2")+NOTA+SERIE,"F2_LOJA")
	U_VALLAUDO(NOTA)

Return

User Function QIPAR215(cOrigem)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis de Tipos de fontes que podem ser utilizadas no relatório   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private oFont6		:= TFONT():New("ARIAL",7,6,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 6 Normal
	Private oFont6N 	:= TFONT():New("ARIAL",7,6,,.T.,,,,.T.,.F.) ///Fonte 6 Negrito
	Private oFont7		:= TFONT():New("ARIAL",8,7,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 7 Normal
	Private oFont8		:= TFONT():New("ARIAL",9,8,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 8 Normal
	Private oFont8N 	:= TFONT():New("ARIAL",8,8,,.T.,,,,.T.,.F.) ///Fonte 8 Negrito
	Private oFont10 	:= TFONT():New("ARIAL",8,8,,.T.,,,,.T.,.F.) ///Fonte 8 Negrito
	Private oFont10 	:= TFONT():New("ARIAL",9,10,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 10 Normal
	Private oFont10S	:= TFONT():New("ARIAL",9,10,.T.,.F.,5,.T.,5,.T.,.T.) ///Fonte 10 Sublinhando
	Private oFont10N 	:= TFONT():New("ARIAL",9,10,,.T.,,,,.T.,.F.) ///Fonte 10 Negrito
	Private oFont12		:= TFONT():New("ARIAL",12,12,,.F.,,,,.T.,.F.) ///Fonte 12 Normal
	Private oFont12NS	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.T.) ///Fonte 12 Negrito e Sublinhado
	Private oFont12N	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.F.) ///Fonte 12 Negrito
	Private oFont14		:= TFONT():New("ARIAL",14,14,,.F.,,,,.T.,.F.) ///Fonte 14 Normal
	Private oFont14NS	:= TFONT():New("ARIAL",14,14,,.T.,,,,.T.,.T.) ///Fonte 14 Negrito e Sublinhado
	Private oFont14N	:= TFONT():New("ARIAL",14,14,,.T.,,,,.T.,.F.) ///Fonte 14 Negrito
	Private oFont16 	:= TFONT():New("ARIAL",16,16,,.F.,,,,.T.,.F.) ///Fonte 16 Normal
	Private oFont16N	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.F.) ///Fonte 16 Negrito
	Private oFont16NS	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.T.) ///Fonte 16 Negrito e Sublinhado
	Private oFont20N	:= TFONT():New("ARIAL",20,20,,.T.,,,,.T.,.F.) ///Fonte 20 Negrito
	Private oFont22N	:= TFONT():New("ARIAL",22,22,,.T.,,,,.T.,.F.) ///Fonte 22 Negrito

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variveis para impressão                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cStartPath
	Private nLin 		:= 50
	Private oPrint		:= TMSPRINTER():New("")
	Private cPerg 		:= "QIPAR215"
	Private oBrush1 	:= TBrush():New( , CLR_GRAY )
	Private oBrush2 	:= TBrush():New( , RGB(255,0,0)) //Calcular RGB em http://www.webcalc.com.br/utilitarios/rgb_hex.html
	Private SeqLab:= "01"
	Private _cOrigem:=cOrigem
	Private nPag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define Tamanho do Papel                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	#define DMPAPER_A4 9 //Papel A4
	oPrint:setPaperSize( DMPAPER_A4 )

	//TMSPrinter(): SetPaperSize ()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Orientacao do papel (Retrato ou Paisagem)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oPrint:SetPortrait()///Define a orientacao da impressao como retrato
	//oPrint:SetLandscape() ///Define a orientacao da impressao como paisagem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria as perguntas na SX1                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if _cOrigem<>"QIP" //Se Modulo for diferente de QIP
		DbselectArea("SF2")
		SF2->(DbSetOrder(1))
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))

		DbSelectArea("QPK")
		QPK->(DbSetOrder(4))
		if SF2->(DbSeek(FILIAL+NOTA+SERIE))
			if SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))

				While SD2->(!EoF()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE ==	xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE

					if QPK->(DbSeek(xFilial("QPK")+SD2->D2_COD+SD2->D2_LOTECTL))

						IF QPK->QPK_LAUDO <> ' ' .and. QPK->QPK_SITOP > '1'

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Monta Query com os dados que serão impressos no relatório            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

							cQry:=""
							cQry:="	SELECT QPR_OP OP, QPR_PRODUT PRODUT,  "
							cQry+="	QPR_LOTE LOTE, QPR_LABOR LABOR, QPR_ENSAIO ENSAIO, QPR_RESULT RESULT, "
							cQry+="	QP8_TEXTO TEXTO, '' LIE, '' LSE, QPQ_MEDICA MEDICA, '' UNIMED"
							cQry+="	FROM "+RetSqlName("QPR")+" QPR, "+RetSqlName("QP8")+" QP8, "+RetSqlName("QPQ")+" QPQ "
							cQry+="	WHERE QPR_FILIAL		=	'"+QPK->QPK_FILIAL+"' "
							cQry+="	AND QPR_OP				=	'"+QPK->QPK_OP+"' "
							cQry+="	AND QPR_PRODUT			=	'"+QPK->QPK_PRODUT+"' "
							cQry+="	AND QPR_LOTE			= 	'"+QPK->QPK_LOTE+"' "
							cQry+="	AND QPR_REVI			= 	'"+QPK->QPK_REVI+"' "
							cQry+="	AND QPR_PRODUT			=	QP8_PRODUT
							cQry+="	AND QPR_LABOR			=   QP8_LABOR
							cQry+="	AND QPR_ENSAIO			=	QP8_ENSAIO
							cQry+="	AND QPR_REVI			=	QP8_REVI
							CQRY+=" AND QPR_FILIAL			=	QPQ_FILIAL
							CQRY+=" AND QPR_CHAVE			=	QPQ_CODMED
							cQry+="	AND QPR.D_E_L_E_T_ 	!= 	'*' "
							cQry+="	AND QP8.D_E_L_E_T_ 	!= 	'*' "
							cQry+="	AND QPQ.D_E_L_E_T_ 	!= 	'*' "

							cQry+=" UNION ALL "

							cQry+="	SELECT QPR_OP OP, QPR_PRODUT PRODUT,  "
							cQry+="	QPR_LOTE LOTE, QPR_LABOR LABOR, QPR_ENSAIO ENSAIO, QPR_RESULT RESULT, "
							cQry+="	'' TEXTO, QP7_LIE LIE, QP7_LSE LSE, QPS_MEDICA MEDICA, QP7_UNIMED UNIMED "
							cQry+="	FROM "+RetSqlName("QPR")+" QPR, "+RetSqlName("QP7")+" QP7, "+RetSqlName("QPS")+" QPS "
							cQry+="	WHERE QPR_FILIAL		=	'"+QPK->QPK_FILIAL+"' "
							cQry+="	AND QPR_OP				=	'"+QPK->QPK_OP+"' "
							cQry+="	AND QPR_PRODUT			=	'"+QPK->QPK_PRODUT+"' "
							cQry+="	AND QPR_LOTE			= 	'"+QPK->QPK_LOTE+"' "
							cQry+="	AND QPR_REVI			= 	'"+QPK->QPK_REVI+"' "
							cQry+="	AND QPR_PRODUT			=	QP7_PRODUT
							cQry+="	AND QPR_LABOR			=   QP7_LABOR
							cQry+="	AND QPR_ENSAIO			=	QP7_ENSAIO
							cQry+="	AND QPR_REVI			=	QP7_REVI
							CQRY+=" AND QPR_FILIAL			=	QPS_FILIAL
							CQRY+=" AND QPR_CHAVE			=	QPS_CODMED
							cQry+="	AND QPR.D_E_L_E_T_ 	!= 	'*' "
							cQry+="	AND QP7.D_E_L_E_T_ 	!= 	'*' "
							cQry+="	AND QPS.D_E_L_E_T_ 	!= 	'*' "
							cQry+="	GROUP BY QPR_OP, QPR_PRODUT,  "
							cQry+="	QPR_LOTE, QPR_LABOR, QPR_ENSAIO, QPR_RESULT, "
							cQry+="	'', QP7_LIE, QP7_LSE, QPS_MEDICA, QP7_UNIMED"

							cQry+="	ORDER BY LABOR DESC, QP7_SEQLAB "
							//cQry+="	ORDER BY LABOR DESC, ENSAIO "
//							MemoWrite("C:\quality.txt", cQry)

							if Select("QRY")>0
								Qry->(dbCloseArea())
							EndIf

							cQry := ChangeQuery(cQry)
							TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Chamada do Cabeçalho e info principal                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Cabecalho()
							Principal()

							oPrint:Line (nLin-5, 145, nLin+45, 145) //vertical ini
							oPrint:Line (nLin-5, 2300, nLin+45, 2300) //Vertical Fim
							oPrint:FillRect( {nLin-5,145, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
							oPrint:Say(nLin-2, 1150,	"ANÁLISES", oFont12N,,,,2)
							nLin+=50
							oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal

							cTexto1:=""
							cTexto2:=""
							cTexto3:=""
							cTexto4:=""
							cTexto5:=""

							While QRY->(!EoF())
								cLab:=QRY->LABOR
								oPrint:Line (nLin-5, 145, nLin+45, 145) //vertical ini
								oPrint:Line (nLin-5, 2300, nLin+45, 2300) //Vertical Fim
								oPrint:Say(nLin, 150, SeqLab+" - "+Posicione("SX5",1,xFilial("SX5")+"Q2"+QRY->LABOR,"X5_DESCRI"), oFont10N)
								SeqLab:= Soma1(SeqLab,1)
								nLin+= 50
								nLinInic:=nLin
								oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal
								oPrint:Line (nLin-5, 145, nLin+45, 145) //vertical ini
								oPrint:Line (nLin-5, 2300, nLin+45, 2300) //Vertical Fim
								oPrint:Say(nLin, 150, "PARÂMETRO", oFont10N,,,,2)
								oPrint:Say(nLin, 700, "REFERÊNCIA", oFont10N)
								oPrint:Say(nLin, 1150, "ESPEC.", oFont10N,,,,2)
								oPrint:Say(nLin, /*2122*/2060, "RESULTADO", oFont10N,,,,2)
								nLin+= 50
								oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal

								While QRY->(!EoF()) .AND. QRY->LABOR == cLab

									oPrint:Say(nLin,150, substr(Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_DESCPO"),1,30), oFont8)
									//oPrint:Say(nLin,730, Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF"), oFont8,,,,2)
									IF !EMPTY(QRY->TEXTO)
										cTexto1:=Alltrim(subStr(QRY->TEXTO,1,60))
										cTexto2:=Alltrim(subStr(QRY->TEXTO,61,60))
										cTexto3:=Alltrim(subStr(QRY->TEXTO,121,60))
										cTexto4:=Alltrim(subStr(QRY->TEXTO,181,60))
										cTexto5:=Alltrim(subStr(QRY->TEXTO,241,59))
										oPrint:Say(nLin,/*870*/730, cTexto1, oFont8)
									ELSE
										oPrint:Say(nLin,/*870*/730, Alltrim(QRY->LIE)+" a "+ Alltrim(QRY->LSE) +" "+ AllTRIM(QRY->UNIMED), oFont8)
									ENDIF
									oPrint:Say(nLin,1000, Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF"), oFont8,,,,2)
									oPrint:Say(nLin,1950, Alltrim(QRY->MEDICA), oFont8)
									if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto2)
										nLin+=50
										oPrint:Say(nLin,/*870*/1000, cTexto2, oFont8)
										cTexto2:=""
									Endif
									if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto3)
										nLin+=50
										oPrint:Say(nLin,/*870*/1000, cTexto3, oFont8)
										cTexto3:=""
									Endif
									if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto4)
										nLin+=50
										oPrint:Say(nLin,/*870*/1000, cTexto4, oFont8)
										cTexto4:=""
									Endif
									if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto5)
										nLin+=50
										oPrint:Say(nLin,/*870*/1000, cTexto5, oFont8)
										cTexto5:=""
									Endif

									QRY->(DbSkip())
									nLin+= 50
									oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal
								EndDo
								nLinFim:=nLin

							ENDDO

							Secundario()
						EndIf
					EndIf
					SD2->(DbSkip())
				EndDo
			EndIf

		Endif

	Else //Se Modulo for igual de QIP

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Query com os dados que serão impressos no relatório            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cQry:=""
		cQry:="	SELECT QPR_OP OP, QPR_PRODUT PRODUT,  "
		cQry+="	QPR_LOTE LOTE, QPR_LABOR LABOR, QPR_ENSAIO ENSAIO, QPR_RESULT RESULT, "
		cQry+="	QP8_TEXTO TEXTO, '' LIE, '' LSE, QPQ_MEDICA MEDICA, '' UNIMED "
		cQry+="	FROM "+RetSqlName("QPR")+" QPR, "+RetSqlName("QP8")+" QP8, "+RetSqlName("QPQ")+" QPQ "
		cQry+="	WHERE QPR_FILIAL		=	'"+QPK->QPK_FILIAL+"' "
		cQry+="	AND QPR_OP				=	'"+QPK->QPK_OP+"' "
		cQry+="	AND QPR_PRODUT			=	'"+QPK->QPK_PRODUT+"' "
		cQry+="	AND QPR_LOTE			= 	'"+QPK->QPK_LOTE+"' "
		cQry+="	AND QPR_REVI			= 	'"+QPK->QPK_REVI+"' "
		cQry+="	AND QPR_PRODUT			=	QP8_PRODUT
		cQry+="	AND QPR_LABOR			=   QP8_LABOR
		cQry+="	AND QPR_ENSAIO			=	QP8_ENSAIO
		cQry+="	AND QPR_REVI			=	QP8_REVI
		CQRY+=" AND QPR_FILIAL			=	QPQ_FILIAL
		CQRY+=" AND QPR_CHAVE			=	QPQ_CODMED
		cQry+="	AND QPR.D_E_L_E_T_ 	!= 	'*' "
		cQry+="	AND QP8.D_E_L_E_T_ 	!= 	'*' "
		cQry+="	AND QPQ.D_E_L_E_T_ 	!= 	'*' "

		cQry+=" UNION ALL "

		cQry+="	SELECT QPR_OP OP, QPR_PRODUT PRODUT,  "
		cQry+="	QPR_LOTE LOTE, QPR_LABOR LABOR, QPR_ENSAIO ENSAIO, QPR_RESULT RESULT, "
		cQry+="	'' TEXTO, QP7_LIE LIE, QP7_LSE LSE, QPS_MEDICA MEDICA, QP7_UNIMED UNIMED "
		cQry+="	FROM "+RetSqlName("QPR")+" QPR, "+RetSqlName("QP7")+" QP7, "+RetSqlName("QPS")+" QPS "
		cQry+="	WHERE QPR_FILIAL		=	'"+QPK->QPK_FILIAL+"' "
		cQry+="	AND QPR_OP				=	'"+QPK->QPK_OP+"' "
		cQry+="	AND QPR_PRODUT			=	'"+QPK->QPK_PRODUT+"' "
		cQry+="	AND QPR_LOTE			= 	'"+QPK->QPK_LOTE+"' "
		cQry+="	AND QPR_REVI			= 	'"+QPK->QPK_REVI+"' "
		cQry+="	AND QPR_PRODUT			=	QP7_PRODUT
		cQry+="	AND QPR_LABOR			=   QP7_LABOR
		cQry+="	AND QPR_ENSAIO			=	QP7_ENSAIO
		cQry+="	AND QPR_REVI			=	QP7_REVI
		CQRY+=" AND QPR_FILIAL			=	QPS_FILIAL
		CQRY+=" AND QPR_CHAVE			=	QPS_CODMED
		cQry+="	AND QPR.D_E_L_E_T_ 	!= 	'*' "
		cQry+="	AND QP7.D_E_L_E_T_ 	!= 	'*' "
		cQry+="	AND QPS.D_E_L_E_T_ 	!= 	'*' "
		cQry+="	GROUP BY QPR_OP, QPR_PRODUT,  "
		cQry+="	QPR_LOTE, QPR_LABOR, QPR_ENSAIO, QPR_RESULT, "
		cQry+="	'', QP7_LIE, QP7_LSE, QPS_MEDICA, QP7_UNIMED"

		cQry+="	ORDER BY LABOR DESC, ENSAIO "
//		MemoWrite("C:\quality.txt", cQry)

		if Select("QRY")>0
			Qry->(dbCloseArea())
		EndIf

		cQry := ChangeQuery(cQry)
		TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamada do Cabeçalho e info principal                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Cabecalho()
		Principal()

		//oPrint:FillRect( {nLin-5,145, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
		oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal
		oPrint:Say(nLin, 1150,	"ENSAIOS DO PRODUTO ACABADO", oFont12N,,,,2)
		nLin+=50
		oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal
		cTexto1:=""
		cTexto2:=""
		cTexto3:=""
		cTexto4:=""
		cTexto5:=""

		While QRY->(!EoF())
			cLab:=QRY->LABOR
			//oPrint:Say(nLin, 150, SeqLab+" - "+Posicione("SX5",1,xFilial("SX5")+"Q2"+QRY->LABOR,"X5_DESCRI"), oFont10N)
			SeqLab:= Soma1(SeqLab,1)
			//nLin+= 50
			nLinInic:=nLin
			
			oPrint:Say(nLin, 150, "PARÂMETRO", oFont10N)
			oPrint:Say(nLin, 800, "ESPECIFICAÇÃO", oFont10N)
			oPrint:Say(nLin, 1550, "REFERÊNCIA", oFont10N,,,,2)
			oPrint:Say(nLin, /*2122*/2060, "RESULTADO", oFont10N,,,,2)
			nLin+= 50
			oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal
			//oPrint:Say(nLin, 150, SeqLab+" - "+Posicione("SX5",1,xFilial("SX5")+"Q2"+QRY->LABOR,"X5_DESCRI"), oFont10N)
			oPrint:Say(nLin, 950, Posicione("SX5",1,xFilial("SX5")+"Q2"+QRY->LABOR,"X5_DESCRI"), oFont10N)
			nLin+= 50
			//oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal

			While QRY->(!EoF()) .AND. QRY->LABOR == cLab

				//oPrint:Say(nLin,150, substr(Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_DESCPO"),1,40), oFont7)
				oPrint:Say(nLin,150, Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_DESCPO"), oFont7)
				//oPrint:Say(nLin,830, Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF"), oFont8,,,,2)
				IF !EMPTY(QRY->TEXTO)
					cTexto1:=Alltrim(subStr(QRY->TEXTO,1,60))
					cTexto2:=Alltrim(subStr(QRY->TEXTO,61,60))
					cTexto3:=Alltrim(subStr(QRY->TEXTO,121,60))
					cTexto4:=Alltrim(subStr(QRY->TEXTO,181,60))
					cTexto5:=Alltrim(subStr(QRY->TEXTO,241,59))
					oPrint:Say(nLin,/*870*/830, cTexto1, oFont7)
				ELSE
					oPrint:Say(nLin,/*870*/830, Alltrim(QRY->LIE)+" a "+ Alltrim(QRY->LSE)  +" "+ AllTRIM(QRY->UNIMED), oFont7)
				ENDIF
				If (Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF")) == '1'
					oPrint:Say(nLin,1550, "DL", oFont7,,,,2)
				EndIf
				If (Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF")) == '2'
					oPrint:Say(nLin,1550, "FB", oFont7,,,,2)
				EndIf
							
				//oPrint:Say(nLin,1150, Posicione("QP1",1,xFilial("QP1")+QRY->ENSAIO,"QP1_XREF"), oFont8,,,,2)
				oPrint:Say(nLin,1950, Alltrim(QRY->MEDICA), oFont7)
				if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto2)
					nLin+=50
					oPrint:Say(nLin,/*870*/1000, cTexto2, oFont7)
					cTexto2:=""
				Endif
				if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto3)
					nLin+=50
					oPrint:Say(nLin,/*870*/1000, cTexto3, oFont7)
					cTexto3:=""
				Endif
				if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto4)
					nLin+=50
					oPrint:Say(nLin,/*870*/1000, cTexto4, oFont7)
					cTexto4:=""
				Endif
				if !EMPTY(QRY->TEXTO) .and. !Empty(cTexto5)
					nLin+=50
					oPrint:Say(nLin,/*870*/1000, cTexto5, oFont7)
					cTexto5:=""
				Endif

				QRY->(DbSkip())
				nLin+= 50

			EndDo
			nLinFim:=nLin

		ENDDO

		Secundario()

	Endif
	///////////////////////////////////////////////////////////////////////////////////////
	////Visualiza a impressao
	///////////////////////////////////////////////////////////////////////////////////////

	oPrint:Preview()

	cFunction := FUNNAME()

	//----------------------------CUSTOMIZAÇÃO EM TESTE---------------------------------------
	If cFunction == 'MATA410'

		cQry:=""
		cQry+="SELECT A1_XLAUCOR LAUDOCOR"
		cQry+="	FROM "+RetSqlName("SA1")+"  SA1   "
		cQry+=" WHERE A1_COD = '"+_cCliente+"'  AND A1_LOJA = '"+_cLoja+"'  and D_E_L_E_T_ <> '*'"

		if Select("QRY1")>0
			QRY1->(dbCloseArea())
		EndIf

		cQry := ChangeQuery(cQry)

		TcQuery cQry New Alias "QRY1" // Cria uma nova area com o resultado do query

		If QRY1->LAUDOCOR = '1'

			U_QIPARCOR(FILIAL,NOTA,SERIE)

		EndIf
	EndIf

	Return

	//------------------------------------------------FINAL TESTE-----------------------------

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cabecalho ºAutor  ³Microsiga           º Data ³  01/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que monta o cabeçalho do relatorio                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cabecalho()

	oPrint:StartPage() // Inicia uma nova pagina
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	oPrint:Say(3300, 1077, "Página " + cValToChar(nPag), oFont8)
	//	oPrint:Say(3300, 1077, Time(), oFont10)
	oPrint:Say(3340, 1063, DTOC(dDatabase), oFont8)

	nLin+=80
	oPrint:SayBitmap(170, 180, cStartPath + "logo_genix_laudo.jpg", 420, 140)///Impressao da Logo//Largura,Altura
	//oPrint:SayBitmap(100, 1950, cStartPath + "logo_extracaps.png", 240, 233)///Impressao da Logo
	oPrint:Say(nLin, 1780, "Genix Indústria Farmacêutica LTDA", oFont8N)
	nLin+=35
	oPrint:Say(nLin, 1780, "V.P., 1E, Qd 03, Módulos 01 e 02,", oFont8)
	nLin+=35
	oPrint:Say(nLin, 1780, "DAIA, Anápolis-GO CEP: 75132-040", oFont8)
	nLin+=35
	oPrint:Say(nLin, 1780, "Telefone: +55 62 4014-9084", oFont8)
	nLin+=35
	oPrint:Say(nLin, 1780, "Fax: +55 62 4014-9001", oFont8)
	nLin+=35
	oPrint:Say(nLin, 1780, "E-mail: sac@genix.ind.br", oFont8)
	nLin+=100
	//	oPrint:Line (nLin, 146, nLin, 2300)
	//	nLin+=80

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Principal ºAutor  ³Marcos Natã         º Data ³  30/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que monta info principal do relatorio               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Principal()

	_secao:=Alltrim(QPK->QPK_LOTE)
	_secao:=substr(_secao,len(_secao),1)
	If nPag = 1
		oPrint:FillRect( {nLin-5,146, nLin+215, 2300}, oBrush2 )
		oPrint:Say(nLin+35, 1780, "HARD TWO-PIECE", oFont16N,,CLR_WHITE,,2)
		oPrint:Say(nLin+110, 1815, "GELATIN CAPSULES", oFont16N,,CLR_WHITE,,2)
		nLin+= 280
		oPrint:Say(nLin-40, 1150,	"CERTIFICADO DE ANÁLISE", oFont16N,,,,2)
		//oPrint:Say(nLin+= 40, 150,	"Este  certificado  garante  que  as  informações  aqui  contidas  foram  aprovadas  pela  Unidade  da  Qualidade  de  acordo  com  as", oFont10) //C
		//oPrint:Say(nLin+= 50, 150,	"especificações estabelecidas conforme descrito no Manual de Especificações Técnicas e requisitos regulatórios aplicáveis.", oFont10) //C
		nLin+= 70
	EndIf
	//oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal //C
	//oPrint:Line (nLin-5, 145, nLin+45, 145) //vertical ini	//C
	//oPrint:Line (nLin-5, 2300, nLin+45, 2300) //Vertical Fim //C
	//oPrint:FillRect( {nLin-5,145, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	//oPrint:Say(nLin-2, 1150,	"INFORMAÇÕES DO PRODUTO", oFont12N,,,,2)
	//nLin+= 50
	nLinInic:=nLin
	oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal //C
	oPrint:Say(nLin, 150,	"PRODUTO: ", oFont10N)
	oPrint:Say(nLin, 490,	Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_DESC"), oFont10)
	if _cOrigem<>"QIP"
		oPrint:Say(nLin, 1350,	"NOTA FISCAL: "/* +Alltrim(NOTA)+"          Série: "+Alltrim(SERIE)+"          Item: "+Alltrim(SD2->D2_ITEM)*/, oFont10N)
		oPrint:Say(nLin, 1700,	Alltrim(NOTA)+ " / " + Alltrim(SERIE), oFont10)
	Else
		oPrint:Say(nLin, 1350,	" ", oFont10N)
	EndIf
	nLin+= 50
	//oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal //C
	oPrint:Say(nLin, 150,	"CÓDIGO: ", oFont10N)
	oPrint:Say(nLin, 490,	QPK->QPK_PRODUT, oFont10)
	oPrint:Say(nLin, 1350,	"DATA DE EMISÃO: ", oFont10N)
	oPrint:Say(nLin, 1700,	DtoC(posicione("QPL",3,xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE,"QPL_DTLAUD")), oFont10)
	nLin+= 50
	//oPrint:Line (nLin-5, 145, nLin-5, 2300) //horizontal //C
	_CorTMP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORTMP"))
	_CorCRP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORCRP"))

	//Alteração por Stephen Noel solicitado pela Drª Patricia, para que a descricao da cora salte para proxima linha
	//Quando nao couber o nome completo na mesma linha

	descz3:= Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorCRP,"Z3_DESC"))
	desc2z3:= Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorCRP,"Z3_DESC"))
	somalen:=(Len(descz3)+ Len(desc2z3))
	If (somalen < 16)
		oPrint:Say(nLin, 150,	"CÓDIGO DA COR:", oFont10N)
		oPrint:Say(nLin, 490,	_CorTMP+" - "+Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorTMP,"Z3_DESC"))+" / "+;
		_CorCRP+" - "+Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorCRP,"Z3_DESC")), oFont10)
		oPrint:Say(nLin, 1350,	"PROCEDÊNCIA: ", oFont10N)
		oPrint:Say(nLin, 1700,	Posicione("SZ1",9,xFilial("SZ1")+QPK->QPK_OP+_secao,"Z1_PROCED"), oFont10)
		nLin+= 50
	Else
		_CorTMP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORTMP"))
		_CorCRP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORCRP"))
		oPrint:Say(nLin, 150,	"CÓDIGO DA COR:", oFont10N)
		oPrint:Say(nLin, 490,	_CorTMP+" - "+Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorTMP,"Z3_DESC"))+" / ")//+;
		oPrint:Say(nLin, 1350,	"PROCEDÊNCIA: ", oFont10N)
		oPrint:Say(nLin, 1700,	Posicione("SZ1",9,xFilial("SZ1")+QPK->QPK_OP+_secao,"Z1_PROCED"), oFont10)
		nLin+= 50
		oPrint:Say(nLin, 150,	_CorCRP+" - "+Alltrim(posicione("SZ3",2,xFilial("SZ3")+_CorCRP,"Z3_DESC")), oFont10)
		nLin+= 50
	EndIf
	//Fim alteração stephen
	_Grupo:=Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_GRUPO")
	oPrint:Say(nLin, 150,	"TAMANHO: ", oFont10N)
	oPrint:Say(nLin, 490,	posicione("SBM",1,xFilial("SBM")+_Grupo,"BM_TAMANHO"), oFont10)
	oPrint:Say(nLin, 1350,	"ORIGEM: ", oFont10N)
	oPrint:Say(nLin, 1700,	Posicione("SZ1",9,xFilial("SZ1")+QPK->QPK_OP+_secao,"Z1_ORIGEM"), oFont10)
	nLin+= 50
	oPrint:Say(nLin, 150,	"LOTE: ", oFont10N)
	oPrint:Say(nLin, 490,	QPK->QPK_LOTE, oFont10)
	oPrint:Say(nLin, 1350,	"FABRICAÇÃO: ", oFont10N)
	oPrint:Say(nLin, 1700,	DtoC(Posicione("SZ1",9,xFilial("SZ1")+QPK->QPK_OP+_secao,"Z1_DTFAB")), oFont10)
	nLin+= 50
	oPrint:Say(nLin, 150,	"SEÇÃO: ", oFont10N)
	oPrint:Say(nLin, 490,	_secao, oFont10)
	oPrint:Say(nLin, 1350,	"VALIDADE: ", oFont10N)
	oPrint:Say(nLin, 1700,	DtoC(Posicione("SZ1",9,xFilial("SZ1")+QPK->QPK_OP+_secao,"Z1_DTVALID")), oFont10)
	nLin+= 70

	nLinFim:=nLin

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Secundario ºAutor  ³Marcos Natã         º Data ³  30/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que monta info secundaria do relatorio               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Secundario()

	_CorTMP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORTMP"))
	_RevTMP:=Alltrim(Posicione("SC2",9,xFilial("SC2")+SUBSTR(QPK->QPK_OP, 1, 6)+SUBSTR(QPK->QPK_OP, 7, 2)+QPK->QPK_PRODUT,"C2_XRVCAP"))
	_CorCRP:=Alltrim(Posicione("SB1",1,xFilial("SB1")+QPK->QPK_PRODUT,"B1_XCORCRP"))
	_RevCRP:=Alltrim(Posicione("SC2",9,xFilial("SC2")+SUBSTR(QPK->QPK_OP, 1, 6)+SUBSTR(QPK->QPK_OP, 7, 2)+QPK->QPK_PRODUT,"C2_XRVBODY"))
	
//	cQry1 := "SELECT C2_NUM OP, C2_XRVCAP REV FROM SC2010 "
//	cQry1 += "WHERE D_E_L_E_T_ = ' ' "
//	cQry1 += "AND C2_NUM = '"+ SUBSTR(QPK->QPK_OP, 1, 6) +"' "
//
//	If Select("REV1") > 0
//		DBSelectArea("REV1")
//		DBCloseArea("REV1")
//	Endif
//	cQry1 := changequery(cQry1)
//	TcQuery cQry1 New Alias "REV1"

	cQry1 := "SELECT * FROM SZF010 "
	cQry1 += "WHERE D_E_L_E_T_ = ' ' "
	cQry1 += "AND ZF_CODCOR = '"+ _CorTMP +"' "
	cQry1 += "AND ZF_REVISAO = '"+ _RevTMP +"' "

	If Select("TMP") > 0
		DBSelectArea("TMP")
		DBCloseArea("TMP")
	Endif
	cQry1 := changequery(cQry1)
	TcQuery cQry1 New Alias "TMP"

//-------------------------------------------------

//	cQry1 := "SELECT C2_NUM OP, C2_XRVBODY REV FROM SC2010 "
//	cQry1 += "WHERE D_E_L_E_T_ = ' ' "
//	cQry1 += "AND C2_NUM = '"+ SUBSTR(QPK->QPK_OP, 1, 6) +"' "
//
//	If Select("REV2") > 0
//		DBSelectArea("REV2")
//		DBCloseArea("REV2")
//	Endif
//	cQry1 := changequery(cQry1)
//	TcQuery cQry1 New Alias "REV2"

	cQry1 := "SELECT * FROM SZF010 "
	cQry1 += "WHERE D_E_L_E_T_ = ' ' "
	cQry1 += "AND ZF_CODCOR = '"+ _CorCRP +"' "	
	cQry1 += "AND ZF_REVISAO = '"+ _RevCRP +"' "

	If Select("CRP") > 0
		DBSelectArea("CRP")
		DBCloseArea("CRP")
	Endif
	cQry1 := changequery(cQry1)
	TcQuery cQry1 New Alias "CRP"

	nLin+=20
	nLinInic:=nLin
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	//oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Say(nLin, 1150,	"ATRIBUTOS VISUAIS", oFont12N,,,,2)
	//nLin+= 50
	//oPrint:Say(nLin, 146, "Todas as cápsulas são analisadas visualmente de forma estatística conforme especificações. Os valores são baseados na NBR 5426/1985 - Plano de amostragem", oFont8)
	//nLin+= 40
	//oPrint:Say(nLin, 146, "e procedimentos na inspeção por atributos.", oFont8)
	nLin+= 50
	//oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	
	//Cabeçalho dos Atributos Visuais // Valores Fixos.
	oPrint:Say(nLin-2, 150, "Defeitos visuais", oFont8)
	oPrint:Say(nLin-2, 800, "Crítico", oFont8,,,,2)
	oPrint:Say(nLin-2, 1000, "Maior", oFont8,,,,2)
	oPrint:Say(nLin-2, 1200, "Menor", oFont8,,,,2)
	oPrint:Say(nLin-2, 1550, "MT", oFont8,,,,2)
	//oPrint:Say(nLin-2, 1950, "Resultado", oFont8)
	nLin+= 40
	//oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin-2, 150, "NQA", oFont8)
	oPrint:Say(nLin-2, 800, "00", oFont8,,,,2)
	oPrint:Say(nLin-2, 1000, "02", oFont8,,,,2)
	oPrint:Say(nLin-2, 1200, "07", oFont8,,,,2)
	oPrint:Say(nLin-2, 1850, "Cumpre especificação", oFont8)
	nLin+= 40
	//oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin-2, 150, "Defeitos de gravação", oFont8)
	oPrint:Say(nLin-2, 800, "Crítico", oFont8,,,,2)
	oPrint:Say(nLin-2, 1000, "Maior", oFont8,,,,2)
	oPrint:Say(nLin-2, 1200, "Menor", oFont8,,,,2)
	oPrint:Say(nLin-2, 1550, "MT", oFont8,,,,2)
	//oPrint:Say(nLin-2, 1950, "Resultado", oFont8)
	nLin+= 40
	//oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin-2, 150, "NQA", oFont8)
	oPrint:Say(nLin-2, 800, "00", oFont8,,,,2)
	oPrint:Say(nLin-2, 1000, "07", oFont8,,,,2)
	oPrint:Say(nLin-2, 1200, "10", oFont8,,,,2)
	oPrint:Say(nLin-2, 1850, "Cumpre especificação (Se aplicável)", oFont8)
	nLin+= 50
	//oPrint:Say(nLin, 146, "Os valores acima são referentes a uma amostra de 1.250 cápsulas.", oFont8)
	//nLin+= 50
	//oPrint:FillRect( {nLin-5,145, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	//oPrint:Say(nLin, 1150,	"REFERÊNCIAS", oFont12N,,,,2)
	nLin+= 50
	oPrint:Say(nLin, 150,	"(DL) - Desenvolvimento Local", oFont8)
	oPrint:Say(nLin+= 50, 150,	"(FB) - Farmacopéia Brasileira 5ª Edição", oFont8)
	oPrint:Say(nLin+= 50, 150,	"(MT) - Manual de Especificações Técnicas", oFont8)
	
	oPrint:EndPage()
	nPag++
	nLin:=50
	Cabecalho()
	Principal()
	/*
	oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Say(nLin, 1150,	"REQUISITOS REGULATÓRIOS", oFont12N,,,,2)
	nLin+= 50
	oPrint:Say(nLin, 150, "MATÉRIA-PRIMA", oFont10N)
	oPrint:Say(nLin+=50, 150, "GELATINA: De acordo com as exigências dos Compêndios Oficiais." , oFont8)
	oPrint:Say(nLin+=50, 150, "A origem é bovina e tem os certificados de suitability: R1-CEP-2003-172-Rev.01 e R1-CEP-2003-178-Rev.01.", oFont8)
	oPrint:Say(nLin+=50, 150, "Declaramos que o lote em questão foi produzido com gelatina nacional, livre de BSE, oriunda de fornecedor(es) devidamente qualificado(s) e em condições sanitárias", oFont8)
	oPrint:Say(nLin+=50, 150, "satisfatórias, conforme atestam as declarações do Ministério da Agricultura, Pecuária e Abastecimento.", oFont8)
	oPrint:Say(nLin+=50, 150, "CORANTES: De acordo com as exigências dos Compêndios Oficiais.", oFont8)
	oPrint:Say(nLin+=50, 150, "TINTAS DE GRAVAÇÃO: De acordo com as exigências dos Compêndios Oficiais.", oFont8)
	nLin+= 75
	oPrint:Say(nLin, 150, "CÁPSULA", oFont10N)
	oPrint:Say(nLin+=50, 150, "- Não contém conservantes.", oFont8)
	oPrint:Say(nLin+=75, 150, "- Para que a cápsula mantenha as suas características ideiais durante o prazo de validade, recomenda-se que as cápsulas sejam transportadas e armazenadas com a", oFont8)
	oPrint:Say(nLin+=50, 150, "  temperatura entre 15ºC e 25ºC e umidade relativa entre 35% e 65% UR.", oFont8)
	oPrint:Say(nLin+=75, 150, "- Este  certificado  garante  que  as  informações  aqui  contidas  foram  aprovadas  pela  Unidade  da  Qualidade  de  acordo  com  as especificações estabelecidas", oFont8)
	oPrint:Say(nLin+=50, 150, "  conforme descrito no Manual de Especificações Técnicas e requisitos regulatórios aplicáveis.", oFont8)
	nLin+= 50
	*/
	//oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin, 1150,	"COMPOSIÇÃO DA CÁPSULA", oFont12N,,,,2)
	nLin+= 60
	oPrint:Say(nLin, 146, "A tampa representa 40% e o corpo 60% do peso total da cápsula.", oFont8)
	nLin+= 60
	oPrint:Say(nLin, 146, "Composição da Tampa: " + alltrim(TMP->ZF_CODCOR) + " - " + TMP->ZF_DESC, oFont10N)
	nLin+= 60
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	//oPrint:Say(nLin, 150, "Código da cor", oFont8N)
	oPrint:Say(nLin, 150, "Color Index", oFont8N)
	oPrint:Say(nLin, 783, "Componente", oFont8N)
	oPrint:Say(nLin, 1700, "Porcentagem", oFont8N)
	nLin+= 40
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	While TMP->(!EOF())
	
	//Validando se a amarração de cor x componente foi aprovado pela Garantia da Qualidade.
	If Empty(TMP->ZF_APROV)
		Alert ("Entrei no alerta da cor não aprovada pela Garantia da Qualidade." + Chr(13)+Chr(10) + TMP->ZF_CODCOR + " - " + TMP->ZF_DESC)
	EndIf
	
		//oPrint:Say(nLin+2, 150, TMP->ZF_CODCOR + " - " + TMP->ZF_DESC, oFont8)
		If Empty(TMP->ZF_CODCI)
		oPrint:Say(nLin+2, 150, TMP->ZF_CODCI, oFont7)
		Else
		oPrint:Say(nLin+2, 150, Transform(TMP->ZF_CODCI,"@R 99.999"), oFont7)
		EndIf
		oPrint:Say(nLin+2, 783, TMP->ZF_DESCCOM, oFont7)
		oPrint:Say(nLin+2, 1700, alltrim(TMP->ZF_COMPLEM) + " " + alltrim(TMP->ZF_PORCENT) + " %", oFont7)
		TMP->(DbSkip())
		nLin += 40
	EndDo
	nLin+= 40
	oPrint:Say(nLin, 146, "Composição do Corpo: " + alltrim(CRP->ZF_CODCOR) + " - " + CRP->ZF_DESC, oFont10N)
	nLin+= 60
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	//oPrint:Say(nLin+2, 150, "Código da cor", oFont8N)
	oPrint:Say(nLin+2, 150, "Color Index", oFont8N)
	oPrint:Say(nLin+2, 783, "Componente", oFont8N)
	oPrint:Say(nLin+2, 1700, "Porcentagem", oFont8N)
	nLin+= 40
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	While CRP->(!EOF())
	
		//Validando se a amarração de cor x componente foi aprovado pela Garantia da Qualidade.
		If Empty(CRP->ZF_APROV)
			Alert ("Entrei no alerta da cor não aprovada pela Garantia da Qualidade." + Chr(13)+Chr(10) + CRP->ZF_CODCOR + " - " + CRP->ZF_DESC)
		EndIf
		//oPrint:Say(nLin+2, 150, CRP->ZF_CODCOR + " - " + CRP->ZF_DESC, oFont8)
		If Empty(CRP->ZF_CODCI)
		oPrint:Say(nLin+2, 150, CRP->ZF_CODCI, oFont7)
		Else
		oPrint:Say(nLin+2, 150, Transform(CRP->ZF_CODCI,"@R 99.999"), oFont7)
		EndIf
		oPrint:Say(nLin+2, 783, CRP->ZF_DESCCOM, oFont7)
		oPrint:Say(nLin+2, 1700, alltrim(CRP->ZF_COMPLEM) + " " + alltrim(CRP->ZF_PORCENT) + " %", oFont7)
		CRP->(DbSkip())
		nLin += 40
	EndDo
	nLin+= 10
	nLin+= 50
	
	//oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin, 1150,	"REQUISITOS REGULATÓRIOS", oFont12N,,,,2)
	nLin+= 50
	oPrint:Say(nLin, 150, "MATÉRIA-PRIMA", oFont10N)
	oPrint:Say(nLin+=50, 150, "GELATINA: De acordo com as exigências dos Compêndios Oficiais." , oFont8)
	oPrint:Say(nLin+=50, 150, "A origem é bovina e tem os certificados de suitability: R1-CEP-2003-172-Rev.01 e R1-CEP-2003-178-Rev.01.", oFont8)
	oPrint:Say(nLin+=50, 150, "Declaramos que o lote em questão foi produzido com gelatina nacional, livre de BSE, oriunda de fornecedor(es) devidamente qualificado(s) e em condições sanitárias", oFont8)
	oPrint:Say(nLin+=50, 150, "satisfatórias, conforme atestam as declarações do Ministério da Agricultura, Pecuária e Abastecimento.", oFont8)
	oPrint:Say(nLin+=50, 150, "CORANTES: De acordo com as exigências dos Compêndios Oficiais.", oFont8)
	oPrint:Say(nLin+=50, 150, "TINTAS DE GRAVAÇÃO: De acordo com as exigências dos Compêndios Oficiais.", oFont8)
	nLin+= 75
	oPrint:Say(nLin, 150, "CÁPSULA", oFont10N)
	oPrint:Say(nLin+=50, 150, "- Não contém conservantes.", oFont8)
	oPrint:Say(nLin+=75, 150, "- Para que a cápsula mantenha as suas características ideiais durante o prazo de validade, recomenda-se que as cápsulas sejam transportadas e armazenadas com a", oFont8)
	oPrint:Say(nLin+=50, 150, "  temperatura entre 15ºC e 25ºC e umidade relativa entre 35% e 65% UR.", oFont8)
	oPrint:Say(nLin+=75, 150, "- Este  certificado  garante  que  as  informações  aqui  contidas  foram  aprovadas  pela  Unidade  da  Qualidade  de  acordo  com  as especificações estabelecidas", oFont8)
	oPrint:Say(nLin+=50, 150, "  conforme descrito no Manual de Especificações Técnicas e requisitos regulatórios aplicáveis.", oFont8)
	nLin+= 50
	
	//oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin, 1150,	"RESULTADO FINAL", oFont12N,,,,2)
	nLin+= 50
	_xResult:=posicione("QPL",3,xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE,"QPL_LAUDO")
	oPrint:Say(nLin, 150,	"( "+iif(_xResult=="A","X","   ")+" ) - APROVADO", oFont8)
	nLin+= 50
	oPrint:Say(nLin, 150,	"( "+iif(_xResult<>"A","X","   ")+" ) - REPROVADO", oFont8)
	nLin+= 50
	//oPrint:FillRect( {nLin-5,146, nLin+45, 2300}, oBrush1 )///imprime o quadrante cinza
	oPrint:Line (nLin-5, 146, nLin-5, 2300) //horizontal
	oPrint:Say(nLin, 1150,	"ASSINATURA", oFont12N,,,,2)
	nLin+= 50

	nLin+= 150
	if _cOrigem<>"QIP"
		oPrint:SayBitmap(nlin-150, 1000, cStartPath + "assinatura_patricia.png", 340, 170)///Impressao da assinatura 248,204
		oPrint:Line(nLin, 750, nLin, 1500)
		nLin+= 30
		oPrint:Say(nLin, 1150, "FARMACEUTICA RESPONSÁVEL", oFont8,,,,2)
		nLin+= 50
		oPrint:Say(nLin, 1150, Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZP01","X5_DESCRI")), oFont8,,,,2)
	Else
		oPrint:SayBitmap(nlin-100, 490, cStartPath + "assinatura_james.png", 230, 100)///Impressao da assinatura 230,140
		oPrint:SayBitmap(nlin-150, 1600, cStartPath + "assinatura_patricia.png", 340, 170)///Impressao da assinatura 248,204
		oPrint:Line(nLin, 199, nLin, 949)
		oPrint:Line(nLin, 1416, nLin, 2166)
		nLin+= 30
		oPrint:Say(nLin, 599, "CONTROLE DE QUALIDADE", oFont8,,,,2)
		oPrint:Say(nLin, 1816, "FARMACEUTICA RESPONSÁVEL", oFont8,,,,2)
		nLin+= 50
		oPrint:Say(nLin, 599, Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZP02","X5_DESCRI")), oFont8,,,,2)
		oPrint:Say(nLin, 1816, Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZP01","X5_DESCRI")), oFont8,,,,2)
	EndIf
	nLin+=50
	nLinFim:=nLin
	nLin:=50
	oPrint:EndPage()

Return
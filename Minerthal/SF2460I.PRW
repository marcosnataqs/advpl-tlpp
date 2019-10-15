#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} Sf2460i

Descrição:
Ponto de entrada localizado após a atualização das tabelas referentes
à nota fiscal (SF2/SD2), mas antes da contabilização.
ATENÇÃO: Este ponto de entrada está dentro da transação na 
gravação das tabelas do documento.
Programa Fonte
MATA461.PRX, MATA468N.PRX
Sintaxe
SF2460I - Atualização das tabelas referentes à nota fiscal ( < UPAR> ) --> URET

@type User Function
@version 1.0
/*/
User Function Sf2460i
	local _nVez,_vE1,_nDifComis,_nDifBase,_nOrdE1,_nOrdE3,_nRecE1,_nRecE3,_cPedido,nAliqIcm:=0
	aAreaLoc := GetArea()

	// Verifica se é venda e a quantidade de parcelas
	// atualmente em SE1

	// Regiao e distrito

	sf2->(reclock(alias(),.f.))
	sf2->f2_mipedid:=sc5->c5_num
	sf2->f2_mireg  :=sc5->c5_mireg
	sf2->f2_midistr:=sc5->c5_midistr
	sf2->f2_micodmu:=sc5->c5_micodmu
	sf2->f2_miacomp:=sc5->c5_miacomp
	sf2->f2_mibcopv:=sc5->c5_banco
	sf2->f2_mibolet:=sc5->c5_boleto
	sf2->f2_mirota :=sc5->c5_mirota
	sf2->f2_veicul1 :=sc5->c5_micodve
	//sf2->f2_dtdigit :=sc5->c5_emissao   valter alterou para f2_dtentr em 05042017
	sf2->f2_dtentr :=sc5->c5_emissao
	sf2->f2_micpgto :=sc5->c5_micpgto
	sf2->(msunlock())

	if sf2->f2_valfat>0
		// Calcula o valor total a ser pago de comissao, acumula variaveis
		// de peso liquido e bruto
		_nRecD2:=sd2->(recno())
		_nOrdD2:=sd2->(indexord())
		sd2->(dbsetorder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		_cKeyD2:=sf2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		_nBaseComis:=_nValComis:=0
		sd2->(dbseek(_cKeyD2))
		_nPesoProd := _nPesoEmbal:=0
		_nQtdFrete := 0
		_nTotItem  := 0
		_cPedido   := ""
		do while sd2->(!eof().and.D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA==_cKeyD2)
			_nPesoProd+=sd2->(d2_quant*posicione("SB1",1,xfilial("SB1")+d2_cod,"B1_PESO"))
			if empty(sd2->d2_micemba).and.;
			posicione("SB1",1,xfilial("SB1")+sd2->(d2_cod+d2_micemba),"B1_PESBRU")>0
				_nPesoEmbal+=sb1->(int(sd2->d2_quant*b1_PESBRU)-(int(sd2->d2_quant*b1_peso)))
				//		posicione("SZU",1,xfilial("SZU")+sd2->(d2_cod+d2_micemba),"ZU_MIPESO")>0
				//		_nPesoEmbal+=szu->(int(sd2->d2_quant/zu_miqtemb)*zu_mipeso)

			endif
			If SD2->D2_GRUPO $ GetMV('MV_MIGRUFR') .AND. !(SD2->D2_TES $('583/584'))
				_nQtdFrete += SD2->D2_QUANT
				_nTotItem  := _nTotItem + 1
				_cPedido   := SD2->D2_PEDIDO
			EndIf
			_cPedido:=sd2->d2_pedido

			SC6->( DBSEEK( XFILIAL("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV ) )
			RECLOCK( "SD2", .F. )
			//	SD2->D2_TOTAL  := SC6->C6_PRUNIT * SC6->C6_QTDVEN          //valter 20/10/09
			SD2->D2_TOTAL  := SC6->C6_PRUNIT * SD2->D2_QUANT          //valter 20/10/09
			SD2->D2_PRCVEN := SC6->C6_PRUNIT
			SD2->D2_VALACRS:= 0
			SD2->( MSUNLOCK() )

			// Verifica se deve abater acrescimo financeiro
			//      _lDescAcres:=(posicione("SA3",1,xfilial("SA3")+SF2->f2_vend1,"A3_ACREFIN")=="N")
			_lDescAcres:=(posicione("SA3",1,xfilial("SA3")+SF2->f2_vend1,"A3_ACREFIN"))

			//    _nBaseItem:=sd2->(d2_total-if(_lDescAcres,d2_valacrs,0))
			_nBaseItem:=sd2->(d2_total-if(_lDescAcres=="N",(d2_valacrs*d2_quant),0))
			_nBaseComis+=_nBaseItem
			_nValComis+=sd2->d2_mivcom1
			sd2->(dbskip(1))
		enddo

		// Atualiza os pesos liquido e bruto em SF2
		if sf2->(round(f2_pliqui+f2_pbruto,2)<>round(_nPesoProd*2+_nPesoEmbal,2).and.;
		reclock(alias(),.f.))
			sf2->f2_pliqui:=_nPesoProd
			sf2->f2_pbruto:=_nPesoProd+_nPesoEmbal
			sf2->(msunlock())
		endif
		//valter em 27/03/15
		cBcoCart := GetMV("MV_CARTEIR")
		_cBanco:= posicione("SC5",1,xfilial("SC5")+_cPedido,"C5_BANCO")
		if _cBanco = cBcoCart
			_lCarteira := .t.
		else
			_lCarteira := .f.
		endif
		//	_cBanco:=posicione("SC5",1,xfilial("SC5")+_cPedido,"C5_BANCO")
		// 	_lCarteira:=_cBanco $ GetMV("MV_CARTEIR")
		_nOrdE1:=se1->(indexord())
		_nRecE1:=se1->(recno())
		Se1->(dbsetorder(1)) // _Filial+_Prefixo+_Num+_parcela+_Tipo
		_vE1:={}
		_cKeyE1:=sf2->(f2_filial+f2_serie+f2_doc)
		se1->(dbseek(_cKeyE1))
		do while se1->(!eof().and._cKeyE1==e1_filial+e1_prefixo+e1_num)
			aadd(_vE1,se1->(recno()))
			se1->(dbskip(1))
		enddo
		se1->(dbsetorder(_nOrdE1))

		//	_nRateioPor:=len(_vE1)+if(_lCarteira,0,1)   //acrescenta ou não parcela de venda
		_nRateioPor:=len(_vE1)+if(_lCarteira,0,0)
		_nValComis :=round(_nValComis,2)
		_nParcCom  :=Round(_nValComis/_nRateioPor,2)
		_nParcBase :=Round(_nBaseComis/_nRateioPor,2)
		_nDifComis :=if(_nRateioPor<=1,0,_nValComis -(round(_nParcCom *_nRateioPor,2)))
		_nDifBase  :=if(_nRateioPor<=1,0,_nBaseComis-(round(_nParcBase*_nRateioPor,2)))

		// Caso o banco seja carteira, elimina o registro de SE3 correspondente à emissao,
		// senao simplesmente atualiza os valores
		_nOrdE3:=se3->(indexord())
		se3->(dbsetorder(1)) //E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ
		_cKeyE3:=sf2->(f2_filial+f2_serie+f2_doc)
		if Se3->(dbseek(_cKeyE3,.f.))

			do while se3->(!eof().and.e3_filial+e3_prefixo+e3_num==_cKeyE3)
				if se3->(e3_baiemi=="E".and.reclock(alias(),.f.))
					if _lCarteira
						se3->(dbdelete())
					else
						se3->e3_comis   :=_nParcCom
						se3->e3_base    :=_nParcBase
						se3->e3_miacomp :=SF2->F2_MIACOMP
					endif
					se3->(msunlock())
				endif
				se3->(dbskip(1))
			enddo
		endif
		se3->(dbsetorder(_nOrdE3))

		for _nVez:=1 to len(_vE1)
			se1->(dbgoto(_vE1[_nVez]))
			if se1->(reclock(alias(),.f.))
				se1->e1_valcom1:=_nParcCom +if(_nVez==len(_vE1),_nDifComis,0)
				se1->e1_bascom1:=_nParcBase+if(_nVez==len(_vE1),_nDifBase,0)
				se1->e1_bascom2:=se1->e1_bascom1
				se1->e1_comis1 :=se1->(e1_valcom1/e1_bascom1*100)
				se1->e1_comis2 :=1
				se1->e1_valcom2:=(se1->e1_bascom1*se1->e1_comis2/100)
				se1->e1_mireg  :=sf2->f2_mireg
				se1->e1_midistr:=sf2->f2_midistr
				se1->e1_micodmu:=sf2->f2_micodmu
				se1->e1_micobfi:=sf2->f2_micobfi
				se1->e1_miacomp:=sf2->f2_miacomp
				se1->e1_mibcopv:=sf2->f2_mibcopv
				se1->e1_mibolet:=sf2->f2_mibolet

				se1->(msunlock())
			endif
		next
		se1->(dbsetorder(_nOrdE1))
		se1->(dbgoto(_nRecE1))

		/* Regulariza Rateio de Frete */
		/* Testar                     */

		_nDesFrete := 0
		_nValAcres := 0
		_lGrupo    := .F.
		_nContador := 0
		_nAcresFin := 0
		_nTotDias  := 0
		DbSelectArea('SC5')
		DbSetOrder(1)
		DbSeek(xFilial()+_cPedido)

		DbSelectArea('SD2')
		DbSeek(_cKeyD2)
		Do While !EoF() .and. (D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==_cKeyD2
			If SD2->D2_GRUPO $ GetMV('MV_MIGRUFR')

				DbSelectArea('SC5')
				DbSetOrder(1)
				DbSeek(xFilial()+_cPedido)

				DbSelectArea("SE4")
				DbSetOrder(1)
				DbSeek(xFilial()+SC5->C5_CONDPAG)

				If SE4->E4_ACRESCI == "S"

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+SD2->D2_COD)
					//valter 24/11/11 inicio
					//If SB1->B1_ACRSFIN > 0
					//valter 24/11/11 fim
					If SC5->C5_MIPERCM > 0
						If SE4->e4_tipo=="1"
							_nRetE4:=0
							_vDias:={}
							_cDias1:=alltrim(SE4->e4_cond)
							_cDias:=''
							_cPertence:='0123456789,'
							for _nVez:=1 to len(_cDias1)
								_cDias+=if(substr(_cDias1,_nVez,1)$_cPertence,substr(_cDias1,_nVez,1),'')
							next
							do While right(_cDias,1)==','
								_cDias:=left(_cDias,len(_cDias)-1)
							enddo
							for _nVez:=1 to len(_cDias)
								_cLido:=substr(_cDias,_nVez,1)
								If _nVez==1
									_cDia:=if(_cLido<>",",_cLido,'')
								ElseIf _cLido==','
									If val(_cDia)>0.or._cDia=='00'
										aadd(_vDias,val(_cDia))
										_cDia:=''
									EndIf
								Else
									_cDia+=_cLido
								EndIf
							next
							aadd(_vDias,val(_cDia))
							_nTotdias:=0
							for _nVez:=1 to len(_vDias)
								_nTotDias+=_vDias[_nVez]
							next
							_nTotDias/=len(_vDias)
							// valter 11/09/15
							//iF SB1->B1_GRUPO $ GETMV("MV_MIGRPRO").AND. SC5->C5_MIDTPED <=GETMV("MV_MIDTPRO")
							//valter 09/08/19
							iF SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")

								_ntotDias-=30
							else
								_ntotDias-=0
							endif

							//valter 16/09/15
							if _ntotDias < 0
								_ntotDias = 0
							Endif

						ElseIf AllTrim(SC5->C5_CONDPAG)=="88"
							_vCamposDt:={'C5_DATA1','C5_DATA2','C5_DATA3','C5_DATA4'}
							_nRetE4   :=0

							//valter 09/08/19
							iF SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")
								_nTaxaMes :=val(alltrim(getmv("MV_MIPERCM")))
							Else
								_nTaxaMes :=val(alltrim(getmv("MV_MIPERCP")))
							Endif
							_nTaxaDia :=_nTaxaMes/30
							_vDias    :={}
							for _nVez  :=1 to len(_vCamposDt)
								_dData :='SC5->'+_vCamposDt[_nVez]
								_dData :=&_dData
								If !empty(_dData)
									//aadd(_vDias,_dData-ddatabase)
									aadd(_vDias,_dData-SC5->C5_EMISSAO)
								EndIf
							next
							_nTotdias := 0
							for _nVez := 1 to len(_vDias)
								_nTotDias += _vDias[_nVez]
							next
							_nTotDias     /= len(_vDias)
							// valter 11/09/15
							//iF SB1->B1_GRUPO $ GETMV("MV_MIGRPRO").AND. SC5->C5_MIDTPED <=GETMV("MV_MIDTPRO")
							//valter 09/08/19
							iF SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")

								_ntotDias-=37
							else
								_ntotDias-=7
							endif

							//valter 16/09/15
							if _ntotDias < 0
								_ntotDias = 0
							Endif

							_nTotDias     := If(_nTotDias < 0,0,_nTotDias)
						EndIF
						//valter
						if SA3->A3_MITPTAB=="B"
							_nContador := _nContador + 1
							_nAcresFin := _nAcresFin + ((SC5->C5_MIPERCM/30) * _nTotDias )
						Else
							_nContador := _nContador + 1
							_nAcresFin := _nAcresFin + ROUND(((SC5->C5_MIPERCM/30) * _nTotDias ), 2 )
						Endif

					Endif
				EndIF
			EndIF
			DbSelectArea('SD2')
			DbSkip()
		enddo

		If _nAcresFin > 0
			RecLock('SF2',.F.)
			SF2->F2_FRETE  := SC5->C5_FRETE
			_nAcresFin := _nAcresFin / _nContador
			_nDesFrete :=  SF2->F2_FRETE / ( 1 + (_nAcresFin / 100 ))
			_nValAcres :=  SF2->F2_FRETE - _nDesFrete
			SF2->F2_FRETE   := _nDesFrete
			SF2->F2_DESCONT := 0
			MsUnLock()
			_nValAcres := _nValAcres / _nQtdFrete
		EndIf

		/*/
		DbSelectArea('SC5')
		DbSetOrder(1)
		DbSeek(xFilial()+_cPedido)

		If SC5->C5_ACRSFIN > 0
		_nDesFrete :=  SF2->F2_FRETE / ( 1 + (SC5->C5_ACRSFIN / 100 ))
		_nValAcres :=  SF2->F2_FRETE - _nDesFrete
		RecLock('SF2',.F.)
		SF2->F2_FRETE   := _nDesFrete
		SF2->F2_VALMERC := SF2->F2_VALMERC + _nValAcres
		SF2->F2_DESCONT := 0
		MsUnLock()
		_nValAcres := _nValAcres / _nQtdFrete
		EndIf
		/*/
		DbSelectArea('SD2')
		DbSeek(_cKeyD2)
		_nValSE1  := 0.00
		nSD2BIcm  := 0.00
		_nSD2VIcm := 0.00
		_nSD2FIcm := 0.00
		Do While !EoF() .and. (D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==_cKeyD2
			
			If SD2->D2_GRUPO $ GetMV('MV_MIGRUFR') .AND. !(SD2->D2_TES $('583/584'))
				
				_nPercFrete := (SD2->D2_QUANT / _nQtdFrete)
				_nVlFrete   :=  SF2->F2_FRETE * _nPercFrete
				_lGrupo     := .T.
				RecLock('SD2',.F.)
				SD2->D2_VALACRS := SD2->D2_VALACRS + (_nValAcres * SD2->D2_QUANT )
				SD2->D2_VALFRE  := _nVlFrete
				SD2->D2_DESCON  := 0
				MsUnLock()
				//RecLock('SF2',.F.)
				//SF2->F2_VALMERC := SF2->F2_VALMERC + (_nValAcres * SD2->D2_QUANT)
				//MsUnLock()
			Else
				_nVlFrete       := 0
				_lGrupo         := .F.
				SD2->D2_VALFRE  := 0

				If SD2->D2_TES $('583/584')

				EndIf
			EndIf

			dbSelectArea("SF4")
			MsSeek(xFilial("SF4")+SD2->D2_TES)
			_nRedIcm := If(SF4->F4_BASEICM > 0, SF4->F4_BASEICM / 100,1)

			DbSelectArea('SC5')
			DbSetOrder(1)
			DbSeek(xFilial()+_cPedido)

			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek(xFilial()+SC5->C5_CONDPAG)

			nAliqIcm := If(Empty(SD2->D2_PICM), nAliqIcm,SD2->D2_PICM)

			If SE4->E4_ACRESCI == "S"

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+SD2->D2_COD)

				If SC5->C5_MIPERCM > 0
					If SE4->e4_tipo=="1"
						_nRetE4:=0
						_vDias:={}
						_cDias1:=alltrim(SE4->e4_cond)
						_cDias:=''
						_cPertence:='0123456789,'
						for _nVez:=1 to len(_cDias1)
							_cDias+=if(substr(_cDias1,_nVez,1)$_cPertence,substr(_cDias1,_nVez,1),'')
						next
						do While right(_cDias,1)==','
							_cDias:=left(_cDias,len(_cDias)-1)
						enddo
						for _nVez:=1 to len(_cDias)
							_cLido:=substr(_cDias,_nVez,1)
							If _nVez==1
								_cDia:=if(_cLido<>",",_cLido,'')
							ElseIf _cLido==','
								If val(_cDia)>0.or._cDia=='00'
									aadd(_vDias,val(_cDia))
									_cDia:=''
								EndIf
							Else
								_cDia+=_cLido
							EndIf
						next
						aadd(_vDias,val(_cDia))
						_nTotdias:=0
						for _nVez:=1 to len(_vDias)
							_nTotDias+=_vDias[_nVez]
						next
						_nTotDias/=len(_vDias)
						// valter 11/09/15
						//	iF SB1->B1_GRUPO $ GETMV("MV_MIGRPRO").AND. SC5->C5_MIDTPED <=GETMV("MV_MIDTPRO")

						//valter 09/08/19
						iF SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")
							_ntotDias-=30
						else
							_ntotDias-=0
						endif

						//valter 16/09/15
						if _ntotDias < 0
							_ntotDias = 0
						Endif

					ElseIf AllTrim(SC5->C5_CONDPAG)=="88"
						_vCamposDt:={'C5_DATA1','C5_DATA2','C5_DATA3','C5_DATA4'}
						_nRetE4   :=0
						//valter 09/08/19
						iF SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")
							_nTaxaMes :=val(alltrim(getmv("MV_MIPERCM")))
						Else
							_nTaxaMes :=val(alltrim(getmv("MV_MIPERCP")))
						Endif

						_nTaxaDia :=_nTaxaMes/30
						_vDias    :={}
						for _nVez  :=1 to len(_vCamposDt)
							_dData :='SC5->'+_vCamposDt[_nVez]
							_dData :=&_dData
							If !empty(_dData)
								//aadd(_vDias,_dData-ddatabase)
								aadd(_vDias,_dData-SC5->C5_EMISSAO)
							EndIf
						next
						_nTotdias := 0
						for _nVez := 1 to len(_vDias)
							_nTotDias += _vDias[_nVez]
						next
						_nTotDias     /= len(_vDias)
						// valter 11/09/15
						//	iF SB1->B1_GRUPO $ GETMV("MV_MIGRPRO") .AND. SC5->C5_MIDTPED <=GETMV("MV_MIDTPRO")

						//VALTER 09/08/19
						If SC5->C5_EMISSAO <=GETMV("MV_MIDTPRO")

							_ntotDias-=37
						else
							_ntotDias-=7
						endif

						//valter 16/09/15
						if _ntotDias < 0
							_ntotDias = 0
						Endif

						_nTotDias     := If(_nTotDias < 0,0,_nTotDias)
					Endif

					//valter
					if SA3->A3_MITPTAB=="B"
						_nAcresFin := 0
						_nAcresFin := ((((SC5->C5_MIPERCM/30) * _nTotDias) / 100))

					Else
						_nAcresFin := 0
						_nAcresFin := ((((SC5->C5_MIPERCM/30) * _nTotDias) / 100))
					Endif

					/*
					RecLock('SF2',.F.)
					SF2->F2_VALMERC  := SF2->F2_VALMERC + ((_nAcresFin * SD2->D2_TOTAL))
					SF2->F2_VALFAT   := SF2->F2_VALFAT +  ((_nAcresFin * SD2->D2_TOTAL))
					MsUnLock()
					*/
					dbSelectArea("SF4")
					MsSeek(xFilial("SF4")+SD2->D2_TES)
					_nRedIcm := If(SF4->F4_BASEICM > 0, SF4->F4_BASEICM / 100,1)
					dbSelectArea("SD2")
					_nValSE1   := 0.00
					_nSD2TOTAL := SD2->D2_TOTAL
					//_nSD2BIcm  := SD2->D2_BASEICM
					//_nSD2VIcm  := SD2->D2_VALICM
					RecLock('SD2',.F.)
					SD2->D2_VALACRS := SD2->D2_VALACRS + (NoRound((_nAcresFin * SD2->D2_TOTAL),2))
					SD2->D2_PRCVEN  := ROUND((1+_nAcresFin) * SD2->D2_PRCVEN, 4 )
					IF _lGrupo
						SD2->D2_PRCVEN := Round(SD2->D2_PRCVEN + _nValAcres,4)
					EndIf
					SD2->D2_TOTAL   := Round(SD2->D2_PRCVEN * SD2->D2_QUANT,4)
					//SD2->D2_TOTAL   := ROUND(SD2->D2_TOTAL + ((_nAcresFin * SD2->D2_PRCVEN)* SD2->D2_QUANT),2)

					_nSD2Total := SD2->D2_TOTAL - _nSD2Total
					//SD2->D2_VALACRS := SD2->D2_VALACRS + _nSD2Total
					//SD2->D2_BASEICM := NoRound(SD2->D2_BASEICM+((SD2->D2_VALFRE+_nSD2Total) * _nRedICm),2)
					SD2->D2_BASEICM := Round((SD2->D2_TOTAL+SD2->D2_VALFRE) * _nRedICm,4)
					SD2->D2_VALICM  := Round((SD2->D2_BASEICM * SD2->D2_PICM )/100,4)
					SD2->D2_ICMFRET := Round(((SD2->D2_VALFRE * _nRedICm) * SD2->D2_PICM )/100,4)
					_nValSE1 += _nSD2Total
					nAliqIcm := If(Empty(SD2->D2_PICM), nAliqIcm,SD2->D2_PICM)

					//nSD2BIcm  := SD2->D2_BASEICM - nSD2BIcm
					//_nSD2VIcm  := SD2->D2_VALICM  - _nSD2VIcm

					/*
					IF _lGrupo
					SD2->D2_TOTAL   := ROUND(SD2->D2_TOTAL +  (_nValAcres * SD2->D2_QUANT),2)
					EndIf
					*/
					//SD2->D2_PRCVEN  := ROUND(SD2->D2_TOTAL / SD2->D2_QUANT,2)
									
					MsUnLOck()

					// valter - função duplicada 22/08/2009
					//	RecLock('SF2',.F.)
					//	SF2->F2_VALMERC  := SF2->F2_VALMERC + (_nValAcres * _nQtdFrete)
					//	SF2->F2_VALFAT   := SF2->F2_VALMERC + SF2->F2_FRETE + SF2->F2_VALIPI + SF2->F2_SEGURO
					//	SF2->F2_VALBRUT  := SF2->F2_VALMERC + SF2->F2_FRETE + SF2->F2_VALIPI + SF2->F2_SEGURO
					//   	MsUnLock()

				EndIF
			EndIF
			/*/
			If _nValAcres > 0 .And. _lGrupo
			SD2->D2_TOTAL   := SD2->D2_TOTAL + (_nValAcres * SD2->D2_QUANT)
			SD2->D2_PRCVEN  := SD2->D2_TOTAL / SD2->D2_QUANT
			SD2->D2_VALACRS := SD2->D2_VALACRS + (_nValAcres / SD2->D2_QUANT)
			EndIf
			/*/
			nSD2BIcm  := nSD2BIcm  + SD2->D2_BASEICM
			_nSD2VIcm := _nSD2VIcm + SD2->D2_VALICM
			_nSD2FIcm := _nSD2FIcm + SD2->D2_ICMFRET

			// 29/06/05

			dbSelectArea("SB1")
			MsSeek(xFilial("SB1")+SD2->D2_COD)

			dbSelectArea("SD2")
			RecLock("SD2",.F.)
			SD2->D2_MIFAMIL := SB1->B1_FPCOD
			MsUnLock()

			// 29/06/05

			DbSelectArea('SD2')
			DbSkip()
		enddo
		If nSD2BIcm > 0
			dbSelectArea("SF2")
			RecLock("SF2",.F.)
			//SF2->F2_BASEICM := nSD2BIcm+Round(If(Empty(_nSD2FICM),SF2->F2_FRETE * _nRedIcm,0),2)
			SF2->F2_BASEICM := Round(SF2->(F2_VALBRUT-F2_VALIPI) *  _nRedIcm,2)
			//SF2->F2_VALICM  := _nSD2VIcm+If (Empty(_nSD2FIcm),SF2->F2_ICMFRET,0)
			SF2->F2_VALICM  := Round((SF2->F2_BASEICM * nAliqIcm)/100,2)
			SF2->F2_ICMFRET := If (_nSD2FIcm>0,_nSD2FIcm,SF2->F2_ICMFRET)
			MsUnLock()
		Endif
		
		//---------------------------------------------------------------------------//
		//-- Adiciona valor do frete ao total da nota fiscal dos itens bonificados --//
		//---------------------------------------------------------------------------//
		FreteBon()
		
		If SF2->F2_VALFAT > 0
			_vParcelas:=condicao(SF2->F2_VALFAT,SF2->F2_COND,0,ddatabase)
			_nUltima:=SF2->F2_VALFAT
			for _nVez:=1 to len(_vParcelas)
				if _nVez==len(_vParcelas)
					_vParcelas[_nVez][2]:=_nUltima
				else
					_nUltima-=_vParcelas[_nVez][2]
				endif
			next

			dbSelectArea("SE1")
			aAreaSE1:=GetARea()

			dbSelectArea("SE1")
			dbSetOrder(1)
			dbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)
			nQtdSE1:=1
			While !Eof() .And. E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC
				If E1_CLIENTE+E1_LOJA == SF2->F2_CLIENTE+SF2->F2_LOJA
					RecLock("SE1",.F.)
					SE1->E1_VALOR := _vParcelas[nQtdSe1,2]
					SE1->E1_SALDO := SE1->E1_VALOR
					SE1->E1_VLCRUZ:= SE1->E1_VALOR
					nQtdSe1++
					MsUnLock()
				Endif
				dbSkip()
			End

			RestArea(aAreaSE1)
		Endif
	Else
		// Calcula peso liquido e bruto
		_nRecD2:=sd2->(recno())
		_nOrdD2:=sd2->(indexord())
		sd2->(dbsetorder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		_cKeyD2:=sf2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		_nBaseComis:=_nValComis:=0
		sd2->(dbseek(_cKeyD2))
		_nPesoProd := _nPesoEmbal:=0
		_nQtdFrete := 0
		_nTotItem  := 0
		_cPedido   := ""
		do while sd2->(!eof().and.D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA==_cKeyD2)
			_nPesoProd+=sd2->(d2_quant*posicione("SB1",1,xfilial("SB1")+d2_cod,"B1_PESO"))
			if empty(sd2->d2_micemba).and.;
			posicione("SB1",1,xfilial("SB1")+sd2->(d2_cod+d2_micemba),"B1_PESBRU")>0
				_nPesoEmbal+=sb1->(int(sd2->d2_quant*b1_PESBRU)-(int(sd2->d2_quant*b1_peso)))
				//		posicione("SZU",1,xfilial("SZU")+sd2->(d2_cod+d2_micemba),"ZU_MIPESO")>0
				//		_nPesoEmbal+=szu->(int(sd2->d2_quant/zu_miqtemb)*zu_mipeso)

			endif

			// 29/06/05

			dbSelectArea("SB1")
			MsSeek(xFilial("SB1")+SD2->D2_COD)

			dbSelectArea("SD2")
			RecLock("SD2",.F.)
			SD2->D2_MIFAMIL := SB1->B1_FPCOD
			MsUnLock()

			// 29/06/05

			sd2->(dbskip(1))
		enddo

		// Atualiza os pesos liquido e bruto em SF2
		if sf2->(round(f2_pliqui+f2_pbruto,2)<>round(_nPesoProd*2+_nPesoEmbal,2).and.;
		reclock(alias(),.f.))
			sf2->f2_pliqui:=_nPesoProd
			sf2->f2_pbruto:=_nPesoProd+_nPesoEmbal
			sf2->(msunlock())
		endif

	endif
	RestArea(aAreaLoc)
Return

/*/{Protheus.doc} FreteBon
Adiciona valor de frete dos itens bonificados ao total da nota fiscal
@type Static Function
@author Marcos Natã Santos
@since 15/10/2019
@version 1.0
/*/
Static Function FreteBon()
	Local aAreaSF2 := SF2->( GetArea() )
	Local aAreaSD2 := SD2->( GetArea() )
	Local cSD2Key := SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
	Local nQtdTot := 0
	Local nPercFrt := 0
	Local nVlFrt := 0
	
	SD2->(dbSetOrder(3))
	SD2->(dbGoTop())
	If SD2->( dbSeek(cSD2Key) )
		While SD2->(!EOF()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cSD2Key
			nQtdTot += SD2->D2_QUANT //-- Calcula quantidade total vendida --//
			SD2->(dbSkip())
		EndDo
	EndIf

	SD2->(dbSetOrder(3))
	SD2->(dbGoTop())
	If SD2->( dbSeek(cSD2Key) )
		While SD2->(!EOF()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cSD2Key
			If SD2->D2_TES $ "583/584"
				nPercFrt := (SD2->D2_QUANT / nQtdTot)
				nVlFrt := SF2->F2_FRETE * nPercFrt
				
				SF2->F2_VALFAT += nVlFrt //-- Adiciona valor de frete do item bonificado --//
			EndIf
			SD2->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
Return
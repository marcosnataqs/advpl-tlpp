#include "rwmake.ch"

*-------------------------------------------------------------------------------
user function MSD2460
* Ponto de entrada apos a gravacao do item da nf de saida
*-------------------------------------------------------------------------------    
Local nCusto := 0
// Posiciona Sc6,Sc5
_cPedido:= SD2->D2_PEDIDO
_cNf    := SD2->D2_DOC
_cSerie := SD2->D2_SERIE
_nRecSc5:=sc5->(recno())
_nRecSc6:=sc6->(recno())
_nRecSd2:=sd2->(recno())
_nOrdSd2:=sd2->(indexord())
_nOrdSc5:=sc5->(indexord())
_nOrdSc6:=sc6->(indexord())
sc5->(dbsetorder(1)) //C5_FILIAL+C5_NUM
sc6->(dbsetorder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
sc5->(dbseek(xfilial()+sd2->d2_pedido,.f.))
sc6->(dbseek(xfilial()+sd2->(d2_pedido+d2_itempv+d2_cod),.f.))

//Custo da última compra - Ewerton - 08/12/2014.
If SB8->(dbSeek(xFilial("SB8") + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_LOTECTL))
	nCusto := SB8->B8_MIPREST
EndIf

if sd2->(reclock(alias(),.f.))         
   sd2->d2_mireg  :=sc5->c5_mireg  
   sd2->d2_midistr:=sc5->c5_midistr   
   sd2->d2_micodmu:=sc5->c5_micodmu
   sd2->d2_miacomp:=sc5->c5_miacomp
   sd2->d2_micemba:=sc6->c6_micemba
   sd2->d2_midtped:=sc5->c5_midtped
   sd2->d2_dtdigit:=sc5->c5_emissao
   sd2->d2_micond:=sc5->c5_condpag
   sd2->d2_micpgto=sc5->c5_micpgto
   SD2->D2_MITPFRE := sc5->c5_tpfrete
   SD2->D2_MIPREST := nCusto //Ewerton - 08/12/2014.
   // Verifica se deve abater acrescimo financeiro
//   _lDescAcres:=(posicione("SA3",1,xfilial("SA3")+sc5->c5_vend1,"A3_ACREFIN")=="N")
     _lDescAcres:=posicione("SA3",1,xfilial("SA3")+sc5->c5_vend1,"A3_ACREFIN")

//   sd2->d2_mivcom1:=sd2->((d2_total-if(_lDescAcres,d2_valacrs,0))*d2_comis1)/100
 
 //  sd2->d2_mivcom1:=sd2->((d2_total-  if(_lDescAcres=="N",d2_valacrs*d2_quant,0))  *d2_comis1)/100
   sd2->d2_mivcom1:=sd2->((d2_total-  if(_lDescAcres=="N",d2_valacrs,0))  *d2_comis1)/100  // 20082009 valter
   
   sd2->d2_mivend1:=sc5->c5_vend1
//   sd2->d2_mivend2:=sc5->c5_vend2
   sd2->d2_mivesp :=sc6->c6_mivesp
      //valter 28/01/16 - gravar numero de cabeças suplementadas
      sd2->d2_miccdia :=sb1->b1_consdia
    
  //valter 18/05/2016
  // sd2->d2_micabsu :=(sc6->c6_qtdven*sb1->b1_pesofrt)/sb1->b1_consdia/30
   sd2->d2_micabsu :=(sd2->d2_quant*sb1->b1_pesofrt)/sb1->b1_consdia/30
   
   IF SM0->M0_CODIGO $ "01"
      SD2->D2_MITPCOM := SC6->C6_MITPCOM
   Endif
   sd2->(msunlock())
endif

sc5->(dbsetorder(_nOrdSc5))
sc6->(dbsetorder(_nOrdSc6))
sc5->(dbgoto(_nRecSc5))
sc6->(dbgoto(_nRecSc6))

return

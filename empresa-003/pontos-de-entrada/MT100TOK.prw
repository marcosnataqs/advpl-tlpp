#Include "TOTVS.CH"
#Include "TopConn.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} MT100TOK

LOCALIZAÇÃO : Function A103Tudok()

EM QUE PONTO : Este P.E. é chamado na função A103Tudok()
Pode ser usado para validar a inclusao da NF.

VALIDAÇÃO: Se houver título de comissão em aberto
compara o valor da entrada e exclui o título prefixo COM.

@author Marcos Natã Santos
@since 25/06/2018
@version 12.1.17
@type function
/*/
User Function MT100TOK()
  Local lRet       := .T.
  Local cQry       := ""
  Local aAreaSE2   := SE2->(GetArea())
  Local nPosTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
  Local nTotalNF   := 0
  Local nX         := 0
  Local cHistBaixa := "AUTO BX COMISSAO"
  Local aBaixa     := {}

  Private lMsErroAuto := .F.

  lMT100TOK := .F.

  For nX := 1 To Len(aCols)
    If !aCols[nX][len(aHeader)+1] // Retira linhas deletadas
      nTotalNF += aCols[nX][nPosTotal]
    EndIf
  Next nX

  cQry := "SELECT R_E_C_N_O_ RECNO " + CRLF
  cQry += "FROM SE2010 " + CRLF
  cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
  cQry += "AND E2_PREFIXO = 'COM' " + CRLF
  cQry += "AND E2_TIPO = 'DP' " + CRLF
  cQry += "AND E2_FORNECE = '"+ CA100FOR +"' " + CRLF
  cQry += "AND E2_LOJA = '"+ CLOJA +"' " + CRLF
  cQry += "AND E2_SALDO > 0 " + CRLF
  cQry += "AND ROWNUM = 1 " + CRLF
	cQry := ChangeQuery(cQry)

  MEMOWRITE("C:\Users\marcosnqs\Desktop\querys\bx_comissao.sql",cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMP1"

	TMP1->(dbGoTop())
  COUNT TO NQTREG
  TMP1->(dbGoTop())
  
  If NQTREG > 0
    SE2->( dbSetOrder(1) )
    SE2->( dbGoTo(TMP1->RECNO) )

    If (SE2->E2_SALDO+SE2->E2_IRRF) = nTotalNF
      AADD(aBaixa, {"E2_FILIAL" ,   SE2->E2_FILIAL ,  Nil})
      AADD(aBaixa, {"E2_PREFIXO" ,  SE2->E2_PREFIXO , Nil})
      AADD(aBaixa, {"E2_NUM" ,      SE2->E2_NUM ,     Nil})
      AADD(aBaixa, {"E2_PARCELA" ,  SE2->E2_PARCELA , Nil})
      AADD(aBaixa, {"E2_TIPO" ,     SE2->E2_TIPO ,    Nil})
      AADD(aBaixa, {"E2_FORNECE" ,  SE2->E2_FORNECE , Nil})
      AADD(aBaixa, {"E2_LOJA" ,     SE2->E2_LOJA ,    Nil}) 
      AADD(aBaixa, {"AUTMOTBX" ,    "COMISSAO" ,      Nil})
      AADD(aBaixa, {"AUTBANCO" ,    "" ,              Nil})
      AADD(aBaixa, {"AUTAGENCIA" ,  "" ,              Nil})
      AADD(aBaixa, {"AUTCONTA" ,    "" ,              Nil})
      AADD(aBaixa, {"AUTDTBAIXA" ,  dDataBase ,       Nil}) 
      AADD(aBaixa, {"AUTDTCREDITO", dDataBase ,       Nil})
      AADD(aBaixa, {"AUTHIST" ,     cHistBaixa ,      Nil})
      AADD(aBaixa, {"AUTVLRPG" ,    SE2->E2_SALDO ,   Nil})

      MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)

      If lMsErroAuto
        MostraErro()
        MsgInfo("Por favor realizar a baixa da comissão referente a esta NFS manualmente.")
      Else
        SE2->( dbSetOrder(1) )
        SE2->( dbGoTo(TMP1->RECNO) )

        cQry := "SELECT R_E_C_N_O_ RECNO " + CRLF
        cQry += "FROM " + RetSqlName("SE2") + CRLF
        cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
        cQry += "AND E2_PREFIXO = 'COM' " + CRLF
        cQry += "AND E2_TIPO = 'TX' " + CRLF
        cQry += "AND E2_NATUREZ = 'IRF' " + CRLF
        cQry += "AND E2_FORNECE = 'UNIAO' " + CRLF
        cQry += "AND E2_LOJA = '00' " + CRLF
        cQry += "AND E2_SALDO > 0 " + CRLF
        cQry += "AND E2_NUM = '"+ SE2->E2_NUM +"' " + CRLF
        cQry += "AND ROWNUM = 1 " + CRLF
        cQry := ChangeQuery(cQry)

        MEMOWRITE("C:\Users\marcosnqs\Desktop\querys\bx_irf.sql",cQry)

        If Select("TMP2") > 0
          TMP2->(DbCloseArea())
        EndIf

        TcQuery cQry New Alias "TMP2"

        TMP2->(dbGoTop())
        COUNT TO NQTREG
        TMP2->(dbGoTop())

        SE2->( dbSetOrder(1) )
        SE2->( dbGoTo(TMP2->RECNO) )

        If NQTREG > 0
          aBaixa := {}
          AADD(aBaixa, {"E2_FILIAL" ,   SE2->E2_FILIAL ,  Nil})
          AADD(aBaixa, {"E2_PREFIXO" ,  SE2->E2_PREFIXO , Nil})
          AADD(aBaixa, {"E2_NUM" ,      SE2->E2_NUM ,     Nil})
          AADD(aBaixa, {"E2_PARCELA" ,  SE2->E2_PARCELA , Nil})
          AADD(aBaixa, {"E2_TIPO" ,     SE2->E2_TIPO ,    Nil})
          AADD(aBaixa, {"E2_FORNECE" ,  SE2->E2_FORNECE , Nil})
          AADD(aBaixa, {"E2_LOJA" ,     SE2->E2_LOJA ,    Nil}) 
          AADD(aBaixa, {"AUTMOTBX" ,    "COMISSAO" ,      Nil})
          AADD(aBaixa, {"AUTBANCO" ,    "" ,              Nil})
          AADD(aBaixa, {"AUTAGENCIA" ,  "" ,              Nil})
          AADD(aBaixa, {"AUTCONTA" ,    "" ,              Nil})
          AADD(aBaixa, {"AUTDTBAIXA" ,  dDataBase ,       Nil}) 
          AADD(aBaixa, {"AUTDTCREDITO", dDataBase ,       Nil})
          AADD(aBaixa, {"AUTHIST" ,     cHistBaixa ,      Nil})
          AADD(aBaixa, {"AUTVLRPG" ,    SE2->E2_SALDO ,   Nil})

          lMsErroAuto := .F.

          MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)

          If lMsErroAuto
            MostraErro()
            MsgInfo("Por favor realizar a baixa do IRF referente a esta NFS manualmente.")
          EndIf

          TMP2->(DbCloseArea())
        EndIf
      EndIf
    // Else
    //   lRet := .F.
    //   MsgAlert("Valor total da NFS difere do valor da comissão calculado.";
    //             +" Por favor verificar título de comissão.")
    EndIf
  EndIf

  RestArea(aAreaSE2)
  TMP1->(DbCloseArea())

Return lRet
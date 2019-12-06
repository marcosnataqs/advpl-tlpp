#Include "Protheus.ch"

/*/{Protheus.doc} FA070POS

Ponto de entrada FA070POS executado antes da montagem da tela de baixa do contas a receber.
Variaveis disponiveis: cBanco, cAgencia, cConta, cCheque

@author Marcos Natã Santos
@since 29/08/2018
@version 12.1.17
@type function
/*/
User Function FA070POS()
    CalcMult()
Return

/*/{Protheus.doc} CalcMult

Utiliza rotina padrão para cálculo de multa.
Devido rotina padrão FINA070 não está funcionando corretamente.

@author Marcos Natã Santos
@since 29/08/2018
@version 12.1.17
@type function
/*/
Static Function CalcMult()
    Local cMvJurTipo := SuperGetMv("MV_JURTIPO",,"")
    Local lMulLoj	 := SuperGetMv("MV_LJINTFS", ,.F.)

    If !( SE1->E1_TIPO $ MVRECANT + "|" + MV_CRNEG ) .And. ( cMvJurTipo == "L" .OR. lMulLoj )       	

		  nMulta := LojxRMul( , , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDtCredito , , SE1->E1_MULTA, ,;
		  					 SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1",.T. ) 

	Endif

Return
#Include "Protheus.ch"

/*/{Protheus.doc} FA080POS

Ponto de entrada FA080POS executado antes da montagem da tela de baixa do contas a pagar.
Variaveis disponiveis: cBanco, cAgencia, cConta, cCheque

@author Marcos Natã Santos
@since 03/07/2018
@version 12.1.17
@type function
/*/
User Function FA080POS()

    cMotBx   := "NORMAL"
    cBanco   := "756"
    // cAgencia := "3261G"
    // cConta   := "40160"

Return
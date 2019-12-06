#Include "Protheus.ch"

/*/{Protheus.doc} FA070POS

Ponto de entrada FA070POS executado antes da montagem da tela de baixa do contas a receber.
Variaveis disponiveis: cBanco, cAgencia, cConta, cCheque

@author Marcos Natã Santos
@since 03/07/2018
@version 12.1.17
@type function
/*/
User Function FA070POS()
    //-- Seta motivo da baixa para NORMAL
    cMotBx := "NORMAL"
Return
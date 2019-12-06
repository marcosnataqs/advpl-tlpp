#Include "PROTHEUS.CH"

/*/{Protheus.doc} GP05X001

Pedidos x Faturamentos

@author Marcos Natã Santos
@since 02/10/2018
@version 12.1.17
@type function
/*/
User Function GP05X001()
    Local oGroup
    Local oRadMenu
    Local nRadMenu := 1
    Local oSay
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Pedidos x Faturamentos" FROM 000, 000  TO 200, 350 COLORS 0, 16777215 PIXEL

        @ 038, 010 GROUP oGroup TO 063, 165 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
        @ 046, 017 SAY oSay PROMPT "Relatório para análise de pedidos de venda versus faturamento real." SIZE 145, 014 OF oDlg COLORS 0, 16777215 PIXEL
        @ 072, 010 RADIO oRadMenu VAR nRadMenu ITEMS "Sintético","Analítico" SIZE 092, 015 OF oDlg COLOR 0, 16777215 PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End(), OpcRad(nRadMenu)},{|| oDlg:End()})

Return

/*/{Protheus.doc} OpcRad
OpcRad
@author Marcos Natã Santos
@since 02/10/2018
@version 12.1.17
@type function
/*/
Static Function OpcRad(nRadMenu)

    If nRadMenu = 1
        //-- Relatório Sintético
        U_GP05R007()
    Else
        //-- Relatório Analítico
        U_GP05R006()
    EndIf

Return
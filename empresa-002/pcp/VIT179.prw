#Include "Protheus.ch"

/*/ {Protheus.doc} VIT179

Valida se a OP foi finalizada no EVO pela rotina PM12

Campo: SH6->H6_OP

@type  Function
@author marcos.santos
@since 16/03/2018
@version 1.0
@return lRet, Logico
/*/
User Function VIT179() // U_VIT179()
    lRet := .T.

    If Posicione("SC2", 1, xFilial("SC2") + M->H6_OP, "C2_XFIMEVO") == "N"
        lRet := .F.
        MsgAlert("Fase de pesagem não finalizada no EVOLUTIO. Por favor finalizar na PM12!")
    EndIf

Return lRet
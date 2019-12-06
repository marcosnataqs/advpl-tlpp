#Include "Protheus.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc} VIT216

Job verifica/atualiza parametro MV_CQ

@type  Function
@author marcos.santos
@since 22/03/2018
@version 1.0
/*/
User Function VIT216() // U_VIT216()

    PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' TABLES 'SX6'

        //----------------------------------------
        // Atualiza armazém do CQ para o padrão 98
        //----------------------------------------
        If TrocaCQ()
            WorkFlow()
        EndIf

    RESET ENVIRONMENT

Return

/*/{Protheus.doc} TrocaCQ

@type  Function
@author marcos.santos
@since 22/03/2018
@version 1.0
/*/
Static Function TrocaCQ()
    Local lOk 		:= .F.
    Local cArmCQ 	:= "98"
    Local cMVCQ     := GetMV("MV_CQ")

    If cMVCQ <> '98'
        lOk := .T.

        dbSelectArea("SX6")
        dbSetOrder(1)
        if !( dbSeek(XFilial("SX6")+"MV_XLOCKCQ") .and. RecLock("SX6", .f.) )
            lOk := .F.
        else
            SX6->X6_CONTEUD := "B"
            SX6->X6_CONTSPA := "B"
            SX6->X6_CONTENG := "B"
            SX6->(MsUnLock())
        endif

        if !( dbSeek(XFilial("SX6")+"MV_CQ") .and. RecLock("SX6", .f.) )
            lOk := .F.
        else
            SX6->X6_CONTEUD := cArmCQ
            SX6->X6_CONTSPA := cArmCQ
            SX6->X6_CONTENG := cArmCQ
            SX6->(MsUnLock())       
        endif
    EndIf

Return lOk

/*/{Protheus.doc} WorkFlow

@type  Function
@author marcos.santos
@since 22/03/2018
@version 1.0
/*/
Static Function WorkFlow()
    _cde      :=    GetMV("MV_WFMAIL")
    _cconta   :=    GetMV("MV_WFACC")
    _csenha   :=    GetMV("MV_WFPASSW")
    _cpara    :=    "report_ti@vitamedic.ind.br"
    _ccc      :=    ""
    _ccc      :=    ""
    _ccco     :=    ""

    _cassunto :=    "Ajusta Parametro MV_CQ"

    _cmensagem :=   "<p> Parametro MV_CQ atualizado para 98. </p>"

    _canexos  :=    ""
    _lavisa   :=    .F.

    U_EnvEmail(_cde,_cconta,_csenha,_cpara,_ccc,_ccco,_cassunto,_cmensagem,_canexos,_lavisa)
Return
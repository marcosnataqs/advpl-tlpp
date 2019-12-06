#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*/{Protheus.doc} MT681INC

MT681INC - Inclusão do Movimento de Estoque
É executado após a gravação dos dados na rotina de inclusão do apontamento de produção PCP Mod2.

Realiza apontamento automático para as operações informadas no Cadastro das Operações (SG2)
Campo: G2_XREFAUT

@author Marcos Natã Santos
@since 29/05/2018
@version 12.1.17
@type function
/*/
User Function MT681INC
    Local aRotAuto := {}
    Local cRefAuto := ""
    Local cOperac  := ""
    Local cRecurso := ""

    Private lMsErroAuto := .F.

    cRefAuto := Posicione("SG2", 3, xFilial("SG2")+SH6->H6_PRODUTO+SH6->H6_OPERAC, "G2_XREFAUT")

    If !Empty(cRefAuto)

        cOperac  := Posicione("SG2", 3, xFilial("SG2")+SH6->H6_PRODUTO+cRefAuto, "G2_OPERAC")
        cRecurso := Posicione("SG2", 3, xFilial("SG2")+SH6->H6_PRODUTO+cRefAuto, "G2_RECURSO")

        If !Empty(cOperac) .And. !Empty(cRecurso)

            aRotAuto := { {"H6_OP"		, SH6->H6_OP      		, NIL},;
                        {"H6_PRODUTO" 	, SH6->H6_PRODUTO   	, NIL},;
                        {"H6_OPERAC" 	, cOperac        		, NIL},;
                        {"H6_RECURSO" 	, cRecurso          	, NIL},;
                        {"H6_DTAPONT"  	, dDataBase				, NIL},;
                        {"H6_DATAINI" 	, SH6->H6_DATAINI    	, NIL},;
                        {"H6_HORAINI"	, SH6->H6_HORAINI  		, NIL},;
                        {"H6_DATAFIN"	, SH6->H6_DATAFIN 		, NIL},;
                        {"H6_HORAFIN"	, SH6->H6_HORAFIN  		, NIL},;
                        {"H6_PT"     	, SH6->H6_PT      		, NIL},;
                        {"H6_LOTECTL"  	, SH6->H6_LOTECTL	    , NIL},;
                        {"H6_DTVALID"  	, SH6->H6_DTVALID	    , NIL},;
                        {"H6_XTURNO"  	, SH6->H6_XTURNO	    , NIL},;
                        {"H6_LOCAL"  	, SH6->H6_LOCAL			, NIL},;
                        {"H6_QTDPROD"	, SH6->H6_QTDPROD		, NIL},;
                        {"H6_QTDPERD"	, SH6->H6_QTDPERD		, NIL}}
                        
            MSExecAuto({|x| MATA681(x)}, aRotAuto)

            If lMsErroAuto
                MsgAlert("Falha no Apontamento das Operações Automáticas. Verificar Erro!")
                MostraErro()
            Else
                MsgInfo("Operações Automáticas Apontadas com Sucesso!")
            EndIf

        Else
            MsgAlert("Operação Automática " + AllTrim(cOperac) + " Informada Não Existe!")
        EndIf

    EndIf

Return Nil
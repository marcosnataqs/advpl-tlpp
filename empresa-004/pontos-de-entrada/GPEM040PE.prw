#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#Include 'Topconn.ch'
#Include 'TbiConn.ch'
#Include 'FWMVCDEF.ch'

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} GPEM040

Ponto de Entrada GPEM040

@author Marcos Natã Santos
@since 05/09/2018
@version 12.1.17
@type function
/*/
User Function GPEM040()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local lVerba     := .F.
    Local oObj       := ""
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local cIdGrid    := "GPEM040_MGET"
    Local oModelGrid := Nil
    Local nI         := 0
    Local cVerba     := "601"
    Local aAreaSE2   := SE2->( GetArea() )
    
    Private nOperation  := 0
    
    If aParam <> NIL
        
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
        nOperation := oObj:GetOperation()
        oModelGrid := oObj:GetModel(cIdGrid)
                
        If cIdPonto == 'MODELCOMMITTTS'

            For nI := 1 To oModelGrid:Length()
                oModelGrid:GoLine(nI)
                If .Not. oModelGrid:IsDeleted()
                    If oModelGrid:GetValue("RR_PD") == cVerba
                        lVerba := .T.
                        EXIT
                    EndIf
                EndIf
            Next nI

            If lVerba

                If BSCTIT(SRA->RA_CIC)

                    While TMPSE2->( !EOF() )

                        SE2->( dbSetOrder(1) )
                        If SE2->( dbSeek(TMPSE2->E2_FILIAL+TMPSE2->E2_PREFIXO+TMPSE2->E2_NUM+TMPSE2->E2_PARCELA+TMPSE2->E2_TIPO+TMPSE2->E2_FORNECE+TMPSE2->E2_LOJA) )

                            If nOperation == MODEL_OPERATION_INSERT
                                RecLock("SE2", .F.)
                                SE2->E2_SALDO := 0
                                SE2->E2_BAIXA := Date()
                                SE2->( MsUnlock() )
                            ElseIf nOperation == MODEL_OPERATION_DELETE
                                RecLock("SE2", .F.)
                                SE2->E2_SALDO := SE2->E2_VALOR
                                SE2->E2_BAIXA := STOD(Space(8))
                                SE2->( MsUnlock() )
                            EndIf

                        EndIf

                        TMPSE2->( dbSkip() )
                    EndDo

                    TMPSE2->(DbCloseArea())
                EndIf

            EndIf

        EndIf

    EndIf

    RestArea(aAreaSE2)

Return xRet

/*/{Protheus.doc} BSCTIT

Busca título a pagar pelo CPF

@author Marcos Natã Santos
@since 05/09/2018
@version 12.1.17
@type function
/*/
Static Function BSCTIT(cCPF)
    Local cQry     := ""
    Local nQtReg   := 0
    Local cNaturez := "301010022"
    Local cTipo    := "PA"

    Default cCPF   := ""

    cQry := "SELECT SE2.E2_FILIAL, " + CRLF
	cQry += "   SE2.E2_PREFIXO, " + CRLF
	cQry += "   SE2.E2_NUM, " + CRLF
	cQry += "   SE2.E2_PARCELA, " + CRLF
	cQry += "   SE2.E2_TIPO, " + CRLF
	cQry += "   SE2.E2_FORNECE, " + CRLF
	cQry += "   SE2.E2_LOJA, " + CRLF
	cQry += "   SE2.E2_SALDO " + CRLF
    cQry += "FROM "+ RetSqlName("SE2") +" SE2 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA2") +" SA2 " + CRLF
    cQry += "ON SA2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND SA2.A2_COD = SE2.E2_FORNECE " + CRLF
    cQry += "AND SA2.A2_LOJA = SE2.E2_LOJA " + CRLF
    cQry += "WHERE SE2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND SE2.E2_TIPO = '"+ cTipo +"' " + CRLF
    cQry += "AND SE2.E2_NATUREZ = '"+ cNaturez +"' " + CRLF
    If nOperation == MODEL_OPERATION_INSERT
        cQry += "AND SE2.E2_SALDO > 0 " + CRLF
    EndIf
    cQry += "AND SA2.A2_CGC = '"+ cCPF +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMPSE2") > 0
		TMPSE2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "TMPSE2"
	TMPSE2->(dbGoTop())
    COUNT TO nQtReg
    TMPSE2->(dbGoTop())

    If nQtReg > 0
        Return .T.
    Else
        TMPSE2->(DbCloseArea())
        Return .F.
    EndIf

Return
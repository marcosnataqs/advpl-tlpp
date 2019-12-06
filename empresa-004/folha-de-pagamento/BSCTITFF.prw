#Include 'Protheus.ch'
#Include 'Topconn.ch'

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} BSCTITF

Busca Adiantameno Fundo Fixo para Rescisão

@author Marcos Natã Santos
@since 03/09/2018
@version 12.1.17
@type function
/*/
User Function BSCTITFF(cCPF)
    Local cQry     := ""
    Local nQtReg   := 0
    Local cNaturez := "301010022"
    Local cTipo    := "PA"
    Local nValor   := 0

    Default cCPF   := ""

    cQry := "SELECT SUM(E2_SALDO) SALDO " + CRLF
    cQry += "FROM "+ RetSqlName("SE2") +" SE2 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA2") +" SA2 " + CRLF
    cQry += "ON SA2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND SA2.A2_COD = SE2.E2_FORNECE " + CRLF
    cQry += "AND SA2.A2_LOJA = SE2.E2_LOJA " + CRLF
    cQry += "WHERE SE2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "AND SE2.E2_TIPO = '"+ cTipo +"' " + CRLF
    cQry += "AND SE2.E2_NATUREZ = '"+ cNaturez +"' " + CRLF
    cQry += "AND SE2.E2_SALDO > 0 " + CRLF
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
        nValor := TMPSE2->SALDO
    EndIf

    TMPSE2->(DbCloseArea())

// Return nValor
Return 0

//---------------------------------------------//
//-- Representantes com títulos PA em aberto --//
//---------------------------------------------//
// SELECT SRA.RA_FILIAL FILIAL,
// 	SRA.RA_MAT MATRICULA,
// 	SRA.RA_NOME NOME, 
// 	SRA.RA_CIC CPF, 
// 	SE2.E2_PREFIXO PREF,
// 	SE2.E2_TIPO TIPO,
// 	SE2.E2_NUM TITULO,
// 	SE2.E2_SALDO SALDO
// FROM SE2010 SE2
// INNER JOIN SA2010 SA2
// ON SA2.D_E_L_E_T_ <> '*'
// AND SA2.A2_COD = SE2.E2_FORNECE
// AND SA2.A2_LOJA = SE2.E2_LOJA
// INNER JOIN SRA010 SRA
// ON SRA.D_E_L_E_T_ <> '*'
// AND SRA.RA_CIC = SA2.A2_CGC
// AND SRA.RA_SITFOLH = ' '
// WHERE SE2.D_E_L_E_T_ <> '*'
// AND SE2.E2_NATUREZ = '301010022'
// AND SE2.E2_TIPO = 'PA'
// AND SE2.E2_SALDO > 0;
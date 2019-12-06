#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} VIT265

Busca situação tributária na tabela de "Exceções Fiscais - SF7"

Gatilho: SC6->C6_TES

@type  Function
@author marcos.santos
@since 29/03/2018
@version 1.0
@return cSitTrib, char, Situação Tributária
/*/
User Function VIT265() // U_VIT265()
    cSitTrib := ""

    //----------------------------------------
    // Caso o produto tenha exceção fiscal
    //----------------------------------------
    If !Empty(SB1->B1_GRTRIB)
        cQry := "SELECT F7_ORIGEM ORIGEM "
        cQry += "FROM "+ RetSqlName("SF7") +" "
        cQry += "WHERE D_E_L_E_T_ <> '*' "
        cQry += "    AND F7_FILIAL = '"+ xFilial("SF7") +"' "
        cQry += "    AND F7_GRTRIB = '"+ SB1->B1_GRTRIB +"' "
        cQry += "    AND F7_EST = '"+ SA1->A1_EST +"' "
        cQry := ChangeQuery(cQry)

        If Select("QF7") > 0
		    QF7->(DbCloseArea())
	    EndIf

	    TCQuery cQry New Alias "QF7"

        QF7->(DBGoTop())
        
        // Sit. Trib. deve estar preenchida na SF7
        If !Empty(QF7->ORIGEM)
            cSitTrib := QF7->ORIGEM+SF4->F4_SITTRIB
        Else
            cSitTrib := SUBSTR(SF4->F4_ORIGEM,1,1)+SF4->F4_SITTRIB
        EndIf
    Else
        //--------------------
        // Busca apenas do TES
        //--------------------
        cSitTrib := SUBSTR(SF4->F4_ORIGEM,1,1)+SF4->F4_SITTRIB
    EndIf

Return cSitTrib
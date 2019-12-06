#Include "Protheus.ch"

//+--------------------------------------------------------------------+
//| P.E. | MT680VAL | Autor | Marcos Natã | Data | 03/04/2017 	       |
//+--------------------------------------------------------------------+
//| Descr. | Ponto de entrada no apontamento PCP MOD2 com chamada      |
//|          de workflow.                                              |
//+--------------------------------------------------------------------+
//| Uso    | Qualidade                                                 |
//+--------------------------------------------------------------------+

User Function MT680VAL()
	Local cOperac := POSICIONE("SG2", 3, xFilial("SG2") + M->H6_PRODUTO + M->H6_OPERAC, "G2_OPE_OBR")
	
	// Valida se o apontamento é para o armazém 98 e se o apontamento gera produção
	If M->H6_LOCAL == '98' .And. cOperac == 'S'
		// Envia emails
		U_EMLAPTQL()
	EndIf
Return
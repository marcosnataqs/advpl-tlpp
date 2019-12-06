#Include "Protheus.ch"

//+--------------------------------------------------------------------+
//| P.E. | MT680EST | Autor | Marcos Natã | Data | 27/04/2017 	       |
//+--------------------------------------------------------------------+
//| Descr. | Ponto de entrada no estorno PCP MOD2 com chamada          |
//|          de workflow.                                              |
//+--------------------------------------------------------------------+
//| Uso    | Qualidade                                                 |
//+--------------------------------------------------------------------+

User Function MT680EST()
	Local nAcao := PARAMIXB[1]
	Local lRet  := .T.
	Private cMotivo := Space(Len(SH6->H6_XMTVEST))
	Private aButtons := {}

	If SH6->H6_LOCAL == "98" .And. nAcao = 2
		DEFINE DIALOG oDlg TITLE "Motivo do Estorno" FROM 000,000 TO 200, 400 PIXEL
		@ 035, 035 SAY oSay PROMPT "Motivo: " SIZE 100, 012 OF oDlg PIXEL
		@ 045, 035 MSGET cMotivo SIZE 150, 012 OF oDlg PIXEL VALID NAOVAZIO() PICTURE "@!"
		ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| },, aButtons)

		RecLock("SH6", .F.)
			SH6->H6_XMTVEST := cMotivo
		SH6->(MsUnlock())

		// Chamada de workflow
		U_EMLEST98()
	EndIf

Return lRet
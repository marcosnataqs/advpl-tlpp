#Include "Protheus.ch"
#Include "Topconn.ch"

//+--------------------------------------------------------------------+
//| Rotina | FICHATVO | Autor | Marcos Natã | Data | 19/06/2017        |
//+--------------------------------------------------------------------+
//| Descr. | Exporta ficha de ativos em formato planilha.              |
//+--------------------------------------------------------------------+
//| Uso | Genix Qualicaps                                              |
//+--------------------------------------------------------------------+

User Function FICHATVO()
	Private cPerg := "FICHATVO"
	Private cDoCodigo
	Private cAteCodigo
	Private cDoItem
	Private cAteItem
	Private cDoCC
	Private cAteCC
	Private cDaContabil
	Private cAteContabil
	Private nConBaixa

	AjustaSX1()

	//Tela de Parametros
	Pergunte(cPerg, .T.)

	cDoCodigo := MV_PAR01
	cAteCodigo := MV_PAR02
	cDoItem := MV_PAR03
	cAteItem := MV_PAR04
	cDoCC := MV_PAR05
	cAteCC := MV_PAR06
	cDaContabil := MV_PAR07
	cAteContabil := MV_PAR08
	nConBaixa := MV_PAR09

	ProcExport()

Return

// Seleciona local para exportação
Static Function ProcExport()
	Private targetDir := "C:\Windows\Temp\"

	If !ApOleClient('MsExcel')
		MsgAlert("É necessário instalar o excel antes de exportar este relatório.")
		Return
	EndIf

	Processa({||RunExport()}, "Exportando dados", "Aguarde...")

Return

// Estrutura do arquivo excel
Static Function RunExport()
	Private oExcel := FWMsExcel():New()
	Private oExcelApp := MsExcel():New()
	Private aHead := {}
	Private aRow := {}

	oExcel:AddworkSheet("fichatvo")
	oExcel:AddTable("fichatvo", "Ficha de Ativo")

	HeadEx()
	BodyEx()

	oExcel:Activate()
	oExcel:GetXMLFile(targetDir + "fichatvo.xls")
	oExcelApp:WorkBooks:Open(targetDir + "fichatvo.xls")
	oExcelApp:SetVisible(.T.)

Return

// Cria cabeçalho
Static Function HeadEx()
	aHead := {;
	"COD_BEM",;
	"ITEM",;
	"DESCRICAO",;
	"PLAQUETA",;
	"GRUPO",;
	"ENDERECO",;
	"DT_AQUISICAO",;
	"DT_BAIXA",;
	"COD_PROJETO",;
	"NOTA_FISCAL",;
	"SERIE_NF",;
	"QUANTIDADE",;
	"NUM_PLACA",;
	"CIA_SEGURO",;
	"NUM_APOLICE",;
	"VENC_APOLICE",;
	"TIPO_SEGURO",;
	"COD_FORNEC",;
	"LOJA_FORNEC",;
	"RAZAO_SOCIAL",;
	"HISTOR",;
	"TIPO_ATIVO",;
	"HISTORICO",;
	"CONTA",;
	"CONTA_CORRECAO",;
	"CTA_DESP_DEP",;
	"CTA_DEP_ACUM",;
	"CTA_COR_DEPR",;
	"CC_DESPESA",;
	"DT_IN_DEPREC",;
	"DATA_BAIXA",;
	"QTD_BAIXA",;
	"IND_CALCULO",;
	"VAL_M_AMPLIA",;
	"TX_DEPR",;
	"INDICE",;
	"CORRECAO_MES",;
	"DEPR_MES",;
	"COR_DEP_MES",;
	"COR_EXER",;
	"DEPR_EXER",;
	"COR_DEP_EXER",;
	"COR_ACUM",;
	"DEPR_ACUM",;
	"COR_DEPR_ACUM";
	}

	For i = 1 To Len(aHead)
		If aHead[i] == "VAL_M_AMPLIA" .Or. aHead[i] == "DEPR_ACUM" .Or. aHead[i] == "CORRECAO_MES";
		.Or. aHead[i] == "DEPR_MES" .Or. aHead[i] == "COR_DEP_MES" .Or. aHead[i] == "COR_EXER";
		.Or. aHead[i] == "DEPR_EXER" .Or. aHead[i] == "COR_DEP_EXER" .Or. aHead[i] == "COR_ACUM";
		.Or. aHead[i] == "COR_DEPR_ACUM"
			oExcel:AddColumn("fichatvo", "Ficha de Ativo", aHead[i], 2, 3, .F.)
		ElseIf aHead[i] == "DESCRICAO" .Or. aHead[i] == "RAZAO_SOCIAL" .Or. aHead[i] == "HISTORICO";
		.Or. aHead[i] == "HISTOR"
			oExcel:AddColumn("fichatvo", "Ficha de Ativo", aHead[i], 1, 1, .F.)
		Else
			oExcel:AddColumn("fichatvo", "Ficha de Ativo", aHead[i], 2, 1, .F.)
		EndIf
	Next

Return

// Gera corpo de dados
Static Function BodyEx()
	Local cTmp1
	Local cTmp2
	Private i
	Private cQry := ""
	aRow := Array(Len(aHead))

	cQry +=  "SELECT "
	cQry +=  "  SN1.N1_CBASE                                      COD_BEM, "
	cQry +=  "  SN1.N1_ITEM                                       ITEM, "
	cQry +=  "  SN1.N1_DESCRIC                                    DESCRICAO, "
	cQry +=  "  SN1.N1_CHAPA                                      PLAQUETA, "
	cQry +=  "  SN1.N1_GRUPO                                      GRUPO, "
	cQry +=  "  SN1.N1_LOCAL                                      ENDERECO, "
	cQry +=  "  SN1.N1_AQUISIC                                    DT_AQUISICAO, "
	cQry +=  "  SN1.N1_BAIXA                                      DT_BAIXA, "
	cQry +=  "  SN1.N1_PROJETO                                    COD_PROJETO, "
	cQry +=  "  SN1.N1_NFISCAL                                    NOTA_FISCAL, "
	cQry +=  "  SN1.N1_NSERIE                                     SERIE_NF, "
	cQry +=  "  SN1.N1_QUANTD                                     QUANTIDADE, "
	cQry +=  "  SN1.N1_PLACA                                      NUM_PLACA, "
	cQry +=  "  SN1.N1_CSEGURO                                    CIA_SEGURO, "
	cQry +=  "  SN1.N1_APOLICE                                    NUM_APOLICE, "
	cQry +=  "  SN1.N1_DTVENC                                     VENC_APOLICE, "
	cQry +=  "  SN1.N1_TIPOSEG                                    TIPO_SEGURO, "
	cQry +=  "  SN1.N1_FORNEC                                     COD_FORNEC, "
	cQry +=  "  SN1.N1_LOJA                                       LOJA_FORNEC, "
	cQry +=  "  SA2.A2_NREDUZ                                     RAZAO_SOCIAL, "
	cQry +=  "  SN2.N2_HISTOR                                     HISTOR, "
	cQry +=  "  CONCAT(CONCAT(SN3.N3_TIPO, ' - '), SX5.X5_DESCRI) TIPO_ATIVO, "
	cQry +=  "  SN3.N3_HISTOR                                     HISTORICO, "
	cQry +=  "  SN3.N3_CCONTAB                                    CONTA, "
	cQry +=  "  SN3.N3_CCORREC                                    CONTA_CORRECAO, "
	cQry +=  "  SN3.N3_CDEPREC                                    CTA_DESP_DEP, "
	cQry +=  "  SN3.N3_CCDEPR                                     CTA_DEP_ACUM, "
	cQry +=  "  SN3.N3_CDESP                                      CTA_COR_DEPR, "
	cQry +=  "  SN3.N3_CCUSTO                                     CC_DESPESA, "
	cQry +=  "  SN3.N3_DINDEPR                                    DT_IN_DEPREC, "
	cQry +=  "  SN3.N3_DTBAIXA                                    DATA_BAIXA, "
	cQry +=  "  SN3.N3_PERCBAI                                    QTD_BAIXA, "
	cQry +=  "  SN3.N3_CODIND                                     IND_CALCULO, "
	cQry +=  "  (SN3.N3_VORIG1 + SN3.N3_AMPLIA1)                  VAL_M_AMPLIA, "
	cQry +=  "  SN3.N3_TXDEPR1                                    TX_DEPR, "
	cQry +=  "  SN3.N3_INDICE1                                    INDICE, "
	cQry +=  "  SN3.N3_VRCMES1                                    CORRECAO_MES, "
	cQry +=  "  SN3.N3_VRDMES1                                    DEPR_MES, "
	cQry +=  "  SN3.N3_VRCDM1                                     COR_DEP_MES, "
	cQry +=  "  SN3.N3_VRCBAL1                                    COR_EXER, "
	cQry +=  "  SN3.N3_VRDBAL1                                    DEPR_EXER, "
	cQry +=  "  SN3.N3_VRCDB1                                     COR_DEP_EXER, "
	cQry +=  "  SN3.N3_VRCACM1                                    COR_ACUM, "
	cQry +=  "  SN3.N3_VRDACM1                                    DEPR_ACUM, "
	cQry +=  "  SN3.N3_VRCDA1                                     COR_DEPR_ACUM "
	cQry +=  "FROM SN1010 SN1 "
	cQry +=  "  INNER JOIN SN3010 SN3 ON SN3.N3_CBASE = SN1.N1_CBASE AND SN3.N3_ITEM = SN1.N1_ITEM AND SN3.D_E_L_E_T_ = ' ' "
	cQry +=  "  LEFT JOIN SN2010 SN2 ON SN2.N2_CBASE = SN1.N1_CBASE AND SN2.N2_ITEM = SN1.N1_ITEM AND SN2.D_E_L_E_T_ = ' ' "
	cQry +=  "  LEFT JOIN SA2010 SA2 ON SA2.A2_COD = SN1.N1_FORNEC AND SA2.A2_LOJA = SN1.N1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry +=  "  LEFT JOIN SX5010 SX5 ON SX5.X5_TABELA = 'G1' AND SX5.X5_CHAVE = SN3.N3_TIPO "
	cQry +=  "WHERE SN1.D_E_L_E_T_ = ' ' "
	cQry +=  " AND SN1.N1_CBASE >= '"+cDoCodigo+"' "
	cQry +=  " AND SN1.N1_CBASE <= '"+cAteCodigo+"' "
	cQry +=  " AND SN1.N1_ITEM >= '"+cDoItem+"' "
	cQry +=  " AND SN1.N1_ITEM <= '"+cAteItem+"' "
	cQry +=  " AND SN3.N3_CCUSTO >= '"+cDoCC+"' "
	cQry +=  " AND SN3.N3_CCUSTO <= '"+cAteCC+"' "
	cQry +=  " AND SN3.N3_CCONTAB >= '"+cDaContabil+"' "
	cQry +=  " AND SN3.N3_CCONTAB <= '"+cAteContabil+"' "
	If nConBaixa = 2
		cQry +=  " AND SN3.N3_BAIXA = '0' "
	Else
		cQry +=  " AND SN3.N3_BAIXA IN ('0', '1') "
	EndIf
	cQry +=  "ORDER BY SN1.N1_AQUISIC, SN1.N1_CBASE, SN1.N1_ITEM "

	cQry:= ChangeQuery(cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"

	ProcRegua(QRY->(RecCount()))

	cTmp1 := QRY->COD_BEM
	cTmp2 := QRY->ITEM

	While QRY->(!EOF())
		IncProc(ALLTRIM(QRY->COD_BEM) + " - " + ALLTRIM(QRY->ITEM))
		If cTmp1 = QRY->COD_BEM .And. cTmp2 = QRY->ITEM
			For i := 1 To Len(aHead)
				If (aHead[i] == "DT_AQUISICAO" .Or. aHead[i] == "DT_BAIXA" .Or. aHead[i] == "DT_IN_DEPREC";
				.Or. aHead[i] == "DATA_BAIXA" .Or. aHead[i] == "VENC_APOLICE") .And. Empty(aRow[i])
					aRow[i] :=  DTOC(SToD(&("QRY->" + &("aHead[i]"))))
				Else
					aRow[i] := &("QRY->" + &("aHead[i]"))
				EndIf
			Next
			cTmp1 := QRY->COD_BEM
			cTmp2 := QRY->ITEM
		Else
			oExcel:AddRow("fichatvo", "Ficha de Ativo", aRow)
			aRow := Array(Len(aHead))
			For i := 1 To Len(aHead)
				If (aHead[i] == "DT_AQUISICAO" .Or. aHead[i] == "DT_BAIXA" .Or. aHead[i] == "DT_IN_DEPREC";
				.Or. aHead[i] == "DATA_BAIXA" .Or. aHead[i] == "VENC_APOLICE") .And. Empty(aRow[i])
					aRow[i] :=  DTOC(SToD(&("QRY->" + &("aHead[i]"))))
				Else
					aRow[i] := &("QRY->" + &("aHead[i]"))
				EndIf
			Next
			cTmp1 := QRY->COD_BEM
			cTmp2 := QRY->ITEM
		EndIf
		QRY->(DbSkip())
		If QRY->(EOF())
			oExcel:AddRow("fichatvo", "Ficha de Ativo", aRow)
		EndIf
	EndDo

Return

Static Function AjustaSX1()
	PutSx1(cPerg,"01","Do código?","","","MV_CH1","C",10,0,0,"G","","SN1","","",;
	"MV_PAR01","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"02","Até código?","","","MV_CH2","C",10,0,0,"G","","SN1","","",;
	"MV_PAR02","","","","","","","","","","","","","","","","",{},{},{},"")

	PutSx1(cPerg,"03","Do item?","","","MV_CH3","C",4,0,0,"G","","SN1","","",;
	"MV_PAR03","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"04","Até item?","","","MV_CH3","C",4,0,0,"G","","SN1","","",;
	"MV_PAR04","","","","","","","","","","","","","","","","",{},{},{},"")

	PutSx1(cPerg,"05","Do Centro de Custo?","","","MV_CH5","C",9,0,0,"G","","CTT","","",;
	"MV_PAR05","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"06","Até Centro de Custo?","","","MV_CH6","C",9,0,0,"G","","CTT","","",;
	"MV_PAR06","","","","","","","","","","","","","","","","",{},{},{},"")

	PutSx1(cPerg,"07","Da Conta Contabil?","","","MV_CH7","C",20,0,0,"G","","CT1","","",;
	"MV_PAR07","","","","","","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"08","Até Conta Contabil?","","","MV_CH8","C",20,0,0,"G","","CT1","","",;
	"MV_PAR08","","","","","","","","","","","","","","","","",{},{},{},"")

	PutSx1(cPerg,"09","Considera Baixados?","","","MV_CH9","C",3,0,0,"C","","","","",;
	"MV_PAR09","Sim","","","","Não","","","","","","","","","","","",{},{},{},"")

Return
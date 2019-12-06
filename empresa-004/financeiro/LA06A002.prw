#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} LA06A002

Títulos de clientes do tipo DDE
Calcula vencimento baseado na data de entrega do Frete Brasil

@author 	Marcos Natã Santos
@since 		08/01/2018
@version 	12.1.17
/*/
User Function LA06A002 //-- U_LA06A002()
    Local aEstrut := {}
    Local cArqTmp
    Local cIndice1
    Local cIndice2
    Local cQry
    Local aSeek   := {}
    Local aVenc   := {}
    Local oMark

    AADD(aEstrut,{"E1_OK"      , "C", TamSx3('E1_OK')[1], 0})
    AADD(aEstrut,{"A1_COD"     , "C", TamSx3('A1_COD')[1], 0})
    AADD(aEstrut,{"A1_LOJA"    , "C", TamSx3('A1_LOJA')[1], 0})
    AADD(aEstrut,{"A1_NOME"    , "C", TamSx3('A1_NOME')[1], 0})
    AADD(aEstrut,{"E1_NUM"     , "C", TamSx3('E1_NUM')[1], 0})
    AADD(aEstrut,{"E1_PARCELA" , "C", TamSx3('E1_PARCELA')[1], 0})
    AADD(aEstrut,{"E1_EMISSAO" , "D", TamSx3('E1_EMISSAO')[1], 0})
    AADD(aEstrut,{"E1_VENCREA" , "D", TamSx3('E1_VENCREA')[1], 0})
    AADD(aEstrut,{"ZT_OCORDAT" , "D", TamSx3('ZT_OCORDAT')[1], 0})
    AADD(aEstrut,{"DTCALC"     , "D", 8, 0})
    AADD(aEstrut,{"A1_XFORPG"  , "C", TamSx3('A1_XFORPG')[1], 0})
    AADD(aEstrut,{"E1_VALOR"   , "N", TamSx3('E1_VALOR')[1], 2})
    AADD(aEstrut,{"A1_COND"    , "C", TamSx3('A1_COND')[1], 0})
    AADD(aEstrut,{"E4_DESCRI"  , "C", TamSx3('E4_DESCRI')[1], 0})
    AADD(aEstrut,{"E1_NUMBOR"  , "C", TamSx3('E1_NUMBOR')[1], 0})
    AADD(aEstrut,{"E1_PORTADO" , "C", TamSx3('E1_PORTADO')[1], 0})
    AADD(aEstrut,{"RECNO"      , "N", 22, 0})
        
    cArqTmp  := Criatrab(, .F.)
    cIndTmp1 := CriaTrab(, .F.)
    cIndTmp2 := CriaTrab(, .F.)
    cIndTmp1 := Left(cIndTmp1,5) + Right(cIndTmp1,2) + "A"
    cIndTmp2 := Left(cIndTmp2,5) + Right(cIndTmp2,2) + "B"
    
    MsCreate(cArqTmp, aEstrut, "DBFCDX")
    dbUseArea(.T., "DBFCDX", cArqTmp, "ALIASTMP", .T., .F.)

    IndRegua("ALIASTMP", cIndTmp1, "A1_COD")
    IndRegua("ALIASTMP", cIndTmp2, "E1_NUM")
    
    dbClearIndex()
    dbSetIndex(cIndTmp1+OrdBagExt())
    dbSetIndex(cIndTmp2+OrdBagExt())

    //-- Carrega dados na tabela temporária --//
    Processa( {|| LoadData() }, "Aguarde", "Carregando títulos...", .F.)
    
    dbSelectArea('ALIASTMP')

    //-- Pesquisas --//
    aAdd(aSeek,{"Cliente",  {{"","C",006,0,"Cliente","@!"}} } )
    aAdd(aSeek,{"Título",  {{"","C",009,0,"Título","@!"}} } )

    oMark := FWMarkBrowse():New()
    oMark:SetTemporary(.T.)
    oMark:SetAlias( "ALIASTMP" )
    oMark:SetDescription( "Títulos Clientes DDE" )
    oMark:SetFieldMark( "E1_OK" )
    oMark:SetMenuDef("LA06A002")
    oMark:SetSeek(.T., aSeek)

    oMark:AddLegend("E1_VENCREA <> DTCALC", "BR_VERDE"	  , "Vencimento Pendente")
	oMark:AddLegend("E1_VENCREA == DTCALC", "BR_VERMELHO" , "Vencimento Atualizado")

    oMark:SetColumns( GetColumn("A1_COD",     "Cliente",        02, PesqPict("SA1","A1_COD"),     0, TamSx3('A1_COD')[1], 0) )
    oMark:SetColumns( GetColumn("A1_LOJA",    "Loja",           03, PesqPict("SA1","A1_LOJA"),    0, TamSx3('A1_LOJA')[1], 0) )
    oMark:SetColumns( GetColumn("A1_NOME",    "RzSocial",       04, PesqPict("SA1","A1_NOME"),    1, TamSx3('A1_NOME')[1], 0) )
    oMark:SetColumns( GetColumn("E1_NUM",     "Titulo",         05, PesqPict("SE1","E1_NUM"),     0, TamSx3('E1_NUM')[1], 0) )
    oMark:SetColumns( GetColumn("E1_PARCELA", "Parcela",        06, PesqPict("SE1","E1_PARCELA"), 0, TamSx3('E1_PARCELA')[1], 0) )
    oMark:SetColumns( GetColumn("E1_EMISSAO", "Emissao",        07, PesqPict("SE1","E1_EMISSAO"), 0, TamSx3('E1_EMISSAO')[1], 0) )
    oMark:SetColumns( GetColumn("E1_VENCREA", "Vencto Real",    08, PesqPict("SE1","E1_VENCREA"), 0, TamSx3('E1_VENCREA')[1], 0) )
    oMark:SetColumns( GetColumn("ZT_OCORDAT", "Dt Entrega",     09, PesqPict("SZT","ZT_OCORDAT"), 0, TamSx3('ZT_OCORDAT')[1], 0) )
    oMark:SetColumns( GetColumn("DTCALC",     "Venc Calculado", 10, "", 0, 8, 0) )
    oMark:SetColumns( GetColumn("A1_XFORPG",  "Forma Pag",      11, PesqPict("SA1","A1_XFORPG"),    0, TamSx3('A1_XFORPG')[1], 0) )
    oMark:SetColumns( GetColumn("E1_VALOR",   "Valor",          12, PesqPict("SE1","E1_VALOR"),   0, TamSx3('E1_VALOR')[1], 2) )
    oMark:SetColumns( GetColumn("A1_COND",    "Cond Pag",       13, PesqPict("SA1","A1_COND"),    0, TamSx3('A1_COND')[1], 0) )
    oMark:SetColumns( GetColumn("E4_DESCRI",  "Cond Desc",      14, PesqPict("SE4","E4_DESCRI"),  1, TamSx3('E4_DESCRI')[1], 0) )
    oMark:SetColumns( GetColumn("E1_NUMBOR",  "Bordero",      14, PesqPict("SE4","E1_NUMBOR"),  1, TamSx3('E1_NUMBOR')[1], 0) )
    oMark:SetColumns( GetColumn("E1_PORTADO",  "Portador",     14, PesqPict("SE4","E1_PORTADO"),  1, TamSx3('E1_PORTADO')[1], 0) )
    oMark:SetColumns( GetColumn("RECNO",      "Recno",          15, "@X",   2, 22, 0) )

    oMark:Activate()
        
    DBSelectArea('ALIASTMP')
    DbCloseArea()
    MsErase(cArqTmp+GetDBExtension(),,"DBFCDX")
Return

/*/{Protheus.doc} MenuDef
@author 	Marcos Natã Santos
@since 		09/01/2019
@version 	12.1.17
@return 	aRotina
@Obs 		Marcos Natã Santos - Construção
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title "Processar" ACTION "StaticCall( LA06A002, ProcMarked )" OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

/*/{Protheus.doc} GetColumn
Função para criar as colunas do grid
@author 	Marcos Natã Santos
@since 		09/01/2018
@version 	12.1.17
@return     aColumn
/*/
Static Function GetColumn(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
    Local aColumn
    Local bData 	:= {||}
    Default nAlign 	:= 1
    Default nSize 	:= 20
    Default nDecimal:= 0
    Default nArrData:= 0  
        
    If nArrData > 0
        bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
    EndIf
    
    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
    aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

/*/{Protheus.doc} LoadData
@author 	Marcos Natã Santos
@since 		09/01/2018
@version 	12.1.17
/*/
Static Function LoadData
    Local cQry
    Local nRank

    cQry := "SELECT SE1.E1_EMISSAO, " + CRLF
    cQry += "    SE1.E1_NUM, " + CRLF
    cQry += "    SE1.E1_PARCELA, " + CRLF
    cQry += "    SA1.A1_COD, " + CRLF
    cQry += "    SA1.A1_LOJA, " + CRLF
    cQry += "    SA1.A1_NOME, " + CRLF
    cQry += "    SA1.A1_XFORPG, " + CRLF
    cQry += "    SE1.E1_VALOR, " + CRLF
    cQry += "    SA1.A1_COND, " + CRLF
    cQry += "    SE4.E4_DESCRI, " + CRLF
    cQry += "    SZT.ZT_OCORDAT, " + CRLF
    cQry += "    SE1.E1_VENCREA, " + CRLF
    cQry += "    SE1.E1_NUMBOR, " + CRLF
    cQry += "    SE1.E1_PORTADO, " + CRLF
    cQry += "    SE1.R_E_C_N_O_ " + CRLF
    //-- RANK para buscar parcela correta no array aVenc --//
    // cQry += "    RANK() OVER (PARTITION BY SE1.E1_NUM ORDER BY SE1.E1_VENCTO) RANK " + CRLF
    cQry += "FROM "+ RetSqlName("SE1") +" SE1 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 " + CRLF
    cQry += "    ON SA1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SA1.A1_COD = SE1.E1_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
    cQry += "    AND SA1.A1_SEDDE = 'S' " + CRLF //-- Cliente tipo DDE
    cQry += "INNER JOIN "+ RetSqlName("SF2") +" SF2 " + CRLF
    cQry += "    ON SF2.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"' " + CRLF
    cQry += "    AND SF2.F2_DOC = SE1.E1_NUM " + CRLF
    cQry += "    AND SF2.F2_CLIENTE = SE1.E1_CLIENTE " + CRLF
    cQry += "    AND SF2.F2_LOJA = SE1.E1_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SZT") +" SZT " + CRLF
    cQry += "    ON SZT.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SZT.ZT_FILIAL = '"+ xFilial("SZT") +"' " + CRLF
    cQry += "    AND SZT.ZT_CHAVENF = SF2.F2_CHVNFE " + CRLF
    //-- ZT_CODIGO = Status de entrega Frete Brasil
    cQry += "    AND SZT.ZT_CODIGO IN ('01','02','24','31') " + CRLF
    cQry += "LEFT JOIN "+ RetSqlName("SE4") +" SE4 " + CRLF
    cQry += "    ON SE4.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE4.E4_FILIAL = '"+ xFilial("SE4") +"' " + CRLF
    cQry += "    AND SE4.E4_CODIGO = SA1.A1_COND " + CRLF
    cQry += "WHERE SE1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SE1.E1_FILIAL = '"+ xFilial("SE1") +"' " + CRLF
    cQry += "    AND SE1.E1_SALDO = SE1.E1_VALOR " + CRLF
    cQry += "    AND SE1.E1_TIPO = 'NF' " + CRLF
    //-- E1_NATUREZ = Apenas VENDA PRODUTO ACABADO
    cQry += "    AND SE1.E1_NATUREZ = '101010001' " + CRLF
    // cQry += "    AND SE1.E1_VENCREA >= '"+ DTOS(Date()) +"' " + CRLF
    cQry += "    AND SE1.E1_XFRTBRZ = ' ' " + CRLF
    cQry += "ORDER BY SE1.E1_CLIENTE, SE1.E1_EMISSAO, SE1.E1_NUM, SE1.E1_PARCELA " + CRLF
    
    TCQUERY cQry New Alias "TMPSE1"
    
    ProcRegua(TMPSE1->(RecCount()))
    TMPSE1->(dbGoTop())
    While TMPSE1->(!EOF())
        //-- Condicao(nValTot,cCond,nValIpi,dData0,nValSolid)
        aVenc := Condicao(TMPSE1->E1_VALOR, TMPSE1->A1_COND, 0, STOD(TMPSE1->ZT_OCORDAT), 0)
        IncProc()

        nRank := SlcParcela(TMPSE1->E1_NUM,TMPSE1->E1_PARCELA,TMPSE1->A1_COD,TMPSE1->A1_LOJA)

        If nRank <= Len(aVenc)
            If STOD(TMPSE1->E1_VENCREA) <> DataValida(aVenc[nRank, 1], .T.)
                RecLock('ALIASTMP', .T.)
                ALIASTMP->E1_OK      := Space(2)
                ALIASTMP->E1_EMISSAO := STOD(TMPSE1->E1_EMISSAO)
                ALIASTMP->E1_NUM     := TMPSE1->E1_NUM
                ALIASTMP->E1_PARCELA := TMPSE1->E1_PARCELA
                ALIASTMP->A1_COD     := TMPSE1->A1_COD
                ALIASTMP->A1_LOJA    := TMPSE1->A1_LOJA
                ALIASTMP->A1_NOME    := TMPSE1->A1_NOME
                ALIASTMP->A1_XFORPG  := TMPSE1->A1_XFORPG
                ALIASTMP->E1_VALOR   := TMPSE1->E1_VALOR
                ALIASTMP->A1_COND    := TMPSE1->A1_COND
                ALIASTMP->E4_DESCRI  := TMPSE1->E4_DESCRI
                ALIASTMP->ZT_OCORDAT := STOD(TMPSE1->ZT_OCORDAT)
                ALIASTMP->E1_VENCREA := STOD(TMPSE1->E1_VENCREA)
                ALIASTMP->DTCALC     := DataValida(aVenc[nRank, 1], .T.)
                ALIASTMP->E1_NUMBOR  := TMPSE1->E1_NUMBOR
                ALIASTMP->E1_PORTADO := TMPSE1->E1_PORTADO
                ALIASTMP->RECNO      := TMPSE1->R_E_C_N_O_
                ALIASTMP->(MsUnLock())
            EndIf
        EndIf

        TMPSE1->(dbSkip())
    EndDo

    TMPSE1->(DBCloseArea())

Return

/*/{Protheus.doc} ProcMarked
Processa título marcados
@author 	Marcos Natã Santos
@since 		09/01/2018
@version 	12.1.17
/*/
Static Function ProcMarked
    Local nCount := 0

    ALIASTMP->( dbSetOrder(1) )
    ALIASTMP->( dbGoTop() )
    While ALIASTMP->( !EOF() )
        If !Empty(ALIASTMP->E1_OK)
            If ALIASTMP->E1_VENCREA <> ALIASTMP->DTCALC
                If UpdateSE1(ALIASTMP->RECNO, ALIASTMP->DTCALC)
                    GeraOcorCnab(ALIASTMP->RECNO, ALIASTMP->E1_VENCREA)

                    RecLock("ALIASTMP", .F.)
                    ALIASTMP->E1_VENCREA := ALIASTMP->DTCALC
                    ALIASTMP->( MsUnLock() )
                EndIf
            EndIf
            nCount++
        EndIf
        ALIASTMP->( dbSkip() )
    EndDo

    If nCount == 0
        MsgAlert("Selecione ao menos um item.")
        Return
    Else
        MsgInfo("Itens processados com sucesso.")
    EndIf

Return

/*/{Protheus.doc} UpdateSE1
@author 	Marcos Natã Santos
@since 		09/01/2018
@version 	12.1.17
/*/
Static Function UpdateSE1(nRecno,dDtEntrega)
    Local aAreaSE1 := SE1->( GetArea() )
    Local lOk      := .F.

    SE1->( dbGoTo(nRecno) )
    If SE1->( !EOF() )
        RecLock("SE1", .F.)
        SE1->E1_VENCREA := dDtEntrega
        SE1->E1_XFRTBRZ := "S" //-- Indica no titulo alteracao do vencimento
        SE1->( MsUnlock() )
        lOK := .T.
    EndIf

    RestArea(aAreaSE1)

Return lOk

/*/{Protheus.doc} SlcParcela

Seleciona título/parcela rankeando as parcelas

@author 	Marcos Natã Santos
@since 		31/01/2019
@version 	12.1.17
/*/
Static Function SlcParcela(cNum,cParcela,cCodCli,cLoja)
    Local nRank := 1
    Local cQry  := ""

    cQry := "SELECT E1_NUM NUM, " + CRLF
    cQry += "    E1_PARCELA PARCELA, " + CRLF
    cQry += "    RANK() OVER (PARTITION BY E1_NUM ORDER BY E1_VENCTO) RANK " + CRLF
    cQry += "FROM " + RetSqlName("SE1") + CRLF
    cQry += "WHERE D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND E1_FILIAL = '"+ xFilial("SE1") +"' " + CRLF
    cQry += "    AND E1_TIPO = 'NF' " + CRLF
    cQry += "    AND E1_NATUREZ = '101010001' " + CRLF
    cQry += "    AND E1_NUM = '"+ cNum +"' " + CRLF
    cQry += "    AND E1_CLIENTE = '"+ cCodCli +"' " + CRLF
    cQry += "    AND E1_LOJA = '"+ cLoja +"' " + CRLF
    cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	EndIf

    TCQUERY cQry New Alias "TMP1"

    While TMP1->(!EOF())
        If TMP1->NUM == cNum .And. TMP1->PARCELA == cParcela
            nRank := TMP1->RANK
        EndIf 
        TMP1->( dbSkip() )
    EndDo

    TMP1->(DbCloseArea())

Return nRank

/*/{Protheus.doc} GeraOcorCnab

Gera ocorrência Cnab
Tabela FI2 - Ocorrências Cnab

@author 	Marcos Natã Santos
@since 		31/01/2019
@version 	12.1.17
/*/
Static Function GeraOcorCnab(nRecno,dVencAnt)
    Local aAreaSE1 := SE1->( GetArea() )
    Local aAreaFI2 := FI2->( GetArea() )
    
    SE1->( dbGoTo(nRecno) )
    If !Empty(SE1->E1_IDCNAB) .And. !Empty(SE1->E1_NUMBOR)
        If MsgYesNo("Deseja gerar ocorrência Cnab?", "Ocorrência Cnab")
            RecLock("FI2", .T.)
            FI2->FI2_FILIAL := xFilial("FI2")
            FI2->FI2_OCORR  := "06"
            FI2->FI2_DESCOC := "ALTERACAO DE VENCIME"
            FI2->FI2_PREFIX := SE1->E1_PREFIXO
            FI2->FI2_TITULO := SE1->E1_NUM
            FI2->FI2_PARCEL := SE1->E1_PARCELA
            FI2->FI2_TIPO   := SE1->E1_TIPO
            FI2->FI2_CODCLI := SE1->E1_CLIENTE
            FI2->FI2_LOJCLI := SE1->E1_LOJA
            FI2->FI2_GERADO := "2" //-- 1=Gerado 2=Nao Gerado
            FI2->FI2_NUMBOR := SE1->E1_NUMBOR
            FI2->FI2_CARTEI := "1"
            FI2->FI2_DTOCOR := Date()
            FI2->FI2_VALANT := DTOC(dVencAnt)
            FI2->FI2_VALNOV := DTOC(SE1->E1_VENCREA)
            FI2->FI2_CAMPO  := "E1_VENCREA"
            FI2->FI2_TIPCPO := "D"
            FI2->( MsUnLock() )
        EndIf
    EndIf

    RestArea(aAreaSE1)
    RestArea(aAreaFI2)

Return
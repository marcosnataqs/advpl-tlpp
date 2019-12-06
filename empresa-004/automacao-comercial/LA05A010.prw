#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} LA05A010

Cria pedido de venda no Centro de Distribuição (Filial 0101)

@author 	Marcos Natã Santos
@since 		06/05/2019
@version 	12.1.17
/*/
User Function LA05A010(cPedFab,cCodCli,cLoja)
    Local aCab      := {}
    Local aItens    := {}
    Local nSaldoEst := 0
    Local cQry
    Local nQtdReg

    Private cEmpCD    := SUPERGETMV("XX_EMPARM", .F., "01")
    Private cFilCD    := SUPERGETMV("XX_FILARM", .F., "0101")
    Private cOper     := SUPERGETMV("XX_TOREMA", .F., "52")
    Private cCodCliCD := SubStr(SUPERGETMV("XX_CLICD", .F., "00000101"),1,6)
    Private cLojaCD   := SubStr(SUPERGETMV("XX_CLICD", .F., "00000101"),7,2)
    Private cArmCD    := SUPERGETMV("XX_ARMCD", .F., "05")

    cQry := "SELECT DISTINCT SC6.C6_XPEDPAI, " + CRLF
	cQry += "    SC6.C6_NUM, " + CRLF
	cQry += "    SC6.C6_CLI, " + CRLF
	cQry += "    SC6.C6_LOJA, " + CRLF
	cQry += "    SC5.C5_XNOMEE, " + CRLF
	cQry += "    SC5.C5_VEND1, " + CRLF
	cQry += "    SC5.C5_MENNOTA, " + CRLF
	cQry += "    SC5.C5_XMSG, " + CRLF
	cQry += "    SC5.C5_MENPAD, " + CRLF
	cQry += "    SC5.C5_XOBS, " + CRLF
	cQry += "    SC5.C5_XORIGEN, " + CRLF
    cQry += "    SC5.C5_FECENT, " + CRLF
	cQry += "    SC5.C5_SUGENT, " + CRLF
	cQry += "    SC5.C5_TRANSP, " + CRLF
    cQry += "    SC5.C5_XPRICLI, " + CRLF
	cQry += "    SC5.C5_XLDTIME, " + CRLF
    cQry += "    SC6.C6_ITEMPC, " + CRLF
	cQry += "    SC6.C6_NUMPCOM, " + CRLF
	cQry += "    SC6.C6_ITEM, " + CRLF
	cQry += "    SC6.C6_PRODUTO, " + CRLF
	cQry += "    SC6.C6_QTDVEN, " + CRLF
	cQry += "    SC6.C6_PRCVEN, " + CRLF
	cQry += "    SB2.B2_CM1 " + CRLF
    cQry += "FROM "+ RetSqlName("SC6") +" SC6 " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC5") +" SC5 " + CRLF
	cQry += "    ON SC5.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "    AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' " + CRLF
	cQry += "    AND SC5.C5_NUM = SC6.C6_NUM " + CRLF
	cQry += "    AND SC5.C5_CLIENTE = SC6.C6_CLI " + CRLF
	cQry += "    AND SC5.C5_LOJACLI = SC6.C6_LOJA " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SC9") +" SC9 " + CRLF
    cQry += "    ON SC9.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC9.C9_FILIAL = '"+ xFilial("SC9") +"' " + CRLF
    cQry += "    AND SC9.C9_CLIENTE = SC6.C6_CLI " + CRLF
    cQry += "    AND SC9.C9_LOJA = SC6.C6_LOJA " + CRLF
    cQry += "    AND SC9.C9_PEDIDO = SC6.C6_NUM " + CRLF
    cQry += "INNER JOIN "+ RetSqlName("SB2") +" SB2 " + CRLF
	cQry += "    ON SB2.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "    AND SB2.B2_FILIAL = '0101' " + CRLF //-- Centro Distribuição --//
	cQry += "    AND SB2.B2_LOCAL = '05' " + CRLF //-- Padrão --//
	cQry += "    AND SB2.B2_COD = SC6.C6_PRODUTO " + CRLF
    cQry += "WHERE SC6.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "    AND SC6.C6_FILIAL = '"+ xFilial("SC6") +"' " + CRLF
    cQry += "    AND SC6.C6_NUM = '"+ cPedFab +"' " + CRLF
    cQry += "    AND SC6.C6_CLI = '"+ cCodCli +"' " + CRLF
	cQry += "    AND SC6.C6_LOJA = '"+ cLoja +"' " + CRLF
    cQry += "    AND SC9.C9_BLEST = '02' " + CRLF
    cQry += "    AND SC9.C9_BLCRED = ' ' " + CRLF
    cQry := ChangeQuery(cQry)

    If Select("PEDFAB") > 0
        PEDFAB->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "PEDFAB"

    PEDFAB->(dbGoTop())
    COUNT TO nQtdReg
    PEDFAB->(dbGoTop())

    //-- Cabeçalho do pedido --//
    PutPvHead(@aCab)

    If nQtdReg > 0
        While PEDFAB->( !EOF() )

            //-- Verifica saldo no Centro Distribuição --//
            nSaldoEst := StaticCall( LA05A001 , ValSaldoEstoque ,;
					AllTrim(PEDFAB->C6_PRODUTO) , PEDFAB->C6_CLI , PEDFAB->C6_LOJA, PEDFAB->C6_QTDVEN )
            
            If nSaldoEst >= PEDFAB->C6_QTDVEN
                //-- Itens do pedido --//
                PutPvItem(@aItens)
            Else
                aCab   := {}
                aItens := {}
                Help(Nil,Nil,"LA05A010",Nil,"Saldos em estoque insuficientes no Centro de Distribuição.",1,0,Nil,Nil,Nil,Nil,Nil,;
                    {"Favor excluir pedido fábrica gerado e verificar saldos disponíveis no Auto Pedidos de Venda."})
                Exit
            EndIf

            PEDFAB->( dbSkip() )
        EndDo

        If Len(aCab) > 0 .And. Len(aItens) > 0
            IncPedidoCD(aCab, aItens)
        EndIf
    EndIf

    PEDFAB->(DbCloseArea())
Return

/*/{Protheus.doc} PutPvHead

Cabeçalho Pedido de Venda

@author 	Marcos Natã Santos
@since 		06/05/2019
@version 	12.1.17
/*/
Static Function PutPvHead(aCab)
    Local cPvOri := PEDFAB->C6_NUM + cFilCD + cFilAnt

    aAdd( aCab, { "C5_FILIAL",   cFilCD,                  NIL } )
    aAdd( aCab, { "C5_EMISSAO",  Date(),                  NIL } )
    aAdd( aCab, { "C5_TIPO",     "N",                     NIL } )
    aAdd( aCab, { "C5_CLIENTE",  cCodCliCD,               NIL } )
    aAdd( aCab, { "C5_LOJACLI",  cLojaCD,                 NIL } )
    aAdd( aCab, { "C5_CLIENT",   cCodCliCD,               NIL } )
    aAdd( aCab, { "C5_LOJAENT",  cLojaCD,                 NIL } )
    aAdd( aCab, { "C5_XNOMEE",   PEDFAB->C5_XNOMEE,       NIL } )
    aAdd( aCab, { "C5_VEND1",    PEDFAB->C5_VEND1,        NIL } )
    aAdd( aCab, { "C5_MENNOTA",  PEDFAB->C5_MENNOTA,      NIL } )
    aAdd( aCab, { "C5_XMSG",     PEDFAB->C5_XMSG,         NIL } )
    aAdd( aCab, { "C5_MENPAD",   PEDFAB->C5_MENPAD,       NIL } )
    aAdd( aCab, { "C5_XOBS",     PEDFAB->C5_XOBS,         NIL } )
    aAdd( aCab, { "C5_XORIGEN",  PEDFAB->C5_XORIGEN,      NIL } )
    aAdd( aCab, { "C5_FECENT",   STOD(PEDFAB->C5_FECENT), NIL } )
    aAdd( aCab, { "C5_SUGENT",   STOD(PEDFAB->C5_SUGENT), NIL } )
    aAdd( aCab, { "C5_TRANSP",   PEDFAB->C5_TRANSP,       NIL } )
    aAdd( aCab, { "C5_XCLIVEN",  PEDFAB->C6_CLI,          NIL } )
    aAdd( aCab, { "C5_XLJVEN",   PEDFAB->C6_LOJA,         NIL } )
    aAdd( aCab, { "C5_XPRICLI",  PEDFAB->C5_XPRICLI,      NIL } )
    aAdd( aCab, { "C5_XLDTIME",  PEDFAB->C5_XLDTIME,      NIL } )
    aAdd( aCab, { "C5_CONDPAG",  "100",                   NIL } )
    aAdd( aCab, { "C5_XOPER",    cOper,                   NIL } )
    aAdd( aCab, { "C5_XORIGCD",  "N",                     NIL } )
    aAdd( aCab, { "C5_LIBEROK",  Space(1),                NIL } )
    aAdd( aCab, { "C5_XJASEP",   "N",                     NIL } )
    aAdd( aCab, { "C5_XBLQSEP",  "N",                     NIL } )
    aAdd( aCab, { "C5_XPEDPAI",  PEDFAB->C6_XPEDPAI,      NIL } )
    aAdd( aCab, { "C5_XPVORI",   cPvOri,                  NIL } )

Return

/*/{Protheus.doc} PutPvItem

Itens Pedido de Venda

@author 	Marcos Natã Santos
@since 		06/05/2019
@version 	12.1.17
/*/
Static Function PutPvItem(aItens)
	Local aItem := {}
    
    aAdd( aItem , { "C6_FILIAL",   cFilCD,                  NIL } )
    aAdd( aItem , { "C6_ITEM",     PEDFAB->C6_ITEM,         NIL } )
    aAdd( aItem , { "C6_PRODUTO",  PEDFAB->C6_PRODUTO,      NIL } )
    aAdd( aItem , { "C6_QTDVEN",   PEDFAB->C6_QTDVEN,       NIL } )
    aAdd( aItem , { "C6_QTDLIB",   PEDFAB->C6_QTDVEN,       NIL } )
    aAdd( aItem , { "C6_PRCVEN",   PEDFAB->B2_CM1,          NIL } )
    aAdd( aItem , { "C6_PRUNIT",   PEDFAB->C6_PRCVEN,       NIL } )
    aAdd( aItem , { "C6_XPRCVEN",  PEDFAB->C6_PRCVEN,       NIL } )
    aAdd( aItem , { "C6_LOCAL",    cArmCD,                  NIL } )
    aAdd( aItem , { "C6_OPER",     cOper,                   NIL } )
    aAdd( aItem , { "C6_CLASFIS",  "041",                   NIL } )
    aAdd( aItem , { "C6_XBLQSEP",  "N",                     NIL } )
    aAdd( aItem , { "C6_ITEMPC",   PEDFAB->C6_ITEMPC,       NIL } )
    aAdd( aItem , { "C6_NUMPCOM",  PEDFAB->C6_NUMPCOM,      NIL } )
    aAdd( aItem , { "C6_ENTREG",   STOD(PEDFAB->C5_FECENT), NIL } )
    aAdd( aItem , { "C6_SUGENTR",  STOD(PEDFAB->C5_SUGENT), NIL } )
    aAdd( aItem , { "C6_XPEDPAI",  PEDFAB->C6_XPEDPAI,      NIL } )
    aAdd( aItens , aItem )

Return

/*/{Protheus.doc} IncPedidoCD

Inclui pedido de venda (ExecAuto MATA410 )
Centro de Distribuição Linea

@author 	Marcos Natã Santos
@since 		06/05/2019
@version 	12.1.17
/*/
Static Function IncPedidoCD(aCab,aItens)
    Local aAreaSC5 := SC5->( GetArea() )
    Local cAuxEmp  := cEmpAnt
    Local cAuxFil  := cFilAnt
    Local cPvFab   := SubStr(aCab[Len(aCab)][2],1,6)
    Local cPvCD    := ""

    Private lMsErroAuto := .F.

    cEmpAnt := cEmpCD
    cFilAnt := cFilCD

    MSExecAuto({|x,y,z| MATA410(x,y,z) }, aCab, aItens, 3)
    If !lMsErroAuto
        cPvCD := SC5->C5_NUM

        SC5->( dbSetOrder(1) )
        If SC5->( dbSeek(cAuxFil + cPvFab) )
            RecLock("SC5", .F.)
            SC5->C5_XPVCD := cPvCD
            SC5->( MsUnlock() )
        EndIf

        //-- Atualiza tabela SC9 --//
        SC9PVCD(cAuxFil,cPvFab,cPvCD)

        U_PutLgInt(cPvFab, cAuxFil, "01", UsrRetName(__cUserID), "Pedido C.D. "+ cPvCD +" Incluído com Sucesso!",, "S")

        //--------------------------------------------//
        //-- Envia pedido para cotação Frete Brasil --//
        //--------------------------------------------//
        //-- SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI
        If SuperGetMV("MV_XAUTOFB", .F., .F.)
            U_LA05A004(cPvCD, cCodCliCD, cLojaCD)
        EndIf
    Else
        MostraErro()
        U_PutLgInt(cPvFab, cAuxFil, "01", UsrRetName(__cUserID), "Falha na Inclusão do Pedido C.D.!",, "N")
    EndIf

    cEmpAnt := cAuxEmp
    cFilAnt := cAuxFil

    RestArea(aAreaSC5)

Return

/*/{Protheus.doc} SC9PVCD

Atualiza campo C9_XPVCD com pedido do C.D.

@author 	Marcos Natã Santos
@since 		08/05/2019
@version 	12.1.17
/*/
Static Function SC9PVCD(cFilFab,cPvFab,cPvCD)
    Local aAreaSC9 := SC9->( GetArea() )

    PEDFAB->(dbGoTop())
    SC9->( dbSetOrder(1) )
    While PEDFAB->( !EOF() )
        If SC9->( dbSeek(cFilFab + cPvFab + PEDFAB->C6_ITEM) )
            RecLock("SC9", .F.)
            SC9->C9_XPVCD := cPvCD
            SC9->( MsUnlock() )
        EndIf
        PEDFAB->( dbSkip() )
    EndDo

    RestArea(aAreaSC9)
Return
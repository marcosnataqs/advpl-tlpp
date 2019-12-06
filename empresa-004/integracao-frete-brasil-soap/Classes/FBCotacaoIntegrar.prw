#Include "Protheus.ch"

Class FBCotacaoIntegrar

    Data cGuidProcess
    Data nLinha
    Data cRegistroChamada
    Data cCodProcess
    Data cMsgProcess
    Data cMsgProcessCmp
    Data cFlErro
    Data nCotCdItem
    Data dCotDtAprovacao
    Data cUsrAprovacao
    Data cTransCpnj
    Data cTransRzSocial
    Data cCotRef
    Data cNotaNum
    Data cNotaSerie
    Data nCotValNota
    Data cCotTpCalculo
    Data nCotPrazo
    Data dCotPrevEntreg
    Data nCotFrete
    Data nCotFreteValor
    Data nCotFretePeso
    Data nCotPedagio
    Data nCotDespacho
    Data nCotCAT
    Data nCotADEME
    Data nCotOutrosVal
    Data nCotCubagem
    Data nCotSeguro
    Data nCotAdicional
    Data nCotGRIS
    Data nCotTDA
    Data nCotBaseICMS
    Data nCotBaseAliqICMS
    Data nCotICMS
    Data nCotBaseISS
    Data nCotAliqISS
    Data nCotISS

    Method New() Constructor
    Method ConvertDate(cDateTime)
    Method FormatIBGECod(cCod)

EndClass

Method New() Class FBCotacaoIntegrar

    ::cGuidProcess     := ""
    ::nLinha           := 0
    ::cRegistroChamada := ""
    ::cCodProcess      := ""
    ::cMsgProcess      := ""
    ::cMsgProcessCmp   := ""
    ::cFlErro          := ""
    ::nCotCdItem       := 0
    ::dCotDtAprovacao  := Space(8)
    ::cUsrAprovacao    := ""
    ::cTransCpnj       := ""
    ::cTransRzSocial   := ""
    ::cCotRef          := ""
    ::cNotaNum         := ""
    ::cNotaSerie       := ""
    ::nCotValNota      := 0
    ::cCotTpCalculo    := ""
    ::nCotPrazo        := 0
    ::dCotPrevEntreg   := Space(8)
    ::nCotFrete        := 0
    ::nCotFreteValor   := 0
    ::nCotFretePeso    := 0
    ::nCotPedagio      := 0
    ::nCotDespacho     := 0
    ::nCotCAT          := 0
    ::nCotADEME        := 0
    ::nCotOutrosVal    := 0
    ::nCotCubagem      := 0
    ::nCotSeguro       := 0
    ::nCotAdicional    := 0
    ::nCotGRIS         := 0
    ::nCotTDA          := 0
    ::nCotBaseICMS     := 0
    ::nCotBaseAliqICMS := 0
    ::nCotICMS         := 0
    ::nCotBaseISS      := 0
    ::nCotAliqISS      := 0
    ::nCotISS          := 0

Return Self

Method ConvertDate(cDateTime) Class FBCotacaoIntegrar
    Local cDate, dDate
    cDate := SubStr(cDateTime,1,4) + SubStr(cDateTime,6,2) + SubStr(cDateTime,9,2)
    dDate := STOD(cDate)
Return dDate

Static Function IBGECodState(cState)
    Local aStates   := {}
    Local cCodState := ""
    Local oHash     := Nil
    Local oVal      := Nil

    Default cState := ""

    //-------------------------//
    //-- Códigos padrão IBGE --//
    //-------------------------//
    aAdd(aStates, {'RO', '11'})
    aAdd(aStates, {'AC', '12'})
    aAdd(aStates, {'AM', '13'})
    aAdd(aStates, {'RR', '14'})
    aAdd(aStates, {'PA', '15'})
    aAdd(aStates, {'AP', '16'})
    aAdd(aStates, {'TO', '17'})
    aAdd(aStates, {'MA', '21'})
    aAdd(aStates, {'PI', '22'})
    aAdd(aStates, {'CE', '23'})
    aAdd(aStates, {'RN', '24'})
    aAdd(aStates, {'PB', '25'})
    aAdd(aStates, {'PE', '26'})
    aAdd(aStates, {'AL', '27'})
    aAdd(aStates, {'SE', '28'})
    aAdd(aStates, {'BA', '29'})
    aAdd(aStates, {'MG', '31'})
    aAdd(aStates, {'ES', '32'})
    aAdd(aStates, {'RJ', '33'})
    aAdd(aStates, {'SP', '35'})
    aAdd(aStates, {'PR', '41'})
    aAdd(aStates, {'SC', '42'})
    aAdd(aStates, {'RS', '43'})
    aAdd(aStates, {'MS', '50'})
    aAdd(aStates, {'MT', '51'})
    aAdd(aStates, {'GO', '52'})
    aAdd(aStates, {'DF', '53'})

    oHash := AToHM(aStates)

    If HMGet(oHash, cState, oVal)
        cCodState := oVal[1,2]
    EndIf

Return cCodState

Method FormatIBGECod(cState,cCityCod) Class FBCotacaoIntegrar
    Local cCodFormatted
    cCodFormatted := AllTrim(IBGECodState(cState) + cCityCod)
Return cCodFormatted
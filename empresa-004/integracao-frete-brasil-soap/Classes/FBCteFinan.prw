#Include "Protheus.ch"

Class FBCteFinan

    Data cTransportador
    Data cDoc
    Data cSerie
    Data dEmissao
    Data cChvNfe
    Data nTotalFrete
    Data nBaseIcm
    Data nValorIcm
    Data nAliqIcm
    Data cOrigIBGE
    Data cDestIBGE

    Method New() Constructor

EndClass

Method New() Class FBCteFinan

    ::cTransportador := ""
    ::cDoc           := ""
    ::cSerie         := ""
    ::dEmissao       := STOD(Space(8))
    ::cChvNfe        := ""
    ::nTotalFrete    := 0
    ::nBaseIcm       := 0
    ::nValorIcm      := 0
    ::nAliqIcm       := 0

Return Self
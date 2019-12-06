#Include "Protheus.ch"

Class FBCotacao

    Data cTransportador
    Data cTransRzSocial
    Data cContrato
    Data cOrcSelecionado
    Data cAprovacao
    Data cAprovaUsuario
    Data cMelhorPreco
    Data cMelhorPrazo

    Method New() Constructor

EndClass

Method New() Class FBCotacao

    ::cTransportador  := ""
    ::cTransRzSocial  := ""
    ::cContrato       := ""
    ::cOrcSelecionado := ""
    ::cAprovacao      := Space(8)
    ::cAprovaUsuario  := ""
    ::cMelhorPreco    := ""
    ::cMelhorPrazo    := ""

Return Self
#Include "Protheus.ch"

Class FBOcorrencia

    Data cRegistro
    Data cRemetente
    Data cRemRazaoSocial
    Data cNumero
    Data cSerie
    Data cChave
    Data dEmissao
    Data cTransportador
    Data cTranRazaoSocial
    Data cCodigo
    Data cDescricao
    Data dOcorreuData
    Data cOcorreuHora
    Data cResponsavelNome
    Data cResponsavelDocumento
    Data cResponsavelContato
    Data dSolucaoData
    Data cSolucaoHora
    Data cSolucaoResponsavel
    Data dCancelaData

    Method New() Constructor

EndClass

Method New() Class FBOcorrencia

    ::cRegistro             := ""
    ::cRemetente            := ""
    ::cRemRazaoSocial       := ""
    ::cNumero               := ""
    ::cSerie                := ""
    ::cChave                := ""
    ::dEmissao              := Space(8)
    ::cTransportador        := ""
    ::cTranRazaoSocial      := ""
    ::cCodigo               := ""
    ::cDescricao            := ""
    ::dOcorreuData          := Space(8)
    ::cOcorreuHora          := ""
    ::cResponsavelNome      := ""
    ::cResponsavelDocumento := ""
    ::cResponsavelContato   := ""
    ::dSolucaoData          := Space(8)
    ::cSolucaoHora          := ""
    ::cSolucaoResponsavel   := ""
    ::dCancelaData          := Space(8)

Return Self
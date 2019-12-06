#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} MYMT930
Esta rotina tem a finalidade de executar automaticamente o MATA930, Reprocessamento dos Livros Fiscais.
@type User Function
@author Marcos Natã Santos
@since 21/10/2019
@version 1.0
@param cData, char
@param nTipo, numeric
@param cNF, char
@param cSerie, char
@param cCodCli, char
@param cLoja, char
/*/
User Function MYMT930(cData, nTipo, cNF, cSerie, cCodCli, cLoja)
    Local aParam  := Array(11)
    Local lRotAut := .T.

    aParam[1]  := cData //Data Inicial
    aParam[2]  := cData //Data Final
    aParam[3]  := nTipo //1-Entrada 2-Saída 3-Ambos
    aParam[4]  := cNF //Nota Fiscal Incial
    aParam[5]  := cNF //Nota Fiscal Final
    aParam[6]  := cSerie //Série Incial
    aParam[7]  := cSerie //Série Final
    aParam[8]  := cCodCli //Cli/For Inicial
    aParam[9]  := cCodCli //Cli/For Final
    aParam[10] := cLoja //Loja Incial
    aParam[11] := cLoja //Loja Final

    MATA930(lRotAut, aParam)

Return
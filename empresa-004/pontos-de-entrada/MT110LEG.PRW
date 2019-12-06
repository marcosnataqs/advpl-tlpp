#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function MT110COR
LOCALIZAÇÃO : Function A110Legenda - Função da dialog de legendas da
mbrowse da Solicitação de Compras.
EM QUE PONTO : Após a montagem do Array contendo as legendas da
tabela SC1 e antes da execução da função Brwlegenda que monta a
dialog com as legendas, utilizado para adicionar legendas na dialog.
Deve ser usado em conjunto com o ponto MT110COR que manipula o Array
com as regras para apresentação das cores dos estatus na Mbrowse.
@type  Function
@author Marcos Natã Santos
@since 11/06/2019
@version 12.1.17
@return aLeg, Array, Legenda de cores
/*/
User Function MT110LEG()
    Local aLeg := PARAMIXB[1]
    aAdd(aLeg, {"BR_CANCEL","Solicitação Inconsistente(Leadtime e Lote Mínimo)"}) //Bloqueado por PCO
Return aLeg

/*/{Protheus.doc} User Function MT110COR
LOCALIZAÇÃO  : Function MATA110 - Função da Solicitação de Compras.
EM QUE PONTO : No inicio da rotina MATA110 e antes da execução
da Mbrowse da SC,utilizado para manipular o Array com as regras
para apresentação das cores dos estatus na Mbrowse.
@type  Function
@author Marcos Natã Santos
@since 11/06/2019
@version 12.1.17
@return aCores, Array, Regras de cores
/*/
User Function MT110COR()
    Local aCores     := PARAMIXB[1]
    Local cRegraLead := "C1_XLEADTI > 0 .And. C1_XLEADTI < DateDiffDay(C1_EMISSAO,C1_DATPRF) .And. C1_QUJE <> C1_QUANT .And. C1_RESIDUO = ' '"
    aAdd(aCores, { "", ""})
    aIns(aCores, 1)
    aCores[1] := { cRegraLead, "BR_CANCEL"} //Bloqueado por PCO
Return aCores
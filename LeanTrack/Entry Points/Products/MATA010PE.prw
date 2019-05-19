#Include "Protheus.ch"
#include "parmtype.ch"
#Include "FwMVCDef.ch"

/*/{Protheus.doc} ITEM

Ponto de Entrada MATA010 (Cadastro de Produtos)

@author 	Marcos Natã Santos
@since 		15/05/2019
@version 	12.1.17
@return 	xRet
@Obs 		O ID do modelo da dados da rotina MATA010 é ITEM
/*/
User Function ITEM
    Local aParam     := PARAMIXB
    Local oModel     := FwModelActive()
    Local xRet       := .T.
    Local oObj       := ""
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local nOpc       := 0

    Local cProdTipos := SuperGetMv("LT_PRODTPS", .F., "PA")
    Local cProduto   := ""
    Local cDescricao := ""
    Local cUnidade   := ""
    Local cTipo      := ""
 
 
    If aParam <> NIL
        
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
        
        nOpc := oObj:GetOperation()
        
        If cIdPonto == "MODELCOMMITTTS"
            If oModel <> NIL

                cProduto   := AllTrim( oModel:GetModel("SB1MASTER"):GetValue("B1_COD") )
                cDescricao := AllTrim( oModel:GetModel("SB1MASTER"):GetValue("B1_DESC") )
                cUnidade   := AllTrim( oModel:GetModel("SB1MASTER"):GetValue("B1_UM") )
                cTipo      := AllTrim( oModel:GetModel("SB1MASTER"):GetValue("B1_TIPO") )

                If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
                    // If cTipo $ cProdTipos
                        U_LTPostProd(cProduto, cDescricao, cUnidade)
                    // EndIf
                EndIf

            EndIf
        EndIf

    EndIf
 
Return xRet
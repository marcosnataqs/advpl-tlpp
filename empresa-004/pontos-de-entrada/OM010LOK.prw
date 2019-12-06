/*/{Protheus.doc} OM010LOK
Tabela de Preços
Ponto de entrada executado somente se a validação dos itens estiver ok,
permitindo ao usuário interferir na validação.
@type  User Function
@author Marcos Natã Santos
@since 12/07/2019
@version 1.0
@return lRet, logical, Validação de linha
/*/
User Function OM010LOK
    Local lRet := .T.
    Local oModel := FWModelActive()
    Local oModelDA1 := oModel:GetModel("DA1DETAIL")
    Local nX := 0
    Local cMsg := ""

    For nX := 1 To oModelDA1:length()
        oModelDA1:GoLine(nX)
        If oModelDA1:IsInserted() .Or. oModelDA1:IsUpdated()
            lRet := DuplProd(oModelDA1, AllTrim( oModelDA1:GetValue("DA1_CODPRO")))
            If !lRet
                cMsg := "Produto " + AllTrim(oModelDA1:GetValue("DA1_CODPRO")) + " já existe na tabela."
                Help('',1,,"Produto em duplicidade",cMsg,1,0)
                Exit
            EndIf
        EndIf
    Next nX

Return lRet

/*/{Protheus.doc} DuplProd
Valida duplicidade de item na tabela de preço
@type  Static Function
@author Marcos Natã Santos
@since 12/07/2019
@version 1.0
@param cProduto, char, Código do produto
@return lRet, logic, Validação
/*/
Static Function DuplProd(oModel, cProduto)
    Local lRet := .T.
    Local nX := 0
    Local nDupl := 0

    For nX := 1 To oModel:length()
        oModel:GoLine(nX)
        If AllTrim(oModel:GetValue("DA1_CODPRO")) == cProduto
            nDupl++
        EndIf
    Next nX

    If nDupl > 1
        lRet := .F.
    EndIf
Return lRet
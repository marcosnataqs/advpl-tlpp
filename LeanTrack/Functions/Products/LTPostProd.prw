#Include "Protheus.ch"
#Include "RestFul.ch"

/*/{Protheus.doc} LTPostProd

DESCRIÇÃO DOS PARÂMETROS
------------------------------------------------------------------
Campo	  | Regras	     |  Detalhes                             |
------------------------------------------------------------------
descricao | obrigatório	 |  Descrição do produto                 |
codigo	  | obrigatório	 |  Identificador único do produto       |
unidade	  | obrigatório	 |  Unidade do produto ex: (Caixa 15 und)|
------------------------------------------------------------------


DESCRIÇÃO DA RESPOSTA
---------------------------------------------
Campo	            | Detalhes              |
---------------------------------------------
total_count	        | Quantidade Processada |
rows_created_count	| Quantidade Cadastrada |
rows_updated_count	| Quantidade Atualizada |
rows_failed_count   | Quantidade que Falhou |
rows_failed	        | Lista de falhas       |
---------------------------------------------

@author 	Marcos Natã Santos
@since 		15/05/2019
@version 	12.1.17
/*/
User Function LTPostProd(cProduto, cDescricao, cUnidade)
	Local cUrl        := SuperGetMv("LT_URL", .F., "https://demo.leantrack.com.br")
	Local oLeanTrack  := FWRest():New(cUrl)
	Local cAuthToken  := U_LTGetToken()
	Local aHeader     := {}
	Local cJSON       := ""

	Default cProduto   := ""
	Default cDescricao := ""
	Default cUnidade   := ""
	
	aAdd(aHeader, "Content-Type: application/json")
	aAdd(aHeader, "Authorization: Bearer " + cAuthToken)

	cJSON := '[{"descricao": "'+ cDescricao +'","codigo": "'+ cProduto +'","unidade": "'+ cUnidade +'"}]'
	
	oLeanTrack:setPath("/api/integration/products")
	oLeanTrack:SetPostParams(cJSON)

	If oLeanTrack:Post(aHeader)
		ConOut("LEANTRACK /api/integration/products -> Produto" + cProduto + " atualizado com sucesso!")
	Else
		ConOut("LEANTRACK /api/integration/products -> Produto" + cProduto + " erro na atualização! -> " + AllTrim(oLeanTrack:cResult))
	EndIf

Return
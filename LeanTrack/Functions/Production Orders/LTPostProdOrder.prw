#Include "Protheus.ch"
#Include "RestFul.ch"

/*/{Protheus.doc} LTPostProdOrder

DESCRIÇÃO DOS PARÂMETROS
-----------------------------------------------------------------------------------------------
Campo	    |  Regras	                            |  Detalhes                               |
-----------------------------------------------------------------------------------------------
produto	    |  obrigatório, deve existir no banco	|  Código de identificação do produto     |
codigo	    |  obrigatório, deve ser único	        |  Identificador da OP                    |
quantidade  |  obrigatório, númerico	            |  Quantidade a ser produzida             |
dt_inicio	|  obrigatório, formato: d/m/Y H:i:s	|  Data de início da OP                   |
dt_fim	    |  opcional, formato: d/m/Y H:i:s	    |  Data de fim da OP                      |
dt_emissao  |  obrigatório, formato: d/m/Y H:i:s	|  Data de Emissão da OP                  |
equipamento |  opcional, deve existir no banco	    |  Código de identificação do equipamento |
-----------------------------------------------------------------------------------------------

DESCRIÇÃO DA RESPOSTA
----------------------------------------------
Campo	            |  Detalhes              |
----------------------------------------------
total_count	        |  Quantidade Processada |
rows_created_count	|  Quantidade Cadastrada |
rows_updated_count	|  Quantidade Atualizada |
rows_failed_count	|  Quantidade que Falhou |
rows_failed	        |  Lista de falhas       |
----------------------------------------------

@author 	Marcos Natã Santos
@since 		19/05/2019
@version 	12.1.17
/*/
User Function LTPostProdOrder

Return
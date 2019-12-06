#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} F200VAR

O ponto de entrada F200VAR do CNAB a receber sera executado apos carregar
os dados do arquivo de recepcao bancaria e sera utilizado para alterar os dados recebidos.

@author 	Marcos Natã Santos
@since 		25/02/2019
@version 	12.1.17
@Obs 		Ponto de Entrada
/*/
User Function F200VAR

	//-- Banco Santander --//
	//-- Valor do desconto não vem informado corretamente no retorno do banco --//
	//-- Atribuição do valor do abatimento como desconto --//
	If cBanco == "033"
		nDescont := nAbatim
		xBuffer  := Space(85)
		aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, /*cMotBan*/, xBuffer, dDtVc })
	EndIf

Return
#Include "Protheus.ch"

/*/{Protheus.doc} MT097EST

LOCALIZAÇÃO : Function A097ESTORNA - Função da Dialog que estorna a
liberação dos documentos com alçada. 

EM QUE PONTO : O ponto se encontra no inicio da função A097ESTORNA,
não passa parametros e não envia retorno, usado conforme necessidades do 
usuario para diversos fins.

@author 	Marcos Natã Santos
@since 		09/08/2018
@version 	12.1.17
@return 	Nil
/*/
User Function MT097EST()
    Local lPROCPR  := SuperGetMV("MV_XPROPR",.F.,.T.)

    /*
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³ Customização Titulo Provisorio           				  º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	*/
	If lPROCPR
        //-- Exclui Títulos Provisórios
		MsgRun("Verificando Titulos Provisorio ","Aguarde...", {||U_ExclTitPR(SCR->CR_FILIAL,AllTrim(SCR->CR_NUM),'PR ',,)})
	EndIf

Return
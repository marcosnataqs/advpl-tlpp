#Include 'Protheus.ch'

/*/{Protheus.doc} F200DB1

O ponto de entrada F200DB1 utilizado no CNAB a receber, será executado
após gravar as despesas bancarias no SE5.

@type Function
@author Marcos Natã Santos
@since 24/08/2018
@version 12.1.17
/*/
User Function F200DB1
    Local cBanco, cAgencia, cConta
    Local cBcos := SuperGetMv("MV_XITAUBC", .F., "341/342/343/344/345/346/347/348")

    //-------------------------//
    //-- Banco Itau Corrente --//
    //-------------------------//
    cBanco   := SuperGetMv("MV_XBCITAU", .F., "341")
    cAgencia := SuperGetMv("MV_XAGITAU", .F., "0208")
    cConta   := SuperGetMv("MV_XCTITAU", .F., "05175")

    //-------------------------------------------------//
    //-- Envia tarifas para conta corrente principal --//
    //-------------------------------------------------//
    If SE5->E5_BANCO $ cBcos

        RecLock("SE5", .F.)
            SE5->E5_BANCO   := cBanco
            SE5->E5_AGENCIA := cAgencia
            SE5->E5_CONTA   := cConta
        SE5->( MsUnlock() )

    EndIf

Return Nil
#Include "Protheus.ch"

/*/{Protheus.doc} VIT348

Gerar sequencial numérico para cnab Sicoob "Nosso Número"

@type  Function
@author marcos.santos
@since 10/04/2018
@version 1.0
@return cNumero, caracter, Sequencial Numerico para Sicoob
/*/
User Function VIT348() // U_VIT348()
    Local nNumero := Val(SEE->EE_FAXATU)
    Local cNumCoop := "3064"
    Local cNumCliente := "125130"
    Local cNumero := ""
    Local cParcela := "01" // Parcela única
    Local cModalidade := "01" // Na capa
    Local cTpForm := "4" // A4 sem envelopamento

    If nNumero == Nil .Or. Empty(nNumero)
        nNumero := 1
    Else
        nNumero++
    EndIf
    
    RecLock("SEE")
    Replace EE_FAXATU With StrZero(nNumero,12)
    SEE->(MsUnlock())

    cNumero := cNumCoop + PadL(cNumCliente,10,"0") + StrZero(nNumero,7)

    cNumero := StrZero(nNumero,9) + Mod11(cNumero) + cParcela + cModalidade + cTpForm

    RecLock("SE1")
    Replace E1_NUMBCO With PadL(SubStr(cNumero,1,10),12,"0")
    SE1->(MsUnlock())

Return cNumero

/*/{Protheus.doc} Mod11

Calcula DV para Nosso Número Sicoob

@type  Function
@author marcos.santos
@since 12/04/2018
@version 1.0
@param cNossoNum, caracter
@return cDigVfr, caracter, Digito Verificador
/*/
Static Function Mod11(cNossoNum)
    Local cDigVfr   := ""
    Local aMult     := Array(4)
    Local nSoma     := 0
    Local nResto    := 0
    Local nCont     := 1

    aMult := {3,1,9,7}

    For nX := 1 To Len(cNossoNum)
        nSoma += (Val(SubStr(cNossoNum,nX,1)) * aMult[nCont])
        If nCont = 4
            nCont := 1
        Else
            nCont++
        EndIf
    Next

    nResto := nSoma % 11

    If nResto = 0 .Or. nResto = 1
        cDigVfr := "0"
    Else
        cDigVfr := Str(11 - nResto)
    EndIf

Return AllTrim(cDigVfr)
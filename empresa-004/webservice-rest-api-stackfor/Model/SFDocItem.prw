#Include "PROTHEUS.CH"

/*/{Protheus.doc} SFDocItem
Classe SFDocItem
@type  User Function
@author Marcos Natã Santos
@since 03/12/2019
@version 1.0
/*/
User Function SFDocItem
Return

Class SFDocItem

    Data item as character
    Data productCod as character
    Data productDesc as character
    Data quant as numeric
    Data unit as character
    Data price as numeric
    Data total as numeric

    Method New(item, productCod, productDesc, quant, unit, price, total) Constructor

EndClass

Method New(item, productCod, productDesc, quant, unit, price, total) Class SFDocItem

    ::item := item
    ::productCod := productCod
    ::productDesc := productDesc
    ::quant := quant
    ::unit := unit
    ::price := price
    ::total := total

Return Self
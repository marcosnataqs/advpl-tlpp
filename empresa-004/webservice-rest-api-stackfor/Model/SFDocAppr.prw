#Include "PROTHEUS.CH"

/*/{Protheus.doc} SFDocAppr
Classe SFDocAppr
@type  User Function
@author Marcos Natã Santos
@since 25/11/2019
@version 1.0
/*/
User Function SFDocAppr
Return

Class SFDocAppr

    Data filial as character
    Data issueDate as date
    Data order as character
    Data level as character
    Data value as numeric

    Method New(filial, issueDate, order, level, value) Constructor

EndClass

Method New(filial, issueDate, order, level, value) Class SFDocAppr

    ::filial := filial
    ::issueDate := issueDate
    ::order := order
    ::level := level
    ::value := value

Return Self
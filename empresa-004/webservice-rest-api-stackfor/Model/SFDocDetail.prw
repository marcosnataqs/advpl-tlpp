#Include "PROTHEUS.CH"

/*/{Protheus.doc} SFDocDetail
Classe SFDocDetail
@type  User Function
@author Marcos Natã Santos
@since 03/12/2019
@version 1.0
/*/
User Function SFDocDetail
Return

Class SFDocDetail

    Data order as character
    Data issueDate as date
    Data provider as character
    Data payTerm as character
    Data currency as character
    Data totOrder as numeric
    Data items as array

    Method New(order, issueDate, provider, payTerm, currency, totOrder, items) Constructor

EndClass

Method New(order, issueDate, provider, payTerm, currency, totOrder, items) Class SFDocDetail

    ::order := order
    ::issueDate := issueDate
    ::provider := provider
    ::payTerm := payTerm
    ::currency := currency
    ::totOrder := totOrder
    ::items := items

Return Self
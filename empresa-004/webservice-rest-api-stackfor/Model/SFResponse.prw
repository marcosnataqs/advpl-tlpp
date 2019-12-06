#Include "PROTHEUS.CH"

/*/{Protheus.doc} SFResponse
Classe SFResponse
@type  User Function
@author Marcos Natã Santos
@since 24/06/2019
@version 1.0
/*/
User Function SFResponse
Return

Class SFResponse

    Data status as character
    Data msg as character
    Data result as object

    Method New(status, msg, result) Constructor

EndClass

Method New(status, msg, result) Class SFResponse

    ::status := status
    ::msg    := msg
    ::result := result

Return Self
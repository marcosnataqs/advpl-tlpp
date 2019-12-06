#Include "PROTHEUS.CH"

/*/{Protheus.doc} SFUser
Classe SFUser
@type  User Function
@author Marcos Natã Santos
@since 24/06/2019
@version 1.0
/*/
User Function SFUser
Return

Class SFUser

    Data userId as character
    Data user as character
    Data name as character
    Data mail as character

    Method New(userId, user, name, mail) Constructor

EndClass

Method New(userId, user, name, mail) Class SFUser

    ::userId := userId
    ::user := user
    ::name := name
    ::mail := mail

Return Self
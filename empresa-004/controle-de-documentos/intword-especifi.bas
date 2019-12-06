Sub tabitens()

' Item Macro

' Macro recorded 09/09/2019 by Marcos Natã Santos

'

Dim nItens As Integer

Dim Campo  As String

Selection.GoTo What:=wdGoToBookmark, Name:="tabitens"
Selection.HomeKey Unit:=wdLine

nItens = Val(ActiveDocument.Variables.Item("Adv_nroitens").Value)

Application.Visible = True

For K = 1 To nItens
    ' Posiciona no inicio da tabela
    Selection.HomeKey Unit:=wdLine


    ' Insere o campo Codigo do Produto

    Campo = "DOCVARIABLE Adv_CodProd" & Trim(Str(K))

    Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:=Campo, PreserveFormatting:=True

    
    ' Insere o campo Descricao do Produto

    Selection.MoveRight

    Campo = "DOCVARIABLE Adv_Desc" & Trim(Str(K))

    Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:=Campo, PreserveFormatting:=True
    
    ' Insere uma nova linha na tabela
    If K < nItens Then Selection.InsertRowsBelow 1

Next

End Sub
VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_select_sex"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Command50_Click()
Me.List90.RowSource = "qry_female"
End Sub

Private Sub Command51_Click()
Me.List90.RowSource = "qry_male"

End Sub

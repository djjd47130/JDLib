object ListViewColumns: TListViewColumns
  Left = 195
  Top = 164
  HelpContext = 26110
  ActiveControl = ColumnListBox
  BorderStyle = bsDialog
  Caption = 'ListView Columns Editor'
  ClientHeight = 199
  ClientWidth = 385
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ColumnGroupBox: TGroupBox
    Left = 3
    Top = 6
    Width = 156
    Height = 147
    Caption = '&Columns'
    TabOrder = 0
    object ColumnListBox: TListBox
      Left = 18
      Top = 15
      Width = 120
      Height = 85
      ItemHeight = 13
      TabOrder = 0
      OnClick = ColumnListBoxClick
      OnDragDrop = ColumnListBoxDragDrop
      OnDragOver = ColumnListBoxDragOver
      OnEndDrag = ColumnListBoxEndDrag
      OnMouseDown = ColumnListBoxMouseDown
      OnStartDrag = ColumnListBoxStartDrag
    end
    object New: TButton
      Left = 19
      Top = 111
      Width = 53
      Height = 25
      Caption = '&New'
      Default = True
      TabOrder = 1
      OnClick = NewClick
    end
    object Delete: TButton
      Left = 83
      Top = 110
      Width = 53
      Height = 25
      Caption = '&Delete'
      TabOrder = 2
      OnClick = DeleteClick
    end
  end
  object PropGroupBox: TGroupBox
    Left = 169
    Top = 6
    Width = 211
    Height = 147
    Caption = 'Column Properties'
    Enabled = False
    TabOrder = 1
    object Label1: TLabel
      Left = 11
      Top = 26
      Width = 39
      Height = 13
      Caption = 'Ca&ption:'
      FocusControl = TextEdit
    end
    object Label4: TLabel
      Left = 11
      Top = 52
      Width = 49
      Height = 13
      Caption = 'A&lignment:'
      FocusControl = AlignmentEdit
    end
    object TextEdit: TEdit
      Left = 65
      Top = 22
      Width = 134
      Height = 21
      TabOrder = 0
      OnChange = ValueChanged
      OnExit = TextEditExit
    end
    object AlignmentEdit: TComboBox
      Left = 65
      Top = 49
      Width = 134
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = ValueChanged
      OnExit = AlignmentEditExit
      Items.Strings = (
        'Left Justify'
        'Right Justify'
        'Center')
    end
    object GroupBox1: TGroupBox
      Left = 11
      Top = 74
      Width = 191
      Height = 67
      Caption = '&Width'
      TabOrder = 2
      object WidthEdit: TEdit
        Left = 10
        Top = 25
        Width = 60
        Height = 21
        TabOrder = 0
        OnChange = ValueChanged
        OnExit = WidthEditExit
      end
      object HWidthBtn: TRadioButton
        Left = 86
        Top = 27
        Width = 90
        Height = 17
        Caption = '&Header Width'
        TabOrder = 1
        OnClick = HWidthBtnClick
      end
      object IWidthBtn: TRadioButton
        Left = 86
        Top = 44
        Width = 81
        Height = 17
        Caption = '&Item Width'
        TabOrder = 2
        OnClick = HWidthBtnClick
      end
      object WidthBtn: TRadioButton
        Left = 86
        Top = 9
        Width = 92
        Height = 17
        Caption = 'Width &Value'
        TabOrder = 3
        OnClick = HWidthBtnClick
      end
    end
  end
  object Ok: TButton
    Left = 30
    Top = 162
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object Cancel: TButton
    Left = 118
    Top = 162
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object Apply: TButton
    Left = 207
    Top = 162
    Width = 75
    Height = 25
    Caption = '&Apply'
    Enabled = False
    TabOrder = 4
    OnClick = ApplyClick
  end
  object Help: TButton
    Left = 295
    Top = 162
    Width = 75
    Height = 25
    Caption = '&Help'
    TabOrder = 5
    OnClick = HelpClick
  end
end

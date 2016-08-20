object frmSearchResult: TfrmSearchResult
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'frmSearchResult'
  ClientHeight = 338
  ClientWidth = 228
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnMouseEnter = FormMouseEnter
  OnMouseLeave = FormMouseLeave
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 0
    Top = 0
    Width = 228
    Height = 193
    Align = alTop
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 212
  end
  object Bevel: TBevel
    Left = 8
    Top = 127
    Width = 50
    Height = 50
    Visible = False
  end
  object Detail: TListView
    Left = 0
    Top = 215
    Width = 228
    Height = 123
    Align = alBottom
    Columns = <
      item
        Caption = 'Property'
        Width = 80
      end
      item
        AutoSize = True
        Caption = 'Value'
      end>
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
  end
end

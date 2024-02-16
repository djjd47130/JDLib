object JDGlyphPicker: TJDGlyphPicker
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Character Picker'
  ClientHeight = 447
  ClientWidth = 741
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pMain: TPanel
    Left = 0
    Top = 0
    Width = 741
    Height = 281
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      741
      281)
    object Label1: TLabel
      Left = 8
      Top = 6
      Width = 26
      Height = 13
      Caption = 'Font:'
    end
    object Label2: TLabel
      Left = 8
      Top = 47
      Width = 84
      Height = 13
      Caption = 'Select Character:'
    end
    object lblPreview: TLabel
      Left = 522
      Top = 64
      Width = 211
      Height = 211
      Alignment = taCenter
      Anchors = [akTop, akRight, akBottom]
      AutoSize = False
      Caption = ' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -147
      Font.Name = 'Tahoma'
      Font.Style = []
      Font.Quality = fqAntialiased
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 503
    end
    object Label3: TLabel
      Left = 327
      Top = 6
      Width = 68
      Height = 13
      Caption = 'Custom Color:'
    end
    object lblFontSize: TLabel
      Left = 447
      Top = 1
      Width = 23
      Height = 13
      Caption = 'Size:'
    end
    object Grd: TStringGrid
      Left = 8
      Top = 66
      Width = 508
      Height = 211
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelKind = bkTile
      BorderStyle = bsNone
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 80
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goThumbTracking]
      TabOrder = 0
      OnDrawCell = GrdDrawCell
      OnSelectCell = GrdSelectCell
      ColWidths = (
        80)
      RowHeights = (
        80)
    end
    object cboFont: TComboBox
      Left = 8
      Top = 20
      Width = 199
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnClick = cboFontClick
    end
    object cboStandardColor: TComboBox
      Left = 213
      Top = 20
      Width = 108
      Height = 21
      Style = csDropDownList
      TabOrder = 2
      Items.Strings = (
        'fcNeutral'
        'fcLtGray'
        'fcMdGray'
        'fcDkGray'
        'fcBlue'
        'fcGreen,'
        'fcRed'
        'fcYellow'
        'fcOrange'
        'fcPurple')
    end
    object chkStandardColor: TCheckBox
      Left = 213
      Top = 6
      Width = 108
      Height = 13
      Caption = 'Standard Color:'
      TabOrder = 3
    end
    object cboCustomColor: TColorBox
      Left = 327
      Top = 20
      Width = 114
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbCustomColors]
      TabOrder = 4
    end
    object txtFontSize: TSpinEdit
      Left = 447
      Top = 20
      Width = 58
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 0
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 413
    Width = 741
    Height = 34
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      741
      34)
    object cmdOK: TBitBtn
      Left = 658
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object cmdCancel: TBitBtn
      Left = 577
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object dlgImageFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 124
  end
end

object frmFontButtonEditor: TfrmFontButtonEditor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Font Button Editor'
  ClientHeight = 570
  ClientWidth = 725
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 536
    Width = 725
    Height = 34
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      725
      34)
    object cmdOK: TBitBtn
      Left = 642
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
      Left = 561
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 329
    Width = 725
    Height = 207
    Align = alBottom
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 321
      Top = 6
      Width = 114
      Height = 195
      Caption = 'Image'
      TabOrder = 0
      object Label4: TLabel
        Left = 9
        Top = 52
        Width = 83
        Height = 13
        Caption = 'Hover Grow Size:'
      end
      object Label3: TLabel
        Left = 9
        Top = 100
        Width = 82
        Height = 13
        Caption = 'Press Down Size:'
      end
      object seGrowSize: TSpinEdit
        Left = 9
        Top = 71
        Width = 97
        Height = 22
        MaxValue = 50
        MinValue = 0
        TabOrder = 0
        Value = 2
        OnChange = PropChange
      end
      object cboImagePosition: TComboBox
        Left = 9
        Top = 25
        Width = 97
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = 'Image Top'
        Items.Strings = (
          'Image Top'
          'Image Bottom'
          'Image Left'
          'Image Right'
          'Image Only'
          'Caption Only')
      end
      object seDownSize: TSpinEdit
        Left = 9
        Top = 119
        Width = 97
        Height = 22
        MaxValue = 50
        MinValue = -50
        TabOrder = 2
        Value = 2
        OnChange = PropChange
      end
      object chkAutoSize: TCheckBox
        Left = 9
        Top = 147
        Width = 97
        Height = 17
        Caption = 'Auto Size'
        TabOrder = 3
        OnClick = PropChange
      end
    end
    object GroupBox3: TGroupBox
      Left = 210
      Top = 6
      Width = 105
      Height = 195
      Caption = 'Standard'
      TabOrder = 2
      object shpColor: TShape
        Left = 73
        Top = 16
        Width = 25
        Height = 25
        Cursor = crHandPoint
        OnMouseUp = shpColorMouseUp
      end
      object Label7: TLabel
        Left = 9
        Top = 20
        Width = 60
        Height = 13
        Caption = 'Background:'
      end
      object chkEnabled: TCheckBox
        Left = 7
        Top = 47
        Width = 74
        Height = 17
        Caption = 'Enabled'
        TabOrder = 0
        OnClick = PropChange
      end
      object chkTransparent: TCheckBox
        Left = 7
        Top = 70
        Width = 93
        Height = 17
        Caption = 'Transparent'
        TabOrder = 1
        OnClick = PropChange
      end
      object chkShowFocusRect: TCheckBox
        Left = 7
        Top = 93
        Width = 93
        Height = 17
        Caption = 'Focus Rect'
        TabOrder = 2
        OnClick = PropChange
      end
    end
    object GroupBox4: TGroupBox
      Left = 441
      Top = 6
      Width = 101
      Height = 115
      Caption = 'Style Colors'
      TabOrder = 1
      object chkStyleCaption: TCheckBox
        Left = 8
        Top = 24
        Width = 82
        Height = 17
        Caption = 'Caption'
        TabOrder = 0
        OnClick = PropChange
      end
      object chkStyleImage: TCheckBox
        Left = 8
        Top = 47
        Width = 82
        Height = 17
        Caption = 'Image'
        TabOrder = 1
        OnClick = PropChange
      end
      object chkStyleBack: TCheckBox
        Left = 8
        Top = 70
        Width = 82
        Height = 17
        Caption = 'Background'
        TabOrder = 2
        OnClick = PropChange
      end
      object chkStyleFrame: TCheckBox
        Left = 8
        Top = 93
        Width = 82
        Height = 17
        Caption = 'Frame'
        TabOrder = 3
        OnClick = PropChange
      end
    end
    object cmdTest: TFontButton
      Left = 8
      Top = 6
      Width = 196
      Height = 43
      DrawStyle = fdTransparent
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Image.AutoSize = False
      Image.Text = #61473
      Image.Font.Charset = DEFAULT_CHARSET
      Image.Font.Color = clWindowText
      Image.Font.Height = -21
      Image.Font.Name = 'Wingdings'
      Image.Font.Style = []
      Image.Font.Quality = fqAntialiased
      TabOrder = 3
      Text = 'This is a test'
    end
  end
  object pMain: TPanel
    Left = 0
    Top = 0
    Width = 725
    Height = 265
    Align = alTop
    TabOrder = 2
    DesignSize = (
      725
      265)
    object Label1: TLabel
      Left = 8
      Top = 7
      Width = 59
      Height = 13
      Caption = 'Image Font:'
    end
    object Label2: TLabel
      Left = 8
      Top = 53
      Width = 84
      Height = 13
      Caption = 'Select Character:'
    end
    object lblPreview: TLabel
      Left = 471
      Top = 72
      Width = 246
      Height = 185
      Alignment = taCenter
      Anchors = [akTop, akRight, akBottom]
      AutoSize = False
      Caption = ' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -173
      Font.Name = 'Tahoma'
      Font.Style = []
      Font.Quality = fqAntialiased
      ParentFont = False
      Layout = tlCenter
      ExplicitHeight = 217
    end
    object txtImageFont: TEdit
      Left = 8
      Top = 26
      Width = 217
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object BitBtn1: TBitBtn
      Left = 223
      Top = 26
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = BitBtn1Click
    end
    object Grd: TStringGrid
      Left = 8
      Top = 72
      Width = 457
      Height = 185
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
      TabOrder = 2
      OnDblClick = GrdDblClick
      OnDrawCell = GrdDrawCell
      OnSelectCell = GrdSelectCell
      ColWidths = (
        80)
      RowHeights = (
        80)
    end
  end
  object dlgImageFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 28
    Top = 272
  end
  object dlgColor: TColorDialog
    Options = [cdFullOpen]
    Left = 112
    Top = 272
  end
end

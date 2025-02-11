object frmFontButtonEditor: TfrmFontButtonEditor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Font Button Editor'
  ClientHeight = 571
  ClientWidth = 947
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
    Top = 537
    Width = 947
    Height = 34
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      947
      34)
    object cmdOK: TBitBtn
      Left = 864
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
      Left = 783
      Top = 5
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
    Top = 325
    Width = 947
    Height = 212
    Align = alBottom
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 501
      Top = 1
      Width = 121
      Height = 210
      Align = alRight
      Caption = 'Image'
      TabOrder = 0
      object Label6: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 17
        Width = 113
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        AutoSize = False
        Caption = 'Position:'
        ExplicitWidth = 41
      end
      object Label5: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 60
        Width = 113
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        AutoSize = False
        Caption = 'Standard Color:'
        ExplicitLeft = 3
        ExplicitTop = 73
        ExplicitWidth = 103
      end
      object Label7: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 103
        Width = 113
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        AutoSize = False
        Caption = 'Draw Style'
        ExplicitLeft = 3
        ExplicitTop = 122
      end
      object cboImagePosition: TComboBox
        AlignWithMargins = True
        Left = 4
        Top = 34
        Width = 113
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Align = alTop
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Image Top'
        OnClick = PropChange
        Items.Strings = (
          'Image Top'
          'Image Bottom'
          'Image Left'
          'Image Right'
          'Image Only'
          'Caption Only')
      end
      object chkAutoSize: TCheckBox
        AlignWithMargins = True
        Left = 4
        Top = 146
        Width = 113
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        Caption = 'Auto Size'
        TabOrder = 3
        OnClick = PropChange
      end
      object cboStandardColor: TComboBox
        AlignWithMargins = True
        Left = 4
        Top = 77
        Width = 113
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Align = alTop
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = '[Don'#39't Use]'
        OnClick = PropChange
        Items.Strings = (
          '[Don'#39't Use]'
          'Neutral'
          'Blue'
          'Green'
          'Red'
          'Yellow'
          'Orange')
      end
      object cboDrawStyle: TComboBox
        AlignWithMargins = True
        Left = 4
        Top = 120
        Width = 113
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Align = alTop
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 2
        Text = 'Themed'
        OnClick = PropChange
        Items.Strings = (
          'Themed'
          'Transparent'
          'Hybrid')
      end
    end
    object Panel3: TPanel
      Left = 847
      Top = 1
      Width = 99
      Height = 210
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 4
      object GroupBox4: TGroupBox
        Left = 0
        Top = 0
        Width = 99
        Height = 94
        Align = alTop
        Caption = 'Style Colors'
        TabOrder = 0
        object chkStyleCaption: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 15
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Caption'
          TabOrder = 0
          OnClick = PropChange
        end
        object chkStyleImage: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 34
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Image'
          TabOrder = 1
          OnClick = PropChange
        end
        object chkStyleBack: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 53
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Background'
          TabOrder = 2
          OnClick = PropChange
        end
        object chkStyleFrame: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 72
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Frame'
          TabOrder = 3
          OnClick = PropChange
        end
      end
      object GroupBox5: TGroupBox
        Left = 0
        Top = 94
        Width = 99
        Height = 94
        Align = alTop
        Caption = 'Anchors'
        TabOrder = 1
        object chkAnchorLeft: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 15
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Left'
          TabOrder = 0
          OnClick = PropChange
        end
        object chkAnchorTop: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 34
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Top'
          TabOrder = 1
          OnClick = PropChange
        end
        object chkAnchorRight: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 53
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Right'
          TabOrder = 2
          OnClick = PropChange
        end
        object chkAnchorBottom: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 72
          Width = 91
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Bottom'
          TabOrder = 3
          OnClick = PropChange
        end
      end
    end
    object GroupBox2: TGroupBox
      Left = 622
      Top = 1
      Width = 105
      Height = 210
      Align = alRight
      Caption = 'More'
      TabOrder = 1
      DesignSize = (
        105
        210)
      object lblGrowSize: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 19
        Width = 96
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        AutoSize = False
        Caption = 'Hover Grow Size:'
      end
      object lblDownSize: TLabel
        AlignWithMargins = True
        Left = 6
        Top = 62
        Width = 82
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        AutoSize = False
        Caption = 'Press Down Size:'
      end
      object lblMargin: TLabel
        AlignWithMargins = True
        Left = 6
        Top = 106
        Width = 82
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        AutoSize = False
        Caption = 'Margin'
      end
      object lblSpacing: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 150
        Width = 82
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        AutoSize = False
        Caption = 'Spacing'
      end
      object seGrowSize: TSpinEdit
        AlignWithMargins = True
        Left = 6
        Top = 36
        Width = 94
        Height = 22
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 50
        MinValue = 0
        TabOrder = 0
        Value = 2
        OnChange = PropChange
      end
      object seDownSize: TSpinEdit
        AlignWithMargins = True
        Left = 6
        Top = 79
        Width = 94
        Height = 22
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 50
        MinValue = -50
        TabOrder = 1
        Value = 2
        OnChange = PropChange
      end
      object seMargin: TSpinEdit
        AlignWithMargins = True
        Left = 6
        Top = 123
        Width = 94
        Height = 22
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 500
        MinValue = -1
        TabOrder = 2
        Value = 2
        OnChange = PropChange
      end
      object seSpacing: TSpinEdit
        AlignWithMargins = True
        Left = 5
        Top = 167
        Width = 94
        Height = 22
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 500
        MinValue = -1
        TabOrder = 3
        Value = 2
        OnChange = PropChange
      end
    end
    object Panel4: TPanel
      Left = 727
      Top = 1
      Width = 120
      Height = 210
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 2
      object GroupBox3: TGroupBox
        Left = 0
        Top = 0
        Width = 120
        Height = 157
        Align = alTop
        Caption = 'Standard'
        TabOrder = 0
        object Label11: TLabel
          AlignWithMargins = True
          Left = 4
          Top = 114
          Width = 112
          Height = 13
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          AutoSize = False
          Caption = 'Caption:'
          ExplicitLeft = 28
          ExplicitTop = 137
        end
        object chkEnabled: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 15
          Width = 112
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Enabled'
          TabOrder = 0
          OnClick = PropChange
        end
        object chkShowFocusRect: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 34
          Width = 112
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Focus Rect'
          TabOrder = 1
          OnClick = PropChange
        end
        object chkVisible: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 53
          Width = 112
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Visible'
          TabOrder = 2
          OnClick = PropChange
        end
        object chkShowHint: TCheckBox
          AlignWithMargins = True
          Left = 4
          Top = 72
          Width = 112
          Height = 17
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          Caption = 'Show Hint'
          TabOrder = 3
          OnClick = PropChange
        end
        object txtHint: TEdit
          AlignWithMargins = True
          Left = 4
          Top = 91
          Width = 112
          Height = 21
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          TabOrder = 4
          TextHint = '(Hint)'
          OnChange = txtHintChange
        end
        object txtCaption: TEdit
          AlignWithMargins = True
          Left = 4
          Top = 129
          Width = 112
          Height = 21
          Margins.Left = 2
          Margins.Top = 0
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          TabOrder = 5
          TextHint = '(Caption)'
          OnChange = txtHintChange
        end
      end
    end
    object GroupBox6: TGroupBox
      Left = 396
      Top = 1
      Width = 105
      Height = 210
      Align = alRight
      Caption = 'Help'
      TabOrder = 3
      DesignSize = (
        105
        210)
      object lblContextID: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 83
        Width = 97
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        AutoSize = False
        Caption = 'Context ID:'
        ExplicitLeft = 6
        ExplicitTop = 43
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 43
        Width = 97
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        AutoSize = False
        Caption = 'Keyword:'
        ExplicitLeft = 6
        ExplicitTop = 34
      end
      object cboHelpType: TComboBox
        AlignWithMargins = True
        Left = 4
        Top = 17
        Width = 97
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Align = alTop
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Keyword'
        OnClick = PropChange
        Items.Strings = (
          'Keyword'
          'Context')
      end
      object seHelpContextID: TSpinEdit
        AlignWithMargins = True
        Left = 6
        Top = 103
        Width = 94
        Height = 22
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 9999999
        MinValue = 0
        TabOrder = 1
        Value = 2
        OnChange = PropChange
      end
      object txtHelpKeyword: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 58
        Width = 97
        Height = 21
        Margins.Left = 2
        Margins.Top = 0
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        TabOrder = 2
        TextHint = '(Keyword)'
        OnChange = txtHintChange
      end
    end
  end
  object pMain: TPanel
    Left = 0
    Top = 0
    Width = 947
    Height = 281
    Align = alTop
    TabOrder = 0
    DesignSize = (
      947
      281)
    object Label1: TLabel
      Left = 8
      Top = 5
      Width = 59
      Height = 13
      Caption = 'Image Font:'
    end
    object Label2: TLabel
      Left = 8
      Top = 47
      Width = 84
      Height = 13
      Caption = 'Select Character:'
    end
    object lblPreview: TLabel
      Left = 766
      Top = 64
      Width = 173
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
      ExplicitLeft = 718
      ExplicitHeight = 299
    end
    object Label10: TLabel
      Left = 272
      Top = 5
      Width = 66
      Height = 13
      Caption = 'Caption Font:'
    end
    object txtImageFont: TEdit
      Left = 8
      Top = 22
      Width = 215
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object BitBtn1: TBitBtn
      Left = 223
      Top = 22
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = BitBtn1Click
    end
    object Grd: TStringGrid
      Left = 8
      Top = 66
      Width = 752
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
      TabOrder = 4
      OnDblClick = GrdDblClick
      OnDrawCell = GrdDrawCell
      OnSelectCell = GrdSelectCell
      ColWidths = (
        80)
      RowHeights = (
        80)
    end
    object txtCaptionFont: TEdit
      Left = 272
      Top = 22
      Width = 215
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
    object BitBtn2: TBitBtn
      Left = 487
      Top = 22
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 3
      OnClick = BitBtn2Click
    end
  end
  object dlgImageFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 132
  end
  object dlgCaptionFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 412
  end
end

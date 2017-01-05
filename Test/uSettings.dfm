object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Settings'
  ClientHeight = 556
  ClientWidth = 684
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Pages: TPageControl
    Left = 0
    Top = 33
    Width = 684
    Height = 401
    ActivePage = TabSheet2
    Align = alTop
    TabHeight = 30
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'General'
      object Panel7: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 1
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 0
        object Label4: TLabel
          Left = 0
          Top = 0
          Width = 235
          Height = 31
          Align = alLeft
          Caption = 'Automatic Login (Remember Me)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 19
        end
        object ToggleSwitch2: TToggleSwitch
          Left = 600
          Top = 0
          Width = 72
          Height = 31
          Cursor = crHandPoint
          Align = alRight
          Alignment = taLeftJustify
          TabOrder = 0
          ThumbWidth = 20
          ExplicitHeight = 20
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Main Screen'
      ImageIndex = 1
      object Panel1: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 1
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 0
        object Label1: TLabel
          Left = 0
          Top = 0
          Width = 135
          Height = 31
          Align = alLeft
          Caption = 'Main Menu Overlay'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 19
        end
        object ToggleSwitch1: TToggleSwitch
          Left = 600
          Top = 0
          Width = 72
          Height = 31
          Cursor = crHandPoint
          Align = alRight
          Alignment = taLeftJustify
          TabOrder = 0
          ThumbWidth = 20
          ExplicitHeight = 20
        end
      end
      object Panel2: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 97
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 1
      end
      object Panel3: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 129
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 2
      end
      object Panel4: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 161
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 3
      end
      object Panel5: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 33
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 4
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 124
          Height = 31
          Align = alLeft
          Caption = 'Main Menu Speed'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 19
        end
        object trkMainMenuSpeed: TTrackBar
          Left = 522
          Top = 0
          Width = 150
          Height = 31
          Align = alRight
          Max = 5
          Min = 1
          Position = 1
          ShowSelRange = False
          TabOrder = 0
          ThumbLength = 25
          TickStyle = tsNone
          OnChange = trkMainMenuSpeedChange
        end
      end
      object Panel6: TPanel
        AlignWithMargins = True
        Left = 2
        Top = 65
        Width = 672
        Height = 31
        Margins.Left = 2
        Margins.Top = 1
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = clBlack
        ParentBackground = False
        TabOrder = 5
        object Label3: TLabel
          Left = 0
          Top = 0
          Width = 118
          Height = 31
          Align = alLeft
          Caption = 'Sub Menu Speed'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 19
        end
        object trkSubMenuSpeed: TTrackBar
          Left = 522
          Top = 0
          Width = 150
          Height = 31
          Align = alRight
          Max = 5
          Min = 1
          Position = 1
          ShowSelRange = False
          TabOrder = 0
          ThumbLength = 25
          TickStyle = tsNone
          OnChange = trkSubMenuSpeedChange
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Point-of-Sale'
      ImageIndex = 2
    end
    object TabSheet4: TTabSheet
      Caption = 'Inventory'
      ImageIndex = 3
    end
    object TabSheet5: TTabSheet
      Caption = 'Customers'
      ImageIndex = 4
    end
    object TabSheet6: TTabSheet
      Caption = 'Purchase Orders'
      ImageIndex = 5
    end
    object TabSheet7: TTabSheet
      Caption = 'Vendors'
      ImageIndex = 6
    end
    object TabSheet8: TTabSheet
      Caption = 'Lookup Lists'
      ImageIndex = 7
    end
  end
  object pmSettings: TPageMenu
    Left = 0
    Top = 0
    Width = 684
    Height = 33
    ButtonWidth = 28
    ItemIndex = 0
    Items = <
      item
        Caption = 'General'
      end
      item
        Caption = 'Something Else'
      end
      item
        Caption = 'Another Page'
      end
      item
        Caption = 'Yet Another'
      end>
    Spacing = 35
    OnChange = pmSettingsChange
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = []
    SelectedFont.Charset = DEFAULT_CHARSET
    SelectedFont.Color = clWhite
    SelectedFont.Height = -24
    SelectedFont.Name = 'Tahoma'
    SelectedFont.Style = [fsBold]
    ExplicitTop = -6
  end
end

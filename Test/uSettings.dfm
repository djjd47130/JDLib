object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Settings'
  ClientHeight = 556
  ClientWidth = 417
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Pages: TPageControl
    Left = 0
    Top = 0
    Width = 417
    Height = 401
    ActivePage = TabSheet1
    Align = alTop
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'General'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 409
        Height = 31
        Align = alTop
        TabOrder = 0
        object StaticText1: TStaticText
          Left = 1
          Top = 1
          Width = 216
          Height = 29
          Align = alLeft
          AutoSize = False
          Caption = 'Main Menu Overlay'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          ShowAccelChar = False
          TabOrder = 0
          ExplicitHeight = 39
        end
        object ToggleSwitch1: TToggleSwitch
          Left = 332
          Top = 1
          Width = 76
          Height = 29
          Align = alRight
          TabOrder = 1
          ExplicitLeft = 333
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 31
        Width = 409
        Height = 31
        Align = alTop
        TabOrder = 1
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Main Screen'
      ImageIndex = 1
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
  end
end

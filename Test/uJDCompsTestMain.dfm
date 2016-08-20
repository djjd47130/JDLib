object frmTestMain: TfrmTestMain
  Left = 0
  Top = 0
  Caption = 'JD Components Test Application'
  ClientHeight = 585
  ClientWidth = 917
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pContent: TPanel
    Left = 328
    Top = 48
    Width = 57
    Height = 49
    BevelOuter = bvNone
    TabOrder = 7
  end
  object pLeft: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 545
    Align = alLeft
    BevelOuter = bvNone
    Color = 789516
    ParentBackground = False
    TabOrder = 0
    StyleElements = [seFont, seBorder]
    OnResize = pLeftResize
    object FontButton1: TFontButton
      Left = 0
      Top = 0
      Width = 185
      Height = 30
      Align = alTop
      DrawStyle = fdHybrid
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Image.AutoSize = False
      Image.Text = #61451
      Image.Font.Charset = ANSI_CHARSET
      Image.Font.Color = clWhite
      Image.Font.Height = -21
      Image.Font.Name = 'FontAwesome'
      Image.Font.Style = []
      Image.Font.Quality = fqAntialiased
      Image.UseStandardColor = False
      Margin = 10
      Spacing = 10
      TabOrder = 0
      Text = 'Main Menu'
      OnClick = btnLeftMenuClick
    end
    object FontButton2: TFontButton
      Left = 0
      Top = 30
      Width = 185
      Height = 30
      Align = alTop
      DrawStyle = fdHybrid
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Image.AutoSize = False
      Image.Text = #61451
      Image.Font.Charset = ANSI_CHARSET
      Image.Font.Color = clWhite
      Image.Font.Height = -21
      Image.Font.Name = 'FontAwesome'
      Image.Font.Style = []
      Image.Font.Quality = fqAntialiased
      Image.UseStandardColor = False
      Margin = 10
      Spacing = 10
      TabOrder = 1
      Text = 'Main Menu'
    end
    object btnCurrentLocation: TFontButton
      Left = 0
      Top = 515
      Width = 185
      Height = 30
      Align = alBottom
      DrawStyle = fdHybrid
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Image.AutoSize = False
      Image.Text = #61451
      Image.Font.Charset = ANSI_CHARSET
      Image.Font.Color = clWhite
      Image.Font.Height = -21
      Image.Font.Name = 'FontAwesome'
      Image.Font.Style = []
      Image.Font.Quality = fqAntialiased
      Image.UseStandardColor = False
      Margin = 10
      Spacing = 10
      TabOrder = 2
      Text = 'Main Location'
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 545
    Width = 917
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = 1315860
    ParentBackground = False
    TabOrder = 1
    StyleElements = [seFont, seBorder]
  end
  object pSubMenu: TPanel
    Left = 194
    Top = 8
    Width = 128
    Height = 185
    BevelOuter = bvNone
    Color = 2302755
    ParentBackground = False
    TabOrder = 2
    StyleElements = [seFont, seBorder]
  end
  object pLocation: TPanel
    Left = 416
    Top = 30
    Width = 137
    Height = 163
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
    Visible = False
    StyleElements = [seFont, seBorder]
    object StaticText1: TStaticText
      Left = 0
      Top = 0
      Width = 137
      Height = 21
      Align = alTop
      AutoSize = False
      Caption = 'Change Location'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
      TabOrder = 0
    end
  end
  object pSettings: TPanel
    Left = 576
    Top = 30
    Width = 169
    Height = 163
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 4
    Visible = False
    StyleElements = [seFont, seBorder]
    object StaticText2: TStaticText
      Left = 0
      Top = 0
      Width = 169
      Height = 21
      Align = alTop
      AutoSize = False
      Caption = 'Settings'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
      TabOrder = 0
    end
    object pmSettings: TPageMenu
      Left = 0
      Top = 21
      Width = 169
      Height = 28
      ButtonWidth = 20
      ItemIndex = 0
      Items = <
        item
          Caption = 'General'
        end
        item
          Caption = 'Something Else'
        end>
      Spacing = 20
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
    end
  end
  object pInventory: TPanel
    Left = 416
    Top = 284
    Width = 137
    Height = 231
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 5
    Visible = False
    StyleElements = [seFont, seBorder]
    object StaticText5: TStaticText
      Left = 0
      Top = 0
      Width = 137
      Height = 21
      Align = alTop
      AutoSize = False
      Caption = 'Inventory'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
      TabOrder = 0
    end
  end
  object pCustomers: TPanel
    Left = 576
    Top = 284
    Width = 137
    Height = 231
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 6
    Visible = False
    StyleElements = [seFont, seBorder]
    object StaticText6: TStaticText
      Left = 0
      Top = 0
      Width = 137
      Height = 21
      Align = alTop
      AutoSize = False
      Caption = 'Customers'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
      TabOrder = 0
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 216
    Top = 480
  end
  object DB: TFDConnection
    Params.Strings = (
      'DriverID=MSSQL'
      'Server=JD-BEAST\RMPro'
      'Password=RMPro2016MPZ#'
      'Database=RugTest'
      'User_Name=sa')
    LoginPrompt = False
    Left = 216
    Top = 256
  end
  object smLeftMenu: TSmoothMove
    Step = 15.000000000000000000
    Value = 100.000000000000000000
    OnValue = smLeftMenuValue
    Left = 216
    Top = 312
  end
  object smSubMenu: TSmoothMove
    Step = 15.000000000000000000
    Value = 100.000000000000000000
    OnValue = smSubMenuValue
    Left = 216
    Top = 360
  end
  object smBottomMenu: TSmoothMove
    Step = 15.000000000000000000
    Value = 100.000000000000000000
    OnValue = smBottomMenuValue
    Left = 216
    Top = 408
  end
end

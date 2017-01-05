object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Weather Component Test'
  ClientHeight = 514
  ClientWidth = 772
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 265
    Top = 0
    Width = 5
    Height = 514
    ExplicitLeft = 313
    ExplicitHeight = 481
  end
  object lstCurrent: TListView
    Left = 0
    Top = 0
    Width = 265
    Height = 514
    Align = alLeft
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Name'
        Width = 140
      end
      item
        Caption = 'Value'
        Width = 120
      end>
    LargeImages = imgCurrent
    ReadOnly = True
    RowSelect = True
    SmallImages = imgCurrent
    TabOrder = 0
    ViewStyle = vsReport
  end
  object pRight: TPanel
    Left = 344
    Top = 0
    Width = 428
    Height = 514
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 0
      Top = 227
      Width = 428
      Height = 5
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = 24
      ExplicitTop = 235
    end
    object imgMap: TImage
      Left = 0
      Top = 232
      Width = 428
      Height = 168
      Align = alBottom
      Proportional = True
      Stretch = True
      Transparent = True
    end
    object lstForecast: TListView
      Left = 0
      Top = 0
      Width = 428
      Height = 113
      Align = alTop
      BorderStyle = bsNone
      Columns = <
        item
          Caption = 'Timing'
          Width = 150
        end
        item
          Caption = 'Description'
          Width = 400
        end>
      LargeImages = imgForecast
      ReadOnly = True
      RowSelect = True
      SmallImages = imgForecast
      TabOrder = 0
      ViewStyle = vsReport
    end
    object lstAlerts: TListView
      Left = 0
      Top = 400
      Width = 428
      Height = 114
      Align = alBottom
      BorderStyle = bsNone
      Columns = <
        item
          Caption = 'Date / Time'
          Width = 100
        end
        item
          Caption = 'Expires'
          Width = 100
        end
        item
          Caption = 'Alert Type'
          Width = 100
        end
        item
          Caption = 'Details'
          Width = 320
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
    end
  end
  object Weather: TJDWeather
    Service = wsWUnderground
    AllAtOnce = True
    Active = True
    AllFreq = 300
    ConditionFreq = 300
    ForecastFreq = 300
    MapsFreq = 300
    AlertsFreq = 300
    Key = '94d3080777d94610'
    LocationType = wlAutoIP
    Units = wuImperial
    OnConditions = WeatherConditions
    OnForecast = WeatherForecast
    OnAlerts = WeatherAlerts
    OnMaps = WeatherMaps
    Left = 296
    Top = 56
  end
  object imgCurrent: TImageList
    Height = 50
    Width = 50
    Left = 120
    Top = 184
  end
  object imgForecast: TImageList
    Height = 50
    Width = 50
    Left = 528
    Top = 48
  end
end

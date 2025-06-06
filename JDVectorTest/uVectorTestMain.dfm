object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 534
  ClientWidth = 787
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
  object Img: TJDVectorImage
    Left = 0
    Top = 0
    Width = 761
    Height = 534
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBlack
    DoubleBuffered = True
    Frame.Alpha = 255
    Frame.Color.Color = clGray
    Frame.Color.UseStandardColor = False
    Frame.Width = 1.700000047683716000
    Graphic.Caption = 'JD Logo'
    Graphic.Name = 'JDLogo'
    Graphic.Parts = <
      item
        Brush.Alpha = 200
        Brush.Color.Color = 3948179
        Brush.Color.UseStandardColor = False
        Pen.Alpha = 0
        Pen.Color.Color = 2434341
        Pen.Color.UseStandardColor = False
        Pen.Width = 3.000000000000000000
        Caption = 'J Left'
        Scale = 1.000000000000000000
        Parts = <>
        Points = <
          item
            Y = 50.000000000000000000
          end
          item
            X = 49.000000000000000000
            Y = 100.000000000000000000
          end
          item
            X = 49.000000000000000000
            Y = 70.000000000000000000
          end
          item
            X = 30.000000000000000000
            Y = 50.000000000000000000
          end>
        Subtractive = False
      end
      item
        Brush.Alpha = 200
        Brush.Color.Color = 10176567
        Brush.Color.UseStandardColor = False
        Pen.Alpha = 0
        Pen.Color.Color = 2434341
        Pen.Color.UseStandardColor = False
        Pen.Width = 3.000000000000000000
        Caption = 'D Right'
        Scale = 1.000000000000000000
        Parts = <>
        Points = <
          item
            X = 50.000000000000000000
          end
          item
            X = 100.000000000000000000
            Y = 50.000000000000000000
          end
          item
            X = 51.000000000000000000
            Y = 100.000000000000000000
          end
          item
            X = 51.000000000000000000
            Y = 70.000000000000000000
          end
          item
            X = 70.000000000000000000
            Y = 50.000000000000000000
          end
          item
            X = 50.000000000000000000
            Y = 30.000000000000000000
          end>
        Subtractive = False
      end
      item
        Brush.Alpha = 0
        Brush.Color.Color = 1490631
        Brush.Color.UseStandardColor = False
        Pen.Alpha = 0
        Pen.Color.Color = 2434341
        Pen.Color.UseStandardColor = False
        Pen.Width = 3.000000000000000000
        Caption = 'Diamond Center'
        Scale = 1.000000000000000000
        Parts = <
          item
            Brush.Alpha = 50
            Brush.Color.Color = clLime
            Brush.Color.UseStandardColor = False
            Pen.Alpha = 50
            Pen.Color.Color = clGray
            Pen.Color.UseStandardColor = False
            Pen.Width = 3.000000000000000000
            Caption = 'New Part'
            Scale = 1.000000000000000000
            Parts = <>
            Points = <
              item
                X = 55.000000000000000000
                Y = 55.000000000000000000
              end
              item
                X = 35.000000000000000000
                Y = 40.000000000000000000
              end
              item
                X = 40.000000000000000000
                Y = 35.000000000000000000
              end>
            Subtractive = True
          end>
        Points = <
          item
            X = 50.000000000000000000
            Y = 32.000000000000000000
          end
          item
            X = 68.000000000000000000
            Y = 50.000000000000000000
          end
          item
            X = 50.000000000000000000
            Y = 68.000000000000000000
          end
          item
            X = 32.000000000000000000
            Y = 50.000000000000000000
          end>
        Subtractive = False
      end>
    Graphic.Scale = 1.000000000000000000
    GridLines.Alpha = 255
    GridLines.Color.Color = clGray
    GridLines.Color.UseStandardColor = False
    GridLines.Width = 1.000000000000000000
    Padding = 20.000000000000000000
    ShowGrid = False
    OnClick = ImgClick
  end
end

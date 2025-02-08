unit JD.Ctrls.Gauges.Objects;

interface

{$DEFINE USE_GDIP}

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls,
  {$IFDEF USE_GDIP}
  GDIPAPI, GDIPOBJ, GDIPUTIL,
  {$ENDIF}
  JD.Common, JD.Ctrls.Gauges, JD.Graphics;

type

  ///  <summary>
  ///  Circle gauge (full 360 arc)
  ///  </summary>
  TJDGaugeCircle = class(TJDGaugeBase)
    class function GetCaption: String; override;
  protected
    function GetBaseRect: TJDRect; override;
    function GetGlyphRect: TJDRect; override;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; override;
    procedure PaintValueBase(AValue: TJDGaugeValue); override;
    procedure PaintPeak(AValue: TJDGaugeValue); override;
    procedure PaintValue(AValue: TJDGaugeValue); override;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); override;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); override;
  public
    function Radius: Single;
  end;

  ///  <summary>
  ///  Horizontal Bar Gauge (Left to Right)
  ///  </summary>
  TJDGaugeHorzBar = class(TJDGaugeBase)
    class function GetCaption: String; override;
  protected
    function GetGlyphRect: TJDRect; override;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; override;
    procedure PaintValueBase(AValue: TJDGaugeValue); override;
    procedure PaintPeak(AValue: TJDGaugeValue); override;
    procedure PaintValue(AValue: TJDGaugeValue); override;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); override;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); override;
  end;

  ///  <summary>
  ///  Vertical Bar Gauge (Top to Bottom)
  ///  </summary>
  TJDGaugeVertBar = class(TJDGaugeBase)
    class function GetCaption: String; override;
  protected
    function GetBaseRect: TJDRect; override;
    function GetGlyphRect: TJDRect; override;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; override;
    procedure PaintValueBase(AValue: TJDGaugeValue); override;
    procedure PaintPeak(AValue: TJDGaugeValue); override;
    procedure PaintValue(AValue: TJDGaugeValue); override;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); override;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); override;
  end;

  ///  <summary>
  ///  Pie gauge (full 360 pie chart)
  ///  </summary>
  TJDGaugePie = class(TJDGaugeBase)
    class function GetCaption: String; override;
  protected
    function GetBaseRect: TJDRect; override;
    function GetGlyphRect: TJDRect; override;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; override;
    procedure PaintValueBase(AValue: TJDGaugeValue); override;
    procedure PaintPeak(AValue: TJDGaugeValue); override;
    procedure PaintValue(AValue: TJDGaugeValue); override;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); override;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); override;
  end;

  ///  <summary>
  ///  Needle gauge (full 360 arc)
  ///  </summary>
  TJDGaugeNeedle = class(TJDGaugeBase)
    class function GetCaption: String; override;
  protected
    function GetBaseRect: TJDRect; override;
    function GetGlyphRect: TJDRect; override;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; override;
    procedure PaintValueBase(AValue: TJDGaugeValue); override;
    procedure PaintPeak(AValue: TJDGaugeValue); override;
    procedure PaintValue(AValue: TJDGaugeValue); override;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); override;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); override;
  public
    function Radius: Single;
  end;

implementation

{ TJDGaugeCircle }

class function TJDGaugeCircle.GetCaption: String;
begin
  Result:= 'Circle';
end;

function TJDGaugeCircle.GetBaseRect: TJDRect;
var
  Z: Integer;
begin
  //Center within client rect...
  if Owner.ClientRect.Width > Owner.ClientRect.Height then begin
    Z:= Owner.ClientRect.Height;
  end else begin
    Z:= Owner.ClientRect.Width;
  end;
  Result.X:= (Owner.ClientRect.Width div 2) - (Z div 2);
  Result.Y:= (Owner.ClientRect.Height div 2) - (Z div 2);
  Result.Width:= Z;
  Result.Height:= Z;
  Result.Inflate(-Owner.Thickness, -Owner.Thickness)
end;

function TJDGaugeCircle.GetGlyphRect: TJDRect;
var
  R: TJDRect;
  S: String;
  W, H: Integer;
begin
  S:= Owner.Glyph.Glyph;
  Canvas.Font.Assign(Owner.Glyph.Font);
  W:= Canvas.TextWidth(S);
  H:= Canvas.TextHeight(S);
  R:= GetBaseRect;
  Result.Width:= W;
  Result.Height:= H;
  Result.Left:= (R.Width / 2) - (Result.Width / 2);
  Result.Top:= (R.Height / 2) - (Result.Height / 2);
end;

function TJDGaugeCircle.GetValueRect(AValue: TJDGaugeValue): TJDRect;
var
  Offset: Integer;
begin
  Result:= GetBaseRect;
  case Owner.Grouping of
    ctDefault, ctOverlay: begin
      //Current behavior

    end;
    ctStack: begin
      Offset:= Round((AValue.Thickness / 2) * (AValue.Index));
      Result.Inflate(-Offset, -Offset);
    end;
    ctStackReverse: begin
      Offset:= Round(AValue.Thickness * AValue.Index);
      Result.Inflate(-Offset, -Offset);
      //TODO
    end;
    ctMerge: begin
      //TODO: Combine values into same base...

    end;
    ctMergeReverse: begin

    end;
  end;
end;

procedure TJDGaugeCircle.PaintPeak(AValue: TJDGaugeValue);
var
  Angle: Integer;
  R: TJDRect;
begin
  R:= GetBaseRect;
  Angle:= Round(360 * (AValue.Peak.PeakVal / AValue.Max));
  if AValue.Reverse then
    Angle:= -Angle;
  GPCanvas.DrawArc(Pen, R, -90, Angle);
end;

procedure TJDGaugeCircle.PaintValueTick(ATicks: TJDGaugeTicks;
  AValue: TJDGaugeValue; AVal, AMin, AMax: Double);
var
  R: TJDRect;
  Perc: Double;
  CP, P1, P2: TJDPoint;
  Rad: Single;
  Deg: Single;
begin
  //Gauge base rectangle
  R:= GetBaseRect;
  //Center point
  CP:= R.Center;
  //Percent around circle
  Perc:= (AVal / AMax);
  //Degrees
  Deg:= (Perc * 360); //TODO
  //Radius - TODO: Find out why this is not accurate...
  Rad:= Radius;
  //GDI+ pen
  Pen.SetColor(ColorToGPColor(ATicks.Color.GetJDColor));
  Pen.SetWidth(ATicks.Thickness);
  //Tick position
  case ATicks.Position of
    tpDefault, tpOutside: begin
      Rad:= Rad - 8; //TODO
      P1:= PointAroundCenter(CP, Rad, Deg);
      P2:= PointAroundCenter(CP, Round(Rad + ATicks.Length), Deg);
    end;
    tpInside: begin
      Rad:= Rad - 16; //TODO
      P1:= PointAroundCenter(CP, Rad, Deg);
      P2:= PointAroundCenter(CP, Round(Rad - ATicks.Length), Deg);
    end;
    tpCenter: begin
      Rad:= Rad - 12; //TODO
      P1:= PointAroundCenter(CP, Round(Rad - (ATicks.Length / 2)), Deg);
      P2:= PointAroundCenter(CP, Round(Rad + (ATicks.Length / 2)), Deg);
    end;
  end;
  //Draw line
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeCircle.PaintValue(AValue: TJDGaugeValue);
var
  Angle: Integer;
  R: TJDRect;
  Offset: Integer;
begin
  //TODO: Calculate for MIN property...

  R:= GetValueRect(AValue);
  Angle:= Round(360 * (AValue.Value / AValue.Max));
  if AValue.Reverse then
    Angle:= -Angle;

  case Owner.Grouping of
    ctDefault, ctOverlay: begin
      //Current behavior

    end;
    ctStack: begin
      Offset:= Round(AValue.Thickness * AValue.Index);
      R.Inflate(-Offset, -Offset);
    end;
    ctStackReverse: begin
      Offset:= Round(AValue.Thickness * AValue.Index);
      R.Inflate(-Offset, -Offset);
    end;
    ctMerge: begin
      //TODO: Combine values into same base...

    end;
    ctMergeReverse: begin

    end;
  end;

  GPCanvas.DrawArc(Pen, R, -90, Angle);
  //GPCanvas.DrawArc //TODO: Use center point with radius instead of rect...

end;

procedure TJDGaugeCircle.PaintValueBase(AValue: TJDGaugeValue);
var
  R: TJDRect;
begin
  R:= GetValueRect(AValue);
  Pen.SetColor(ColorToGPColor(Owner.ColorMain.GetJDColor));
  Pen.SetWidth(Owner.Thickness);
  GPCanvas.DrawArc(Pen, R, -90, 360);
end;

procedure TJDGaugeCircle.PaintValueGlyph(AValue: TJDGaugeValue);
begin

end;

function TJDGaugeCircle.Radius: Single;
var
  R: TJDRect;
begin
  //TODO
  R:= GetBaseRect;
  Result:= R.Height / 2;
end;

{ TJDGaugeHorzBar }

class function TJDGaugeHorzBar.GetCaption: String;
begin
  Result:= 'Horizontal Bar';
end;

function TJDGaugeHorzBar.GetGlyphRect: TJDRect;
begin
  Result:= inherited;
end;

function TJDGaugeHorzBar.GetValueRect(AValue: TJDGaugeValue): TJDRect;
begin
  Result:= GetBaseRect;
  case Owner.Grouping of
    ctDefault, ctOverlay: begin
      //Current behavior...

    end;
    ctStack: begin
      //Stack bars on top of each other...
      Result.Height:= (Result.Height / Owner.Values.Count);
      Result.Top:= (Result.Height * AValue.Index);
    end;
    ctStackReverse: begin
      //Stack bars from the bottom up...
      Result.Height:= (Owner.ClientHeight / Owner.Values.Count);
      Result.Top:= Owner.ClientHeight - Result.Height - (Result.Height * AValue.Index);
    end;
    ctMerge: begin
      //Merge multiple bars on one base...

    end;
    ctMergeReverse: begin

    end;
  end;
end;

procedure TJDGaugeHorzBar.PaintPeak(AValue: TJDGaugeValue);
var
  Perc: Double;
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  //TODO: Calculate for MIN property...
  Perc:= (AValue.Peak.PeakVal / AValue.Max);
  if AValue.Reverse then
    Perc:= -Perc;
  R:= GetValueRect(AValue);
  P1.X:= R.X;
  P1.Y:= (R.Height / 2);
  P2.X:= (R.Width * Perc) + R.X;
  P2.Y:= (R.Height / 2);
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeHorzBar.PaintValueTick(ATicks: TJDGaugeTicks;
  AValue: TJDGaugeValue; AVal, AMin, AMax: Double);
var
  R: TJDRect;
  Perc: Double;
  P1, P2: TJDPoint;
begin
  R:= GetBaseRect;
  Perc:= (AVal / AMax);
  Pen.SetColor(ColorToGPColor(ATicks.Color.GetJDColor));
  Pen.SetWidth(ATicks.Thickness);
  case ATicks.Position of
    tpOutside: begin
      P1.X:= (R.Width * Perc) + R.X;
      P1.Y:= R.Y + R.Height;
      P2.X:= P1.X;
      P2.Y:= R.Y + R.Height - ATicks.Length;
    end;
    tpInside: begin
      P1.X:= (R.Width * Perc) + R.X;
      P1.Y:= R.Y;
      P2.X:= P1.X;
      P2.Y:= R.Y + ATicks.Length;
    end;
    tpCenter: begin
      P1.X:= (R.Width * Perc) + R.X;
      P1.Y:= R.Y + (R.Height / 2) - (ATicks.Length / 2);
      P2.X:= P1.X;
      P2.Y:= R.Y + (R.Height / 2) + (ATicks.Length / 2);
    end;
  end;
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeHorzBar.PaintValue(AValue: TJDGaugeValue);
var
  Perc: Double;
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  Perc:= (AValue.Value / AValue.Max);
  if AValue.Reverse then
    Perc:= -Perc;
  R:= GetValueRect(AValue);

  //TODO: Calculate for MIN property...

  P1.X:= R.X;
  P1.Y:= R.Top + (R.Height / 2);
  P2.X:= (R.Width * Perc) + R.X;
  P2.Y:= R.Top + (R.Height / 2);
  GPCanvas.DrawLine(Pen, P1, P2);

end;

procedure TJDGaugeHorzBar.PaintValueBase(AValue: TJDGaugeValue);
var
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  R:= GetValueRect(AValue);
  P1.X:= R.X;
  P1.Y:= R.Top + (R.Height / 2);
  P2.X:= (R.Width) + R.X;
  P2.Y:= R.Top + (R.Height / 2);
  GPCanvas.DrawLine(Pen, P1, P2);
  if Owner.HoverElement = geBase then begin
    //Hovering over glyph, draw rectangle...
    Canvas.Pen.Style:= psSolid;
    Pen.SetWidth(1);
    Pen.SetColor(ColorToGPColor(clSilver));
    if Owner.ShowRect then begin
      R.Deflate(1, 1);
      GPCanvas.DrawRectangle(Pen, R);
    end;
  end;
end;

procedure TJDGaugeHorzBar.PaintValueGlyph(AValue: TJDGaugeValue);
begin

end;

{ TJDGaugeVertBar }

class function TJDGaugeVertBar.GetCaption: String;
begin
  Result:= 'Vertical Bar';
end;

function TJDGaugeVertBar.GetBaseRect: TJDRect;
begin
  if Owner.BaseAutoSize then begin
    Result:= Owner.ClientRect;
    if Owner.ShowGlyph or Owner.ShowCaption or Owner.ShowValue then begin
      Result.Y:= Result.Y + 30; //TODO
    end;
  end else begin
    Result.Width:= Owner.BaseSize;
    Result.Height:= Owner.ClientRect.Height;
    Result.X:= Owner.ClientRect.Left;
    Result.Y:= Owner.ClientRect.Top;
    if Owner.ShowGlyph or Owner.ShowCaption or Owner.ShowValue then begin
      Result.Y:= Result.Y + 30; //TODO
    end;
  end;
end;

function TJDGaugeVertBar.GetGlyphRect: TJDRect;
begin
  Result:= Owner.ClientRect;
  Result.Height:= 30; //TODO
  if Owner.ShowCaption then begin
    Result.Width:= 30; //TODO
  end;
end;

function TJDGaugeVertBar.GetValueRect(AValue: TJDGaugeValue): TJDRect;
begin
  Result:= GetBaseRect;
  case Owner.Grouping of
    ctDefault, ctOverlay: ;
    ctStack: ;
    ctStackReverse: ;
    ctMerge: ;
    ctMergeReverse: ;
  end;
end;

procedure TJDGaugeVertBar.PaintPeak(AValue: TJDGaugeValue);
var
  Perc: Double;
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  //TODO: Change from top-to-bottom to bottom-to-top...
  Perc:= (AValue.Peak.PeakVal / AValue.Max);
  if AValue.Reverse then
    Perc:= -Perc;
  R:= GetBaseRect;
  P1.X:= (R.Width / 2);
  P1.Y:=  R.Bottom - (R.Bottom * Perc);
  P2.X:= (R.Width / 2);
  P2.Y:= R.Bottom;
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeVertBar.PaintValueTick(ATicks: TJDGaugeTicks;
  AValue: TJDGaugeValue; AVal, AMin, AMax: Double);
var
  R: TJDRect;
  Perc: Double;
  P1, P2: TJDPoint;
begin
  R:= GetValueRect(AValue);
  Perc:= (AVal / AMax);
  Pen.SetColor(ColorToGPColor(ATicks.Color.GetJDColor));
  Pen.SetWidth(ATicks.Thickness);
  case ATicks.Position of
    tpOutside: begin
      P1.X:= R.Right;
      P1.Y:= (R.Height * Perc) + R.Y;
      P2.X:= R.Right - ATicks.Length;
      P2.Y:= P1.Y;
    end;
    tpInside: begin
      P1.X:= R.Left;
      P1.Y:= (R.Height * Perc) + R.Y;
      P2.X:= R.Left + ATicks.Length;
      P2.Y:= P1.Y;
    end;
    tpDefault, tpCenter: begin
      P1.X:= R.TopCenter.X - (ATicks.Length / 2);
      P1.Y:= (R.Height * Perc) + R.Y;
      P2.X:= R.TopCenter.X + (ATicks.Length / 2);
      P2.Y:= P1.Y;
    end;
  end;
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeVertBar.PaintValue(AValue: TJDGaugeValue);
var
  Perc: Double;
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  //TODO: Calculate for MIN property...

  //TODO: Implement Grouping property...

  //TODO: Change from top-to-bottom to bottom-to-top...

  Perc:= (AValue.Value / AValue.Max);
  if AValue.Reverse then
    Perc:= -Perc;
  R:= GetBaseRect;
  P1.X:= (R.Width / 2);
  P1.Y:= R.Bottom - (R.Height * Perc);
  P2.X:= (R.Width / 2);
  P2.Y:= R.Bottom;
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeVertBar.PaintValueBase(AValue: TJDGaugeValue);
var
  R: TJDRect;
  P1, P2: TJDPoint;
begin
  //TODO: Change from top-to-bottom to bottom-to-top...
  R:= GetValueRect(AValue);
  P1.X:= (R.Width / 2);
  P2.Y:= R.Bottom;
  P2.X:= (R.Width / 2);
  P2.Y:= R.Top;
  GPCanvas.DrawLine(Pen, P1, P2);
end;

procedure TJDGaugeVertBar.PaintValueGlyph(AValue: TJDGaugeValue);
begin

end;

{ TJDGaugePie }

class function TJDGaugePie.GetCaption: String;
begin
  Result:= 'Pie';
end;

function TJDGaugePie.GetBaseRect: TJDRect;
var
  Z: Integer;
begin
  //Center within client rect...
  if Owner.ClientRect.Width > Owner.ClientRect.Height then begin
    Z:= Owner.ClientRect.Height;
  end else begin
    Z:= Owner.ClientRect.Width;
  end;
  Result.X:= (Owner.ClientRect.Width div 2) - (Z div 2);
  Result.Y:= (Owner.ClientRect.Height div 2) - (Z div 2);
  Result.Width:= Z;
  Result.Height:= Z;
  Result.Inflate(-3, -3);
end;

function TJDGaugePie.GetGlyphRect: TJDRect;
begin
  Result:= inherited;
end;

function TJDGaugePie.GetValueRect(AValue: TJDGaugeValue): TJDRect;
begin
  Result:= GetBaseRect;
  case Owner.Grouping of
    ctOverlay: ;
    ctStack: ;
    ctStackReverse: ;
    ctDefault, ctMerge: ;
    ctMergeReverse: ;
  end;
end;

procedure TJDGaugePie.PaintPeak(AValue: TJDGaugeValue);
var
  A: Integer;
  R: TJDRect;
begin
  R:= GetBaseRect;
  A:= Round(360 * (AValue.Peak.PeakVal / AValue.Max));
  if AValue.Reverse then
    A:= -A;
  Pen.SetColor(ColorToGPColor(AValue.Peak.Color.GetJDColor));
  Pen.SetWidth(AValue.Peak.Thickness);
  Brush.SetColor(ColorToGPColor(AValue.Peak.Color.GetJDColor));
  GPCanvas.FillPie(Brush, R, -90, A);
  //GPCanvas.DrawPie(Pen, R, -90, A);
  //TODO: Fix this to work around center point...
end;

procedure TJDGaugePie.PaintValue(AValue: TJDGaugeValue);
var
  A: Integer;
  R: TJDRect;
  //B: TGPBrush;
begin
  //TODO: Calculate for MIN property...

  //TODO: Implement Grouping property...

  R:= GetBaseRect;
  A:= Round(360 * (AValue.Value / AValue.Max));
  if AValue.Reverse then
    A:= -A;
  Pen.SetColor(ColorToGPColor(AValue.Color.GetJDColor));
  Pen.SetWidth(AValue.Thickness);
  Brush.SetColor(ColorToGPColor(AValue.Color.GetJDColor));

  //TODO: Check for gradient...

  GPCanvas.FillPie(Brush, R, -90, A);
  //GPCanvas.DrawPie(Pen, R, -90, A);
  //TODO: Fix this to work around center point...
end;

procedure TJDGaugePie.PaintValueBase(AValue: TJDGaugeValue);
var
  R: TJDRect;
begin
  Pen.SetColor(ColorToGPColor(Owner.ColorMain.GetJDColor));
  Pen.SetWidth(Owner.Thickness);
  Brush.SetColor(ColorToGPColor(Owner.ColorMain.GetJDColor));
  R:= GetValueRect(AValue);
  GPCanvas.FillPie(Brush, R, -90, 360);
  //GPCanvas.DrawPie(Pen, R, -90, 360);
  //TODO: Fix this to work around center point...
end;

procedure TJDGaugePie.PaintValueGlyph(AValue: TJDGaugeValue);
begin

end;

procedure TJDGaugePie.PaintValueTick(ATicks: TJDGaugeTicks;
  AValue: TJDGaugeValue; AVal, AMin, AMax: Double);
begin
  inherited;

end;

{ TJDGaugeNeedle }

function TJDGaugeNeedle.GetBaseRect: TJDRect;
begin
  Result:= Owner.ClientRect;
end;

class function TJDGaugeNeedle.GetCaption: String;
begin
  Result:= 'Needle';
end;

function TJDGaugeNeedle.GetGlyphRect: TJDRect;
begin
  Result:= GetBaseRect; //TODO
end;

function TJDGaugeNeedle.GetValueRect(AValue: TJDGaugeValue): TJDRect;
begin
  Result:= GetBaseRect; //TODO
end;

procedure TJDGaugeNeedle.PaintPeak(AValue: TJDGaugeValue);
begin

end;

procedure TJDGaugeNeedle.PaintValue(AValue: TJDGaugeValue);
begin

end;

procedure TJDGaugeNeedle.PaintValueBase(AValue: TJDGaugeValue);
begin

end;

procedure TJDGaugeNeedle.PaintValueGlyph(AValue: TJDGaugeValue);
begin

end;

procedure TJDGaugeNeedle.PaintValueTick(ATicks: TJDGaugeTicks;
  AValue: TJDGaugeValue; AVal, AMin, AMax: Double);
begin

end;

function TJDGaugeNeedle.Radius: Single;
var
  R: TJDRect;
begin
  //TODO
  R:= GetBaseRect;
  Result:= R.Height / 2;
end;

initialization
  JDRegisterGaugeType(TJDGaugeCircle);
  JDRegisterGaugeType(TJDGaugeHorzBar);
  JDRegisterGaugeType(TJDGaugeVertBar);
  JDRegisterGaugeType(TJDGaugePie);
  JDRegisterGaugeType(TJDGaugeNeedle);

end.

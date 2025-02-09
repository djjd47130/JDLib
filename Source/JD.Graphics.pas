unit JD.Graphics;

//Delphi class operators: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Operator_Overloading_(Delphi)

//Code review: https://codereview.stackexchange.com/questions/79214/converting-delphi-colors-between-tcolor-rgb-cmyk-and-hsv

//32bit Bitmap Alpha: https://stackoverflow.com/questions/10147932/how-change-the-alpha-value-of-a-specific-color-in-a-32-bit-tbitmap

interface

{$DEFINE USE_GDIP}

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.ImgList, Vcl.Dialogs
  {$IFDEF USE_GDIP}
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  {$ENDIF}
  , JD.Common //This unit should NOT use any other JD related units!
  ;

const
  //GLOBAL COLOR SETUP
  //These are the default colors for the 3 color modes,
  //  as well as colors in Windows default themes.

  //Light version of colors
  LIGHT_NEUTRAL = $00D1C6B8; //$00DEC4AB;
  LIGHT_GRAY =    clSilver;
  LIGHT_BLUE =    $00F7392B; //clBlue; //$003C0E00; //$00D7A36F;
  LIGHT_GREEN =   $0000B900; //$0055A667;
  LIGHT_RED =     $004A4ADF; //$006464E3;
  LIGHT_YELLOW =  $003EFFFF;
  LIGHT_ORANGE =  $002492FF;
  LIGHT_PURPLE =  $009212BC;

  //Medium version of colors
  MED_NEUTRAL =   clSilver;
  MED_GRAY =      clGray;
  MED_BLUE =      clBlue;
  MED_GREEN =     clGreen;
  MED_RED =       clRed;
  MED_YELLOW =    clYellow;
  MED_ORANGE =    $000080FF;
  MED_PURPLE =    clPurple;

  //Dark version of colors
  DARK_NEUTRAL =  $005F4A3F; //$006B4732;
  DARK_GRAY =     clDkGray;
  DARK_BLUE =     $00986D34;
  DARK_GREEN =    $002C6137;
  DARK_RED =      $002629B9;
  DARK_YELLOW =   $0000B0B0;
  DARK_ORANGE =   $00145CD6; //$00165792;
  DARK_PURPLE =   $00400080;

  //Default windows colors
  WIN_NEUTRAL =   DARK_NEUTRAL;
  WIN_GRAY =      DARK_GRAY;
  WIN_BLUE =      DARK_BLUE;
  WIN_GREEN =     DARK_GREEN;
  WIN_RED =       DARK_RED;
  WIN_YELLOW =    DARK_YELLOW;
  WIN_ORANGE =    DARK_ORANGE;
  WIN_PURPLE =    DARK_PURPLE;

  //Extended
  WIN_MAIN =      $00F8F8ED;
  WIN_GRAD_FROM = $00E4E1C0;
  WIN_GRAD_TO =   $00F8F8ED;

type

  ///  <summary>
  ///  JD standard colors, to avoid having to decide on specific colors.
  ///  Automatically differs whether using light or dark modes.
  ///  Customizable via ColorManager (TJDColorManager).
  ///  </summary>
  TJDStandardColor = (fcNeutral, fcGray, fcBlue, fcGreen,
    fcRed, fcYellow, fcOrange, fcPurple);

  ///  <summary>
  ///  A set of TJDStandardColor enum values.
  ///  </summary>
  TJDStandardColors = array[TJDStandardColor] of TColor;

  ///  <summary>
  ///  Enum to define whether in light or dark mode.
  ///  Middle mode not yet supported.
  ///  </summary>
  TJDColorMode = (cmLight, cmMedium, cmDark);

  ///  <summary>
  ///  Hue value of an HSB color value.
  ///  <br/>Min: 0.0
  ///  <br/>Max: 360.0
  ///  </summary>
  TJDCHue = record
  private
    FValue: Double;
  public
    class operator Implicit(Value: TJDCHue): Double;
    class operator Implicit(Value: Double): TJDCHue;
    class operator Negative(a: TJDCHue): TJDCHue;
    class operator Positive(a: TJDCHue): TJDCHue;
    class operator Inc(a: TJDCHue): TJDCHue;
    class operator Dec(a: TJDCHue): TJDCHue;
    class operator Equal(a: TJDCHue; b: TJDCHue): Boolean;
    class operator NotEqual(a: TJDCHue; b: TJDCHue): Boolean;
    class operator GreaterThan(a: TJDCHue; b: TJDCHue): Boolean;
    class operator GreaterThanOrEqual(a: TJDCHue; b: TJDCHue): Boolean;
    class operator LessThan(a: TJDCHue; b: TJDCHue): Boolean;
    class operator LessThanOrEqual(a: TJDCHue; b: TJDCHue): Boolean;
    class operator Add(a: TJDCHue; b: TJDCHue): TJDCHue;
    class operator Subtract(a: TJDCHue; b: TJDCHue): TJDCHue;
    class operator Multiply(a: TJDCHue; b: TJDCHue): TJDCHue;
    class operator Divide(a: TJDCHue; b: TJDCHue): TJDCHue;
  end;

  ///  <summary>
  ///  Saturation of an HSB color value.
  ///  <br/>Min: 0.0
  ///  <br/>Max: 100.0
  ///  </summary>
  TJDCSaturation = record
  private
    FValue: Double;
  public
    class operator Implicit(Value: TJDCSaturation): Double;
    class operator Implicit(Value: Double): TJDCSaturation;
    class operator Negative(a: TJDCSaturation): TJDCSaturation;
    class operator Positive(a: TJDCSaturation): TJDCSaturation;
    class operator Inc(a: TJDCSaturation): TJDCSaturation;
    class operator Dec(a: TJDCSaturation): TJDCSaturation;
    class operator Equal(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator NotEqual(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator GreaterThan(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator GreaterThanOrEqual(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator LessThan(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator LessThanOrEqual(a: TJDCSaturation; b: TJDCSaturation): Boolean;
    class operator Add(a: TJDCSaturation; b: TJDCSaturation): TJDCSaturation;
    class operator Subtract(a: TJDCSaturation; b: TJDCSaturation): TJDCSaturation;
    class operator Multiply(a: TJDCSaturation; b: TJDCSaturation): TJDCSaturation;
    class operator Divide(a: TJDCSaturation; b: TJDCSaturation): TJDCSaturation;
  end;

  ///  <summary>
  ///  Brightness (Value) of an HSB color value.
  ///  <br/>Min: 0.0
  ///  <br/>Max: 100.0
  ///  </summary>
  TJDCBrightness = record
  private
    FValue: Double;
  public
    class operator Implicit(Value: TJDCBrightness): Double;
    class operator Implicit(Value: Double): TJDCBrightness;
    class operator Negative(a: TJDCBrightness): TJDCBrightness;
    class operator Positive(a: TJDCBrightness): TJDCBrightness;
    class operator Inc(a: TJDCBrightness): TJDCBrightness;
    class operator Dec(a: TJDCBrightness): TJDCBrightness;
    class operator Equal(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator NotEqual(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator GreaterThan(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator GreaterThanOrEqual(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator LessThan(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator LessThanOrEqual(a: TJDCBrightness; b: TJDCBrightness): Boolean;
    class operator Add(a: TJDCBrightness; b: TJDCBrightness): TJDCBrightness;
    class operator Subtract(a: TJDCBrightness; b: TJDCBrightness): TJDCBrightness;
    class operator Multiply(a: TJDCBrightness; b: TJDCBrightness): TJDCBrightness;
    class operator Divide(a: TJDCBrightness; b: TJDCBrightness): TJDCBrightness;
  end;

  ///  <summary>
  ///  Encapsulates an RGB value, and can be modified using
  ///  CMYK and HSB. Also cast to/from HTML color string.
  ///  Can be implicitly cast with TColor.
  ///  </summary>
  TJDColor = record
  private
    //Fundamentally behind the scenes, we use RGB here...
    FRed: Byte;
    FGreen: Byte;
    FBlue: Byte;
    //FAlpha: Byte;

    //TODO: Support JD Standard colors
    //  At this point, may not be necessary since it's in TJDColorRef.
    //TODO: Support Alpha channel
    //TODO: Support GDI+ colors
    //TODO: Support central user-defined color list where dev can
    //  predefine as many color references as their heart desires,
    //  give each one a unique name, and reference them here...

    //function GetAlpha: Byte;
    //procedure SetAlpha(const Value: Byte);

    function GetHue: TJDCHue;
    function GetSaturation: TJDCSaturation;
    function GetBrightness: TJDCBrightness;
    procedure SetHue(const Value: TJDCHue);
    procedure SetSaturation(const Value: TJDCSaturation);
    procedure SetBrightness(const Value: TJDCBrightness);

    function GetCyan: Byte;
    function GetMagenta: Byte;
    function GetYellow: Byte;
    function GetBlack: Byte;
    procedure SetCyan(const Value: Byte);
    procedure SetMagenta(const Value: Byte);
    procedure SetYellow(const Value: Byte);
    procedure SetBlack(const Value: Byte);

    function GetHTML: String;
    procedure SetHTML(const Value: String);
    function GetGDIPColor: Cardinal;
  public
    class operator Implicit(Value: TJDColor): TColor;
    class operator Implicit(Value: TColor): TJDColor;
    class operator Equal(a: TJDColor; b: TJDColor): Boolean;
    class operator NotEqual(a: TJDColor; b: TJDColor): Boolean;

    //property Alpha: Byte read GetAlpha write SetAlpha;

    property Red: Byte read FRed write FRed;
    property Green: Byte read FGreen write FGreen;
    property Blue: Byte read FBlue write FBlue;

    property Hue: TJDCHue read GetHue write SetHue;
    property Saturation: TJDCSaturation read GetSaturation write SetSaturation;
    property Brightness: TJDCBrightness read GetBrightness write SetBrightness;

    property Cyan: Byte read GetCyan write SetCyan;
    property Magenta: Byte read GetMagenta write SetMagenta;
    property Yellow: Byte read GetYellow write SetYellow;
    property Black: Byte read GetBlack write SetBlack;

    {$IFDEF USE_GDIP}
    property GDIPColor: Cardinal read GetGDIPColor;
    {$ENDIF}
    property HTML: String read GetHTML write SetHTML;
  end;

  TJDColorRef = class;

  TJDColorRGBRef = class(TPersistent)
  private
    FOwner: TJDColorRef;
    function GetB: Byte;
    function GetG: Byte;
    function GetR: Byte;
    procedure SetB(const Value: Byte);
    procedure SetG(const Value: Byte);
    procedure SetR(const Value: Byte);
  public
    constructor Create(AOwner: TJDColorRef);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property R: Byte read GetR write SetR stored False;
    property G: Byte read GetG write SetG stored False;
    property B: Byte read GetB write SetB stored False;
  end;

  TJDColorHSVRef = class(TPersistent)
  private
    FOwner: TJDColorRef;
    function GetH: TJDCHue;
    function GetS: TJDCSaturation;
    function GetV: TJDCBrightness;
    procedure SetH(const Value: TJDCHue);
    procedure SetS(const Value: TJDCSaturation);
    procedure SetV(const Value: TJDCBrightness);
  public
    constructor Create(AOwner: TJDColorRef);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property H: TJDCHue read GetH write SetH stored False;
    property S: TJDCSaturation read GetS write SetS stored False;
    property V: TJDCBrightness read GetV write SetV stored False;
  end;

  TJDColorCMYKRef = class(TPersistent)
  private
    FOwner: TJDColorRef;
    function GetC: Byte;
    function GetK: Byte;
    function GetM: Byte;
    function GetY: Byte;
    procedure SetC(const Value: Byte);
    procedure SetK(const Value: Byte);
    procedure SetM(const Value: Byte);
    procedure SetY(const Value: Byte);
  public
    constructor Create(AOwner: TJDColorRef);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property C: Byte read GetC write SetC stored False;
    property M: Byte read GetM write SetM stored False;
    property Y: Byte read GetY write SetY stored False;
    property K: Byte read GetK write SetK stored False;
  end;

  ///  <summary>
  ///  A selection of a color, interchangeable between
  ///  a JD standard color or a custom color.
  ///  </summary>
  TJDColorRef = class(TPersistent)
  private
    FStandardColor: TJDStandardColor;
    FColor: TColor;
    FUseStandardColor: Boolean;
    FRGB: TJDColorRGBRef;
    FHSV: TJDColorHSVRef;
    FCMYK: TJDColorCMYKRef;
    FOnChange: TNotifyEvent;
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
    procedure SetCMYK(const Value: TJDColorCMYKRef);
    procedure SetHSV(const Value: TJDColorHSVRef);
    procedure SetRGB(const Value: TJDColorRGBRef);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
    function GetJDColor: TJDColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read GetColor write SetColor;
    property StandardColor: TJDStandardColor read FStandardColor write SetStandardColor;
    property RGB: TJDColorRGBRef read FRGB write SetRGB stored False;
    property HSV: TJDColorHSVRef read FHSV write SetHSV stored False;
    property CMYK: TJDColorCMYKRef read FCMYK write SetCMYK stored False;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor;
  end;

  ///  <summary>
  ///  Global object to keep track of color themes throughout JDLib.
  ///  </summary>
  TJDColorManager = class(TObject)
  private
    FComponents: TObjectList<TJDMessageComponent>;
    FControls: TObjectList<TWinControl>;
    FBaseColor: TColor;
    FLtColors: TJDStandardColors;
    FMdColors: TJDStandardColors;
    FDkColors: TJDStandardColors;
    FColorMode: TJDColorMode;
    procedure SetBaseColor(const Value: TColor);
    function GetColor(Clr: TJDStandardColor): TColor;
    function GetColorNew(Mode: TJDColorMode; Clr: TJDStandardColor): TColor;
    procedure SetColorNew(Mode: TJDColorMode; Clr: TJDStandardColor;
      const Value: TColor);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invalidate;
    procedure RegisterComponent(AComponent: TJDMessageComponent);
    procedure UnregisterComponent(AComponent: TJDMessageComponent);
    procedure RegisterControl(AControl: TWinControl);
    procedure UnregisterControl(AControl: TWinControl);
  public
    procedure PopulateColors; virtual;
    property ColorMode: TJDColorMode read FColorMode;
    property BaseColor: TColor read FBaseColor write SetBaseColor;
    property Color[Clr: TJDStandardColor]: TColor read GetColor;
    property ColorNew[Mode: TJDColorMode; Clr: TJDStandardColor]: TColor
      read GetColorNew write SetColorNew;
  end;

  TJDCanvas = class(TPersistent)
  private
    FCanvas: TCanvas;
    FCreatedCanvas: Boolean;
    {$IFDEF USE_GDIP}
    FGPCanvas: TGPGraphics;
    FGPPen: TGPPen;
    FGPSolidBrush: TGPSolidBrush;
    {$ENDIF}
    FPainting: Boolean;
    FBrushColor: TJDColor;
    FPenColor: TJDColor;
    procedure SetBrushColor(const Value: TJDColor);
    procedure SetPenColor(const Value: TJDColor);
    procedure SetPenWidth(const Value: Single);
    function GetPenWidth: Single;
  public
    constructor Create(ACanvas: TCanvas);
    destructor Destroy; override;
    procedure BeginPaint;
    procedure EndPaint;
    property Canvas: TCanvas read FCanvas;
    {$IFDEF USE_GDIP}
    property GPCanvas: TGPGraphics read FGPCanvas;
    {$ENDIF}
    function ClipRect: TJDRect;
  published
    property BrushColor: TJDColor read FBrushColor write SetBrushColor;
    property PenColor: TJDColor read FPenColor write SetPenColor;
    property PenWidth: Single read GetPenWidth write SetPenWidth;
  end;

//Color related
function DetectColorMode(const AColor: TColor): TJDColorMode;
function RGBToHSV(R, G, B: Byte; var H, S, V: Double): Boolean;
function HSVToRGB(H, S, V: Double; var R, G, B: Byte): Boolean;
function ColorToHtml(Color: TColor): string;
function ColorToHtml2(Clr: TColor): string;
function HtmlToColor(Color: string): TColor;
function TweakColor(const AColor: TColor; const Diff: Integer): TColor;

//General graphics related
procedure DrawParentImage(Control: TControl; Dest: TCanvas);
function PointAroundCenter(Center: TJDPoint; Distance: Single; Degrees: Single;
  OvalOffset: Single = 1): TJDPoint;
function DrawTextJD(hDC: HDC; Str: String;
  var lpRect: TJDRect; uFormat: UINT): Integer;

{$IFDEF USE_GDIP}
function RectToGPRect(R: TRect): TGPRectF;
function ColorToGPColor(C: TColor): Cardinal;
{$ENDIF}

///  <summary>
///  Global access to central color manager
///  </summary>
function ColorManager: TJDColorManager;

implementation

uses
  Math;

var
  _ColorManager: TJDColorManager;

function ColorManager: TJDColorManager;
begin
  Result:= _ColorManager;
end;

{$IFDEF USE_GDIP}
function RectToGPRect(R: TRect): TGPRectF;
begin
  Result.X:= R.Left;
  Result.Y:= R.Top;
  Result.Width:= R.Width;
  Result.Height:= R.Height;
end;

function ColorToGPColor(C: TColor): Cardinal;
begin
  Result:= MakeColor(GetRValue(C), GetGValue(C), GetBValue(C));
end;
{$ENDIF}

function DrawTextJD(hDC: HDC; Str: String;
  var lpRect: TJDRect; uFormat: UINT): Integer;
var
  R: TRect;
begin
  R:= lpRect;
  Result:= DrawText(hDC, PChar(Str), Length(Str), R, uFormat);
  lpRect:= R;
end;

function ColorToHtml(Color: TColor): string;
var
  COL: LongInt;
begin
  COL := ColorToRGB(Color);
  { first convert TColor to Integer to remove the higher bits }
  { erst TColor zu Integer, da die Unnötigen höheren Bit entfernt werden }
  Result := '#' + IntToHex(COL and $FF, 2) +
    IntToHex(COL shr 8 and $FF, 2) +
    IntToHex(COL shr 16 and $FF, 2);
end;

function ColorToHtml2(Clr: TColor): string;
begin
  Result := IntToHex(clr, 6);
  Result := '#' + Copy(Result, 5, 2) + Copy(Result, 3, 2) + Copy(Result, 1, 2);
end;

function HtmlToColor(Color: string): TColor;
begin
  Result := StringToColor('$' + Copy(Color, 6, 2) + Copy(Color, 4, 2) + Copy(Color, 2, 2));
end;

procedure DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Point: TPoint;
begin
  //Makes the parent control draw itself within rect to resemble transparency
  with Control do begin
    if Parent = nil then Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Point);
    SetViewportOrgEx(DC, Point.X - Left, Point.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(WM_ERASEBKGND, DC, 0);
    Parent.Perform(WM_PAINT, DC, 0);
    RestoreDC(DC, SaveIndex);
  end;
end;

function TweakColor(const AColor: TColor; const Diff: Integer): TColor;
var
  R, G, B: Byte;
  D: Integer;
  Dir: Integer;
begin
  //Modifies color to slight offset
  //TODO: Change to HSV via TJDColor and adjust brightness instead...
  R:= GetRValue(AColor);
  G:= GetGValue(AColor);
  B:= GetBValue(AColor);
  D:= (R + G + B) div 3; //Calculate average per color channel
  if D >= (256 div 2) then begin //Compare whether it's light or dark
    Dir:= -Diff;
  end else begin
    Dir:= Diff;
  end;
  R:= IntRange(R + Dir, 0, 255);
  G:= IntRange(G + Dir, 0, 255);
  B:= IntRange(B + Dir, 0, 255);
  Result:= RGB(R, G, B);
end;

function DetectColorMode(const AColor: TColor): TJDColorMode;
var
  Clr: TJDColor;
begin
  //Determine whether color is light, dark, or middle
  Clr:= AColor;
  if Clr.Brightness <= 40 then
    Result:= cmDark
  else if Clr.Brightness >= 60 then
    Result:= cmLight
  else
    Result:= cmMedium;
end;

//H = Hue         (0.0..360.0) [0.0..1.0]
//S = Saturation  (0.0..100.0) [0.0..1.0]
//V = Brightness  (0.0..100.0) [0.0..1.0]

function RGBToHSV(R, G, B: Byte; var H, S, V: Double): Boolean;
var
  minRGB, maxRGB, delta: Double;
begin
  //Converts RGB color to HSV color
  h := 0.0;
  minRGB := Min(Min(R, G), B);
  maxRGB := Max(Max(R, G), B);
  delta := (maxRGB - minRGB);
  V := maxRGB;
  if (maxRGB <> 0.0) then
    S := 255.0 * delta / maxRGB
  else
    S := 0.0;
  if (S <> 0.0) then begin
    if R = maxRGB then
      H := (G - B) / delta
    else if G = maxRGB then
      H := 2.0 + (B - R) / delta
    else if B = maxRGB then
      H := 4.0 + (R - G) / delta
  end else
    H := -1.0;
  H := h * 60;
  if H < 0.0 then
    H := H + 360.0;

  //Changed to support 0.0..1.0 instead of 0.0..100.0
  //S := S * 100 / 255;
  //V := B * 100 / 255;
  S := S / 255;
  V := V / 255;

  Result:= True;
end;

function HSVToRGB(H, S, V: Double; var R, G, B: Byte): Boolean;
var
  i: Integer;
  f, p, q, t: Double;
  procedure CopyOutput(const RV, GV, BV: Double);
  const
    RGBmax = 255;
  begin
    R:= Round(RGBmax * RV);
    G:= Round(RGBmax * GV);
    B:= Round(RGBmax * BV);
  end;
begin
  Assert(InRange(H, 0.0, 1.0)); //Shouldn't this be up to 360?
  Assert(InRange(S, 0.0, 1.0));
  Assert(InRange(V, 0.0, 1.0));
  if S = 0.0 then begin
    // achromatic (grey)
    CopyOutput(B, B, B);
    Result:= True;
    exit;
  end;
  H := H * 6.0; // sector 0 to 5
  i := floor(H);
  f := H - i; // fractional part of H
  p := V * (1.0 - S);
  q := V * (1.0 - S * f);
  t := V * (1.0 - S * (1.0 - f));
  case i of
    0: CopyOutput(V, t, p);
    1: CopyOutput(q, V, p);
    2: CopyOutput(p, V, t);
    3: CopyOutput(p, q, V);
    4: CopyOutput(t, p, V);
    else CopyOutput(V, p, q);
  end;
  Result:= True;
end;

function PointAroundCenter(Center: TJDPoint; Distance: Single; Degrees: Single;
  OvalOffset: Single = 1): TJDPoint;
var
  Radians: Real;
begin
  //Oval support: https://stackoverflow.com/questions/8433443/modify-a-formula-from-calculating-around-a-circle-to-around-an-oval
  //Return point around a center point, based on angle and distance (radius)...
  //Convert angle from degrees to radians; Subtract 135 to bring position to 0 Degrees
  Radians:= (Degrees - 135) * Pi / 180;
  Result.X:= Distance*Cos(Radians) - Distance*Sin(Radians) + Center.X;
  Result.Y:= (Distance*Sin(Radians) + Distance*Cos(Radians)) / OvalOffset + Center.Y;
end;

{ TJDCHue }

class operator TJDCHue.Implicit(Value: TJDCHue): Double;
begin
  Result:= Value.FValue;
end;

class operator TJDCHue.Implicit(Value: Double): TJDCHue;
begin
  if (Value < 0.0) or (Value > 360.0) then
    raise EJDOutOfRange.Create('Hue value out of range');
  Result.FValue:= Value;
end;

class operator TJDCHue.Add(a, b: TJDCHue): TJDCHue;
begin
  Result:= Double(A) + Double(B);
end;

class operator TJDCHue.Dec(a: TJDCHue): TJDCHue;
begin
  Result:= Double(A) - 1;
end;

class operator TJDCHue.Divide(a, b: TJDCHue): TJDCHue;
begin
  Result:= Double(A) / Double(B);
end;

class operator TJDCHue.Equal(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) = Double(B);
end;

class operator TJDCHue.GreaterThan(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) > Double(B);
end;

class operator TJDCHue.GreaterThanOrEqual(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) > Double(B);
end;

class operator TJDCHue.Inc(a: TJDCHue): TJDCHue;
begin
  Result:= Double(A) + 1;
end;

class operator TJDCHue.LessThan(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) < Double(B);
end;

class operator TJDCHue.LessThanOrEqual(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) < Double(B);
end;

class operator TJDCHue.Multiply(a, b: TJDCHue): TJDCHue;
begin
  Result:= Double(A) * Double(B);
end;

class operator TJDCHue.Negative(a: TJDCHue): TJDCHue;
begin
  Result:= -Double(A);
end;

class operator TJDCHue.NotEqual(a, b: TJDCHue): Boolean;
begin
  Result:= Double(A) <> Double(B);
end;

class operator TJDCHue.Positive(a: TJDCHue): TJDCHue;
begin
  Result:= +Double(A);
end;

class operator TJDCHue.Subtract(a, b: TJDCHue): TJDCHue;
begin
  Result:= Double(A) - Double(B);
end;

{ TJDCSaturation }

class operator TJDCSaturation.Implicit(Value: TJDCSaturation): Double;
begin
  Result:= Value.FValue;
end;

class operator TJDCSaturation.Implicit(Value: Double): TJDCSaturation;
begin
  if (Value < 0.0) or (Value > 100.0) then
    raise EJDOutOfRange.Create('Saturation value out of range');
  Result.FValue:= Value;
end;

class operator TJDCSaturation.Add(a, b: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) + Double(B);
end;

class operator TJDCSaturation.Dec(a: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) - 1;
end;

class operator TJDCSaturation.Divide(a, b: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) / Double(B);
end;

class operator TJDCSaturation.Equal(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) = Double(B);
end;

class operator TJDCSaturation.GreaterThan(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) > Double(B);
end;

class operator TJDCSaturation.GreaterThanOrEqual(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) >= Double(B);
end;

class operator TJDCSaturation.Inc(a: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) + 1;
end;

class operator TJDCSaturation.LessThan(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) < Double(B);
end;

class operator TJDCSaturation.LessThanOrEqual(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) <= Double(B);
end;

class operator TJDCSaturation.Multiply(a, b: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) * Double(B);
end;

class operator TJDCSaturation.Negative(a: TJDCSaturation): TJDCSaturation;
begin
  Result:= -(Double(A));
end;

class operator TJDCSaturation.NotEqual(a, b: TJDCSaturation): Boolean;
begin
  Result:= Double(A) <> Double(B);
end;

class operator TJDCSaturation.Positive(a: TJDCSaturation): TJDCSaturation;
begin
  Result:= +Double(A);
end;

class operator TJDCSaturation.Subtract(a, b: TJDCSaturation): TJDCSaturation;
begin
  Result:= Double(A) - Double(B);
end;

{ TJDCBrightness }

class operator TJDCBrightness.Implicit(Value: TJDCBrightness): Double;
begin
  Result:= Value.FValue;
end;

class operator TJDCBrightness.Implicit(Value: Double): TJDCBrightness;
begin
  if (Value < 0.0) or (Value > 100.0) then
    raise EJDOutOfRange.Create('Brightness value out of range');
  Result.FValue:= Value;
end;

class operator TJDCBrightness.Add(a, b: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) + Double(B);
end;

class operator TJDCBrightness.Subtract(a, b: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) - Double(B);
end;

class operator TJDCBrightness.Dec(a: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) - 1;
end;

class operator TJDCBrightness.Divide(a, b: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) / Double(B);
end;

class operator TJDCBrightness.Equal(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) = Double(B);
end;

class operator TJDCBrightness.GreaterThan(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) > Double(B);
end;

class operator TJDCBrightness.GreaterThanOrEqual(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) >= Double(B);
end;

class operator TJDCBrightness.Inc(a: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) + 1;
end;

class operator TJDCBrightness.LessThan(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) < Double(B);
end;

class operator TJDCBrightness.LessThanOrEqual(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) <= Double(B);
end;

class operator TJDCBrightness.Multiply(a, b: TJDCBrightness): TJDCBrightness;
begin
  Result:= Double(A) * Double(B);
end;

class operator TJDCBrightness.Negative(a: TJDCBrightness): TJDCBrightness;
begin
  Result:= -Double(A);
end;

class operator TJDCBrightness.NotEqual(a, b: TJDCBrightness): Boolean;
begin
  Result:= Double(A) <> Double(B);
end;

class operator TJDCBrightness.Positive(a: TJDCBrightness): TJDCBrightness;
begin
  Result:= +Double(A);
end;

{ TJDColor }

class operator TJDColor.Implicit(Value: TJDColor): TColor;
begin
  with Value do
    Result:= RGB(Red, Green, Blue);
end;

class operator TJDColor.Implicit(Value: TColor): TJDColor;
begin
  with Result do begin
    FRed:= GetRValue(Value);
    FGreen:= GetGValue(Value);
    FBlue:= GetBValue(Value);
  end;
end;

class operator TJDColor.NotEqual(a, b: TJDColor): Boolean;
begin
  Result:= TColor(A) <> TColor(B);
end;

function TJDColor.GetHue: TJDCHue;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= H;
end;

function TJDColor.GetSaturation: TJDCSaturation;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= S;
end;

function TJDColor.GetBrightness: TJDCBrightness;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= V;
end;

function TJDColor.GetCyan: Byte;
begin
  Result:= GetCValue(RGB(FRed, FGreen, FBlue));
end;

function TJDColor.GetGDIPColor: Cardinal;
begin
  //TODO: Alpha...
  Result:= GDIPAPI.MakeColor(255, FRed, FGreen, FBlue);
  //Result:= GDIPAPI.MakeColor(FAlpha, FRed, FGreen, FBlue);
end;

function TJDColor.GetMagenta: Byte;
begin
  Result:= GetMValue(RGB(FRed, FGreen, FBlue));
end;

function TJDColor.GetYellow: Byte;
begin
  Result:= GetYValue(RGB(FRed, FGreen, FBlue));
end;

class operator TJDColor.Equal(a, b: TJDColor): Boolean;
begin
  Result:= TColor(A) = TColor(B);
end;

function TJDColor.GetBlack: Byte;
begin
  Result:= GetKValue(RGB(FRed, FGreen, FBlue));
end;

procedure TJDColor.SetBrightness(const Value: TJDCBrightness);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  V:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TJDColor.SetHue(const Value: TJDCHue);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  H:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TJDColor.SetSaturation(const Value: TJDCSaturation);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  S:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TJDColor.SetCyan(const Value: Byte);
begin
  Self:= CMYK(Value, Magenta, Yellow, Black);
end;

procedure TJDColor.SetMagenta(const Value: Byte);
begin
  Self:= CMYK(Cyan, Value, Yellow, Black);
end;

procedure TJDColor.SetYellow(const Value: Byte);
begin
  Self:= CMYK(Cyan, Magenta, Value, Black);
end;

procedure TJDColor.SetBlack(const Value: Byte);
begin
  Self:= CMYK(Cyan, Magenta, Yellow, Value);
end;

function TJDColor.GetHTML: String;
begin
  Result:= ColorToHTML(Self);
end;

procedure TJDColor.SetHTML(const Value: String);
begin
  Self:= HTMLToColor(Value);
end;

{ TJDColorRef }

procedure TJDColorRef.Assign(Source: TPersistent);
begin
  if Source is TJDColorRef then begin
    FColor:= TJDColorRef(Source).FColor;
    FStandardColor:= TJDColorRef(Source).FStandardColor;
    FUseStandardColor:= TJDColorRef(Source).FUseStandardColor;
  end else
    inherited;
end;

constructor TJDColorRef.Create;
begin
  FRGB:= TJDColorRGBRef.Create(Self);
  FHSV:= TJDColorHSVRef.Create(Self);
  FCMYK:= TJDColorCMYKRef.Create(Self);
  FColor:= clBlack;
  FStandardColor:= fcNeutral;
  FUseStandardColor:= True;
end;

destructor TJDColorRef.Destroy;
begin
  FreeAndNil(FCMYK);
  FreeAndNil(FHSV);
  FreeAndNil(FRGB);
  inherited;
end;

function TJDColorRef.GetColor: TColor;
begin
  Result:= GetJDColor;
end;

function TJDColorRef.GetJDColor: TJDColor;
begin
  if FUseStandardColor then
    Result:= ColorManager.Color[FStandardColor]
  else
    Result:= FColor;
end;

procedure TJDColorRef.Invalidate;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TJDColorRef.SetColor(const Value: TColor);
begin
  FUseStandardColor:= False;
  FColor := Value;
  Invalidate;
end;

procedure TJDColorRef.SetCMYK(const Value: TJDColorCMYKRef);
begin
  FCMYK.Assign(Value);
  Invalidate;
end;

procedure TJDColorRef.SetHSV(const Value: TJDColorHSVRef);
begin
  FHSV.Assign(Value);
  Invalidate;
end;

procedure TJDColorRef.SetRGB(const Value: TJDColorRGBRef);
begin
  FRGB.Assign(Value);
  Invalidate;
end;

procedure TJDColorRef.SetStandardColor(const Value: TJDStandardColor);
begin
  FStandardColor := Value;
  Invalidate;
end;

procedure TJDColorRef.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor := Value;
  Invalidate;
end;

{ TJDColorManager }

constructor TJDColorManager.Create;
begin
  FComponents:= TObjectList<TJDMessageComponent>.Create(False);
  FControls:= TObjectList<TWinControl>.Create(False);
  FBaseColor:= clWhite;
  PopulateColors;
  Invalidate;
end;

destructor TJDColorManager.Destroy;
begin
  FControls.Free;
  FComponents.Free;
  inherited;
end;

procedure TJDColorManager.Invalidate;
var
  X: Integer;
begin
  try
    //Automatically determine color mode based on base color's brightness...
    FColorMode:= DetectColorMode(FBaseColor);

    //Broadcast change to all registered components...
    for X := 0 to FComponents.Count-1 do begin
      SendMessage(FComponents[X].Handle, WM_JD_COLORCHANGE, 0, 0);
    end;

    //Broadcast change to all registered controls...
    for X := 0 to FControls.Count-1 do begin
      SendMessage(FControls[X].Handle, WM_JD_COLORCHANGE, 0, 0);
    end;

  except
    on E: Exception do begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TJDColorManager.PopulateColors;
begin
  //Light versions of colors
  FLtColors[fcNeutral]:= LIGHT_NEUTRAL;
  FLtColors[fcGray]:= LIGHT_GRAY;
  FLtColors[fcBlue]:= LIGHT_BLUE;
  FLtColors[fcGreen]:= LIGHT_GREEN;
  FLtColors[fcRed]:= LIGHT_RED;
  FLtColors[fcYellow]:= LIGHT_YELLOW;
  FLtColors[fcOrange]:= LIGHT_ORANGE;
  FLtColors[fcPurple]:= LIGHT_PURPLE;

  //Medium versions of colors
  FMdColors[fcNeutral]:= MED_NEUTRAL;
  FMdColors[fcGray]:= MED_GRAY;
  FMdColors[fcBlue]:= MED_BLUE;
  FMdColors[fcGreen]:= MED_GREEN;
  FMdColors[fcRed]:= MED_RED;
  FMdColors[fcYellow]:= MED_YELLOW;
  FMdColors[fcOrange]:= MED_ORANGE;
  FMdColors[fcPurple]:= MED_PURPLE;

  //Dark versions of colors
  FDkColors[fcNeutral]:= DARK_NEUTRAL;
  FDkColors[fcGray]:= DARK_GRAY;
  FDkColors[fcBlue]:= DARK_BLUE;
  FDkColors[fcGreen]:= DARK_GREEN;
  FDkColors[fcRed]:= DARK_RED;
  FDkColors[fcYellow]:= DARK_YELLOW;
  FDkColors[fcOrange]:= DARK_ORANGE;
  FDkColors[fcPurple]:= DARK_PURPLE;

end;

procedure TJDColorManager.SetBaseColor(const Value: TColor);
begin
  FBaseColor:= TColor(Value);
  Invalidate;
end;

function TJDColorManager.GetColor(Clr: TJDStandardColor): TColor;
begin
  case FColorMode of
    cmLight:  Result:= GetColorNew(cmDark, Clr);
    cmMedium: Result:= GetColorNew(cmMedium, Clr);
    cmDark:   Result:= GetColorNew(cmLight, Clr);
    else      Result:= GetColorNew(cmDark, Clr);
  end;
end;

function TJDColorManager.GetColorNew(Mode: TJDColorMode;
  Clr: TJDStandardColor): TColor;
begin
  case Mode of
    cmLight:  Result:= FLtColors[Clr];
    cmMedium: Result:= FMdColors[Clr];
    cmDark:   Result:= FDkColors[Clr];
    else      Result:= FDkColors[Clr];
  end;
end;

procedure TJDColorManager.SetColorNew(Mode: TJDColorMode; Clr: TJDStandardColor;
  const Value: TColor);
begin
  case Mode of
    cmLight:  FLtColors[Clr]:= Value;
    cmMedium: FMdColors[Clr]:= Value;
    cmDark:   FDkColors[Clr]:= Value;
  end;
end;

procedure TJDColorManager.RegisterComponent(AComponent: TJDMessageComponent);
begin
  FComponents.Add(AComponent);
end;

procedure TJDColorManager.UnregisterComponent(AComponent: TJDMessageComponent);
begin
  FComponents.Delete(FComponents.IndexOf(AComponent));
end;

procedure TJDColorManager.RegisterControl(AControl: TWinControl);
begin
  FControls.Add(AControl)
end;

procedure TJDColorManager.UnregisterControl(AControl: TWinControl);
begin
  FControls.Delete(FControls.IndexOf(AControl));
end;

{ TJDCanvas }

function TJDCanvas.ClipRect: TJDRect;
begin
  Result:= FCanvas.ClipRect;
end;

constructor TJDCanvas.Create(ACanvas: TCanvas);
begin
  if Assigned(ACanvas) then begin
    FCanvas:= ACanvas;
    FCreatedCanvas:= False;
  end else begin
    FCanvas:= TCanvas.Create;
    //TODO
    FCreatedCanvas:= True;
  end;
  FGPPen:= TGPPen.Create;
  FGPSolidBrush:= TGPSolidBrush.Create;
end;

destructor TJDCanvas.Destroy;
begin
  FreeAndNil(FGPSolidBrush);
  FreeAndNil(FGPPen);
  if FCreatedCanvas then
    FreeAndNil(FCanvas);
  inherited;
end;

procedure TJDCanvas.BeginPaint;
begin
  FPainting:= True;
  FGPCanvas:= TGPGraphics.Create(FCanvas.Handle);
end;

procedure TJDCanvas.EndPaint;
begin
  FPainting:= False;
  FreeAndNil(FGPCanvas);
end;

function TJDCanvas.GetPenWidth: Single;
begin
  Result:= FGPPen.GetWidth;
end;

procedure TJDCanvas.SetBrushColor(const Value: TJDColor);
begin
  FBrushColor:= Value;
  FGPSolidBrush.SetColor(ColorToGPColor(Value));
end;

procedure TJDCanvas.SetPenColor(const Value: TJDColor);
begin
  FPenColor:= Value;
  FGPPen.SetColor(ColorToGPColor(Value));
end;

procedure TJDCanvas.SetPenWidth(const Value: Single);
begin
  FGPPen.SetWidth(Value);
end;

{ TJDColorRGBRef }

constructor TJDColorRGBRef.Create(AOwner: TJDColorRef);
begin
  FOwner:= AOwner;

end;

destructor TJDColorRGBRef.Destroy;
begin

  inherited;
end;

function TJDColorRGBRef.GetB: Byte;
begin
  Result:= FOwner.GetJDColor.Blue;
end;

function TJDColorRGBRef.GetG: Byte;
begin
  Result:= FOwner.GetJDColor.Green;
end;

function TJDColorRGBRef.GetR: Byte;
begin
  Result:= FOwner.GetJDColor.Red;
end;

procedure TJDColorRGBRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDColorRGBRef.SetB(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Blue:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorRGBRef.SetG(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Green:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorRGBRef.SetR(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Red:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

{ TJDColorHSVRef }

constructor TJDColorHSVRef.Create(AOwner: TJDColorRef);
begin
  FOwner:= AOwner;

end;

destructor TJDColorHSVRef.Destroy;
begin

  inherited;
end;

function TJDColorHSVRef.GetH: TJDCHue;
begin
  Result:= FOwner.GetJDColor.Hue;
end;

function TJDColorHSVRef.GetS: TJDCSaturation;
begin
  Result:= FOwner.GetJDColor.Saturation;
end;

function TJDColorHSVRef.GetV: TJDCBrightness;
begin
  Result:= FOwner.GetJDColor.Brightness;
end;

procedure TJDColorHSVRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDColorHSVRef.SetH(const Value: TJDCHue);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Hue:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorHSVRef.SetS(const Value: TJDCSaturation);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Saturation:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorHSVRef.SetV(const Value: TJDCBrightness);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Brightness:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

{ TJDColorCMYKRef }

constructor TJDColorCMYKRef.Create(AOwner: TJDColorRef);
begin
  FOwner:= AOwner;

end;

destructor TJDColorCMYKRef.Destroy;
begin

  inherited;
end;

function TJDColorCMYKRef.GetC: Byte;
begin
  Result:= FOwner.GetJDColor.Cyan;
end;

function TJDColorCMYKRef.GetK: Byte;
begin
  Result:= FOwner.GetJDColor.Black;
end;

function TJDColorCMYKRef.GetM: Byte;
begin
  Result:= FOwner.GetJDColor.Magenta;
end;

function TJDColorCMYKRef.GetY: Byte;
begin
  Result:= FOwner.GetJDColor.Yellow;
end;

procedure TJDColorCMYKRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDColorCMYKRef.SetC(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Cyan:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorCMYKRef.SetK(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Black:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorCMYKRef.SetM(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Magenta:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorCMYKRef.SetY(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Yellow:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

initialization
  _ColorManager:= TJDColorManager.Create;
finalization
  _ColorManager.Free;
end.


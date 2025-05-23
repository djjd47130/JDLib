﻿unit JD.Graphics;

//Delphi class operators: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Operator_Overloading_(Delphi)

//Code review: https://codereview.stackexchange.com/questions/79214/converting-delphi-colors-between-tcolor-rgb-cmyk-and-hsv

//32bit Bitmap Alpha: https://stackoverflow.com/questions/10147932/how-change-the-alpha-value-of-a-specific-color-in-a-32-bit-tbitmap

interface

{$IF CompilerVersion >= 20.0} // 20.0 corresponds to Delphi 2009
  {$DEFINE USE_GDIP}
{$IFEND}

{.$DEFINE JD_ALPHA}

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.ImgList, Vcl.Dialogs
  {$IFDEF USE_GDIP}
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  {$ENDIF}
  , JD.Common //JD.Common should NOT use any other JD related units!
  , JD.SuperObject
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
  ///  An array of TColor values indexed by TJDStandardColor values.
  ///  </summary>
  TJDStandardColors = array[TJDStandardColor] of TColor;

  ///  <summary>
  ///  Enum to define whether in light or dark mode.
  ///  Middle mode not yet supported.
  ///  </summary>
  TJDColorMode = (cmLight, cmMedium, cmDark);


////////////////////////////////////////////////////////////////////////////////
/// TJDColor - Encapsulating various approaches to color management together
////////////////////////////////////////////////////////////////////////////////


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
    {$IFDEF JD_ALPHA}
    FAlpha: Byte;
    {$ENDIF}
    

    //TODO: Support JD Standard colors
    //  At this point, may not be necessary since it's in TJDColorRef.
    //TODO: Support Alpha channel
    //TODO: Support GDI+ colors
    //TODO: Support central user-defined color list where dev can
    //  predefine as many color references as their heart desires,
    //  give each one a unique name, and reference them here...

    {$IFDEF JD_ALPHA}
    function GetAlpha: Byte;
    procedure SetAlpha(const Value: Byte);
    {$ENDIF}

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
  public
    class operator Implicit(Value: TJDColor): TColor;
    class operator Implicit(Value: TColor): TJDColor;
    class operator Equal(a: TJDColor; b: TJDColor): Boolean;
    class operator NotEqual(a: TJDColor; b: TJDColor): Boolean;

    function GetGDIPColor(Alpha: Byte = 255): Cardinal;

    {$IFDEF JD_ALPHA}
    property Alpha: Byte read GetAlpha write SetAlpha;
    {$ENDIF}

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
    //property GDIPColor: Cardinal read GetGDIPColor;
    {$ENDIF}
    property HTML: String read GetHTML write SetHTML;
  end;

  TJDColorArray = array of TJDColor;

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
    function GetH: Word;
    function GetS: Byte;
    function GetV: Byte;
    procedure SetH(const Value: Word);
    procedure SetS(const Value: Byte);
    procedure SetV(const Value: Byte);
  public
    constructor Create(AOwner: TJDColorRef);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property H: Word read GetH write SetH stored False;
    property S: Byte read GetS write SetS stored False;
    property V: Byte read GetV write SetV stored False;
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
  ///  A selection of a color with several customizable options.
  ///  Meant to be used as a published property on custom controls.
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
    function GetColor: TColor; virtual;
    procedure SetColor(const Value: TColor); virtual;
    procedure SetStandardColor(const Value: TJDStandardColor); virtual;
    procedure SetUseStandardColor(const Value: Boolean); virtual;
    procedure SetCMYK(const Value: TJDColorCMYKRef); virtual;
    procedure SetHSV(const Value: TJDColorHSVRef); virtual;
    procedure SetRGB(const Value: TJDColorRGBRef); virtual;
    function IsStandardColorStored: Boolean;
    function IsMainColorStored: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate; virtual;
    function GetJDColor: TJDColor; virtual;
    function GetGDIPColor(Alpha: Byte = 255): Cardinal;

    function SaveToJSON: ISuperObject; virtual;
    procedure LoadFromJSON(O: ISuperObject); virtual;

    function SaveToString: String; virtual;
    procedure LoadFromString(S: String); virtual;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read GetColor write SetColor stored IsMainColorStored;
    property RGB: TJDColorRGBRef read FRGB write SetRGB stored False;
    property HSV: TJDColorHSVRef read FHSV write SetHSV stored False;
    property CMYK: TJDColorCMYKRef read FCMYK write SetCMYK stored False;
    property StandardColor: TJDStandardColor read FStandardColor write SetStandardColor stored IsStandardColorStored;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor stored True;
  end;

  ///  <summary>
  ///  A selection of a color with several customizable options
  ///  including an Alpha transparency channel.
  ///  Meant to be used as a published property on custom controls.
  ///  </summary>
  TJDAlphaColorRef = class(TJDColorRef)
  private
    FAlpha: Byte;
    procedure SetAlpha(const Value: Byte);
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    function GetJDColor: TJDColor; override;
    {$IFDEF USE_GDIP}
    function GDIPColor: TGPColor;
    {$ENDIF}
  published
    property Alpha: Byte read FAlpha write SetAlpha;
  end;




////////////////////////////////////////////////////////////////////////////////
/// NEW CONCEPT - Dynamically add colors referenced by name
////////////////////////////////////////////////////////////////////////////////

  TJDColorItem = class;
  TJDColorItems = class;
  TJDColorList = class;

  TJDColorName = String; //TODO: Create property editor similar to TColor drop-down

  TJDColorItemEvent = procedure(Sender: TObject; Item: TJDColorItem) of object;

  TJDColorItem = class(TCollectionItem)
  private
    FName: String;
    FColor: TJDColorRef;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TJDColorRef);
    procedure SetName(const Value: String);
    function GenerateUniqueName: String;
    procedure ColorChanged(Sender: TObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
    function GetDisplayName: String; override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TJDColorRef read FColor write SetColor;
    property Name: String read FName write SetName;
  end;

  TJDColorItems = class(TOwnedCollection)
  private
    FOwnerComponent: TJDColorList;
  protected
  public
    constructor Create(AOwner: TPersistent); reintroduce;
    destructor Destroy; override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  end;

  TJDColorList = class(TComponent)
  private
    FColors: TJDColorItems;
    FOnChange: TJDColorItemEvent;
    FOnItemAdded: TJDColorItemEvent;
    FOnItemDeleted: TJDColorItemEvent;
    FOnItemChanged: TJDColorItemEvent;
    procedure SetColors(const Value: TJDColorItems);
    procedure ItemNotify(Sender: TObject; Item: TCollectionItem; Action: TCollectionNotification);
  protected
    procedure Changed(Item: TJDColorItem); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Colors: TJDColorItems read FColors write SetColors;
    property OnChange: TJDColorItemEvent read FOnChange write FOnChange;
    property OnItemAdded: TJDColorItemEvent read FOnItemAdded write FOnItemAdded;
    property OnItemDeleted: TJDColorItemEvent read FOnItemDeleted write FOnItemDeleted;
    property OnItemChanged: TJDColorItemEvent read FOnItemChanged write FOnItemChanged;
  end;






  ///  <summary>
  ///  Global object to keep track of color themes throughout JDLib.
  ///  - Single instance accessible via "ColorManager" global variable.
  ///  - BaseColor: The main background color to be used to determine color mode.
  ///  - ColorMode: Controls whether in Light, Dark, or Medium light modes.
  ///  - BaseColor: The main background color to be used to determine color mode
  ///    and use for masks.
  ///  - Color[TJDStandardColor]: Access to read/write internal standard color value.
  ///  - ColorNew[TJDColorMode]: New version of Color.
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









////////////////////////////////////////////////////////////////////////////////
// Color related functions
////////////////////////////////////////////////////////////////////////////////

/// <summary>
/// Determines the color mode based on currently active theme's base color
/// </summary>
function DetectColorMode(const AColor: TColor): TJDColorMode;

/// <summary>
/// Converts RGB color to HSV color
/// </summary>
function RGBToHSV(R, G, B: Byte; var H, S, V: Double): Boolean;

/// <summary>
/// Converts HSV color to RGB color
/// </summary>
//function HSVToRGB(H, S, V: Double; var R, G, B: Byte): Boolean;
procedure HSVToRGB(H, S, V: Double; out R, G, B: Byte);

/// <summary>
/// Converts RGB color to HTML color
/// </summary>
function ColorToHtml(Color: TColor): string;

/// <summary>
/// Converts RGB color to HTML color
/// </summary>
function ColorToHtml2(Clr: TColor): string;

/// <summary>
/// Converts HTML color to RGB color
/// </summary>
function HtmlToColor(Color: string): TColor;

/// <summary>
/// Tweaks the brightness of a given color
/// </summary>
function TweakColor(const AColor: TColor; const Diff: Integer): TColor;

/// <summary>
/// Returns an array of colors ranging between 2 specified colors.
/// </summary>
function GenerateColorGradient(StartColor, EndColor: TJDColor; Steps: Integer): TArray<TJDColor>;

/// <summary>
/// Returns an array of colors ranging between multiple specified colors.
/// </summary>
function GenerateMultiColorGradient(Colors: TArray<TJDColor>; Steps: Integer): TArray<TJDColor>;


function ColorFade(const ASource: TColor; const ACount: Integer; const Shift: Integer): TJDColorArray; overload;

function ColorFade(const ASource: TColor; const Shift: Integer): TJDColor; overload;

function CreateGPCanvas(const DC: HDC): TGPGraphics;

////////////////////////////////////////////////////////////////////////////////
// General graphics related functions
////////////////////////////////////////////////////////////////////////////////

/// <summary>
/// Restricts an integer value within the range of a byte.
/// </summary>
function ClampByte(Value: Integer): Byte;

/// <summary>
/// Draws a control's parent image in a given canvas for a transparency effect.
/// </summary>
procedure DrawParentImage(Control: TControl; Dest: TCanvas);

/// <summary>
/// Determines a point around a given point at a given radius
/// </summary>
function PointAroundCenter(Center: TJDPoint; Distance: Single; Degrees: Single;
  OvalOffset: Single = 1): TJDPoint;

/// <summary>
/// Draws text to a given canvas with a given format
/// </summary>
function DrawTextJD(hDC: HDC; Str: String;
  var lpRect: TJDRect; uFormat: UINT): Integer;

{$IFDEF USE_GDIP}
//TODO: Move into JD.Common with TJDPoint and TJDRect...
//function PointToGPPoint(P: TPoint): TGPPointF;
function RectToGPRect(R: TRect): TGPRectF;
function ColorToGPColor(C: TColor): Cardinal;
{$ENDIF}

///  <summary>
///  Global access to central color manager
///  </summary>
function ColorManager: TJDColorManager;

implementation

uses
  System.Math, System.StrUtils;

var
  _ColorManager: TJDColorManager;

function ColorManager: TJDColorManager;
begin
  Result:= _ColorManager;
end;

function GetAValue(Color: TColor): Byte;
begin
  Result := (Color shr 24) and $FF;
end;

function SetAValue(Color: TColor; A: Byte): TColor;
begin
  Result := (Color and $00FFFFFF) or (A shl 24);
end;

{$IFDEF JD_ALPHA}
function RGBA(R, G, B, A: Byte): TColor;
begin
  //Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
  Result := (A shl 24) or (B shl 16) or (G shl 8) or R;
end;
{$ENDIF}

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
  { erst TColor zu Integer, da die Unn�tigen h�heren Bit entfernt werden }
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

function ClampByte(Value: Integer): Byte;
begin
  if Value < 0 then
    Result := 0
  else if Value > 255 then
    Result := 255
  else
    Result := Value;
end;

function GenerateColorGradient(StartColor, EndColor: TJDColor; Steps: Integer): TArray<TJDColor>;
var
  i: Integer;
  RStart, GStart, BStart: Byte;
  REnd, GEnd, BEnd: Byte;
  RStep, GStep, BStep: Double;
  Gradient: TArray<TJDColor>;
begin
  SetLength(Gradient, Steps);

  // Extract RGB values from the start and end colors
  RStart := StartColor.Red;
  GStart := StartColor.Green;
  BStart := StartColor.Blue;

  REnd := EndColor.Red;
  GEnd := EndColor.Green;
  BEnd := EndColor.Blue;

  // Calculate step increments for each color component
  RStep := (REnd - RStart) / (Steps - 1);
  GStep := (GEnd - GStart) / (Steps - 1);
  BStep := (BEnd - BStart) / (Steps - 1);

  // Generate the gradient
  for i := 0 to Steps - 1 do begin
    Gradient[i].Red := ClampByte(Round(RStart + (RStep * i)));
    Gradient[i].Green := ClampByte(Round(GStart + (GStep * i)));
    Gradient[i].Blue := ClampByte(Round(BStart + (BStep * i)));
    {$IFDEF JD_ALPHA}
    Gradient[i].Alpha := 255; // Full opacity, adjust if needed
    {$ENDIF}
  end;

  Result := Gradient;
end;

function GenerateMultiColorGradient(Colors: TArray<TJDColor>; Steps: Integer): TArray<TJDColor>;
var
  i, SegmentSteps, StartIndex: Integer;
  PartialGradient: TArray<TJDColor>;
  TotalSteps, CurrentStep: Integer;
begin
  if Length(Colors) < 2 then
    raise Exception.Create('GenerateMultiColorGradient requires at least two colors.');

  TotalSteps := Steps * (Length(Colors) - 1); // Total steps across all segments
  SetLength(Result, TotalSteps);

  CurrentStep := 0;

  // Loop through each pair of consecutive colors
  for i := 0 to High(Colors) - 1 do begin
    SegmentSteps := Steps; // Number of steps for this segment

    // Generate the gradient for this pair
    PartialGradient := GenerateColorGradient(Colors[i], Colors[i + 1], SegmentSteps);

    // Append the partial gradient to the result
    for StartIndex := 0 to High(PartialGradient) do begin
      Result[CurrentStep] := PartialGradient[StartIndex];
      Inc(CurrentStep);
    end;
  end;
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

procedure HSVToRGB(H, S, V: Double; out R, G, B: Byte);
var
  C, X, M, HPrime: Double;
  R_, G_, B_: Double;
begin
  Assert((H >= 0) and (H <= 360), 'Hue must be in the range 0-360');
  Assert((S >= 0) and (S <= 100), 'Saturation must be in the range 0-100');
  Assert((V >= 0) and (V <= 100), 'Brightness must be in the range 0-100');

  // Normalize S and V to 0-1 range
  S := S / 100;
  V := V / 100;

  HPrime := H / 60;
  C := V * S;
  X := C * (1 - Abs(Frac(HPrime) - 1));
  M := V - C;

  if (HPrime >= 0) and (HPrime < 1) then begin
    R_ := C;
    G_ := X;
    B_ := 0;
  end else if (HPrime >= 1) and (HPrime < 2) then begin
    R_ := X;
    G_ := C;
    B_ := 0;
  end else if (HPrime >= 2) and (HPrime < 3) then begin
    R_ := 0;
    G_ := C;
    B_ := X;
  end else if (HPrime >= 3) and (HPrime < 4) then begin
    R_ := 0;
    G_ := X;
    B_ := C;
  end else if (HPrime >= 4) and (HPrime < 5) then begin
    R_ := X;
    G_ := 0;
    B_ := C;
  end else begin
    R_ := C;
    G_ := 0;
    B_ := X;
  end;

  // Convert to 0-255 range
  R := Round((R_ + M) * 255);
  G := Round((G_ + M) * 255);
  B := Round((B_ + M) * 255);
end;

function PointAroundCenter(Center: TJDPoint; Distance: Single; Degrees: Single;
  OvalOffset: Single = 1): TJDPoint;
var
  Radians: Real;
begin
  //Oval support: https://stackoverflow.com/questions/8433443/modify-a-formula-from-calculating-around-a-circle-to-around-an-oval
  //Return point around a center point, based on angle and distance (radius)...
  //Convert angle from degrees to radians; Subtract 135 to bring position to 0 Degrees
  //TODO: I recall an updated version of this along with a reverse function... where are they???
  Radians:= (Degrees - 135) * Pi / 180;
  Result.X:= Distance*Cos(Radians) - Distance*Sin(Radians) + Center.X;
  Result.Y:= (Distance*Sin(Radians) + Distance*Cos(Radians)) / OvalOffset + Center.Y;
end;

function GetDegreesFromPointAroundCenter(Center: TJDPoint; P: TJDPoint;
  OvalOffset: Single = 1): Single;
var
  Radians: Real;
begin
  //Given a point, return the angle back to the center point
  //Reverse of PointAroundCenter.
  //GENERATED BY CODEIUM
  Radians:= Arctan2(P.Y - Center.Y, P.X - Center.X);
  Result:= (Radians * 180 / Pi) + 135;
end;

function ColorFade(const ASource: TColor; const ACount: Integer; const Shift: Integer): TJDColorArray;
var
  X: Integer;
  R, G, B: Byte;
begin
  SetLength(Result, ACount);
  for X := 0 to ACount-1 do begin
    R:= IntRange(GetRValue(ASource), 1, 254) + (Shift * X);
    G:= IntRange(GetGValue(ASource), 1, 254) + (Shift * X);
    B:= IntRange(GetBValue(ASource), 1, 254) + (Shift * X);
    Result[X]:= RGB(R, G, B);
  end;
end;

function ColorFade(const ASource: TColor; const Shift: Integer): TJDColor;
var
  R, G, B: Byte;
begin
  R:= IntRange(GetRValue(ASource), 1, 254) + (Shift);
  G:= IntRange(GetGValue(ASource), 1, 254) + (Shift);
  B:= IntRange(GetBValue(ASource), 1, 254) + (Shift);
  Result:= RGB(R, G, B);
end;

function CreateGPCanvas(const DC: HDC): TGPGraphics;
begin
  Result:= TGPGraphics.Create(DC);
  Result.SetInterpolationMode(InterpolationMode.InterpolationModeHighQuality);
  Result.SetSmoothingMode(SmoothingMode.SmoothingModeHighQuality);
  Result.SetCompositingQuality(CompositingQuality.CompositingQualityHighQuality);
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
  with Value do begin
    {$IFDEF JD_ALPHA}
    Result:= RGBA(Red, Green, Blue, Alpha);
    {$ELSE}
    Result:= RGB(Red, Green, Blue);
    {$ENDIF}

    //Result:= SetAValue(Result, Alpha);
  end;
end;

class operator TJDColor.Implicit(Value: TColor): TJDColor;
begin
  with Result do begin
    FRed:= GetRValue(Value);
    FGreen:= GetGValue(Value);
    FBlue:= GetBValue(Value);
    {$IFDEF JD_ALPHA}
    FAlpha:= 255; // GetAValue(Value);
    {$ENDIF}
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

function TJDColor.GetGDIPColor(Alpha: Byte = 255): Cardinal;
begin
  {$IFDEF JD_ALPHA}
  Result:= GDIPAPI.MakeColor(Alpha, FRed, FGreen, FBlue);
  {$ELSE}
  Result:= GDIPAPI.MakeColor(255, FRed, FGreen, FBlue);
  {$ENDIF}
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

{$IFDEF JD_ALPHA}
function TJDColor.GetAlpha: Byte;
begin
  Result:= FAlpha;
end;
{$ENDIF}

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

{$IFDEF JD_ALPHA}
procedure TJDColor.SetAlpha(const Value: Byte);
begin
  FAlpha:= Value;
end;
{$ENDIF}

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

function TJDColorRef.GetGDIPColor(Alpha: Byte = 255): Cardinal;
begin
  Result:= GDIPAPI.MakeColor(Alpha, RGB.R, RGB.G, RGB.B);
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

function TJDColorRef.IsMainColorStored: Boolean;
begin
  Result:= not FUseStandardColor;
end;

function TJDColorRef.IsStandardColorStored: Boolean;
begin
  Result:= FUseStandardColor;
end;

procedure TJDColorRef.SetColor(const Value: TColor);
begin
  FUseStandardColor:= False;
  FColor := Value;
  Invalidate;
end;

procedure TJDColorRef.LoadFromJSON(O: ISuperObject);
begin
  FRGB.R:= O.I['R'];
  FRGB.G:= O.I['G'];
  FRGB.B:= O.I['B'];
  FStandardColor:= TJDStandardColor(O.I['StandardColor']);
  FUseStandardColor:= O.B['UseStandardColor']; //This MUST be loaded after RGB and StandardColor!!!
  Invalidate;
end;

function TJDColorRef.SaveToJSON: ISuperObject;
begin
  Result:= SO;
  Result.B['UseStandardColor']:= UseStandardColor;
  Result.I['StandardColor']:= Integer(StandardColor);
  Result.I['R']:= FRGB.R;
  Result.I['G']:= FRGB.G;
  Result.I['B']:= FRGB.B;
end;

procedure TJDColorRef.LoadFromString(S: String);
begin
  LoadFromJSON(SO(S));
end;

function TJDColorRef.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
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

{ TJDAlphaColorRef }

procedure TJDAlphaColorRef.Assign(Source: TPersistent);
begin
  if Source is TJDAlphaColorRef then begin
    FColor:= TJDAlphaColorRef(Source).FColor;
    FAlpha:= TJDAlphaColorRef(Source).FAlpha;
    FStandardColor:= TJDColorRef(Source).FStandardColor;
    FUseStandardColor:= TJDColorRef(Source).FUseStandardColor;
  end else
    inherited;
end;

constructor TJDAlphaColorRef.Create;
begin
  inherited;
  FAlpha:= 255;
end;

{$IFDEF USE_GDIP}
function TJDAlphaColorRef.GDIPColor: TGPColor;
begin
  Result:= MakeColor(FAlpha, GetJDColor.Red, GetJDColor.Green, GetJDColor.Blue);
end;
{$ENDIF}

function TJDAlphaColorRef.GetJDColor: TJDColor;
begin
  inherited;
  {$IFDEF JD_ALPHA}
  Result.Alpha:= FAlpha;
  {$ENDIF}
end;

procedure TJDAlphaColorRef.SetAlpha(const Value: Byte);
begin
  FAlpha := Value;
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

function TJDColorHSVRef.GetH: Word;
begin
  Result:= Round(FOwner.GetJDColor.Hue.FValue);
end;

function TJDColorHSVRef.GetS: Byte;
begin
  Result:= Round(FOwner.GetJDColor.Saturation.FValue);
end;

function TJDColorHSVRef.GetV: Byte;
begin
  Result:= Round(FOwner.GetJDColor.Brightness.FValue);
end;

procedure TJDColorHSVRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDColorHSVRef.SetH(const Value: Word);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Hue:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorHSVRef.SetS(const Value: Byte);
var
  C: TJDColor;
begin
  C:= FOwner.Color;
  C.Saturation:= Value;
  FOwner.Color:= C;
  Invalidate;
end;

procedure TJDColorHSVRef.SetV(const Value: Byte);
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

{ TJDColorItem }

constructor TJDColorItem.Create(Collection: TCollection);
begin
  inherited;
  FColor:= TJDColorRef.Create;
  FColor.OnChange:= ColorChanged;
  FName:= GenerateUniqueName;

end;

destructor TJDColorItem.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

procedure TJDColorItem.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

function TJDColorItem.GenerateUniqueName: string;
var
  BaseName: string;
  Count, I: Integer;
  Unique: Boolean;
begin
  BaseName := 'Item';
  Count := 1;
  Unique := False;

  while not Unique do begin
    Unique := True;
    for I := 0 to Collection.Count - 1 do begin
      if CompareText((Collection.Items[I] as TJDColorItem).Name, BaseName + IntToStr(Count)) = 0 then
      begin
        Unique := False;
        Break;
      end;
    end;
    if not Unique then
      Inc(Count);
  end;

  Result := BaseName + IntToStr(Count);
end;

function TJDColorItem.GetDisplayName: String;
begin
  Result:= Name;
end;

procedure TJDColorItem.Assign(Source: TPersistent);
begin
  if Source is TJDColorItem then begin
    Name := TJDColorItem(Source).Name;
    Color.Assign(TJDColorItem(Source).Color);
  end else
    inherited Assign(Source);
end;

procedure TJDColorItem.Invalidate;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TJDColorItem.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDColorItem.SetName(const Value: String);
var
  I: Integer;
  Item: TCollectionItem;
begin
  if CompareText(FName, Value) = 0 then
    Exit;

  for I := 0 to Collection.Count - 1 do begin
    Item := Collection.Items[I];
    if CompareText((Item as TJDColorItem).Name, Value) = 0 then
      raise Exception.Create('Duplicate name not allowed');
  end;

  FName := Value;
  Changed(False);
  Invalidate;
end;

{ TJDColorItems }

constructor TJDColorItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJDColorItem);
  FOwnerComponent:= AOwner as TJDColorList;
end;

destructor TJDColorItems.Destroy;
begin

  inherited;
end;

procedure TJDColorItems.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited Notify(Item, Action);
  if Assigned(FOwnerComponent) then
    FOwnerComponent.ItemNotify(Self, Item, Action);
end;

{ TJDColorList }

procedure TJDColorList.Changed(Item: TJDColorItem);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, Item);
end;

constructor TJDColorList.Create(AOwner: TComponent);
begin
  inherited;
  FColors:= TJDColorItems.Create(Self);

end;

destructor TJDColorList.Destroy;
begin

  FreeAndNil(FColors);
  inherited;
end;

procedure TJDColorList.ItemNotify(Sender: TObject; Item: TCollectionItem;
  Action: TCollectionNotification);
begin

end;

procedure TJDColorList.SetColors(const Value: TJDColorItems);
begin
  FColors := Value;
end;

initialization
  _ColorManager:= TJDColorManager.Create;
finalization
  _ColorManager.Free;
end.


unit JD.Graphics;

interface

uses
  System.Classes, System.SysUtils,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.ImgList,
  Dialogs,
  JD.Ctrls.FontButton;

const

  //GLOBAL COLOR SETUP

  DARK_NEUTRAL =  $005F4A3F;//$006B4732;
  DARK_BLUE =     $00986D34;//
  DARK_GREEN =    $002C6137;
  DARK_RED =      $002629B9;
  DARK_YELLOW =   $0000B0B0;
  DARK_ORANGE =   $00145CD6;//$00165792;

  LIGHT_NEUTRAL = $00D1C6B8;//$00DEC4AB;
  LIGHT_BLUE =    $00D7A36F;//
  LIGHT_GREEN =   $0055A667;
  LIGHT_RED =     $004A4ADF;//$006464E3;
  LIGHT_YELLOW =  $003EFFFF;
  LIGHT_ORANGE =  $002492FF;

  WIN_NEUTRAL =   DARK_NEUTRAL;
  WIN_BLUE =      DARK_BLUE;
  WIN_GREEN =     DARK_GREEN;
  WIN_RED =       DARK_RED;
  WIN_YELLOW =    DARK_YELLOW;
  WIN_ORANGE =    DARK_ORANGE;
  WIN_MAIN =      $00F8F8ED;
  WIN_GRAD_FROM = $00E4E1C0;
  WIN_GRAD_TO =   $00F8F8ED;

type
  EOutOfRange = Exception;

  TColorMode = (cmLight, cmDark, cmMiddle);

  THue = record
  private
    FValue: Double;
  public
    class operator implicit(Value: THue): Double;
    class operator implicit(Value: Double): THue;
  end;

  TSaturation = record
  private
    FValue: Double;
  public
    class operator implicit(Value: TSaturation): Double;
    class operator implicit(Value: Double): TSaturation;
  end;

  TBrightness = record
  private
    FValue: Double;
  public
    class operator implicit(Value: TBrightness): Double;
    class operator implicit(Value: Double): TBrightness;
  end;

  TColorRec = record
  private
    FRed: Byte;
    FGreen: Byte;
    FBlue: Byte;
    function GetHue: Double;
    function GetSaturation: Double;
    function GetBrightness: Double;
    procedure SetHue(const Value: Double);
    procedure SetSaturation(const Value: Double);
    procedure SetBrightness(const Value: Double);
    function GetBlack: Byte;
    function GetCyan: Byte;
    function GetMagenta: Byte;
    function GetYellow: Byte;
    procedure SetBlack(const Value: Byte);
    procedure SetCyan(const Value: Byte);
    procedure SetMagenta(const Value: Byte);
    procedure SetYellow(const Value: Byte);
  public
    class operator implicit(Value: TColorRec): TColor;
    class operator implicit(Value: TColor): TColorRec;
    property Red: Byte read FRed write FRed;
    property Green: Byte read FGreen write FGreen;
    property Blue: Byte read FBlue write FBlue;
    property Hue: Double read GetHue write SetHue;
    property Saturation: Double read GetSaturation write SetSaturation;
    property Brightness: Double read GetBrightness write SetBrightness;
    property Cyan: Byte read GetCyan write SetCyan;
    property Magenta: Byte read GetMagenta write SetMagenta;
    property Yellow: Byte read GetYellow write SetYellow;
    property Black: Byte read GetBlack write SetBlack;
  end;

  TImageListRef = class;
  TImageListRefs = class;
  TRMProFontGlyph = class;
  TRMProFontGlyphList = class;
  TRMProFontGlyphs = class;

  TImageListRef = class(TCollectionItem)
  private
    FImageList: TImageList;
    FOwner: TImageListRefs;
    procedure SetImageList(const Value: TImageList);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property ImageList: TImageList read FImageList write SetImageList;
  end;

  TImageListRefs = class(TOwnedCollection)
  private
    FOwner: TRMProFontGlyphs;
    function GetItem(Index: Integer): TImageListRef;
    procedure SetItem(Index: Integer; const Value: TImageListRef);
  public
    constructor Create(AOwner: TPersistent);
    procedure Invalidate;
    function Add: TImageListRef;
    function Insert(Index: Integer): TImageListRef;
    property Items[Index: Integer]: TImageListRef read GetItem write SetItem; default;
  end;

  TRMProFontGlyph = class(TCollectionItem)
  private
    FOwner: TRMProFontGlyphList;
    FGlyph: String;
    FCaption: String;
    FColor: TFontButtonColor;
    FScale: Double;
    procedure SetGlyph(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetColor(const Value: TFontButtonColor);
    procedure SetScale(const Value: Double);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property Caption: String read FCaption write SetCaption;
    property Glyph: String read FGlyph write SetGlyph;
    property Color: TFontButtonColor read FColor write SetColor;
    property Scale: Double read FScale write SetScale;
  end;

  TRMProFontGlyphList = class(TOwnedCollection)
  private
    FOwner: TRMProFontGlyphs;
    function GetItem(Index: Integer): TRMProFontGlyph;
    procedure SetItem(Index: Integer; const Value: TRMProFontGlyph);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TRMProFontGlyphs);
    procedure Invalidate;
    function Add: TRMProFontGlyph;
    function Insert(Index: Integer): TRMProFontGlyph;
    property Items[Index: Integer]: TRMProFontGlyph read GetItem write SetItem; default;
  end;

  TRMProFontGlyphs = class(TMessageComponent)
  private
    FBuffer: TBitmap;
    FImageLists: TImageListRefs;
    FGlyphs: TRMProFontGlyphList;
    FUpdating: Boolean;
    FUpdated: Boolean;
    procedure SetGlyphs(const Value: TRMProFontGlyphList);
    procedure SetImageLists(const Value: TImageListRefs);
  protected
    procedure WndMethod(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate;
    procedure PopulateImageList;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function Updating: Boolean; reintroduce;
  published
    property ImageLists: TImageListRefs read FImageLists write SetImageLists;
    property Glyphs: TRMProFontGlyphList read FGlyphs write SetGlyphs;
  end;

function GetFontGlyphs(dc: HDC; const PrivateOnly: Boolean = True): TCharArray;
function RGBToHSV(R, G, B: Byte; var H, S, V: Double): Boolean;
function HSVToRGB(H, S, V: Double; var R, G, B: Byte): Boolean;
function IntRange(const Value, Min, Max: Integer): Integer;
function TweakColor(const AColor: TColor; const Diff: Integer): TColor;
function DetectColorMode(const AColor: TColor): TColorMode;
procedure DrawParentImage(Control: TControl; Dest: TCanvas);

implementation

uses
  Vcl.Forms,
  Math;

//var
  //FOldWndProc: TFarProc;

function GetFontGlyphs(dc: HDC; const PrivateOnly: Boolean = True): TCharArray;
var
  n: dword;
  GlyphSet: PGlyphSet;
  I, J: integer;
  CharCode: DWORD;
  procedure AddChar(const Code: DWORD);
  begin
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1]:= Chr(Code);
  end;
begin
  SetLength(Result, 0);
  n := GetFontUnicodeRanges(dc, nil);
  GlyphSet := AllocMem(n);
  try
    n := GetFontUnicodeRanges(dc, GlyphSet);
    if n <> 0 then begin
      for I := 0 to GlyphSet^.cRanges-1 do begin
        for J := 0 to GlyphSet^.ranges[i].cGlyphs-1 do begin
          CharCode:= Ord(GlyphSet^.ranges[i].wcLow) + J;
          if (not PrivateOnly) or (PrivateOnly and (CharCode >= $E000)) then
            AddChar(CharCode);
        end;
      end;
    end;
  finally
    FreeMem(GlyphSet);
  end;
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

function IntRange(const Value, Min, Max: Integer): Integer;
begin
  //Ensures an integer falls within a given min/max range
  Result:= Value;
  if Result < Min then Result:= Min;
  if Result > Max then Result:= Max;
end;

function TweakColor(const AColor: TColor; const Diff: Integer): TColor;
var
  R, G, B: Byte;
  D: Integer;
  Dir: Integer;
begin
  //Modifies color to slight offset
  R:= GetRValue(AColor);
  G:= GetGValue(AColor);
  B:= GetBValue(AColor);
  D:= (R + G + B) div 3;
  if D >= (256 div 2) then begin
    Dir:= -Diff;
  end else begin
    Dir:= Diff;
  end;
  R:= IntRange(R + Dir, 0, 255);
  G:= IntRange(G + Dir, 0, 255);
  B:= IntRange(B + Dir, 0, 255);
  Result:= RGB(R, G, B);
end;

function DetectColorMode(const AColor: TColor): TColorMode;
var
  Clr: TColorRec;
begin
  //Determine whether color is light, dark, or middle
  Clr:= AColor;
  if (Clr.Brightness > 0.4) and (Clr.Brightness < 0.6) then begin
    Result:= cmMiddle;
  end else if Clr.Brightness >= 0.5 then begin
    Result:= cmLight;
  end else begin
    Result:= cmDark;
  end;
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

{ THue }

class operator THue.implicit(Value: THue): Double;
begin
  Result:= Value.FValue;
end;

class operator THue.implicit(Value: Double): THue;
begin
  if (Value < 0.0) or (Value > 360.0) then
    raise EOutOfRange.Create('Hue value out of range');
  Result.FValue:= Value;
end;

{ TSaturation }

class operator TSaturation.implicit(Value: TSaturation): Double;
begin
  Result:= Value.FValue;
end;

class operator TSaturation.implicit(Value: Double): TSaturation;
begin
  if (Value < 0.0) or (Value > 100.0) then
    raise EOutOfRange.Create('Saturation value out of range');
  Result.FValue:= Value;
end;

{ TBrightness }

class operator TBrightness.implicit(Value: TBrightness): Double;
begin
  Result:= Value.FValue;
end;

class operator TBrightness.implicit(Value: Double): TBrightness;
begin
  if (Value < 0.0) or (Value > 100.0) then
    raise EOutOfRange.Create('Brightness value out of range');
  Result.FValue:= Value;
end;

{ TColorRec }

class operator TColorRec.implicit(Value: TColorRec): TColor;
begin
  with Value do
    Result:= RGB(Red, Green, Blue);
end;

class operator TColorRec.implicit(Value: TColor): TColorRec;
begin
  with Result do begin
    FRed:= GetRValue(Value);
    FGreen:= GetGValue(Value);
    FBlue:= GetBValue(Value);
  end;
end;

function TColorRec.GetHue: Double;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= H;
end;

function TColorRec.GetSaturation: Double;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= S;
end;

function TColorRec.GetBrightness: Double;
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  Result:= V;
end;

function TColorRec.GetCyan: Byte;
begin
  Result:= GetCValue(RGB(FRed, FGreen, FBlue));
end;

function TColorRec.GetMagenta: Byte;
begin
  Result:= GetMValue(RGB(FRed, FGreen, FBlue));
end;

function TColorRec.GetYellow: Byte;
begin
  Result:= GetYValue(RGB(FRed, FGreen, FBlue));
end;

function TColorRec.GetBlack: Byte;
begin
  Result:= GetKValue(RGB(FRed, FGreen, FBlue));
end;

procedure TColorRec.SetBrightness(const Value: Double);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  V:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TColorRec.SetHue(const Value: Double);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  H:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TColorRec.SetSaturation(const Value: Double);
var
  H, S, V: Double;
begin
  RGBToHSV(FRed, FGreen, FBlue, H, S, V);
  S:= Value;
  HSVToRGB(H, S, V, FRed, FGreen, FBlue);
end;

procedure TColorRec.SetCyan(const Value: Byte);
begin
  Self:= CMYK(Value, Magenta, Yellow, Black);
end;

procedure TColorRec.SetMagenta(const Value: Byte);
begin
  Self:= CMYK(Cyan, Value, Yellow, Black);
end;

procedure TColorRec.SetYellow(const Value: Byte);
begin
  Self:= CMYK(Cyan, Magenta, Value, Black);
end;

procedure TColorRec.SetBlack(const Value: Byte);
begin
  Self:= CMYK(Cyan, Magenta, Yellow, Value);
end;

{ TImageListRef }

procedure TImageListRef.Assign(Source: TPersistent);
var
  S: TImageListRef;
begin
  if Source is TImageListRef then begin
    S:= TImageListRef(Source);
    Self.ImageList:= S.ImageList;
  end else
    inherited;
end;

constructor TImageListRef.Create(AOwner: TCollection);
begin
  inherited;
  FOwner:= TImageListRefs(AOwner);
end;

destructor TImageListRef.Destroy;
begin

  inherited;
end;

function TImageListRef.GetDisplayName: String;
begin
  if Assigned(ImageList) then
    Result:= ImageList.Name
  else
    Result:= inherited GetDisplayName;
end;

procedure TImageListRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TImageListRef.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  Invalidate;
end;

{ TImageListRefs }

constructor TImageListRefs.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TImageListRef);
  FOwner:= TRMProFontGlyphs(AOwner);
end;

function TImageListRefs.Add: TImageListRef;
begin
  Result:= TImageListRef(inherited Add);
end;

function TImageListRefs.GetItem(Index: Integer): TImageListRef;
begin
  Result:= TImageListRef(inherited Items[Index]);
end;

function TImageListRefs.Insert(Index: Integer): TImageListRef;
begin
  Result:= TImageListRef(inherited Insert(Index));
end;

procedure TImageListRefs.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TImageListRefs.SetItem(Index: Integer; const Value: TImageListRef);
begin
  inherited Items[Index]:= Value;
end;

{ TRMProFontGlyph }

procedure TRMProFontGlyph.Assign(Source: TPersistent);
var
  S: TRMProFontGlyph;
begin
  if Source is TRMProFontGlyph then begin
    S:= TRMProFontGlyph(Source);
    Self.Caption:= S.Caption;
    Self.Glyph:= S.Glyph;
    Self.Color:= S.Color;
    Self.Scale:= S.Scale;
  end else
    inherited;
end;

constructor TRMProFontGlyph.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);
  FOwner:= TRMProFontGlyphList(AOwner);
  FCaption:= 'New Glyph';
  FGlyph:= 'a';
  FScale:= 0.96;
end;

destructor TRMProFontGlyph.Destroy;
begin
  inherited;
end;

function TRMProFontGlyph.GetDisplayName: String;
begin
  Result:= FCaption;
end;

procedure TRMProFontGlyph.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TRMProFontGlyph.SetCaption(const Value: String);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TRMProFontGlyph.SetColor(const Value: TFontButtonColor);
begin
  FColor := Value;
  Invalidate;
end;

procedure TRMProFontGlyph.SetGlyph(const Value: String);
begin
  if Length(Value) <> 1 then
    raise Exception.Create('Glyph text must be 1 character');
  FGlyph := Value;
  Invalidate;
end;

procedure TRMProFontGlyph.SetScale(const Value: Double);
begin
  //if Value < 1 then
    //raise Exception.Create('Value must be at least 1');
  FScale := Value;
  Invalidate;
end;

{ TRMProFontGlyphList }

constructor TRMProFontGlyphList.Create(AOwner: TRMProFontGlyphs);
begin
  inherited Create(AOwner, TRMProFontGlyph);
  FOwner:= TRMProFontGlyphs(AOwner);
end;

function TRMProFontGlyphList.GetItem(Index: Integer): TRMProFontGlyph;
begin
  Result:= TRMProFontGlyph(inherited Items[Index]);
end;

function TRMProFontGlyphList.Insert(Index: Integer): TRMProFontGlyph;
begin
  Result:= TRMProFontGlyph(inherited Insert(Index));
end;

procedure TRMProFontGlyphList.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TRMProFontGlyphList.SetItem(Index: Integer;
  const Value: TRMProFontGlyph);
begin
  inherited Items[Index]:= Value;
end;

procedure TRMProFontGlyphList.Update(Item: TCollectionItem);
begin
  inherited;
  Invalidate;
end;

function TRMProFontGlyphList.Add: TRMProFontGlyph;
begin
  Result:= TRMProFontGlyph(inherited Add);
end;

{ TRMProFontGlyphs }

constructor TRMProFontGlyphs.Create(AOwner: TComponent);
begin
  inherited;
  FBuffer:= TBitmap.Create;
  FImageLists:= TImageListRefs.Create(Self);
  FGlyphs:= TRMProFontGlyphList.Create(Self);
end;

destructor TRMProFontGlyphs.Destroy;
begin
  FreeAndNil(FGlyphs);
  FBuffer.Free;
  FImageLists.Free;
  inherited;
end;

procedure TRMProFontGlyphs.Invalidate;
begin
  Self.PopulateImageList;
end;

procedure TRMProFontGlyphs.SetGlyphs(const Value: TRMProFontGlyphList);
begin
  FGlyphs.Assign(Value);
  Invalidate;
end;

procedure TRMProFontGlyphs.SetImageLists(const Value: TImageListRefs);
begin
  FImageLists.Assign(Value);
  Invalidate;
end;

function TRMProFontGlyphs.Updating: Boolean;
begin
  Result:= FUpdating;
end;

procedure TRMProFontGlyphs.WndMethod(var Message: TMessage);
begin
  if Message.Msg = WM_COLORCHANGE then begin
    Invalidate;
  end;
  inherited;
end;

procedure TRMProFontGlyphs.Assign(Source: TPersistent);
var
  S: TRMProFontGlyphs;
begin
  if Source is TRMProFontGlyphs then begin
    S:= TRMProFontGlyphs(Source);
    Self.Glyphs.Assign(S.Glyphs);
    Self.ImageLists.Assign(S.ImageLists);

  end else
    inherited;
end;

procedure TRMProFontGlyphs.BeginUpdate;
begin
  if not FUpdating then begin
    FUpdating:= True;
    FUpdated:= False;
  end;
end;

procedure TRMProFontGlyphs.EndUpdate;
begin
  if FUpdating then begin
    FUpdating:= False;
    if FUpdated then
      Invalidate;
  end;
end;

procedure TRMProFontGlyphs.PopulateImageList;
var
  IL: TImageListRef;
  G: TRMProFontGlyph;
  MC: TColor;
  X, Y: Integer;
  R: TRect;
begin
  if FUpdating then begin
    FUpdated:= True;
    Exit;
  end;

  FBuffer.Canvas.Font.Name:= 'RMPicons';
  FBuffer.Canvas.Font.Quality:= fqAntialiased;
  MC:= ColorManager.BaseColor;
  for X := 0 to FImageLists.Count-1 do begin
    IL:= FImageLists[X];
    if Assigned(IL.FImageList) then begin
      IL.FImageList.BeginUpdate;
      try
        IL.FImageList.Clear;
        FBuffer.Width:= IL.FImageList.Width;
        FBuffer.Height:= IL.FImageList.Height;
        R:= FBuffer.Canvas.ClipRect;
        FBuffer.Canvas.Brush.Color:= MC;
        for Y := 0 to FGlyphs.Count-1 do begin
          G:= FGlyphs[Y];
          FBuffer.Canvas.Font.Height:= Trunc(FBuffer.Height * G.Scale);
          FBuffer.Canvas.Font.Color:= ColorManager.Color[G.Color];
          FBuffer.Canvas.FillRect(R);

          DrawText(FBuffer.Canvas.Handle, PChar(G.Glyph), Length(G.Glyph), R,
            DT_CENTER or DT_SINGLELINE or DT_VCENTER);

          IL.ImageList.AddMasked(FBuffer, MC);
        end;
      finally
        IL.FImageList.EndUpdate;
      end;
    end;
  end;
end;

end.

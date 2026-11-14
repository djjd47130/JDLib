unit JD.FontGlyphs;

(*
TODO:
- Standardize a single TJDFontGlyph (TPersistent) which can be referenced as any
  published property with its own property editor, supporting overlay images
  and several other rendering options to paint a single font glyph image.
- Support multi-layered glyph - not necessarily an "overlay", but instead
  combining 2 or more font glyphs in layers. Useful for multi-color vectors.


*)

interface

uses
  System.Classes, System.SysUtils,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls,
  JD.Graphics, JD.Common;

type
  ///  <summary>
  ///  Represents a reference to a particular TImageList component.
  ///  </summary>
  TJDImageListRef = class;

  ///  <summary>
  ///  Represents a collection of TJDImageListRef objects.
  ///  </summary>
  TJDImageListRefs = class;

  ///  <summary>
  ///  Represents a reference to a particular font glyph with options for
  ///  font name, character, scale, and color.
  ///  Also provides property editor to pick glyph and options.
  ///  Specifically used within TFontGlyphItem.
  ///  </summary>
  TJDFontGlyphRef = class;

  ///  <summary>
  ///  Represents a single specific font glyph within a TJDFontGlyphList collection.
  ///  </summary>
  TJDFontGlyphItem = class;

  ///  <summary>
  ///  Represents a list of TJDFontGlyphItem objects.
  ///  </summary>
  TJDFontGlyphList = class;

  ///  <summary>
  ///  Component encapsulating a list of image glyphs and a list of
  ///  TImageList components to be populated with selected font glyphs.
  ///  </summary>
  TJDFontGlyphs = class;

  ///  <summary>
  ///  Represents a particular font glyph with options for font,
  ///  character, scale, and color.
  ///  Also provides property editor to pick glyph and options.
  ///  For use on any component which wishes to implement font glyph properties.
  ///  </summary>
  TJDFontGlyph = class;


  TJDImageListRef = class(TCollectionItem)
  private
    FImageList: TImageList;
    FOwner: TJDImageListRefs;
    procedure SetImageList(const Value: TImageList);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    ///  <summary>
    ///  Reference to the TImageList component which should be populated with glyphs.
    ///  </summary>
    property ImageList: TImageList read FImageList write SetImageList;
  end;

  TJDImageListRefs = class(TOwnedCollection)
  private
    FOwner: TJDFontGlyphs;
    function GetItem(Index: Integer): TJDImageListRef;
    procedure SetItem(Index: Integer; const Value: TJDImageListRef);
  public
    constructor Create(AOwner: TPersistent);
    procedure Invalidate;
    function Add: TJDImageListRef;
    function Insert(Index: Integer): TJDImageListRef;
    property Items[Index: Integer]: TJDImageListRef read GetItem write SetItem; default;
  end;

  TJDFontGlyphRef = class(TPersistent)
  private
    FOwner: TJDFontGlyphItem;
    FColor: TColor;
    FUseStandardColor: Boolean;
    FFontName: TFontName;
    procedure SetColor(const Value: TColor);
    procedure SetFontName(const Value: TFontName);
    procedure SetGlyph(const Value: String);
    function GetGlyph: String;
    function GetStandardColor: TJDStandardColor;
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
  public
    constructor Create(AOwner: TJDFontGlyphItem);
    destructor Destroy; override;
  published
    property FontName: TFontName read FFontName write SetFontName;
    property Glyph: String read GetGlyph write SetGlyph;
    property Color: TColor read FColor write SetColor;
    property StandardColor: TJDStandardColor read GetStandardColor write SetStandardColor;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor;
  end;

  TJDFontGlyphItem = class(TCollectionItem)
  private
    FOwner: TJDFontGlyphList;
    FGlyph: String;
    FCaption: String;
    FColor: TJDStandardColor;
    FScale: Double;
    FRef: TJDFontGlyphRef;
    procedure SetGlyph(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetColor(const Value: TJDStandardColor);
    procedure SetScale(const Value: Double);
    procedure SetRef(const Value: TJDFontGlyphRef);
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
    property Color: TJDStandardColor read FColor write SetColor;
    property Scale: Double read FScale write SetScale;
    property Ref: TJDFontGlyphRef read FRef write SetRef;
  end;

  TJDFontGlyphList = class(TOwnedCollection)
  private
    FOwner: TJDFontGlyphs;
    function GetItem(Index: Integer): TJDFontGlyphItem;
    procedure SetItem(Index: Integer; const Value: TJDFontGlyphItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJDFontGlyphs); reintroduce;
    procedure Invalidate;
    function Add: TJDFontGlyphItem;
    function Insert(Index: Integer): TJDFontGlyphItem;
    property Items[Index: Integer]: TJDFontGlyphItem read GetItem write SetItem; default;
  end;

  TJDFontGlyphs = class(TJDMessageComponent)
  private
    FBuffer: TBitmap;
    FImageLists: TJDImageListRefs;
    FGlyphs: TJDFontGlyphList;
    // FIX (review §3.46): this used to be a Boolean flag (FUpdating), so nested
    // BeginUpdate/EndUpdate pairs broke - the inner EndUpdate cleared the flag
    // while the outer update was still going. It is now a nesting counter:
    // BeginUpdate adds one, EndUpdate takes one away, and the glyphs only
    // repopulate when the count drops back to zero.
    FUpdateCount: Integer;
    FUpdated: Boolean;
    procedure SetGlyphs(const Value: TJDFontGlyphList);
    procedure SetImageLists(const Value: TJDImageListRefs);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure WndMethod(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    procedure PopulateImageList;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function Updating: Boolean; reintroduce;
  published
    property ImageLists: TJDImageListRefs read FImageLists write SetImageLists;
    property Glyphs: TJDFontGlyphList read FGlyphs write SetGlyphs;
  end;

  TJDFontGlyph = class(TPersistent)
  private
    FStandardColor: TJDStandardColor;
    FGlyph: String;
    FUseStandardColor: Boolean;
    FOnChange: TNotifyEvent;
    FFont: TFont;
    procedure SetGlyph(const Value: String);
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure FontChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property Glyph: String read FGlyph write SetGlyph;
    property Font: TFont read FFont write SetFont;
    property StandardColor: TJDStandardColor read FStandardColor write SetStandardColor;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;





  //NEW CONCEPT - Single property to contain multiple layered glyphs and overlays.
  //Carries no specific size - only references to glyphs, colors, and offsets.
  //Basically a vector image which can be scaled as needed.

type
  TJDGlyphImage = class;

  TJDGlyphImagePosition = (gipCenter, gipTopLeft, gipTopRight, gipBottomLeft, gipBottomRight);

  TJDGlyphImageItem = class(TCollectionItem)
  const
    DEF_GLYPH = ' ';
    DEF_COLOR = clWindowText;
    DEF_SCALE = 0.96;
    DEF_POSITION = gipCenter;
  private
    FOwner: TJDGlyphImage;
    //FGlyph: WideChar;
    //FColor: TJDColorRef;
    FScale: Single;
    //FPosition: TJDGlyphImagePosition;
    procedure SetScale(const Value: Single);
    function IsScaleStored: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Scale: Single read FScale write SetScale stored IsScaleStored;
  end;

  TJDGlyphImageItems = class(TOwnedCollection)

  end;

  TJDGlyphImage = class(TPersistent)
  private
    FGlyphs: TJDGlyphImageItems;
    procedure SetGlyphs(const Value: TJDGlyphImageItems);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Glyphs: TJDGlyphImageItems read FGlyphs write SetGlyphs;
  end;




  TJDGlyphImageList = class(TJDMessageComponent)
  private
  protected
    procedure WndMethod(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
  published
  end;



function GetFontGlyphs(dc: HDC; const PrivateOnly: Boolean = True): TCharArray;

implementation

function GetFontGlyphs(DC: HDC; const PrivateOnly: Boolean = True): TCharArray;
var
  Ranges: DWORD;
  GlyphSet: PGlyphSet;
  I, J: Integer;
  CharCode: DWORD;
  procedure AddChar(const Code: DWORD);
  begin
    // FIX (review §3.46): Chr() only covers 0..$FFFF - a code past that
    // (possible in a font's Unicode ranges) would overflow, so skip it.
    if Code > $FFFF then
      Exit;
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1]:= Chr(Code);
  end;
begin
  SetLength(Result, 0);
  Ranges:= GetFontUnicodeRanges(DC, nil);
  GlyphSet:= AllocMem(Ranges);
  try
    Ranges:= GetFontUnicodeRanges(dc, GlyphSet);
    if Ranges <> 0 then begin
      for I:= 0 to GlyphSet^.cRanges-1 do begin
        for J:= 0 to GlyphSet^.Ranges[I].cGlyphs-1 do begin
          CharCode:= Ord(GlyphSet^.Ranges[I].wcLow) + J;
          if (not PrivateOnly) or (PrivateOnly and (CharCode >= $E000)) then
            AddChar(CharCode);
        end;
      end;
    end;
  finally
    FreeMem(GlyphSet);
  end;
end;

{ TJDImageListRef }

constructor TJDImageListRef.Create(AOwner: TCollection);
begin
  inherited;
  FOwner:= TJDImageListRefs(AOwner);
end;

destructor TJDImageListRef.Destroy;
begin

  inherited;
end;

procedure TJDImageListRef.Assign(Source: TPersistent);
var
  S: TJDImageListRef;
begin
  if Source is TJDImageListRef then begin
    S:= TJDImageListRef(Source);
    Self.ImageList:= S.ImageList;
  end else
    inherited;
end;

function TJDImageListRef.GetDisplayName: String;
begin
  if Assigned(ImageList) then
    Result:= ImageList.Name
  else
    Result:= inherited GetDisplayName;
end;

procedure TJDImageListRef.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDImageListRef.SetImageList(const Value: TImageList);
begin
  // FIX (review §3.35): the image list used to be stored as a bare pointer,
  // so if the TImageList was destroyed first this reference dangled and
  // PopulateImageList crashed on it. Register the owning TJDFontGlyphs
  // component for free-notification instead: when the image list is freed,
  // TJDFontGlyphs.Notification nils this reference. (The old list is
  // unregistered here when the reference changes. A collection item has no
  // Notification of its own, which is why this lives on the owner component.)
  if FImageList <> Value then begin
    if (FImageList <> nil) and (FOwner <> nil) and (FOwner.FOwner <> nil) then
      FImageList.RemoveFreeNotification(FOwner.FOwner);
    FImageList:= Value;
    if (Value <> nil) and (FOwner <> nil) and (FOwner.FOwner <> nil) then
      Value.FreeNotification(FOwner.FOwner);
  end;
  Invalidate;
end;

{ TJDImageListRefs }

constructor TJDImageListRefs.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJDImageListRef);
  FOwner:= TJDFontGlyphs(AOwner);
end;

function TJDImageListRefs.Add: TJDImageListRef;
begin
  Result:= TJDImageListRef(inherited Add);
  Invalidate;
end;

function TJDImageListRefs.GetItem(Index: Integer): TJDImageListRef;
begin
  Result:= TJDImageListRef(inherited Items[Index]);
end;

function TJDImageListRefs.Insert(Index: Integer): TJDImageListRef;
begin
  Result:= TJDImageListRef(inherited Insert(Index));
  Invalidate;
end;

procedure TJDImageListRefs.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDImageListRefs.SetItem(Index: Integer; const Value: TJDImageListRef);
begin
  inherited Items[Index]:= Value;
  Invalidate;
end;

{ TJDFontGlyphRef }

constructor TJDFontGlyphRef.Create(AOwner: TJDFontGlyphItem);
begin
  FOwner:= AOwner;
  //TODO: Use default constants
  Self.FColor:= clBlue;
  Self.FUseStandardColor:= True;
  Self.FFontName:= 'FontAwesome';
end;

destructor TJDFontGlyphRef.Destroy;
begin

  inherited;
end;

function TJDFontGlyphRef.GetGlyph: String;
begin
  Result:= FOwner.Glyph;
end;

function TJDFontGlyphRef.GetStandardColor: TJDStandardColor;
begin
  Result:= FOwner.Color;
end;

procedure TJDFontGlyphRef.SetColor(const Value: TColor);
begin
  FColor:= Value;
  FOwner.Invalidate;
end;

procedure TJDFontGlyphRef.SetFontName(const Value: TFontName);
begin
  FFontName:= Value;
  FOwner.Invalidate;
end;

procedure TJDFontGlyphRef.SetGlyph(const Value: String);
begin
  FOwner.FGlyph := Value;
  FOwner.Invalidate;
end;

procedure TJDFontGlyphRef.SetStandardColor(const Value: TJDStandardColor);
begin
  FOwner.Color:= Value;
end;

procedure TJDFontGlyphRef.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor := Value;
  FOwner.Invalidate;
end;

{ TJDFontGlyphItem }

constructor TJDFontGlyphItem.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);
  FOwner:= TJDFontGlyphList(AOwner);
  //TODO: Implement default constants
  FCaption:= 'New Glyph';
  FGlyph:= 'a';
  FScale:= 0.96;
  FColor:= TJDStandardColor.fcNeutral;
  FRef:= TJDFontGlyphRef.Create(Self);
end;

destructor TJDFontGlyphItem.Destroy;
begin
  FRef.Free;
  inherited;
end;

procedure TJDFontGlyphItem.Assign(Source: TPersistent);
var
  S: TJDFontGlyphItem;
begin
  if Source is TJDFontGlyphItem then begin
    S:= TJDFontGlyphItem(Source);
    Self.Caption:= S.Caption;
    Self.Glyph:= S.Glyph;
    Self.Color:= S.Color;
    Self.Scale:= S.Scale;
    Self.Ref:= S.Ref;
  end else
    inherited;
end;

function TJDFontGlyphItem.GetDisplayName: String;
begin
  Result:= FCaption;
end;

procedure TJDFontGlyphItem.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDFontGlyphItem.SetCaption(const Value: String);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDFontGlyphItem.SetColor(const Value: TJDStandardColor);
begin
  FColor := Value;
  Invalidate;
end;

procedure TJDFontGlyphItem.SetRef(const Value: TJDFontGlyphRef);
begin
  FRef.Assign(Value);
  Invalidate;
end;

procedure TJDFontGlyphItem.SetGlyph(const Value: String);
begin
  if Length(Value) <> 1 then
    raise Exception.Create('Glyph text must be 1 character');
  //TODO: Support values larger than 1 character
  FGlyph := Value;
  Invalidate;
end;

procedure TJDFontGlyphItem.SetScale(const Value: Double);
begin
  // FIX (review §3.46): a zero or negative scale made PopulateImageList
  // compute a zero (or negative) font height. Clamp it to a small positive
  // value instead - the glyph just renders tiny rather than breaking.
  if Value <= 0 then
    FScale:= 0.01
  else
    FScale:= Value;
  Invalidate;
end;

{ TJDFontGlyphList }

constructor TJDFontGlyphList.Create(AOwner: TJDFontGlyphs);
begin
  inherited Create(AOwner, TJDFontGlyphItem);
  FOwner:= TJDFontGlyphs(AOwner);
end;

function TJDFontGlyphList.GetItem(Index: Integer): TJDFontGlyphItem;
begin
  Result:= TJDFontGlyphItem(inherited Items[Index]);
end;

function TJDFontGlyphList.Insert(Index: Integer): TJDFontGlyphItem;
begin
  Result:= TJDFontGlyphItem(inherited Insert(Index));
end;

procedure TJDFontGlyphList.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDFontGlyphList.SetItem(Index: Integer;
  const Value: TJDFontGlyphItem);
begin
  inherited Items[Index]:= Value;
end;

procedure TJDFontGlyphList.Update(Item: TCollectionItem);
begin
  inherited;
  Invalidate;
end;

function TJDFontGlyphList.Add: TJDFontGlyphItem;
begin
  Result:= TJDFontGlyphItem(inherited Add);
end;

{ TJDFontGlyphs }

constructor TJDFontGlyphs.Create(AOwner: TComponent);
begin
  inherited;
  FBuffer:= TBitmap.Create;
  FImageLists:= TJDImageListRefs.Create(Self);
  FGlyphs:= TJDFontGlyphList.Create(Self);
end;

destructor TJDFontGlyphs.Destroy;
begin
  FreeAndNil(FGlyphs);
  FBuffer.Free;
  // FreeAndNil (not .Free) so TJDFontGlyphs.Notification can still safely
  // test FImageLists for nil during destruction.
  FreeAndNil(FImageLists);
  inherited;
end;

procedure TJDFontGlyphs.Invalidate;
begin
  Self.PopulateImageList;
end;

procedure TJDFontGlyphs.SetGlyphs(const Value: TJDFontGlyphList);
begin
  FGlyphs.Assign(Value);
  Invalidate;
end;

procedure TJDFontGlyphs.SetImageLists(const Value: TJDImageListRefs);
begin
  FImageLists.Assign(Value);
  Invalidate;
end;

function TJDFontGlyphs.Updating: Boolean;
begin
  Result:= FUpdateCount > 0;
end;

procedure TJDFontGlyphs.WndMethod(var Message: TMessage);
begin
  // FIX (review §3.35): this used to handle WM_JD_COLORCHANGE here AND call
  // inherited, but the base class (TJDMessageComponent) handles that same
  // message by calling Invalidate too - so PopulateImageList ran twice per
  // theme change. Just let inherited handle it, exactly once.
  inherited;
end;

procedure TJDFontGlyphs.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  // FIX (review §3.35): paired with TJDImageListRef.SetImageList - when a
  // referenced TImageList is freed, nil the reference instead of leaving a
  // dangling pointer behind for PopulateImageList to crash on.
  if (Operation = opRemove) and (AComponent is TImageList) and (FImageLists <> nil) then begin
    for I:= 0 to FImageLists.Count-1 do begin
      if FImageLists[I].FImageList = AComponent then
        FImageLists[I].FImageList:= nil;
    end;
  end;
end;

procedure TJDFontGlyphs.Assign(Source: TPersistent);
var
  S: TJDFontGlyphs;
begin
  if Source is TJDFontGlyphs then begin
    S:= TJDFontGlyphs(Source);
    Self.Glyphs.Assign(S.Glyphs);
    Self.ImageLists.Assign(S.ImageLists);
  end else
    inherited;
end;

procedure TJDFontGlyphs.BeginUpdate;
begin
  // The outermost BeginUpdate starts a fresh update; nested calls just add
  // to the count so the matching EndUpdate calls pair up correctly.
  if FUpdateCount = 0 then
    FUpdated:= False;
  Inc(FUpdateCount);
end;

procedure TJDFontGlyphs.EndUpdate;
begin
  if FUpdateCount > 0 then begin
    Dec(FUpdateCount);
    if (FUpdateCount = 0) and FUpdated then
      Invalidate;
  end;
end;

procedure TJDFontGlyphs.PopulateImageList;
var
  ImgLst: TJDImageListRef;
  Glyph: TJDFontGlyphItem;
  MainColor: TColor;
  X, Y: Integer;
  Rect: TRect;
begin
  //Main procedure to populate image lists with glyphs

  if FUpdateCount > 0 then begin
    FUpdated:= True;
    Exit;
  end;

  FBuffer.Canvas.Font.Name:= 'FontAwesome'; //TODO: Use default constants
  FBuffer.Canvas.Font.Quality:= fqAntialiased;
  MainColor:= ColorManager.BaseColor;
  for X := 0 to FImageLists.Count-1 do begin
    ImgLst:= FImageLists[X];
    if Assigned(ImgLst.FImageList) then begin
      ImgLst.FImageList.BeginUpdate;
      try

        ImgLst.FImageList.Clear;
        FBuffer.Width:= ImgLst.FImageList.Width;
        FBuffer.Height:= ImgLst.FImageList.Height;
        Rect:= FBuffer.Canvas.ClipRect;
        FBuffer.Canvas.Brush.Color:= MainColor;
        for Y := 0 to FGlyphs.Count-1 do begin
          Glyph:= FGlyphs[Y];
          FBuffer.Canvas.Font.Name:= Glyph.FRef.FFontName;
          FBuffer.Canvas.Font.Height:= Trunc(FBuffer.Height * Glyph.Scale);

          if Glyph.FRef.FUseStandardColor then
            FBuffer.Canvas.Font.Color:= ColorManager.Color[Glyph.Color]
          else
            FBuffer.Canvas.Font.Color:= Glyph.FRef.FColor;

          FBuffer.Canvas.FillRect(Rect);

          DrawText(FBuffer.Canvas.Handle, PChar(Glyph.Glyph), Length(Glyph.Glyph), Rect,
            DT_CENTER or DT_SINGLELINE or DT_VCENTER);

          ImgLst.ImageList.AddMasked(FBuffer, MainColor);
        end;

      finally
        ImgLst.FImageList.EndUpdate;
      end;
    end;
  end;
end;

{ TJDFontGlyph }

procedure TJDFontGlyph.Assign(Source: TPersistent);
var
  V: TJDFontGlyph;
begin
  if Source is TJDFontGlyph then begin
    V:= TJDFontGlyph(Source);
    FStandardColor:= V.StandardColor;
    FGlyph:= V.Glyph;
    FUseStandardColor:= V.UseStandardColor;
    FFont.Assign(V.Font);
  end else
    inherited;
end;

constructor TJDFontGlyph.Create;
begin
  FFont:= TFont.Create;
  FFont.Name:= 'FontAwesome';
  FFont.Size:= 16;
  FFont.Quality:= fqAntialiased;
  FFont.OnChange:= FontChanged;
  FStandardColor:= fcNeutral;
  FUseStandardColor:= True;

end;

destructor TJDFontGlyph.Destroy;
begin

  FreeAndNil(FFont);
  inherited;
end;

procedure TJDFontGlyph.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDFontGlyph.Invalidate;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TJDFontGlyph.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TJDFontGlyph.SetGlyph(const Value: String);
begin
  FGlyph:= Value;
  Invalidate;
end;

procedure TJDFontGlyph.SetStandardColor(const Value: TJDStandardColor);
begin
  FStandardColor:= Value;
  Invalidate;
end;

procedure TJDFontGlyph.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor := Value;
  Invalidate;
end;

{ TJDGlyphImageItem }

constructor TJDGlyphImageItem.Create(Collection: TCollection);
begin
  inherited;
  // FIX (review §3.35): FOwner was never assigned, so Invalidate crashed on
  // a nil owner. The owner is the TJDGlyphImage that owns this item's
  // collection (same pattern as TJDVectorPoint and the other item classes).
  if Collection is TJDGlyphImageItems then
    FOwner:= TJDGlyphImage(TJDGlyphImageItems(Collection).Owner);
  FScale:= DEF_SCALE;

end;

destructor TJDGlyphImageItem.Destroy;
begin

  inherited;
end;

procedure TJDGlyphImageItem.Invalidate;
begin
  // FOwner is assigned in Create now, but stay safe if this item was ever
  // created without a collection.
  if FOwner <> nil then
    FOwner.Invalidate;
end;

function TJDGlyphImageItem.IsScaleStored: Boolean;
begin
  Result:= FScale <> DEF_SCALE;
end;

procedure TJDGlyphImageItem.SetScale(const Value: Single);
begin
  FScale := Value;
  Invalidate;
end;

{ TJDGlyphImage }

constructor TJDGlyphImage.Create;
begin
  // FIX (review §3.35): FGlyphs was never created, so SetGlyphs crashed the
  // moment anything assigned to it. Create the collection here, owned by
  // this image (same pattern as TJDVectorPart creates its FPoints).
  FGlyphs:= TJDGlyphImageItems.Create(Self, TJDGlyphImageItem);
end;

destructor TJDGlyphImage.Destroy;
begin
  FreeAndNil(FGlyphs);
  inherited;
end;

procedure TJDGlyphImage.Invalidate;
begin

end;

procedure TJDGlyphImage.SetGlyphs(const Value: TJDGlyphImageItems);
begin
  FGlyphs.Assign(Value);
  Invalidate;
end;

{ TJDGlyphImageList }

constructor TJDGlyphImageList.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TJDGlyphImageList.Destroy;
begin

  inherited;
end;

procedure TJDGlyphImageList.Invalidate;
begin
  inherited;

end;

procedure TJDGlyphImageList.WndMethod(var Message: TMessage);
begin
  // FIX (review §3.35): same double-handling as TJDFontGlyphs.WndMethod -
  // the base class already calls Invalidate for WM_JD_COLORCHANGE, so
  // handling it here too ran it twice. Let inherited handle it, exactly once.
  inherited;
end;

end.


unit JD.FontGlyphs;

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
    FUpdating: Boolean;
    FUpdated: Boolean;
    procedure SetGlyphs(const Value: TJDFontGlyphList);
    procedure SetImageLists(const Value: TJDImageListRefs);
  protected
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
  FImageList := Value;
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
  Result:= Fowner.Color;
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
  //TODO: Restrict value to > 0
  FScale := Value;
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
  FImageLists.Free;
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
  Result:= FUpdating;
end;

procedure TJDFontGlyphs.WndMethod(var Message: TMessage);
begin
  if Message.Msg = WM_JD_COLORCHANGE then begin
    Invalidate;
  end;
  inherited;
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
  if not FUpdating then begin
    FUpdating:= True;
    FUpdated:= False;
  end;
end;

procedure TJDFontGlyphs.EndUpdate;
begin
  if FUpdating then begin
    FUpdating:= False;
    if FUpdated then
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

  if FUpdating then begin
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

end.

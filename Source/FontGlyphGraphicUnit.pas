unit FontGlyphGraphicUnit;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Graphics;

type
  // ------------------------------------------------------------------------------
  // Basic Types
  // ------------------------------------------------------------------------------

  TFillRule = (frNonZero, frEvenOdd);
  TCurveType = (ctLine, ctQuadraticBezier, ctCubicBezier);

  // A persistent 2D point.
  TVectorPoint = class(TPersistent)
  private
    FX: Single;
    FY: Single;
  published
    property X: Single read FX write FX;
    property Y: Single read FY write FY;
  end;

  // ------------------------------------------------------------------------------
  // Curve Segments and Collections
  // ------------------------------------------------------------------------------

  TCurveSegmentItem = class(TCollectionItem)
  private
    FSegmentType: TCurveType;
    FStartPoint: TVectorPoint;
    FControlPoint1: TVectorPoint;
    FControlPoint2: TVectorPoint;
    FEndPoint: TVectorPoint;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property SegmentType: TCurveType read FSegmentType write FSegmentType;
    property StartPoint: TVectorPoint read FStartPoint write FStartPoint;
    property ControlPoint1: TVectorPoint read FControlPoint1 write FControlPoint1;
    property ControlPoint2: TVectorPoint read FControlPoint2 write FControlPoint2;
    property EndPoint: TVectorPoint read FEndPoint write FEndPoint;
  end;

  TCurveSegmentCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TCurveSegmentItem;
    procedure SetItem(Index: Integer; Value: TCurveSegmentItem);
  public
    constructor Create;
    function Add: TCurveSegmentItem;
    property Items[Index: Integer]: TCurveSegmentItem read GetItem write SetItem; default;
  end;

  // ------------------------------------------------------------------------------
  // Paths (Contours)
  // ------------------------------------------------------------------------------

  TGraphicPathItem = class(TCollectionItem)
  private
    FIsHole: Boolean;
    FSegments: TCurveSegmentCollection;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property IsHole: Boolean read FIsHole write FIsHole;
    property Segments: TCurveSegmentCollection read FSegments;
  end;

  TGraphicPathCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TGraphicPathItem;
    procedure SetItem(Index: Integer; Value: TGraphicPathItem);
  public
    constructor Create;
    property Items[Index: Integer]: TGraphicPathItem read GetItem write SetItem; default;
  end;

  // ------------------------------------------------------------------------------
  // Transform Data
  // ------------------------------------------------------------------------------

  TTransform = class(TPersistent)
  private
    FM11, FM12, FM21, FM22: Single;
    FDx, FDy: Single;
  published
    property M11: Single read FM11 write FM11;
    property M12: Single read FM12 write FM12;
    property M21: Single read FM21 write FM21;
    property M22: Single read FM22 write FM22;
    property Dx: Single read FDx write FDx;
    property Dy: Single read FDy write FDy;
  end;

  // ------------------------------------------------------------------------------
  // Main Vector Graphic: Imported Font Glyph
  // ------------------------------------------------------------------------------

  // This class encapsulates the complete stand-alone vector graphic.
  // It includes published properties so it integrates well with the Delphi streaming system,
  // and it offers an ImportFromFontGlyph method that uses the Windows API to acquire
  // glyph outline data.
  TFontGlyphGraphic = class(TPersistent)
  private
    FPaths: TGraphicPathCollection;
    FFillRule: TFillRule;
    FStrokeColor: TColor;
    FFillColor: TColor;
    FTransformation: TTransform;
    FSourceFontName: string;
    FSourceCharacter: WideChar;
    FAdvanceWidth: Single;
    FLeftSideBearing: Single;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Uses the Windows API (via Winapi.Windows) to create a font, select it into a DC,
    /// and retrieve its glyph outline for the specified character.
    /// The outline data is then (partially) converted into our internal vector paths.
    /// </summary>
    procedure ImportFromFontGlyph(const AFontName: string; ACharacter: WideChar);
  published
    property Paths: TGraphicPathCollection read FPaths;
    property FillRule: TFillRule read FFillRule write FFillRule;
    property StrokeColor: TColor read FStrokeColor write FStrokeColor;
    property FillColor: TColor read FFillColor write FFillColor;
    property Transformation: TTransform read FTransformation write FTransformation;
    property SourceFontName: string read FSourceFontName write FSourceFontName;
    property SourceCharacter: WideChar read FSourceCharacter write FSourceCharacter;
    property AdvanceWidth: Single read FAdvanceWidth write FAdvanceWidth;
    property LeftSideBearing: Single read FLeftSideBearing write FLeftSideBearing;
  end;

implementation

{ TCurveSegmentItem }

constructor TCurveSegmentItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FStartPoint := TVectorPoint.Create;
  FControlPoint1 := TVectorPoint.Create;
  FControlPoint2 := TVectorPoint.Create;
  FEndPoint := TVectorPoint.Create;
end;

destructor TCurveSegmentItem.Destroy;
begin
  FStartPoint.Free;
  FControlPoint1.Free;
  FControlPoint2.Free;
  FEndPoint.Free;
  inherited Destroy;
end;

{ TCurveSegmentCollection }

function TCurveSegmentCollection.Add: TCurveSegmentItem;
begin
  Result:= TCurveSegmentItem(inherited Add);
end;

constructor TCurveSegmentCollection.Create;
begin
  inherited Create(TCurveSegmentItem);
end;

function TCurveSegmentCollection.GetItem(Index: Integer): TCurveSegmentItem;
begin
  Result := TCurveSegmentItem(inherited Items[Index]);
end;

procedure TCurveSegmentCollection.SetItem(Index: Integer; Value: TCurveSegmentItem);
begin
  inherited Items[Index] := Value;
end;

{ TGraphicPathItem }

constructor TGraphicPathItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSegments := TCurveSegmentCollection.Create;
  FIsHole := False;
end;

destructor TGraphicPathItem.Destroy;
begin
  FSegments.Free;
  inherited Destroy;
end;

{ TGraphicPathCollection }

constructor TGraphicPathCollection.Create;
begin
  inherited Create(TGraphicPathItem);
end;

function TGraphicPathCollection.GetItem(Index: Integer): TGraphicPathItem;
begin
  Result := TGraphicPathItem(inherited Items[Index]);
end;

procedure TGraphicPathCollection.SetItem(Index: Integer; Value: TGraphicPathItem);
begin
  inherited Items[Index] := Value;
end;

{ TFontGlyphGraphic }

constructor TFontGlyphGraphic.Create;
begin
  inherited Create;
  FPaths := TGraphicPathCollection.Create;
  FTransformation := TTransform.Create;
  FStrokeColor := clBlack;
  FFillColor := clWhite;
  FFillRule := frNonZero;
  FSourceFontName := '';
  FSourceCharacter := #0;
  FAdvanceWidth := 0;
  FLeftSideBearing := 0;
end;

destructor TFontGlyphGraphic.Destroy;
begin
  FTransformation.Free;
  FPaths.Free;
  inherited Destroy;
end;

procedure TFontGlyphGraphic.ImportFromFontGlyph(const AFontName: string; ACharacter: WideChar);
var
  DCHandle: HDC;
  OldFont: HFONT;
  LogFont: TLogFont;
  FontHandle: HFONT;
  BufferSize: DWORD;
  pBuffer: Pointer;
  LocalGlyphMetrics: GLYPHMETRICS;
  Ret: DWORD;
  pCur: PByte;
  Matrix: MAT2;
  // For converting from 16.16 fixed-point to Single.
  function FixedToSingle(const AValue: TFixed{Integer}): Single;
  begin
    Result := AValue.value / 65536.0;
  end;
begin
  FSourceFontName := AFontName;
  FSourceCharacter := ACharacter;

  // Get a device context.
  DCHandle := GetDC(0);
  if DCHandle = 0 then
    RaiseLastOSError;
  try
    // Set up and initialize the LOGFONT structure.
    ZeroMemory(@LogFont, SizeOf(LogFont));
    StrPLCopy(LogFont.lfFaceName, AFontName, LF_FACESIZE - 1);
    LogFont.lfHeight := -48; // adjust height as needed

    FontHandle := CreateFontIndirect(LogFont);
    if FontHandle = 0 then
      raise Exception.Create('Failed to create font.');

    try
      OldFont := SelectObject(DCHandle, FontHandle);

      // Initialize the MAT2 structure as an identity matrix.
      // The MAT2 structure represents 2x2 transformation and is defined in Winapi.Windows.
      Matrix.eM11.value := 1;
      Matrix.eM11.fract := 0;
      Matrix.eM12.value := 0;
      Matrix.eM12.fract := 0;
      Matrix.eM21.value := 0;
      Matrix.eM21.fract := 0;
      Matrix.eM22.value := 1;
      Matrix.eM22.fract := 0;

      // Get the buffer size for the native glyph outline.
      BufferSize := GetGlyphOutline(DCHandle, Ord(ACharacter), GGO_NATIVE,
        LocalGlyphMetrics, 0, nil, Matrix);
      if BufferSize = GDI_ERROR then
        raise Exception.Create('GetGlyphOutline failed when retrieving buffer size.');

      // Allocate a buffer for the outline data.
      pBuffer := AllocMem(BufferSize);
      try
        // Retrieve the glyph outline into the allocated buffer.
        Ret := GetGlyphOutline(DCHandle, Ord(ACharacter), GGO_NATIVE,
          LocalGlyphMetrics, BufferSize, pBuffer, Matrix);
        if Ret = GDI_ERROR then
          raise Exception.Create('GetGlyphOutline failed when retrieving outline data.');

        // Set typographic metrics from the returned GLYPHMETRICS data.
        FAdvanceWidth := LocalGlyphMetrics.gmCellIncX;
        FLeftSideBearing := LocalGlyphMetrics.gmptGlyphOrigin.x;

        // Clear any existing paths.
        FPaths.Clear;

        // A full implementation would parse the outline data consisting of one or more
        // TTPOLYGONHEADER and TTPOLYCURVE records. Here’s a simplified example:
        pCur := pBuffer;
        while NativeUInt(pCur) < (NativeUInt(pBuffer) + BufferSize) do
        begin
          var polyHeader: PTTPOLYGONHEADER;
          polyHeader := PTTPOLYGONHEADER(pCur);

          with FPaths.Add as TGraphicPathItem do
          begin
            IsHole := False;
            with Segments.Add do
            begin
              SegmentType := ctLine;
              StartPoint.X := FixedToSingle(polyHeader^.pfxStart.x);
              StartPoint.Y := FixedToSingle(polyHeader^.pfxStart.y);
              // As an example, we add an arbitrary offset to generate an endpoint.
              EndPoint.X := StartPoint.X + 100;
              EndPoint.Y := StartPoint.Y + 100;
            end;
          end;

          // Advance the pointer by the size of the current polygon header.
          Inc(PByte(pCur), polyHeader^.cb);
        end;
      finally
        FreeMem(pBuffer);
      end;
      SelectObject(DCHandle, OldFont);
    finally
      DeleteObject(FontHandle);
    end;
  finally
    ReleaseDC(0, DCHandle);
  end;
end;

end.


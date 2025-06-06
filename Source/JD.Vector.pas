unit JD.Vector;

(*
  JD Vector Library

  Design vector graphics in design-time IDE and render to VCL canvas via GDI+.

  Features:
  - Design a vector graphic within Delphi IDE via Object Inspector.
  - Load/Save vector graphic via JSON String.
  - TODO: Create vector image list.
  - TODO: Import/export font glyphs.
  - TODO: Design vector graphic on canvas in design-time (drag and drop).
  - TODO: Hierarchy of parts

  Usage:
  - Create instance of TJDVectorGraphic
  - Create items in "Parts" collection
    - Each part represents a single polygon of a specific color or texture
    - Each part gets rendered in order from top to bottom
    - Create vector points in "Points" collection
  - Call "Render" to draw graphic to destination canvas

*)

{.$DEFINE USE_PATHS}

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes,
  System.Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics, Vcl.Controls,
  JD.Ctrls,
  JD.Common,
  JD.Graphics,
  XSuperObject,
  GDIPAPI, GDIPOBJ, GDIPUTIL;

type
  /// <summary>
  ///   Represents a single point in a vector polygon.
  /// </summary>
  TJDVectorPoint = class;

  /// <summary>
  ///   Represents array of points making up a vector polygon.
  /// </summary>
  TJDVectorPoints = class;

  /// <summary>
  ///   Represents a single vector part in a vector graphic.
  /// </summary>
  TJDVectorPart = class;

  /// <summary>
  ///   Represents multiple parts making up a complete vector graphic.
  /// </summary>
  TJDVectorParts = class;

  /// <summary>
  ///   Represents a single point in a vector polygon.
  /// </summary>
  TJDVectorGraphic = class;

  /// <summary>
  ///   Preset vector shapes (NOT CURRENTLY IN USE)
  /// </summary>
  /// <remarks>
  ///   vsCustom: Custom polygon
  ///   vsTriangle: Triangle
  ///   vsRectangle: Rectangle
  ///   vsPentagon: Pentagon
  ///   vsHexagon: Hexagon
  /// </remarks>
  TJDVectorShape = (vsCustom, vsTriangle, vsRectangle, vsPentagon, vsHexagon);

  TJDVectorAlign = (vaLeading, vaCenter, vaTrailing);

  TJDVectorPoint = class(TCollectionItem)
  private
    FOwner: TJDVectorPoints;
    FX: Single;
    FY: Single;
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;

    procedure LoadFromJSON(O: ISuperObject);
    function SaveToJSON: ISuperObject;

    procedure LoadFromString(S: String);
    function SaveToString: String;

  published
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
  end;

  TJDVectorPoints = class(TOwnedCollection)
  private
    FOwner: TJDVectorPart;
    function GetItem(Index: Integer): TJDVectorPoint;
    procedure SetItem(Index: Integer; const Value: TJDVectorPoint);
  protected
    procedure Update(Item: TCollectionItem); override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  public
    constructor Create(AOwner: TJDVectorPart);
    procedure Invalidate;
    function GetNamePath: string; override;
    function Add: TJDVectorPoint;
    function Insert(Index: Integer): TJDVectorPoint;

    procedure LoadFromJSON(A: ISuperArray);
    function SaveToJSON: ISuperArray;

    procedure LoadFromString(S: String);
    function SaveToString: String;

    property Items[Index: Integer]: TJDVectorPoint read GetItem write SetItem; default;
  end;

  TJDVectorPart = class(TCollectionItem)
  const
    DEF_SCALE = 0.96;
  private
    FOwner: TJDVectorParts;
    FOffsetX: Single;
    FOffsetY: Single;
    FCaption: String;
    FScale: Double;
    FPoints: TJDVectorPoints;
    FShape: TJDVectorShape;
    FPen: TJDUIPen;
    FBrush: TJDUISolidBrush;
    FParts: TJDVectorParts;
    FSubtractive: Boolean;
    procedure SetCaption(const Value: String);
    procedure SetOffsetX(const Value: Single);
    procedure SetOffsetY(const Value: Single);
    procedure SetScale(const Value: Double);
    procedure SetPoints(const Value: TJDVectorPoints);
    function ToJDPoints: TJDPoints;
    procedure SetShape(const Value: TJDVectorShape);
    function GetScaleStored: Boolean;
    procedure SetBrush(const Value: TJDUISolidBrush);
    procedure SetPen(const Value: TJDUIPen);
    procedure BrushChanged(Sender: TObject);
    procedure PenChanged(Sender: TObject);
    procedure SetParts(const Value: TJDVectorParts);
    procedure SetSubtractive(const Value: Boolean);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
    procedure Render(ACanvas: TGPGraphics; const X, Y: Single; const GlobalScale: Single = 1.0);

    procedure LoadFromJSON(O: ISuperObject);
    function SaveToJSON: ISuperObject;

    procedure LoadFromString(S: String);
    function SaveToString: String;

    procedure LoadFromFont(const FontName: TFontName; const Character: Char);

  published
    property Brush: TJDUISolidBrush read FBrush write SetBrush;
    property Pen: TJDUIPen read FPen write SetPen;
    property Caption: String read FCaption write SetCaption;
    property Scale: Double read FScale write SetScale stored GetScaleStored;
    property OffsetX: Single read FOffsetX write SetOffsetX;
    property OffsetY: Single read FOffsetY write SetOffsetY;
    property Parts: TJDVectorParts read FParts write SetParts; //TODO: Hierarchy...
    property Points: TJDVectorPoints read FPoints write SetPoints;
    property Shape: TJDVectorShape read FShape write SetShape default vsCustom;
    property Subtractive: Boolean read FSubtractive write SetSubtractive;
  end;

  TJDVectorParts = class(TOwnedCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TJDVectorPart;
    procedure SetItem(Index: Integer; const Value: TJDVectorPart);
  protected
    procedure Update(Item: TCollectionItem); override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  public
    constructor Create(AOwner: TPersistent);
    procedure Invalidate;
    function Add: TJDVectorPart;
    function Insert(Index: Integer): TJDVectorPart;

    procedure LoadFromJSON(A: ISuperArray);
    function SaveToJSON: ISuperArray;

    procedure LoadFromString(S: String);
    function SaveToString: String;

    property Items[Index: Integer]: TJDVectorPart read GetItem write SetItem; default;
  end;

  TJDVectorGraphic = class(TPersistent)
  private
    FOwner: TPersistent;
    FParts: TJDVectorParts;
    FOnChange: TNotifyEvent;
    FScale: Single;
    FOffsetX: Single;
    FOffsetY: Single;
    FName: TCaption;
    FCaption: TCaption;
    procedure SetParts(const Value: TJDVectorParts);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetScale(const Value: Single);
    procedure SetOffsetX(const Value: Single);
    procedure SetOffsetY(const Value: Single);
    procedure SetCaption(const Value: TCaption);
    procedure SetName(const Value: TCaption);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); virtual;
    destructor Destroy; override;
    property Owner: TPersistent read FOwner;
    procedure Assign(Source: TPersistent); override;

    procedure Invalidate; virtual;
    function GetBounds(const AltScale: Single = 1.0): TJDRect;
    procedure Render(ACanvas: TGPGraphics; const X, Y: Single;
      const AltScale: Single = 1.0);

    procedure LoadFromJSON(O: ISuperObject);
    function SaveToJSON: ISuperObject;

    procedure LoadFromString(S: String);
    function SaveToString: String;

  published
    property Caption: TCaption read FCaption write SetCaption;
    property Name: TCaption read FName write SetName;
    property Parts: TJDVectorParts read FParts write SetParts;
    property Scale: Single read FScale write SetScale;
    property OffsetX: Single read FOffsetX write SetOffsetX;
    property OffsetY: Single read FOffsetY write SetOffsetY;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;


  TJDVectorGraphicListItem = class(TCollectionItem)

  end;

  TJDVectorGraphicListItems = class(TOwnedCollection)

  end;



implementation

uses
  System.Math;

{ TJDVectorPoint }

constructor TJDVectorPoint.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);
  FOwner:= TJDVectorPoints(AOwner);
  FX:= 0;
  FY:= 0;
end;

destructor TJDVectorPoint.Destroy;
begin

  inherited;
end;

procedure TJDVectorPoint.Assign(Source: TPersistent);
begin
  if Source is TJDVectorPoint then begin
    var S:= TJDVectorPoint(Source);
    FX:= S.X;
    FY:= S.Y;
    Invalidate;
  end else
    inherited;
end;

function TJDVectorPoint.GetDisplayName: String;
begin
  Result:= FormatFloat('0000.0000', X)+' , '+FormatFloat('0000.0000', Y);
end;

procedure TJDVectorPoint.Invalidate;
begin
  if FOwner <> nil then
    FOwner.Invalidate;
end;

procedure TJDVectorPoint.LoadFromJSON(O: ISuperObject);
begin
  FX:= O.F['X'];
  FY:= O.F['Y'];
  Invalidate;
end;

function TJDVectorPoint.SaveToJSON: ISuperObject;
begin
  Result:= SO;
  Result.F['X']:= X;
  Result.F['Y']:= Y;
end;

procedure TJDVectorPoint.LoadFromString(S: String);
begin
  LoadFromJSON(SO(S));
end;

function TJDVectorPoint.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
end;

procedure TJDVectorPoint.SetX(const Value: Single);
begin
  FX := Value;
  Invalidate;
end;

procedure TJDVectorPoint.SetY(const Value: Single);
begin
  FY := Value;
  Invalidate;
end;

{ TJDVectorPoints }

constructor TJDVectorPoints.Create(AOwner: TJDVectorPart);
begin
  inherited Create(AOwner, TJDVectorPoint);
  FOwner:= AOwner;
end;

function TJDVectorPoints.GetItem(Index: Integer): TJDVectorPoint;
begin
  Result:= TJDVectorPoint(inherited Items[Index]);
end;

function TJDVectorPoints.GetNamePath: string;
var
  S, P: string;
begin
  //TODO
  Result := ClassName;
  if GetOwner = nil then Exit;
  if GetOwner is TJDVectorPart then begin
    Result:= TJDVectorPart(GetOwner).Caption;
  end else begin
    S := GetOwner.GetNamePath;
    if S = '' then Exit;
    P := PropName;
    if P = '' then Exit;
    Result := S + '.' + P;
  end;
end;

function TJDVectorPoints.Add: TJDVectorPoint;
begin
  Result:= TJDVectorPoint(inherited Add);
end;

function TJDVectorPoints.Insert(Index: Integer): TJDVectorPoint;
begin
  Result:= TJDVectorPoint(inherited Insert(Index));
end;

procedure TJDVectorPoints.Invalidate;
begin
  if FOwner <> nil then
    FOwner.Invalidate;
end;

procedure TJDVectorPoints.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
  Invalidate;
end;

procedure TJDVectorPoints.LoadFromJSON(A: ISuperArray);
var
  X: Integer;
begin
  Clear;
  for X := 0 to A.Length-1 do begin
    var P:= Self.Add;
    P.LoadFromJSON(A.O[X]);
  end;
end;

function TJDVectorPoints.SaveToJSON: ISuperArray;
var
  X: Integer;
begin
  Result:= SA;
  for X := 0 to Count-1 do begin
    Result.Add(Items[X].SaveToJSON);
  end;
end;

procedure TJDVectorPoints.LoadFromString(S: String);
var
  A: ISuperArray;
  X: Integer;
begin
  Clear;
  A:= SA(S);
  for X := 0 to A.Length-1 do begin
    var P:= Self.Add;
    P.LoadFromString(A.S[X]);
  end;
end;

function TJDVectorPoints.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
end;

procedure TJDVectorPoints.SetItem(Index: Integer; const Value: TJDVectorPoint);
begin
  inherited Items[Index]:= Value;
end;

procedure TJDVectorPoints.Update(Item: TCollectionItem);
begin
  inherited;
  Invalidate;
end;

{ TJDVectorPart }

constructor TJDVectorPart.Create(AOwner: TCollection);
begin
  inherited;
  FOwner:= TJDVectorParts(AOwner);
  FPoints:= TJDVectorPoints.Create(Self);
  FBrush:= TJDUISolidBrush.Create(Self);
  FBrush.OnChange:= BrushChanged;
  FBrush.Color.Color:= clNavy;
  FPen:= TJDUIPen.Create(Self);
  FPen.OnChange:= PenChanged;
  FPen.Color.Color:= clGray;
  FPen.Width:= 3;
  FCaption:= 'New Part';
  FScale:= DEF_SCALE;
  FOffsetX:= 0;
  FOffsetY:= 0;
  FParts:= TJDVectorParts.Create(Self);
end;

destructor TJDVectorPart.Destroy;
begin
  FreeAndNil(FParts);
  FreeAndNil(FPen);
  FreeAndNil(FBrush);
  FreeAndNil(FPoints);
  inherited;
end;

procedure TJDVectorPart.BrushChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDVectorPart.PenChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDVectorPart.Assign(Source: TPersistent);
begin
  if Source is TJDVectorPart then begin
    var S:= TJDVectorPart(Source);
    FOffsetX:= S.OffsetX;
    FOffsetY:= S.OffsetY;
    FScale:= S.Scale;
    FCaption:= S.Caption;
    FPoints.Assign(S.Points);
    FBrush.Assign(S.Brush);
    FPen.Assign(S.Pen);
    FShape:= S.Shape;
    FParts.Assign(S.Parts);
    FSubtractive:= S.Subtractive;

    Invalidate;
  end else
    inherited;
end;

function TJDVectorPart.GetDisplayName: String;
begin
  if FCaption <> '' then
    Result:= FCaption
  else
    Result:= '(No Name)';
end;

function TJDVectorPart.GetScaleStored: Boolean;
begin
  Result:= FScale <> DEF_SCALE;
end;

procedure TJDVectorPart.Invalidate;
begin
  if FOwner <> nil then
    FOwner.Invalidate;
end;

function TJDVectorPart.ToJDPoints: TJDPoints;
var
  I: Integer;
begin
  SetLength(Result, FPoints.Count);
  for I := 0 to FPoints.Count - 1 do
  begin
    Result[I] := TJDPoint.Create(FPoints[I].X, FPoints[I].Y);
  end;
end;

function GPPointF(const X, Y: Single): TGPPointF;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

{
procedure TJDVectorPart.Render(ACanvas: TGPGraphics; const X, Y: Single; const GlobalScale: Single);
var
  B: TGPBrush;
  P: TGPPen;
  Polygon: array of TGPPointF;
  JDPoints: TJDPoints;
  I: Integer;
  Path: TGPGraphicsPath;
begin
  JDPoints := ToJDPoints; // Convert vector points to standardized JDPoints

  if Length(JDPoints) = 0 then Exit;

  // Convert JDPoints to TGPPointF array
  SetLength(Polygon, Length(JDPoints));
  for I := 0 to High(JDPoints) do
    Polygon[I] := GPPointF(
      (JDPoints[I].X * Scale * GlobalScale) + X + (FOffsetX * Scale * GlobalScale),
      (JDPoints[I].Y * Scale * GlobalScale) + Y + (FOffsetY * Scale * GlobalScale)
    );

  // Actual rendering...
  B := FBrush.MakeBrush;
  P := FPen.MakePen;
  try

    Path:= TGPGraphicsPath.Create;
    try

      Path.AddPolygon(PGPPointF(@Polygon[0]), Length(Polygon));

      if Self.FSubtractive then
        Path.SetFillMode(FillModeWinding);

      //New path-based rendering...
      ACanvas.FillPath(B, Path);
      ACanvas.DrawPath(P, Path);

      //Original polygon rendering...
      //ACanvas.FillPolygon(B, PGPPointF(@Polygon[0]), Length(Polygon));
      //ACanvas.DrawPolygon(P, PGPPointF(@Polygon[0]), Length(Polygon));
    finally
      Path.Free;
    end;

  finally
    P.Free;
    B.Free;
  end;

  // Sub-parts...
  for I := 0 to Parts.Count-1 do begin
    Parts[I].Render(ACanvas, X, Y, GlobalScale);
  end;

end;
}

procedure TJDVectorPart.Render(ACanvas: TGPGraphics; const X, Y: Single; const GlobalScale: Single);
var
  B: TGPBrush;
  P: TGPPen;
  Polygon: array of TGPPointF;
  JDPoints: TJDPoints;
  I: Integer;
  Path: TGPGraphicsPath;
  //ClippingRegion: TGPRegion;
begin
  JDPoints := ToJDPoints; // Convert vector points to standardized JDPoints
  if Length(JDPoints) = 0 then Exit;

  // Convert JDPoints to TGPPointF array
  SetLength(Polygon, Length(JDPoints));
  for I := 0 to High(JDPoints) do
    Polygon[I] := GPPointF(
      (JDPoints[I].X * Scale * GlobalScale) + X + (FOffsetX * Scale * GlobalScale),
      (JDPoints[I].Y * Scale * GlobalScale) + Y + (FOffsetY * Scale * GlobalScale)
    );

  B := FBrush.MakeBrush;
  P := FPen.MakePen;
  try
    Path := TGPGraphicsPath.Create;
    try
      {$IFDEF USE_PATHS}
      // **Path-Based Rendering**
      for I := 0 to High(Polygon) do
      begin
        if I = 0 then
          Path.StartFigure;
        Path.AddLine(Polygon[I].X, Polygon[I].Y);
      end;
      Path.CloseFigure;
      {$ELSE}
      // **Polygon-Based Rendering (Legacy Mode)**
      Path.AddPolygon(PGPPointF(@Polygon[0]), Length(Polygon));
      {$ENDIF}

      if Self.FSubtractive then
      begin
        // **Create the clipping region**
        {
        ClippingRegion := TGPRegion.Create(Path);
        ACanvas.SetClip(ClippingRegion, CombineModeIntersect); // This ensures the area is removed
        ACanvas.FillRectangle(B, X, Y, GlobalScale * 100, GlobalScale * 100); // Fill BG with transparent brush
        ClippingRegion.Free;
        }

        var Region:= TGPRegion.Create(Path);
        try
          ACanvas.ExcludeClip(Region);
        finally
          Region.Free;
        end;
      end
      else
      begin
        ACanvas.FillPath(B, Path);
        ACanvas.DrawPath(P, Path);
      end;

    finally
      Path.Free;
    end;

  finally
    P.Free;
    B.Free;
  end;

  // Render Sub-parts
  for I := 0 to Parts.Count - 1 do
    Parts[I].Render(ACanvas, X, Y, GlobalScale);
end;

procedure TJDVectorPart.LoadFromFont(const FontName: TFontName;
  const Character: Char);
begin

end;

procedure TJDVectorPart.LoadFromJSON(O: ISuperObject);
begin
  FCaption:= O.S['Caption'];
  FBrush.LoadFromJSON(O.O['Brush']);
  FPen.LoadFromJSON(O.O['Pen']);
  FPoints.LoadFromJSON(O.A['Points']);
  FOffsetX:= O.F['OffsetX'];
  FOffsetY:= O.F['OffsetY'];
  FScale:= O.F['Scale'];
  FShape:= TJDVectorShape(O.I['Shape']);
  FParts.LoadFromJSON(O.A['Parts']);
  FSubtractive:= O.B['Subtractive'];
end;

function TJDVectorPart.SaveToJSON: ISuperObject;
begin
  Result:= SO;
  Result.S['Caption']:= Caption;
  Result.O['Brush']:= Brush.SaveToJSON;
  Result.O['Pen']:= Pen.SaveToJSON;
  Result.A['Points']:= Points.SaveToJSON;
  Result.F['OffsetX']:= OffsetX;
  Result.F['OffsetY']:= OffsetY;
  Result.F['Scale']:= Scale;
  Result.I['Shape']:= Integer(Shape);
  Result.A['Parts']:= Parts.SaveToJSON;
  Result.B['Subtractive']:= Subtractive;
end;

procedure TJDVectorPart.LoadFromString(S: String);
begin
  LoadFromJSON(SO(S));
end;

function TJDVectorPart.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
end;

procedure TJDVectorPart.SetBrush(const Value: TJDUISolidBrush);
begin
  FBrush.Assign(Value);
  Invalidate;
end;

procedure TJDVectorPart.SetCaption(const Value: String);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetOffsetX(const Value: Single);
begin
  FOffsetX := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetOffsetY(const Value: Single);
begin
  FOffsetY := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetParts(const Value: TJDVectorParts);
begin
  FParts.Assign(Value);
  Invalidate;
end;

procedure TJDVectorPart.SetPen(const Value: TJDUIPen);
begin
  FPen.Assign(Value);
  Invalidate;
end;

procedure TJDVectorPart.SetPoints(const Value: TJDVectorPoints);
begin
  FPoints.Assign(Value);
  Invalidate;
end;

procedure TJDVectorPart.SetScale(const Value: Double);
begin
  FScale := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetShape(const Value: TJDVectorShape);
begin
  FShape := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetSubtractive(const Value: Boolean);
begin
  FSubtractive := Value;
  Invalidate;
end;

{ TJDVectorParts }

constructor TJDVectorParts.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJDVectorPart);
  FOwner:= AOwner;
end;

function TJDVectorParts.Add: TJDVectorPart;
begin
  Result:= TJDVectorPart(inherited Add);
end;

function TJDVectorParts.GetItem(Index: Integer): TJDVectorPart;
begin
  Result:= TJDVectorPart(inherited Items[Index]);
end;

function TJDVectorParts.Insert(Index: Integer): TJDVectorPart;
begin
  Result:= TJDVectorPart(inherited Insert(Index));
end;

procedure TJDVectorParts.Invalidate;
begin
  if FOwner <> nil then begin
    if FOwner is TJDVectorGraphic then
      TJDVectorGraphic(FOwner).Invalidate
    else if FOwner is TJDVectorPart then
      TJDVectorPart(FOwner).Invalidate;
  end;
end;

procedure TJDVectorParts.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
  Invalidate;
end;

procedure TJDVectorParts.LoadFromJSON(A: ISuperArray);
var
  X: Integer;
begin
  Clear;
  for X := 0 to A.Length-1 do begin
    var P:= Add;
    P.LoadFromJSON(A.O[X]);
  end;
end;

function TJDVectorParts.SaveToJSON: ISuperArray;
var
  X: Integer;
begin
  Result:= SA;
  for X := 0 to Count-1 do begin
    Result.Add(Items[X].SaveToJSON);
  end;
end;

procedure TJDVectorParts.LoadFromString(S: String);
begin
  LoadFromJSON(SA(S));
end;

function TJDVectorParts.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
end;

procedure TJDVectorParts.SetItem(Index: Integer; const Value: TJDVectorPart);
begin
  inherited Items[Index]:= Value;
end;

procedure TJDVectorParts.Update(Item: TCollectionItem);
begin
  inherited;
  Invalidate;
end;

{ TJDVectorGraphic }

procedure TJDVectorGraphic.Assign(Source: TPersistent);
begin
  if Source is TJDVectorGraphic then begin
    var S:= TJDVectorGraphic(Source);
    FParts.Assign(S.Parts);
    FScale:= S.Scale;
    FOffsetX:= S.OffsetX;
    FOffsetY:= S.OffsetY;
    FCaption:= S.Caption;
    FName:= S.Name;
  end else
    inherited;
end;

constructor TJDVectorGraphic.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner:= AOwner;
  FParts:= TJDVectorParts.Create(Self);
  FScale:= 1.0;
  FOffsetX:= 0;
  FOffsetY:= 0;
end;

destructor TJDVectorGraphic.Destroy;
begin
  FParts.Free;
  inherited;
end;

function TJDVectorGraphic.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TJDVectorGraphic.Invalidate;
begin
  //TODO: Link to a canvas and invalidate it...
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TJDVectorGraphic.LoadFromJSON(O: ISuperObject);
begin
  //Validate JSON...
  if O = nil then
    raise Exception.Create('JSON object is not valid.');
  //Validate format...
  if not SameText(O.S['Format'], 'JD Vector') then
    raise Exception.Create('Object does not contain valid vector format.');
  //TODO: Validate version...

  FCaption:= O.S['Caption'];
  FName:= O.S['Name'];
  FParts.LoadFromJSON(O.A['Parts']);
  FScale:= O.F['Scale'];
  FOffsetX:= O.F['OffsetX'];
  FOffsetY:= O.F['OffsetY'];
  Invalidate;
end;

function TJDVectorGraphic.SaveToJSON: ISuperObject;
begin
  Result:= SO;
  Result.S['Format']:= 'JD Vector';
  Result.F['Verison']:= 1.0;

  Result.S['Caption']:= Caption;
  Result.S['Name']:= Name;
  Result.A['Parts']:= Parts.SaveToJSON;
  Result.F['Scale']:= Scale;
  Result.F['OffsetX']:= OffsetX;
  Result.F['OffsetY']:= OffsetY;
end;

procedure TJDVectorGraphic.LoadFromString(S: String);
begin
  LoadFromJSON(SO(S));
end;

function TJDVectorGraphic.SaveToString: String;
begin
  Result:= SaveToJSON.AsJSON(True);
end;

procedure TJDVectorGraphic.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDVectorGraphic.SetName(const Value: TCaption);
begin
  FName := Value;
  Invalidate;
end;

procedure TJDVectorGraphic.SetOffsetX(const Value: Single);
begin
  FOffsetX := Value;
  Invalidate;
end;

procedure TJDVectorGraphic.SetOffsetY(const Value: Single);
begin
  FOffsetY := Value;
  Invalidate;
end;

procedure TJDVectorGraphic.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TJDVectorGraphic.SetParts(const Value: TJDVectorParts);
begin
  FParts.Assign(Value);
  Invalidate;
end;

procedure TJDVectorGraphic.SetScale(const Value: Single);
begin
  FScale := Value;
  Invalidate;
end;

procedure TJDVectorGraphic.Render(ACanvas: TGPGraphics; const X, Y: Single;
  const AltScale: Single);
var
  I: Integer;
  P: TJDVectorPart;
begin
  for I := 0 to FParts.Count-1 do begin
    P:= FParts[I];
    P.Render(ACanvas, X, Y, FScale * AltScale);
  end;
end;

function TJDVectorGraphic.GetBounds(const AltScale: Single): TJDRect;
var
  MinX, MinY, MaxX, MaxY: Single;
  I, J: Integer;
  P: TJDVectorPart;
begin
  if FParts.Count = 0 then
    Exit(TRect.Empty);

  MinX := MaxSingle;
  MinY := MaxSingle;
  MaxX := -MaxSingle;
  MaxY := -MaxSingle;

  for I := 0 to FParts.Count - 1 do
  begin
    P := FParts[I];
    for J := 0 to P.Points.Count - 1 do
    begin
      MinX := Min(MinX, P.Points[J].X);
      MinY := Min(MinY, P.Points[J].Y);
      MaxX := Max(MaxX, P.Points[J].X);
      MaxY := Max(MaxY, P.Points[J].Y);
    end;
  end;

  // Ensure calculations are relative to MinX/MinY
  Result := TRect.Create(
    Round(MinX * Scale * AltScale),
    Round(MinY * Scale * AltScale),
    Round((MaxX - MinX) * Scale * AltScale),
    Round((MaxY - MinY) * Scale * AltScale)
  );
end;

end.

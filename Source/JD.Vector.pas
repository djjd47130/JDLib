unit JD.Vector;

(*
  JD Vector Library

  Design vector graphics in design-time IDE and render to VCL canvas

  Usage:
  - Create instance of TJDVectorGraphic
  - Create items in "Parts" collection
    - Each part represents a single polygon of a specific color
    - Each part gets rendered in order from top to bottom
    - Create vector points in "Points" collection
  - Call "Render" to draw graphic to destination canvas

*)

interface

uses
  System.Classes, System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics;

type
  TJDVectorPoint = class;
  TJDVectorPoints = class;
  TJDVectorPart = class;
  TJDVectorParts = class;
  TJDVectorGraphic = class;



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
  public
    constructor Create(AOwner: TJDVectorPart);
    procedure Invalidate;
    function Add: TJDVectorPoint;
    function Insert(Index: Integer): TJDVectorPoint;
    property Items[Index: Integer]: TJDVectorPoint read GetItem write SetItem; default;
  end;

  TJDVectorPart = class(TCollectionItem)
  private
    FOwner: TJDVectorParts;
    FColor: TColor;
    FOffsetX: Single;
    FOffsetY: Single;
    FCaption: String;
    FScale: Double;
    procedure SetColor(const Value: TColor);
    procedure SetCaption(const Value: String);
    procedure SetOffsetX(const Value: Single);
    procedure SetOffsetY(const Value: Single);
    procedure SetScale(const Value: Double);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
    procedure Render(ACanvas: TCanvas; const X, Y: Integer; const Scale: Single);
  published
    property Caption: String read FCaption write SetCaption;
    property Color: TColor read FColor write SetColor;
    property Scale: Double read FScale write SetScale;
    property OffsetX: Single read FOffsetX write SetOffsetX;
    property OffsetY: Single read FOffsetY write SetOffsetY;
  end;

  TJDVectorParts = class(TOwnedCollection)
  private
    FOwner: TJDVectorGraphic;
    function GetItem(Index: Integer): TJDVectorPart;
    procedure SetItem(Index: Integer; const Value: TJDVectorPart);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJDVectorGraphic);
    procedure Invalidate;
    function Add: TJDVectorPart;
    function Insert(Index: Integer): TJDVectorPart;
    property Items[Index: Integer]: TJDVectorPart read GetItem write SetItem; default;
  end;

  TJDVectorGraphic = class(TPersistent)
  private
    FParts: TJDVectorParts;
    procedure SetParts(const Value: TJDVectorParts);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invalidate;
    procedure Render(ACanvas: TCanvas; const X, Y: Integer; const Scale: Single);
  published
    property Parts: TJDVectorParts read FParts write SetParts;
  end;

implementation

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
  inherited;

end;

function TJDVectorPoint.GetDisplayName: String;
begin
  Result:= inherited GetDisplayName;
end;

procedure TJDVectorPoint.Invalidate;
begin
  FOwner.Invalidate;
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

end;

function TJDVectorPoints.GetItem(Index: Integer): TJDVectorPoint;
begin
  Result:= TJDVectorPoint(inherited Items[Index]);
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
  FOwner.Invalidate;
end;

procedure TJDVectorPoints.SetItem(Index: Integer; const Value: TJDVectorPoint);
begin
  inherited Items[Index]:= Value;
end;

procedure TJDVectorPoints.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TJDVectorPart }

constructor TJDVectorPart.Create(AOwner: TCollection);
begin
  inherited;
  FOwner:= TJDVectorParts(AOwner);
  FCaption:= 'New Part';
  FColor:= clBlue;
  FScale:= 1.0;
  FOffsetX:= 0;
  FOffsetY:= 0;
end;

destructor TJDVectorPart.Destroy;
begin

  inherited;
end;

procedure TJDVectorPart.Assign(Source: TPersistent);
begin
  inherited;

end;

function TJDVectorPart.GetDisplayName: String;
begin
  if FCaption <> '' then
    Result:= FCaption
  else
    Result:= '(No Name)';
end;

procedure TJDVectorPart.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDVectorPart.Render(ACanvas: TCanvas; const X, Y: Integer; const Scale: Single);
begin
  //TODO: Render vector part on canvas, offset by X and Y...



end;

procedure TJDVectorPart.SetCaption(const Value: String);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDVectorPart.SetColor(const Value: TColor);
begin
  FColor := Value;
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

procedure TJDVectorPart.SetScale(const Value: Double);
begin
  FScale := Value;
  Invalidate;
end;

{ TJDVectorParts }

constructor TJDVectorParts.Create(AOwner: TJDVectorGraphic);
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
  FOwner.Invalidate;
end;

procedure TJDVectorParts.SetItem(Index: Integer; const Value: TJDVectorPart);
begin
  inherited Items[Index]:= Value;
end;

procedure TJDVectorParts.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TJDVectorGraphic }

constructor TJDVectorGraphic.Create;
begin
  FParts:= TJDVectorParts.Create(Self);
end;

destructor TJDVectorGraphic.Destroy;
begin
  FParts.Free;
  inherited;
end;

procedure TJDVectorGraphic.Invalidate;
begin

end;

procedure TJDVectorGraphic.SetParts(const Value: TJDVectorParts);
begin
  FParts.Assign(Value);
end;

procedure TJDVectorGraphic.Render(ACanvas: TCanvas; const X, Y: Integer; const Scale: Single);
var
  I: Integer;
  P: TJDVectorPart;
begin
  for I := 0 to FParts.Count-1 do begin
    P:= FParts[I];
    P.Render(ACanvas, X, Y, Scale);
  end;
end;

end.

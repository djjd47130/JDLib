unit RMP.BusinessObjects;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TLocation = class;
  TLocations = class;

  TLocationType = (ltMain, ltStore, ltVirtual, ltEComm, ltTransit);

  TLocation = class(TObject)
  private
    FOwner: TLocations;
    FID: Integer;
    FLocationType: TLocationType;
    FCaption: String;
    procedure SetCaption(const Value: String);
    procedure SetID(const Value: Integer);
    procedure SetLocationType(const Value: TLocationType);
  public
    constructor Create(AOwner: TLocations);
    destructor Destroy; override;
    property ID: Integer read FID write SetID;
    property Caption: String read FCaption write SetCaption;
    property LocationType: TLocationType read FLocationType write SetLocationType;
  end;

  TLocations = class(TObject)
  private
    FItems: TObjectList<TLocation>;
    function GetItem(Index: Integer): TLocation;
    procedure SetItem(Index: Integer; const Value: TLocation);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const ID: Integer): TLocation;
    procedure Clear;
    function Count: Integer;
    procedure Delete(const Index: Integer);
    property Items[Index: Integer]: TLocation read GetItem write SetItem; default;
  end;

  TLookupItem = class(TObject)

  end;

  TLookupItems = class(TObject)

  end;

implementation

{ TLocation }

constructor TLocation.Create(AOwner: TLocations);
begin
  inherited Create;

end;

destructor TLocation.Destroy;
begin

  inherited;
end;

procedure TLocation.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TLocation.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TLocation.SetLocationType(const Value: TLocationType);
begin
  FLocationType := Value;
end;

{ TLocations }

constructor TLocations.Create;
begin
  inherited;
  FItems:= TObjectList<TLocation>.Create(True);

end;

destructor TLocations.Destroy;
begin
  //TODO: Clear;
  FItems.Free;
  inherited;
end;

function TLocations.Count: Integer;
begin
  Result:= FItems.Count;
end;

function TLocations.Add(const ID: Integer): TLocation;
begin
  Result:= TLocation.Create(Self);
  Result.FID:= ID;
  FItems.Add(Result);
end;

procedure TLocations.Clear;
begin
  while Count > 0 do
    Delete(0);
end;

procedure TLocations.Delete(const Index: Integer);
begin
  FItems.Delete(Index);
end;

function TLocations.GetItem(Index: Integer): TLocation;
begin
  Result:= FItems[Index];
end;

procedure TLocations.SetItem(Index: Integer; const Value: TLocation);
begin
  FItems[Index]:= Value;
end;

end.

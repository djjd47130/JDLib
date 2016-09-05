unit RMP.Globals;

interface

uses
  RMP.BusinessObjects;

type
  TGlobals = class
  private
    class var FLocations: TLocations;
    class var FCurrentLogin: TLogin;
  public
    class constructor Create;
    class destructor Destroy;
    class property Locations: TLocations read FLocations;
  end;

implementation

{ TGlobals }

class constructor TGlobals.Create;
begin
  FLocations:= TLocations.Create;

end;

class destructor TGlobals.Destroy;
begin

  FLocations.Free;
end;

end.

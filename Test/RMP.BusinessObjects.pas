unit RMP.BusinessObjects;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls,
  Winapi.Windows;

type
  TLogin = class;
  TLogins = class;
  TLocation = class;
  TLocations = class;
  TLookupItem = class;
  TLookupItems = class;

  TLookupType = (loEntityType = 1, loLoginStat = 2, loLocationType = 3,
    loInvoiceType = 4, loInvoiceStat = 5, loInventType = 6, loInventStat = 7);

  TEntityType = (etGuru = 0, etEmployee = 1, etCustomer = 2, etVendor = 3,
    etDesigner = 4, etThirdParty = 5, etGuest = 6, etContact = 7,
    etSalesperson = 8, etLocation = 9);

  TLoginStat = (lsNew = 50, lsActive = 51, lsLocked = 52, lsRecovery = 53,
    lsDisabled = 54, lsTerminated = 55);

  TLocationType = (ltMain = 100, ltStore = 101, ltVirtual = 102,
    ltEComm = 103, ltTransit = 104);

  TInvoiceType = (itSale = 150, itApproval = 151, itConsign = 152, itBO = 153,
    itService = 154, itSaleOutState = 155, itCustomOrder = 156);

  TInvoiceStat = (isPending = 200, isOutstanding = 201, isComplete = 202);

  TInventType = (ntOneOfAKind = 250, ntProgram = 251, ntInternal = 152,
    ntCustomer = 253, ntSample = 254);

  TInventStat = (nsPending = 300, nsOrdered = 301, nsInStock = 302,
    nsSold = 303, nsOnApproval = 304, nsConsigned = 305, nsHold = 306,
    nsInTransit = 307, nsReturned = 308);




  TItemDrawStyle = (dsTile, dsList, dsSmallList, dsGrid, dsDetail, dsPreview);

  TRMPItem = class(TObject)
  private
    FID: Integer;
    FCaption: TCaption;
    FDetail: TCaption;
  protected
    procedure DrawItem(ACanvas: TCanvas; ARect: TRect; AStyle: TItemDrawStyle); virtual;
  public

  published

  end;

  TRMPItems = class(TObject)

  end;

  TLogin = class(TObject)

  end;

  TLogins = class(TObject)

  end;

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
  private
    FOwner: TLookupItems;
    FID: Integer;
    FLookupType: TLookupType;
    FCaption: String;

  end;

  TLookupItems = class(TObject)

  end;

  TCustomer = class(TObject)

  end;

  TCustomers = class(TObject)

  end;

  TInvoice = class(TObject)

  end;

implementation

{ TRMPItem }

procedure TRMPItem.DrawItem(ACanvas: TCanvas; ARect: TRect;
  AStyle: TItemDrawStyle);
begin
  case AStyle of
    dsTile: begin
      //Typically for use in the Image Grid showing search results

    end;
    dsList: begin
      //Used for simple glyph/caption buttons

    end;
    dsSmallList: begin
      //Same as dsList, but for smaller buttons

    end;
    dsGrid: begin
      //Used for detailed attributes in a grid view

    end;
    dsDetail: begin
      //Used to provide complete details in a larger view

    end;
    dsPreview: begin
      //Used for popups to preview the item

    end;
  end;
end;

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

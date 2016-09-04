unit RMP.FormHistory;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Forms;

type
  TFormHistoryItem = class;
  TFormHistory = class;

  TFormHistoryItem = class(TObject)
  private
    FOwner: TFormHistory;
    FForm: TForm;
  public
    constructor Create(AOwner: TFormHistory; AForm: TForm);
  end;

  TFormHistory = class(TComponent)
  private
    FItems: TObjectList<TFormHistoryItem>;
    FMaxItems: Integer;
    procedure SetMaxItems(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddToHistory(AForm: TForm): TFormHistoryItem;
  public
    property MaxItems: Integer read FMaxItems write SetMaxItems;
  end;

implementation

{ TFormHistoryItem }

constructor TFormHistoryItem.Create(AOwner: TFormHistory; AForm: TForm);
begin
  FOwner:= AOwner;
  FForm:= AForm;
end;

{ TFormHistory }

constructor TFormHistory.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TObjectList<TFormHistoryItem>.Create(True);
end;

destructor TFormHistory.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TFormHistory.SetMaxItems(const Value: Integer);
begin
  FMaxItems := Value;
end;

function TFormHistory.AddToHistory(AForm: TForm): TFormHistoryItem;
begin
  Result:= TFormHistoryItem.Create(Self, AForm);
  FItems.Add(Result);

end;

end.

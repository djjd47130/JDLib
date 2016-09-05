unit JD.FormHistory;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls;

type
  TFormHistoryItem = class;
  TFormHistory = class;

  TFormHistoryEvent = procedure(Sender: TFormHistory; Item: TFormHistoryItem) of object;

  TFormHistoryItem = class(TObject)
  private
    FOwner: TFormHistory;
    FForm: TForm;
    FFormClass: TFormClass;
  public
    constructor Create(AOwner: TFormHistory; AForm: TForm; AFormClass: TFormClass);
    property Form: TForm read FForm;
    property FormClass: TFormClass read FFormClass;
  end;

  TFormHistory = class(TComponent)
  private
    FItems: TObjectList<TFormHistoryItem>;
    FCurrent: TFormHistoryItem;
    FMaxItems: Integer;
    FOnShowForm: TFormHistoryEvent;
    FParentControl: TControl;
    procedure SetMaxItems(const Value: Integer);
    procedure EnsureMax;
    procedure SetParentControl(const Value: TControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowForm(AForm: TForm; AFormClass: TFormClass): TFormHistoryItem;
    procedure GoBack;
  published
    property MaxItems: Integer read FMaxItems write SetMaxItems;
    property ParentControl: TControl read FParentControl write SetParentControl;

    property OnShowForm: TFormHistoryEvent read FOnShowForm write FOnShowForm;
  end;

implementation

{ TFormHistoryItem }

constructor TFormHistoryItem.Create(AOwner: TFormHistory; AForm: TForm; AFormClass: TFormClass);
begin
  FOwner:= AOwner;
  FForm:= AForm;
  FFormClass:= AFormClass;
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
  if FMaxItems < 1 then
    FMaxItems:= 1;
  EnsureMax;
end;

procedure TFormHistory.SetParentControl(const Value: TControl);
begin
  FParentControl := Value;
  //TODO: Move all forms to new parent control, if necessary...

end;

procedure TFormHistory.EnsureMax;
begin
  while FItems.Count > FMaxItems do
    FItems.Delete(0);
end;

function TFormHistory.ShowForm(AForm: TForm; AFormClass: TFormClass): TFormHistoryItem;
begin
  //Create new history item and set as the new current form
  Result:= TFormHistoryItem.Create(Self, AForm, AFormClass);
  FCurrent:= Result;
  FItems.Add(Result);
  //If necessary, remove any oldest items to conform with MaxItems
  EnsureMax;
  //Trigger event to show new form
  if Assigned(FOnShowForm) then
    FOnShowForm(Self, FCurrent);
end;

procedure TFormHistory.GoBack;
begin
  //TODO: Revert back to the prior screen (user pressed the back button)
  if FItems.Count = 0 then begin
    //Can't do anything here, no history items exist
    FCurrent:= nil;
  end else
  if FItems.Count = 1 then begin
    //Can't go back any further, stay on first possible form
    FCurrent:= FItems[0];
  end else
  if FItems.Count > 1 then begin
    //Revert to the previous form, delete the most recent from history
    FCurrent:= FItems[FItems.Count-2];
    FItems.Delete(FItems.Count-1);
  end else begin
    //Shouldn't reach this, but just in case...
    FCurrent:= nil;
  end;
  //Trigger event to show new form
  if Assigned(FOnShowForm) then
    FOnShowForm(Self, FCurrent);
end;

end.

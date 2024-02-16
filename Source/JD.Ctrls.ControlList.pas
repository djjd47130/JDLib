unit JD.Ctrls.ControlList;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Forms, Vcl.Graphics, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TControlList = class;
  TControlListItem = class;
  TControlListObject = class;


  TControlList = class(TScrollingWinControl)
  private
    FItems: TObjectList<TControlListItem>;
    FListControl: TControl;
    procedure SetListControl(const Value: TControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Color;
    property ListControl: TControl read FListControl write SetListControl;
  end;

  TControlListItem = class(TObject)
  private
    FOwner: TControlList;
  public
    constructor Create(AOwner: TControlList);
    destructor Destroy; override;
  end;

  TControlListObject = class(TObject)
  private
    FOwner: TControlListItem;
    FName: TCaption;
    FWidth: Integer;
    FTop: Integer;
    FHeight: Integer;
    FLeft: Integer;
    FObjects: TObjectList<TControlListObject>;
    procedure SetHeight(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetName(const Value: TCaption);
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetObject(const Index: Integer): TControlListObject;
  protected
    procedure Render; virtual;
  public
    constructor Create(AOwner: TControlListItem);
    destructor Destroy; override;
    procedure Invalidate;
    property Name: TCaption read FName write SetName;
    property Left: Integer read FLeft write SetLeft;
    property Top: Integer read FTop write SetTop;
    property Height: Integer read FHeight write SetHeight;
    property Width: Integer read FWidth write SetWidth;
    function ObjectCount: Integer;
    property Objects[const Index: Integer]: TControlListObject read GetObject; default;
  end;

  TControlListText = class(TControlListObject)
  private
    FText: String;
    procedure SetText(const Value: String);
  public
    property Text: String read FText write SetText;
  end;

implementation

{ TControlList }

constructor TControlList.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TObjectList<TControlListItem>.Create(True);

end;

destructor TControlList.Destroy;
begin

  FItems.Clear;
  FItems.Free;
  inherited;
end;

procedure TControlList.SetListControl(const Value: TControl);
begin
  FListControl := Value;
end;

{ TControlListItem }

constructor TControlListItem.Create(AOwner: TControlList);
begin
  FOwner:= AOwner;

end;

destructor TControlListItem.Destroy;
begin

  inherited;
end;

{ TControlListObject }

constructor TControlListObject.Create(AOwner: TControlListItem);
begin
  FOwner:= AOwner;
  FObjects:= TObjectList<TControlListObject>.Create(True);
end;

destructor TControlListObject.Destroy;
begin
  FObjects.Clear;
  FObjects.Free;
  inherited;
end;

function TControlListObject.GetObject(const Index: Integer): TControlListObject;
begin
  Result:= FObjects[Index];
end;

procedure TControlListObject.Invalidate;
begin
  Render; //TODO
end;

function TControlListObject.ObjectCount: Integer;
begin
  Result:= FObjects.Count;
end;

procedure TControlListObject.Render;
begin
  //TODO: Inherited objects render, but need to clear...

end;

procedure TControlListObject.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TControlListObject.SetLeft(const Value: Integer);
begin
  FLeft := Value;
  Invalidate;
end;

procedure TControlListObject.SetName(const Value: TCaption);
begin
  FName := Value;
  Invalidate;
end;

procedure TControlListObject.SetTop(const Value: Integer);
begin
  FTop := Value;
  Invalidate;
end;

procedure TControlListObject.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  Invalidate;
end;

{ TControlListText }

procedure TControlListText.SetText(const Value: String);
begin
  FText := Value;
end;

end.

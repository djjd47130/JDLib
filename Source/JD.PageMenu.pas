unit JD.PageMenu;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons;

type
  TPageMenuItem = class;
  TPageMenuItems = class;
  TPageMenu = class;

  TPageMenuItemEvent = procedure(Sender: TObject; const AItem: TPageMenuItem) of object;

  TPageMenuItem = class(TCollectionItem)
  private
    FCaption: TCaption;
    procedure SetCaption(const Value: TCaption);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
  published
    property Caption: TCaption read FCaption write SetCaption;
  end;

  TPageMenuItems = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TPageMenuItem;
    procedure SetItem(Index: Integer; const Value: TPageMenuItem);
  public
    constructor Create(AOwner: TPersistent); reintroduce;
    destructor Destroy; override;
    function Add: TPageMenuItem; reintroduce;
    property Items[Index: Integer]: TPageMenuItem read GetItem write SetItem; default;
  end;

  TPageMenu = class(TCustomControl)
  private
    FItems: TPageMenuItems;
    FItemIndex: Integer;
    FSpacing: Integer;
    FButtonWidth: Integer;
    FLeftButton: TBitBtn;
    FRightButton: TBitBtn;
    FNavTimer: TTimer;
    FOnChange: TPageMenuItemEvent;
    procedure SetItems(const Value: TPageMenuItems);
    procedure SetItemIndex(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
    procedure ShowNavigation(const AShow: Boolean);
    procedure SetButtonWidth(const Value: Integer);
    procedure NextButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure NavTimerExec(Sender: TObject);
    procedure ResetNavTimer;
    procedure BackButtonMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure NextButtonMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure Paint; override;
    procedure WMMouseMove(var Msg: TMessage); message WM_MOUSEMOVE;
    procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
    procedure MouseMoved; virtual;
    procedure DoOnChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TextAreaRect: TRect;
  published
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property Items: TPageMenuItems read FItems write SetItems;
    property Spacing: Integer read FSpacing write SetSpacing;
  published
    property OnChange: TPageMenuItemEvent read FOnChange write FOnChange;
  published
    property Align;
    property Anchors;
    property Color;
    property Font;
    property Visible;
  end;

implementation

{ TPageMenuItem }

constructor TPageMenuItem.Create(AOwner: TCollection);
begin
  inherited;

end;

destructor TPageMenuItem.Destroy;
begin

  inherited;
end;

function TPageMenuItem.GetDisplayName: String;
begin
  if FCaption = '' then
    Result:= 'TPageMenuItem'
  else
    Result:= FCaption;
end;

procedure TPageMenuItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
end;

{ TPageMenuItems }

function TPageMenuItems.Add: TPageMenuItem;
begin
  Result:= TPageMenuItem(inherited Add);
end;

constructor TPageMenuItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TPageMenuItem);

end;

destructor TPageMenuItems.Destroy;
begin

  inherited;
end;

function TPageMenuItems.GetItem(Index: Integer): TPageMenuItem;
begin
  Result:= TPageMenuItem(inherited Items[Index]);
end;

procedure TPageMenuItems.SetItem(Index: Integer; const Value: TPageMenuItem);
begin
  inherited Items[Index]:= Value;
end;

{ TPageMenu }

constructor TPageMenu.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TPageMenuItems.Create(Self);
  FLeftButton:= TBitBtn.Create(nil);
  FRightButton:= TBitBtn.Create(nil);
  FNavTimer:= TTimer.Create(nil);
  FNavTimer.Interval:= 2000;
  FNavTimer.OnTimer:= NavTimerExec;

  FItemIndex:= 0;
  FSpacing:= 20;
  Font.Size:= 14;
  FButtonWidth:= 20;

  FLeftButton.Parent:= Self;
  FLeftButton.Align:= alLeft;
  FLeftButton.Width:= 20;
  FLeftButton.Caption:= '<';
  FLeftButton.TabStop:= False;
  FLeftButton.OnClick:= BackButtonClick;
  FLeftButton.OnMouseMove:= BackButtonMouseMove;

  FRightButton.Parent:= Self;
  FRightButton.Align:= alRight;
  FRightButton.Width:= 20;
  FRightButton.Caption:= '>';
  FRightButton.TabStop:= False;
  FRightButton.OnClick:= NextButtonClick;
  FLeftButton.OnMouseMove:= NextButtonMouseMove;
end;

destructor TPageMenu.Destroy;
begin
  FNavTimer.Free;
  FRightButton.Free;
  FLeftButton.Free;
  FItems.Free;
  inherited;
end;

procedure TPageMenu.DoOnChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self, FItems[FItemIndex]);
end;

procedure TPageMenu.NavTimerExec(Sender: TObject);
begin
  FNavTimer.Enabled:= False;
  ShowNavigation(False);
end;

procedure TPageMenu.ResetNavTimer;
begin
  FNavTimer.Enabled:= False;
  FNavTimer.Enabled:= True;
end;

procedure TPageMenu.BackButtonClick(Sender: TObject);
begin
  if FItemIndex = 0 then
    ItemIndex:= FItems.Count-1
  else
    ItemIndex:= ItemIndex - 1;
  Invalidate;
end;

procedure TPageMenu.NextButtonClick(Sender: TObject);
begin
  if FItemIndex = FItems.Count-1 then
    ItemIndex:= 0
  else
    ItemIndex:= ItemIndex + 1;
  Invalidate;
end;

procedure TPageMenu.BackButtonMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseMoved;
end;

procedure TPageMenu.NextButtonMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseMoved;
end;

procedure TPageMenu.MouseMoved;
begin
  ShowNavigation(True);
  ResetNavTimer;
end;

procedure TPageMenu.WMMouseMove(var Msg: TMessage);
begin
  MouseMoved;
end;

procedure TPageMenu.WMMouseLeave(var Msg: TMessage);
begin
  //ShowNavigation(False);
end;

procedure TPageMenu.Paint;
var
  X, P: Integer;
  I: TPageMenuItem;
  R: TRect;
  L: Integer;
  W: Integer;
begin
  inherited;
  Canvas.Brush.Style:= bsSolid;
  Canvas.Pen.Style:= psClear;
  Canvas.Brush.Color:= Color;
  Canvas.FillRect(Canvas.ClipRect);

  Canvas.Font.Assign(Self.Font);
  Canvas.Brush.Style:= bsClear;

  L:= FButtonWidth + 2;
  R.Left:= L;
  for X := 0 to FItems.Count-1 do begin
    P := (X + FItemIndex) mod FItems.Count;
    I:= FItems[P];
    W:= Canvas.TextWidth(I.Caption);
    R.Width:= W;
    Canvas.TextOut(R.Left, 0, I.Caption);
    //DrawText(Canvas.Handle, PChar(I.Caption), Length(I.Caption), R, DT_LEFT);
    R.Left:= R.Left + W + FSpacing;
  end;
end;

procedure TPageMenu.SetButtonWidth(const Value: Integer);
begin
  FButtonWidth := Value;
  FLeftButton.Width:= Value;
  FRightButton.Width:= Value;
  Invalidate;
end;

procedure TPageMenu.SetItemIndex(const Value: Integer);
begin
  FItemIndex := Value;
  Invalidate;
  DoOnChange;
end;

procedure TPageMenu.SetItems(const Value: TPageMenuItems);
begin
  FItems.Assign(Value);
  Invalidate;
end;

procedure TPageMenu.SetSpacing(const Value: Integer);
begin
  FSpacing := Value;
  Invalidate;
end;

procedure TPageMenu.ShowNavigation(const AShow: Boolean);
begin
  FLeftButton.Visible:= AShow;
  FRightButton.Visible:= AShow;
end;

function TPageMenu.TextAreaRect: TRect;
begin
  Result:= ClientRect;
  Result.Left:= Result.Left + FButtonWidth;
  Result.Width:= ClientWidth - (FButtonWidth * 2);
end;

end.

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
    FRect: TRect;
    procedure SetCaption(const Value: TCaption);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    function ItemRect: TRect;
    function Owner: TPageMenuItems;
    procedure Invalidate;
  published
    property Caption: TCaption read FCaption write SetCaption;
  end;

  TPageMenuItems = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TPageMenuItem;
    procedure SetItem(Index: Integer; const Value: TPageMenuItem);
    function PageMenu: TPageMenu;
  public
    constructor Create(AOwner: TPersistent); reintroduce;
    destructor Destroy; override;
    procedure Invalidate;
    function Add: TPageMenuItem; reintroduce;
    procedure Delete(const Index: Integer); reintroduce;
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
    FSelectedFont: TFont;
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
    procedure SetSelectedFont(const Value: TFont);
    procedure SelectedFontChanged(Sender: TObject);
    procedure ItemsChanged(Sender: TObject);
  protected
    procedure Paint; override;
    procedure WMMouseMove(var Msg: TMessage); message WM_MOUSEMOVE;
    procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
    procedure WMLeftMouseDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure MouseMoved; virtual;
    procedure DoOnChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TextAreaRect: TRect;
    procedure RecalcItemRects;
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
    property SelectedFont: TFont read FSelectedFont write SetSelectedFont;
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

procedure TPageMenuItem.Invalidate;
begin
  Owner.Invalidate;
end;

function TPageMenuItem.ItemRect: TRect;
begin
  Result:= FRect;
end;

function TPageMenuItem.Owner: TPageMenuItems;
begin
  Result:= TPageMenuItems(Collection);
end;

procedure TPageMenuItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  Invalidate;
end;

{ TPageMenuItems }

constructor TPageMenuItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TPageMenuItem);

end;

procedure TPageMenuItems.Delete(const Index: Integer);
begin
  inherited Delete(Index);
  Invalidate;
end;

destructor TPageMenuItems.Destroy;
begin

  inherited;
end;

function TPageMenuItems.Add: TPageMenuItem;
begin
  Result:= TPageMenuItem(inherited Add);
  Invalidate;
end;

function TPageMenuItems.GetItem(Index: Integer): TPageMenuItem;
begin
  Result:= TPageMenuItem(inherited Items[Index]);
end;

function TPageMenuItems.PageMenu: TPageMenu;
begin
  Result:= TPageMenu(Owner);
end;

procedure TPageMenuItems.Invalidate;
begin
  PageMenu.RecalcItemRects;
  PageMenu.Invalidate;
end;

procedure TPageMenuItems.SetItem(Index: Integer; const Value: TPageMenuItem);
begin
  inherited Items[Index]:= Value;
  Invalidate;
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

  FSelectedFont:= TFont.Create;
  FSelectedFont.OnChange:= SelectedFontChanged;
  FSelectedFont.Assign(Font);
  FSelectedFont.Color:= clSilver;

  RecalcItemRects;
end;

destructor TPageMenu.Destroy;
begin
  FNavTimer.Free;
  FRightButton.Free;
  FLeftButton.Free;
  FItems.Free;
  inherited;
end;

procedure TPageMenu.SelectedFontChanged(Sender: TObject);
begin
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.ItemsChanged(Sender: TObject);
begin
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.DoOnChange;
begin
  Invalidate;
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
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.NextButtonClick(Sender: TObject);
begin
  if FItemIndex = FItems.Count-1 then
    ItemIndex:= 0
  else
    ItemIndex:= ItemIndex + 1;
  RecalcItemRects;
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

procedure TPageMenu.WMLeftMouseDown(var Msg: TWMLButtonDown);
var
  P: TPoint;
  X: Integer;
  I: TPageMenuItem;
begin
  P:= Point(Msg.XPos, Msg.YPos);
  //P:= Self.ScreenToClient(P); //???
  for X := 0 to FItems.Count-1 do begin
    I:= FItems[X];
    if PtInRect(I.ItemRect, P) then begin
      Self.ItemIndex:= I.Index;
      Break;
    end;
  end;
end;

procedure TPageMenu.WMMouseLeave(var Msg: TMessage);
begin
  //ShowNavigation(False);
end;

procedure TPageMenu.SetButtonWidth(const Value: Integer);
begin
  FButtonWidth := Value;
  FLeftButton.Width:= Value;
  FRightButton.Width:= Value;
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.SetItemIndex(const Value: Integer);
begin
  FItemIndex := Value;
  RecalcItemRects;
  Invalidate;
  DoOnChange;
end;

procedure TPageMenu.SetItems(const Value: TPageMenuItems);
begin
  FItems.Assign(Value);
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.SetSelectedFont(const Value: TFont);
begin
  FSelectedFont.Assign(Value);
  RecalcItemRects;
  Invalidate;
end;

procedure TPageMenu.SetSpacing(const Value: Integer);
begin
  FSpacing := Value;
  RecalcItemRects;
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

procedure TPageMenu.RecalcItemRects;
var
  X, P: Integer;
  I: TPageMenuItem;
  R: TRect;
  L: Integer;
  W: Integer;
begin
  L:= FButtonWidth + 2;
  R.Top:= 0;
  R.Height:= ClientHeight;
  R.Left:= L;
  for X := 0 to FItems.Count-1 do begin
    if X = 0 then
      Canvas.Font.Assign(FSelectedFont)
    else
      Canvas.Font.Assign(Font);
    P := (X + FItemIndex) mod FItems.Count;
    I:= FItems[P];
    W:= Canvas.TextWidth(I.Caption);
    R.Width:= W;
    I.FRect:= R;
    R.Left:= R.Left + W + FSpacing;
  end;
end;

procedure TPageMenu.Paint;
var
  X, P: Integer;
  I: TPageMenuItem;
  R: TRect;
begin
  inherited;
  Canvas.Brush.Style:= bsSolid;
  Canvas.Pen.Style:= psClear;
  Canvas.Brush.Color:= Color;
  Canvas.FillRect(Canvas.ClipRect);
  Canvas.Brush.Style:= bsClear;
  for X := 0 to FItems.Count-1 do begin
    P := (X + FItemIndex) mod FItems.Count;
    I:= FItems[P];
    if X = 0 then
      Canvas.Font.Assign(FSelectedFont)
    else
      Canvas.Font.Assign(Font);
    R:= I.ItemRect;
    Canvas.TextOut(R.Left, 0, I.Caption);
  end;
end;

end.

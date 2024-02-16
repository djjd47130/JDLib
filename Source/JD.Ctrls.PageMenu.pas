unit JD.Ctrls.PageMenu;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Types,
  Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  JD.FontGlyphs, JD.Graphics;

type
  TJDPageMenuItem = class;
  TJDPageMenuItems = class;
  TJDPageMenu = class;

  TJDPageMenuItemEvent = procedure(Sender: TObject; const AItem: TJDPageMenuItem) of object;

  TJDPageMenuItem = class(TCollectionItem)
  private
    FCaption: TCaption;
    FRect: TRect;
    FGlyph: TJDFontGlyph;
    FShowGlyph: Boolean;
    procedure SetCaption(const Value: TCaption);
    procedure SetGlyph(const Value: TJDFontGlyph);
    procedure GlyphChanged(Sender: TObject);
    procedure SetShowGlyph(const Value: Boolean);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    function ItemRect: TRect;
    function Owner: TJDPageMenuItems;
    procedure Invalidate;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property Glyph: TJDFontGlyph read FGlyph write SetGlyph;
    property ShowGlyph: Boolean read FShowGlyph write SetShowGlyph;
  end;

  TJDPageMenuItems = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TJDPageMenuItem;
    procedure SetItem(Index: Integer; const Value: TJDPageMenuItem);
    function PageMenu: TJDPageMenu;
  public
    constructor Create(AOwner: TPersistent); reintroduce;
    destructor Destroy; override;
    procedure Invalidate;
    function Add: TJDPageMenuItem; reintroduce;
    procedure Delete(const Index: Integer); reintroduce;
    property Items[Index: Integer]: TJDPageMenuItem read GetItem write SetItem; default;
  end;

  TJDPageMenu = class(TCustomControl)
  private
    FItems: TJDPageMenuItems;
    FItemIndex: Integer;
    FSpacing: Integer;
    FButtonWidth: Integer;
    FLeftButton: TBitBtn;
    FRightButton: TBitBtn;
    FNavTimer: TTimer;
    FOnChange: TJDPageMenuItemEvent;
    FSelectedFont: TFont;
    FActiveFirst: Boolean;
    FAlignment: TVerticalAlignment;
    FShowButtons: Boolean;
    procedure SetItems(const Value: TJDPageMenuItems);
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
    procedure SetActiveFirst(const Value: Boolean);
    procedure SetAlignment(const Value: TVerticalAlignment);
    procedure SetShowButtons(const Value: Boolean);
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
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    function TextAreaRect: TRect;
    procedure RecalcItemRects;
    procedure ItemsChanged(Sender: TObject);
  published
    ///  <summary>
    ///  Whether the active item is forced to be the first, wrapping the rest.
    ///  </summary>
    property ActiveFirst: Boolean read FActiveFirst write SetActiveFirst;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property Items: TJDPageMenuItems read FItems write SetItems;
    ///  <summary>
    ///  The font for the currently selected item.
    ///  </summary>
    property SelectedFont: TFont read FSelectedFont write SetSelectedFont;
    property ShowButtons: Boolean read FShowButtons write SetShowButtons;
    property Spacing: Integer read FSpacing write SetSpacing;
    property Alignment: TVerticalAlignment read FAlignment write SetAlignment;
  published
    property OnChange: TJDPageMenuItemEvent read FOnChange write FOnChange;
  published
    property Align;
    property Anchors;
    property DoubleBuffered;
    property Color;
    property Font;
    property ParentDoubleBuffered;
    property Visible;
  end;

implementation

{ TJDPageMenuItem }

constructor TJDPageMenuItem.Create(AOwner: TCollection);
begin
  inherited;
  FGlyph:= TJDFontGlyph.Create;
  FGlyph.OnChange:= GlyphChanged;
end;

destructor TJDPageMenuItem.Destroy;
begin

  FreeAndNil(FGlyph);
  inherited;
end;

function TJDPageMenuItem.GetDisplayName: String;
begin
  if FCaption = '' then
    Result:= 'TPageMenuItem'
  else
    Result:= FCaption;
end;

procedure TJDPageMenuItem.Invalidate;
begin
  Owner.Invalidate;
end;

procedure TJDPageMenuItem.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

function TJDPageMenuItem.ItemRect: TRect;
begin
  Result:= FRect;
end;

function TJDPageMenuItem.Owner: TJDPageMenuItems;
begin
  Result:= TJDPageMenuItems(Collection);
end;

procedure TJDPageMenuItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDPageMenuItem.SetGlyph(const Value: TJDFontGlyph);
begin
  FGlyph.Assign(Value);
  Invalidate;
end;

procedure TJDPageMenuItem.SetShowGlyph(const Value: Boolean);
begin
  FShowGlyph := Value;
  Invalidate;
end;

{ TJDPageMenuItems }

constructor TJDPageMenuItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJDPageMenuItem);

end;

procedure TJDPageMenuItems.Delete(const Index: Integer);
begin
  inherited Delete(Index);
  Invalidate;
end;

destructor TJDPageMenuItems.Destroy;
begin

  inherited;
end;

function TJDPageMenuItems.Add: TJDPageMenuItem;
begin
  Result:= TJDPageMenuItem(inherited Add);
  Invalidate;
end;

function TJDPageMenuItems.GetItem(Index: Integer): TJDPageMenuItem;
begin
  Result:= TJDPageMenuItem(inherited Items[Index]);
end;

function TJDPageMenuItems.PageMenu: TJDPageMenu;
begin
  Result:= TJDPageMenu(Owner);
end;

procedure TJDPageMenuItems.Invalidate;
begin
  PageMenu.RecalcItemRects;
  PageMenu.Invalidate;
end;

procedure TJDPageMenuItems.SetItem(Index: Integer; const Value: TJDPageMenuItem);
begin
  inherited Items[Index]:= Value;
  Invalidate;
end;

{ TJDPageMenu }

constructor TJDPageMenu.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TJDPageMenuItems.Create(Self);
  FSelectedFont:= TFont.Create; //TODO: This is crashing...

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
  FLeftButton.Visible:= False;

  FRightButton.Parent:= Self;
  FRightButton.Align:= alRight;
  FRightButton.Width:= 20;
  FRightButton.Caption:= '>';
  FRightButton.TabStop:= False;
  FRightButton.OnClick:= NextButtonClick;
  FLeftButton.OnMouseMove:= NextButtonMouseMove;
  FRightButton.Visible:= False;

  FSelectedFont.Assign(Font);
  FSelectedFont.Color:= clSilver;
  FSelectedFont.OnChange:= SelectedFontChanged;

end;

procedure TJDPageMenu.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;

  RecalcItemRects;
end;

destructor TJDPageMenu.Destroy;
begin
  FreeAndNil(FSelectedFont);
  FNavTimer.Free;
  FRightButton.Free;
  FLeftButton.Free;
  FItems.Free;
  inherited;
end;

procedure TJDPageMenu.SelectedFontChanged(Sender: TObject);
begin
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.ItemsChanged(Sender: TObject);
begin
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.DoOnChange;
begin
  Invalidate;
  if Assigned(FOnChange) then
    FOnChange(Self, FItems[FItemIndex]);
end;

procedure TJDPageMenu.NavTimerExec(Sender: TObject);
begin
  FNavTimer.Enabled:= False;
  ShowNavigation(False);
end;

procedure TJDPageMenu.ResetNavTimer;
begin
  FNavTimer.Enabled:= False;
  FNavTimer.Enabled:= True;
end;

procedure TJDPageMenu.BackButtonClick(Sender: TObject);
begin
  if FItemIndex = 0 then
    ItemIndex:= FItems.Count-1
  else
    ItemIndex:= ItemIndex - 1;
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.NextButtonClick(Sender: TObject);
begin
  if FItemIndex = FItems.Count-1 then
    ItemIndex:= 0
  else
    ItemIndex:= ItemIndex + 1;
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.BackButtonMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseMoved;
end;

procedure TJDPageMenu.NextButtonMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseMoved;
end;

procedure TJDPageMenu.MouseMoved;
begin
  ShowNavigation(True);
  ResetNavTimer;
end;

procedure TJDPageMenu.WMMouseMove(var Msg: TMessage);
begin
  MouseMoved;
end;

procedure TJDPageMenu.WMLeftMouseDown(var Msg: TWMLButtonDown);
var
  P: TPoint;
  X: Integer;
  I: TJDPageMenuItem;
begin
  P:= Point(Msg.XPos, Msg.YPos);
  for X := 0 to FItems.Count-1 do begin
    I:= FItems[X];
    if PtInRect(I.ItemRect, P) then begin
      Self.ItemIndex:= I.Index;
      Break;
    end;
  end;
end;

procedure TJDPageMenu.WMMouseLeave(var Msg: TMessage);
begin
  //ShowNavigation(False);
end;

procedure TJDPageMenu.SetActiveFirst(const Value: Boolean);
begin
  FActiveFirst := Value;
  Invalidate;
end;

procedure TJDPageMenu.SetAlignment(const Value: TVerticalAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TJDPageMenu.SetButtonWidth(const Value: Integer);
begin
  FButtonWidth := Value;
  FLeftButton.Width:= Value;
  FRightButton.Width:= Value;
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.SetItemIndex(const Value: Integer);
begin
  FItemIndex := Value;
  RecalcItemRects;
  Invalidate;
  DoOnChange;
end;

procedure TJDPageMenu.SetItems(const Value: TJDPageMenuItems);
begin
  FItems.Assign(Value);
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.SetSelectedFont(const Value: TFont);
begin
  FSelectedFont.Assign(Value);
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.SetShowButtons(const Value: Boolean);
begin
  FShowButtons := Value;
  Invalidate;
end;

procedure TJDPageMenu.SetSpacing(const Value: Integer);
begin
  FSpacing := Value;
  RecalcItemRects;
  Invalidate;
end;

procedure TJDPageMenu.ShowNavigation(const AShow: Boolean);
begin
  FLeftButton.Visible:= AShow and FShowButtons;
  FRightButton.Visible:= AShow and FShowButtons;
end;

function TJDPageMenu.TextAreaRect: TRect;
begin
  Result:= ClientRect;
  Result.Left:= Result.Left + FButtonWidth;
  Result.Width:= ClientWidth - (FButtonWidth * 2);
end;

procedure TJDPageMenu.RecalcItemRects;
var
  X, P: Integer;
  I: TJDPageMenuItem;
  R: TRect;
  L: Integer;
  W: Integer;
begin
  //TODO: Account for ActiveFirst property...
  //TODO: Account for Glyphs...
  L:= FButtonWidth + 2;
  R.Top:= 0;
  R.Height:= ClientHeight;
  R.Left:= L;
  for X := 0 to FItems.Count-1 do begin
    if ActiveFirst then begin
      P := (X + FItemIndex) mod FItems.Count;
      I:= FItems[P];
    end else begin
      I:= FItems[X];
    end;
    if I.Index = Self.ItemIndex then
    //if X = 0 then
      Canvas.Font.Assign(FSelectedFont)
    else
      Canvas.Font.Assign(Font);
    W:= Canvas.TextWidth(I.Caption);
    if I.ShowGlyph then
      W:= W + 30; //TODO: Calculate glyph width...
    R.Width:= W;
    I.FRect:= R;
    R.Left:= R.Left + W + FSpacing;
  end;
end;

procedure TJDPageMenu.Paint;
var
  X, P: Integer;
  I: TJDPageMenuItem;
  R: TRect;
  Flags: Cardinal;
  procedure SetFlags;
  begin
    Flags:= DT_SINGLELINE;
    if I.ShowGlyph then
      Flags:= Flags or DT_RIGHT
    else
      Flags:= Flags or DT_CENTER;
    case Self.Alignment of
      taAlignTop:       Flags:= Flags or DT_TOP;
      taAlignBottom:    Flags:= Flags or DT_BOTTOM;
      taVerticalCenter: Flags:= Flags or DT_VCENTER;
    end;
  end;
begin
  inherited;
  Canvas.Brush.Style:= bsSolid;
  Canvas.Pen.Style:= psClear;
  Canvas.Brush.Color:= Color;
  Canvas.FillRect(Canvas.ClipRect);
  Canvas.Brush.Style:= bsClear;
  for X := 0 to FItems.Count-1 do begin
    if ActiveFirst then begin
      P := (X + FItemIndex) mod FItems.Count;
      I:= FItems[P];
    end else begin
      I:= FItems[X];
    end;

    //Text...
    if I.Index = Self.ItemIndex then
    //if X = 0 then
      Canvas.Font.Assign(FSelectedFont)
    else
      Canvas.Font.Assign(Font);
    R:= I.ItemRect;
    SetFlags;
    DrawText(Canvas.Handle, PChar(I.Caption), Length(I.Caption), R, Flags);

    //Glyph...
    if I.ShowGlyph then begin
      Canvas.Font.Assign(I.Glyph.Font);
      if I.Glyph.UseStandardColor then
        Canvas.Font.Color:= ColorManager.Color[I.Glyph.StandardColor];
      DrawText(Canvas.Handle, PChar(I.Glyph.Glyph), Length(I.Glyph.Glyph),
        R, DT_SINGLELINE or DT_LEFT or DT_VCENTER);
    end;
  end;
end;

end.

unit JD.Ctrls.ChipList;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics,
  JD.Common, JD.Ctrls, JD.Graphics,
  Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.GDIPUTIL;



type
  TChipHitArea = (haNone, haChip, haCloseButton, haToggleButton);

  TChipHitTestResult = record
    X: Integer;
    Y: Integer;
    Index: Integer;
    HitArea: TChipHitArea;
  end;


type
  TJDChipList = class;
  TJDChipListUI = class;

  TJDChipListAction = (caAdded, caModified, caDeleted);

  TJDChipListToggle = (ctButton, ctClick, ctDblClick, ctRightClick, ctMiddleClick,
    ctShiftClick, ctCtrlClick);

  TJDChipListActionEvent = procedure(Sender: TObject; const Action: TJDChipListAction) of object;

  TJDChipListUI = class(TJDUIItem)
  private
    FChipList: TJDChipList;
    FChipColor: TColor;
    FDeleteButtonColor: TColor;
    FChipExcludeColor: TColor;
    FChipNormal: TJDUIObject;
    FShowDeleteBtn: Boolean;
    procedure SetChipColor(const Value: TColor);
    procedure SetDeleteButtonColor(const Value: TColor);
    procedure SetChipExcludeColor(const Value: TColor);
    procedure SetChipNormal(const Value: TJDUIObject);
    procedure SetShowDeleteBtn(const Value: Boolean);
  public
    constructor Create(AChipList: TJDChipList); reintroduce;
    destructor Destroy; override;
    procedure Invalidate; override;
  published
    property ChipColor: TColor read FChipColor write SetChipColor;
    property ChipExcludeColor: TColor read FChipExcludeColor write SetChipExcludeColor;
    property DeleteButtonColor: TColor read FDeleteButtonColor write SetDeleteButtonColor;
    property ShowDeleteBtn: Boolean read FShowDeleteBtn write SetShowDeleteBtn;

    property ChipNormal: TJDUIObject read FChipNormal write SetChipNormal;
  end;

  TJDChipListItem = class(TCollectionItem)
  private
    FCaption: TCaption;
    FExclude: Boolean;
    procedure SetCaption(const Value: TCaption);
    procedure SetExclude(const Value: Boolean);
  protected
    function GetDisplayName: String; override;
  public
    procedure Invalidate;
    function ChipRect(Owner: TJDChipList): TRect;
    function CloseRect(Owner: TJDChipList): TRect;
    function ToggleRect(Owner: TJDChipList): TRect;
    function TextRect(Owner: TJDChipList): TRect;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property Exclude: Boolean read FExclude write SetExclude;
  end;

  TJDChipListItems = class(TOwnedCollection)
  private
    FOwner: TJDChipList;
    function GetItem(const Index: Integer): TJDChipListItem;
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJDChipList); reintroduce;
    destructor Destroy; override;
    function Add: TJDChipListItem; reintroduce;
    property Items[const Index: Integer]: TJDChipListItem read GetItem; default;
  end;

  TJDChipList = class(TJDControl)
  private
    FScrollOffset: Integer;
    FItems: TJDChipListItems;
    FUI: TJDChipListUI;
    FOnAction: TJDChipListActionEvent;
    FAllowExclude: Boolean;
    FExcludeToggle: TJDChipListToggle;
    FAutoSize: Boolean;
    FChipPadding: Integer;
    FChipHeight: Integer;
    FHit: TChipHitTestResult;
    procedure SetUI(const Value: TJDChipListUI);
    procedure SetAllowExclude(const Value: Boolean);
    procedure SetExcludeToggle(const Value: TJDChipListToggle);
    procedure SetItems(const Value: TJDChipListItems);
    procedure SetAutoSize(const Value: Boolean); reintroduce;
    procedure AdjustHeight;
    procedure HandleScroll(Delta: Integer);
    //procedure SetScrollOffset(const Value: Integer);
    function GetTotalScrollableHeight: Integer;
    procedure SetChipHeight(const Value: Integer);
    procedure SetChipPadding(const Value: Integer);
    function ShowExcludeBtn: Boolean;
  protected
    procedure Paint; override;
    procedure DoAction(const Action: TJDChipListAction); virtual;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    function PerformHitTest(X, Y: Integer): TChipHitTestResult; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property AlignWithMargins;
    property AllowExclude: Boolean read FAllowExclude write SetAllowExclude;
    property Anchors;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property ChipHeight: Integer read FChipHeight write SetChipHeight;
    property ChipPadding: Integer read FChipPadding write SetChipPadding;
    property Color;
    property DoubleBuffered;
    property Enabled;
    property ExcludeToggle: TJDChipListToggle read FExcludeToggle write SetExcludeToggle;
    property Font;
    property Items: TJDChipListItems read FItems write SetItems;
    property ParentBackground;
    property ParentColor;
    property ParentDoubleBuffered;
    property UI: TJDChipListUI read FUI write SetUI;

    property OnAction: TJDChipListActionEvent read FOnAction write FOnAction;
    property OnResize;

  end;

implementation

uses
  System.Math;

{ TJDChipListUI }

constructor TJDChipListUI.Create(AChipList: TJDChipList);
begin
  inherited Create(AChipList);

  FChipList:= AChipList;

  FChipColor:= clGray;
  FDeleteButtonColor:= clMaroon;
  FChipExcludeColor:= clRed;

  FChipNormal:= TJDUIObject.Create(FChipList);


end;

destructor TJDChipListUI.Destroy;
begin

  FreeAndNil(FChipNormal);

  inherited;
end;

procedure TJDChipListUI.Invalidate;
begin
  inherited;
  if Assigned(FChipList) then begin
    FChipList.Invalidate;
    FChipList.AdjustHeight;
  end;
end;

procedure TJDChipListUI.SetChipColor(const Value: TColor);
begin
  FChipColor := Value;
  Invalidate;
end;

procedure TJDChipListUI.SetChipExcludeColor(const Value: TColor);
begin
  FChipExcludeColor := Value;
  Invalidate;
end;

procedure TJDChipListUI.SetChipNormal(const Value: TJDUIObject);
begin
  FChipNormal.Assign(Value);
  Invalidate;
end;

procedure TJDChipListUI.SetDeleteButtonColor(const Value: TColor);
begin
  FDeleteButtonColor := Value;
  Invalidate;
end;

procedure TJDChipListUI.SetShowDeleteBtn(const Value: Boolean);
const
  TEST = clNone;
begin
  FShowDeleteBtn := Value;
  Invalidate;
end;

{ TJDChipListItem }

//TODO: Revise rect methods to reflect optional buttons and wrapping

function TJDChipListItem.ChipRect(Owner: TJDChipList): TRect;
var
  ChipWidth, X, Y, TextSize: Integer;
  I: Integer;
begin
  if Owner = nil then Exit(Rect(0, 0, 0, 0));

  //Default position
  X := Owner.ChipPadding;
  Y := Owner.ChipPadding - Owner.FScrollOffset;

  //TODO: Would a better approach be to base each next position off prior item?
  //  Would be recursive up to first item, and minimize redundant loops.
  if Index > 0 then begin
    //var Prior:= Owner.Items[Index-1];
    //TextSize := Owner.Canvas.TextWidth(TJDChipListItem(Owner.Items[I]).Caption);


  end;

  //ORIGINAL: Loop through items and monitor position...
  for I := 0 to Index - 1 do
  begin
    TextSize := Owner.Canvas.TextWidth(TJDChipListItem(Owner.Items[I]).Caption);
    X := X + TextSize + (Owner.ChipHeight + (Owner.ChipPadding*2)) + Owner.ChipPadding;
    if Owner.AllowExclude and (Owner.ExcludeToggle = ctButton) then
      X:= X + Owner.ChipHeight + Owner.ChipPadding;

    if X + TextSize + (Owner.ChipHeight + (Owner.ChipPadding*2)) > Owner.ClientWidth - Owner.ChipPadding then
    begin
      X := Owner.ChipPadding;
      Inc(Y, Owner.ChipHeight + Owner.ChipPadding);
    end;
  end;

  ChipWidth := Owner.Canvas.TextWidth(Caption) + Owner.ChipHeight + (Owner.ChipPadding*2);
  if Owner.AllowExclude and (Owner.ExcludeToggle = ctButton) then
    ChipWidth:= ChipWidth + Owner.ChipHeight + Owner.ChipPadding;
  Result := Rect(X, Y, X + ChipWidth, Y + Owner.ChipHeight);
end;

function TJDChipListItem.TextRect(Owner: TJDChipList): TRect;
begin
  Result:= ChipRect(Owner);
  Result.Right:= Result.Right - Owner.ChipPadding;
  Result.Top:= Result.Top + Owner.ChipPadding;
  Result.Bottom:= Result.Bottom - Owner.ChipPadding;
  Result.Left:= Result.Left + (Owner.ChipPadding*2);
end;

function TJDChipListItem.CloseRect(Owner: TJDChipList): TRect;
begin
  Result:= ChipRect(Owner);
  Result.Right:= Result.Right - Owner.ChipPadding;
  Result.Top:= Result.Top + Owner.ChipPadding;
  Result.Bottom:= Result.Bottom - Owner.ChipPadding;
  Result.Left:= Result.Right - Result.Height;
end;

function TJDChipListItem.ToggleRect(Owner: TJDChipList): TRect;
begin
  Result:= ChipRect(Owner);
  Result.Top:= Result.Top + Owner.ChipPadding;
  Result.Bottom:= Result.Bottom - Owner.ChipPadding;
  Result.Right:= Result.Right - (Owner.ChipPadding*2) - Result.Height;
  Result.Left:= Result.Right - Result.Height;
end;

{
function TJDChipListItem.ChipRect(Owner: TJDChipList): TRect;
var
  I, TextW: Integer;
  DelW, TogW, ThisW: Integer;
  X, Y: Integer;
begin
  if Owner = nil then
    Exit(Rect(0,0,0,0));

  // how many pixels do we need on the right for each chip?
  DelW := 0;
  if Owner.FUI.FShowDeleteBtn then
    DelW := Owner.ChipHeight + Owner.ChipPadding;

  TogW := 0;
  if Owner.AllowExclude and (Owner.ExcludeToggle = ctButton) then
    TogW := Owner.ChipHeight + Owner.ChipPadding;

  // start laying out at top-left (minus scroll)
  X := Owner.ChipPadding;
  Y := Owner.ChipPadding - Owner.FScrollOffset;

  // run through all preceding chips
  for I := 0 to Index - 1 do
  begin
    TextW := Owner.Canvas.TextWidth(
               TJDChipListItem(Owner.Items[I]).Caption
             );

    // total width = text + 2×padding + any delete/toggle buttons
    ThisW := TextW
           + (Owner.ChipPadding * 2)
           + DelW + TogW;

    // wrap if we’d overflow
    if X + ThisW > Owner.ClientWidth - Owner.ChipPadding then
    begin
      X := Owner.ChipPadding;
      Inc(Y, Owner.ChipHeight + Owner.ChipPadding);
    end;

    // advance past that chip + inter-chip gap
    Inc(X, ThisW + Owner.ChipPadding);
  end;

  // now size *this* chip the same way
  TextW := Owner.Canvas.TextWidth(Caption);
  ThisW := TextW
         + (Owner.ChipPadding * 2)
         + DelW + TogW;

  Result := Rect(X, Y, X + ThisW, Y + Owner.ChipHeight);
end;


function TJDChipListItem.CloseRect(Owner: TJDChipList): TRect;
var
  R: TRect;
  BtnW, RightEdge: Integer;
begin
  R := ChipRect(Owner);
  BtnW := Owner.ChipHeight;
  RightEdge := R.Right - Owner.ChipPadding;

  if not Owner.FUI.FShowDeleteBtn then
    Exit(Rect(0,0,0,0));

  // pack the “X” flush at the far right
  Result := Rect(
    RightEdge - BtnW,
    R.Top    + Owner.ChipPadding,
    RightEdge,
    R.Bottom - Owner.ChipPadding
  );
end;


function TJDChipListItem.ToggleRect(Owner: TJDChipList): TRect;
var
  R: TRect;
  BtnW, RightEdge: Integer;
begin
  R := ChipRect(Owner);
  BtnW := Owner.ChipHeight;

  // if we *also* have a delete-btn on the right then
  // toggle lives just left of it; otherwise it tucks
  // flush at the chip’s right edge
  if Owner.FUI.FShowDeleteBtn then
    RightEdge := CloseRect(Owner).Left - Owner.ChipPadding
  else
    RightEdge := R.Right - Owner.ChipPadding;

  if not (Owner.AllowExclude and (Owner.ExcludeToggle = ctButton)) then
    Exit(Rect(0,0,0,0));

  Result := Rect(
    RightEdge - BtnW,
    R.Top    + Owner.ChipPadding,
    RightEdge,
    R.Bottom - Owner.ChipPadding
  );
end;


function TJDChipListItem.TextRect(Owner: TJDChipList): TRect;
var
  R: TRect;
  LeftEdge, RightEdge: Integer;
begin
  R := ChipRect(Owner);

  // text starts just past the left padding
  LeftEdge := R.Left + Owner.ChipPadding;

  // text ends just before whichever button is nearest
  if (Owner.AllowExclude and (Owner.ExcludeToggle = ctButton)) then
    RightEdge := ToggleRect(Owner).Left - Owner.ChipPadding
  else if Owner.FUI.FShowDeleteBtn then
    RightEdge := CloseRect(Owner).Left - Owner.ChipPadding
  else
    RightEdge := R.Right - Owner.ChipPadding;

  Result := Rect(
    LeftEdge,
    R.Top    + Owner.ChipPadding,
    RightEdge,
    R.Bottom - Owner.ChipPadding
  );
end;
}


function TJDChipListItem.GetDisplayName: String;
begin
  Result:= FCaption;
end;

procedure TJDChipListItem.Invalidate;
begin
  if Assigned(Collection) and (Collection.Owner is TJDChipList) then begin
    TJDChipList(Collection.Owner).Invalidate;
    TJDChipList(Collection.Owner).AdjustHeight;
  end;
end;

procedure TJDChipListItem.SetCaption(const Value: TCaption);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Invalidate;
  end;
end;

procedure TJDChipListItem.SetExclude(const Value: Boolean);
begin
  if FExclude <> Value then
  begin
    FExclude := Value;
    Invalidate;
  end;
end;

{ TJDChipListItems }

function TJDChipListItems.Add: TJDChipListItem;
begin
  Result:= TJDChipListItem(inherited Add);
end;

constructor TJDChipListItems.Create(AOwner: TJDChipList);
begin
  inherited Create(AOwner, TJDChipListItem);
  FOwner:= AOwner;
end;

destructor TJDChipListItems.Destroy;
begin

  inherited;
end;

function TJDChipListItems.GetItem(const Index: Integer): TJDChipListItem;
begin
  Result:= TJDChipListItem(inherited GetItem(Index));
end;

procedure TJDChipListItems.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;

  if FOwner <> nil then
  begin
    case Action of
      cnAdded: FOwner.DoAction(caAdded);
      cnExtracted, cnRemoved: FOwner.DoAction(caDeleted);
    end;

    FOwner.AdjustHeight;
    FOwner.Invalidate;
  end;
end;

procedure TJDChipListItems.Update(Item: TCollectionItem);
begin
  inherited;

  if FOwner <> nil then
  begin
    FOwner.DoAction(caModified);  // Detect when any item is updated, including reordering
    FOwner.AdjustHeight;
    FOwner.Invalidate;
  end;
end;

{ TJDChipList }

constructor TJDChipList.Create(AOwner: TComponent);
begin
  inherited;
  FUI:= TJDChipListUI.Create(Self);

  FItems:= TJDChipListItems.Create(Self);

  Font.Style:= [fsBold];
  FChipHeight:= 24;
  FChipPadding:= 6;

end;

destructor TJDChipList.Destroy;
begin

  FreeAndNil(FItems);
  FreeAndNil(FUI);
  inherited;
end;

procedure TJDChipList.DoAction(const Action: TJDChipListAction);
begin
  if Assigned(FOnAction) then
    FOnAction(Self, Action);
end;

procedure TJDChipList.SetAllowExclude(const Value: Boolean);
begin
  FAllowExclude := Value;
  AdjustHeight;
  Invalidate;
end;

procedure TJDChipList.SetAutoSize(const Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    AdjustHeight;
    Invalidate;
  end;
end;

procedure TJDChipList.SetChipHeight(const Value: Integer);
begin
  FChipHeight := Value;
  AdjustHeight;
  Invalidate;
end;

procedure TJDChipList.SetChipPadding(const Value: Integer);
begin
  FChipPadding := Value;
  AdjustHeight;
  Invalidate;
end;

procedure TJDChipList.SetExcludeToggle(const Value: TJDChipListToggle);
begin
  FExcludeToggle := Value;
  AdjustHeight;
  Invalidate;
end;

procedure TJDChipList.AdjustHeight;
//var
  //NeededHeight, RowCount: Integer;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  if not AutoSize then Exit;
  if Items.Count = 0 then Exit;

  var Last:= Items.Items[Items.Count-1];
  var H:= Last.ChipRect(Self).Bottom + ChipPadding;
  if Height <> H then
    Height:= H;

  {
  RowCount := (Items.Count * (ChipHeight + ChipPadding)) div ClientWidth;

  NeededHeight := (RowCount * (ChipHeight + ChipPadding)) + ChipPadding;
  Height := Max(NeededHeight, ChipHeight + (2 * ChipPadding));
  }
end;

function TJDChipList.GetTotalScrollableHeight: Integer;
var
  LastChip: TJDChipListItem;
begin
  if Items.Count = 0 then Exit(1);

  LastChip := Items.Items[Items.Count - 1];

  // Ensure the last chip fits correctly within scrollable bounds
  Result := LastChip.ChipRect(Self).Bottom + ChipPadding;

  // Prevent rounding issues—ensure scrolling allows full visibility
  if Result < ClientHeight then
    Result := ClientHeight;
end;

{
procedure TJDChipList.SetScrollOffset(const Value: Integer);
var
  MaxScroll: Integer;
begin
  MaxScroll := Max(0, GetTotalScrollableHeight - ClientHeight);

  // Allow scrolling to the exact bottom, ensuring last row stays visible
  if Value >= MaxScroll - (ChipHeight + ChipPadding) then
    FScrollOffset := MaxScroll
  else
    FScrollOffset := Max(0, Min(Value, MaxScroll));

  AdjustHeight;
  Invalidate;
end;
}

procedure TJDChipList.HandleScroll(Delta: Integer);
var
  MaxScroll: Integer;
begin
  MaxScroll := Max(0, GetTotalScrollableHeight - ClientHeight);

  // If already at the bottom and scrolling down, exit immediately
  if (FScrollOffset >= MaxScroll) and (Delta > 0) then Exit;

  // If already at the top and scrolling up, exit immediately
  if (FScrollOffset <= 0) and (Delta < 0) then Exit;

  // Apply scrolling as needed
  FScrollOffset := Max(0, Min(FScrollOffset + Delta, MaxScroll));

  Invalidate;
end;

procedure TJDChipList.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FHit:= Self.PerformHitTest(X, Y);
  case FHit.HitArea of
    haNone: ;
    haChip: ;
    haCloseButton: begin
      if FHit.Index >= 0 then
        FItems.Delete(FHit.Index);
    end;
    haToggleButton: begin
      if FHit.Index >= 0 then
        FItems[FHit.Index].Exclude:= not FItems[FHit.Index].Exclude;
    end;
  end;

  Invalidate;
end;

procedure TJDChipList.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  var TempHit:= PerformHitTest(X, Y);
  if (TempHit.Index = FHit.Index) and (TempHit.HitArea = FHit.HitArea) then
    Exit;

  FHit:= TempHit;
  case FHit.HitArea of
    haNone: ;
    haChip: ;
    haCloseButton: ;
    haToggleButton: ;
  end;
  Invalidate;
end;

procedure TJDChipList.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FHit:= Self.PerformHitTest(X, Y);

  Invalidate;
end;

procedure TJDChipList.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  var D:= -Msg.WheelDelta div 120 * (ChipHeight + ChipPadding); // Scroll one item per tick
  HandleScroll(D);
end;

procedure TJDChipList.SetItems(const Value: TJDChipListItems);
begin
  FItems.Assign(Value);
  AdjustHeight;
  Invalidate;
end;

procedure TJDChipList.SetUI(const Value: TJDChipListUI);
begin
  FUI.Assign(Value);
  AdjustHeight;
  Invalidate;
end;

function TJDChipList.PerformHitTest(X, Y: Integer): TChipHitTestResult;
var
  I: Integer;
  ChipRect, CloseButtonRect, ToggleButtonRect: TRect;
begin
  Result.X:= X;
  Result.Y:= Y;
  Result.Index := -1;
  Result.HitArea := haNone;

  for I := 0 to Items.Count - 1 do begin
    ChipRect := TJDChipListItem(Items[I]).ChipRect(Self);
    CloseButtonRect := TJDChipListItem(Items[I]).CloseRect(Self);
    ToggleButtonRect := TJDChipListItem(Items[I]).ToggleRect(Self);

    if PtInRect(ChipRect, Point(X, Y)) then begin
      Result.Index := I;
      Result.HitArea := haChip;
      if PtInRect(CloseButtonRect, Point(X, Y)) then
        Result.HitArea := haCloseButton
      else if PtInRect(ToggleButtonRect, Point(X, Y)) then
        if AllowExclude and (ExcludeToggle = ctButton) then
          Result.HitArea := haToggleButton;
      Exit;
    end;

  end;
end;

function TJDChipList.ShowExcludeBtn: Boolean;
begin
  Result:= AllowExclude and (FExcludeToggle = ctButton);
end;

procedure TJDChipList.Paint;
var
  G: TGPGraphics;
  I: Integer;
  ChipRect, CloseButtonRect, ToggleButtonRect, TextRect: TRect;
  ScrollThumbHeight, ScrollThumbTop: Integer;
begin
  inherited;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    Canvas.Font.Assign(Self.Font);
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style:= psSolid;
    Canvas.Pen.Color:= clSilver; //TODO

    for I := 0 to Items.Count - 1 do begin
      ChipRect := TJDChipListItem(Items[I]).ChipRect(Self);

      if (ChipRect.Bottom < 0) or (ChipRect.Top > ClientHeight) then Continue; // Skip off-screen items

      //Chip Background
      if FAllowExclude and TJDChipListItem(Items[I]).Exclude then
        Canvas.Brush.Color := FUI.ChipExcludeColor
      else
        Canvas.Brush.Color := FUI.ChipColor;
      if (FHit.Index = I) then
        Canvas.Pen.Width:= 2
      else
        Canvas.Pen.Width:= 1;
      Canvas.RoundRect(ChipRect.Left, ChipRect.Top, ChipRect.Right, ChipRect.Bottom, 10, 10);

      //Chip Text
      var Txt: String:= TJDChipListItem(Items[I]).Caption;
      TextRect:= TJDChipListItem(Items[I]).TextRect(Self);
      DrawTextJD(Canvas.Handle, Txt, TextRect, DT_SINGLELINE or DT_NOPREFIX, taVerticalCenter, taLeftJustify);

      //Close Button
      if FUI.FShowDeleteBtn then begin
        CloseButtonRect:= Items[I].CloseRect(Self);
        Canvas.Brush.Color := FUI.DeleteButtonColor;
        if (FHit.HitArea = haCloseButton) and (FHit.Index = I) then
          Canvas.Pen.Width:= 2
        else
          Canvas.Pen.Width:= 1;
        Canvas.RoundRect(CloseButtonRect.Left, CloseButtonRect.Top, CloseButtonRect.Right, CloseButtonRect.Bottom, 10, 10);
        DrawTextJD(Canvas.Handle, 'X', CloseButtonRect, DT_SINGLELINE, taVerticalCenter, taCenter);
      end;

      //Toggle Button
      if ShowExcludeBtn then begin
        ToggleButtonRect:= Items[I].ToggleRect(Self);
        Canvas.Brush.Color := FUI.DeleteButtonColor; //TODO
        if (FHit.HitArea = haToggleButton) and (FHit.Index = I) then
          Canvas.Pen.Width:= 2
        else
          Canvas.Pen.Width:= 1;
        Canvas.RoundRect(ToggleButtonRect.Left, ToggleButtonRect.Top, ToggleButtonRect.Right, ToggleButtonRect.Bottom, 10, 10);
        DrawTextJD(Canvas.Handle, '!', ToggleButtonRect, DT_SINGLELINE, taVerticalCenter, taCenter);
      end;

    end;

    //Scrollbar
    if GetTotalScrollableHeight > ClientHeight then  begin
      ScrollThumbHeight := Max(20, (ClientHeight * ClientHeight) div GetTotalScrollableHeight);  // Minimum thumb height
      ScrollThumbTop := (FScrollOffset * (ClientHeight - ScrollThumbHeight)) div (GetTotalScrollableHeight - ClientHeight);
      Canvas.Brush.Style:= bsClear;
      Canvas.Pen.Style:= psSolid;
      Canvas.Pen.Width:= 3;
      Canvas.Pen.Color:= clSilver;
      Canvas.MoveTo(ClientWidth-4, ScrollThumbTop);
      Canvas.LineTo(ClientWidth-4, ScrollThumbTop+ScrollThumbHeight);
    end;

  finally
    G.Free;
  end;
end;


function CreateRoundedRectPath(X, Y, Width, Height, Radius: Integer): TGPGraphicsPath;
var
  Path: TGPGraphicsPath;
begin
  Path := TGPGraphicsPath.Create;

  // Top-left corner
  Path.AddArc(X, Y, Radius, Radius, 180, 90);
  Path.AddLine(X + Radius, Y, X + Width - Radius, Y);

  // Top-right corner
  Path.AddArc(X + Width - Radius, Y, Radius, Radius, 270, 90);
  Path.AddLine(X + Width, Y + Radius, X + Width, Y + Height - Radius);

  // Bottom-right corner
  Path.AddArc(X + Width - Radius, Y + Height - Radius, Radius, Radius, 0, 90);
  Path.AddLine(X + Width - Radius, Y + Height, X + Radius, Y + Height);

  // Bottom-left corner
  Path.AddArc(X, Y + Height - Radius, Radius, Radius, 90, 90);
  Path.AddLine(X, Y + Height - Radius, X, Y + Radius);

  Path.CloseFigure;

  Result := Path;
end;


{
procedure TJDChipList.Paint;
var
  I: Integer;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  ChipRect, CloseButtonRect, ToggleButtonRect: TRect;
  Pen, HighlightPen: TGPPen;
  Brush, CloseBrush, ToggleBrush: TGPSolidBrush;
  Font: TGPFont;
  Format: TGPStringFormat;
  TextOrigin, CloseTextOrigin, ToggleTextOrigin: TGPPointF;
  Radius: Integer;
begin
  inherited;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    Radius := 10;

    // **Initialize Brushes and Pens Properly**
    Pen := TGPPen.Create(MakeColor(192, 192, 192), 1); // Default border
    HighlightPen := TGPPen.Create(MakeColor(255, 0, 0), 2); // Highlighted border

    Brush := TGPSolidBrush.Create(MakeColor(GetRValue(FUI.ChipColor), GetGValue(FUI.ChipColor), GetBValue(FUI.ChipColor)));
    CloseBrush := TGPSolidBrush.Create(MakeColor(GetRValue(FUI.DeleteButtonColor), GetGValue(FUI.DeleteButtonColor), GetBValue(FUI.DeleteButtonColor)));
    ToggleBrush := TGPSolidBrush.Create(MakeColor(128, 128, 128)); // Placeholder color for toggle button

    Font := TGPFont.Create(Canvas.Font.Name, Canvas.Font.Size, FontStyleBold);
    Format := TGPStringFormat.Create;
    Format.SetAlignment(StringAlignmentCenter);
    Format.SetLineAlignment(StringAlignmentCenter);

    for I := 0 to Items.Count - 1 do
    begin
      ChipRect := TJDChipListItem(Items[I]).ChipRect(Self);
      if (ChipRect.Bottom < 0) or (ChipRect.Top > ClientHeight) then Continue; // Skip off-screen items

      // Create rounded rect path
      Path := CreateRoundedRectPath(ChipRect.Left, ChipRect.Top, ChipRect.Width, ChipRect.Height, Radius);

      // **Set dynamic brush color for excluded items**
      if FAllowExclude and TJDChipListItem(Items[I]).Exclude then
        Brush.SetColor(MakeColor(GetRValue(FUI.ChipExcludeColor), GetGValue(FUI.ChipExcludeColor), GetBValue(FUI.ChipExcludeColor)))
      else
        Brush.SetColor(MakeColor(GetRValue(FUI.ChipColor), GetGValue(FUI.ChipColor), GetBValue(FUI.ChipColor)));

      // **Draw the Chip background**
      if (FHit.Index = I) then
        G.DrawPath(HighlightPen, Path)
      else
        G.DrawPath(Pen, Path);
      G.FillPath(Brush, Path);

      // **Render chip text**
      TextOrigin.X := ChipRect.Left + 6;
      TextOrigin.Y := ChipRect.Top + ((ChipRect.Bottom - ChipRect.Top) / 2) - 8;
      Brush.SetColor(MakeColor(GetRValue(Self.Font.Color), GetGValue(Self.Font.Color), GetBValue(Self.Font.Color)));
      G.DrawString(PWideChar(TJDChipListItem(Items[I]).Caption), -1, Font, TextOrigin, Format, Brush);

      // **Draw Close Button**
      CloseButtonRect := Items[I].CloseRect(Self);
      G.FillEllipse(CloseBrush, CloseButtonRect.Left, CloseButtonRect.Top, CloseButtonRect.Width, CloseButtonRect.Height);
      CloseTextOrigin.X := CloseButtonRect.Left + 5;
      CloseTextOrigin.Y := CloseButtonRect.Top + 2;
      G.DrawString('X', -1, Font, CloseTextOrigin, Format, CloseBrush);

      // **Draw Toggle Button (if applicable)**
      if AllowExclude and (FExcludeToggle = ctButton) then
      begin
        ToggleButtonRect := Items[I].ToggleRect(Self);
        G.FillEllipse(ToggleBrush, ToggleButtonRect.Left, ToggleButtonRect.Top, ToggleButtonRect.Width, ToggleButtonRect.Height);
        ToggleTextOrigin.X := ToggleButtonRect.Left + 5;
        ToggleTextOrigin.Y := ToggleButtonRect.Top + 2;
        G.DrawString('!', -1, Font, ToggleTextOrigin, Format, ToggleBrush);
      end;

      Path.Free;
    end;
  finally
    // **Proper cleanup of all allocated objects**
    Pen.Free;
    HighlightPen.Free;
    Brush.Free;
    CloseBrush.Free;
    ToggleBrush.Free;
    Font.Free;
    Format.Free;
    G.Free;
  end;
end;
}


end.

unit JD.Ctrls.ListBox;

interface

(*

Simple
  [Img] Caption 1         Col1  Col2  Col3  Col4
  [Img] Caption 2         Col1  Col2  Col3  Col4
  [Img] Caption 3         Col1  Col2  Col3  Col4
  [Img] Caption 4         Col1  Col2  Col3  Col4

Grid
  [     ] [     ] [     ] [     ] [     ]
  [ Img ] [ Img ] [ Img ] [ Img ] [ Img ]
  [     ] [     ] [     ] [     ] [     ]
  Caption Caption Caption Caption Caption

  [     ] [     ] [     ] [     ] [     ]
  [ Img ] [ Img ] [ Img ] [ Img ] [ Img ]
  [     ] [     ] [     ] [     ] [     ]
  Caption Caption Caption Caption Caption

Sumary
  [     ] [ Caption 1                   ]
  [ Img ] [ Summary                     ]
  [     ] [                             ]

  [     ] [ Caption 2                   ]
  [ Img ] [ Summary                     ]
  [     ] [                             ]

  [     ] [ Caption 3                   ]
  [ Img ] [ Summary                     ]
  [     ] [                             ]

Chips
  [Img] Caption 1 (x)  [Img] Caption 2 (x)  [Img] Caption 3 (x)
  [Img] Caption 4 (x)  [Img] Caption 5 (x)  [Img] Caption 6 (x)
  [Img] Caption 7 (x)

Cards
  [       ] [       ] [       ] [       ] [       ]  [
  [  Img  ] [  Img  ] [  Img  ] [  Img  ] [  Img  ]  [ I
  [       ] [       ] [       ] [       ] [       ]  [
   Caption   Caption   Caption   Caption   Caption    Cap
      0         1         2         3         4

Collapse
  [ Img ] [ Caption 1                   ]

  [     ] [ Caption 2                   ]
  [     ] [ Summary                     ]
  [ Img ] [                             ]
  [     ] [                             ]
  [     ] [                             ]

  [ Img ] [ Caption 3                   ]

Messages
  [ Summary 1 ]
                            [ Summary 2 ]
  [ Summary 3 ]
                            [ Summary 4 ]
  [ Summary 5 ]
                            [ Summary 6 ]


*)



uses
  System.Classes, System.SysUtils,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, Vcl.Forms, Vcl.StdCtrls, Vcl.ImgList,
  JD.Ctrls, JD.Graphics, JD.Common,
  System.Types, System.UITypes;



type
  TJDListStyle = (lsSimple, lsGrid, lsSummary, lsChips, lsCards, lsCollapse,
    lsMessages);

  TJDListHitArea = (haNone, haItem, haText, haButton, haCheckbox, haImage,
    haHeader);

  TJDListHitTestResult = record
    X: Integer;
    Y: Integer;
    Index: Integer;
    HitArea: TJDListHitArea;
  end;



type
  /// <summary>
  /// Base UI persistent nested within TJDList control.
  /// </summary>
  TJDListUI = class;

  /// <summary>
  /// The style associated with any given list item, whether it be
  /// a normal list item or an alternate one.
  /// </summary>
  TJDListUIItem = class;

  /// <summary>
  /// Represents a single entry in a list.
  /// </summary>
  TJDListItem = class;

  /// <summary>
  /// Represents a list of multiple entries.
  /// </summary>
  TJDListItems = class;

  /// <summary>
  /// Base JD List Box control.
  /// </summary>
  TJDCustomListBox = class;

  /// <summary>
  /// Published JD List Box control.
  /// </summary>
  TJDListBox = class;



{$REGION 'User Interface Persistent Classes'}

  TJDListUI = class(TJDUIItem)
  private
    FList: TJDCustomListBox;
    FItem: TJDListUIItem;
    FItemAlt: TJDListUIItem;
    procedure SetItem(const Value: TJDListUIItem);
    procedure SetItemAlt(const Value: TJDListUIItem);
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
  published
    property Item: TJDListUIItem read FItem write SetItem;
    property ItemAlt: TJDListUIItem read FItemAlt write SetItemAlt;
  end;

  TJDListUIItem = class(TJDUIItem)
  private
    FNormal: TJDUIObject;
    FHot: TJDUIObject;
    procedure SetNormal(const Value: TJDUIObject);
    procedure SetHot(const Value: TJDUIObject);
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
  published
    property Normal: TJDUIObject read FNormal write SetNormal;
    property Hot: TJDUIObject read FHot write SetHot;
  end;

{$ENDREGION}



{$REGION 'List Items'}

  IJDListItem = interface
    ['{8A1E81C7-2145-4F84-87C6-46F128D5E411}']
    function GetCaption: WideString; stdcall;
    procedure SetCaption(const Value: WideString); stdcall;
    function GetSummary: WideString; stdcall;
    procedure SetSummary(const Value: WideString); stdcall;
    function GetImageIndex: Integer; stdcall;
    procedure SetImageIndex(const Value: Integer); stdcall;
    function GetTag: Int64; stdcall;
    procedure SetTag(const Value: Int64); stdcall;

    property Caption: WideString read GetCaption write SetCaption;
    property Summary: WideString read GetSummary write SetSummary;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    //property ImageList: TImageList read FImageList write SetImageList;
    property Tag: Int64 read GetTag write SetTag;
  end;

  TJDListItem = class(TCollectionItem)
  private
    FCaption: TCaption;
    FSummary: TStringList;
    FImageIndex: TImageIndex;
    FImageList: TImageList;
    FData: Pointer;
    FTag: Integer;
    function GetSummary: TStrings;
    procedure SetCaption(const Value: TCaption);
    procedure SetData(const Value: Pointer);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetImageList(const Value: TImageList);
    procedure SetSummary(const Value: TStrings);
    procedure SetTag(const Value: Integer);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Invalidate; virtual;
    property Data: Pointer read FData write SetData;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property Summary: TStrings read GetSummary write SetSummary;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property ImageList: TImageList read FImageList write SetImageList;
    property Tag: Integer read FTag write SetTag;
  end;

  TJDListItems = class(TOwnedCollection)
  private
    FOwner: TJDCustomListBox;
  public
    constructor Create(AOwner: TJDCustomListBox); reintroduce;
    procedure Invalidate; virtual;
  end;

{$ENDREGION}



{$REGION 'List Columns'}

  // List Columns

  TJDListColumn = class(TCollectionItem)
  private
    {
    FAlignment: TAlignment;
    FAutoSize: Boolean;
    FCaption: TCaption;
    FFormat: String;
    FImageIndex: TImageIndex;
    FMaxWidth: Integer;
    FMinWidth: Integer;
    FTag: Integer;
    FVisible: Boolean;
    FWidth: Integer;
    FPickList: TStringList;
    }
  public
  published
  end;

  TJDListColumns = class(TOwnedCollection)

  end;

{$ENDREGION}



{$REGION 'List Groups'}

  // List Groups

  TJDListGroupState = (jlgNormal, jlgHidden, jlgCollapsed, lsgNoHeader,
    jlgCollapsible, jlgFocused, jlgSelected, jlgSubsetted, jlgSubSetLinkFocused);
  TJDListGroupStates = set of TJDListGroupState;

  TJDListGroup = class(TCollectionItem)
  private
    {
    FFooter: String;
    FFooterAlign: TAlignment;
    FGroupID: Integer;
    FHeader: String;
    FHeaderAlign: TAlignment;
    FState: TJDListGroupStates;
    FSubtitle: String;
    FTitleImage: TImageIndex;
    }
  end;

  TJDListGroups = class(TOwnedCollection)

  end;

{$ENDREGION}



{$REGION 'List Control'}

  TJDCustomListBox = class(TScrollingWinControl)
  private
    FItems: TJDListItems;
    FStyle: TJDListStyle;
    FScrollPos: Integer;
    FScrollingPos: Integer;
    FDragScrolling: Boolean;
    FItemHeight: Integer;
    procedure SetStyle(const Value: TJDListStyle);
    procedure SetItemHeight(const Value: Integer);
    procedure SetScrollPos(Value: Integer; Animate, Snap: Boolean);
  protected
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    function PerformHitTest(X, Y: Integer): TJDListHitTestResult; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DrawFocusRect; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Canvas: TCanvas; reintroduce;

    function Scrolling: Boolean;

    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property Style: TJDListStyle read FStyle write SetStyle;
  end;

  TJDListBox = class(TJDCustomListBox)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;
    property DoubleBuffered;
  end;

{$ENDREGION}



{$REGION 'List Implementation Objects'}

type
  IJDLBListObj = interface;

  //EXPERIMENTAL interface-based implementation concept...
  IJDLBListObj = interface
    procedure Paint; stdcall;
    procedure PaintBackground; stdcall;
    procedure PaintItem; stdcall;
    function GetItemRect(const Index: Integer): TJDRect; stdcall;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; stdcall;
  end;

type
  TJDLBListObj = class;

  TJDLBListObjClass = class of TJDLBListObj;

  //BASE ABSTRACT LIST BOX IMPLEMENTATION OBJECT
  TJDLBListObj = class(TInterfacedPersistent, IJDLBListObj)
  private
    FList: TJDCustomListBox;
  protected
    procedure Paint; virtual; stdcall;
    procedure PaintBackground; virtual; stdcall;
    procedure PaintItem; virtual; stdcall;
    function GetItemRect(const Index: Integer): TJDRect; virtual; stdcall;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; virtual; stdcall;
  public
    constructor Create(AList: TJDCustomListBox); virtual;
    destructor Destroy; override;
  end;



  //Simple - Similar to default TListBox, extremely simple lines of text.
  TJDLBSimple = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Grid - Similar to TListView / TStringGrid, rows and columns of data.
  TJDListGridOption = (goRowSelect, goRowHighlight);
  TJDListGridOptions = set of TJDListGridOption;

  TJDLBGrid = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Summary - Variable height full-width items with rich content.
  TJDListSummaryOption = (soShowSummary, soShowImage, soVariableSize);
  TJDListSummaryOptions = set of TJDListSummaryOption;

  TJDLBSummary = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Chips - In-line "chip" items with delete and toggle buttons.
  TJDListChipOption = (coShowClose, coShowToggle);
  TJDListChipOptions = set of TJDListChipOption;

  TJDLBChips = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Cards - Similar to TJDLBSummary, but horizontally scrolling cards.
  TJDListCardOption = (doShowClose);
  TJDListCardOptions = set of TJDListCardOption;

  TJDLBCards = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Collapse - Similar to TJDLBSummary, but with collapsible data panels.
  TJDListCollapseOption = (loShowClose, loShowCollapse, loAutoCollapse);
  TJDListCollapseOptions = set of TJDListCollapseOption;

  TJDLBCollapse = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;



  //Messages - A left-and-right conversation stream of messages.
  TJDListMessageOption = (moShowClose, moShowEdit);
  TJDListMessageOptions = set of TJDListMessageOption;

  TJDLBMessages = class(TJDLBListObj)
  private
  protected
    procedure Paint; override;
    procedure PaintBackground; override;
    procedure PaintItem; override;
    function GetItemRect(const Index: Integer): TJDRect; override;
    function HitTest(const X, Y: Integer): TJDListHitTestResult; override;
  public
    constructor Create(AList: TJDCustomListBox); override;
    destructor Destroy; override;
  end;

{$ENDREGION}



////////////////////////////////////////////////////////////////////////////////
implementation
////////////////////////////////////////////////////////////////////////////////



uses
  System.Math;

const
  ScrollTimerId = 123;
  DragTimerId = 234;
  ScrollTimerInterval = 15;
  DragTimerInterval = 15;

{ TJDListUI }

constructor TJDListUI.Create(AOwner: TPersistent);
begin
  FList:= TJDCustomListBox(AOwner);
  FItem:= TJDListUIItem.Create(Self);
  FItemAlt:= TJDListUIItem.Create(Self);

end;

destructor TJDListUI.Destroy;
begin

  FreeAndNil(FItemAlt);
  FreeAndNil(FItem);
  inherited;
end;

procedure TJDListUI.Invalidate;
begin
  inherited;
  FList.Invalidate;
end;

procedure TJDListUI.SetItemAlt(const Value: TJDListUIItem);
begin
  FItemAlt.Assign(Value);
end;

procedure TJDListUI.SetItem(const Value: TJDListUIItem);
begin
  FItem.Assign(Value);
end;

{ TJDListUIItem }

constructor TJDListUIItem.Create(AOwner: TPersistent);
begin
  inherited;
  FNormal:= TJDUIObject.Create(Self);
  FHot:= TJDUIObject.Create(Self);
end;

destructor TJDListUIItem.Destroy;
begin
  FreeAndNil(FHot);
  FreeAndNil(FNormal);
  inherited;
end;

procedure TJDListUIItem.SetHot(const Value: TJDUIObject);
begin
  FHot.Assign(Value);
end;

procedure TJDListUIItem.SetNormal(const Value: TJDUIObject);
begin
  FNormal.Assign(Value);
end;

{ TJDListItems }

constructor TJDListItems.Create(AOwner: TJDCustomListBox);
begin
  inherited Create(AOwner, TJDListItem);
  FOwner:= AOwner;

end;

procedure TJDListItems.Invalidate;
begin
  if Assigned(FOwner) then
    FOwner.Invalidate;
end;

{ TJDListItem }

constructor TJDListItem.Create(Collection: TCollection);
begin
  inherited;

end;

destructor TJDListItem.Destroy;
begin

  inherited;
end;

function TJDListItem.GetSummary: TStrings;
begin
  Result:= TStrings(FSummary);
end;

procedure TJDListItem.Invalidate;
begin
  //TODO
  TJDListItems(Self.GetOwner).Invalidate;
end;

procedure TJDListItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDListItem.SetData(const Value: Pointer);
begin
  FData := Value;
  Invalidate;
end;

procedure TJDListItem.SetImageIndex(const Value: TImageIndex);
begin
  FImageIndex := Value;
  Invalidate;
end;

procedure TJDListItem.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  Invalidate;
end;

procedure TJDListItem.SetSummary(const Value: TStrings);
begin
  FSummary.Assign(Value);
  Invalidate;
end;

procedure TJDListItem.SetTag(const Value: Integer);
begin
  FTag := Value;
  Invalidate;
end;

{ TJDCustomListBox }

function TJDCustomListBox.Canvas: TCanvas;
begin
  Result:= nil; // inherited Self.Canvas; //TODO
end;

constructor TJDCustomListBox.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TJDListItems.Create(Self);
end;

destructor TJDCustomListBox.Destroy;
begin

  inherited;
end;

procedure TJDCustomListBox.DrawFocusRect;
begin

end;

procedure TJDCustomListBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TJDCustomListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TJDCustomListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

function TJDCustomListBox.PerformHitTest(X, Y: Integer): TJDListHitTestResult;
begin
  case Self.FStyle of
    lsSimple: begin

    end;
    lsGrid: begin

    end;
    lsSummary: begin

    end;
    lsChips: begin

    end;
    lsCards: begin

    end;
    lsCollapse: begin

    end;
    lsMessages: begin

    end;
  end;
end;

function TJDCustomListBox.Scrolling: Boolean;
begin
  Result := (FScrollingPos <> FScrollPos) or FDragScrolling;
end;

procedure TJDCustomListBox.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  Invalidate;
end;

procedure TJDCustomListBox.SetStyle(const Value: TJDListStyle);
begin
  FStyle := Value;
  Invalidate;
  //TODO: Rearrange...
end;

procedure TJDCustomListBox.WMPaint(var Message: TWMPaint);
begin

  inherited;

  //GDI+

  //Background

  //Header

  //Items


end;

procedure TJDCustomListBox.SetScrollPos(Value: Integer; Animate,
  Snap: Boolean);
var
  PageHeight: Integer;
  AlreadyScrolling: Boolean;
begin
  if FScrollPos <> Value then
  begin
    PageHeight := (ClientHeight div FItemHeight) * FItemHeight;
    Value := Max(0, Min(Value, FItemHeight * FItemHeight - PageHeight));
    if Snap then
      Value := (Value div FItemHeight) * FItemHeight;
    Winapi.Windows.SetScrollPos(Handle, SB_VERT, Value, True);
    if Animate then
    begin
      AlreadyScrolling := Scrolling;
      FScrollPos := Value;
      if not AlreadyScrolling then
      begin
        DrawFocusRect;
        SetTimer(Handle, ScrollTimerId, ScrollTimerInterval, nil);
      end;
    end
    else
    begin
      ScrollWindow(Handle, 0, FScrollPos - Value, nil, nil);
      FScrollPos := Value;
      FScrollingPos := FScrollPos;
    end;
  end;
end;

procedure TJDCustomListBox.WMVScroll(var Message: TWMVScroll);

  function RealScrollPos: Integer;
  var
    Info: TScrollInfo;
  begin
    Info.cbSize := SizeOf(TScrollInfo);
    Info.fMask := SIF_TRACKPOS;
    Result := Message.Pos;
    if GetScrollInfo(Handle, SB_VERT, Info) then
      Result := Info.nTrackPos;
  end;

var
  PageHeight: Integer;
begin
  PageHeight := (ClientHeight div FItemHeight) * FItemHeight;

  case Message.ScrollCode of
    SB_LINEUP:
      SetScrollPos(FScrollPos - FItemHeight, True, True);
    SB_LINEDOWN:
      SetScrollPos(FScrollPos + FItemHeight, True, True);
    SB_PAGEUP:
      SetScrollPos(FScrollPos - PageHeight, True, True);
    SB_PAGEDOWN:
      SetScrollPos(FScrollPos + PageHeight, True, True);
    SB_THUMBPOSITION:
      SetScrollPos(RealScrollPos, True, False);
    SB_THUMBTRACK:
      SetScrollPos(RealScrollPos, False, False);
    SB_TOP:
      SetScrollPos(0, False, True);
    SB_BOTTOM:
      //SetScrollPos(FRowCount * FItemHeight, False, False)
      ; //TODO
  end;
  inherited;
end;

{ TJDListBox }

constructor TJDListBox.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TJDListBox.Destroy;
begin

  inherited;
end;

{ TJDLBListObj }

constructor TJDLBListObj.Create(AList: TJDCustomListBox);
begin
  FList:= AList;

end;

destructor TJDLBListObj.Destroy;
begin

  inherited;
end;

function TJDLBListObj.GetItemRect(const Index: Integer): TJDRect;
begin

end;

function TJDLBListObj.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin

end;

procedure TJDLBListObj.Paint;
begin
  PaintBackground;

  //TODO

end;

procedure TJDLBListObj.PaintBackground;
begin
  FList.Canvas.Brush.Style:= bsSolid;
end;

procedure TJDLBListObj.PaintItem;
begin

end;

{ TJDLBSimple }

constructor TJDLBSimple.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBSimple.Destroy;
begin

  inherited;
end;

function TJDLBSimple.GetItemRect(const Index: Integer): TJDRect;
begin
  //TODO: Return rect of very simple list item within a listbox.
  inherited;

end;

function TJDLBSimple.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBSimple.Paint;
begin
  inherited;

end;

procedure TJDLBSimple.PaintBackground;
begin
  inherited;

end;

procedure TJDLBSimple.PaintItem;
begin
  inherited;

end;

{ TJDLBGrid }

constructor TJDLBGrid.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBGrid.Destroy;
begin

  inherited;
end;

function TJDLBGrid.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBGrid.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBGrid.Paint;
begin
  inherited;

end;

procedure TJDLBGrid.PaintBackground;
begin
  inherited;

end;

procedure TJDLBGrid.PaintItem;
begin
  inherited;

end;

{ TJDLBSummary }

constructor TJDLBSummary.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBSummary.Destroy;
begin

  inherited;
end;

function TJDLBSummary.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBSummary.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBSummary.Paint;
begin
  inherited;

end;

procedure TJDLBSummary.PaintBackground;
begin
  inherited;

end;

procedure TJDLBSummary.PaintItem;
begin
  inherited;

end;

{ TJDLBChips }

constructor TJDLBChips.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBChips.Destroy;
begin

  inherited;
end;

function TJDLBChips.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBChips.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBChips.Paint;
begin
  inherited;

end;

procedure TJDLBChips.PaintBackground;
begin
  inherited;

end;

procedure TJDLBChips.PaintItem;
begin
  inherited;

end;

{ TJDLBCards }

constructor TJDLBCards.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBCards.Destroy;
begin

  inherited;
end;

function TJDLBCards.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBCards.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBCards.Paint;
begin
  inherited;

end;

procedure TJDLBCards.PaintBackground;
begin
  inherited;

end;

procedure TJDLBCards.PaintItem;
begin
  inherited;

end;

{ TJDLBCollapse }

constructor TJDLBCollapse.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBCollapse.Destroy;
begin

  inherited;
end;

function TJDLBCollapse.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBCollapse.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBCollapse.Paint;
begin
  inherited;

end;

procedure TJDLBCollapse.PaintBackground;
begin
  inherited;

end;

procedure TJDLBCollapse.PaintItem;
begin
  inherited;

end;

{ TJDLBMessages }

constructor TJDLBMessages.Create(AList: TJDCustomListBox);
begin

end;

destructor TJDLBMessages.Destroy;
begin

  inherited;
end;

function TJDLBMessages.GetItemRect(const Index: Integer): TJDRect;
begin
  inherited;

end;

function TJDLBMessages.HitTest(const X, Y: Integer): TJDListHitTestResult;
begin
  inherited;

end;

procedure TJDLBMessages.Paint;
begin
  inherited;

end;

procedure TJDLBMessages.PaintBackground;
begin
  inherited;

end;

procedure TJDLBMessages.PaintItem;
begin
  inherited;

end;

end.

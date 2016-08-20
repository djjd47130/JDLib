unit JD.Ctrls.LeftToolbar;

(*
  JD Left Menu (to change name from "Toolbar" to "Menu")
  Designed to display a dynamically drawn menu along left with many customizable options

  NOTE: Extremely raw code, in beginning stages - Can compile, but in fresh development so not actually working yet.

*)

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics;

type
  TLeftButtonStateProps = class;
  TLeftToolbar = class;
  TLeftToolbarItem = class;
  TLeftToolbarItems = class;

  TLeftToolbarBorder = (lbNone, lbRect, lbElipse, lbRoundRect,
    lbBtnDown, lbBtnUp, lbBtnHover); //NOTE: "Btn" refers to Windows/VCL styled drawing

  TLeftToolbarState = (lsNormal, lsHover, lsDown, lsClick);

  TLeftToolbarItemEvent = procedure(Sender: TObject; const Item: Integer) of object;

  TLeftButtonStateProps = class(TPersistent)
  private
    FBackColor: TColor;
    FForeColor: TColor;
    FBorderColor: TColor;
    FBorder: TLeftToolbarBorder;
    FOverlay: TPicture;
    procedure SetBackColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetForeColor(const Value: TColor);
    procedure SetOverlay(const Value: TPicture);
    procedure SetBorder(const Value: TLeftToolbarBorder);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Border: TLeftToolbarBorder read FBorder write SetBorder;
    property BackColor: TColor read FBackColor write SetBackColor;
    property ForeColor: TColor read FForeColor write SetForeColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Overlay: TPicture read FOverlay write SetOverlay;
  end;

  TLeftToolbarItem = class(TCollectionItem)
  private
    FToolbar: TLeftToolbar;
    FPicture: TPicture;
    FCaption: TCaption;
    FGroupIndex: Integer;
    procedure SetCaption(const Value: TCaption);
    procedure SetPicture(const Value: TPicture);
    procedure SetGroupIndex(const Value: Integer);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function BoundsRect: TRect;
    function State: TLeftToolbarState;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex;
    property Picture: TPicture read FPicture write SetPicture;
  end;

  TLeftToolbarItems = class(TOwnedCollection)
  private
    FToolbar: TLeftToolbar;
    function GetItem(Index: Integer): TLeftToolbarItem;
    procedure SetItem(Index: Integer; const Value: TLeftToolbarItem);
  public
    constructor Create(AOwner: TPersistent; AToolbar: TLeftToolbar); reintroduce;
    property Items[Index: Integer]: TLeftToolbarItem read GetItem write SetItem; default;
  end;

  TLeftToolbarGroup = class(TCollectionItem)
  private
    FToolbar: TLeftToolbar;
    FCaption: TCaption;
    procedure SetCaption(const Value: TCaption);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function BoundsRect: TRect;
  published
    property Caption: TCaption read FCaption write SetCaption;

  end;

  TLeftToolbarGroups = class(TOwnedCollection)
  private
    FToolbar: TLeftToolbar;
    function GetItem(Index: Integer): TLeftToolbarGroup;
    procedure SetItem(Index: Integer; const Value: TLeftToolbarGroup);
  public
    constructor Create(AOwner: TPersistent; AToolbar: TLeftToolbar); reintroduce;
    property Items[Index: Integer]: TLeftToolbarGroup read GetItem write SetItem; default;
  end;

  TLeftToolbar = class(TCustomControl)
  private
    FItems: TLeftToolbarItems;
    FGroups: TLeftToolbarGroups;
    FItemIndex: Integer;
    FItemHeight: Integer;
    FHover: Boolean;
    FStyleDown: TLeftButtonStateProps;
    FStyleNormal: TLeftButtonStateProps;
    FStyleClick: TLeftButtonStateProps;
    FStyleHover: TLeftButtonStateProps;
    procedure SetItems(const Value: TLeftToolbarItems);
    procedure SetItemIndex(const Value: Integer);
    procedure SetItemHeight(const Value: Integer);
    procedure SetStyleClick(const Value: TLeftButtonStateProps);
    procedure SetStyleDown(const Value: TLeftButtonStateProps);
    procedure SetStyleHover(const Value: TLeftButtonStateProps);
    procedure SetStyleNormal(const Value: TLeftButtonStateProps);
    procedure SetGroups(const Value: TLeftToolbarGroups);
  protected
    procedure WMPaint(var Msg: TMessage); message WM_PAINT;
    procedure CMHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Color;
    property Font;
    property Groups: TLeftToolbarGroups read FGroups write SetGroups;
    property Items: TLeftToolbarItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property ParentColor;
    property ParentFont;
    property StyleNormal: TLeftButtonStateProps read FStyleNormal write SetStyleNormal;
    property StyleHover: TLeftButtonStateProps read FStyleHover write SetStyleHover;
    property StyleClick: TLeftButtonStateProps read FStyleClick write SetStyleClick;
    property StyleDown: TLeftButtonStateProps read FStyleDown write SetStyleDown;
    property Width;
  end;

implementation

{ TLeftButtonStateProps }

constructor TLeftButtonStateProps.Create;
begin
  FOverlay:= TPicture.Create;
end;

destructor TLeftButtonStateProps.Destroy;
begin
  FOverlay.Free;
  inherited;
end;

procedure TLeftButtonStateProps.Invalidate;
begin
  //TODO
end;

procedure TLeftButtonStateProps.SetBackColor(const Value: TColor);
begin
  FBackColor := Value;
  Invalidate;
end;

procedure TLeftButtonStateProps.SetBorder(const Value: TLeftToolbarBorder);
begin
  FBorder := Value;
  Invalidate;
end;

procedure TLeftButtonStateProps.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TLeftButtonStateProps.SetForeColor(const Value: TColor);
begin
  FForeColor := Value;
  Invalidate;
end;

procedure TLeftButtonStateProps.SetOverlay(const Value: TPicture);
begin
  FOverlay := Value;
  Invalidate;
end;

{ TLeftToolbarItem }

constructor TLeftToolbarItem.Create(Collection: TCollection);
begin
  inherited;
  FPicture:= TPicture.Create;
  FToolbar:= TLeftToolbarItems(Collection).FToolbar;
end;

destructor TLeftToolbarItem.Destroy;
begin

  FPicture.Free;
  inherited;
end;

function TLeftToolbarItem.GetDisplayName: String;
begin
  if Trim(FCaption) <> '' then
    Result:= FCaption
  else
    inherited;
end;

procedure TLeftToolbarItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  FToolbar.Invalidate;
end;

procedure TLeftToolbarItem.SetGroupIndex(const Value: Integer);
begin
  FGroupIndex := Value;
  FToolbar.Invalidate;
end;

procedure TLeftToolbarItem.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
  FToolbar.Invalidate;
end;

function TLeftToolbarItem.State: TLeftToolbarState;
begin
  Result:= TLeftToolbarState.lsNormal;
  if FToolbar.FItemIndex = Self.Index then
    Result:= TLeftToolbarState.lsDown;
  //TODO: Detect if mouse is currently over or clicked on

end;

function TLeftToolbarItem.BoundsRect: TRect;
var
  T: Integer;
begin
  //TODO: Return rectangle of full possible drawing area of item
  T:= Self.Index * FToolbar.ItemHeight;
  Result:= Rect(0, T, FToolbar.ClientWidth, T + FToolbar.ItemHeight);
end;

{ TLeftToolbarItems }

constructor TLeftToolbarItems.Create(AOwner: TPersistent; AToolbar: TLeftToolbar);
begin
  inherited Create(AOwner, TLeftToolbarItem);
  FToolbar:= AToolbar;
end;

function TLeftToolbarItems.GetItem(Index: Integer): TLeftToolbarItem;
begin
  Result:= TLeftToolbarItem(inherited Items[Index]);
end;

procedure TLeftToolbarItems.SetItem(Index: Integer;
  const Value: TLeftToolbarItem);
begin
  inherited Items[Index]:= Value;
end;

{ TLeftToolbarGroup }

constructor TLeftToolbarGroup.Create(Collection: TCollection);
begin
  inherited;
  FToolbar:= TLeftToolbarGroups(Collection).FToolbar;
end;

destructor TLeftToolbarGroup.Destroy;
begin

  inherited;
end;

function TLeftToolbarGroup.GetDisplayName: String;
begin
  if Trim(FCaption) <> '' then
    Result:= FCaption
  else
    inherited;
end;

procedure TLeftToolbarGroup.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  FToolbar.Invalidate;
end;

function TLeftToolbarGroup.BoundsRect: TRect;
begin
  //TODO: Return rect representing group header display

end;

{ TLeftToolbarGroups }

constructor TLeftToolbarGroups.Create(AOwner: TPersistent;
  AToolbar: TLeftToolbar);
begin
  inherited Create(AOwner, TLeftToolbarGroup);
  FToolbar:= AToolbar;
end;

function TLeftToolbarGroups.GetItem(Index: Integer): TLeftToolbarGroup;
begin
  Result:= TLeftToolbarGroup(inherited Items[Index]);
end;

procedure TLeftToolbarGroups.SetItem(Index: Integer;
  const Value: TLeftToolbarGroup);
begin
  inherited Items[Index]:= Value;
end;

{ TLeftToolbar }

constructor TLeftToolbar.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TLeftToolbarItems.Create(Self, Self);
  FGroups:= TLeftToolbarGroups.Create(Self, Self);

  ParentColor:= False;
  Color:= clBtnFace;

  FHover:= False;

  FStyleDown:= TLeftButtonStateProps.Create;
  FStyleDown.FBackColor:= Color;
  FStyleDown.FForeColor:= Color;
  FStyleDown.FBorderColor:= clRed;
  FStyleDown.Border:= lbRect;

  FStyleNormal:= TLeftButtonStateProps.Create;
  FStyleNormal.FBackColor:= Color;
  FStyleNormal.FForeColor:= Color;
  FStyleNormal.FBorderColor:= Color;
  FStyleNormal.Border:= lbNone;

  FStyleClick:= TLeftButtonStateProps.Create;
  FStyleClick.FBackColor:= Color;
  FStyleClick.FForeColor:= Color;
  FStyleClick.FBorderColor:= clBlue;
  FStyleClick.Border:= lbRect;

  FStyleHover:= TLeftButtonStateProps.Create;
  FStyleHover.FBackColor:= Color;
  FStyleHover.FForeColor:= Color;
  FStyleHover.FBorderColor:= clSkyBlue;
  FStyleHover.Border:= lbRect;

  Align:= alLeft;
  Width:= 200;
  FItemHeight:= 42;
  FItemIndex:= -1;

end;

destructor TLeftToolbar.Destroy;
begin

  FGroups.Free;
  FItems.Free;
  inherited;
end;

procedure TLeftToolbar.SetGroups(const Value: TLeftToolbarGroups);
begin
  FGroups := Value;
  Invalidate;
end;

procedure TLeftToolbar.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  Invalidate;
end;

procedure TLeftToolbar.SetItemIndex(const Value: Integer);
begin
  FItemIndex := Value;
  Invalidate;
end;

procedure TLeftToolbar.SetItems(const Value: TLeftToolbarItems);
begin
  FItems.Assign(Value);
  Invalidate;
end;

procedure TLeftToolbar.SetStyleClick(const Value: TLeftButtonStateProps);
begin
  FStyleClick.Assign(Value);
  Invalidate;
end;

procedure TLeftToolbar.SetStyleDown(const Value: TLeftButtonStateProps);
begin
  FStyleDown.Assign(Value);
  Invalidate;
end;

procedure TLeftToolbar.SetStyleHover(const Value: TLeftButtonStateProps);
begin
  FStyleHover.Assign(Value);
  Invalidate;
end;

procedure TLeftToolbar.SetStyleNormal(const Value: TLeftButtonStateProps);
begin
  FStyleNormal.Assign(Value);
  Invalidate;
end;

procedure TLeftToolbar.CMHitTest(var Msg: TWMNCHitTest);
var
  X: Integer;
  P: TPoint;
  I: TLeftToolbarItem;
  G: TLeftToolbarGroup;
  H: Boolean;
begin
  //TODO: Detect if point is within a certain item
  P:= Msg.Pos;
  Msg.Result:= HTCLIENT;
  H:= False;

  //HTOBJECT
  for X := 0 to FItems.Count-1 do begin
    I:= FItems[X];
    if PtInRect(I.BoundsRect, P) then begin
      Msg.Result:= HTOBJECT;
      //TODO: Make hover effect
      H:= True;

    end;
  end;
  for X := 0 to FGroups.Count-1 do begin
    G:= FGroups[X];
    if PtInRect(G.BoundsRect, P) then begin
      Msg.Result:= HTOBJECT;
      //TODO: Make hover effect
      H:= True;

    end;
  end;

  if FHover <> H then begin
    FHover:= H;
    Invalidate;
  end;

  //TODO: This aproach won't work because each item needs to know
  //  its current state by itself.

end;

procedure TLeftToolbar.WMPaint(var Msg: TMessage);
var
  C: TCanvas;
  B: TBrush;
  P: TPen;
  I: TLeftToolbarItem;
  X: Integer;
  R, IR, CR: TRect; //TODO: Move IR and CR to item class

  procedure DrawBackground;
  begin
    B.Style:= bsSolid;
    P.Style:= psClear;
    B.Color:= Self.Color; //TODO: Change color to preferences

    C.FillRect(R);
  end;

  procedure DrawImage;
  begin
    IR:= Rect(R.Left, R.Top, R.Height, R.Bottom);
    //TODO: Draw image inside image rect

    //TODO: Check whether current state has overlay image assigned

  end;

  procedure DrawCaption;
  begin
    CR:= Rect(R.Height, R.Top, R.Right, R.Bottom);
    C.TextOut(CR.Left, CR.Top, I.Caption);
    //TODO: Change to DrawText and implement alignment options

  end;

  procedure DrawBorder;
  begin
    //TODO: Draw border around full item

  end;

begin
  inherited;
  C:= Canvas;
  B:= C.Brush;
  P:= C.Pen;
  C.Font.Assign(Font);

  //Draw overall background
  B.Style:= bsSolid;
  P.Style:= psClear;
  B.Color:= Color;
  C.FillRect(C.ClipRect);

  for X := 0 to FItems.Count-1 do begin
    I:= FItems[X];
    R:= I.BoundsRect;
    DrawBackground;
    DrawImage;
    DrawCaption;
    DrawBorder;
  end;

end;

end.

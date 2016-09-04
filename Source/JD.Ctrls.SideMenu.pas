unit JD.Ctrls.SideMenu;

(*
  JD Side Menu
  Designed to display a dynamically drawn menu along side with many customizable options

  NOTE: Extremely raw code, in beginning stages - Can compile, but in fresh development so not actually working yet.

*)

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics;

type
  TSideButtonStateProps = class;
  TSideMenu = class;
  TSideMenuItem = class;
  TSideMenuItems = class;

  TSideMenuBorder = (lbNone, lbRect, lbElipse, lbRoundRect,
    lbBtnDown, lbBtnUp, lbBtnHover); //NOTE: "Btn" refers to Windows/VCL styled drawing

  TSideMenuState = (lsNormal, lsHover, lsDown, lsClick);

  TSideMenuItemEvent = procedure(Sender: TObject; const Item: Integer) of object;

  TSideButtonStateProps = class(TPersistent)
  private
    FBackColor: TColor;
    FForeColor: TColor;
    FBorderColor: TColor;
    FBorder: TSideMenuBorder;
    FOverlay: TPicture;
    procedure SetBackColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetForeColor(const Value: TColor);
    procedure SetOverlay(const Value: TPicture);
    procedure SetBorder(const Value: TSideMenuBorder);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Border: TSideMenuBorder read FBorder write SetBorder;
    property BackColor: TColor read FBackColor write SetBackColor;
    property ForeColor: TColor read FForeColor write SetForeColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Overlay: TPicture read FOverlay write SetOverlay;
  end;

  TSideMenuItem = class(TCollectionItem)
  private
    FToolbar: TSideMenu;
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
    function State: TSideMenuState;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex;
    property Picture: TPicture read FPicture write SetPicture;
  end;

  TSideMenuItems = class(TOwnedCollection)
  private
    FToolbar: TSideMenu;
    function GetItem(Index: Integer): TSideMenuItem;
    procedure SetItem(Index: Integer; const Value: TSideMenuItem);
  public
    constructor Create(AOwner: TPersistent; AToolbar: TSideMenu); reintroduce;
    property Items[Index: Integer]: TSideMenuItem read GetItem write SetItem; default;
  end;

  TSideMenuGroup = class(TCollectionItem)
  private
    FToolbar: TSideMenu;
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

  TSideMenuGroups = class(TOwnedCollection)
  private
    FToolbar: TSideMenu;
    function GetItem(Index: Integer): TSideMenuGroup;
    procedure SetItem(Index: Integer; const Value: TSideMenuGroup);
  public
    constructor Create(AOwner: TPersistent; AToolbar: TSideMenu); reintroduce;
    property Items[Index: Integer]: TSideMenuGroup read GetItem write SetItem; default;
  end;

  TSideMenu = class(TCustomControl)
  private
    FItems: TSideMenuItems;
    FGroups: TSideMenuGroups;
    FItemIndex: Integer;
    FItemHeight: Integer;
    FHover: Boolean;
    FStyleDown: TSideButtonStateProps;
    FStyleNormal: TSideButtonStateProps;
    FStyleClick: TSideButtonStateProps;
    FStyleHover: TSideButtonStateProps;
    procedure SetItems(const Value: TSideMenuItems);
    procedure SetItemIndex(const Value: Integer);
    procedure SetItemHeight(const Value: Integer);
    procedure SetStyleClick(const Value: TSideButtonStateProps);
    procedure SetStyleDown(const Value: TSideButtonStateProps);
    procedure SetStyleHover(const Value: TSideButtonStateProps);
    procedure SetStyleNormal(const Value: TSideButtonStateProps);
    procedure SetGroups(const Value: TSideMenuGroups);
  protected
    procedure Paint; override;
    procedure CMHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Color;
    property Font;
    property Groups: TSideMenuGroups read FGroups write SetGroups;
    property Height;
    property Items: TSideMenuItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property ParentColor;
    property ParentFont;
    property StyleNormal: TSideButtonStateProps read FStyleNormal write SetStyleNormal;
    property StyleHover: TSideButtonStateProps read FStyleHover write SetStyleHover;
    property StyleClick: TSideButtonStateProps read FStyleClick write SetStyleClick;
    property StyleDown: TSideButtonStateProps read FStyleDown write SetStyleDown;
    property Visible;
    property Width;
  end;

implementation

{ TSideButtonStateProps }

constructor TSideButtonStateProps.Create;
begin
  FOverlay:= TPicture.Create;
end;

destructor TSideButtonStateProps.Destroy;
begin
  FOverlay.Free;
  inherited;
end;

procedure TSideButtonStateProps.Invalidate;
begin
  //TODO
end;

procedure TSideButtonStateProps.SetBackColor(const Value: TColor);
begin
  FBackColor := Value;
  Invalidate;
end;

procedure TSideButtonStateProps.SetBorder(const Value: TSideMenuBorder);
begin
  FBorder := Value;
  Invalidate;
end;

procedure TSideButtonStateProps.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TSideButtonStateProps.SetForeColor(const Value: TColor);
begin
  FForeColor := Value;
  Invalidate;
end;

procedure TSideButtonStateProps.SetOverlay(const Value: TPicture);
begin
  FOverlay := Value;
  Invalidate;
end;

{ TSideMenuItem }

constructor TSideMenuItem.Create(Collection: TCollection);
begin
  inherited;
  FPicture:= TPicture.Create;
  FToolbar:= TSideMenuItems(Collection).FToolbar;
end;

destructor TSideMenuItem.Destroy;
begin

  FPicture.Free;
  inherited;
end;

function TSideMenuItem.GetDisplayName: String;
begin
  if Trim(FCaption) <> '' then
    Result:= FCaption
  else
    inherited;
end;

procedure TSideMenuItem.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  FToolbar.Invalidate;
end;

procedure TSideMenuItem.SetGroupIndex(const Value: Integer);
begin
  FGroupIndex := Value;
  FToolbar.Invalidate;
end;

procedure TSideMenuItem.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
  FToolbar.Invalidate;
end;

function TSideMenuItem.State: TSideMenuState;
begin
  Result:= TSideMenuState.lsNormal;
  if FToolbar.FItemIndex = Self.Index then
    Result:= TSideMenuState.lsDown;
  //TODO: Detect if mouse is currently over or clicked on

end;

function TSideMenuItem.BoundsRect: TRect;
var
  T: Integer;
begin
  //TODO: Return rectangle of full possible drawing area of item
  T:= Self.Index * FToolbar.ItemHeight;
  Result:= Rect(0, T, FToolbar.ClientWidth, T + FToolbar.ItemHeight);
end;

{ TSideMenuItems }

constructor TSideMenuItems.Create(AOwner: TPersistent; AToolbar: TSideMenu);
begin
  inherited Create(AOwner, TSideMenuItem);
  FToolbar:= AToolbar;
end;

function TSideMenuItems.GetItem(Index: Integer): TSideMenuItem;
begin
  Result:= TSideMenuItem(inherited Items[Index]);
end;

procedure TSideMenuItems.SetItem(Index: Integer;
  const Value: TSideMenuItem);
begin
  inherited Items[Index]:= Value;
end;

{ TSideMenuGroup }

constructor TSideMenuGroup.Create(Collection: TCollection);
begin
  inherited;
  FToolbar:= TSideMenuGroups(Collection).FToolbar;
end;

destructor TSideMenuGroup.Destroy;
begin

  inherited;
end;

function TSideMenuGroup.GetDisplayName: String;
begin
  if Trim(FCaption) <> '' then
    Result:= FCaption
  else
    inherited;
end;

procedure TSideMenuGroup.SetCaption(const Value: TCaption);
begin
  FCaption := Value;
  FToolbar.Invalidate;
end;

function TSideMenuGroup.BoundsRect: TRect;
begin
  //TODO: Return rect representing group header display

end;

{ TSideMenuGroups }

constructor TSideMenuGroups.Create(AOwner: TPersistent;
  AToolbar: TSideMenu);
begin
  inherited Create(AOwner, TSideMenuGroup);
  FToolbar:= AToolbar;
end;

function TSideMenuGroups.GetItem(Index: Integer): TSideMenuGroup;
begin
  Result:= TSideMenuGroup(inherited Items[Index]);
end;

procedure TSideMenuGroups.SetItem(Index: Integer;
  const Value: TSideMenuGroup);
begin
  inherited Items[Index]:= Value;
end;

{ TSideMenu }

constructor TSideMenu.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TSideMenuItems.Create(Self, Self);
  FGroups:= TSideMenuGroups.Create(Self, Self);

  ParentColor:= False;
  Color:= clBtnFace;

  FHover:= False;

  FStyleDown:= TSideButtonStateProps.Create;
  FStyleDown.FBackColor:= Color;
  FStyleDown.FForeColor:= Color;
  FStyleDown.FBorderColor:= clRed;
  FStyleDown.Border:= lbRect;

  FStyleNormal:= TSideButtonStateProps.Create;
  FStyleNormal.FBackColor:= Color;
  FStyleNormal.FForeColor:= Color;
  FStyleNormal.FBorderColor:= Color;
  FStyleNormal.Border:= lbNone;

  FStyleClick:= TSideButtonStateProps.Create;
  FStyleClick.FBackColor:= Color;
  FStyleClick.FForeColor:= Color;
  FStyleClick.FBorderColor:= clBlue;
  FStyleClick.Border:= lbRect;

  FStyleHover:= TSideButtonStateProps.Create;
  FStyleHover.FBackColor:= Color;
  FStyleHover.FForeColor:= Color;
  FStyleHover.FBorderColor:= clSkyBlue;
  FStyleHover.Border:= lbRect;

  Align:= alLeft;
  Width:= 200;
  FItemHeight:= 42;
  FItemIndex:= -1;

end;

destructor TSideMenu.Destroy;
begin

  FGroups.Free;
  FItems.Free;
  inherited;
end;

procedure TSideMenu.SetGroups(const Value: TSideMenuGroups);
begin
  FGroups := Value;
  Invalidate;
end;

procedure TSideMenu.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  Invalidate;
end;

procedure TSideMenu.SetItemIndex(const Value: Integer);
begin
  FItemIndex := Value;
  Invalidate;
end;

procedure TSideMenu.SetItems(const Value: TSideMenuItems);
begin
  FItems.Assign(Value);
  Invalidate;
end;

procedure TSideMenu.SetStyleClick(const Value: TSideButtonStateProps);
begin
  FStyleClick.Assign(Value);
  Invalidate;
end;

procedure TSideMenu.SetStyleDown(const Value: TSideButtonStateProps);
begin
  FStyleDown.Assign(Value);
  Invalidate;
end;

procedure TSideMenu.SetStyleHover(const Value: TSideButtonStateProps);
begin
  FStyleHover.Assign(Value);
  Invalidate;
end;

procedure TSideMenu.SetStyleNormal(const Value: TSideButtonStateProps);
begin
  FStyleNormal.Assign(Value);
  Invalidate;
end;

procedure TSideMenu.CMHitTest(var Msg: TWMNCHitTest);
var
  X: Integer;
  P: TPoint;
  I: TSideMenuItem;
  G: TSideMenuGroup;
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

procedure TSideMenu.Paint;
var
  C: TCanvas;
  B: TBrush;
  P: TPen;
  I: TSideMenuItem;
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

unit uJDCompsTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.UITypes,
  JD.SmoothMove, JD.PageMenu, JD.Ctrls.FontButton, JD.Ctrls.SideMenu,
  uContentForm,
  RMP.Globals,
  uSettings,
  uInventoryList,
  uCustomerList,
  RMP.BusinessObjects,
  JD.FormHistory,
  Vcl.Themes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.Styles.Fixes,
  Vcl.Styles.Ext,
  //Vcl.Styles.SysControls,
  Vcl.Styles.NC,
  FireDAC.Stan.Intf,

  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, Vcl.Menus;

const
  LEFT_MIN_POS = 40;
  LEFT_MAX_POS = 200;

  SUB_MIN_POS = 0;
  SUB_MAX_POS = 220;

  BOTTOM_MIN_POS = 40;
  BOTTOM_MAX_POS = 60;

  POPUP_MIN_POS = 0;
  POPUP_MAX_POS = 150;

type
  TfrmTestMain = class(TForm)
    pLeft: TPanel;
    pBottom: TPanel;
    pSubMenu: TPanel;
    pContent: TPanel;
    Events: TApplicationEvents;
    DB: TFDConnection;
    smLeftMenu: TSmoothMove;
    smSubMenu: TSmoothMove;
    smBottomMenu: TSmoothMove;
    FontButton1: TFontButton;
    btnDashboard: TFontButton;
    btnCurrentLocation: TFontButton;
    FontButton3: TFontButton;
    btnCustomers: TFontButton;
    btnInventory: TFontButton;
    FontButton2: TFontButton;
    FontButton4: TFontButton;
    FontButton5: TFontButton;
    FontButton19: TFontButton;
    FontButton20: TFontButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    pLocation: TPanel;
    lblLocations: TStaticText;
    pCustomers: TPanel;
    StaticText6: TStaticText;
    btnCustomerList: TFontButton;
    FontButton6: TFontButton;
    pInventory: TPanel;
    StaticText5: TStaticText;
    btnInventoryList: TFontButton;
    FontButton7: TFontButton;
    FontButton8: TFontButton;
    FontButton24: TFontButton;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    pPurchaseOrders: TPanel;
    StaticText1: TStaticText;
    FontButton12: TFontButton;
    FontButton13: TFontButton;
    FontButton14: TFontButton;
    FontButton25: TFontButton;
    pVendors: TPanel;
    StaticText2: TStaticText;
    FontButton10: TFontButton;
    FontButton11: TFontButton;
    FontButton15: TFontButton;
    FontButton23: TFontButton;
    TabSheet6: TTabSheet;
    pUsers: TPanel;
    StaticText3: TStaticText;
    FontButton16: TFontButton;
    FontButton17: TFontButton;
    FontButton18: TFontButton;
    FontButton21: TFontButton;
    FontButton22: TFontButton;
    btnPOS: TFontButton;
    TabSheet7: TTabSheet;
    pPOS: TPanel;
    StaticText4: TStaticText;
    FontButton26: TFontButton;
    FontButton27: TFontButton;
    FontButton28: TFontButton;
    FontButton9: TFontButton;
    FontButton29: TFontButton;
    FontButton30: TFontButton;
    tmrPopup: TTimer;
    smPopup: TSmoothMove;
    TabSheet8: TTabSheet;
    pPopup: TPanel;
    Panel2: TPanel;
    PageControl2: TPageControl;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    pNewInvoice: TPanel;
    FontButton31: TFontButton;
    FontButton32: TFontButton;
    FontButton33: TFontButton;
    FontButton34: TFontButton;
    FontButton35: TFontButton;
    FontButton36: TFontButton;
    FontButton37: TFontButton;
    FontButton38: TFontButton;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    procedure smLeftMenuValue(Sender: TObject; const Position: Double);
    procedure btnLeftMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure smBottomMenuValue(Sender: TObject; const Position: Double);
    procedure btnBottomMenuClick(Sender: TObject);
    procedure smSubMenuValue(Sender: TObject; const Position: Double);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnCurrentLocationClick(Sender: TObject);
    procedure pLeftResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnLocationClick(Sender: TObject);
    procedure btnInventoryClick(Sender: TObject);
    procedure btnCustomersClick(Sender: TObject);
    procedure EventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure pmSettingsChange(Sender: TObject; const AItem: TPageMenuItem);
    procedure FormDestroy(Sender: TObject);
    procedure btnInventoryListClick(Sender: TObject);
    procedure btnCustomerListClick(Sender: TObject);
    procedure FontButton2Click(Sender: TObject);
    procedure FontButton4Click(Sender: TObject);
    procedure FontButton5Click(Sender: TObject);
    procedure btnPOSClick(Sender: TObject);
    procedure tmrPopupTimer(Sender: TObject);
    procedure smPopupValue(Sender: TObject; const Position: Double);
    procedure FormShow(Sender: TObject);
    procedure FontButton26MouseEnter(Sender: TObject);
    procedure FontButton26MouseLeave(Sender: TObject);
  private
    FHist: TFormHistory;
    FShowMainMenu: Boolean;
    FShowSubMenu: Boolean;
    FShowBottomMenu: Boolean;
    FShowPopup: Boolean;
    FSettings: TfrmSettings;
    FInventoryList: TfrmInventoryList;
    FCustomerList: TfrmCustomerList;
    FLocations: TLocations;
    FNCControls: TNCControls;
    FPopupControl: TControl;
    FBackButton: TNCButton;
    procedure HideSubMenuPanels;
    procedure PositionSubMenu;
    procedure ShowBottomMenuCaptions(const AShow: Boolean);
    procedure LoadReg;
    procedure LoadLocations;
    procedure SetupTitleBar;
    procedure btnCloseClick(Sender: TObject);
    procedure PositionSystemButtons;
    procedure btnBackClick(Sender: TObject);
    procedure btnMaxClick(Sender: TObject);
    procedure btnMinClick(Sender: TObject);
    procedure HistShowForm(Sender: TFormHistory; Item: TFormHistoryItem);
    procedure HideMenus;
  public
    procedure ShowMainMenu(const Force: Boolean = False);
    procedure HideMainMenu(const Force: Boolean = False);
    procedure ShowSubMenu(const Force: Boolean = False; const Width: Integer = SUB_MAX_POS);
    procedure HideSubMenu(const Force: Boolean = False);
    procedure ShowBottomMenu(const Force: Boolean = False);
    procedure HideBottomMenu(const Force: Boolean = False);
    procedure ShowPopup(const Force: Boolean = False);
    procedure HidePopup;
    function ShowContent(AForm: TfrmContent; const AClass: TfrmContentClass): TfrmContent;
  end;

var
  frmTestMain: TfrmTestMain;

implementation

{$R *.dfm}

uses
  uSearchView, Registry, Vcl.Styles.Utils.Graphics;

procedure TfrmTestMain.LoadReg;
var
  R: TRegistry;
begin
  R:= TRegistry.Create(KEY_READ);
  try
    R.RootKey:= HKEY_LOCAL_MACHINE;
    if R.OpenKey('Software\7Lands\RugM\Setup\', False) then begin

      DB.Params.Values['Server']:= R.ReadString('ServerName');
      DB.Params.Values['Password']:= R.ReadString('DBPassword');
      DB.Params.Values['Database']:= R.ReadString('DatabaseName');

      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure TfrmTestMain.FormCreate(Sender: TObject);
begin
  FNCControls:= TNCControls.Create(Self);
  FNCControls.ShowCaption:= False;
  FNCControls.ShowSystemMenu:= False;

  FHist:= TFormHistory.Create(nil);
  FHist.OnShowForm:= HistShowForm;

  smLeftMenu.Value:= LEFT_MIN_POS;
  smLeftMenu.Reset;
  smSubMenu.Value:= SUB_MIN_POS;
  smSubMenu.Reset;
  smBottomMenu.Value:= BOTTOM_MIN_POS;
  smBottomMenu.Reset;

  pContent.Left:= LEFT_MIN_POS;
  pContent.Width:= ClientWidth - pContent.Left;
  pContent.Top:= 0;
  pContent.Height:= ClientHeight - BOTTOM_MIN_POS;
  pContent.Anchors:= [akLeft,akTop,akRight,akBottom];

  FSettings:= TfrmSettings.Create(nil);
  FSettings.Parent:= pContent;
  FSettings.Align:= alClient;

  FInventoryList:= nil;
  FCustomerList:= nil;

  FLocations:= TLocations.Create;

  LoadReg;

  DB.Connected:= True;

end;

procedure TfrmTestMain.FormDestroy(Sender: TObject);
begin
  DB.Connected:= False;

  FLocations.Free;
  FInventoryList.Free;
  FCustomerList.Free;

  FHist.Free;

  FSettings.Free;
end;

procedure TfrmTestMain.HistShowForm(Sender: TFormHistory; Item: TFormHistoryItem);
begin
  //TODO: Show relevant form
  //Self.ShowContent()
  if Assigned(Item) then begin
    if Assigned(Item.Form) then begin
      //Show form in content box
      Item.Form.Parent:= pContent;
      Item.Form.BorderStyle:= bsNone;
      Item.Form.Align:= alClient;
      Item.Form.Show;
      Item.Form.BringToFront;
    end else begin
      //No form assigned

    end;
  end else begin
    //No item assigned

  end;
end;

procedure TfrmTestMain.SetupTitleBar;
var
  Clr: TColor;
  procedure PrepButton(ABtn: TNCButton);
  begin
    ABtn.Style:= nsAlpha;
    ABtn.UseFontAwesome:= True;
    ABtn.Caption:= '';
    ABtn.ImageAlignment:= iaCenter;
    ABtn.FontColor:= clWhite;
    ABtn.HotFontColor:= clWhite;
    ABtn.AlphaValue:= 255;
    ABtn.AlphaColor:= $00151515;
    ABtn.AlphaHotColor:= $003C3C3C;
  end;
begin
  FNCControls.ButtonsList.Clear;
  FNCControls.ShowCaption:= True;

  Clr:= FNCControls.StyleServices.GetStyleColor(TStyleColor.scButtonHot);

  FBackButton:= FNCControls.ButtonsList.Add;
  PrepButton(FBackButton);
  FBackButton.ImageIndex:= fa_chevron_left;
  FBackButton.OnClick:= btnBackClick;

  PositionSystemButtons;
end;

procedure TfrmTestMain.FormResize(Sender: TObject);
begin
  PositionSubMenu;
  PositionSystemButtons;
end;

procedure TfrmTestMain.FormShow(Sender: TObject);
begin

  SetupTitleBar;

end;

procedure TfrmTestMain.btnBackClick(Sender: TObject);
begin
  FHist.GoBack;
end;

procedure TfrmTestMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTestMain.btnMaxClick(Sender: TObject);
begin
  case Self.WindowState of
    TWindowState.wsNormal: WindowState:= wsMaximized;
    else WindowState:= wsNormal;
  end;
  SetupTitleBar;
end;

procedure TfrmTestMain.btnMinClick(Sender: TObject);
begin
  WindowState:= wsMinimized;
end;

procedure TfrmTestMain.PositionSystemButtons;
begin
  if Assigned(FNCControls) then begin
    if FNCControls.ButtonsCount > 0 then begin
      FBackButton.BoundsRect := Rect(0, 0, 45, 32);
    end;
  end;
end;

function TfrmTestMain.ShowContent(AForm: TfrmContent; const AClass: TfrmContentClass): TfrmContent;
begin
  if not Assigned(AForm) then begin
    AForm:= AClass.Create(nil);
    AForm.Parent:= pContent;
    AForm.Align:= alClient;
  end;
  AForm.Show;
  AForm.BringToFront;
  Result:= AForm;
end;

procedure TfrmTestMain.btnLocationClick(Sender: TObject);
var
  C, N: String;
begin
  if Sender is TFontButton then begin
    C:= btnCurrentLocation.Text;
    N:= (Sender as TFontButton).Text;
    if C = N then begin
      MessageDlg('You are already in location "'+C+'".', mtInformation,
        [mbOK], 0);
    end else begin
      HideMenus;
      case MessageDlg('Change location from "'+C+'" to "'+N+'"?',
        mtConfirmation, [mbYes,mbNo], 0)
      of
        mrYes: begin
          btnCurrentLocation.Text:= (Sender as TFontButton).Text;
          btnCurrentLocation.Hint:= (Sender as TFontButton).Text;
        end;
        else begin

        end;
      end;
    end;
  end;
end;

procedure TfrmTestMain.HideMenus;
begin
  HideMainMenu;
  HideSubMenu;
  HideBottomMenu;
  HidePopup;
end;

procedure TfrmTestMain.btnInventoryListClick(Sender: TObject);
begin
  HideMenus;
  FInventoryList:= TfrmInventoryList(ShowContent(FInventoryList, TfrmInventoryList));
  FInventoryList.Qry.Connection:= DB;
end;

procedure TfrmTestMain.btnCustomerListClick(Sender: TObject);
begin
  HideMenus;
  FCustomerList:= TfrmCustomerList(ShowContent(FCustomerList, TfrmCustomerList));
  FCustomerList.Qry.Connection:= DB;
end;

procedure TfrmTestMain.FontButton26MouseEnter(Sender: TObject);
var
  X, H: Integer;
begin
  tmrPopup.Enabled:= False;
  FPopupControl:= TControl(Sender);
  pNewInvoice.Parent:= pPopup;
  pNewInvoice.Align:= alClient;
  H:= 0;
  for X := 0 to pNewInvoice.ControlCount-1 do begin
    H:= H + pNewInvoice.Controls[X].Height;
  end;
  if H > 0 then
    pPopup.Height:= H
  else
    pPopup.Height:= 200;
  pNewInvoice.Show;
  pNewInvoice.BringToFront;
  tmrPopup.Enabled:= True;
end;

procedure TfrmTestMain.FontButton26MouseLeave(Sender: TObject);
var
  C: TControl;
  R: TRect;
  P: TPoint;
begin
  C:= TControl(Sender);
  P:= Mouse.CursorPos;
  R.TopLeft:= C.ClientToScreen(Point(0, 0));
  R.Width:= C.Width;
  R.Height:= C.Height;
  if not PtInRect(R, P) then begin
    HidePopup;
  end;
end;

procedure TfrmTestMain.FontButton2Click(Sender: TObject);
begin
  HideSubMenu(True);
  pPurchaseOrders.Parent:= pSubMenu;
  pPurchaseOrders.Align:= alClient;
  pPurchaseOrders.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.HidePopup;
begin
  pPopup.Visible:= False;
  pPopup.Width:= 0;
  smPopup.Value:= 0;
end;

procedure TfrmTestMain.FontButton4Click(Sender: TObject);
begin
  HideSubMenu(True);
  pVendors.Parent:= pSubMenu;
  pVendors.Align:= alClient;
  pVendors.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.FontButton5Click(Sender: TObject);
begin
  HideSubMenu(True);
  pUsers.Parent:= pSubMenu;
  pUsers.Align:= alClient;
  pUsers.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnPOSClick(Sender: TObject);
begin
  HideSubMenu(True);
  pPOS.Parent:= pSubMenu;
  pPOS.Align:= alClient;
  pPOS.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnInventoryClick(Sender: TObject);
begin
  HideSubMenu(True);
  pInventory.Parent:= pSubMenu;
  pInventory.Align:= alClient;
  pInventory.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnCustomersClick(Sender: TObject);
begin
  HideSubMenu(True);
  pCustomers.Parent:= pSubMenu;
  pCustomers.Align:= alClient;
  pCustomers.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnSettingsClick(Sender: TObject);
begin
  HideMenus;
  //Load Settings
  FSettings.Show;
  FSettings.BringToFront;
end;

procedure TfrmTestMain.LoadLocations;
const
  LOC_MAIN =    '';
  LOC_STORE =   '';
  LOC_VIRTUAL = '';
  LOC_ECOMM =   '';
  LOC_TRANSIT = '';
var
  Q: TFDQuery;
  X: Integer;
  T: Integer;
  C: TControl;
  L: TLocation;
  B: TFontButton;
begin
  FLocations.Clear;
  for X := pLocation.ControlCount-1 downto 0 do begin
    C:= pLocation.Controls[X];
    if C is TFontButton then begin
      C.Free;
    end;
  end;
  Q:= TFDQuery.Create(nil);
  try
    Q.Connection:= Self.DB;
    Q.Open('select * from Stores order by Company_Name');
    while not Q.Eof do begin
      L:= FLocations.Add(Q.FieldByName('ID').AsInteger);
      L.Caption:= Q.FieldByName('Company_Name').AsString;
      case L.ID of
        0: begin
          L.LocationType:= TLocationType.ltMain;
        end;
        7777: begin
          L.LocationType:= TLocationType.ltTransit;
        end;
        8888: begin
          L.LocationType:= TLocationType.ltEComm;
        end;
        else begin
          if Q.FieldByName('Flag').AsBoolean = True then
            L.LocationType:= TLocationType.ltVirtual
          else
            L.LocationType:= TLocationType.ltStore;
        end;
      end;
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
  T:= lblLocations.Height + 1;
  lblLocations.Top:= -1;
  for X := 0 to FLocations.Count-1 do begin
    L:= FLocations[X];
    if L.LocationType in [ltMain, ltStore, ltVirtual, ltEComm] then begin
      B:= TFontButton.Create(pLocation);
      B.Parent:= pLocation;
      B.Align:= alTop;
      B.Top:= T + 1;
      B.Height:= 30;
      B.Text:= L.Caption;
      B.Hint:= L.Caption;
      B.ShowHint:= True;
      B.Tag:= L.ID;
      B.TabStop:= False;
      B.Image.Font.Name:= 'FontAwesome';
      B.Image.UseStandardColor:= False;
      B.Image.Font.Color:= clWhite;
      B.OnClick:= btnLocationClick;
      case L.LocationType of
        ltMain:     B.Image.Text:= LOC_MAIN;
        ltStore:    B.Image.Text:= LOC_STORE;
        ltVirtual:  B.Image.Text:= LOC_VIRTUAL;
        ltEComm:    B.Image.Text:= LOC_ECOMM;
        ltTransit:  B.Image.Text:= LOC_TRANSIT;
      end;
      T:= T + B.Height;
    end;
  end;
end;

procedure TfrmTestMain.btnCurrentLocationClick(Sender: TObject);
begin
  HideSubMenu(True);
  LoadLocations;
  pLocation.Parent:= pSubMenu;
  pLocation.Align:= alClient;
  pLocation.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestmain.PositionSubMenu;
begin
  pSubMenu.Top:= 0;
  pSubMenu.Height:= ClientHeight - pBottom.Height;
  pSubMenu.Left:= pLeft.Width;
end;

procedure TfrmTestMain.HideBottomMenu(const Force: Boolean = False);
begin
  FShowBottomMenu:= False;
  ShowBottomMenuCaptions(False);
  smBottomMenu.Value:= BOTTOM_MIN_POS;
  if Force then
    smBottomMenu.Reset;
end;

procedure TfrmTestMain.HideMainMenu(const Force: Boolean = False);
begin
  FShowMainMenu:= False;
  smLeftMenu.Value:= LEFT_MIN_POS;
  if Force then
    smLeftMenu.Reset;
end;

procedure TfrmTestMain.HideSubMenu(const Force: Boolean = False);
begin
  FShowSubMenu:= False;
  HideSubMenuPanels;
  smSubMenu.Value:= SUB_MIN_POS;
  if Force then
    smSubMenu.Reset;
end;

procedure TfrmTestMain.ShowBottomMenu(const Force: Boolean = False);
begin
  FShowBottomMenu:= True;
  ShowBottomMenuCaptions(True);
  smBottomMenu.Value:= BOTTOM_MAX_POS;
  if Force then
    smBottomMenu.Reset;
end;

procedure TfrmTestMain.ShowMainMenu(const Force: Boolean = False);
begin
  FShowMainMenu:= True;
  smLeftMenu.Value:= LEFT_MAX_POS;
  if Force then
    smLeftMenu.Reset;
end;

procedure TfrmTestMain.ShowPopup(const Force: Boolean);
begin
  FShowPopup:= True;
  smPopup.Value:= POPUP_MAX_POS;
end;

procedure TfrmTestMain.ShowSubMenu(const Force: Boolean = False; const Width: Integer = SUB_MAX_POS);
begin
  FShowSubMenu:= True;
  smSubMenu.Value:= Width;
  if Force then
    smSubMenu.Reset;
end;

procedure TfrmTestMain.HideSubMenuPanels;
var
  X: Integer;
  C: TComponent;
begin
  for X := 0 to pSubMenu.ControlCount-1 do begin
    C:= pSubMenu.Controls[X];
    if C is TPanel then begin
      (C as TPanel).Visible:= False;
    end;
  end;
end;

procedure TfrmTestMain.pmSettingsChange(Sender: TObject;
  const AItem: TPageMenuItem);
begin
  FSettings.Pages.ActivePageIndex:= AItem.Index;

  //TODO: Change settings page
  case AItem.Index of
    0: begin
      //General

    end;
    1: begin
      //Main Screen

    end;
    2: begin
      //Point-of-Sale

    end;
    3: begin
      //Inventory

    end;
    4: begin
      //Customers

    end;
  end;
end;

procedure TfrmTestMain.pLeftResize(Sender: TObject);
begin
  PositionSubMenu;
end;

procedure TfrmTestMain.ShowBottomMenuCaptions(const AShow: Boolean);
var
  X: Integer;
  C: TControl;
begin
  for X := 0 to pBottom.ControlCount-1 do begin
    C:= pBottom.Controls[X];
    if C is TFontButton then begin
      if AShow then
        (C as TFontButton).ImagePosition:= TFontButtonImgPosition.fpImgTop
      else
        (C as TFontButton).ImagePosition:= TFontButtonImgPosition.fpImgOnly;
    end;
  end;
end;

procedure TfrmTestMain.EventsMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin

  if FShowMainMenu and
    (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    //not PtInRect(pLeft.ClientRect, pLeft.ScreenToClient(Msg.pt)) and
    not PtInRect(pLeft.ClientRect, pLeft.ScreenToClient(Msg.pt)) then
  begin
    HideMainMenu;
  end;

  if FShowSubMenu and
    (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    not PtInRect(pLeft.ClientRect, pLeft.ScreenToClient(Msg.pt)) and
    not PtInRect(pSubMenu.ClientRect, pSubMenu.ScreenToClient(Msg.pt)) then
  begin
    HideSubMenu;
  end;

  if FShowBottomMenu and
    (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    not PtInRect(pBottom.ClientRect, pBottom.ScreenToClient(Msg.pt)) then
  begin
    HideBottomMenu;
  end;

  if (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    not PtInRect(pPopup.ClientRect, pPopup.ScreenToClient(Msg.pt)) then
  begin
    HidePopup;
  end;

  if Assigned(FPopupControl) then begin
    if (Msg.message = WM_MOUSEMOVE) and
      not PtInRect(FPopupControl.ClientRect, FPopupControl.ScreenToClient(Msg.pt)) and
      //not PtInRect(pSubMenu.ClientRect, pSubMenu.ScreenToClient(Msg.pt)) and
      not PtInRect(pPopup.ClientRect, pPopup.ScreenToClient(Msg.pt)) then
    begin
      HidePopup;
    end;
  end;

end;

procedure TfrmTestMain.btnBottomMenuClick(Sender: TObject);
begin
  if FShowBottomMenu then begin
    HideBottomMenu;
  end else begin
    ShowBottomMenu;
  end;
end;

procedure TfrmTestMain.btnLeftMenuClick(Sender: TObject);
begin
  if FShowMainMenu then begin
    HideMainMenu;
  end else begin
    ShowMainMenu;
  end;
end;

procedure TfrmTestMain.smBottomMenuValue(Sender: TObject;
  const Position: Double);
begin
  pBottom.Height:= Trunc(Position);
  Application.ProcessMessages;
end;

procedure TfrmTestMain.smLeftMenuValue(Sender: TObject;
  const Position: Double);
begin
  pLeft.Width:= Trunc(Position);
  Application.ProcessMessages;
end;

procedure TfrmTestMain.smPopupValue(Sender: TObject; const Position: Double);
begin
  pPopup.Width:= Trunc(Position);
  Application.ProcessMessages;
end;

procedure TfrmTestMain.smSubMenuValue(Sender: TObject; const Position: Double);
begin
  pSubMenu.Width:= Trunc(Position);
  Application.ProcessMessages;
end;

procedure TfrmTestMain.tmrPopupTimer(Sender: TObject);
var
  P: TPoint;
begin
  if Assigned(FPopupControl) then begin
    tmrPopup.Enabled:= False;
    HidePopup;
    P:= Point(FPopupControl.Width, 0);
    P:= FPopupControl.ClientToParent(P);
    pPopup.Left:= P.X + pLeft.Width - 5;
    pPopup.Top:= P.Y;
    pPopup.Width:= 0;
    //pPopup.Height:= FPopupControl.Height;
    pPopup.Visible:= True;
    pPopup.BringToFront;
    smPopup.Value:= POPUP_MAX_POS;
  end;
end;

end.

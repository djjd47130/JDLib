unit uJDCompsTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  JD.SmoothMove, JD.PageMenu, JD.Ctrls.FontButton,
  uSettings,
  uInventoryList,
  uCustomerList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.AppEvnts, Vcl.ComCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef;

const
  LEFT_MIN_POS = 40;
  LEFT_MAX_POS = 200;

  SUB_MIN_POS = 0;
  SUB_MAX_POS = 200;

  BOTTOM_MIN_POS = 40;
  BOTTOM_MAX_POS = 60;

type
  TfrmTestMain = class(TForm)
    pLeft: TPanel;
    pBottom: TPanel;
    pSubMenu: TPanel;
    pLocation: TPanel;
    pSettings: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    pInventory: TPanel;
    StaticText5: TStaticText;
    pCustomers: TPanel;
    StaticText6: TStaticText;
    pContent: TPanel;
    ApplicationEvents1: TApplicationEvents;
    DB: TFDConnection;
    smLeftMenu: TSmoothMove;
    smSubMenu: TSmoothMove;
    smBottomMenu: TSmoothMove;
    pmSettings: TPageMenu;
    FontButton1: TFontButton;
    FontButton2: TFontButton;
    btnCurrentLocation: TFontButton;
    procedure smLeftMenuValue(Sender: TObject; const Position: Double);
    procedure btnLeftMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure smBottomMenuValue(Sender: TObject; const Position: Double);
    procedure btnBottomMenuClick(Sender: TObject);
    procedure smSubMenuValue(Sender: TObject; const Position: Double);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnCollapseSubMenuClick(Sender: TObject);
    procedure btnCurrentLocationClick(Sender: TObject);
    procedure pLeftResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnLocationClick(Sender: TObject);
    procedure FontButton5Click(Sender: TObject);
    procedure FontButton6Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure pmSettingsChange(Sender: TObject; const AItem: TPageMenuItem);
    procedure FormDestroy(Sender: TObject);
    procedure btnInventoryListClick(Sender: TObject);
    procedure FontButton21Click(Sender: TObject);
  private
    FShowMainMenu: Boolean;
    FShowSubMenu: Boolean;
    FShowBottomMenu: Boolean;
    FSettings: TfrmSettings;
    FInventoryList: TfrmInventoryList;
    FCustomerList: TfrmCustomerList;
    procedure HideSubMenuPanels;
    procedure PositionSubMenu;
    procedure ShowBottomMenuCaptions(const AShow: Boolean);
    procedure LoadReg;
  public
    procedure ShowMainMenu(const Force: Boolean = False);
    procedure HideMainMenu(const Force: Boolean = False);
    procedure ShowSubMenu(const Force: Boolean = False);
    procedure HideSubMenu(const Force: Boolean = False);
    procedure ShowBottomMenu(const Force: Boolean = False);
    procedure HideBottomMenu(const Force: Boolean = False);
  end;

var
  frmTestMain: TfrmTestMain;

implementation

{$R *.dfm}

uses
  uSearchView, Registry;

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
var
  X: Integer;
  T: TTabSheet;
  I: TPageMenuItem;
begin
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
  FSettings.Parent:= pSettings;
  FSettings.Align:= alClient;
  FSettings.Show;
  FSettings.BringToFront;

  FInventoryList:= nil;

  pmSettings.Items.Clear;
  for X := 0 to FSettings.Pages.PageCount-1 do begin
    T:= FSettings.Pages.Pages[X];
    I:= pmSettings.Items.Add;
    I.Caption:= T.Caption;
    T.TabVisible:= False;
  end;
  pmSettings.ItemIndex:= 0;

  LoadReg;

  DB.Connected:= True;

end;

procedure TfrmTestMain.FormDestroy(Sender: TObject);
begin
  DB.Connected:= False;

  FInventoryList.Free;
  FCustomerList.Free;


  FSettings.Free;
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
      smSubMenu.Value:= SUB_MIN_POS;
      case MessageDlg('Change location from "'+C+'" to "'+N+'"?',
        mtConfirmation, [mbYes,mbNo], 0)
      of
        mrYes: begin
          btnCurrentLocation.Text:= (Sender as TFontButton).Text;
        end;
        else begin

        end;
      end;
    end;
  end;
end;

procedure TfrmTestMain.btnInventoryListClick(Sender: TObject);
begin
  HideSubMenu;
  if FInventoryList = nil then begin
    FInventoryList:= TfrmInventoryList.Create(nil);
    FInventoryList.Parent:= pContent;
    FInventoryList.Align:= alClient;
    FInventoryList.Qry.Connection:= DB;
  end;
  FInventoryList.Show;
  FInventoryList.BringToFront;
end;

procedure TfrmTestMain.FontButton21Click(Sender: TObject);
begin
  HideSubMenu;
  if FCustomerList = nil then begin
    FCustomerList:= TfrmCustomerList.Create(nil);
    FCustomerList.Parent:= pContent;
    FCustomerList.Align:= alClient;
    FCustomerList.Qry.Connection:= DB;
  end;
  FCustomerList.Show;
  FCustomerList.BringToFront;
end;

procedure TfrmTestMain.FontButton5Click(Sender: TObject);
begin
  HideSubMenu(True);
  //Load Settings
  pInventory.Parent:= pSubMenu;
  pInventory.Align:= alClient;
  pInventory.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.FontButton6Click(Sender: TObject);
begin
  HideSubMenu(True);
  //Load Customer Menu
  pCustomers.Parent:= pSubMenu;
  pCustomers.Align:= alClient;
  pCustomers.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnSettingsClick(Sender: TObject);
begin
  HideSubMenu(True);
  //Load Settings
  pSettings.Parent:= pSubMenu;
  pSettings.Align:= alClient;
  pSettings.Visible:= True;
  ShowSubMenu;
end;

procedure TfrmTestMain.btnCurrentLocationClick(Sender: TObject);
begin
  HideSubMenu(True);
  //Load locations
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

procedure TfrmTestMain.FormResize(Sender: TObject);
begin
  PositionSubMenu;
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

procedure TfrmTestMain.ShowSubMenu(const Force: Boolean = False);
begin
  FShowSubMenu:= True;
  smSubMenu.Value:= SUB_MAX_POS;
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

procedure TfrmTestMain.btnCollapseSubMenuClick(Sender: TObject);
begin
  HideSubMenu;
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

procedure TfrmTestMain.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if FShowSubMenu and
    (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    not PtInRect(pLeft.ClientRect, pLeft.ScreenToClient(Msg.pt)) and
    not PtInRect(pSubMenu.ClientRect, pSubMenu.ScreenToClient(Msg.pt)) then
  begin
    //HideMainMenu; //???
    HideSubMenu;
  end;

  if FShowBottomMenu and
    (Msg.message >= WM_LBUTTONDOWN) and (Msg.message <= WM_MBUTTONDBLCLK) and
    not PtInRect(pBottom.ClientRect, pBottom.ScreenToClient(Msg.pt)) then
  begin
    HideBottomMenu;
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
end;

procedure TfrmTestMain.smLeftMenuValue(Sender: TObject;
  const Position: Double);
begin
  pLeft.Width:= Trunc(Position);
end;

procedure TfrmTestMain.smSubMenuValue(Sender: TObject; const Position: Double);
begin
  pSubMenu.Width:= Trunc(Position);
end;

end.

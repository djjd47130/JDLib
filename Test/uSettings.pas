unit uSettings;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.WinXCtrls, JD.PageMenu;

type
  TfrmSettings = class(TForm)
    Pages: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    pmSettings: TPageMenu;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    ToggleSwitch1: TToggleSwitch;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    trkMainMenuSpeed: TTrackBar;
    Panel6: TPanel;
    Label3: TLabel;
    trkSubMenuSpeed: TTrackBar;
    Panel7: TPanel;
    Label4: TLabel;
    ToggleSwitch2: TToggleSwitch;
    TabSheet8: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure pmSettingsChange(Sender: TObject; const AItem: TPageMenuItem);
    procedure trkMainMenuSpeedChange(Sender: TObject);
    procedure trkSubMenuSpeedChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

uses
  uJDCompsTestMain;

procedure TfrmSettings.FormCreate(Sender: TObject);
var
  X: Integer;
  T: TTabSheet;
  I: TPageMenuItem;
begin
  Pages.Align:= alClient;

  pmSettings.Items.Clear;
  for X := 0 to Pages.PageCount-1 do begin
    T:= Pages.Pages[X];
    I:= pmSettings.Items.Add;
    I.Caption:= T.Caption;
    T.TabVisible:= False;
  end;
  pmSettings.ItemIndex:= 0;


  trkMainMenuSpeed.Position:= 4;
  trkSubMenuSpeed.Position:= 4;


end;

procedure TfrmSettings.pmSettingsChange(Sender: TObject;
  const AItem: TPageMenuItem);
begin
  Pages.ActivePageIndex:= AItem.Index;

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

procedure TfrmSettings.trkMainMenuSpeedChange(Sender: TObject);
begin
  case trkMainMenuSpeed.Position of
    1: frmTestMain.smLeftMenu.Delay:= 25;
    2: frmTestMain.smLeftMenu.Delay:= 20;
    3: frmTestMain.smLeftMenu.Delay:= 15;
    4: frmTestMain.smLeftMenu.Delay:= 11;
    5: frmTestMain.smLeftMenu.Delay:= 7;
  end;
end;

procedure TfrmSettings.trkSubMenuSpeedChange(Sender: TObject);
begin
  case trkSubMenuSpeed.Position of
    1: frmTestMain.smSubMenu.Delay:= 25;
    2: frmTestMain.smSubMenu.Delay:= 20;
    3: frmTestMain.smSubMenu.Delay:= 15;
    4: frmTestMain.smSubMenu.Delay:= 11;
    5: frmTestMain.smSubMenu.Delay:= 7;
  end;
end;

end.

unit uSysMonTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.ImageList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ImgList, Vcl.ComCtrls,
  JD.SysMon.Utils, JD.SysMon,
  JD.Common, JD.FontGlyphs;

type

  TItemType = (itCPU, itRAM, itDrive);

  TListRef = class(TObject)
  end;

  TCPURef = class(TListRef)
  private
    FCPU: TJDSystemMonitorCPUInfo;
  public
    constructor Create(ACPU: TJDSystemMonitorCPUInfo);
    property CPU: TJDSystemMonitorCPUInfo read FCPU;
  end;

  TRAMRef = class(TListRef)
  private
    FRAM: TJDSystemMonitorRAMInfo;
  public
    constructor Create(ARAM: TJDSystemMonitorRAMInfo);
    property RAM: TJDSystemMonitorRAMInfo read FRAM;
  end;

  TDriveRef = class(TListRef)
  private
    FDrive: TJDSystemMonitorDriveInfo;
  public
    constructor Create(ADrive: TJDSystemMonitorDriveInfo);
    property Drive: TJDSystemMonitorDriveInfo read FDrive;
  end;

  TfrmJDSysMonTestMain = class(TForm)
    Lst: TListView;
    img16: TImageList;
    Glyphs: TJDFontGlyphs;
    Mon: TJDSystemMonitor;
    procedure FormCreate(Sender: TObject);
    procedure MonDriveAdded(Sender: TObject; Drive: TJDSystemMonitorDriveInfo);
    procedure MonDriveRemoved(Sender: TObject;
      Drive: TJDSystemMonitorDriveInfo);
    procedure MonDriveInfo(Sender: TObject; Drive: TJDSystemMonitorDriveInfo);
    procedure FormDestroy(Sender: TObject);
    procedure MonCPUInfo(Sender: TObject; CPU: TJDSystemMonitorCPUInfo);
    procedure MonRAMInfo(Sender: TObject; RAM: TJDSystemMonitorRAMInfo);
  private
    function AddDriveToList(ADrive: TJDSystemMonitorDriveInfo): TListItem;
    procedure RemoveDriveFromList(ADrive: TJDSystemMonitorDriveInfo);
    procedure UpdateDriveInList(ADrive: TJDSystemMonitorDriveInfo);
    procedure UpdateDriveListItem(Item: TListItem; Drive: TJDSystemMonitorDriveInfo);
    procedure UpdateCPUInList(ACPU: TJDSystemMonitorCPUInfo);
    procedure UpdateRAMInList(ARAM: TJDSystemMonitorRAMInfo);
    procedure ClearList;
  public

  end;

var
  frmJDSysMonTestMain: TfrmJDSysMonTestMain;

implementation

{$R *.dfm}

{ TCPURef }

constructor TCPURef.Create(ACPU: TJDSystemMonitorCPUInfo);
begin
  FCPU:= ACPU;
end;

{ TRAMRef }

constructor TRAMRef.Create(ARAM: TJDSystemMonitorRAMInfo);
begin
  FRAM:= ARAM;
end;

{ TDriveRef }

constructor TDriveRef.Create(ADrive: TJDSystemMonitorDriveInfo);
begin
  FDrive:= ADrive;
end;

{ TfrmJDSysMonTestMain }

procedure TfrmJDSysMonTestMain.FormCreate(Sender: TObject);
var
  I: TListItem;
  CR: TCPURef;
  RR: TRAMRef;
begin
  ReportMemoryLeaksOnShutdown:= True;
  Lst.Align:= alClient;

  I:= Lst.Items.Add;
  CR:= TCPURef.Create(GetCPUInfo);
  I.Data:= CR;
  I.GroupID:= 0;
  I.Caption:= 'CPU';
  I.SubItems.Add(''); //Type
  I.SubItems.Add(''); //Capacity
  I.SubItems.Add(''); //Used
  I.SubItems.Add(''); //Free
  I.SubItems.Add(''); //Percent

  I:= Lst.Items.Add;
  RR:= TRAMRef.Create(GetRAMInfo);
  I.Data:= RR;
  I.GroupID:= 1;
  I.Caption:= 'RAM';
  I.SubItems.Add(''); //Type
  I.SubItems.Add(''); //Capacity
  I.SubItems.Add(''); //Used
  I.SubItems.Add(''); //Free
  I.SubItems.Add(''); //Percent

end;

procedure TfrmJDSysMonTestMain.FormDestroy(Sender: TObject);
begin
  ClearList;
end;

procedure TfrmJDSysMonTestMain.MonCPUInfo(Sender: TObject;
  CPU: TJDSystemMonitorCPUInfo);
begin
  UpdateCPUInList(CPU);
end;

procedure TfrmJDSysMonTestMain.MonDriveAdded(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
begin
  AddDriveToList(Drive);
end;

procedure TfrmJDSysMonTestMain.MonDriveInfo(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
begin
  UpdateDriveInList(Drive);
end;

procedure TfrmJDSysMonTestMain.MonDriveRemoved(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
begin
  RemoveDriveFromList(Drive);
end;

procedure TfrmJDSysMonTestMain.MonRAMInfo(Sender: TObject;
  RAM: TJDSystemMonitorRAMInfo);
begin
  UpdateRAMInList(RAM);
end;

function TfrmJDSysMonTestMain.AddDriveToList(ADrive: TJDSystemMonitorDriveInfo): TListItem;
var
  R: TDriveRef;
begin
  Result:= Lst.Items.Add;
  R:= TDriveRef.Create(ADrive);
  Result.Data:= R;
  Result.GroupID:= 2;
  Result.SubItems.Add('');
  Result.SubItems.Add('');
  Result.SubItems.Add('');
  Result.SubItems.Add('');
  Result.SubItems.Add('');
  UpdateDriveListItem(Result, ADrive);
end;

procedure TfrmJDSysMonTestMain.UpdateDriveListItem(Item: TListItem; Drive: TJDSystemMonitorDriveInfo);
begin
  Item.Caption:= Drive.DriveName;
  Item.SubItems[0]:= Drive.DriveType;
  Item.SubItems[1]:= DataSizeStr(Drive.SizeTotal);
  Item.SubItems[2]:= DataSizeStr(Drive.SizeUsed);
  Item.SubItems[3]:= DataSizeStr(Drive.SizeFree);
  Item.SubItems[4]:= FormatFloat('0.0', Drive.UsagePerc)+'%';
  //TODO: Icon...
end;

procedure TfrmJDSysMonTestMain.UpdateCPUInList(ACPU: TJDSystemMonitorCPUInfo);
var
  X: Integer;
  I: TListItem;
  R: TListRef;
begin
  for X := 0 to Lst.Items.Count-1 do begin
    I:= Lst.Items[X];
    if I.Data <> nil then begin
      R:= TListRef(I.Data);
      if R is TCPURef then begin
        I.Caption:= ACPU.CPUName;
        I.SubItems[4]:= FormatFloat('0.0', ACPU.UsagePerc)+'%';
        Break;
      end;
    end;
  end;
end;

procedure TfrmJDSysMonTestMain.UpdateRAMInList(ARAM: TJDSystemMonitorRAMInfo);
var
  X: Integer;
  I: TListItem;
  R: TListRef;
begin
  for X := 0 to Lst.Items.Count-1 do begin
    I:= Lst.Items[X];
    if I.Data <> nil then begin
      R:= TListRef(I.Data);
      if R is TRAMRef then begin
        I.SubItems[1]:= DataSizeStr(ARAM.SizeTotal);
        I.SubItems[2]:= DataSizeStr(ARAM.SizeUsed);
        I.SubItems[3]:= DataSizeStr(ARAM.SizeFree);
        I.SubItems[4]:= FormatFloat('0.0', ARAM.UsagePerc)+'%';
        Break;
      end;
    end;
  end;
end;

procedure TfrmJDSysMonTestMain.UpdateDriveInList(ADrive: TJDSystemMonitorDriveInfo);
var
  X: Integer;
  I: TListItem;
  DL: String;
  R: TListRef;
begin
  for X := 0 to Lst.Items.Count-1 do begin
    I:= Lst.Items[X];
    if I.Data <> nil then begin
      R:= TListRef(I.Data);
      if R is TDriveRef then begin
        DL:= TDriveRef(R).Drive.DriveLetter;
        if DL = ADrive.DriveLetter then begin
          UpdateDriveListItem(I, ADrive);
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmJDSysMonTestMain.RemoveDriveFromList(ADrive: TJDSystemMonitorDriveInfo);
var
  X: Integer;
  I: TListItem;
  DL: String;
  R: TListRef;
begin
  for X := 0 to Lst.Items.Count-1 do begin
    I:= Lst.Items[X];
    if I.Data <> nil then begin
      R:= TListRef(I.Data);
      if R is TDriveRef then begin
        DL:= TDriveRef(R).Drive.DriveLetter;
        if DL = ADrive.DriveLetter then begin
          R.Free;
          Lst.Items.Delete(X);
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmJDSysMonTestMain.ClearList;
var
  X: Integer;
  I: TListItem;
  R: TListRef;
begin
  for X := 0 to Lst.Items.Count-1 do begin
    I:= Lst.Items[X];
    if I.Data <> nil then begin
      R:= TListRef(I.Data);
      R.Free;
    end;
  end;
  Lst.Items.Clear;
end;

end.

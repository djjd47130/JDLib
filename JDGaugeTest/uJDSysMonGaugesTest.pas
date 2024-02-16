unit uJDSysMonGaugesTest;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls,
  JD.Common, JD.Ctrls, JD.Ctrls.Gauges, JD.Ctrls.Gauges.Objects, JD.SysMon,
  JD.Graphics, JD.SysMon.Utils,
  NeedleGaugeObj, JD.VolumeControls, MSI_Common, MSI_CPU;

type

  TDriveGaugeRef = class(TObject)
  private
    FDrive: TJDSystemMonitorDriveInfo;
    FGauge: TJDGauge;
  public
    constructor Create(Drive: TJDSystemMonitorDriveInfo);
    destructor Destroy; override;
    procedure Update(ADrive: TJDSystemMonitorDriveInfo);
    property Gauge: TJDGauge read FGauge;
    property Drive: TJDSystemMonitorDriveInfo read FDrive;
  end;

  TfrmJDSSysMonGaugesTest = class(TForm)
    gCPU: TJDGauge;
    gRAM: TJDGauge;
    Mon: TJDSystemMonitor;
    gVol: TJDGauge;
    Vol: TJDVolumeControls;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MonCPUInfo(Sender: TObject; CPU: TJDSystemMonitorCPUInfo);
    procedure MonRAMInfo(Sender: TObject; RAM: TJDSystemMonitorRAMInfo);
    procedure MonDriveInfo(Sender: TObject; Drive: TJDSystemMonitorDriveInfo);
    procedure MonDriveAdded(Sender: TObject; Drive: TJDSystemMonitorDriveInfo);
    procedure MonDriveRemoved(Sender: TObject;
      Drive: TJDSystemMonitorDriveInfo);
    procedure VolVolumeChanged(Sender: TObject; const Volume: Integer);
    procedure VolMuteChanged(Sender: TObject; const Muted: Boolean);
  private
    FDrives: TObjectList<TDriveGaugeRef>;
    function FindDriveRef(ADrive: TJDSystemMonitorDriveInfo): TDriveGaugeRef;
    procedure AdjustColors;
    procedure SetSubCaptionVisibility;
  public
    { Public declarations }
  end;

var
  frmJDSSysMonGaugesTest: TfrmJDSSysMonGaugesTest;

implementation

{$R *.dfm}

{ TDriveGaugeRef }

constructor TDriveGaugeRef.Create(Drive: TJDSystemMonitorDriveInfo);
begin
  FDrive:= Drive;
  //TODO: Create gauge...
  FGauge:= TJDGauge.Create(nil);
  FGauge.Parent:= frmJDSSysMonGaugesTest;
  FGauge.GaugeType:= 'Horizontal Bar';
  FGauge.Assign(frmJDSSysMonGaugesTest.gCPU);
  FGauge.Align:= alTop;
  FGauge.Top:= 50000;
  frmJDSSysMonGaugesTest.FormResize(nil);
  frmJDSSysMonGaugesTest.AdjustColors;
end;

destructor TDriveGaugeRef.Destroy;
begin
  //TODO: Destroy gauge...
  FreeAndNil(FGauge);
  frmJDSSysMonGaugesTest.FormResize(nil);
  inherited;
end;

procedure TDriveGaugeRef.Update(ADrive: TJDSystemMonitorDriveInfo);
begin
  FDrive:= ADrive;
  Gauge.MainValue.Caption:= Drive.DriveName;
  Gauge.MainValue.SubCaption:= DataSizeStr(Drive.SizeFree) + ' Free of ' + DataSizeStr(Drive.SizeTotal);
  Gauge.MainValue.Value:= Drive.UsagePerc;
  if ADrive.DriveType = 'Local Disk' then
    Gauge.Glyph.Glyph:= ''
  else if ADrive.DriveType = 'Network Drive' then
    Gauge.Glyph.Glyph:= ''
  else if ADrive.DriveType = 'CD Drive' then
    Gauge.Glyph.Glyph:= ''
  else
    Gauge.Glyph.Glyph:= '';
end;

{ TfrmJDSSysMonGaugesTest }

function TfrmJDSSysMonGaugesTest.FindDriveRef(
  ADrive: TJDSystemMonitorDriveInfo): TDriveGaugeRef;
var
  X: Integer;
begin
  Result:= nil;
  for X := 0 to FDrives.Count-1 do begin
    if FDrives[X].FDrive.DriveLetter = ADrive.DriveLetter then begin
      Result:= FDrives[X];
      Break;
    end;
  end;
end;

procedure TfrmJDSSysMonGaugesTest.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= True;
  {$ENDIF}
  FDrives:= TObjectList<TDriveGaugeRef>.Create(True);
  Width:= 1200;
  Height:= 420;
  WindowState:= wsMaximized;
  gVol.MainValue.Value:= Vol.Volume;
  if Vol.Muted then
    gVol.Glyph.Glyph:= ''
  else
    gVol.Glyph.Glyph:= '';
  FormResize(nil);
end;

procedure TfrmJDSSysMonGaugesTest.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDrives);
end;

procedure TfrmJDSSysMonGaugesTest.FormResize(Sender: TObject);
const
  MAX_FONT_HEIGHT = 50;
  MAX_FONT_OFFSET = 3;
  FONT_SCALE = 0.8; // 0.96;
  GLYPH_SCALE = 0.96;
var
  X: Integer;
  H: Integer;
  G: TJDGauge;
begin
  //Recalculate gauge heights...
  if Application.Terminated then Exit;
  H:= (ClientHeight div ControlCount);
  for X := 0 to ControlCount-1 do begin
    Controls[X].Height:= H;
    if Controls[X] is TJDGauge then begin
      G:= TJDGauge(Controls[X]);
      if H < MAX_FONT_HEIGHT then begin
        G.Font.Height:= Trunc((H - MAX_FONT_OFFSET) * FONT_SCALE);
        G.SubCaptionFont.Height:= Trunc((H - MAX_FONT_OFFSET) * FONT_SCALE);
      end else begin
        G.Font.Height:= Trunc((MAX_FONT_HEIGHT - MAX_FONT_OFFSET) * FONT_SCALE);
        G.SubCaptionFont.Height:= Trunc((MAX_FONT_HEIGHT - MAX_FONT_OFFSET) * FONT_SCALE);
      end;
      G.Glyph.Font.Height:= Trunc((H - 3) * GLYPH_SCALE);
      G.Thickness:= Round(H / 2.5);
      G.MainValue.OffsetThickness:= H / 1.8;
      G.MainValue.Peak.OffsetThickness:= H / 2.5;
      G.MainValue.TicksMajor.Length:= (H / 5);
    end;
  end;
  SetSubCaptionVisibility;
end;

procedure TfrmJDSSysMonGaugesTest.SetSubCaptionVisibility;
var
  X: Integer;
  G: TJDGauge;
begin
  if Application.Terminated then Exit;
  for X := 0 to ControlCount-1 do begin
    if Controls[X] is TJDGauge then begin
      G:= TJDGauge(Controls[X]);
      G.ShowSubCaption:= Self.ClientWidth >= 800;
    end;
  end;
end;

procedure TfrmJDSSysMonGaugesTest.VolMuteChanged(Sender: TObject;
  const Muted: Boolean);
begin
  if Application.Terminated then Exit;
  if Muted then
    gVol.Glyph.Glyph:= ''
  else
    gVol.Glyph.Glyph:= '';
end;

procedure TfrmJDSSysMonGaugesTest.VolVolumeChanged(Sender: TObject;
  const Volume: Integer);
begin
  if Application.Terminated then Exit;
  gVol.MainValue.Value:= Volume;
end;

procedure TfrmJDSSysMonGaugesTest.MonCPUInfo(Sender: TObject;
  CPU: TJDSystemMonitorCPUInfo);
begin
  if Application.Terminated then Exit;
  gCPU.MainValue.Value:= CPU.UsagePerc;
  gCPU.MainValue.SubCaption:= CPU.CPUName;
  AdjustColors;
end;

procedure TfrmJDSSysMonGaugesTest.MonDriveAdded(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
var
  R: TDriveGaugeRef;
begin
  if Application.Terminated then Exit;
  R:= TDriveGaugeRef.Create(Drive);
  try

  finally
    FDrives.Add(R);
  end;
end;

procedure TfrmJDSSysMonGaugesTest.MonDriveRemoved(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
var
  R: TDriveGaugeRef;
  I: Integer;
begin
  if Application.Terminated then Exit;
  R:= Self.FindDriveRef(Drive);
  I:= FDrives.IndexOf(R);
  FDrives.Delete(I);
end;

procedure TfrmJDSSysMonGaugesTest.MonDriveInfo(Sender: TObject;
  Drive: TJDSystemMonitorDriveInfo);
var
  R: TDriveGaugeRef;
begin
  if Application.Terminated then Exit;
  R:= FindDriveRef(Drive);
  R.Update(Drive);
  AdjustColors;
end;

procedure TfrmJDSSysMonGaugesTest.MonRAMInfo(Sender: TObject;
  RAM: TJDSystemMonitorRAMInfo);
begin
  if Application.Terminated then Exit;
  gRAM.MainValue.Value:= RAM.UsagePerc;
  gRAM.MainValue.SubCaption:= DataSizeStr(RAM.SizeFree) + ' Free of ' + DataSizeStr(RAM.SizeTotal);
  AdjustColors;
end;

procedure TfrmJDSSysMonGaugesTest.AdjustColors;
var
  X: Integer;
  G: TJDGauge;
begin
  //Change gauge colors depending on value...
  if Application.Terminated then Exit;
  for X := 0 to ControlCount-1 do begin
    if Controls[X] is TJDGauge then begin
      G:= TJDGauge(Controls[X]);
      if G.MainValue.Value > (G.MainValue.Range * 0.75) then begin
        G.MainValue.Color.StandardColor:= fcRed;
        G.Glyph.StandardColor:= fcRed;
      end else
      if G.MainValue.Value > (G.MainValue.Range * 0.5) then begin
        G.MainValue.Color.StandardColor:= fcOrange;
        G.Glyph.StandardColor:= fcOrange;
      end else
      if G.MainValue.Value > (G.MainValue.Range * 0.25) then begin
        G.MainValue.Color.StandardColor:= fcBlue;
        G.Glyph.StandardColor:= fcBlue;
      end else begin
        G.MainValue.Color.StandardColor:= fcGreen;
        G.Glyph.StandardColor:= fcGreen;
      end;
    end;
  end;
end;

end.

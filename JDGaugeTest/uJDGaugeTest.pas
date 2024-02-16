unit uJDGaugeTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JD.Common, JD.Ctrls, JD.Ctrls.Gauges,
  JD.Ctrls.Gauges.Objects, JD.SysMon, JD.SysMon.Utils, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmGaugeTestMain = class(TForm)
    Gauge: TJDGauge;
    pTop: TPanel;
    cboType: TComboBox;
    Tmr: TTimer;
    procedure TmrTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cboTypeClick(Sender: TObject);
    procedure GaugeGlyphClick(Sender: TObject);
    procedure GaugeValueClick(Sender: TJDGauge; Value: TJDGaugeValue);
    procedure GaugeCaptionClick(Sender: TJDGauge; Value: TJDGaugeValue);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGaugeTestMain: TfrmGaugeTestMain;

implementation

{$R *.dfm}

procedure TfrmGaugeTestMain.FormCreate(Sender: TObject);
var
  L: TJDGaugeClassList;
  X: Integer;
begin
  Gauge.Align:= alClient;
  cboType.Items.Clear;
  L:= JDGaugeClasses;
  for X := 0 to L.Count-1 do begin
    cboType.Items.Append(L[X].GetCaption);
  end;
  cboType.ItemIndex:= cboType.Items.IndexOf(Gauge.GaugeType);
end;

procedure TfrmGaugeTestMain.GaugeCaptionClick(Sender: TJDGauge;
  Value: TJDGaugeValue);
begin
  ShowMessage('Caption "'+Value.Caption+'" clicked!');
end;

procedure TfrmGaugeTestMain.GaugeGlyphClick(Sender: TObject);
begin
  ShowMessage('Glyph clicked!');
end;

procedure TfrmGaugeTestMain.GaugeValueClick(Sender: TJDGauge;
  Value: TJDGaugeValue);
begin
  ShowMessage('Value "'+Value.Caption+'" clicked!');
end;

procedure TfrmGaugeTestMain.cboTypeClick(Sender: TObject);
begin
  Gauge.GaugeType:= cboType.Text;
end;

procedure TfrmGaugeTestMain.TmrTimer(Sender: TObject);
var
  Perc: Double;
begin
  Perc:= GetTotalCpuUsagePct;
  Gauge.Values[0].Value:= Perc;
end;

end.

unit uJDGaugeStackTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JD.Common, JD.Ctrls, JD.Ctrls.Gauges;

type
  TfrmJDGaugeStackTest = class(TForm)
    JDGauge1: TJDGauge;
    procedure FormCreate(Sender: TObject);
  private
    //FGauge: TJDGauge;
  public
    { Public declarations }
  end;

var
  frmJDGaugeStackTest: TfrmJDGaugeStackTest;

implementation

{$R *.dfm}

procedure TfrmJDGaugeStackTest.FormCreate(Sender: TObject);
begin
{
  FGauge:= TJDGauge.Create(Self);
  FGauge.Parent:= Self;
  FGauge.Left:= 0;
  FGauge.Top:= 0;
  FGauge.Width:= 100;
  FGauge.Height:= 100;
  }
end;

end.

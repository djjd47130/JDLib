program JDGaugeTest;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uJDGaugeTest in 'uJDGaugeTest.pas' {frmGaugeTestMain},
  uJDGaugeTest2 in 'uJDGaugeTest2.pas' {Form1},
  uJDGaugeStackTest in 'uJDGaugeStackTest.pas' {frmJDGaugeStackTest},
  uJDSysMonGaugesTest in 'uJDSysMonGaugesTest.pas' {frmJDSSysMonGaugesTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'JD Gauge Test';
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TfrmJDSSysMonGaugesTest, frmJDSSysMonGaugesTest);
  Application.CreateForm(TfrmGaugeTestMain, frmGaugeTestMain);
  Application.CreateForm(TfrmJDGaugeStackTest, frmJDGaugeStackTest);
  Application.Run;
end.

program JDSysMonTest;

uses
  Vcl.Forms,
  uSysMonTestMain in 'uSysMonTestMain.pas' {frmJDSysMonTestMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmJDSysMonTestMain, frmJDSysMonTestMain);
  Application.Run;
end.

program JDCompsTest;

uses
  Vcl.Forms,
  uJDCompsTestMain in 'uJDCompsTestMain.pas' {frmTestMain},
  Vcl.Themes,
  Vcl.Styles,
  uSearchView in 'uSearchView.pas' {frmSearchView},
  uSettings in 'uSettings.pas' {frmSettings},
  uInventoryList in 'uInventoryList.pas' {frmInventoryList},
  uCustomerList in 'uCustomerList.pas' {frmCustomerList},
  uContentForm in 'uContentForm.pas' {frmContent};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TfrmTestMain, frmTestMain);
  Application.CreateForm(TfrmCustomerList, frmCustomerList);
  Application.CreateForm(TfrmContent, frmContent);
  Application.Run;
end.

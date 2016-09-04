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
  uContentForm in 'uContentForm.pas' {frmContent},
  RMP.BusinessObjects in 'RMP.BusinessObjects.pas',
  Vcl.Styles.Utils.Graphics in '..\..\..\vcl-styles-utils-master\Common\Vcl.Styles.Utils.Graphics.pas',
  RMP.FormHistory in 'RMP.FormHistory.pas';

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

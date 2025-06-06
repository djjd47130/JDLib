program JDVectorTest;

uses
  Vcl.Forms,
  uVectorTestMain in 'uVectorTestMain.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  JD.VectorGraphicEditor in '..\Source\Editors\JD.VectorGraphicEditor.pas' {frmJDVectorEditor};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TfrmJDVectorEditor, frmJDVectorEditor);
  Application.Run;
end.

unit uDashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uContentForm, Vcl.StdCtrls;

type
  TfrmDashboard = class(TfrmContent)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

end.

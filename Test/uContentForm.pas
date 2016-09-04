unit uContentForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfrmContent = class;

  //Represents a single button along the bottom bar of the host window
  TContextMenuItem = class(TObject)
  private
    FCaption: String;
  public

  end;

  TfrmContentClass = class of TfrmContent;

  TfrmContent = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmContent: TfrmContent;

implementation

{$R *.dfm}

end.

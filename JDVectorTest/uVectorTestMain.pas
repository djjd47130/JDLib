unit uVectorTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JD.Common, JD.Ctrls, JD.Vector,
  JD.VectorGraphicEditor,
  JD.Ctrls.VectorEditor,
  JD.Graphics;

type
  TForm1 = class(TForm)
    Img: TJDVectorImage;
    procedure FormCreate(Sender: TObject);
    procedure ImgClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  ColorManager.BaseColor:= clBlack;

  Img.Align:= alClient;
end;

procedure TForm1.ImgClick(Sender: TObject);
begin
  var F:= TfrmJDVectorEditor.Create(nil);
  try
    F.LoadGraphic(Img.Graphic);
    if F.ShowModal = mrOK then begin
      Img.Graphic.Assign(F.Img.Graphic);
    end;
  finally
    F.Free;
  end;
end;

end.

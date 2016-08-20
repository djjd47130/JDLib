unit uInventoryList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uSearchView, Vcl.ExtCtrls,
  JD.Ctrls.FontButton, Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Imaging.GIFImg, JD.ImageGrid,
  Vcl.Imaging.jpeg;

type
  TfrmInventoryList = class(TfrmSearchView)
  private

  protected
    function GetQuery: String; override;
    function GetIDField: String; override;
    function GetCaptionField: String; override;
    function GetDetailField: String; override;
    function GetSortField: String; override;
  public
    { Public declarations }
  end;

var
  frmInventoryList: TfrmInventoryList;

implementation

{$R *.dfm}

function TfrmInventoryList.GetCaptionField: String;
begin
  Result:= 'Rug_No';
end;

function TfrmInventoryList.GetDetailField: String;
begin
  Result:= 'Short_Desc';
end;

function TfrmInventoryList.GetIDField: String;
begin
  Result:= 'ID';
end;

function TfrmInventoryList.GetSortField: String;
begin
  Result:= 'Rug_No';
end;

function TfrmInventoryList.GetQuery: String;
var
  L: TStringList;
begin
  L:= TStringList.Create;
  try
    L.Add('    SELECT ROW_NUMBER() OVER(ORDER BY '+GetSortField+') AS NUMBER,');
    L.Add('      I.ID, I.Rug_No, I.Short_Desc ');
    L.Add('    FROM Invent I');
    L.Add('      JOIN SKU S on S.ID = I.Sku_ID');
    Result:= L.Text;
  finally
    L.Free;
  end;
end;

end.

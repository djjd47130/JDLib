unit uCustomerList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uSearchView, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, JD.ImageGrid,
  JD.Ctrls.FontButton, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TfrmCustomerList = class(TfrmSearchView)
    procedure ResultsDblClick(Sender: TObject);
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
  frmCustomerList: TfrmCustomerList;

implementation

{$R *.dfm}

{ TfrmCustomerList }

function TfrmCustomerList.GetCaptionField: String;
begin
  Result:= 'ID';
end;

function TfrmCustomerList.GetDetailField: String;
begin
  Result:= 'EntityName'
end;

function TfrmCustomerList.GetIDField: String;
begin
  Result:= 'ID';
end;

function TfrmCustomerList.GetSortField: String;
begin
  Result:= 'LastName, FirstName, CompanyName';
end;

procedure TfrmCustomerList.ResultsDblClick(Sender: TObject);
begin
  inherited;
  //TODO: Show details for current record

end;

function TfrmCustomerList.GetQuery: String;
var
  L: TStringList;
  T, ST: String;
begin
  T:= Trim(txtSearchText.Text);
  ST:= QuotedStr('%'+T+'%');
  L:= TStringList.Create;
  try
    L.Add('    SELECT ROW_NUMBER() OVER(ORDER BY '+GetSortField+') AS NUMBER,');
    L.Add('      C.ID, C.FirstName, C.LastName, C.CompanyName,');
    L.Add('       EntityName = case when Isnull(C.CompanyName,'''') <>'''' then C.CompanyName else C.FirstName + '' '' + C.LastName end');
    L.Add('    FROM Customer C');
    if T <> '' then begin
      L.Add('    where C.FirstName like '+ST);
      L.Add('    or C.LastName like '+ST);
      L.Add('    or C.CompanyName like '+ST);
    end;

    Result:= L.Text;
  finally
    L.Free;
  end;
end;

end.

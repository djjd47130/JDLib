unit uSearchView;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  uContentForm,
  JD.Ctrls.FontButton,
  {$IFDEF DEBUG}
  Clipbrd,
  {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, JD.ImageGrid, Vcl.Imaging.GIFImg,
  Vcl.Imaging.jpeg;

type

  TSearchResult = class(TObject)
  private
    FID: Integer;
    FCaption: String;
    FBitmap: TBitmap;
    FDetail: String;
    procedure SetBitmap(const Value: TBitmap);
    procedure SetCaption(const Value: String);
    procedure SetID(const Value: Integer);
    procedure SetDetail(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
  public
    property ID: Integer read FID write SetID;
    property Caption: String read FCaption write SetCaption;
    property Detail: String read FDetail write SetDetail;
    property Bitmap: TBitmap read FBitmap write SetBitmap;
  end;

  TfrmSearchView = class(TfrmContent)
    Panel1: TPanel;
    txtSearchText: TEdit;
    Label1: TLabel;
    btnGo: TFontButton;
    pResults: TPanel;
    Panel2: TPanel;
    btnNext: TFontButton;
    btnPrev: TFontButton;
    Qry: TFDQuery;
    Results: TImageGrid;
    imgDefault: TImage;
    lblPage: TLabel;
    btnFilter: TFontButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ResultsDrawCell(Sender: TCustomImageGrid; Index, ACol,
      ARow: Integer; R: TRect);
    procedure btnGoClick(Sender: TObject);
    procedure ResultsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure ResultsResize(Sender: TObject);
    procedure txtSearchTextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FDefaultImage: TBitmap;
    FPageCount: Integer;
    FRecordCount: Integer;
    FCurrentPage: Integer;
    FPageSize: Integer;
    FColCount: Integer;
    FMinColWidth: Integer;
    FMaxColWidth: Integer;
    procedure ClearResults;
    procedure LoadPage;
    procedure SetPageSize(const Value: Integer);
    procedure DisplayNavigation;
    procedure ShowPage;
    procedure SetColCount(const Value: Integer);
    procedure SetMaxColWidth(const Value: Integer);
    procedure SetMinColWidth(const Value: Integer);
  protected
    function GetQuery: String; virtual;
    function GetIDField: String; virtual;
    function GetCaptionField: String; virtual;
    function GetDetailField: String; virtual;
    function GetSortField: String; virtual;
  public
    function PageCount: Integer;
    function RecordCount: Integer;
    function CurrentPage: Integer;
  public
    property MinColWidth: Integer read FMinColWidth write SetMinColWidth;
    property MaxColWidth: Integer read FMaxColWidth write SetMaxColWidth;
    property ColCount: Integer read FColCount write SetColCount;
    property PageSize: Integer read FPageSize write SetPageSize;
  end;

var
  frmSearchView: TfrmSearchView;

implementation

{$R *.dfm}

{ TSearchResult }

constructor TSearchResult.Create;
begin
  FBitmap:= TBitmap.Create;
  FID:= 0;
  FCaption:= 'New Item';
end;

destructor TSearchResult.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TSearchResult.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
end;

procedure TSearchResult.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TSearchResult.SetDetail(const Value: String);
begin
  FDetail := Value;
end;

procedure TSearchResult.SetID(const Value: Integer);
begin
  FID := Value;
end;

{ TfrmSearchView }

procedure TfrmSearchView.FormCreate(Sender: TObject);
begin
  pResults.Align:= alClient;
  Results.Align:= alClient;
  FDefaultImage:= TBitmap.Create;
  FDefaultImage.Assign(imgDefault.Picture.Graphic);
  FPageSize:= 100;
  FPageCount:= 0;
  FRecordCount:= 0;
  FCurrentPage:= 1;
  FColCount:= 5;
  FMinColWidth:= 150;
  FMaxColWidth:= 200;
  lblPage.Caption:= '';
end;

procedure TfrmSearchView.FormDestroy(Sender: TObject);
begin
  FDefaultImage.Free;
  ClearResults;
end;

function TfrmSearchView.PageCount: Integer;
begin
  Result:= FPageCount;
end;

function TfrmSearchView.RecordCount: Integer;
begin
  Result:= FRecordCount;
end;

function TfrmSearchView.CurrentPage: Integer;
begin
  Result:= FCurrentPage;
end;

function TfrmSearchView.GetCaptionField: String;
begin
  Result:= 'Caption';
end;

function TfrmSearchView.GetDetailField: String;
begin
  Result:= 'Detail';
end;

function TfrmSearchView.GetIDField: String;
begin
  Result:= 'ID';
end;

function TfrmSearchView.GetQuery: String;
begin
  //Virtual - to be inherited
end;

function TfrmSearchView.GetSortField: String;
begin
  Result:= '1';
end;

procedure TfrmSearchView.LoadPage;
var
  L: TStringList;
begin
  Qry.Close;
  Qry.SQL.Clear;

  L:= TStringList.Create;
  try
    L.Add('SELECT * FROM (');
    L.Add(GetQuery); //Get main query from inherited form
    L.Add('  ) AS TBL');
    L.Add('WHERE NUMBER BETWEEN (('+IntToStr(FCurrentPage)+' - 1) * '+
      IntToStr(FPageSize)+' + 1) AND ('+IntToStr(FCurrentPage)+' * '+IntToStr(FPageSize)+')');
    L.Add('ORDER BY '+GetSortField);

    {$IFDEF DEBUG}
    Clipboard.AsText:= L.Text;
    {$ENDIF}

    Qry.Open(L.Text);

    ShowPage;

  finally
    L.Free;
  end;
end;

procedure TfrmSearchView.btnGoClick(Sender: TObject);
var
  L: TStringList;
begin
  inherited;
  ClearResults;
  FPageCount:= 0;
  FRecordCount:= 0;
  FCurrentPage:= 1;

  //TODO: First get total count to calculate page count
  Qry.Close;
  L:= TStringList.Create;
  try
    L.Add(GetQuery); //Get main query from inherited form

    {$IFDEF DEBUG}
    Clipboard.AsText:= L.Text;
    {$ENDIF}

    Qry.Open(L.Text);
    FRecordCount:= Qry.RecordCount;
    FPageCount:= (FRecordCount div FPageSize) + 1;

  finally
    L.Free;
  end;

  LoadPage;
end;

procedure TfrmSearchView.DisplayNavigation;
var
  Starting, Ending: Integer;
begin
  btnPrev.Enabled:= FCurrentPage > 1;
  btnNext.Enabled:= FCurrentPage < FPageCount;
  Starting:= Trunc((FCurrentPage - 1) * FPageSize) + 1;
  Ending:= Starting + FPageSize - 1;
  if Ending > FRecordCount then
    Ending:= FRecordCount;
  lblPage.Caption:= IntToStr(Starting)+' to '+IntToStr(Ending)+' of '+IntToStr(FRecordCount);
end;

procedure TfrmSearchView.btnNextClick(Sender: TObject);
begin
  if FCurrentPage < FPageCount then
    FCurrentPage:= FCurrentPage + 1;
  LoadPage;
end;

procedure TfrmSearchView.btnPrevClick(Sender: TObject);
begin
  if FCurrentPage > 1 then
    FCurrentPage:= FCurrentPage - 1;
  LoadPage;
end;

procedure TfrmSearchView.ClearResults;
var
  X: Integer;
  R: TSearchResult;
begin
  for X := 0 to Results.Items.Count-1 do begin
    R:= TSearchResult(Results.Items.Objects[X]);
    R.Free;
  end;
  Results.Items.Clear;
end;

procedure TfrmSearchView.ShowPage;
var
  R: TSearchResult;
begin
  ClearResults;
  Qry.First;
  while not Qry.Eof do begin
    R:= TSearchResult.Create;
    R.ID:= Qry.FieldByName(GetIDField).AsInteger;
    R.Caption:= Qry.FieldByName(GetCaptionField).AsString;
    R.Detail:= Qry.FieldByName(GetDetailField).AsString;
    R.Bitmap:= FDefaultImage;
    Results.Items.AddObject(R.FCaption, R);

    Qry.Next;
  end;
  DisplayNavigation;
end;

procedure TfrmSearchView.txtSearchTextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      btnGoClick(Sender);
    end;
  end;
end;

procedure TfrmSearchView.ResultsDrawCell(Sender: TCustomImageGrid; Index, ACol,
  ARow: Integer; R: TRect);
const
  SPACING = 10;
var
  C: TCanvas;
  Res: TSearchResult;
  FCap: UINT;
  FDet: UINT;
  FImg: UINT;
  DispRect, CR, IR, DR: TRect;
  function CaptionRect: TRect;
  begin
    Result:= Rect(DispRect.Left, DispRect.Top, DispRect.Right, DispRect.Top + 20);
  end;
  function ImageRect: TRect;
  begin
    Result:= Rect(DispRect.Left, CaptionRect.Bottom, DispRect.Right, DispRect.Bottom - 60);
  end;
  function DetailRect: TRect;
  begin
    Result:= Rect(DispRect.Left, ImageRect.Bottom, DispRect.Right, DispRect.Bottom);
  end;
begin
  C:= Results.Canvas;
  Res:= TSearchResult(Results.Items.Objects[Index]);
  DispRect:= R;
  InflateRect(DispRect, -SPACING, -SPACING);
  C.Font.Assign(Font);
  C.Brush.Style:= bsSolid;
  C.Brush.Color:= clBlack;
  C.Pen.Style:= psSolid;
  C.Pen.Width:= 1;
  if Index = Results.ItemIndex then begin
    C.Pen.Color:= Results.MarkerColor;
  end else begin
    C.Pen.Color:= clBlack;
  end;
  C.Rectangle(R);
  C.Brush.Style:= bsClear;
  C.Pen.Style:= psClear;
  CR:= CaptionRect;
  InflateRect(CR, -2, -2);
  IR:=ImageRect;
  InflateRect(IR, -2, -2);
  DR:= DetailRect;
  InflateRect(DR, -2, -2);
  FCap:= DT_CENTER or DT_VCENTER;
  FDet:= DT_CENTER or DT_VCENTER or DT_WORDBREAK;
  FImg:= DT_CENTER or DT_VCENTER or DT_WORDBREAK;
  C.Font.Assign(Results.CaptionFont);
  DrawText(C.Handle, PChar(Res.FCaption), Length(Res.FCaption), CR, FCap);
  if Res.FBitmap.Width > 0 then begin
    C.StretchDraw(IR, Res.FBitmap);
  end else begin
    C.Font.Assign(Results.CaptionFont);
    C.Font.Size:= 16;
    DrawText(C.Handle, PChar('No Image'), Length('No Image'), IR, FImg);
  end;
  C.Font.Assign(Results.DetailFont);
  DrawText(C.Handle, PChar(Res.FDetail), Length(Res.FDetail), DR, FDet);
end;

procedure TfrmSearchView.ResultsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Results.Invalidate;
  Results.Repaint;
end;

procedure TfrmSearchView.ResultsResize(Sender: TObject);
var
  W: Integer;
begin
  //TODO: Calculate optimal col count based on width


  W:= Results.ClientWidth div FColCount;
  Results.CellWidth:= W;
  Results.CellHeight:= Trunc(W * 1.5);
end;

procedure TfrmSearchView.SetColCount(const Value: Integer);
begin
  FColCount := Value;
end;

procedure TfrmSearchView.SetMaxColWidth(const Value: Integer);
begin
  FMaxColWidth := Value;
end;

procedure TfrmSearchView.SetMinColWidth(const Value: Integer);
begin
  FMinColWidth := Value;
end;

procedure TfrmSearchView.SetPageSize(const Value: Integer);
begin
  FPageSize := Value;
  //TODO: Invalidate (Needs to reload entire query)

end;

end.

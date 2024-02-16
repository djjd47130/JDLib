{*******************************************************}
{                                                       }
{            Delphi Visual Component Library            }
{                                                       }
{ Copyright(c) 2016 Embarcadero Technologies, Inc.      }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit ColEdit;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, LibHelp;

type
  TColInfo = class(TObject)
  private
    FOwner: TList;
    FCaption: string;
    FWidth: Integer;
    FIndex: Integer;
    FAlignment: TAlignment;
    FWidthType: TWidth;
    function GetIndex: Integer;
  public
    constructor Create(AOwner: TList; Column: TListColumn);
    destructor Destroy; override;
    property Index: Integer read GetIndex;
    property Owner: TList read FOwner;
  end;

type
  TListViewColumns = class(TForm)
    ColumnGroupBox: TGroupBox;
    PropGroupBox: TGroupBox;
    ColumnListBox: TListBox;
    New: TButton;
    Delete: TButton;
    Ok: TButton;
    Cancel: TButton;
    Apply: TButton;
    Help: TButton;
    Label1: TLabel;
    Label4: TLabel;
    TextEdit: TEdit;
    AlignmentEdit: TComboBox;
    GroupBox1: TGroupBox;
    WidthEdit: TEdit;
    HWidthBtn: TRadioButton;
    IWidthBtn: TRadioButton;
    WidthBtn: TRadioButton;
    procedure ValueChanged(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure TextEditExit(Sender: TObject);
    procedure IndexEditExit(Sender: TObject);
    procedure WidthEditExit(Sender: TObject);
    procedure ColumnListBoxClick(Sender: TObject);
    procedure NewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure AlignmentEditExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ColumnListBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ColumnListBoxDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure ColumnListBoxStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure ColumnListBoxEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ColumnListBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HWidthBtnClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
  private
    FInfoList: TList;
    FDefaultText: string;
    FDragIndex: Integer;
    FColumns: TListColumns;
    procedure FlushControls;
    procedure GetItem(Value: TListColumn);
    function GetColInfo(Index: Integer): TColInfo;
    function ListBoxText(Value: TColInfo): string;
    procedure SetItem(Value: TColInfo);
    procedure SetListBoxText(Index: Integer; const S: string);
    procedure SetStates;
  public
    property ColItems[Index: Integer]: TColInfo read GetColInfo;
    property Columns: TListColumns read FColumns;
    property DefaultText: string read FDefaultText;
    property InfoList: TList read FInfoList;
  end;

function EditListViewColumns(AColumns: TListColumns): Boolean;

implementation

{$R *.dfm}

uses DsnConst;

function EditListViewColumns(AColumns: TListColumns): Boolean;
var
  I: Integer;
begin
  with TListViewColumns.Create(Application) do
    try
      FColumns := AColumns;
      for I := 0 to Columns.Count - 1 do
      begin
        TColInfo.Create(InfoList, Columns.Items[I]);
        ColumnListBox.Items.Add(ListBoxText(InfoList[I]));
      end;
      if InfoList.Count > 0 then
      begin
        ColumnListBox.ItemIndex := 0;
        ColumnListBoxClick(nil);
      end;
      SetStates;
      Result := ShowModal = mrOk;
      if Result and Apply.Enabled then ApplyClick(nil);
    finally
      Free;
    end;
end;

procedure ConvertError(Value: TEdit);
begin
  with Value do
  begin
    SetFocus;
    SelectAll;
  end;
end;

{ TColInfo }

constructor TColInfo.Create(AOwner: TList; Column: TListColumn);
begin
  inherited Create;
  FOwner := AOwner;
  AOwner.Add(Self);
  if Column <> nil then
    with Column do
    begin
      FCaption := Caption;
      FWidth := Width;
      FWidthType := WidthType;
      FIndex := Index;
      FAlignment := Alignment;
    end
  else begin
    FWidth := 50;
    FIndex := Index;
    FAlignment := taLeftJustify;
  end;
end;

destructor TColInfo.Destroy;
begin
  Owner.Remove(Self);
  inherited Destroy;
end;

function TColInfo.GetIndex: Integer;
begin
  Result := Owner.IndexOf(Self);
end;

{ TListViewColumns }

procedure TListViewColumns.ValueChanged(Sender: TObject);
begin
  Apply.Enabled := True;
  if Sender = TextEdit then TextEditExit(Sender);
end;

procedure TListViewColumns.DeleteClick(Sender: TObject);
var
  I, OldIndex: Integer;
begin
  with ColumnListBox do
    if ItemIndex <> -1 then
    begin
      OldIndex := ItemIndex;
      ColItems[ItemIndex].Free;
      Items.Delete(ItemIndex);
      if Items.Count > 0 then
      begin
        if OldIndex = Items.Count then Dec(OldIndex);
        for I := OldIndex to Items.Count - 1 do
          SetListBoxText(I, ListBoxText(ColItems[I]));
        ItemIndex := OldIndex;
      end;
      ColumnListBoxClick(nil);
    end;
  SetStates;
  Apply.Enabled := True;
end;

procedure TListViewColumns.SetListBoxText(Index: Integer; const S: string);
var
  TempIndex: Integer;
begin
  with ColumnListBox do
  begin
    TempIndex := ItemIndex;
    Items[Index] := S;
    ItemIndex := TempIndex;
  end;
end;

procedure TListViewColumns.TextEditExit(Sender: TObject);
begin
  with ColumnListBox do
    if ItemIndex <> -1 then
    begin
      ColItems[ItemIndex].FCaption := TextEdit.Text;
      SetListBoxText(ItemIndex, ListBoxText(ColItems[ItemIndex]));
    end;
end;

procedure TListViewColumns.IndexEditExit(Sender: TObject);
begin
  {if ActiveControl <> Cancel then
    try
      with ColumnListBox do
        if (ItemIndex <> -1) and (IndexEdit.Text <> '') then
          ColItems[ItemIndex].FIndex := StrToInt(IndexEdit.Text);
    except
      ConvertError(IndexEdit);
      raise;
    end;}
end;

procedure TListViewColumns.WidthEditExit(Sender: TObject);
begin
  if ActiveControl <> Cancel then
    try
      with ColumnListBox do
        if (ItemIndex <> -1) and (WidthEdit.Text <> '') then
          ColItems[ItemIndex].FWidth := StrToInt(WidthEdit.Text);
    except
      ConvertError(WidthEdit);
      raise;
    end;
end;

procedure TListViewColumns.AlignmentEditExit(Sender: TObject);
begin
  with ColumnListBox do
    if ItemIndex <> -1 then
      ColItems[ItemIndex].FAlignment := TAlignment(AlignmentEdit.ItemIndex);
end;

procedure TListViewColumns.FlushControls;
begin
  TextEditExit(nil);
  IndexEditExit(nil);
  WidthEditExit(nil);
  AlignmentEditExit(nil);
end;

procedure TListViewColumns.GetItem(Value: TListColumn);
var
  ColInfo: TColInfo;
begin
  with Value do
  begin
    ColInfo := InfoList[Index];
    Caption := ColInfo.FCaption;
    if ColInfo.FWidthType = ColumnTextWidth then
      Width := ColumnTextWidth
    else if ColInfo.FWidthType = ColumnHeaderWidth then
      Width := ColumnHeaderWidth
    else Width := ColInfo.FWidth;
    ColInfo.FWidth := Width;
    Alignment := ColInfo.FAlignment;
  end
end;

procedure TListViewColumns.SetItem(Value: TColInfo);
begin
  if Value <> nil then
    with Value do
    begin
      TextEdit.Text := FCaption;
      WidthEdit.Text := IntToStr(FWidth);
      if FWidthType = ColumnHeaderWidth then
        HWidthBtn.Checked := True
      else if FWidthType = ColumnTextWidth then
        IWidthBtn.Checked := True
      else WidthBtn.Checked := True;
      {IndexEdit.Text := IntToStr(FIndex);}
      AlignmentEdit.ItemIndex := Ord(FAlignment);
      AlignmentEdit.Enabled := FIndex <> 0;
    end
  else begin
    TextEdit.Text := '';
    WidthEdit.Text := '';
    WidthBtn.Checked := True;
    {IndexEdit.Text := '';}
    AlignmentEdit.ItemIndex := -1;
  end;
end;

procedure TListViewColumns.ColumnListBoxClick(Sender: TObject);
var
  TempEnabled: Boolean;
begin
  TempEnabled := Apply.Enabled;
  with ColumnListBox do
    if ItemIndex <> -1 then SetItem(ColItems[ItemIndex])
    else SetItem(nil);
  Apply.Enabled := TempEnabled;
end;

procedure TListViewColumns.NewClick(Sender: TObject);
var
  ColInfo: TColInfo;
begin
  FlushControls;
  ColInfo := TColInfo.Create(FInfoList, nil);
  with ColumnListBox do
  begin
    Items.Add(ListBoxText(ColInfo));
    ItemIndex := ColInfo.Index;
  end;
  SetItem(ColInfo);
  SetStates;
  TextEdit.SetFocus;
  Apply.Enabled := True;
end;

procedure TListViewColumns.SetStates;
begin
  Delete.Enabled := ColumnListBox.Items.Count > 0;
  PropGroupBox.Enabled := Delete.Enabled;
  Apply.Enabled := False;
  AlignmentEdit.Enabled := ColumnListBox.ItemIndex > 0;
end;

function TListViewColumns.ListBoxText(Value: TColInfo): string;
begin
  with Value do
  begin
    Result := FCaption;
    if Result = '' then Result := DefaultText;
    FmtStr(Result, '%d - %s', [InfoList.IndexOf(Value), Result])
  end;
end;

procedure TListViewColumns.FormCreate(Sender: TObject);
begin
  FDefaultText := SUntitled;
  FInfoList := TList.Create;
  HelpContext := hcDListViewColEdit;
end;

procedure TListViewColumns.FormDestroy(Sender: TObject);
begin
  while FInfoList.Count > 0 do TColInfo(FInfoList.Last).Free;
  FInfoList.Free;
end;

procedure TListViewColumns.ApplyClick(Sender: TObject);
var
  I: Integer;
begin
  FlushControls;
  Columns.Clear;
  for I := 0 to InfoList.Count - 1 do
  begin
    GetItem(Columns.Add);
    SetListBoxText(I, ListBoxText(InfoList[I]));
  end;
  Apply.Enabled := False;
  with TListView(Columns.Owner) do UpdateItems(0, Items.Count -1);
  ColumnListBoxClick(nil);
end;

function TListViewColumns.GetColInfo(Index: Integer): TColInfo;
begin
  Result := InfoList[Index];
end;

procedure TListViewColumns.ColumnListBoxDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Index: Integer;
begin
  with ColumnListBox do
  begin
    Index := ItemAtPos(Point(X, Y), True);
    Accept := Index <> FDragIndex;
    if Index <> LB_ERR then ItemIndex := Index;
  end;
end;

procedure TListViewColumns.ColumnListBoxDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  I, Index, StartIndex: Integer;
begin
  with ColumnListBox do
  begin
    Index := ItemAtPos(Point(X, Y), True);
    StartIndex := Index;
    if (Index <> LB_ERR) and (FDragIndex <> LB_ERR) then
    begin
      Items.Move(FDragIndex, Index);
      InfoList.Move(FDragIndex, Index);
      if FDragIndex < Index then Index := FDragIndex;
      for I := Index to Items.Count - 1 do
        SetListBoxText(I, ListBoxText(ColItems[I]));
      Apply.Enabled := True;
      ItemIndex := StartIndex;
    end;
  end;
end;

procedure TListViewColumns.ColumnListBoxStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FDragIndex := ColumnListBox.ItemIndex;
end;

procedure TListViewColumns.ColumnListBoxEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  FDragIndex := LB_ERR;
end;

procedure TListViewColumns.ColumnListBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with ColumnListBox do
    if ItemAtPos(Point(X, Y), True) = ItemIndex then BeginDrag(False);
end;

procedure TListViewColumns.HWidthBtnClick(Sender: TObject);
begin
  with ColumnListBox do
    if ItemIndex <> -1 then
      with ColItems[ItemIndex] do
      begin
        if Sender = HWidthBtn then FWidthType := ColumnHeaderWidth
        else if Sender = IWidthBtn then FWidthType := ColumnTextWidth
        else if Sender = WidthBtn then
        begin
          FWidth := StrToInt(WidthEdit.Text);
          FWidthType := FWidth;
        end;
        WidthEdit.Enabled := Sender = WidthBtn;
        Apply.Enabled := True;
      end;
end;

procedure TListViewColumns.HelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.


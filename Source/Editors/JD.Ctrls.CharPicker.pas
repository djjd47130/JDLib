unit JD.Ctrls.CharPicker;

(*
  TODO:
  - Make compatible with both TJDFontGlyph and TJDFontGlyphRef.

*)

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls,
  DesignEditors, DesignIntf, ColnEdit,
  JD.FontGlyphs, JD.Graphics, Vcl.Samples.Spin;

type
  TJDGlyphPicker = class(TForm)
    pMain: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblPreview: TLabel;
    Grd: TStringGrid;
    dlgImageFont: TFontDialog;
    pBottom: TPanel;
    cmdOK: TBitBtn;
    cmdCancel: TBitBtn;
    cboFont: TComboBox;
    cboStandardColor: TComboBox;
    chkStandardColor: TCheckBox;
    cboCustomColor: TColorBox;
    Label3: TLabel;
    txtFontSize: TSpinEdit;
    lblFontSize: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrdDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure GrdSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cboFontClick(Sender: TObject);
  private
    FCharFont: TFont;
    FChars: TCharArray;
    FBmp: TBitmap;
    procedure Invalidate; reintroduce;
    function GetChar: String;
    procedure SetChar(const Value: String);
    procedure SetCharFont(const Value: TFont);
    function GridChar(const ACol, ARow: Integer): String;
    function GridIndex(const ACol, ARow: Integer): Integer;
    function CalcRowCount: Integer;
    procedure SelectChar(const Value: String);
    procedure FontChanged(Sender: TObject);
    procedure LoadFonts;
    procedure SetCustomColor(const Value: TColor);
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
    procedure SetSize(const Value: Integer);
    function GetCustomColor: TColor;
    function GetSize: Integer;
    function GetStandardColor: TJDStandardColor;
    function GetUseStandardColor: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Char: String read GetChar write SetChar;
    property CharFont: TFont read FCharFont write SetCharFont;
    property StandardColor: TJDStandardColor read GetStandardColor write SetStandardColor;
    property CustomColor: TColor read GetCustomColor write SetCustomColor;
    property UseStandardColor: Boolean read GetUseStandardColor write SetUseStandardColor;
    property Size: Integer read GetSize write SetSize;
  end;

var
  JDGlyphPicker: TJDGlyphPicker;

procedure Register;

implementation

{$R *.dfm}

{ TJDGlyphPicker }

constructor TJDGlyphPicker.Create(AOwner: TComponent);
begin
  inherited;
  LoadFonts;
  FCharFont:= TFont.Create;
  FCharFont.OnChange:= FontChanged;
  FBmp:= TBitmap.Create;
  pMain.Align:= alClient;
  //TODO: Populate standard colors combo...

end;

destructor TJDGlyphPicker.Destroy;
begin
  FBmp.Free;
  FCharFont.Free;
  inherited;
end;

procedure TJDGlyphPicker.FormShow(Sender: TObject);
begin
  pMain.Align:= alClient;
  FormResize(Sender);
  Invalidate;
end;

procedure TJDGlyphPicker.FormResize(Sender: TObject);
begin
  Grd.ColCount:= CalcRowCount;
end;

procedure TJDGlyphPicker.cboFontClick(Sender: TObject);
begin
  Self.CharFont.Name:= cboFont.Text;
end;

procedure TJDGlyphPicker.LoadFonts;
begin
  cboFont.Items.BeginUpdate;
  try
    cboFont.Items.Assign(Screen.Fonts);
  finally
    cboFont.Items.EndUpdate;
  end;
  cboFont.ItemIndex:= -1;
end;

procedure TJDGlyphPicker.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

function TJDGlyphPicker.CalcRowCount: Integer;
begin
  Result:= Trunc(Grd.ClientWidth / (Grd.DefaultColWidth + 1));
end;

function TJDGlyphPicker.GetChar: String;
begin
  Result:= GridChar(Grd.Col, Grd.Row);
end;

function TJDGlyphPicker.GetCustomColor: TColor;
begin
  Result:= cboCustomColor.Selected;
end;

function TJDGlyphPicker.GetSize: Integer;
begin
  Result:= txtFontSize.Value;
end;

function TJDGlyphPicker.GetStandardColor: TJDStandardColor;
begin
  Result:= TJDStandardColor(cboStandardColor.ItemIndex);
end;

function TJDGlyphPicker.GetUseStandardColor: Boolean;
begin
  Result:= chkStandardColor.Checked;
end;

function TJDGlyphPicker.GridIndex(const ACol, ARow: Integer): Integer;
begin
  //Returns the array index of character which belongs in a given cell
  Result:= (ARow * Grd.ColCount) + ACol;
end;

procedure TJDGlyphPicker.Invalidate;
begin
  //Font has changed, reset to reflect newly selected font
  FBmp.Canvas.Font.Assign(CharFont);
  cboFont.ItemIndex:= cboFont.Items.IndexOf(CharFont.Name);
  lblPreview.Font.Name:= CharFont.Name;

  FChars:= GetFontGlyphs(FBmp.Canvas.Handle);
  Grd.RowCount:= Trunc(Length(FChars) / Grd.ColCount)+1;
  Grd.Repaint;
  SelectChar(lblPreview.Caption);
end;

procedure TJDGlyphPicker.SelectChar(const Value: String);
var
  X: Integer;
  C: System.Char;
  Row, Col: Integer;
begin
  for X := 0 to Length(FChars)-1 do begin
    C:= FChars[X];
    if C = Value then begin

      Row:= Trunc((X) / Grd.ColCount);
      Col:= X - (Row * Grd.ColCount);

      Grd.Col:= Col;
      Grd.Row:= Row;
      Grd.TopRow:= Row;

      Break;
    end;
  end;
end;

procedure TJDGlyphPicker.GrdDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  C: TCanvas;
  Br: TBrush;
  Pn: TPen;
  I: Integer;
  Hex: String;
  R: TRect;
begin
  //Draw character in individual cell
  //State: gdSelected, gdFocused, gdFixed, gdRowSelected, gdHotTrack, gdPressed
  C:= Grd.Canvas;
  Br:= C.Brush;
  Pn:= C.Pen;
  C.Font.Name:= CharFont.Name;
  C.Font.Size:= 30;
  C.Font.Quality:= TFontQuality.fqAntialiased;
  Br.Style:= bsSolid;
  Pn.Style:= psSolid;

  I:= (ARow * Grd.ColCount) + ACol;

  if I < Length(FChars) then begin

    //Font Glyph Image
    if gdSelected in State then begin
      if gdFocused in State then begin
        Pn.Color:= clBlack;
        Br.Color:= clSkyBlue;
      end else begin
        Pn.Color:= clGray;
        Br.Color:= clSkyBlue;
      end;
    end else begin
      if gdHotTrack in State then begin
        Pn.Color:= clGray;
        Br.Color:= clTeal;
      end else begin
        Pn.Color:= clGray;
        Br.Color:= clWhite;
      end;
    end;
    C.FillRect(Rect);
    DrawText(C.Handle, FChars[I], 1, Rect, DT_CENTER or DT_VCENTER);

    //Character Hex Code
    C.Font.Size:= 12;
    C.Font.Name:= 'Tahoma';
    R:= Rect;
    Hex:= '$' + IntToHex(Ord(FChars[I]), 4);
    R.Top:= R.Bottom - C.TextHeight(Hex);
    DrawText(C.Handle, Hex, Length(Hex), R, DT_CENTER or DT_VCENTER);

  end else begin
    //Empty spot, draw blank
    Br.Color:= clWhite;
    Pn.Color:= clWhite;
    C.FillRect(Rect);
  end;

end;

procedure TJDGlyphPicker.GrdSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  I: Integer;
begin
  //User selected a cell in the grid, make sure it's a valid cell
  I:= GridIndex(ACol, ARow);
  CanSelect:= I > -1;
  if CanSelect then
    lblPreview.Caption:= GridChar(ACol, ARow)
  else
    lblPreview.Caption:= ' ';
  //ApplyTest;
end;

function TJDGlyphPicker.GridChar(const ACol, ARow: Integer): String;
var
  I: Integer;
begin
  //Returns the character which belongs in a given cell
  I:= GridIndex(ACol, ARow);
  if I > -1 then Result:= FChars[I] else Result:= ' ';
end;

procedure TJDGlyphPicker.SetChar(const Value: String);
begin
  //Need to re-engineer due to string/char conversion
  if GetChar <> Value then begin
    SelectChar(Value);
    lblPreview.Caption:= Value;
  end;
end;

procedure TJDGlyphPicker.SetCharFont(const Value: TFont);
begin
  FCharFont.Assign(Value);
end;

procedure TJDGlyphPicker.SetCustomColor(const Value: TColor);
begin
  cboCustomColor.Selected:= Value;
end;

procedure TJDGlyphPicker.SetSize(const Value: Integer);
begin
  txtFontSize.Value:= Value;
end;

procedure TJDGlyphPicker.SetStandardColor(const Value: TJDStandardColor);
begin
  cboStandardColor.ItemIndex:= Integer(Value);
end;

procedure TJDGlyphPicker.SetUseStandardColor(const Value: Boolean);
begin
  chkStandardColor.Checked:= Value;
end;



type
  TJDFontGlyphEditor = class(TClassProperty)
  private
    procedure EditJDFontGlyph;
    procedure EditJDFontGlyphRef;
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TJDFontGlyphComponentEditor = class(TComponentEditor)
  private
    procedure ExecEditor;
  protected
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;
  end;

{ TJDFontGlyphEditor }

procedure TJDFontGlyphEditor.EditJDFontGlyphRef;
var
  Frm: TJDGlyphPicker;
  Prop: TJDFontGlyphRef;
begin
  Prop:= TJDFontGlyphRef(Self.GetOrdValue);

  Frm:= TJDGlyphPicker.Create(Application);
  try
    Frm.txtFontSize.Visible:= False;
    Frm.lblFontSize.Visible:= False;
    Frm.CharFont.Name:= Prop.FontName;
    Frm.Char:= Prop.Glyph;
    Frm.UseStandardColor:= Prop.UseStandardColor;
    Frm.StandardColor:= Prop.StandardColor;
    Frm.CustomColor:= Prop.Color;
    if Frm.ShowModal = mrOK then begin
      Prop.FontName:= Frm.CharFont.Name;
      Prop.Glyph:= Frm.Char;
      Prop.UseStandardColor:= Frm.UseStandardColor;
      Prop.StandardColor:= Frm.StandardColor;
      Prop.Color:= Frm.CustomColor;
    end;
  finally
    Frm.Free;
  end;
end;

procedure TJDFontGlyphEditor.EditJDFontGlyph;
var
  Frm: TJDGlyphPicker;
  Prop: TJDFontGlyph;
begin
  Prop:= TJDFontGlyph(Self.GetOrdValue);

  Frm:= TJDGlyphPicker.Create(Application);
  try
    Frm.txtFontSize.Visible:= True;
    Frm.lblFontSize.Visible:= True;
    Frm.CharFont.Assign(Prop.Font);
    Frm.Char:= Prop.Glyph;
    Frm.UseStandardColor:= Prop.UseStandardColor;
    Frm.StandardColor:= Prop.StandardColor;
    Frm.CustomColor:= Prop.Font.Color;
    Frm.Size:= Prop.Font.Size;
    if Frm.ShowModal = mrOK then begin
      Prop.Font.Assign(Frm.CharFont);
      Prop.Glyph:= Frm.Char;
      Prop.UseStandardColor:= Frm.UseStandardColor;
      Prop.StandardColor:= Frm.StandardColor;
      Prop.Font.Color:= Frm.CustomColor;
      Prop.Font.Size:= Frm.Size;
    end;
  finally
    Frm.Free;
  end;
end;

procedure TJDFontGlyphEditor.Edit;
var
  ClassName: String;
begin
  //Initialize the property editor window depending on property type
  ClassName:= GetPropType.TypeData.ClassType.ClassName;
  if SameText(ClassName, 'TJDFontGlyphRef') then begin
    EditJDFontGlyphRef;
  end else
  if SameText(ClassName, 'TJDFontGlyph') then begin
    EditJDFontGlyph;
  end;
end;

function TJDFontGlyphEditor.GetAttributes: TPropertyAttributes;
begin
  //Makes the small button show to the right of the property
  Result := inherited GetAttributes + [paDialog];
end;

{ TJDFontGlyphComponentEditor }

constructor TJDFontGlyphComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TJDFontGlyphComponentEditor.Destroy;
begin

  inherited;
end;

procedure TJDFontGlyphComponentEditor.ExecEditor;
begin
  ShowCollectionEditor(Designer, Component, TJDFontGlyphs(Component).Glyphs, 'Glyphs');
end;

procedure TJDFontGlyphComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TJDFontGlyphComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Glyphs';
  end;
end;

function TJDFontGlyphComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TJDFontGlyphRef), nil, '', TJDFontGlyphEditor);
  RegisterPropertyEditor(TypeInfo(TJDFontGlyph), nil, '', TJDFontGlyphEditor);
  RegisterComponentEditor(TJDFontGlyphs, TJDFontGlyphComponentEditor);
end;

end.

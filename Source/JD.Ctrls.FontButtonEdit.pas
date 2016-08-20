(*
  Component editor for TFontButton control

*)


unit JD.Ctrls.FontButtonEdit;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons,
  DesignEditors, DesignIntf,
  JD.Ctrls.FontButton, Vcl.ComCtrls, Vcl.Samples.Spin,
  JD.Ctrls.FontButtonEditCtrl,
  JD.Graphics;

type
  TfrmFontButtonEditor = class(TForm)
    Panel1: TPanel;
    cmdOK: TBitBtn;
    cmdCancel: TBitBtn;
    dlgImageFont: TFontDialog;
    Panel2: TPanel;
    pMain: TPanel;
    Label1: TLabel;
    txtImageFont: TEdit;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Grd: TStringGrid;
    lblPreview: TLabel;
    dlgColor: TColorDialog;
    GroupBox1: TGroupBox;
    seGrowSize: TSpinEdit;
    cboImagePosition: TComboBox;
    Label4: TLabel;
    Label3: TLabel;
    seDownSize: TSpinEdit;
    chkAutoSize: TCheckBox;
    GroupBox3: TGroupBox;
    chkEnabled: TCheckBox;
    shpColor: TShape;
    GroupBox4: TGroupBox;
    chkStyleCaption: TCheckBox;
    chkStyleImage: TCheckBox;
    chkStyleBack: TCheckBox;
    chkStyleFrame: TCheckBox;
    Label7: TLabel;
    chkTransparent: TCheckBox;
    chkShowFocusRect: TCheckBox;
    cmdTest: TFontButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrdSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GrdDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GrdDblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure PropChange(Sender: TObject);
    procedure shpColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FImageFont: TFont;
    FChars: TCharArray;
    FBtn: TFontButton;
    FBmp: TBitmap;
    function GetImageChar: String;
    procedure SetImageFont(const Value: TFont);
    procedure Invalidate; reintroduce;
    function CalcRowCount: Integer;
    function GridIndex(const ACol, ARow: Integer): Integer;
    function GridChar(const ACol, ARow: Integer): String;
    procedure SetImageChar(const Value: String);
    procedure FontChanged(Sender: TObject);
    procedure SelectChar(const Value: String);
    procedure ApplyTest;
  public
    constructor Create(ABtn: TFontButton); reintroduce;
    procedure LoadFrom(ASrc: TFontButton);
    procedure SaveTo(ADst: TFontButton);
  public
    property ImageChar: String read GetImageChar write SetImageChar;
    property ImageFont: TFont read FImageFont write SetImageFont;
  end;

var
  frmFontButtonEditor: TfrmFontButtonEditor;

procedure Register;

implementation

{$R *.dfm}

{ TfrmFontCharSelector }

constructor TfrmFontButtonEditor.Create(ABtn: TFontButton);
begin
  inherited Create(nil);
  FBtn:= ABtn;
end;

procedure TfrmFontButtonEditor.FormCreate(Sender: TObject);
begin
  FBmp:= TBitmap.Create;
  FImageFont:= TFont.Create;
  FImageFont.OnChange:= FontChanged;
end;

procedure TfrmFontButtonEditor.FormDestroy(Sender: TObject);
begin
  FImageFont.Free;
  FBmp.Free;
end;

procedure TfrmFontButtonEditor.FormResize(Sender: TObject);
begin
  Grd.ColCount:= CalcRowCount;
end;

procedure TfrmFontButtonEditor.FormShow(Sender: TObject);
begin
  pMain.Align:= alClient;
  FormResize(Sender);
  LoadFrom(FBtn);
  Invalidate;
  Grd.SetFocus;
end;

procedure TfrmFontButtonEditor.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

function TfrmFontButtonEditor.GetImageChar: String;
begin
  Result:= GridChar(Grd.Col, Grd.Row);
end;

procedure TfrmFontButtonEditor.SetImageChar(const Value: String);
begin
  //Need to re-engineer due to string/char conversion
  lblPreview.Caption:= Value;
  //SelectChar(Value);
end;

procedure TfrmFontButtonEditor.SelectChar(const Value: String);
var
  X: Integer;
  C: Char;
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

function TfrmFontButtonEditor.GridIndex(const ACol, ARow: Integer): Integer;
begin
  //Returns the array index of character which belongs in a given cell
  Result:= (ARow * Grd.ColCount) + ACol;
end;

procedure TfrmFontButtonEditor.Invalidate;
begin
  //Font has changed, reset to reflect newly selected font
  FBmp.Canvas.Font.Assign(ImageFont);
  txtImageFont.Text:= ImageFont.Name;
  lblPreview.Font.Name:= ImageFont.Name;

  FChars:= GetFontGlyphs(FBmp.Canvas.Handle);
  Grd.RowCount:= Trunc(Length(FChars) / Grd.ColCount)+1;
  Grd.Repaint;
  SelectChar(lblPreview.Caption);
end;

function TfrmFontButtonEditor.GridChar(const ACol, ARow: Integer): String;
var
  I: Integer;
begin
  //Returns the character which belongs in a given cell
  I:= GridIndex(ACol, ARow);
  if I > -1 then Result:= FChars[I] else Result:= ' ';
end;

procedure TfrmFontButtonEditor.SetImageFont(const Value: TFont);
begin
  FImageFont.Assign(Value);
end;

procedure TfrmFontButtonEditor.shpColorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  dlgColor.Color:= shpColor.Brush.Color;
  if dlgColor.Execute then begin
    shpColor.Brush.Color:= dlgColor.Color;
    ApplyTest;
  end;
end;

procedure TfrmFontButtonEditor.BitBtn1Click(Sender: TObject);
begin
  dlgImageFont.Font.Assign(ImageFont);
  if dlgImageFont.Execute then begin
    ImageFont.Assign(dlgImageFont.Font);
  end;
end;

function TfrmFontButtonEditor.CalcRowCount: Integer;
begin
  Result:= Trunc(Grd.ClientWidth / (Grd.DefaultColWidth + 1));
end;

procedure TfrmFontButtonEditor.GrdDblClick(Sender: TObject);
begin
  //User double-clicked grid, invoke OK button click handler
  cmdOK.Click;
end;

procedure TfrmFontButtonEditor.GrdSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
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
  ApplyTest;
end;

procedure TfrmFontButtonEditor.PropChange(Sender: TObject);
begin
  ApplyTest;
end;

procedure TfrmFontButtonEditor.LoadFrom(ASrc: TFontButton);
begin
  FBtn:= ASrc;
  cmdTest.Assign(ASrc);

  chkShowFocusRect.Checked:= ASrc.ShowFocusRect;
  seDownSize.Value:= ASrc.DownSize;
  shpColor.Brush.Color:= ASrc.Color;
  chkEnabled.Checked:= ASrc.Enabled;
  chkStyleCaption.Checked:= scCaption in ASrc.StyleColors;
  chkStyleImage.Checked:= scImage in ASrc.StyleColors;
  chkStyleBack.Checked:= scBack in ASrc.StyleColors;
  chkStyleFrame.Checked:= scFrame in ASrc.StyleColors;

  ImageFont.Assign(ASrc.Image.Font);
  ImageChar:= ASrc.Image.Text;
  seGrowSize.Value:= ASrc.Image.GrowSize;
  chkAutoSize.Checked:= ASrc.Image.AutoSize;

end;

procedure TfrmFontButtonEditor.SaveTo(ADst: TFontButton);
begin
  ADst.ShowFocusRect:= chkShowFocusRect.Checked;
  ADst.DownSize:= seDownSize.Value;
  ADst.Color:= shpColor.Brush.Color;
  ADst.Enabled:= chkEnabled.Checked;
  ADst.StyleColors:= [];
  if chkStyleCaption.Checked then
    ADst.StyleColors:= ADst.StyleColors + [scCaption];
  if chkStyleImage.Checked then
    ADst.StyleColors:= ADst.StyleColors + [scImage];
  if chkStyleBack.Checked then
    ADst.StyleColors:= ADst.StyleColors + [scBack];
  if chkStyleFrame.Checked then
    ADst.StyleColors:= ADst.StyleColors + [scFrame];

  ADst.Image.Font.Assign(ImageFont);
  ADst.Image.GrowSize:= seGrowSize.Value;
  ADst.Image.Text:= lblPreview.Caption;
  ADst.Image.AutoSize:= chkAutoSize.Checked;

end;

procedure TfrmFontButtonEditor.ApplyTest;
begin
  SaveTo(cmdTest);
end;

procedure TfrmFontButtonEditor.GrdDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
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
  C.Font.Name:= ImageFont.Name;
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

////////////////////////////////////////////////////////////////////////////////

{ TFontButtonEditor }

type
  TFontButtonEditor = class(TDefaultEditor)
  private
    procedure ExecEditor;
    function ConvertFromControl: Boolean;
  protected
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;
  end;

constructor TFontButtonEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;
end;

destructor TFontButtonEditor.Destroy;
begin
  inherited;
end;

function TFontButtonEditor.ConvertFromControl: Boolean;
var
  F: TfrmSelectControl;
begin
  //Show dialog prompting list of all controls matching given AClass
  F:= TfrmSelectControl.Create(TFontButton(Component));
  try
    Result:= F.ShowModal = mrOK;
  finally
    F.Free;
  end;
end;

procedure TFontButtonEditor.ExecuteVerb(Index: Integer);
begin
  //Executes one of the items in the right-click context menu on control
  case Index of
    0: begin
      ExecEditor;
    end;
    1: begin
      MessageDlg('Font Button Control - by RM Innovation', mtInformation, [mbOK], 0);
    end;
    2: begin
      //Convert from TButton
      ConvertFromControl;
    end;
  end;
  Designer.Modified;
end;

function TFontButtonEditor.GetVerb(Index: Integer): String;
begin
  //Returns menu item caption for right-click context menu on control
  case Index of
    0: Result:= '&Edit Font Button';
    1: Result:= '&About Font Button';
    2: Result:= '&Convert from Control';
  end;
end;

function TFontButtonEditor.GetVerbCount: Integer;
begin
  //Returns number of menu items on right-click context menu on control
  Result:= 3;
end;

procedure TFontButtonEditor.ExecEditor;
var
  F: TfrmFontButtonEditor;
begin
  //Executes the actual component editor window to modify properties
  F:= TfrmFontButtonEditor.Create(TFontButton(Component));
  try
    case F.ShowModal of
      mrOK: begin
        F.SaveTo(TFontButton(Component));
      end;
      else begin
        //Cancelled
      end;
    end;
  finally
    F.Free;
  end;
end;


procedure Register;
begin
  RegisterComponentEditor(TFontButton, TFontButtonEditor);
end;

end.

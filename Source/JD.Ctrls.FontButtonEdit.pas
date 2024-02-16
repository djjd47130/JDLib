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
  JD.Graphics, JD.FontGlyphs;

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
    GroupBox1: TGroupBox;
    cboImagePosition: TComboBox;
    chkAutoSize: TCheckBox;
    Panel3: TPanel;
    GroupBox4: TGroupBox;
    chkStyleCaption: TCheckBox;
    chkStyleImage: TCheckBox;
    chkStyleBack: TCheckBox;
    chkStyleFrame: TCheckBox;
    Label6: TLabel;
    Label5: TLabel;
    cboStandardColor: TComboBox;
    GroupBox2: TGroupBox;
    lblGrowSize: TLabel;
    lblDownSize: TLabel;
    seGrowSize: TSpinEdit;
    seDownSize: TSpinEdit;
    GroupBox5: TGroupBox;
    chkAnchorLeft: TCheckBox;
    chkAnchorTop: TCheckBox;
    chkAnchorRight: TCheckBox;
    chkAnchorBottom: TCheckBox;
    Label7: TLabel;
    cboDrawStyle: TComboBox;
    lblMargin: TLabel;
    seMargin: TSpinEdit;
    lblSpacing: TLabel;
    seSpacing: TSpinEdit;
    Label10: TLabel;
    txtCaptionFont: TEdit;
    BitBtn2: TBitBtn;
    dlgCaptionFont: TFontDialog;
    Panel4: TPanel;
    GroupBox3: TGroupBox;
    chkEnabled: TCheckBox;
    chkShowFocusRect: TCheckBox;
    chkVisible: TCheckBox;
    chkShowHint: TCheckBox;
    txtHint: TEdit;
    Label11: TLabel;
    txtCaption: TEdit;
    GroupBox6: TGroupBox;
    cboHelpType: TComboBox;
    seHelpContextID: TSpinEdit;
    lblContextID: TLabel;
    Label3: TLabel;
    txtHelpKeyword: TEdit;
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
    procedure BitBtn2Click(Sender: TObject);
    procedure txtHintChange(Sender: TObject);
  private
    FImageFont: TFont;
    FCaptionFont: TFont;
    FChars: TCharArray;
    FBtn: TJDFontButton;
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
    procedure SetCaptionFont(const Value: TFont);
  public
    constructor Create(ABtn: TJDFontButton); reintroduce;
    procedure LoadFrom(ASrc: TJDFontButton);
    function SaveTo(ADst: TJDFontButton): Boolean;
  public
    property ImageChar: String read GetImageChar write SetImageChar;
    property ImageFont: TFont read FImageFont write SetImageFont;
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
  end;

var
  frmFontButtonEditor: TfrmFontButtonEditor;

procedure Register;

implementation

{$R *.dfm}

{ TfrmFontCharSelector }

constructor TfrmFontButtonEditor.Create(ABtn: TJDFontButton);
begin
  inherited Create(nil);
  FBtn:= ABtn;
end;

procedure TfrmFontButtonEditor.FormCreate(Sender: TObject);
begin
  FBmp:= TBitmap.Create;
  FImageFont:= TFont.Create;
  FImageFont.OnChange:= FontChanged;
  FCaptionFont:= TFont.Create;
  FCaptionFont.OnChange:= FontChanged;

  lblGrowSize.Align:= alTop;
  seGrowSize.Align:= alTop;
  lblDownSize.Align:= alTop;
  seDownSize.Align:= alTop;
  lblMargin.Align:= alTop;
  seMargin.Align:= alTop;
  lblSpacing.Align:= alTop;
  seSpacing.Align:= alTop;

  seHelpContextID.Align:= alTop;

end;

procedure TfrmFontButtonEditor.FormDestroy(Sender: TObject);
begin
  FCaptionFont.Free;
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
  //Grd.SetFocus;
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
  txtCaptionFont.Text:= CaptionFont.Name;
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

procedure TfrmFontButtonEditor.txtHintChange(Sender: TObject);
begin
  Self.ApplyTest;
end;

procedure TfrmFontButtonEditor.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.Assign(Value);
end;

procedure TfrmFontButtonEditor.BitBtn1Click(Sender: TObject);
begin
  dlgImageFont.Font.Assign(ImageFont);
  if dlgImageFont.Execute then begin
    ImageFont.Assign(dlgImageFont.Font);
    ApplyTest;
  end;
end;

procedure TfrmFontButtonEditor.BitBtn2Click(Sender: TObject);
begin
  dlgCaptionFont.Font.Assign(CaptionFont);
  if dlgCaptionFont.Execute then begin
    CaptionFont.Assign(dlgCaptionFont.Font);
    ApplyTest;
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

procedure TfrmFontButtonEditor.LoadFrom(ASrc: TJDFontButton);
begin
  FBtn:= ASrc;
  //cmdTest.Assign(ASrc);

  chkShowFocusRect.Checked:= ASrc.ShowFocusRect;
  seDownSize.Value:= ASrc.DownSize;

  chkEnabled.Checked:= ASrc.Enabled;
  chkVisible.Checked:= ASrc.Visible;
  chkShowHint.Checked:= ASrc.ShowHint;
  txtHint.Text:= ASrc.Hint;
  txtCaption.Text:= ASrc.Text;

  chkStyleCaption.Checked:= scCaption in ASrc.StyleColors;
  chkStyleImage.Checked:= scImage in ASrc.StyleColors;
  chkStyleBack.Checked:= scBack in ASrc.StyleColors;
  chkStyleFrame.Checked:= scFrame in ASrc.StyleColors;

  chkAnchorLeft.Checked:= akLeft in ASrc.Anchors;
  chkAnchorTop.Checked:= akTop in ASrc.Anchors;
  chkAnchorRight.Checked:= akRight in ASrc.Anchors;
  chkAnchorBottom.Checked:= akBottom in ASrc.Anchors;

  CaptionFont.Assign(ASrc.Font);
  ImageFont.Assign(ASrc.Image.Font);
  ImageChar:= ASrc.Image.Text;
  seGrowSize.Value:= ASrc.Image.GrowSize;
  chkAutoSize.Checked:= ASrc.Image.AutoSize;

  if ASrc.Image.UseStandardColor then begin
  cboStandardColor.ItemIndex:= Integer(ASrc.Image.StandardColor)+1;
  end else begin
    cboStandardColor.ItemIndex:= 0;
  end;

  cboImagePosition.ItemIndex:= Integer(ASrc.ImagePosition);

  cboDrawStyle.ItemIndex:= Integer(ASrc.DrawStyle);

  cboHelpType.ItemIndex:= Integer(ASrc.HelpType);
  txtHelpKeyword.Text:= ASrc.HelpKeyword;
  seHelpContextID.Value:= ASrc.HelpContext;

  seMargin.Value:= ASrc.Margin;
  seSpacing.Value:= ASrc.Spacing;

end;

function SameFonts(AFont1, AFont2: TFont): Boolean;
begin
  Result:= SameText(AFont1.Name, AFont2.Name);
  if Result then
    Result:= AFont1.Size = AFont2.Size;
  if Result then
    Result:= AFont1.Height = AFont2.Height;
  if Result then
    Result:= AFont1.Charset = AFont2.Charset;
  if Result then
    Result:= AFont1.Color = AFont2.Color;
  if Result then
    Result:= AFont1.Orientation = AFont2.Orientation;
  if Result then
    Result:= AFont1.Pitch = AFont2.Pitch;
  if Result then
    Result:= AFont1.Quality = AFont2.Quality;
  if Result then
    Result:= AFont1.Style = AFont2.Style;

end;

function TfrmFontButtonEditor.SaveTo(ADst: TJDFontButton): Boolean;
  function SelAnchors: TAnchors;
  begin
    Result:= [];
    if chkAnchorLeft.Checked then
      Result:= Result + [akLeft];
    if chkAnchorTop.Checked then
      Result:= Result + [akTop];
    if chkAnchorRight.Checked then
      Result:= Result + [akRight];
    if chkAnchorBottom.Checked then
      Result:= Result + [akBottom];
  end;
  function SelStyleColors: TJDFontButtonStyleColors;
  begin
    Result:= [];
    if chkStyleCaption.Checked then
      Result:= Result + [scCaption];
    if chkStyleImage.Checked then
      Result:= Result + [scImage];
    if chkStyleBack.Checked then
      Result:= Result + [scBack];
    if chkStyleFrame.Checked then
      Result:= Result + [scFrame];
  end;
  function SelDrawStyle: TJDFontButtonDrawStyle;
  begin
    Result:= TJDFontButtonDrawStyle(cboDrawStyle.ItemIndex);
  end;
  function SelHelpType: THelpType;
  begin
    Result:= THelpType(cboHelpType.ItemIndex);
  end;
  function SelImagePosition: TJDFontButtonImgPosition;
  begin
    Result:= TJDFontButtonImgPosition(cboImagePosition.ItemIndex);
  end;
  function SelStandardColor: TJDStandardColor;
  begin
    case cboStandardColor.ItemIndex of
      -1, 0: begin
        Result:= fcNeutral;
      end;
      else begin
        Result:= TJDStandardColor(cboStandardColor.ItemIndex-1);
      end;
    end;
  end;
  function SelUseStandardColor: Boolean;
  begin
    Result:= cboStandardColor.ItemIndex > 0;
  end;
begin
  Result:= False;

  if not SameFonts(ADst.Font, CaptionFont) then begin
    ADst.Font.Assign(CaptionFont);
    Result:= True;
  end;

  if not SameFonts(ADst.Image.Font, ImageFont) then begin
    ADst.Image.Font.Assign(ImageFont);
    Result:= True;
  end;

  if ADst.Image.StandardColor <> SelStandardColor then begin
    ADst.Image.StandardColor:= SelStandardColor;
    Result:= True;
  end;

  if SelUseStandardColor <> ADst.Image.UseStandardColor then begin
    ADst.Image.UseStandardColor:= SelUseStandardColor;
    Result:= True;
  end;

  if chkShowFocusRect.Checked <> ADst.ShowFocusRect then begin
    ADst.ShowFocusRect:= chkShowFocusRect.Checked;
    Result:= True;
  end;

  if seDownSize.Value <> ADst.DownSize then begin
    ADst.DownSize:= seDownSize.Value;
    Result:= True;
  end;

  if chkVisible.Checked <> ADst.Visible then begin
    ADst.Visible:= chkVisible.Checked;
    Result:= True;
  end;

  if chkEnabled.Checked <> ADst.Enabled then begin
    ADst.Enabled:= chkEnabled.Checked;
    Result:= True;
  end;

  if chkShowHint.Checked <> ADst.ShowHint then begin
    ADst.ShowHint:= chkShowHint.Checked;
    Result:= True;
  end;

  if txtHint.Text <> ADst.Hint then begin
    ADst.Hint:= txtHint.Text;
    Result:= True;
  end;

  if txtCaption.Text <> ADst.Text then begin
    ADst.Text:= txtCaption.Text;
    Result:= True;
  end;

  if seGrowSize.Value <> ADst.Image.GrowSize then begin
    ADst.Image.GrowSize:= seGrowSize.Value;
    Result:= True;
  end;

  if lblPreview.Caption <> ADst.Image.Text then begin
    ADst.Image.Text:= lblPreview.Caption;
    Result:= True;
  end;

  if chkAutoSize.Checked <> ADst.Image.AutoSize then begin
    ADst.Image.AutoSize:= chkAutoSize.Checked;
    Result:= True;
  end;

  if SelDrawStyle <> ADst.DrawStyle then begin
    ADst.DrawStyle:= SelDrawStyle;
    Result:= True;
  end;

  if seHelpContextID.Value <> ADst.HelpContext then begin
    ADst.HelpContext:= seHelpContextID.Value;
    Result:= True;
  end;

  if txtHelpKeyword.Text <> ADst.HelpKeyword then begin
    ADst.HelpKeyword:= txtHelpKeyword.Text;
    Result:= True;
  end;

  if SelHelpType <> ADst.HelpType then begin
    ADst.HelpType:= SelHelpType;
    Result:= True;
  end;

  if seMargin.Value <> ADst.Margin then begin
    ADst.Margin:= seMargin.Value;
    Result:= True;
  end;

  if seSpacing.Value <> ADst.Spacing then begin
    ADst.Spacing:= seSpacing.Value;
    Result:= True;
  end;

  if SelImagePosition <> ADst.ImagePosition then begin
    ADst.ImagePosition:= SelImagePosition;
    Result:= True;
  end;

  if ADst.StyleColors <> SelStyleColors then begin
    ADst.StyleColors:= SelStyleColors;
    Result:= True;
  end;

  if ADst.Anchors <> SelAnchors then begin
    ADst.Anchors:= SelAnchors;
    Result:= True;
  end;

end;

procedure TfrmFontButtonEditor.ApplyTest;
begin
  //SaveTo(cmdTest);
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
  F:= TfrmSelectControl.Create(TJDFontButton(Component));
  try
    Result:= F.ShowModal = mrOK;
    if Result then
      Designer.Modified;
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
      MessageDlg('Font Button Control - by Jerry Dodge', mtInformation, [mbOK], 0);
    end;
    2: begin
      //Convert from TButton
      ConvertFromControl;
    end;
  end;
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
  F:= TfrmFontButtonEditor.Create(TJDFontButton(Component));
  try
    case F.ShowModal of
      mrOK: begin
        if F.SaveTo(TJDFontButton(Component)) then
          Designer.Modified;
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
  RegisterComponentEditor(TJDFontButton, TFontButtonEditor);
end;

end.

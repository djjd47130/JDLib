unit JD.Ctrls.FontButtonEditCtrl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  JD.Ctrls.FontButton;

type
  TfrmSelectControl = class(TForm)
    lstControls: TListBox;
    cmdOK: TBitBtn;
    cmdCancel: TBitBtn;
    lblPrompt: TLabel;
    pOptions: TPanel;
    chkIncludeInherited: TCheckBox;
    chkCurrentParent: TCheckBox;
    cboControlClass: TComboBox;
    Label1: TLabel;
    procedure OptionChanged(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    FBtn: TFontButton;
    FSrc: TControl;
    function GetSelectedControl: String;
    procedure SetSelectedControl(const Value: String);
    procedure ListControls(AParent: TControl; AList: TStrings;
      AClass: TControlClass; const IncludeInherited: Boolean);
    function GetControlClass: TControlClass;
    procedure SetControlClass(const Value: TControlClass);
    procedure ApplyButton;
    procedure ApplySpeedButton;
    procedure ApplyBitBtn;
  public
    constructor Create(ABtn: TFontButton); reintroduce;
    property ControlClass: TControlClass read GetControlClass write SetControlClass;
    property SelectedControl: String read GetSelectedControl write SetSelectedControl;
  end;

var
  frmSelectControl: TfrmSelectControl;

implementation

{$R *.dfm}

constructor TfrmSelectControl.Create(ABtn: TFontButton);
begin
  inherited Create(nil);
  FBtn:= ABtn;
  OptionChanged(nil);
end;

procedure TfrmSelectControl.cmdOKClick(Sender: TObject);
var
  F: TCustomForm;
begin
  F:= GetParentForm(FBtn);
  FSrc:= TControl(F.FindComponent(SelectedControl));
  if Assigned(FSrc) then begin

    FBtn.Image.Font.Name:= 'RMPicons';
    //FBtn.Image.Text:= ' ';

    FBtn.Parent:= FSrc.Parent;
    //FBtn.Name:= FSrc.Name + '_FontButton';
    FBtn.Left:= FSrc.Left + 8;
    FBtn.Top:= FSrc.Top + 8;
    FBtn.Width:= FSrc.Width;
    FBtn.Height:= FSrc.Height;
    FBtn.Align:= FSrc.Align;
    FBtn.AlignWithMargins:= FSrc.AlignWithMargins;
    FBtn.Anchors:= FSrc.Anchors;
    FBtn.BringToFront;
    FBtn.CustomHint:= FSrc.CustomHint;
    FBtn.Enabled:= FSrc.Enabled;
    FBtn.Visible:= FSrc.Visible;
    FBtn.Cursor:= FSrc.Cursor;
    FBtn.HelpType:= FSrc.HelpType;
    FBtn.HelpKeyword:= FSrc.HelpKeyword;
    FBtn.HelpContext:= FSrc.HelpContext;
    FBtn.Hint:= FSrc.Hint;
    FBtn.ParentCustomHint:= FSrc.ParentCustomHint;
    FBtn.ShowHint:= FSrc.ShowHint;
    //FBtn.StyleColors:= [scCaption, scImage, scBack, scFrame];
    FBtn.Tag:= FSrc.Tag;
    FBtn.Image.Font.Size:= 12;

    if FSrc is TButton then
      ApplyButton
    else if FSrc is TSpeedButton then
      ApplySpeedButton
    else if FSrc is TBitBtn then
      ApplyBitBtn
    else begin
      //Unrecognized control
    end;

    ModalResult:= mrOK;
    Close;
  end else begin
    MessageDlg('Could not find control.', mtError, [mbOK], 0);
  end;
end;

procedure TfrmSelectControl.ApplyButton;
var
  B: TButton;
begin
  B:= TButton(FSrc);
  FBtn.Text:= B.Caption;

  FBtn.Margin:= DEFAULT_MARGIN;
  FBtn.Spacing:= DEFAULT_SPACING;
  FBtn.Text:= B.Caption;
  FBtn.ModalResult:= B.ModalResult;
  FBtn.Cancel:= B.Cancel;
  FBtn.Font.Assign(B.Font);
  FBtn.DoubleBuffered:= B.DoubleBuffered;
  FBtn.ImagePosition:= fpImgLeft;
  FBtn.ParentDoubleBuffered:= B.ParentDoubleBuffered;
  FBtn.TabOrder:= B.TabOrder;
  FBtn.TabStop:= B.TabStop;
  FBtn.DrawStyle:= fdThemed;

  FBtn.OnClick:= B.OnClick;
  FBtn.OnContextPopup:= B.OnContextPopup;
  FBtn.OnEnter:= B.OnEnter;
  FBtn.OnExit:= B.OnExit;
  FBtn.OnKeyDown:= B.OnKeyDown;
  FBtn.OnKeyPress:= B.OnKeyPress;
  FBtn.OnKeyUp:= B.OnKeyUp;
  FBtn.OnMouseDown:= B.OnMouseDown;
  FBtn.OnMouseEnter:= B.OnMouseEnter;
  FBtn.OnMouseLeave:= B.OnMouseLeave;
  FBtn.OnMouseMove:= B.OnMouseMove;
  FBtn.OnMouseUp:= B.OnMouseUp;

end;

procedure TfrmSelectControl.ApplySpeedButton;
var
  B: TSpeedButton;
begin
  B:= TSpeedButton(FSrc);
  FBtn.Text:= B.Caption;

  FBtn.Margin:= B.Margin;
  if B.Spacing = -1 then
    FBtn.Spacing:= DEFAULT_SPACING
  else
    FBtn.Spacing:= B.Spacing;
  FBtn.Text:= B.Caption;
  FBtn.Font.Assign(B.Font);
  FBtn.ImagePosition:= fpImgLeft;
  FBtn.TabStop:= False;
  if B.Flat then
    FBtn.DrawStyle:= TFontButtonDrawStyle.fdHybrid
  else
    FBtn.DrawStyle:= TFontButtonDrawStyle.fdThemed;

  if B.Caption = '' then
    FBtn.ImagePosition:= fpImgOnly
  else begin
    if Assigned(B.Glyph) then begin
      FBtn.Image.Font.Size:= B.Glyph.Height - 4; //NEED BETTER FORMULA HERE
      case B.Layout of
        blGlyphLeft: FBtn.ImagePosition:= fpImgLeft;
        blGlyphRight: FBtn.ImagePosition:= fpImgRight;
        blGlyphTop: FBtn.ImagePosition:= fpImgTop;
        blGlyphBottom: FBtn.ImagePosition:= fpImgBottom;
      end;
    end else begin
      FBtn.ImagePosition:= fpImgNone;
    end;
  end;

  FBtn.OnClick:= B.OnClick;
  FBtn.OnMouseDown:= B.OnMouseDown;
  FBtn.OnMouseEnter:= B.OnMouseEnter;
  FBtn.OnMouseLeave:= B.OnMouseLeave;
  FBtn.OnMouseMove:= B.OnMouseMove;
  FBtn.OnMouseUp:= B.OnMouseUp;

end;

procedure TfrmSelectControl.ApplyBitBtn;
var
  B: TBitBtn;
begin
  B:= TBitBtn(FSrc);
  FBtn.Text:= B.Caption;

  FBtn.Margin:= B.Margin;
  if B.Spacing = -1 then
    FBtn.Spacing:= DEFAULT_SPACING
  else
    FBtn.Spacing:= B.Spacing;
  FBtn.Text:= B.Caption;
  FBtn.ModalResult:= B.ModalResult;
  FBtn.Cancel:= B.Cancel;
  FBtn.Font.Assign(B.Font);
  FBtn.DoubleBuffered:= B.DoubleBuffered;
  FBtn.ImagePosition:= fpImgLeft;
  FBtn.ParentDoubleBuffered:= B.ParentDoubleBuffered;
  FBtn.TabOrder:= B.TabOrder;
  FBtn.TabStop:= B.TabStop;
  FBtn.DrawStyle:= fdThemed;

  case B.Kind of
    bkCustom: begin
      //Keep as-is
    end;
    bkOK: begin
      FBtn.ModalResult:= mrOK;
      FBtn.Text:= 'OK';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clGreen;
      FBtn.Image.Text:= '';  //Check
      FBtn.Default:= True;
      FBtn.Cancel:= False;
    end;
    bkCancel: begin
      FBtn.ModalResult:= mrCancel;
      FBtn.Text:= 'Cancel';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clRed;
      FBtn.Image.Text:= '';  //X
      FBtn.Default:= False;
      FBtn.Cancel:= True;
    end;
    bkHelp: begin
      FBtn.ModalResult:= mrNone;
      FBtn.Text:= 'Help';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clBlue;
      FBtn.Image.Text:= '';  //?
      FBtn.Default:= False;
      FBtn.Cancel:= False;
    end;
    bkYes: begin
      FBtn.ModalResult:= mrYes;
      FBtn.Text:= 'Yes';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clGreen;
      FBtn.Image.Text:= '';  //Check
      FBtn.Default:= True;
      FBtn.Cancel:= False;
    end;
    bkNo: begin
      FBtn.ModalResult:= mrNo;
      FBtn.Text:= 'No';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clRed;
      FBtn.Image.Text:= '';  //X
      FBtn.Default:= False;
      FBtn.Cancel:= True;
    end;
    bkClose: begin
      FBtn.ModalResult:= mrClose;
      FBtn.Text:= 'Close';
      FBtn.StyleColors:= FBtn.StyleColors - [scImage];
      FBtn.Image.Font.Color:= clBlue;
      FBtn.Image.Text:= '';  //Power
      FBtn.Default:= False;
      FBtn.Cancel:= True;
    end;
    bkAbort: begin

    end;
    bkRetry: begin

    end;
    bkIgnore: begin

    end;
    bkAll: begin

    end;
  end;


  if B.Caption = '' then
    FBtn.ImagePosition:= fpImgOnly
  else begin
    if Assigned(B.Glyph) then begin
      FBtn.Image.Font.Size:= B.Glyph.Height - 4; //NEED BETTER FORMULA HERE
      case B.Layout of
        blGlyphLeft: FBtn.ImagePosition:= fpImgLeft;
        blGlyphRight: FBtn.ImagePosition:= fpImgRight;
        blGlyphTop: FBtn.ImagePosition:= fpImgTop;
        blGlyphBottom: FBtn.ImagePosition:= fpImgBottom;
      end;
    end else begin
      FBtn.ImagePosition:= fpImgNone;
    end;
  end;

  FBtn.OnClick:= B.OnClick;
  FBtn.OnContextPopup:= B.OnContextPopup;
  FBtn.OnEnter:= B.OnEnter;
  FBtn.OnExit:= B.OnExit;
  FBtn.OnKeyDown:= B.OnKeyDown;
  FBtn.OnKeyPress:= B.OnKeyPress;
  FBtn.OnKeyUp:= B.OnKeyUp;
  FBtn.OnMouseDown:= B.OnMouseDown;
  FBtn.OnMouseEnter:= B.OnMouseEnter;
  FBtn.OnMouseLeave:= B.OnMouseLeave;
  FBtn.OnMouseMove:= B.OnMouseMove;
  FBtn.OnMouseUp:= B.OnMouseUp;

end;

function TfrmSelectControl.GetControlClass: TControlClass;
var
  CS: String;
begin
  CS:= cboControlClass.Text;
  if SameText(CS, 'TButton') then
    Result:= TButton
  else if SameText(CS, 'TSpeedButton') then
    Result:= TSpeedButton
  else if SameText(CS, 'TBitBtn') then
    Result:= TBitBtn
  else
    Result:= TCustomButton;
end;

procedure TfrmSelectControl.SetControlClass(const Value: TControlClass);
begin
  if Value = TButton then
    cboControlClass.ItemIndex:= cboControlClass.Items.IndexOf('TButton')
  else if Value = TSpeedButton then
    cboControlClass.ItemIndex:= cboControlClass.Items.IndexOf('TSpeedButton')
  else if Value = TSpeedButton then
    cboControlClass.ItemIndex:= cboControlClass.Items.IndexOf('TBitBtn')
  else
    cboControlClass.ItemIndex:= -1;
  OptionChanged(nil);
end;

function TfrmSelectControl.GetSelectedControl: String;
begin
  if lstControls.ItemIndex >= 0 then
    Result:= lstControls.Items[lstControls.ItemIndex]
  else
    Result:= '';
end;

procedure TfrmSelectControl.SetSelectedControl(const Value: String);
begin
  lstControls.ItemIndex:= lstControls.Items.IndexOf(Value);
end;

procedure TfrmSelectControl.ListControls(AParent: TControl; AList: TStrings;
  AClass: TControlClass; const IncludeInherited: Boolean);
var
  X: Integer;
  C: TControl;
begin
  if AParent is TWinControl then begin
    for X := 0 to TWinControl(AParent).ControlCount-1 do begin
      C:= TWinControl(AParent).Controls[X];
      if C is AClass then begin
        AList.Add(C.Name);
      end else begin
        if (C is TWinControl) then begin
          ListControls(TWinControl(C), AList, AClass, IncludeInherited);
        end;
      end;
    end;
  end;
end;

procedure TfrmSelectControl.OptionChanged(Sender: TObject);
var
  C: TControlClass;
begin
  lstControls.Items.BeginUpdate;
  try
    lstControls.Items.Clear;
    C:= Self.ControlClass;
    if chkCurrentParent.Checked then begin
      ListControls(FBtn.Parent, lstControls.Items, C, chkIncludeInherited.Checked);
    end else begin
      ListControls(GetParentForm(FBtn), lstControls.Items, C, chkIncludeInherited.Checked);
    end;
  finally
    lstControls.Items.EndUpdate;
  end;
  if lstControls.Items.Count > 0 then
    lstControls.ItemIndex:= 0;
end;

end.

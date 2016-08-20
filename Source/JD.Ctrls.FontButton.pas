(*
  TFontButton - custom control encapsulating a button with custom effects
    Uses font (vector) glyphs instead of bitmaps or other image types
    Allows for scalable lightweight buttons

  TODO:
  - Fix design-time artifacts drawn in larger controls
  - Arrange properties in appropriate order
  - Finish component editor
  - Properly scale image/caption
    - DPI scaling when set to 125%
  - Fix autosizing due to new rect calculations
  - Fix centering when Margin = -1
  - Implement centering when Spacing = -1
  - Add option to not move text when hovering
    - Actually "CaptionGrow" property needed
  - Fix "ImageGrow" property (always enabled?)

*)

unit JD.Ctrls.FontButton;

//DO NOT ENABLE!!!
{    $DEFINE BUF_BMP}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Forms, Vcl.Styles, Vcl.Themes,
  Vcl.Dialogs;

const
  WM_COLORCHANGE = WM_USER + 42;

type
  TFontButtonImgPosition = (fpImgTop, fpImgBottom, fpImgLeft, fpImgRight, fpImgOnly, fpImgNone);

  TFontButtonState = (fsDisabled, fsFocused, fsHot, fsNormal, fsPressed);

  TFontButtonStyleColor = (scCaption, scImage, scBack, scFrame);
  TFontButtonStyleColors = set of TFontButtonStyleColor;

  TFontButtonDrawStyle = (fdThemed, fdTransparent, fdHybrid);

  TFontButtonKind = (fkCustom, fkOK, fkCancel, fkClose, fkClear, fkEdit, fkSave, fkAdd,
    fkDelete, fkInfo, fkHelp, fkPrint, fkPrintTag, fkCalc, fkRefresh, fkView, fkMerge,
    fkEmail, fkCloseX, fkUndo);

  TFontButtonColor = (fcNeutral, fcBlue, fcGreen, fcRed, fcYellow, fcOrange);

  TFontButtonColors = array[TFontButtonColor] of TColor;

  TFontButtonSubTextStyle = (fsNone, fsOpposite, fsBelow);

  TMessageComponent = class(TComponent)
  private
    FHandle: HWND;
  protected
    procedure WndMethod(var Message: TMessage); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Handle: HWND read FHandle;
  end;

  TColorManager = class(TObject)
  private
    FBaseColor: TColor;
    FColors: TFontButtonColors;
    FIsBaseDark: Boolean;
    FComponents: TObjectList<TMessageComponent>;
    FControls: TObjectList<TWinControl>;
    procedure SetBaseColor(const Value: TColor);
    function GetColor(Clr: TFontButtonColor): TColor;
    procedure SetColor(Clr: TFontButtonColor; const Value: TColor);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invalidate;
    procedure RegisterComponent(AComponent: TMessageComponent);
    procedure UnregisterComponent(AComponent: TMessageComponent);
    procedure RegisterControl(AControl: TWinControl);
    procedure UnregisterControl(AControl: TWinControl);
  public
    property IsBaseDark: Boolean read FIsBaseDark;
    property BaseColor: TColor read FBaseColor write SetBaseColor;
    property Color[Clr: TFontButtonColor]: TColor read GetColor write SetColor;
  end;


const
  DEFAULT_WIDTH = 100;
  DEFAULT_HEIGHT = 30;
  DEFAULT_COLOR = clBtnFace;
  DEFAULT_IMAGE_POSITION = fpImgLeft;
  DEFAULT_DOWN_SIZE = 3;
  DEFAULT_STYLE_COLORS = [scCaption, scBack, scFrame];
  DEFAULT_SHOW_FOCUS_RECT = False;
  DEFAULT_SHOW_GUIDES = False;
  DEFAULT_SPACING = 4;
  DEFAULT_MARGIN = 4;
  DEFAULT_MODAL_RESULT = mrNone;
  DEFAULT_PARENT_COLOR_OVERRIDE = False;
  DEFAULT_TAB_STOP = True;
  DEFAULT_DEFAULT = False;
  DEFAULT_CANCEL = False;
  DEFAULT_DRAW_STYLE = fdThemed;
  DEFAULT_ENABLED = True;
  DEFAULT_KIND = fkCustom;
  DEFAULT_SUB_TEXT_STYLE = fsNone;
  DEFAULT_SUB_TEXT = '';
  DEFAULT_SUB_TEXT_COLOR = clGray;

  DEFAULT_IMAGE_FONT = 'RMPicons';
  DEFAULT_IMAGE_QUALITY = fqAntialiased;
  DEFAULT_IMAGE_SIZE = 16;
  DEFAULT_IMAGE_TEXT = '';
  DEFAULT_IMAGE_AUTO_SIZE = False;
  DEFAULT_IMAGE_GROW_SIZE = 3;
  DEFAULT_IMAGE_STANDARD_COLOR = fcNeutral;
  DEFAULT_IMAGE_USE_STANDARD_COLOR = True;

  DEFAULT_FRAME_SIZE = 1;
  DEFAULT_FRAME_ROUND = 8;
  DEFAULT_FRAME_COLOR = clBlack;
  DEFAULT_FRAME_SHOW_HOVER = True;
  DEFAULT_FRAME_SHOW_ALWAYS = True;

const
  CLR_DK_BLUE = clNavy;
  CLR_BLUE = clBlue;

type
  TFontButtonImage = class;
  TFontButton = class;

  TFontButtonImage = class(TPersistent)
  private
    FOwner: TFontButton;
    FFont: TFont;
    FText: TCaption;
    FAutoSize: Boolean;
    FGrowSize: Integer;
    FStandardColor: TFontButtonColor;
    FUseStandardColor: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetText(const Value: TCaption);
    procedure SetFont(const Value: TFont);
    procedure SetAutoSize(const Value: Boolean);
    procedure SetGrowSize(const Value: Integer);
    procedure SetStandardColor(const Value: TFontButtonColor);
    procedure SetUseStandardColor(const Value: Boolean);
  public
    constructor Create(AOwner: TFontButton);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Text: TCaption read FText write SetText;
    property Font: TFont read FFont write SetFont;
    property GrowSize: Integer read FGrowSize write SetGrowSize default 3;
    property StandardColor: TFontButtonColor read FStandardColor write SetStandardColor default DEFAULT_IMAGE_STANDARD_COLOR;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor default DEFAULT_IMAGE_USE_STANDARD_COLOR;
  end;

  TFontButton = class(TCustomControl)
  private
    FTmp: TBitmap;
    {$IFDEF BUF_BMP}
    FBuf: TBitmap;
    {$ENDIF}
    FActive: Boolean;
    FClicking: Boolean;
    FHovering: Boolean;
    FButtonTheme: THandle;
    FCancel: Boolean;
    FColor: TColor;
    FImage: TFontButtonImage;
    FDownSize: Integer;
    FStyleColors: TFontButtonStyleColors;
    FImagePosition: TFontButtonImgPosition;
    FShowFocusRect: Boolean;
    FModalResult: TModalResult;
    FSpacing: Integer;
    FMargin: Integer;
    FDefault: Boolean;
    FShowGuides: Boolean;
    FDrawStyle: TFontButtonDrawStyle;
    FKind: TFontButtonKind;
    FSubTextStyle: TFontButtonSubTextStyle;
    FSubText: TCaption;
    FSubTextFont: TFont;
    FParentColorOverride: Boolean;
    procedure SetDownSize(const Value: Integer);
    procedure SetImagePosition(const Value: TFontButtonImgPosition);
    procedure SetStyleColors(const Value: TFontButtonStyleColors);
    procedure Reset;
    function CaptionRect: TRect;
    function ImageRect: TRect;
    function CaptionColor: TColor;
    function ImageColor: TColor;
    function CaptionDims: TPoint;
    function ImageDims: TPoint;
    function CaptionFlags: Cardinal;
    function ImageFlags: Cardinal;
    function ContentRect: TRect;
    function ImageFontSize: Integer;
    procedure DrawBtn;
    procedure DrawTheme;
    procedure DrawBackground;
    procedure DrawCaption;
    procedure DrawImage;
    procedure DrawFocus;
    //Property Getters/Setters
    procedure SetColor(Value: TColor);
    procedure SetImage(const Value: TFontButtonImage);
    procedure SetShowFocusRect(const Value: Boolean);
    procedure SetMargin(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
    procedure SetText(const Value: TCaption);
    function GetText: TCaption;
    procedure SetDefault(const Value: Boolean);
    procedure SetCancel(const Value: Boolean);
    procedure SetShowGuides(const Value: Boolean);
    procedure SetDrawStyle(const Value: TFontButtonDrawStyle);
    function GetFont: TFont;
    procedure SetFont(const Value: TFont);
    procedure SetKind(const Value: TFontButtonKind);
    function ActiveCanvas: TCanvas;
    procedure SetSubText(const Value: TCaption);
    procedure SetSubTextStyle(const Value: TFontButtonSubTextStyle);
    procedure SetSubTextFont(const Value: TFont);
    procedure SubTextFontChanged(Sender: TObject);
    function SubCaptionRect: TRect;
    function SubCaptionFlags: Cardinal;
    procedure SetParentColorOverride(const Value: Boolean);
    function ParentIsDark: Boolean;
  protected
    procedure Paint; override;
    function GetEnabled: Boolean; reintroduce;
    procedure SetEnabled(Value: Boolean); reintroduce;
    procedure Loaded; override;
    //Catch Windows Messages
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMMButtonDown(var Message: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMMButtonUp(var Message: TWMMButtonUp); message WM_MBUTTONUP;
    procedure WMFontChange(var Message: TMessage); message WM_FONTCHANGE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMResize(var Message: TWMSize); message WM_SIZE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMColorChange(var Message: TMessage); message WM_COLORCHANGE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function State: TFontButtonState;
    procedure Assign(Source: TPersistent); override;
    procedure Click; override;
    function BackColor: TColor;
    procedure AfterConstruction; override;
  published
    property Align;
    property Anchors;
    property Cancel: Boolean read FCancel write SetCancel default DEFAULT_CANCEL;
    property Color: TColor read FColor write SetColor default DEFAULT_COLOR;
    property Cursor;
    property CustomHint;
    property Default: Boolean read FDefault write SetDefault default DEFAULT_DEFAULT;
    property DoubleBuffered;
    property DownSize: Integer read FDownSize write SetDownSize default DEFAULT_DOWN_SIZE;
    property DrawStyle: TFontButtonDrawStyle read FDrawStyle write SetDrawStyle default DEFAULT_DRAW_STYLE;
    property Enabled: Boolean read GetEnabled write SetEnabled default DEFAULT_ENABLED;
    property Font: TFont read GetFont write SetFont;
    property Hint;
    property Image: TFontButtonImage read FImage write SetImage;
    property ImagePosition: TFontButtonImgPosition read FImagePosition write SetImagePosition default DEFAULT_IMAGE_POSITION;
    property Kind: TFontButtonKind read FKind write SetKind default DEFAULT_KIND;
    property Margin: Integer read FMargin write SetMargin default DEFAULT_MARGIN;
    property ModalResult: TModalResult read FModalResult write FModalResult default DEFAULT_MODAL_RESULT;
    property ParentColorOverride: Boolean read FParentColorOverride write SetParentColorOverride default DEFAULT_PARENT_COLOR_OVERRIDE;
    property ParentCustomHint;
    property ParentDoubleBuffered;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default DEFAULT_SHOW_FOCUS_RECT;
    property ShowGuides: Boolean read FShowGuides write SetShowGuides default DEFAULT_SHOW_GUIDES;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default DEFAULT_SPACING;
    property StyleColors: TFontButtonStyleColors read FStyleColors write SetStyleColors default DEFAULT_STYLE_COLORS;
    //property SubText: TCaption read FSubText write SetSubText;
    //property SubTextStyle: TFontButtonSubTextStyle read FSubTextStyle write SetSubTextStyle default DEFAULT_SUB_TEXT_STYLE;
    //property SubTextFont: TFont read FSubTextFont write SetSubTextFont;
    property TabOrder;
    property TabStop default DEFAULT_TAB_STOP;
    property Text: TCaption read GetText write SetText;
    property Visible;

    property OnClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

//Used for drawing new Windows Themes (XP and up) - only if enabled
function DrawThemeBackground(hTheme: THandle; hdc: HDC; iPartId, iStateId: Integer;
  const pRect: TRect; pClipRect: PRECT): HRESULT; stdcall;
  external 'uxtheme.dll';
function OpenThemeData(hwnd: HWND; pszClassList: LPCWSTR): THandle; stdcall;
  external 'uxtheme.dll';
function CloseThemeData(hTheme: THandle): HRESULT; stdcall;
  external 'uxtheme.dll';

function ColorManager: TColorManager;

implementation

uses
  Math,
  JD.Graphics;

const
  PBS_NORMAL = 1;
  PBS_HOT = 2;
  PBS_PRESSED = 3;
  PBS_DISABLED = 4;
  PBS_DEFAULTED = 5;
  PBS_DEFAULTED_ANIMATING = 6;

type
  TIsThemeActive = function: Bool; stdcall;

const
  THEME_LIB = 'uxtheme.dll';

var
  _ColorManager: TColorManager;

function ColorManager: TColorManager;
begin
  Result:= _ColorManager;
end;

function IsThemeActive: Boolean;
var
  IsThemeActive: TIsThemeActive;
  hUxTheme: HINST;
begin
  //Checks whether or not windows themes are enabled
  Result := False;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and
    (((Win32MajorVersion = 5) and (Win32MinorVersion >= 1)) or
    (Win32MajorVersion > 5)) then
  begin
    hUxTheme := LoadLibrary(THEME_LIB);
    if hUxTheme <> 0 then begin
      try
        IsThemeActive := GetProcAddress(huxtheme, 'IsThemeActive');
        Result := IsThemeActive;
      finally
        if hUxTheme > 0 then
          FreeLibrary(huxtheme);
      end;
    end;
  end;
end;

function IntToButtonState(const Value: Integer): TFontButtonState;
begin
  //Converts an integer (from Winapi) to state enum
  case Value of
    PBS_NORMAL: Result:= fsNormal;
    PBS_HOT: Result:= fsHot;
    PBS_PRESSED: Result:= fsPressed;
    PBS_DISABLED: Result:= fsDisabled;
    PBS_DEFAULTED: Result:= fsFocused;
    PBS_DEFAULTED_ANIMATING: Result:= fsFocused;
    else Result:= fsNormal;
  end;
end;

function ButtonStateToInt(const Value: TFontButtonState): Integer;
begin
  //Converts a state enum to integer (from Winapi)
  case Value of
    fsDisabled: Result:= PBS_DISABLED;
    fsFocused: Result:= PBS_DEFAULTED;
    fsHot: Result:= PBS_HOT;
    fsNormal: Result:= PBS_NORMAL;
    fsPressed: Result:= PBS_PRESSED;
    else Result:= PBS_NORMAL;
  end;
end;

{ TFontButtonImage }

constructor TFontButtonImage.Create(AOwner: TFontButton);
begin
  FOwner:= AOwner;
  FFont:= TFont.Create;


  FFont.Quality:= DEFAULT_IMAGE_QUALITY;
  FFont.Size:= DEFAULT_IMAGE_SIZE;
  FFont.Name:= DEFAULT_IMAGE_FONT;
  FFont.OnChange:= FontChanged;
  FText:= DEFAULT_IMAGE_TEXT;
  FAutoSize:= DEFAULT_IMAGE_AUTO_SIZE;
  FGrowSize:= DEFAULT_IMAGE_GROW_SIZE;
  FStandardColor:= DEFAULT_IMAGE_STANDARD_COLOR;
  FUseStandardColor:= DEFAULT_IMAGE_USE_STANDARD_COLOR;
end;

destructor TFontButtonImage.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TFontButtonImage.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TFontButtonImage.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TFontButtonImage.SetAutoSize(const Value: Boolean);
begin
  FAutoSize := Value;
  Invalidate;
end;

procedure TFontButtonImage.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TFontButtonImage.SetText(const Value: TCaption);
begin
  FText:= Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

procedure TFontButtonImage.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor := Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

procedure TFontButtonImage.SetGrowSize(const Value: Integer);
begin
  FGrowSize := Value;
  Invalidate;
end;

procedure TFontButtonImage.SetStandardColor(const Value: TFontButtonColor);
begin
  FStandardColor := Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

{ TFontButton }

constructor TFontButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovering:= False;
  FClicking:= False;
  FTmp:= TBitmap.Create;
  {$IFDEF BUF_BMP}
  FBuf:= TBitmap.Create;
  {$ENDIF}
  FImage:= TFontButtonImage.Create(Self);
  FSubTextFont:= TFont.Create;
  FSubTextFont.OnChange:= SubTextFontChanged;
  //Font.OnChange:= FontChanged;
  ColorManager.RegisterControl(Self);
end;

destructor TFontButton.Destroy;
begin
  ColorManager.UnregisterControl(Self);
  FSubTextFont.Free;
  FImage.Free;
  {$IFDEF BUF_BMP}
  FBuf.Free;
  {$ENDIF}
  FTmp.Free;
  CloseThemeData(FButtonTheme);
  inherited;
end;

procedure TFontButton.AfterConstruction;
begin
  inherited;
  //Set default values
  FDrawStyle:= DEFAULT_DRAW_STYLE;
  Width:= DEFAULT_WIDTH;
  Height:= DEFAULT_HEIGHT;
  Color:= DEFAULT_COLOR;
  FImagePosition:= DEFAULT_IMAGE_POSITION;
  FDownSize:= DEFAULT_DOWN_SIZE;
  FStyleColors:= DEFAULT_STYLE_COLORS;
  FShowFocusRect:= DEFAULT_SHOW_FOCUS_RECT;
  FMargin:= DEFAULT_MARGIN;
  FSpacing:= DEFAULT_SPACING;
  FModalResult:= DEFAULT_MODAL_RESULT;
  TabStop:= DEFAULT_TAB_STOP;
  FDefault:= DEFAULT_DEFAULT;
  FCancel:= DEFAULT_CANCEL;
  FShowGuides:= DEFAULT_SHOW_GUIDES;
  FKind:= DEFAULT_KIND;
  FSubText:= DEFAULT_SUB_TEXT;
  FSubTextStyle:= DEFAULT_SUB_TEXT_STYLE;
  FSubTextFont.Assign(Self.Font);
  FSubTextFont.Color:= DEFAULT_SUB_TEXT_COLOR;
end;

procedure TFontButton.Loaded;
const
  ButtonDataName: PWideChar = 'button';
begin
  inherited;

  FButtonTheme := OpenThemeData(Handle, ButtonDataName);

end;

procedure TFontButton.Assign(Source: TPersistent);
var
  S, D: TFontButton;
begin
  if Source is TFontButton then begin
    S:= TFontButton(Source);
    D:= Self;

    D.Width:= S.Width;
    D.Height:= S.Height;
    D.ImagePosition:= S.ImagePosition;
    D.Font.Assign(S.Font);
    D.Text:= S.Text;
    D.Color:= S.Color;
    D.Cursor:= S.Cursor;
    D.DownSize:= S.DownSize;
    D.Hint:= S.Hint;
    D.Image.Font.Assign(S.Image.Font);
    D.Image.AutoSize:= S.Image.AutoSize;
    D.Image.GrowSize:= S.Image.GrowSize;
    D.Image.Text:= S.Image.Text;
    D.Margins.Assign(S.Margins);
    D.ShowFocusRect:= S.ShowFocusRect;
    D.ShowHint:= S.ShowHint;
    D.StyleColors:= S.StyleColors;
    D.TabStop:= S.TabStop;
    D.Margin:= S.Margin;
    D.Spacing:= S.Spacing;
    D.DrawStyle:= S.DrawStyle;
    D.Default:= S.Default;
    D.Cancel:= S.Cancel;


  end else
    inherited;
end;

function TFontButton.GetEnabled: Boolean;
begin
  Result:= inherited Enabled;
end;

function TFontButton.GetFont: TFont;
begin
  Result:= inherited Font;
end;

function TFontButton.GetText: TCaption;
begin
  Result:= inherited Caption;
end;

procedure TFontButton.SetCancel(const Value: Boolean);
begin
  FCancel := Value;
  Invalidate;
end;

procedure TFontButton.SetText(const Value: TCaption);
begin
  inherited Text:= Value;
  Invalidate;
end;

procedure TFontButton.SetColor(Value: TColor);
begin
  FColor := Value;
  Invalidate;
end;

procedure TFontButton.SetEnabled(Value: Boolean);
begin
  inherited Enabled:= Value;
  Invalidate;
end;

procedure TFontButton.SetFont(const Value: TFont);
begin
  inherited Font.Assign(Value);
  Invalidate;
end;

procedure TFontButton.SetImage(const Value: TFontButtonImage);
begin
  FImage.Assign(Value);
  Invalidate;
end;

procedure TFontButton.SetShowFocusRect(const Value: Boolean);
begin
  FShowFocusRect := Value;
  Invalidate;
end;

procedure TFontButton.SetShowGuides(const Value: Boolean);
begin
  FShowGuides := Value;
  Invalidate;
end;

procedure TFontButton.SetSpacing(const Value: Integer);
begin
  FSpacing := Value;
  Invalidate;
end;

procedure TFontButton.SetStyleColors(const Value: TFontButtonStyleColors);
begin
  FStyleColors := Value;
  Invalidate;
end;

procedure TFontButton.SetSubText(const Value: TCaption);
begin
  FSubText := Value;
  Invalidate;
end;

procedure TFontButton.SetSubTextFont(const Value: TFont);
begin
  FSubTextFont.Assign(Value);
  Invalidate;
end;

procedure TFontButton.SetSubTextStyle(const Value: TFontButtonSubTextStyle);
begin
  FSubTextStyle := Value;
  Invalidate;
end;

procedure TFontButton.SetDefault(const Value: Boolean);
var
  Form: TCustomForm;
begin
  FDefault := Value;
  if HandleAllocated then begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.Perform(CM_FOCUSCHANGED, 0, LPARAM(Form.ActiveControl));
  end;
  Invalidate;
end;

procedure TFontButton.SetDownSize(const Value: Integer);
begin
  if Value < 1 then begin
    FDownSize:= 1;
    Invalidate;
    raise Exception.Create('Down size must be at least 1');
  end;
  FDownSize := Value;
  Invalidate;
end;

procedure TFontButton.SetDrawStyle(const Value: TFontButtonDrawStyle);
begin
  FDrawStyle := Value;
  Invalidate;
end;

procedure TFontButton.SetImagePosition(const Value: TFontButtonImgPosition);
begin
  FImagePosition := Value;
  Invalidate;
end;

procedure TFontButton.SetMargin(const Value: Integer);
begin
  FMargin := Value;
  Invalidate;
end;

procedure TFontButton.SetParentColorOverride(const Value: Boolean);
begin
  FParentColorOverride := Value;
  Invalidate;
end;

function TFontButton.State: TFontButtonState;
begin
  if FClicking then
    Result:= fsPressed
  else if FHovering then
    Result:= fsHot
  else if Focused then
    Result:= fsFocused
  else if not Enabled then
    Result:= fsDisabled
  else
    Result:= fsNormal;
end;

procedure TFontButton.SubTextFontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TFontButton.WMColorChange(var Message: TMessage);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.WMFontChange(var Message: TMessage);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result:= DLGC_BUTTON;
  inherited;
end;

procedure TFontButton.WMKeyDown(var Message: TWMKeyDown);
begin
  if (Message.CharCode = vkReturn) or
    (Message.CharCode = vkSpace) then
  begin
    FClicking:= True;
  end;
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.WMKeyUp(var Message: TWMKeyUp);
begin
  FClicking:= False;
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.WMKillFocus(var Message: TWMKillFocus);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMMButtonDown(var Message: TWMMButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMMButtonUp(var Message: TWMMButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTCLIENT;
end;

procedure TFontButton.WMRButtonDown(var Message: TWMRButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMRButtonUp(var Message: TWMRButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TFontButton.WMResize(var Message: TWMSize);
begin
  Invalidate;
  inherited;
end;

procedure TFontButton.WMSetFocus(var Message: TWMSetFocus);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TFontButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if (Message.keydata and $20000000) <> 0 then begin
    if IsAccel(Message.charcode, Text) then begin
      Click;
      Message.Result := 1;
    end;
  end;
  inherited;
end;

procedure TFontButton.CMMouseEnter(var Message: TMessage);
begin
  if Enabled then
    FHovering:= True;
  Invalidate;
  inherited;
end;

procedure TFontButton.CMMouseLeave(var Message: TMessage);
begin
  FHovering:= False;
  Invalidate;
  inherited;
end;

procedure TFontButton.CMStyleChanged(var Message: TMessage);
begin
  Reset;
  inherited;
end;

procedure TFontButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if Sender is TFontButton then
      FActive := Sender = Self
    else
      FActive := FDefault;
  Invalidate;
  inherited;
end;

procedure TFontButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FActive) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
  Invalidate;
end;

procedure TFontButton.Reset;
begin
  FHovering:= False;
  FClicking:= False;
  Invalidate;
end;

procedure TFontButton.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then Form.ModalResult := ModalResult;
  inherited Click;
end;

function TFontButton.BackColor: TColor;
begin
  if scBack in StyleColors then begin
    case State of
      fsHot: begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonHot)
      end;
      fsPressed: begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonPressed)
      end;
      fsFocused: begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonFocused)
      end;
      fsDisabled: begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonDisabled)
      end;
      fsNormal: begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonNormal);
      end;
      else begin
        Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonNormal);
      end;
    end;
  end else begin
    if State = fsDisabled then
      Result:= TStyleManager.ActiveStyle.GetStyleColor(scButtonDisabled)
    else
      Result:= TStyleManager.ActiveStyle.GetSystemColor(Self.Color);
  end;
end;

function TFontButton.ParentIsDark: Boolean;
begin
  //TODO: Detect parent control's background color,
  //  return whether it's a light or dark color

end;

function TFontButton.CaptionColor: TColor;
begin
  if scCaption in StyleColors then begin
    case State of
      fsHot: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextHot);
      end;
      fsPressed: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextPressed);
      end;
      fsFocused: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextFocused);
      end;
      fsDisabled: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextDisabled);
      end;
      fsNormal: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
      end;
      else begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
      end;
    end;
  end else begin
    if FParentColorOverride then begin
      //Detect parent color instead of global main color

    end else begin
      if State = fsDisabled then
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextDisabled)
      else
        Result:= TStyleManager.ActiveStyle.GetSystemColor(Font.Color);
    end;
  end;
end;

function TFontButton.ImageColor: TColor;
begin
  if scImage in StyleColors then begin
    case State of
      fsHot: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextHot);
      end;
      fsPressed: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextPressed);
      end;
      fsFocused: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextFocused);
      end;
      fsDisabled: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextDisabled);
      end;
      fsNormal: begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
      end;
      else begin
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
      end;
    end;
  end else begin
    if FParentColorOverride then begin
      //Detect parent color instead of global main color

    end else begin
      if State = fsDisabled then
        Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextDisabled)
      else begin
        if Image.UseStandardColor then begin
          Result:= ColorManager.Color[Image.StandardColor];
        end else begin
          Result:= TStyleManager.ActiveStyle.GetSystemColor(FImage.Font.Color);
        end;
      end;
    end;
  end;
end;

function TFontButton.ImageFontSize: Integer;
const
  RANGE_MIN = 6;
  RANGE_MAX = 3000;
  DIVIDE_BY = 1.7;
  SHRINK_BY = 3;
var
  P: TPoint;
begin
  Result:= Image.Font.Size;
  if Image.AutoSize then begin
    P:= CaptionDims;
    case FImagePosition of
      fpImgTop, fpImgBottom: begin
        Result:= IntRange(Trunc(ClientRect.Height - P.Y / DIVIDE_BY) - SHRINK_BY,
          RANGE_MIN, RANGE_MAX);
      end;
      fpImgLeft, fpImgRight, fpImgOnly: begin
        Result:= IntRange(Trunc(ClientRect.Height / DIVIDE_BY) - SHRINK_BY,
          RANGE_MIN, RANGE_MAX);
      end;
      fpImgNone: begin

      end;
    end;
  end;
  if FImage.FGrowSize > 0 then begin
    if FHovering then begin
      Result:= Result + FImage.FGrowSize;
    end;
  end;
end;

function TFontButton.ImageDims: TPoint;
begin
  FTmp.Canvas.Font.Assign(Image.Font);
  FTmp.Canvas.Font.Size:= ImageFontSize;
  //Result.X:= Canvas.TextWidth(Image.Text);
  Result.Y:= FTmp.Canvas.TextHeight(Image.Text);
  Result.X:= Result.Y;
end;

function TFontButton.CaptionDims: TPoint;
begin
  //Returns the dimensions of the caption text with given font
  FTmp.Canvas.Font.Assign(Font);
  Result.X:= FTmp.Canvas.TextWidth(Text);
  Result.Y:= FTmp.Canvas.TextHeight(Text);
end;

function TFontButton.ContentRect: TRect;
var
  Cap, Img, D: TPoint;
  W, H: Integer;
begin
  Cap:= CaptionDims;
  Img:= ImageDims;

  case FImagePosition of
    fpImgTop, fpImgBottom: begin
      if Img.X > Cap.X then D.X:= Img.X else D.X:= Cap.X;
      D.Y:= Img.Y + Cap.Y + FSpacing;
    end;
    fpImgLeft, fpImgRight: begin
      if Img.Y > Cap.Y then D.Y:= Img.Y else D.Y:= Cap.Y;
      D.X:= Img.X + Cap.X + FSpacing;
    end;
    fpImgOnly: begin
      D.X:= ClientRect.Width;
      D.Y:= ClientRect.Height;
    end;
    fpImgNone: begin

    end;
  end;

  //Make result D centered with ClientRect
  //If Margin = -1 then center else shift image and caption from image edge
  Result.Left:= (ClientRect.Width div 2) - (D.X div 2);
  Result.Right:= Result.Left + D.X;
  Result.Top:= (ClientRect.Height div 2) - (D.Y div 2);
  Result.Bottom:= Result.Top + D.Y;

  W:= Result.Width;
  H:= Result.Height;

  if FMargin <> -1 then begin
    case FImagePosition of
      fpImgTop: begin
        Result.Top:= FMargin;
        Result.Bottom:= FMargin + H;
      end;
      fpImgBottom: begin
        Result.Bottom:= ClientHeight - FMargin;
        Result.Top:= ClientHeight - FMargin - H;
      end;
      fpImgLeft: begin
        Result.Left:= FMargin;
        Result.Right:= FMargin + W;
      end;
      fpImgRight: begin
        Result.Right:= ClientWidth - FMargin;
        Result.Left:= ClientWidth - FMargin - W;
      end;
      fpImgOnly: begin

      end;
      fpImgNone: begin

      end;
    end;
  end;

end;

function TFontButton.CaptionRect: TRect;
var
  Dims: TPoint;
begin
  Result:= ContentRect;
  Dims:= CaptionDims;

  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      Result.Top:= Result.Bottom - Dims.Y;
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      Result.Bottom:= Result.Top + Dims.Y;
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      Result.Left:= Result.Right - Dims.X;
    end;
    fpImgRight: begin
      //Image resized on right, text filled on left
      Result.Right:= Result.Left + Dims.X;
    end;
    fpImgOnly: begin
      //Result means nothing here really
    end;
    fpImgNone: begin
      //No image, just caption
    end;
  end;
end;

function TFontButton.SubCaptionRect: TRect;
var
  Dims: TPoint;
begin
  Result:= ContentRect;
  Dims:= CaptionDims;

  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      Result.Top:= Result.Bottom - Dims.Y;
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      Result.Bottom:= Result.Top + Dims.Y;
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      Result.Left:= Result.Right - Dims.X;
    end;
    fpImgRight: begin
      //Image resized on right, text filled on left
      Result.Right:= Result.Left + Dims.X;
    end;
    fpImgOnly: begin
      //Result means nothing here really
    end;
    fpImgNone: begin
      //No image, just caption
    end;
  end;
end;

function TFontButton.ImageRect: TRect;
var
  Dims: TPoint;
begin
  Result:= ContentRect;
  Dims:= ImageDims;

  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      Result.Bottom:= Result.Top + Dims.Y;
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      Result.Top:= Result.Bottom - Dims.Y;
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      Result.Right:= Result.Left + Dims.Y;
    end;
    fpImgRight: begin
      //Image resized on right, text filled on left
      Result.Left:= Result.Right - Dims.Y;
      //Result.Left:= ClientWidth - Result.Height;
      //Result.Right:= ClientWidth;
    end;
    fpImgOnly: begin
      //Keep result, fill full control with image
    end;
    fpImgNone: begin
      //No image, just caption, result means nothing here
    end;
  end;
end;

function TFontButton.CaptionFlags: Cardinal;
begin
  Result:= DT_SINGLELINE or DT_NOCLIP;
  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      Result:= Result or DT_CENTER or DT_TOP
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      Result:= Result or DT_CENTER or DT_BOTTOM
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      Result:= Result or DT_LEFT or DT_VCENTER
    end;
    fpImgRight: begin
      //Image resized on right, text filled on left
      Result:= Result or DT_RIGHT or DT_VCENTER
    end;
    fpImgOnly: begin
      //Ignore
    end;
    fpImgNone: begin
      //No image, just caption
      Result:= Result or DT_CENTER or DT_VCENTER
    end;
  end;
end;

function TFontButton.SubCaptionFlags: Cardinal;
begin
  Result:= DT_SINGLELINE or DT_NOCLIP;
  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      Result:= Result or DT_CENTER or DT_BOTTOM
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      Result:= Result or DT_CENTER or DT_TOP
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      Result:= Result or DT_RIGHT or DT_VCENTER
    end;
    fpImgRight: begin
      //Image resized on right, text filled on left
      Result:= Result or DT_LEFT or DT_VCENTER
    end;
    fpImgOnly: begin
      //Ignore
    end;
    fpImgNone: begin
      //No image, just caption
      Result:= Result or DT_CENTER or DT_VCENTER
    end;
  end;
end;

function TFontButton.ImageFlags: Cardinal;
begin
  Result:= DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_NOCLIP;
end;

procedure TFontButton.DrawTheme;
const
  WordBreakFlag: array[Boolean] of Integer = (0, DT_WORDBREAK);
var
  Details:  TThemedElementDetails;
  DrawRect: TRect;
begin
  DrawRect := ClientRect;
  case State of
    fsDisabled: begin
      Details := StyleServices.GetElementDetails(tbPushButtonDisabled);
    end;
    fsFocused: begin
      Details := StyleServices.GetElementDetails(tbPushButtonDefaulted)
    end;
    fsHot: begin
      Details := StyleServices.GetElementDetails(tbPushButtonHot)
    end;
    fsNormal: begin
      if FDefault then
        Details := StyleServices.GetElementDetails(tbPushButtonDefaulted)
      else
        Details := StyleServices.GetElementDetails(tbPushButtonNormal);
    end;
    fsPressed: begin
      Details := StyleServices.GetElementDetails(tbPushButtonPressed)
    end;
  end;
  StyleServices.DrawElement(ActiveCanvas.Handle, Details, DrawRect);
end;

procedure TFontButton.DrawBtn;
var
  R: TRect;
begin
  {$IFDEF BUF_BMP}
  R:= FBuf.Canvas.ClipRect;
  {$ELSE}
  R:= Canvas.ClipRect;
  {$ENDIF}
  //Draw Windows Standard Button Background
  if IsThemeActive then begin
    //If Windows Themes are Enabled
    DrawThemeBackground(FButtonTheme, ActiveCanvas.Handle, 1, ButtonStateToInt(State), R, nil);
  end else begin
    //If Windows Themes are Disabled
    DrawFrameControl(ActiveCanvas.Handle, R, DFC_BUTTON, DFCS_BUTTONPUSH);
  end;
end;

function TFontButton.ActiveCanvas: TCanvas;
begin
  //Switches which canvas to draw to based on whether buffer is enabled or not
  {$IFDEF BUF_BMP}
  Result:= FBuf.Canvas;
  {$ELSE}
  Result:= Canvas;
  {$ENDIF}
end;

procedure TFontButton.DrawBackground;
  procedure DoDraw;
  begin
    if (StyleServices.Available) and
      (not SameText(TStyleManager.ActiveStyle.Name, 'Windows')) then
    begin
      DrawTheme;      //VCL style button
    end else begin
      DrawBtn;        //Windows themed button
    end;
  end;
begin
  ActiveCanvas.Brush.Style:= bsSolid;
  ActiveCanvas.Pen.Style:= psClear;
  DrawParentImage(Self, ActiveCanvas);

  case FDrawStyle of
    fdThemed: begin
      //Always draw themed background
      DoDraw;
    end;
    fdTransparent: begin
      //Draw nothing for background
    end;
    fdHybrid: begin
      //Only draw background if state is not in normal state or disabled state
      if (State <> fsNormal) and (State <> fsDisabled) then begin
        DoDraw;
      end;
    end;
  end;

end;

procedure TFontButton.DrawCaption;
var
  R: TRect;
begin
  //Caption
  if ImagePosition <> fpImgOnly then begin
    ActiveCanvas.Font.Assign(Font);
    R:= CaptionRect;
    ActiveCanvas.Brush.Style:= bsClear;
    ActiveCanvas.Pen.Style:= psClear;
    ActiveCanvas.Font.Color:= CaptionColor;
    if FClicking then begin
      R.Left:= R.Left + DownSize;
      R.Top:= R.Top + DownSize;
    end;
    if FShowGuides then begin
      ActiveCanvas.Pen.Style:= psSolid;
      ActiveCanvas.Pen.Color:= clBlack;
      ActiveCanvas.Pen.Width:= 1;
      ActiveCanvas.Rectangle(R);
    end;
    //DrawTextW(Canvas.Handle, Caption.Text, Length(Caption.Text), R, CaptionFlags or DT_CALCRECT);
    DrawTextW(ActiveCanvas.Handle, Text, Length(Text), R, CaptionFlags);

    R:= SubCaptionRect;
    {
    case Self.FSubTextStyle of
      fsNone: begin
        //Do nothing
      end;
      fsOpposite: begin
        //Draw sub text on opposite side
        DrawTextW(ActiveCanvas.Handle, SubText, Length(SubText), R, SubCaptionFlags);

      end;
      fsBelow: begin
        //Draw sub text below main text
        DrawTextW(ActiveCanvas.Handle, SubText, Length(SubText), R, SubCaptionFlags);

      end;
    end;
    }
  end;
end;

procedure TFontButton.DrawImage;
var
  R: TRect;
begin
  //Image
  if ImagePosition <> fpImgNone then begin
    R:= ImageRect;
    ActiveCanvas.Font.Assign(FImage.Font);
    ActiveCanvas.Font.Size:= ImageFontSize;
    ActiveCanvas.Brush.Style:= bsClear;
    ActiveCanvas.Pen.Style:= psClear;
    ActiveCanvas.Font.Color:= ImageColor;
    if FClicking then begin
      R.Left:= R.Left + DownSize;
      R.Top:= R.Top + DownSize;
    end;
    if FShowGuides then begin
      ActiveCanvas.Pen.Style:= psSolid;
      ActiveCanvas.Pen.Color:= clBlack;
      ActiveCanvas.Pen.Width:= 1;
      ActiveCanvas.Rectangle(R);
    end;
    //DrawTextW(Canvas.Handle, FImage.Text, Length(FImage.Text), R, ImageFlags or DT_CALCRECT);
    DrawTextW(ActiveCanvas.Handle, FImage.Text, Length(FImage.Text), R, ImageFlags);
  end;
end;

procedure TFontButton.DrawFocus;
begin
  //Focus Frame
  if (Focused) and (FShowFocusRect) then begin
    DrawFocusRect(ActiveCanvas.Handle, ActiveCanvas.ClipRect);
  end;
end;

procedure TFontButton.Paint;
var
  PS: PAINTSTRUCT;
begin
  BeginPaint(Handle, PS);
  try
    {$IFDEF BUF_BMP}
    if FBuf.Width <> Width then
      FBuf.Width:= Width;
    if FBuf.Height <> Height then
      FBuf.Height:= Height;
    {$ENDIF}
    DrawBackground;
    DrawCaption;
    DrawImage;
    DrawFocus;

    {$IFDEF BUF_BMP}
    BitBlt(Canvas.Handle, 0, 0, Width, Height, FBuf.Handle, 0, 0, SRCCOPY);
    {$ENDIF}
  finally
    EndPaint(Handle, PS);
  end;
end;

procedure TFontButton.SetKind(const Value: TFontButtonKind);
begin
  if Value <> fkCustom then begin
    //Standard for all
    Image.Font.Name:= 'RMPicons';
    Image.UseStandardColor:= True;
    Image.StandardColor:= fcNeutral;
    StyleColors:= StyleColors - [scImage];
  end;
  case Value of
    fkCustom: begin
      //Do nothing
    end;
    fkOK: begin
      Image.StandardColor:= fcGreen;
      Image.Text:= ''; //Checkmark
    end;
    fkCancel: begin
      Image.StandardColor:= fcOrange;
      Image.Text:= ''; //X Extended
    end;
    fkUndo: begin
      Image.StandardColor:= fcOrange;
      Image.Text:= ''; //Loop left arrow
    end;
    fkClose: begin
      Image.StandardColor:= fcBlue;
      Image.Text:= ''; //Power
    end;
    fkClear: begin
      Image.StandardColor:= fcOrange;
      Image.Text:= ''; //X Extended
    end;
    fkEdit: begin
      Image.StandardColor:= fcOrange;
      Image.Text:= ''; //Pencil
    end;
    fkSave: begin
      Image.StandardColor:= fcBlue;
      Image.Text:= ''; //Disk
    end;
    fkAdd: begin
      Image.StandardColor:= fcGreen;
      Image.Text:= ''; //Plus
    end;
    fkDelete: begin
      Image.StandardColor:= fcRed;
      Image.Text:= ''; //X
    end;
    fkInfo: begin
      Image.StandardColor:= fcBlue;
      Image.Text:= ''; //i in circle
    end;
    fkHelp: begin
      Image.StandardColor:= fcBlue;
      Image.Text:= ''; //? in circle
    end;
    fkPrint: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Printer
    end;
    fkPrintTag: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Tag Printer
    end;
    fkCalc: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Calculator
    end;
    fkRefresh: begin
      Image.StandardColor:= fcGreen;
      Image.Text:= ''; //Circular arrows
    end;
    fkView: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Magnifier inside box
    end;
    fkMerge: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Two lines combining into 1 arrow
    end;
    fkEmail: begin
      Image.StandardColor:= fcNeutral;
      Image.Text:= ''; //Envelope
    end;
    fkCloseX: begin
      Image.StandardColor:= fcRed;
      Image.Text:= ''; //X inside box
    end;
  end;
  FKind := Value;
  Invalidate;
end;

{ TMessageComponent }

constructor TMessageComponent.Create(AOwner: TComponent);
begin
  inherited;
  FHandle:= AllocateHwnd(WndMethod);
  ColorManager.RegisterComponent(Self);
end;

destructor TMessageComponent.Destroy;
begin
  ColorManager.UnregisterComponent(Self);
  DeallocateHWnd(FHandle);
  inherited;
end;

procedure TMessageComponent.WndMethod(var Message: TMessage);
begin

end;

{ TColorManager }

constructor TColorManager.Create;
begin
  FBaseColor:= clWhite;
  FComponents:= TObjectList<TMessageComponent>.Create(False);
  FControls:= TObjectList<TWinControl>.Create(False);
  Invalidate;
end;

destructor TColorManager.Destroy;
begin
  FControls.Free;
  FComponents.Free;
  inherited;
end;

function TColorManager.GetColor(Clr: TFontButtonColor): TColor;
begin
  Result:= FColors[Clr];
end;

procedure TColorManager.Invalidate;
var
  B: Byte;
  CR: TColorRec;
  X: Integer;
begin
  CR:= FBaseColor;
  B:= (CR.Red+CR.Green+CR.Blue) div 3;
  FIsBaseDark:= B < 100;
  if FIsBaseDark then begin
    FColors[fcNeutral]:= LIGHT_NEUTRAL;
    FColors[fcBlue]:= LIGHT_BLUE;
    FColors[fcGreen]:= LIGHT_GREEN;
    FColors[fcRed]:= LIGHT_RED;
    FColors[fcYellow]:= LIGHT_YELLOW;
    FColors[fcOrange]:= LIGHT_ORANGE;
  end else begin
    FColors[fcNeutral]:= DARK_NEUTRAL;
    FColors[fcBlue]:= DARK_BLUE;
    FColors[fcGreen]:= DARK_GREEN;
    FColors[fcRed]:= DARK_RED;
    FColors[fcYellow]:= DARK_YELLOW;
    FColors[fcOrange]:= DARK_ORANGE;
  end;
  for X := 0 to FComponents.Count-1 do begin
    SendMessage(FComponents[X].Handle, WM_COLORCHANGE, 0, 0);
  end;
  for X := 0 to FControls.Count-1 do begin
    SendMessage(FControls[X].Handle, WM_COLORCHANGE, 0, 0);
  end;
end;

procedure TColorManager.SetBaseColor(const Value: TColor);
begin
  FBaseColor:= TColor(Value);
  Invalidate;
end;

procedure TColorManager.SetColor(Clr: TFontButtonColor; const Value: TColor);
begin
  FColors[Clr]:= Value;
  Invalidate;
end;

procedure TColorManager.RegisterComponent(AComponent: TMessageComponent);
begin
  FComponents.Add(AComponent);
end;

procedure TColorManager.UnregisterComponent(AComponent: TMessageComponent);
begin
  FComponents.Delete(FComponents.IndexOf(AComponent));
end;

procedure TColorManager.RegisterControl(AControl: TWinControl);
begin
  FControls.Add(AControl)
end;

procedure TColorManager.UnregisterControl(AControl: TWinControl);
begin
  FControls.Delete(FControls.IndexOf(AControl));
end;

initialization
  _ColorManager:= TColorManager.Create;
finalization
  _ColorManager.Free;
end.

(*
  TJDFontButton - custom control encapsulating a button with custom effects
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
  - Implement "SubText" feature for secondary caption
  - Implement "Overlay" feature for secondary glyph
  - Implement action support

*)

unit JD.Ctrls.FontButton;

{$DEFINE FB_ACTIONS}
{ $DEFINE FB_ACTIONS_IMG}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Forms, Vcl.Styles, Vcl.Themes,
  Vcl.Dialogs
  {$IFDEF FB_ACTIONS}
  , Vcl.ActnList
  {$ENDIF}
  , JD.Ctrls
  , JD.Common
  , JD.Graphics
  , JD.FontGlyphs
  ;

type
  TJDFontButtonImgPosition = (fpImgTop, fpImgBottom, fpImgLeft, fpImgRight, fpImgOnly, fpImgNone);

  TJDFontButtonState = (fsDisabled, fsFocused, fsHot, fsNormal, fsPressed);

  TJDFontButtonStyleColor = (scCaption, scImage, scBack, scFrame);
  TJDFontButtonStyleColors = set of TJDFontButtonStyleColor;

  TJDFontButtonDrawStyle = (fdThemed, fdTransparent, fdHybrid);

  TJDFontButtonKind = (fkCustom, fkOK, fkCancel, fkClose, fkClear, fkEdit, fkSave, fkAdd,
    fkDelete, fkInfo, fkHelp, fkPrint, fkPrintTag, fkCalc, fkRefresh, fkView, fkMerge,
    fkEmail, fkCloseX, fkUndo);

  TJDFontButtonSubTextStyle = (fsNone, fsOpposite, fsBelow);

  TJDFontButtonOverlayPosition = (foNone, foTopLeft, foTopRight, foBottomLeft,
    foBottomRight, foCenter);

{$REGION 'Default Constants'}

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

  DEFAULT_IMAGE_FONT = 'FontAwesome';
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

{$ENDREGION}

//TODO: What were these constants defined for?
const
  CLR_DK_BLUE = clNavy;
  CLR_BLUE = clBlue;

type
  TJDFontButton = class;

  TJDFontButtonImage = class(TPersistent)
  private
    FOwner: TJDFontButton;
    FFont: TFont;
    FText: TCaption;
    FAutoSize: Boolean;
    FGrowSize: Integer;
    FStandardColor: TJDStandardColor;
    FUseStandardColor: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetText(const Value: TCaption);
    procedure SetFont(const Value: TFont);
    procedure SetAutoSize(const Value: Boolean);
    procedure SetGrowSize(const Value: Integer);
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
  public
    constructor Create(AOwner: TJDFontButton);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Text: TCaption read FText write SetText;
    property Font: TFont read FFont write SetFont;
    property GrowSize: Integer read FGrowSize write SetGrowSize default 3;
    property StandardColor: TJDStandardColor read FStandardColor write SetStandardColor default DEFAULT_IMAGE_STANDARD_COLOR;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor default DEFAULT_IMAGE_USE_STANDARD_COLOR;
  end;

  TJDFontButtonOverlay = class(TPersistent)
  private
    FOwner: TJDFontButton;
    FFont: TFont;
    FText: TCaption;
    FStandardColor: TJDStandardColor;
    FUseStandardColor: Boolean;
    FPosition: TJDFontButtonOverlayPosition;
    FMargin: Integer;
    procedure FontChanged(Sender: TObject);
    procedure SetText(const Value: TCaption);
    procedure SetFont(const Value: TFont);
    procedure SetStandardColor(const Value: TJDStandardColor);
    procedure SetUseStandardColor(const Value: Boolean);
    procedure SetPosition(const Value: TJDFontButtonOverlayPosition);
    procedure SetMargin(const Value: Integer);
  public
    constructor Create(AOwner: TJDFontButton);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Text: TCaption read FText write SetText;
    property Font: TFont read FFont write SetFont;
    property StandardColor: TJDStandardColor read FStandardColor write SetStandardColor default DEFAULT_IMAGE_STANDARD_COLOR;
    property UseStandardColor: Boolean read FUseStandardColor write SetUseStandardColor default DEFAULT_IMAGE_USE_STANDARD_COLOR;
    property Position: TJDFontButtonOverlayPosition read FPosition write SetPosition;
    property Margin: Integer read FMargin write SetMargin;
  end;

  TJDFontButton = class(TJDControl)
  private
    FTmp: TBitmap;
    FActive: Boolean;
    FClicking: Boolean;
    FHovering: Boolean;
    FButtonTheme: THandle;
    FCancel: Boolean;
    FColor: TColor; //TODO: Should I be using built-in Color property?
    FImage: TJDFontButtonImage;
    FOverlay: TJDFontButtonOverlay;
    FDownSize: Integer;
    FStyleColors: TJDFontButtonStyleColors;
    FImagePosition: TJDFontButtonImgPosition;
    FShowFocusRect: Boolean;
    FModalResult: TModalResult;
    FSpacing: Integer;
    FMargin: Integer;
    FDefault: Boolean;
    FShowGuides: Boolean;
    FDrawStyle: TJDFontButtonDrawStyle;
    FKind: TJDFontButtonKind;
    FSubTextStyle: TJDFontButtonSubTextStyle;
    FSubText: TCaption;
    FSubTextFont: TFont;
    FParentColorOverride: Boolean;
    procedure SetDownSize(const Value: Integer);
    procedure SetImagePosition(const Value: TJDFontButtonImgPosition);
    procedure SetStyleColors(const Value: TJDFontButtonStyleColors);
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
    procedure SetImage(const Value: TJDFontButtonImage);
    procedure SetShowFocusRect(const Value: Boolean);
    procedure SetMargin(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
    procedure SetText(const Value: TCaption);
    function GetText: TCaption;
    procedure SetDefault(const Value: Boolean);
    procedure SetCancel(const Value: Boolean);
    procedure SetShowGuides(const Value: Boolean);
    procedure SetDrawStyle(const Value: TJDFontButtonDrawStyle);
    function GetFont: TFont;
    procedure SetFont(const Value: TFont);
    procedure SetKind(const Value: TJDFontButtonKind);
    function ActiveCanvas: TCanvas;
    procedure SubTextFontChanged(Sender: TObject);
    function SubCaptionRect: TRect;
    procedure SetParentColorOverride(const Value: Boolean);
    procedure SetOverlay(const Value: TJDFontButtonOverlay);
    function OverlayRect: TRect;
    function OverlayFontSize: Integer;
    function OverlayColor: TColor;
    function OverlayDims: TPoint;
  protected
    procedure Paint; override;
    function GetEnabled: Boolean; reintroduce;
    procedure SetEnabled(Value: Boolean); reintroduce;
    procedure Loaded; override;
    {$IFDEF FB_ACTIONS}
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    {$ENDIF}
    //Windows Message Handling
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function State: TJDFontButtonState;
    procedure Assign(Source: TPersistent); override;
    procedure Click; override;
    function BackColor: TColor;
    procedure AfterConstruction; override;
    function ParentIsDark: Boolean;
    function SubCaptionFlags: Cardinal;
    procedure SetSubTextFont(const Value: TFont);
    procedure SetSubTextStyle(const Value: TJDFontButtonSubTextStyle);
    procedure SetSubText(const Value: TCaption);
    function GlyphImageIndex: Integer;
    function GlyphImageByIndex(const Index: Integer): TCaption;
  published
    {$IFDEF FB_ACTIONS}
    property Action;
    {$ENDIF}
    property Align;
    property Anchors;
    property Cancel: Boolean read FCancel write SetCancel default DEFAULT_CANCEL;
    property Color: TColor read FColor write SetColor default DEFAULT_COLOR;
    property Cursor;
    property CustomHint;
    property Default: Boolean read FDefault write SetDefault default DEFAULT_DEFAULT;
    property DoubleBuffered;
    property DownSize: Integer read FDownSize write SetDownSize default DEFAULT_DOWN_SIZE;
    property DrawStyle: TJDFontButtonDrawStyle read FDrawStyle write SetDrawStyle default DEFAULT_DRAW_STYLE;
    property Enabled: Boolean read GetEnabled write SetEnabled default DEFAULT_ENABLED;
    property Font: TFont read GetFont write SetFont;
    property Hint;
    property Image: TJDFontButtonImage read FImage write SetImage;
    property Overlay: TJDFontButtonOverlay read FOverlay write SetOverlay;
    property ImagePosition: TJDFontButtonImgPosition read FImagePosition write SetImagePosition default DEFAULT_IMAGE_POSITION;
    property Kind: TJDFontButtonKind read FKind write SetKind default DEFAULT_KIND;
    property Margin: Integer read FMargin write SetMargin default DEFAULT_MARGIN;
    property ModalResult: TModalResult read FModalResult write FModalResult default DEFAULT_MODAL_RESULT;
    property ParentColorOverride: Boolean read FParentColorOverride write SetParentColorOverride default DEFAULT_PARENT_COLOR_OVERRIDE;
    property ParentCustomHint;
    property ParentDoubleBuffered;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default DEFAULT_SHOW_FOCUS_RECT;
    property ShowGuides: Boolean read FShowGuides write SetShowGuides default DEFAULT_SHOW_GUIDES;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default DEFAULT_SPACING;
    property StyleColors: TJDFontButtonStyleColors read FStyleColors write SetStyleColors default DEFAULT_STYLE_COLORS;
    property SubText: TCaption read FSubText write SetSubText;
    property SubTextStyle: TJDFontButtonSubTextStyle read FSubTextStyle write SetSubTextStyle default DEFAULT_SUB_TEXT_STYLE;
    property SubTextFont: TFont read FSubTextFont write SetSubTextFont;
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

{$REGION 'Windows Themes'}

//Used for drawing new Windows Themes (XP and up) - only if enabled

const
  THEME_LIB = 'uxtheme.dll';

function DrawThemeBackground(hTheme: THandle; hdc: HDC; iPartId, iStateId: Integer;
  const pRect: TRect; pClipRect: PRECT): HRESULT; stdcall;
  external THEME_LIB;
function OpenThemeData(hwnd: HWND; pszClassList: LPCWSTR): THandle; stdcall;
  external THEME_LIB;
function CloseThemeData(hTheme: THandle): HRESULT; stdcall;
  external THEME_LIB;

{$ENDREGION}

implementation

uses
  Math;

const
  //Button states
  PBS_NORMAL = 1;
  PBS_HOT = 2;
  PBS_PRESSED = 3;
  PBS_DISABLED = 4;
  PBS_DEFAULTED = 5;
  PBS_DEFAULTED_ANIMATING = 6;

function JDIsThemeActive: Boolean;
type
  TIsThemeActive = function: Bool; stdcall;
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

function JDIntToButtonState(const Value: Integer): TJDFontButtonState;
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

function JDButtonStateToInt(const Value: TJDFontButtonState): Integer;
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

{ TJDFontButtonImage }

constructor TJDFontButtonImage.Create(AOwner: TJDFontButton);
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

destructor TJDFontButtonImage.Destroy;
begin
  FreeAndNil(FFont);
  inherited;
end;

procedure TJDFontButtonImage.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDFontButtonImage.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDFontButtonImage.SetAutoSize(const Value: Boolean);
begin
  FAutoSize := Value;
  Invalidate;
end;

procedure TJDFontButtonImage.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TJDFontButtonImage.SetText(const Value: TCaption);
begin
  FText:= Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

procedure TJDFontButtonImage.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor := Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

procedure TJDFontButtonImage.SetGrowSize(const Value: Integer);
begin
  FGrowSize := Value;
  Invalidate;
end;

procedure TJDFontButtonImage.SetStandardColor(const Value: TJDStandardColor);
begin
  FStandardColor := Value;
  FOwner.FKind:= fkCustom;
  Invalidate;
end;

{ TJDFontButtonOverlay }

constructor TJDFontButtonOverlay.Create(AOwner: TJDFontButton);
begin
  //TODO: Update default values...
  FOwner:= AOwner;
  FFont:= TFont.Create;
  FFont.Quality:= DEFAULT_IMAGE_QUALITY;
  FFont.Size:= DEFAULT_IMAGE_SIZE div 3;
  FFont.Name:= DEFAULT_IMAGE_FONT;
  FFont.OnChange:= FontChanged;
  FText:= DEFAULT_IMAGE_TEXT;
  FStandardColor:= DEFAULT_IMAGE_STANDARD_COLOR;
  FUseStandardColor:= DEFAULT_IMAGE_USE_STANDARD_COLOR;
  FMargin:= 3;
end;

destructor TJDFontButtonOverlay.Destroy;
begin
  FreeAndNil(FFont);
  inherited;
end;

procedure TJDFontButtonOverlay.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDFontButtonOverlay.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDFontButtonOverlay.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TJDFontButtonOverlay.SetMargin(const Value: Integer);
begin
  FMargin := Value;
  Invalidate;
end;

procedure TJDFontButtonOverlay.SetPosition(
  const Value: TJDFontButtonOverlayPosition);
begin
  FPosition := Value;
  Invalidate;
end;

procedure TJDFontButtonOverlay.SetStandardColor(const Value: TJDStandardColor);
begin
  FStandardColor:= Value;
  Invalidate;
end;

procedure TJDFontButtonOverlay.SetText(const Value: TCaption);
begin
  FText:= Value;
  Invalidate;
end;

procedure TJDFontButtonOverlay.SetUseStandardColor(const Value: Boolean);
begin
  FUseStandardColor:= Value;
  Invalidate;
end;

{ TJDFontButton }

constructor TJDFontButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovering:= False;
  FClicking:= False;
  FTmp:= TBitmap.Create;
  FImage:= TJDFontButtonImage.Create(Self);
  FOverlay:= TJDFontButtonOverlay.Create(Self);
  FSubTextFont:= TFont.Create;
  FSubTextFont.OnChange:= SubTextFontChanged;
end;

destructor TJDFontButton.Destroy;
begin
  FreeAndNil(FSubTextFont);
  FreeAndNil(FOverlay);
  FreeAndNil(FImage);
  FreeAndNil(FTmp);
  CloseThemeData(FButtonTheme);
  inherited;
end;

procedure TJDFontButton.AfterConstruction;
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

procedure TJDFontButton.Loaded;
const
  ButtonDataName: PWideChar = 'button';
begin
  inherited;
  FButtonTheme := OpenThemeData(Handle, ButtonDataName);
end;

procedure TJDFontButton.Assign(Source: TPersistent);
var
  S, D: TJDFontButton;
  //S = Source
  //D = Destination
begin
  if Source is TJDFontButton then begin
    S:= TJDFontButton(Source);
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

function TJDFontButton.GetEnabled: Boolean;
begin
  Result:= inherited Enabled;
end;

function TJDFontButton.GetFont: TFont;
begin
  Result:= inherited Font;
end;

function TJDFontButton.GetText: TCaption;
begin
  Result:= inherited Caption;
end;

procedure TJDFontButton.SetCancel(const Value: Boolean);
begin
  FCancel := Value;
  Invalidate;
end;

procedure TJDFontButton.SetText(const Value: TCaption);
begin
  inherited Text:= Value;
  Invalidate;
end;

procedure TJDFontButton.SetColor(Value: TColor);
begin
  FColor := Value;
  Invalidate;
end;

procedure TJDFontButton.SetEnabled(Value: Boolean);
begin
  inherited Enabled:= Value;
  Invalidate;
end;

procedure TJDFontButton.SetFont(const Value: TFont);
begin
  inherited Font.Assign(Value);
  Invalidate;
end;

procedure TJDFontButton.SetImage(const Value: TJDFontButtonImage);
begin
  FImage.Assign(Value);
  Invalidate;
end;

procedure TJDFontButton.SetShowFocusRect(const Value: Boolean);
begin
  FShowFocusRect := Value;
  Invalidate;
end;

procedure TJDFontButton.SetShowGuides(const Value: Boolean);
begin
  FShowGuides := Value;
  Invalidate;
end;

procedure TJDFontButton.SetSpacing(const Value: Integer);
begin
  FSpacing := Value;
  Invalidate;
end;

procedure TJDFontButton.SetStyleColors(const Value: TJDFontButtonStyleColors);
begin
  FStyleColors := Value;
  Invalidate;
end;

procedure TJDFontButton.SetSubText(const Value: TCaption);
begin
  FSubText := Value;
  Invalidate;
end;

procedure TJDFontButton.SetSubTextFont(const Value: TFont);
begin
  FSubTextFont.Assign(Value);
  Invalidate;
end;

procedure TJDFontButton.SetSubTextStyle(const Value: TJDFontButtonSubTextStyle);
begin
  FSubTextStyle := Value;
  Invalidate;
end;

procedure TJDFontButton.SetDefault(const Value: Boolean);
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

procedure TJDFontButton.SetDownSize(const Value: Integer);
begin
  if Value < 1 then begin
    FDownSize:= 1;
    Invalidate;
    raise Exception.Create('Down size must be at least 1');
  end;
  FDownSize := Value;
  Invalidate;
end;

procedure TJDFontButton.SetDrawStyle(const Value: TJDFontButtonDrawStyle);
begin
  FDrawStyle := Value;
  Invalidate;
end;

procedure TJDFontButton.SetImagePosition(const Value: TJDFontButtonImgPosition);
begin
  FImagePosition := Value;
  Invalidate;
end;

procedure TJDFontButton.SetMargin(const Value: Integer);
begin
  FMargin := Value;
  Invalidate;
end;

procedure TJDFontButton.SetOverlay(const Value: TJDFontButtonOverlay);
begin
  FOverlay.Assign(Value);
  Invalidate;
end;

procedure TJDFontButton.SetParentColorOverride(const Value: Boolean);
begin
  FParentColorOverride := Value;
  Invalidate;
end;

function TJDFontButton.State: TJDFontButtonState;
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

procedure TJDFontButton.SubTextFontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDFontButton.WMFontChange(var Message: TMessage);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TJDFontButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result:= DLGC_BUTTON;
  inherited;
end;

procedure TJDFontButton.WMKeyDown(var Message: TWMKeyDown);
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

procedure TJDFontButton.WMKeyUp(var Message: TWMKeyUp);
begin
  FClicking:= False;
  Invalidate;
  Repaint;
  inherited;
end;

procedure TJDFontButton.WMKillFocus(var Message: TWMKillFocus);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TJDFontButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMMButtonDown(var Message: TWMMButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMMButtonUp(var Message: TWMMButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTCLIENT;
  //TODO...
end;

procedure TJDFontButton.WMRButtonDown(var Message: TWMRButtonDown);
begin
  FClicking:= True;
  if TabStop then
    SetFocus;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMRButtonUp(var Message: TWMRButtonUp);
begin
  FClicking:= False;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMResize(var Message: TWMSize);
begin
  Invalidate;
  inherited;
end;

procedure TJDFontButton.WMSetFocus(var Message: TWMSetFocus);
begin
  Invalidate;
  Repaint;
  inherited;
end;

procedure TJDFontButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if (Message.keydata and $20000000) <> 0 then begin
    if IsAccel(Message.charcode, Text) then begin
      Click;
      Message.Result := 1;
    end;
  end;
  inherited;
end;

procedure TJDFontButton.CMMouseEnter(var Message: TMessage);
begin
  if Enabled then
    FHovering:= True;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.CMMouseLeave(var Message: TMessage);
begin
  FHovering:= False;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.CMStyleChanged(var Message: TMessage);
begin
  Reset;
  inherited;
end;

procedure TJDFontButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if Sender is TJDFontButton then
      FActive := Sender = Self
    else
      FActive := FDefault;
  Invalidate;
  inherited;
end;

procedure TJDFontButton.CMDialogKey(var Message: TCMDialogKey);
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

procedure TJDFontButton.Reset;
begin
  FHovering:= False;
  FClicking:= False;
  Invalidate;
end;

procedure TJDFontButton.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then Form.ModalResult := ModalResult;
  inherited Click;
end;

function TJDFontButton.BackColor: TColor;
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

function TJDFontButton.ParentIsDark: Boolean;
begin
  Result:= False;
  //TODO: Detect parent control's background color,
  //  return whether it's a light or dark color

end;

function TJDFontButton.CaptionColor: TColor;
begin
  Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
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

function TJDFontButton.OverlayColor: TColor;
begin
  //TODO: Return color of overlay image glyph...
  Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
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
          Result:= ColorManager.Color[Overlay.StandardColor];
        end else begin
          Result:= TStyleManager.ActiveStyle.GetSystemColor(Overlay.Font.Color);
        end;
      end;
    end;
  end;
end;

function TJDFontButton.ImageColor: TColor;
begin
  Result:= TStyleManager.ActiveStyle.GetStyleFontColor(sfButtonTextNormal);
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

function TJDFontButton.OverlayFontSize: Integer;
const
  RANGE_MIN = 6;
  RANGE_MAX = 3000;
  DIVIDE_BY = 1.7;
  SHRINK_BY = 3;
var
  P: TPoint;
begin
  //TODO: Return the font size for image overlay glyph...
  Result:= FOverlay.Font.Size;
  //TODO: HOW THE HELL DOES IMAGEFONTSIZE WORK?!
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

function TJDFontButton.ImageFontSize: Integer;
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

function TJDFontButton.ImageDims: TPoint;
begin
  FTmp.Canvas.Font.Assign(Image.Font);
  FTmp.Canvas.Font.Size:= ImageFontSize;
  //Result.X:= Canvas.TextWidth(Image.Text);
  Result.Y:= FTmp.Canvas.TextHeight(Image.Text);
  Result.X:= Result.Y;
end;

function TJDFontButton.OverlayDims: TPoint;
begin
  FTmp.Canvas.Font.Assign(Overlay.Font);
  FTmp.Canvas.Font.Size:= OverlayFontSize;
  //Result.X:= Canvas.TextWidth(Overlay.Text);
  Result.Y:= FTmp.Canvas.TextHeight(Overlay.Text);
  Result.X:= Result.Y;
end;

function TJDFontButton.CaptionDims: TPoint;
begin
  //Returns the dimensions of the caption text with given font
  FTmp.Canvas.Font.Assign(Font);
  Result.X:= FTmp.Canvas.TextWidth(Text);
  Result.Y:= FTmp.Canvas.TextHeight(Text);
end;

function TJDFontButton.ContentRect: TRect;
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

function TJDFontButton.CaptionRect: TRect;
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

function TJDFontButton.SubCaptionRect: TRect;
var
  Dims: TPoint;
  T: Integer;
begin
  Result:= CaptionRect;
  Dims:= CaptionDims;

  case ImagePosition of
    fpImgTop: begin
      //Text resized on bottom, image filled on top
      T:= Result.Height;
      Result.Top:= Result.Bottom;
      Result.Height:= T;
    end;
    fpImgBottom: begin
      //Text resized on top, image filled on bottom
      T:= Result.Height;
      Result.Top:= Result.Top - T;
      Result.Height:= T;
    end;
    fpImgLeft: begin
      //Image resized on left, text filled on right
      //Result.Left:= Result.Right - Dims.X;
      Result.Top:= Result.Top + 30; //TEMPORARY
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

function TJDFontButton.ImageRect: TRect;
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

function TJDFontButton.OverlayRect: TRect;
var
  Dims: TPoint;
  M: Integer;
begin
  Result:= ImageRect;
  Dims:= OverlayDims;
  M:= FOverlay.Margin;

  //TODO: Return rect of overlay image glyph...
  case FOverlay.FPosition of
    foNone: begin
      //No overlay image
    end;
    foTopLeft: begin
      //Overlay on top-left
      Result.Width:= Dims.X + M;
      Result.Height:= Dims.Y + M;
      Result.Left:= Result.Left + M;
      Result.Top:= Result.Top + M;
    end;
    foTopRight: begin
      //Overlay on top-right
      Result.Top:= Result.Top + FOverlay.FMargin;
      Result.Left:= (Result.Right) - Dims.X - M;
      Result.Height:= Dims.Y;
      Result.Width:= Dims.X;
    end;
    foBottomLeft: begin
      //Overlay on bottom-left
      Result.Top:= (Result.Bottom) - Dims.Y - M;
      Result.Left:= Result.Left + M;
      Result.Width:= Dims.X;
      Result.Height:= Dims.Y;
    end;
    foBottomRight: begin
      //Overlay on bottom-right
      Result.Left:= (Result.Right) - Dims.X - M;
      Result.Top:= (Result.Bottom) - Dims.Y - M;
      Result.Width:= Result.Width - M;
      Result.Height:= Result.Height - M;
    end;
    foCenter: begin
      //Overlay centered with main image
      //Keep same?
    end;
  end;
end;

function TJDFontButton.CaptionFlags: Cardinal;
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

function TJDFontButton.SubCaptionFlags: Cardinal;
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

function TJDFontButton.ImageFlags: Cardinal;
begin
  Result:= DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_NOCLIP;
end;

procedure TJDFontButton.DrawTheme;
const
  WordBreakFlag: array[Boolean] of Integer = (0, DT_WORDBREAK);
var
  Details:  TThemedElementDetails;
  DrawRect: TRect;
begin
  //Draw VCL Styles themed button background...
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

procedure TJDFontButton.DrawBtn;
var
  R: TRect;
begin
  //Draw Windows Standard Button Background
  R:= ActiveCanvas.ClipRect;
  if JDIsThemeActive then begin
    //If Windows Themes are Enabled
    DrawThemeBackground(FButtonTheme, ActiveCanvas.Handle, 1, JDButtonStateToInt(State), R, nil);
  end else begin
    //If Windows Themes are Disabled
    DrawFrameControl(ActiveCanvas.Handle, R, DFC_BUTTON, DFCS_BUTTONPUSH);
  end;
end;

function TJDFontButton.GlyphImageIndex: Integer;
var
  L: TCharArray;
  X: Integer;
begin
  Result:= -1;
  L:= JD.FontGlyphs.GetFontGlyphs(ActiveCanvas.Handle, True);
  for X := 0 to Length(L)-1 do begin
    if L[X] = FImage.Text then begin
      Result:= X;
      Break;
    end;
  end;
end;

function TJDFontButton.GlyphImageByIndex(const Index: Integer): TCaption;
var
  L: TCharArray;
begin
  Result:= ' ';
  L:= JD.FontGlyphs.GetFontGlyphs(ActiveCanvas.Handle, True);
  if (Index >= 0) and (Index < Length(L)) then begin
    Result:= L[Index];
  end;
end;

{$IFDEF FB_ACTIONS}
procedure TJDFontButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then begin
    with TCustomAction(Sender) do begin
      if not CheckDefaults or (Self.HelpContext = 0) then
        Self.HelpContext := HelpContext;
      Self.Text:= Caption;
      Self.Enabled:= Enabled;
      Self.Visible:= Visible;
      {$IFDEF FB_ACTIONS_IMG}
      Self.Image.Text:= GlyphImageByIndex(ImageIndex);
      {$ENDIF}
    end;
  end;
  Invalidate;
end;
{$ENDIF}

function TJDFontButton.ActiveCanvas: TCanvas;
begin
  //Returns whichever canvas to draw to based on whether BUF_BMP is defined
  Result:= Canvas;
end;

procedure TJDFontButton.DrawBackground;
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

procedure TJDFontButton.DrawCaption;
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
    DrawTextW(ActiveCanvas.Handle, Text, Length(Text), R, CaptionFlags);

    //Sub Caption
    if SubTextStyle <> fsNone then begin
      ActiveCanvas.Font.Assign(SubTextFont);
      R:= SubCaptionRect;
      if FShowGuides then begin
        ActiveCanvas.Pen.Style:= psSolid;
        ActiveCanvas.Pen.Color:= clBlack;
        ActiveCanvas.Pen.Width:= 1;
        ActiveCanvas.Rectangle(R);
      end;
      //TODO: Finish implmentation of SubText
      DrawTextW(ActiveCanvas.Handle, SubText, Length(SubText), R, SubCaptionFlags);
    end;

  end;
end;

procedure TJDFontButton.DrawImage;
var
  R: TRect;
begin
  //Image Glyph
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
    DrawTextW(ActiveCanvas.Handle, FImage.Text, Length(FImage.Text), R, ImageFlags);
  end;

  //Overlay Glyph
  if Overlay.Position <> foNone then begin
    R:= OverlayRect;
    ActiveCanvas.Font.Assign(FOverlay.Font);
    ActiveCanvas.Font.Size:= OverlayFontSize;
    ActiveCanvas.Brush.Style:= bsClear;
    ActiveCanvas.Pen.Style:= psClear;
    ActiveCanvas.Font.Color:= OverlayColor;
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
    DrawTextW(ActiveCanvas.Handle, FOverlay.Text, Length(FOverlay.Text), R, ImageFlags);
  end;

end;

procedure TJDFontButton.DrawFocus;
begin
  //Focus Frame
  if (Focused) and (FShowFocusRect) then begin
    DrawFocusRect(ActiveCanvas.Handle, ActiveCanvas.ClipRect);
  end;
end;

procedure TJDFontButton.Paint;
var
  PS: PAINTSTRUCT;
begin
  BeginPaint(Handle, PS);
  try
    DrawBackground;
    DrawCaption;
    DrawImage;
    DrawFocus;
  finally
    EndPaint(Handle, PS);
  end;
end;

procedure TJDFontButton.SetKind(const Value: TJDFontButtonKind);
begin
  if Value = FKind then Exit;
  
  if Value <> fkCustom then begin
    //Standard for all
    Image.Font.Name:= 'FontAwesome';
    Image.UseStandardColor:= True;
    Image.StandardColor:= fcNeutral;
    StyleColors:= StyleColors - [scImage];
  end;
  //TODO: Change values below to FontAwesom...
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

end.

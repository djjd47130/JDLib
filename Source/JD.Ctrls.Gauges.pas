unit JD.Ctrls.Gauges;

//GDI+ in DLLs: https://stackoverflow.com/questions/34871348/program-hangs-when-unloading-a-dll-making-use-of-gdiplus

//GDI+ Gradients: https://stackoverflow.com/questions/4736582/gdi-how-to-fill-a-triangle

interface

{$DEFINE USE_GDIP}

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.UITypes,
  System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Dialogs,
  JD.Common, JD.Ctrls, JD.Graphics, JD.FontGlyphs,
  {$IFDEF USE_GDIP}
  GDIPAPI, GDIPOBJ, GDIPUTIL,
  {$ENDIF}
  ActiveX, ComObj;

type
  TJDGauge = class;
  TJDGaugeTicks = class;
  TJDGaugeTickLabels = class;
  TJDGaugeValue = class;
  TJDGaugeValues = class;

  ///  <summary>
  ///  The type of gauge, such as circle, arc, horz bar, vert bar, etc.
  ///  Available types depends on units used which register various gauge types.
  ///  </summary>
  TJDGaugeTypeClass = String;

  ///  <summary>
  ///  The class of a type of gauge, such as TJDGaugeCircle, etc.
  ///  </summary>
  TJDGaugeBaseClass = class of TJDGaugeBase;

  ///  <summary>
  ///  A list of available class types that can be used on gauges.
  ///  </summary>
  TJDGaugeClassList = TList<TJDGaugeBaseClass>;

  ///  <summary>
  ///  Defines the types of line start/end caps in GDI+.
  ///  </summary>
  TJDLineCap = (
    lcFlat          = 0,
    lcSquare        = 1,
    lcRound         = 2,
    lcTriangle      = 3
  );

  ///  <summary>
  ///  Defines the position of tick marks relative to the base.
  ///  </summary>
  TJDGaugeTickPos = (
    tpDefault,
    tpOutside,
    tpInside,
    tpCenter
  );

  ///  <summary>
  ///  Defines how multiple gauge values are grouped together.
  ///  </summary>
  TJDGaugeGrouping = (
    ctDefault,
    ctOverlay,
    ctStack,
    ctStackReverse,
    ctMerge,
    ctMergeReverse
  );

  ///  <summary>
  ///  Defines the orientation of a tick label on a gauge.
  ///  </summary>
  TJDGaugeTickLabelOrientation = (
    loNormal,
    loAngle,
    loRightAngle
  );

  TJDGaugeElement = (
    geNothing,
    geBackground,
    geBase,
    geGlyph,
    geCaption,
    geSubCaption,
    geValue,
    geValueCaption,
    geValueGlyph
  );

  ///  <summary>
  ///  Event type specific to a particular value object.
  ///  </summary>
  TJDGaugeValueEvent = procedure(Sender: TJDGauge; Value: TJDGaugeValue) of object;

  TJDGaugeCrosshairs = class(TPersistent)
  private
    FOwner: TJDGauge;
    FVertVisible: Boolean;
    FHorzVisible: Boolean;
    FVertColor: TJDColorRef;
    FHorzColor: TJDColorRef;
    FVertThickness: Single;
    FHorzThickness: Single;
    procedure SetHorzVisible(const Value: Boolean);
    procedure SetVertVisible(const Value: Boolean);
    procedure SetHorzColor(const Value: TJDColorRef);
    procedure SetVertColor(const Value: TJDColorRef);
    procedure SetHorzThickness(const Value: Single);
    procedure SetVertThickness(const Value: Single);
  public
    constructor Create(AGauge: TJDGauge);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property HorzColor: TJDColorRef read FHorzColor write SetHorzColor;
    property VertColor: TJDColorRef read FVertColor write SetVertColor;
    property HorzVisible: Boolean read FHorzVisible write SetHorzVisible;
    property VertVisible: Boolean read FVertVisible write SetVertVisible;
    property HorzThickness: Single read FHorzThickness write SetHorzThickness;
    property VertThickness: Single read FVertThickness write SetVertThickness;
  end;

  ///  <summary>
  ///  Defines options to draw with a gradient brush.
  ///  </summary>
  TJDGaugeGradient = class(TPersistent)
  private
    FOwner: TJDGauge;
    FColor2: TJDColorRef;
    FColor1: TJDColorRef;
    FPoint2X: Single;
    FPoint2Y: Single;
    FPoint1X: Single;
    FPoint1Y: Single;
    FUseGradient: Boolean;
    procedure SetColor1(const Value: TJDColorRef);
    procedure SetColor2(const Value: TJDColorRef);
    procedure SetPoint1X(const Value: Single);
    procedure SetPoint1Y(const Value: Single);
    procedure SetPoint2X(const Value: Single);
    procedure SetPoint2Y(const Value: Single);
    procedure SetUseGradient(const Value: Boolean);
  public
    constructor Create(AOwner: TJDGauge);
    destructor Destroy; override;
    procedure Invalidate;
    function CreateBrush: TGPLinearGradientBrush;
  published
    property Color1: TJDColorRef read FColor1 write SetColor1;
    property Color2: TJDColorRef read FColor2 write SetColor2;
    property Point1X: Single read FPoint1X write SetPoint1X;
    property Point1Y: Single read FPoint1Y write SetPoint1Y;
    property Point2X: Single read FPoint2X write SetPoint2X;
    property Point2Y: Single read FPoint2Y write SetPoint2Y;
    property UseGradient: Boolean read FUseGradient write SetUseGradient default False;
  end;

  ///  <summary>
  ///  Represents settings for the labels associated with tick marks on a gauge.
  ///  </summary>
  TJDGaugeTickLabels = class(TPersistent)
  private
    FOwner: TJDGaugeTicks;
    FFont: TFont;
    FOrientation: TJDGaugeTickLabelOrientation;
    FVisible: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetFont(const Value: TFont);
    procedure SetOrientation(const Value: TJDGaugeTickLabelOrientation);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TJDGaugeTicks);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property Font: TFont read FFont write SetFont;
    property Orientation: TJDGaugeTickLabelOrientation read FOrientation write SetOrientation default loNormal;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  ///  <summary>
  ///  Represents settings for tick marks on a gauge.
  ///  </summary>
  TJDGaugeTicks = class(TPersistent)
  private
    FOwner: TJDGauge;
    FColor: TJDColorRef;
    FInterval: Single;
    FLabels: TJDGaugeTickLabels;
    FLength: Single;
    FPosition: TJDGaugeTickPos;
    FThickness: Single;
    FVisible: Boolean;
    procedure SetColor(const Value: TJDColorRef);
    procedure SetInterval(const Value: Single);
    procedure SetLabels(const Value: TJDGaugeTickLabels);
    procedure SetLength(const Value: Single);
    procedure SetPosition(const Value: TJDGaugeTickPos);
    procedure SetThickness(const Value: Single);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TJDGauge);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
  published
    property Color: TJDColorRef read FColor write SetColor;
    property Interval: Single read FInterval write SetInterval;
    property Labels: TJDGaugeTickLabels read FLabels write SetLabels;
    property Length: Single read FLength write SetLength;
    property Position: TJDGaugeTickPos read FPosition write SetPosition default tpDefault;
    property Thickness: Single read FThickness write SetThickness;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  ///  <summary>
  ///  Internal thread to manage gauge value peak decay.
  ///  DO NOT USE OUTSIDE OF CONTROL.
  ///  </summary>
  TJDGaugePeakDecayThread = class(TThread)
  private
    FOnDecay: TNotifyEvent;
    FDelay: Integer;
    procedure SetDelay(const Value: Integer);
  protected
    procedure Execute; override;
    procedure SYNC_OnDecay;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    property Delay: Integer read FDelay write SetDelay;
    property OnDecay: TNotifyEvent read FOnDecay write FOnDecay;
  end;

  ///  <summary>
  ///  A peak meter which decays by a given step value.
  ///  </summary>
  TJDGaugePeak = class(TPersistent)
  private
    FOwner: TJDGaugeValue;
    FEnabled: Boolean;
    FColor: TJDColorRef;
    FDecay: Double;
    FOnChange: TNotifyEvent;
    FPeakVal: Double;
    FDecayThread: TJDGaugePeakDecayThread;
    FOffsetThickness: Single;
    FDrawOverValue: Boolean;
    procedure SetColor(const Value: TJDColorRef);
    procedure SetEnabled(const Value: Boolean);
    procedure SetDecay(const Value: Double);
    function GetThickness: Single;
    procedure SetOffsetThickness(const Value: Single);
    procedure CreateDecayThread;
    procedure DestroyDecayThread;
    procedure SetDrawOverValue(const Value: Boolean);
  protected
    procedure Changed(Sender: TObject);
    procedure PeakDecay(Sender: TObject);
  public
    constructor Create(AOwner: TJDGaugeValue);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AfterConstruction; override;
    procedure Invalidate;
    property PeakVal: Double read FPeakVal;
    property Thickness: Single read GetThickness;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TJDColorRef read FColor write SetColor;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Decay: Double read FDecay write SetDecay;
    property OffsetThickness: Single read FOffsetThickness write SetOffsetThickness;
    property DrawOverValue: Boolean read FDrawOverValue write SetDrawOverValue default False;
  end;

  ///  <summary>
  ///  Represents a specific value in a TJDGauge control.
  ///  A single gauge can consist of multiple values, but requires
  ///  at least one value item. Each value can have its own color,
  ///  thickness, etc.
  ///  </summary>
  TJDGaugeValue = class(TCollectionItem)
  private
    FOwner: TJDGaugeValues;
    FMax: Double;
    FOffsetThickness: Single;
    FReverse: Boolean;
    FMin: Double;
    FColor: TJDColorRef;
    FCaption: TCaption;
    FValue: Double;
    FStartOffsetPerc: Integer;
    FCapStart: TJDLineCap;
    FCapStop: TJDLineCap;
    FPeak: TJDGaugePeak;
    FGlyph: TJDFontGlyph;
    FTicksMinor: TJDGaugeTicks;
    FTicksMajor: TJDGaugeTicks;
    FSubCaption: String;
    procedure SetCaption(const Value: TCaption);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetMax(const Value: Double);
    procedure SetMin(const Value: Double);
    procedure SetReverse(const Value: Boolean);
    procedure SetValue(const Value: Double);
    procedure Changed(Sender: TObject);
    procedure SetStartOffsetPerc(const Value: Integer);
    procedure SetCapStart(const Value: TJDLineCap);
    procedure SetCapStop(const Value: TJDLineCap);
    procedure SetPeak(const Value: TJDGaugePeak);
    function GetThickness: Single;
    procedure SetOffsetThickness(const Value: Single);
    procedure SetGlyph(const Value: TJDFontGlyph);
    procedure GlyphChanged(Sender: TObject);
    procedure SetTicksMajor(const Value: TJDGaugeTicks);
    procedure SetTicksMinor(const Value: TJDGaugeTicks);
    procedure SetSubCaption(const Value: String);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Invalidate;
    function Range: Double;
    function Percent: Single;
    property Thickness: Single read GetThickness;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property CapStart: TJDLineCap read FCapStart write SetCapStart;
    property CapStop: TJDLineCap read FCapStop write SetCapStop;
    property Glyph: TJDFontGlyph read FGlyph write SetGlyph;
    property Peak: TJDGaugePeak read FPeak write SetPeak;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
    property Value: Double read FValue write SetValue;
    property Color: TJDColorRef read FColor write SetColor;
    property OffsetThickness: Single read FOffsetThickness write SetOffsetThickness;
    property Reverse: Boolean read FReverse write SetReverse default False;
    property StartOffsetPerc: Integer read FStartOffsetPerc write SetStartOffsetPerc default 0;
    property SubCaption: String read FSubCaption write SetSubCaption;
    property TicksMajor: TJDGaugeTicks read FTicksMajor write SetTicksMajor;
    property TicksMinor: TJDGaugeTicks read FTicksMinor write SetTicksMinor;
  end;

  ///  <summary>
  ///  Represents a collection of TJDGuageValue items.
  ///  </summary>
  TJDGaugeValues = class(TOwnedCollection)
  private
    FOwner: TJDGauge;
    function GetItem(Index: Integer): TJDGaugeValue;
    procedure SetItem(Index: Integer; const Value: TJDGaugeValue);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJDGauge); reintroduce;
    destructor Destroy; override;
    procedure Invalidate;
    function Add: TJDGaugeValue;
    function Insert(Index: Integer): TJDGaugeValue;
    property Items[Index: Integer]: TJDGaugeValue read GetItem write SetItem; default;
  end;

  ///  <summary>
  ///  Base abstract class for all possible implementations of the JD Gauge control.
  ///  Inheritance expected - DO NOT CREATE MANUALLY.
  ///  </summary>
  TJDGaugeBase = class(TObject)
    class function GetCaption: String; virtual; abstract;
  private
    FOwner: TJDGauge;
    FGPCanvas: TGPGraphics;
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    FGradBrush: TGPLinearGradientBrush;
    function TextFlags: Cardinal;
    function GetLeftFromAlignment(const A: TAlignment;
      const VR, TR: TJDRect): Single;
  protected
    function GetBaseRect: TJDRect; virtual;
    function GetGlyphRect: TJDRect; virtual;
    function GetValueRect(AValue: TJDGaugeValue): TJDRect; virtual; abstract;
    function GetValueFieldRect(AValue: TJDGaugeValue): TJDRect; virtual;
    function GetCaptionRect(AValue: TJDGaugeValue): TJDRect; virtual;
    function GetSubCaptionRect(AValue: TJDGaugeValue): TJDRect; virtual;
    function GetValueCaptionRect(AValue: TJDGaugeValue): TJDRect; virtual;
    procedure HitTest(const P: TJDPoint; var E: TJDGaugeElement; var V: TJDGaugeValue); virtual;
    procedure PaintBackground; virtual;
    procedure PaintText(AValue: TJDGaugeValue); virtual;
    procedure PaintValueBase(AValue: TJDGaugeValue); virtual; abstract;
    procedure PaintPeak(AValue: TJDGaugeValue); virtual; abstract;
    procedure PaintValue(AValue: TJDGaugeValue); virtual; abstract;
    procedure PaintValueGlyph(AValue: TJDGaugeValue); virtual; abstract;
    procedure PaintValueTicks(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue); virtual;
    procedure PaintValueTick(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue; AVal, AMin, AMax: Double); virtual; abstract;
    procedure PaintGlyph; virtual;
    procedure PaintRect; virtual;
    procedure PaintCrosshairs; virtual;
  public
    constructor Create(AOwner: TJDGauge); virtual;
    destructor Destroy; override;
    procedure PaintStart; virtual;
    procedure PaintStop; virtual;
    property Owner: TJDGauge read FOwner;
    function Canvas: TCanvas;
    property GPCanvas: TGPGraphics read FGPCanvas;
    property Pen: TGPPen read FPen;
    property Brush: TGPSolidBrush read FBrush;
    property GradBrush: TGPLinearGradientBrush read FGradBrush;
  end;

  ///  <summary>
  ///  Base control to implement JD gauge controls. Use properties
  ///  "GaugeType" and "GaugeStyle" to control the appearance of the gauge,
  ///  as well as the "Values" collection property. Each possible value must
  ///  be implemented as a collection item in this "Values" property.
  ///  </summary>
  TJDGauge = class(TJDControl)
  private
    FGaugeObj: TJDGaugeBase;
    FValues: TJDGaugeValues;
    FGlyph: TJDFontGlyph;
    FThickness: Single;
    FColorMain: TJDColorRef;
    FGaugeType: TJDGaugeTypeClass;
    FShowValue: Boolean;
    FShowGlyph: Boolean;
    FShowRect: Boolean;
    FSplit: Boolean;
    FShowCaption: Boolean;
    FValueFormat: String;
    FShowBase: Boolean;
    FGrouping: TJDGaugeGrouping;
    FShowValueGlyphs: Boolean;
    FBaseSize: Single;
    FBaseAutoSize: Boolean;
    FOnValueClick: TJDGaugeValueEvent;
    FCaptionAlign: TAlignment;
    FValueAlign: TAlignment;
    FCaptionMargin: Single;
    FValueMargin: Single;
    FShowSubCaption: Boolean;
    FSubCaptionFont: TFont;
    FSubCaptionMargin: Single;
    FSubCaptionAlign: TAlignment;
    FHoverElement: TJDGaugeElement;
    FHoverValue: TJDGaugeValue;
    FCrosshairs: TJDGaugeCrosshairs;
    FClicking: Boolean;
    FClickPoint: TJDPoint;
    FOnGlyphClick: TNotifyEvent;
    FOnCaptionClick: TJDGaugeValueEvent;
    procedure GlyphChanged(Sender: TObject);
    procedure SetGlyph(const Value: TJDFontGlyph);
    procedure SetThickness(const Value: Single);
    procedure SetColorMain(const Value: TJDColorRef);
    procedure SetShowGlyph(const Value: Boolean);
    procedure SetShowValue(const Value: Boolean);
    procedure SetShowRect(const Value: Boolean);
    procedure SetValues(const Value: TJDGaugeValues);
    procedure SetGaugeType(const Value: TJDGaugeTypeClass);
    procedure SetSplit(const Value: Boolean);
    function GetMainValue: TJDGaugeValue;
    procedure SetMainValue(const Value: TJDGaugeValue);
    function EnsureFirstValueExists: TJDGaugeValue;
    procedure SetShowCaption(const Value: Boolean);
    procedure SetValueFormat(const Value: String);
    procedure SetShowBase(const Value: Boolean);
    procedure SetGrouping(const Value: TJDGaugeGrouping);
    procedure SetShowValueGlyphs(const Value: Boolean);
    procedure SetBaseAutoSize(const Value: Boolean);
    procedure SetBaseSize(const Value: Single);
    procedure SetCaptionAlign(const Value: TAlignment);
    procedure SetValueAlign(const Value: TAlignment);
    procedure SetCaptionMargin(const Value: Single);
    procedure SetValueMargin(const Value: Single);
    procedure SetShowSubCaption(const Value: Boolean);
    procedure SetSubCaptionFont(const Value: TFont);
    procedure SetSubCaptionMargin(const Value: Single);
    procedure SetSubCaptionAlign(const Value: TAlignment);
    procedure SetCrosshairs(const Value: TJDGaugeCrosshairs);
  protected
    procedure Paint; override;
    procedure ValueClick(Value: TJDGaugeValue);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure GlyphClicked; virtual;
    procedure ValueClicked(AValue: TJDGaugeValue); virtual;
    procedure CaptionClicked(AValue: TJDGaugeValue); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AfterConstruction; override;
    property Canvas;
    property HoverElement: TJDGaugeElement read FHoverElement;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;
    property BaseAutoSize: Boolean read FBaseAutoSize write SetBaseAutoSize;
    property BaseSize: Single read FBaseSize write SetBaseSize;
    property CaptionAlign: TAlignment read FCaptionAlign write SetCaptionAlign default taLeftJustify;
    property CaptionMargin: Single read FCaptionMargin write SetCaptionMargin;
    property Color;
    property ColorMain: TJDColorRef read FColorMain write SetColorMain;
    property Crosshairs: TJDGaugeCrosshairs read FCrosshairs write SetCrosshairs;
    property Cursor;
    property DoubleBuffered;
    property Font;
    property GaugeType: TJDGaugeTypeClass read FGaugeType write SetGaugeType;
    property Glyph: TJDFontGlyph read FGlyph write SetGlyph;
    property Grouping: TJDGaugeGrouping read FGrouping write SetGrouping;
    property Hint;
    property ShowBase: Boolean read FShowBase write SetShowBase;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption;
    property ShowGlyph: Boolean read FShowGlyph write SetShowGlyph;
    property ShowHint;
    property ShowRect: Boolean read FShowRect write SetShowRect;
    property ShowSubCaption: Boolean read FShowSubCaption write SetShowSubCaption;
    property ShowValue: Boolean read FShowValue write SetShowValue;
    property ShowValueGlyphs: Boolean read FShowValueGlyphs write SetShowValueGlyphs;
    property Split: Boolean read FSplit write SetSplit;
    property SubCaptionAlign: TAlignment read FSubCaptionAlign write SetSubCaptionAlign;
    property SubCaptionFont: TFont read FSubCaptionFont write SetSubCaptionFont;
    property SubCaptionMargin: Single read FSubCaptionMargin write SetSubCaptionMargin;
    property Thickness: Single read FThickness write SetThickness;
    property Values: TJDGaugeValues read FValues write SetValues;
    property ValueAlign: TAlignment read FValueAlign write SetValueAlign default taRightJustify;
    property ValueFormat: String read FValueFormat write SetValueFormat;
    property ValueMargin: Single read FValueMargin write SetValueMargin;

    property MainValue: TJDGaugeValue read GetMainValue write SetMainValue stored False;

    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;

    property OnCaptionClick: TJDGaugeValueEvent read FOnCaptionClick write FOnCaptionClick;
    property OnGlyphClick: TNotifyEvent read FOnGlyphClick write FOnGlyphClick;
    property OnValueClick: TJDGaugeValueEvent read FOnValueClick write FOnValueClick;
  end;


///  <summary>
///  Returns a list of all available class types for JD Gauges.
///  </summary>
function JDGaugeClasses: TJDGaugeClassList;


///  <summary>
///  Registers a class type for JD Gauges.
///  </summary>
procedure JDRegisterGaugeType(AClass: TJDGaugeBaseClass);


implementation


uses
  JD.Ctrls.Gauges.Objects;

var
  _JDGaugeClasses: TJDGaugeClassList;

function JDGaugeClasses: TJDGaugeClassList;
begin
  if _JDGaugeClasses = nil then
    _JDGaugeClasses:= TJDGaugeClassList.Create;
  Result:= _JDGaugeClasses;
end;

procedure JDRegisterGaugeType(AClass: TJDGaugeBaseClass);
var
  X: Integer;
  N: String;
begin
  try
    if _JDGaugeClasses = nil then
      _JDGaugeClasses:= TJDGaugeClassList.Create;
    if JDGaugeClasses.IndexOf(AClass) >= 0 then
      raise Exception.Create('JD Gauge class "'+AClass.ClassName+'" already registered.');
    N:= AClass.GetCaption;
    for X := 0 to JDGaugeClasses.Count-1 do begin
      if JDGaugeClasses[X].GetCaption = N then
        raise Exception.Create('JD Gauge class caption "'+N+'" already registered.');
    end;
    JDGaugeClasses.Add(AClass);
  except
    on E: Exception do begin
      MessageDlg('Failed to register JD gauge class with error: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

{ TJDGaugeTicks }

constructor TJDGaugeTicks.Create(AOwner: TJDGauge);
begin
  FOwner:= AOwner;
  FLabels:= TJDGaugeTickLabels.Create(Self);
  FColor:= TJDColorRef.Create;
  FInterval:= 10.0;
  FThickness:= 1.0;
  FLength:= 5.0;
  FPosition:= TJDGaugeTickPos.tpDefault;
end;

destructor TJDGaugeTicks.Destroy;
begin
  FreeAndNil(FColor);
  FreeAndNil(FLabels);
  inherited;
end;

procedure TJDGaugeTicks.Assign(Source: TPersistent);
begin
  if Source is TJDGaugeTicks then begin
    FColor.Assign(TJDGaugeTicks(Source).FColor);
    FInterval:= TJDGaugeTicks(Source).FInterval;
    FThickness:= TJDGaugeTicks(Source).FThickness;
    FLength:= TJDGaugeTicks(Source).FLength;
    FVisible:= TJDGaugeTicks(Source).FVisible;
    FLabels.Assign(TJDGaugeTicks(Source).FLabels);
    FPosition:= TJDGaugeTicks(Source).FPosition;
  end else
    inherited;
end;

procedure TJDGaugeTicks.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDGaugeTicks.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeTicks.SetInterval(const Value: Single);
begin
  FInterval := Value;
  Invalidate;
end;

procedure TJDGaugeTicks.SetLabels(const Value: TJDGaugeTickLabels);
begin
  FLabels.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeTicks.SetLength(const Value: Single);
begin
  FLength := Value;
  Invalidate;
end;

procedure TJDGaugeTicks.SetPosition(const Value: TJDGaugeTickPos);
begin
  FPosition := Value;
  Invalidate;
end;

procedure TJDGaugeTicks.SetThickness(const Value: Single);
begin
  FThickness := Value;
  Invalidate;
end;

procedure TJDGaugeTicks.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  Invalidate;
end;

{ TJDGaugeGradient }

constructor TJDGaugeGradient.Create(AOwner: TJDGauge);
begin
  FOwner:= AOwner;
  FColor1:= TJDColorRef.Create;
  FColor2:= TJDColorRef.Create;

  FColor1.UseStandardColor:= True;
  FColor1.StandardColor:= fcBlue;
  FColor2.UseStandardColor:= True;
  FColor2.StandardColor:= fcGray;
  FPoint1X:= 0;
  FPoint1Y:= 0;
  FPoint2X:= 100;
  FPoint2Y:= 100;
  FUseGradient:= False;
end;

function TJDGaugeGradient.CreateBrush: TGPLinearGradientBrush;
begin
  Result:= TGPLinearGradientBrush.Create(
    MakePoint(FPoint1X, FPoint1Y),
    MakePoint(FPoint2X, FPoint2Y),
    ColorToGPColor(FColor1.Color),
    ColorToGPColor(FColor2.Color));
end;

destructor TJDGaugeGradient.Destroy;
begin
  FreeAndNil(FColor2);
  FreeAndNil(FColor1);
  inherited;
end;

procedure TJDGaugeGradient.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDGaugeGradient.SetColor1(const Value: TJDColorRef);
begin
  FColor1.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeGradient.SetColor2(const Value: TJDColorRef);
begin
  FColor2.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeGradient.SetPoint1X(const Value: Single);
begin
  FPoint1X := Value;
  Invalidate;
end;

procedure TJDGaugeGradient.SetPoint1Y(const Value: Single);
begin
  FPoint1Y := Value;
  Invalidate;
end;

procedure TJDGaugeGradient.SetPoint2X(const Value: Single);
begin
  FPoint2X := Value;
  Invalidate;
end;

procedure TJDGaugeGradient.SetPoint2Y(const Value: Single);
begin
  FPoint2Y := Value;
  Invalidate;
end;

procedure TJDGaugeGradient.SetUseGradient(const Value: Boolean);
begin
  FUseGradient := Value;
  Invalidate;
end;

{ TJDGaugeTickLabels }

constructor TJDGaugeTickLabels.Create(AOwner: TJDGaugeTicks);
begin
  FOwner:= AOwner;
  FFont:= TFont.Create;
  FFont.OnChange:= FontChanged;

  FVisible:= False;
  FOrientation:= loNormal;
end;

destructor TJDGaugeTickLabels.Destroy;
begin

  inherited;
end;

procedure TJDGaugeTickLabels.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDGaugeTickLabels.Assign(Source: TPersistent);
begin
  //TODO
end;

procedure TJDGaugeTickLabels.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDGaugeTickLabels.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FFont.OnChange:= FontChanged;
  Invalidate;
end;

procedure TJDGaugeTickLabels.SetOrientation(
  const Value: TJDGaugeTickLabelOrientation);
begin
  FOrientation := Value;
  Invalidate;
end;

procedure TJDGaugeTickLabels.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  Invalidate;
end;

{ TJDGaugeCrosshairs }

constructor TJDGaugeCrosshairs.Create(AGauge: TJDGauge);
begin
  FOwner:= AGauge;
  FHorzColor:= TJDColorRef.Create;
  FVertColor:= TJDColorRef.Create;
end;

destructor TJDGaugeCrosshairs.Destroy;
begin
  FreeAndNil(FVertColor);
  FreeAndNil(FHorzColor);
  inherited;
end;

procedure TJDGaugeCrosshairs.Assign(Source: TPersistent);
var
  V: TJDGaugeCrosshairs;
begin
  if Source is TJDGaugeCrosshairs then begin
    V:= TJDGaugeCrosshairs(Source);
    FHorzColor.Assign(V.HorzColor);
    FVertColor.Assign(V.VertColor);
    FHorzThickness:= V.HorzThickness;
    FVertThickness:= V.VertThickness;
    FHorzVisible:= V.HorzVisible;
    FVertVisible:= V.VertVisible;
  end else
    inherited;
end;

procedure TJDGaugeCrosshairs.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDGaugeCrosshairs.SetHorzColor(const Value: TJDColorRef);
begin
  FHorzColor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeCrosshairs.SetHorzThickness(const Value: Single);
begin
  if Value = FHorzThickness then Exit;
  FHorzThickness := Value;
  Invalidate;
end;

procedure TJDGaugeCrosshairs.SetHorzVisible(const Value: Boolean);
begin
  if Value = FHorzVisible then Exit;
  FHorzVisible := Value;
  Invalidate;
end;

procedure TJDGaugeCrosshairs.SetVertColor(const Value: TJDColorRef);
begin
  FVertColor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeCrosshairs.SetVertThickness(const Value: Single);
begin
  if Value = FVertThickness then Exit;
  FVertThickness := Value;
  Invalidate;
end;

procedure TJDGaugeCrosshairs.SetVertVisible(const Value: Boolean);
begin
  if Value = FVertVisible then Exit;
  FVertVisible := Value;
  Invalidate;
end;

{ TJDGaugePeakDecayThread }

constructor TJDGaugePeakDecayThread.Create;
begin
  inherited Create(False);
  FDelay:= 35;
end;

destructor TJDGaugePeakDecayThread.Destroy;
begin

  inherited;
end;

procedure TJDGaugePeakDecayThread.Execute;
begin
  while not Terminated do begin
    try
      Sleep(FDelay);
      if Terminated then Break;
      Synchronize(SYNC_OnDecay);
    except
      on E: Exception do begin
        //TODO
      end;
    end;
  end;
end;

procedure TJDGaugePeakDecayThread.SetDelay(const Value: Integer);
begin
  FDelay := Value;
end;

procedure TJDGaugePeakDecayThread.SYNC_OnDecay;
begin
  if Assigned(FOnDecay) then
    FOnDecay(Self);
end;

{ TJDGaugePeak }

constructor TJDGaugePeak.Create(AOwner: TJDGaugeValue);
begin
  FOwner:= AOwner;

  CreateDecayThread;

  FColor:= TJDColorRef.Create;
  FColor.UseStandardColor:= True;
  FColor.StandardColor:= fcNeutral;
  FColor.OnChange:= Changed;

  FEnabled:= False;
  FOffsetThickness:= 0;
  FDecay:= 1.0
end;

procedure TJDGaugePeak.AfterConstruction;
begin
  inherited;
end;

destructor TJDGaugePeak.Destroy;
begin
  DestroyDecayThread;
  FreeAndNil(FColor);
  inherited;
end;

procedure TJDGaugePeak.CreateDecayThread;
begin
  if Assigned(FDecayThread) then Exit;

  FDecayThread:= TJDGaugePeakDecayThread.Create;
  FDecayThread.OnDecay:= Self.PeakDecay;
end;

procedure TJDGaugePeak.DestroyDecayThread;
begin
  if Assigned(FDecayThread) then begin
    FDecayThread.OnDecay:= nil;
    FDecayThread.Terminate;
    FDecayThread.WaitFor;
    FDecayThread.Free;
    FDecayThread:= nil;
  end;
end;

procedure TJDGaugePeak.Assign(Source: TPersistent);
var
  V: TJDGaugePeak;
begin
  if Source is TJDGaugePeak then begin
    V:= TJDGaugePeak(Source);

    FEnabled:= V.Enabled;
    FColor.Assign(V.Color);
    FDecay:= V.Decay;
    FOffsetThickness:= V.OffsetThickness;
    FDrawOverValue:= V.DrawOverValue;
  end else
    inherited;
end;

procedure TJDGaugePeak.Changed(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDGaugePeak.Invalidate;
begin
  if Application.Terminated then Exit;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TJDGaugePeak.PeakDecay(Sender: TObject);
begin
  if Application.Terminated then Exit;

  //Decrease peak meter by decay value...
  if not FEnabled then Exit;
  FPeakVal:= FPeakVal - FDecay;
  //Don't go below 0
  if FPeakVal < 0 then
    FPeakVal:= 0;
  //Don't go below current value
  if FPeakVal < FOwner.Value then
    FPeakVal:= FOwner.Value;
  Invalidate;
end;

procedure TJDGaugePeak.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugePeak.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  Invalidate;
end;

procedure TJDGaugePeak.SetOffsetThickness(const Value: Single);
begin
  FOffsetThickness := Value;
  Invalidate;
end;

procedure TJDGaugePeak.SetDecay(const Value: Double);
begin
  if Value <= 0 then
    raise Exception.Create('Peak decay must be greater than 0!');
  FDecay := Value;
  Invalidate;
end;

procedure TJDGaugePeak.SetDrawOverValue(const Value: Boolean);
begin
  FDrawOverValue := Value;
  Invalidate;
end;

function TJDGaugePeak.GetThickness: Single;
begin
  Result:= FOwner.FOwner.FOwner.FThickness + FOffsetThickness;
end;

{ TJDGaugeValue }

constructor TJDGaugeValue.Create(ACollection: TCollection);
begin
  inherited;
  FOwner:= TJDGaugeValues(ACollection);

  FGlyph:= TJDFontGlyph.Create;
  FGlyph.OnChange:= Self.GlyphChanged;

  FColor:= TJDColorRef.Create;
  FColor.UseStandardColor:= False;
  FColor.Color:= clSkyBlue;
  FColor.OnChange:= Changed;

  FPeak:= TJDGaugePeak.Create(Self);
  FPeak.OnChange:= Changed;

  FTicksMajor:= TJDGaugeTicks.Create(Self.FOwner.FOwner);
  FTicksMinor:= TJDGaugeTicks.Create(Self.FOwner.FOwner);

  FOffsetThickness:= 0;
  FMin:= 0;
  FMax:= 100;
  FValue:= 25;

  FCapStart:= lcFlat;
  FCapStop:= lcFlat;
end;

destructor TJDGaugeValue.Destroy;
begin
  FreeAndNil(FTicksMinor);
  FreeAndNil(FTicksMajor);
  FreeAndNil(FPeak);
  FreeAndNil(FColor);
  FreeAndNil(FGlyph);
  inherited;
end;

procedure TJDGaugeValue.Assign(Source: TPersistent);
var
  V: TJDGaugeValue;
begin
  if Source is TJDGaugeValue then begin
    V:= TJDGaugeValue(Source);
    FMax:= V.Max;
    FOffsetThickness:= V.OffsetThickness;
    FReverse:= V.Reverse;
    FMin:= V.Min;
    FColor.Assign(V.Color);
    FCaption:= V.Caption;
    FValue:= V.Value;
    FStartOffsetPerc:= V.StartOffsetPerc;
    FCapStart:= V.CapStart;
    FCapStop:= V.CapStop;
    FPeak.Assign(V.Peak);
    FGlyph.Assign(V.Glyph);
    FTicksMinor.Assign(V.TicksMinor);
    FTicksMajor.Assign(V.TicksMajor);
    FSubCaption:= V.SubCaption;
  end else
    inherited;
end;

procedure TJDGaugeValue.Changed(Sender: TObject);
begin
  Invalidate;
end;

function TJDGaugeValue.GetDisplayName: String;
begin
  if FCaption <> '' then
    Result:= FCaption
  else
    Result:= inherited;
end;

function TJDGaugeValue.GetThickness: Single;
begin
  Result:= FOwner.FOwner.FThickness + FOffsetThickness;
end;

procedure TJDGaugeValue.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDGaugeValue.Invalidate;
begin
  if Application.Terminated then Exit;
  FOwner.Invalidate;
end;

function TJDGaugeValue.Percent: Single;
begin
  //TODO: Account for Min...
  Result:= (FValue / FMax);
end;

function TJDGaugeValue.Range: Double;
begin
  Result:= FMin + FMax;
end;

procedure TJDGaugeValue.SetCapStart(const Value: TJDLineCap);
begin
  if Value = FCapStart then Exit;
  FCapStart := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetCapStop(const Value: TJDLineCap);
begin
  if Value = FCapStop then Exit;
  FCapStop := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetCaption(const Value: TCaption);
begin
  if Value = FCaption then Exit;
  FCaption := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeValue.SetGlyph(const Value: TJDFontGlyph);
begin
  FGlyph.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeValue.SetPeak(const Value: TJDGaugePeak);
begin
  FPeak.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeValue.SetMax(const Value: Double);
begin
  if Value = FMax then Exit;
  FMax := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetMin(const Value: Double);
begin
  if Value = FMin then Exit;
  FMin := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetOffsetThickness(const Value: Single);
begin
  if Value = FOffsetThickness then Exit;
  FOffsetThickness := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetReverse(const Value: Boolean);
begin
  if Value = FReverse then Exit;
  FReverse := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetStartOffsetPerc(const Value: Integer);
begin
  if Value = FStartOffsetPerc then Exit;
  FStartOffsetPerc := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetSubCaption(const Value: String);
begin
  if Value = FSubCaption then Exit;
  FSubCaption := Value;
  Invalidate;
end;

procedure TJDGaugeValue.SetTicksMajor(const Value: TJDGaugeTicks);
begin
  FTicksMajor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeValue.SetTicksMinor(const Value: TJDGaugeTicks);
begin
  FTicksMinor.Assign(Value);
  Invalidate;
end;

procedure TJDGaugeValue.SetValue(const Value: Double);
begin
  if Application.Terminated then Exit;
  if Value = FValue then Exit;
  
  FValue := Value;
  if FPeak.Enabled then begin
    if Value > FPeak.FPeakVal then
      FPeak.FPeakVal:= Value;
  end;
  Invalidate;
end;

{ TJDGaugeValues }

constructor TJDGaugeValues.Create(AOwner: TJDGauge);
begin
  inherited Create(AOwner, TJDGaugeValue);
  FOwner:= AOwner;
end;

destructor TJDGaugeValues.Destroy;
begin

  inherited;
end;

function TJDGaugeValues.Add: TJDGaugeValue;
begin
  Result:= TJDGaugeValue(inherited Add);
  Invalidate;
end;

function TJDGaugeValues.GetItem(Index: Integer): TJDGaugeValue;
begin
  Result:= TJDGaugeValue(inherited Items[Index]);
end;

function TJDGaugeValues.Insert(Index: Integer): TJDGaugeValue;
begin
  Result:= TJDGaugeValue(inherited Insert(Index));
  Invalidate;
end;

procedure TJDGaugeValues.Invalidate;
begin
  if Application.Terminated then Exit;

  if Assigned(FOwner) then
    FOwner.Invalidate;
end;

procedure TJDGaugeValues.SetItem(Index: Integer; const Value: TJDGaugeValue);
begin
  inherited Items[Index]:= Value;
  Invalidate;
end;

procedure TJDGaugeValues.Update(Item: TCollectionItem);
begin
  inherited;
  Invalidate;
end;

{ TJDGaugeBase }

constructor TJDGaugeBase.Create(AOwner: TJDGauge);
begin
  FOwner:= AOwner;

end;

destructor TJDGaugeBase.Destroy;
begin

  inherited;
end;

function TJDGaugeBase.Canvas: TCanvas;
begin
  Result:= FOwner.Canvas;
end;

function TJDGaugeBase.GetBaseRect: TJDRect;
begin
  if Owner.BaseAutoSize then begin
    Result:= Owner.ClientRect;
    if Owner.ShowGlyph then begin
      Result.Left:= Result.Height;
    end;
  end else begin
    //TODO: Implement manual sizing...
    Result:= Owner.ClientRect;
    //Result.Width:= Owner.ClientWidth;
    //Result.Height:= Owner.BaseSize;
    //Result.Top:= (Owner.ClientHeight / 2) - (Result.Height / 2);
  end;
end;

function TJDGaugeBase.GetGlyphRect: TJDRect;
begin
  Result:= Owner.ClientRect;
  Result.Width:= Result.Height;
end;

function TJDGaugeBase.TextFlags: Cardinal;
begin
  Result:= DT_SINGLELINE or DT_VCENTER or DT_LEFT;
end;

function TJDGaugeBase.GetLeftFromAlignment(const A: TAlignment;
  const VR, TR: TJDRect): Single;
begin
  case A of
    taLeftJustify: begin
      Result:= VR.Left + Owner.CaptionMargin;
    end;
    taRightJustify: begin
      Result:= VR.Right - TR.Width - Owner.CaptionMargin;
    end;
    taCenter: begin
      Result:= (VR.Width / 2) - (TR.Width / 2);
    end;
    else begin
      Result:= 0;
    end;
  end;
end;

function TJDGaugeBase.GetCaptionRect(AValue: TJDGaugeValue): TJDRect;
var
  VR, TR: TJDRect;
begin
  VR:= GetValueRect(AValue);
  if Owner.ShowGlyph then begin
    VR.Left:= VR.Left + Result.Height;
  end;
  if Owner.ShowValueGlyphs then begin
    //TODO
  end;
  Result:= VR;
  TR:= Rect(0, 0, 5, 5);
  Canvas.Font.Assign(Owner.Font);
  DrawTextJD(Canvas.Handle, AValue.Caption, TR, TextFlags or DT_CALCRECT);
  TR.Inflate(4, 4);
  Result.Top:= (VR.Height / 2) - (TR.Height / 2);
  Result.Left:= GetLeftFromAlignment(Owner.CaptionAlign, VR, TR);
  Result.Width:= TR.Width;
  Result.Height:= TR.Height;
end;

function TJDGaugeBase.GetSubCaptionRect(AValue: TJDGaugeValue): TJDRect;
var
  VR, TR: TJDRect;
begin
  VR:= GetValueRect(AValue);
  if Owner.ShowGlyph then begin
    VR.Left:= VR.Left + Result.Height;
  end;
  if Owner.ShowValueGlyphs then begin
    //TODO
  end;
  Result:= VR;
  TR:= Rect(0, 0, 5, 5);
  Canvas.Font.Assign(Owner.SubCaptionFont);
  DrawTextJD(Canvas.Handle, AValue.SubCaption, TR, TextFlags or DT_CALCRECT);
  TR.Inflate(4, 4);
  Result.Top:= (VR.Height / 2) - (TR.Height / 2);
  Result.Left:= GetLeftFromAlignment(Owner.SubCaptionAlign, VR, TR);
  Result.Width:= TR.Width;
  Result.Height:= TR.Height;
end;

function TJDGaugeBase.GetValueCaptionRect(AValue: TJDGaugeValue): TJDRect;
var
  VR, TR: TJDRect;
begin
  VR:= GetValueRect(AValue);
  if Owner.ShowGlyph then begin
    VR.Left:= VR.Left + Result.Height;
  end;
  if Owner.ShowValueGlyphs then begin
    //TODO
  end;
  Result:= VR;
  TR:= Rect(0, 0, 5, 5);
  Canvas.Font.Assign(Owner.Font);
  DrawTextJD(Canvas.Handle, FormatFloat(Owner.ValueFormat, AValue.Value), TR, TextFlags or DT_CALCRECT);
  TR.Inflate(4, 4);
  Result.Top:= (VR.Height / 2) - (TR.Height / 2);
  Result.Left:= GetLeftFromAlignment(Owner.ValueAlign, VR, TR);
  Result.Width:= TR.Width;
  Result.Height:= TR.Height;
end;

function TJDGaugeBase.GetValueFieldRect(AValue: TJDGaugeValue): TJDRect;
begin
  Result:= GetValueRect(AValue);
  //TODO: Return value rect only consisting of actual gauge drawing area...

end;

procedure TJDGaugeBase.HitTest(const P: TJDPoint; var E: TJDGaugeElement;
  var V: TJDGaugeValue);
var
  X: Integer;
  Val: TJDGaugeValue;
  procedure Chk(const Element: TJDGaugeElement; Rect: TJDRect);
  begin
    if E <> geNothing then Exit;
    if Rect.ContainsPoint(P) then
      E:= Element;
  end;
  procedure ChkVal(const Element: TJDGaugeElement; Rect: TJDRect);
  begin
    if E <> geNothing then Exit;
    if Rect.ContainsPoint(P) then begin
      E:= Element;
      V:= Owner.FValues[X];
    end;
  end;
begin
  //TODO: Determine what element (E) and value (V) are at point (P)...
  E:= geNothing;
  V:= nil;
  Chk(geGlyph, GetGlyphRect);
  for X := 0 to Owner.FValues.Count-1 do begin
    if E <> geNothing then break;
    Val:= Owner.FValues[X];
    ChkVal(geCaption, GetCaptionRect(Val));
    ChkVal(geSubCaption, GetSubCaptionRect(Val));
    ChkVal(geValueCaption, GetValueCaptionRect(Val));
  end;
  Chk(geBase, GetBaseRect);
  Chk(geBackground, TJDRect(Owner.ClientRect));
  {
  TJDGaugeElement = (
    geNothing,
    geBackground,
    geBase,
    geGlyph,
    geCaption,
    geSubCaption,
    geValue,
    geValueCaption,
    geValueGlyph
  );
  }
end;

procedure TJDGaugeBase.PaintText(AValue: TJDGaugeValue);
var
  S: String;
  procedure DoText(const S: String; Font: TFont; A: TAlignment; R: TJDRect; M: Single; E: TJDGaugeElement);
  begin
    Canvas.Font.Assign(Font);
    DrawTextJD(Canvas.Handle, S, R, TextFlags);
    if E = Owner.HoverElement then begin
      Pen.SetWidth(1);
      Pen.SetColor(ColorToGPColor(clSilver));
      GPCanvas.DrawRectangle(Pen, R);
    end;
  end;
  procedure DoCaption;
  begin
    DoText(AValue.Caption, Owner.Font, Owner.CaptionAlign, GetCaptionRect(AValue), Owner.CaptionMargin, geCaption);
  end;
  procedure DoValue;
  begin
    DoText(FormatFloat(Owner.FValueFormat, AValue.Value), Owner.Font,
      Owner.ValueAlign, GetValueCaptionRect(AValue), Owner.ValueMargin, geValueCaption);
  end;
  procedure DoSubCaption;
  begin
    DoText(AValue.SubCaption, Owner.SubCaptionFont, Owner.SubCaptionAlign,
      GetSubCaptionRect(AValue), Owner.SubCaptionMargin, geSubCaption);
  end;
begin
  if Owner.FShowCaption and
    Owner.FShowValue and
    Owner.FShowSubCaption and
    (Owner.CaptionAlign = taCenter) and
    (Owner.ValueAlign = taCenter) and
    (Owner.SubCaptionAlign = taCenter) then
  begin
    //All 3 are centered - combine together...
    S:= AValue.Caption + ' - ' + AValue.SubCaption + ' - ' + FormatFloat(Owner.FValueFormat, AValue.Value);
    DoText(S, Owner.Font, Owner.ValueAlign, GetCaptionRect(AValue), Owner.ValueMargin, geCaption);
  end else
  if Owner.FShowCaption and
    Owner.FShowValue and
    (Owner.CaptionAlign = taCenter) and
    (Owner.ValueAlign = taCenter) then
  begin
    //Both are centered - combine together...
    S:= AValue.Caption + ' - ' + FormatFloat(Owner.FValueFormat, AValue.Value);
    DoText(S, Owner.Font, Owner.ValueAlign, GetCaptionRect(AValue), Owner.ValueMargin, geCaption);
  end else
  if Owner.FShowCaption and
    Owner.FShowSubCaption and
    (Owner.CaptionAlign = taCenter) and
    (Owner.SubCaptionAlign = taCenter) then
  begin
    //Both are centered - combine together...
    S:= AValue.Caption + ' - ' + AValue.SubCaption;
    DoText(S, Owner.Font, Owner.ValueAlign, GetCaptionRect(AValue), Owner.ValueMargin, geCaption);
  end else
  if Owner.FShowSubCaption and
    Owner.FShowValue and
    (Owner.ValueAlign = taCenter) and
    (Owner.SubCaptionAlign = taCenter) then
  begin
    //Both are centered - combine together...
    S:= AValue.SubCaption + ' - ' + FormatFloat(Owner.FValueFormat, AValue.Value);
    DoText(S, Owner.Font, Owner.ValueAlign, GetCaptionRect(AValue), Owner.ValueMargin, geSubCaption);
  end else begin
    if Owner.FShowSubCaption then begin
      DoSubCaption;
    end;
    if Owner.FShowCaption then begin
      DoCaption;
    end;
    if Owner.FShowValue then begin
      DoValue;
    end;
  end;
end;

procedure TJDGaugeBase.PaintBackground;
begin

end;

procedure TJDGaugeBase.PaintCrosshairs;
var
  R: TJDRect;
  P, P1, P2: TJDPoint;
begin
  P:= Owner.ScreenToClient(Mouse.CursorPos);
  R:= Owner.ClientRect;
  if Owner.Crosshairs.VertVisible then begin
    Pen.SetWidth(Owner.Crosshairs.VertThickness);
    Pen.SetColor(ColorToGPColor(Owner.Crosshairs.VertColor.GetColor));
    P1.X:= P.X;
    P1.Y:= R.Top;
    P2.X:= P.X;
    P2.Y:= R.Bottom;
    GPCanvas.DrawLine(Pen, P1, P2);
  end;
  if Owner.Crosshairs.HorzVisible then begin
    Pen.SetWidth(Owner.Crosshairs.HorzThickness);
    Pen.SetColor(ColorToGPColor(Owner.Crosshairs.HorzColor.GetColor));
    P1.X:= R.Left;
    P1.Y:= P.Y;
    P2.X:= R.Right;
    P2.Y:= P.Y;
    GPCanvas.DrawLine(Pen, P1, P2);
  end;
end;

procedure TJDGaugeBase.PaintGlyph;
var
  R: TJDRect;
begin
  R:= GetGlyphRect;
  Canvas.Brush.Style:= bsClear;
  Canvas.Pen.Style:= psClear;
  Canvas.Font.Assign(Owner.Glyph.Font);
  if Owner.Glyph.UseStandardColor then
    Canvas.Font.Color:= ColorManager.Color[Owner.Glyph.StandardColor];
  DrawTextJD(Canvas.Handle, Owner.Glyph.Glyph, R,
    DT_SINGLELINE or DT_CENTER or DT_VCENTER);
  if Owner.FHoverElement = geGlyph then begin
    //Hovering over glyph, draw rectangle...
    Canvas.Pen.Style:= psSolid;
    Pen.SetWidth(1);
    Pen.SetColor(ColorToGPColor(clSilver));
    R.Deflate(1, 1);
    GPCanvas.DrawRectangle(Pen, R);
  end;
end;

procedure TJDGaugeBase.PaintRect;
var
  R: TJDRect;
begin
  R:= GetBaseRect;
  Pen.SetWidth(1);
  Pen.SetColor(ColorToGPColor(clBlack));
  GPCanvas.DrawRectangle(Pen, R);
end;

procedure TJDGaugeBase.PaintStart;
begin
  FGPCanvas:= TGPGraphics.Create(Canvas.Handle);
  FGPCanvas.SetSmoothingMode(SmoothingModeAntiAlias);

  FPen:= TGPPen.Create(ColorToGPColor(Owner.ColorMain.GetColor), Owner.Thickness);
  FPen.SetStartCap(LineCapFlat);
  FPen.SetEndCap(LineCapFlat);

  FBrush:= TGPSolidBrush.Create(ColorToGPColor(Owner.ColorMain.GetColor));

  FGradBrush:= TGPLinearGradientBrush.Create;
end;

procedure TJDGaugeBase.PaintStop;
begin
  FreeAndNil(FGradBrush);
  FreeAndNil(FBrush);
  FreeAndNil(FPen);
  FreeAndNil(FGPCanvas);
end;

procedure TJDGaugeBase.PaintValueTicks(ATicks: TJDGaugeTicks; AValue: TJDGaugeValue);
var
  Val: Double;
begin
  Pen.SetColor(ColorToGPColor(ATicks.Color.GetColor));
  Pen.SetWidth(ATicks.Thickness);
  Val:= 0;
  while (Val <= AValue.Max) do begin
    PaintValueTick(ATicks, AValue, Val, AValue.Min, AValue.Max);
    Val:= Val + ATicks.Interval;
  end;
  //TODO: Reverse

end;

{ TJDGauge }

procedure TJDGauge.Assign(Source: TPersistent);
var
  S: TJDGauge;
begin
  if Source is TJDGauge then begin
    S:= TJDGauge(Source);
    Self.FValues.Assign(S.FValues);
    Self.FGlyph.Assign(S.FGlyph);
    Self.FThickness:= S.FThickness;
    Self.FColorMain.Assign(S.FColorMain);
    Self.GaugeType:= S.GaugeType;
    Self.FShowValue:= S.FShowValue;
    Self.FShowGlyph:= S.FShowGlyph;
    Self.FShowRect:= S.FShowRect;
    Self.FSplit:= S.FSplit;
    Self.FShowCaption:= S.FShowCaption;
    Self.FValueFormat:= S.FValueFormat;
    Self.FShowBase:= S.FShowBase;
    Self.FGrouping:= S.FGrouping;
    Self.FShowValueGlyphs:= S.FShowValueGlyphs;
    Self.FBaseSize:= S.FBaseSize;
    Self.FBaseAutoSize:= S.FBaseAutoSize;
    Self.FOnValueClick:= S.FOnValueClick;
    Self.FCaptionAlign:= S.FCaptionAlign;
    Self.FValueAlign:= S.FValueAlign;
    Self.FCaptionMargin:= S.FCaptionMargin;
    Self.FValueMargin:= S.FValueMargin;
    Self.FShowSubCaption:= S.FShowSubCaption;
    Self.FSubCaptionFont.Assign(S.FSubCaptionFont);
    Self.FSubCaptionMargin:= S.FSubCaptionMargin;
    Self.FSubCaptionAlign:= S.FSubCaptionAlign;
    //TODO: Crosshairs

    Self.Align:= S.Align;
    Self.AlignWithMargins:= S.AlignWithMargins;
    Self.Anchors:= S.Anchors;
    Self.Color:= S.Color;
    Self.Cursor:= S.Cursor;
    Self.Font.Assign(S.Font);
    Self.Caption:= S.Caption;
    Self.DoubleBuffered:= S.DoubleBuffered;
    Self.Hint:= S.Hint;
    Self.ShowHint:= S.ShowHint;
    //TODO...

  end else
    inherited;
end;

procedure TJDGauge.CMMouseEnter(var Message: TMessage);
begin

end;

procedure TJDGauge.CMMouseLeave(var Message: TMessage);
begin
  FHoverElement:= geNothing;
  Invalidate;
end;

constructor TJDGauge.Create(AOwner: TComponent);
begin
  inherited;
  FClicking:= False;
  FGaugeObj:= nil;
  FValues:= TJDGaugeValues.Create(Self);

  DoubleBuffered:= True;

  FGlyph:= TJDFontGlyph.Create;
  FGlyph.OnChange:= GlyphChanged;

  FSubCaptionFont:= TFont.Create;
  FSubCaptionFont.OnChange:= GlyphChanged;

  FColorMain:= TJDColorRef.Create;
  FColorMain.UseStandardColor:= False;
  FColorMain.Color:= clSilver;
  FColorMain.OnChange:= GlyphChanged;

  FCrosshairs:= TJDGaugeCrosshairs.Create(Self);

  Width:= 200;
  Height:= 50;

  FThickness:= 10;
  FValueFormat:= '#,###,##0.00';
  FShowBase:= True;
  FShowCaption:= True;
  FShowValue:= True;
  FBaseAutoSize:= True;
  FBaseSize:= 50;
  FCaptionAlign:= taLeftJustify;
  FValueAlign:= taRightJustify;
  FCaptionMargin:= 10;
  FValueMargin:= 10;

  GaugeType:= 'Horizontal Bar';

end;

procedure TJDGauge.AfterConstruction;
var
  V: TJDGaugeValue;
begin
  inherited;
  //Ensure a default value on new instance...
  if FValues.Count = 0 then begin
    V:= FValues.Add;
    V.Caption:= 'Default';
  end;

  FSubCaptionFont.Assign(Font);
end;

destructor TJDGauge.Destroy;
var
  X: Integer;
begin
  //TODO: Kill decay threads before anything else...
  for X := 0 to FValues.Count-1 do begin
    FValues[X].FPeak.DestroyDecayThread;
  end;
  FreeAndNil(FCrosshairs);
  FreeAndNil(FGaugeObj);
  FreeAndNil(FColorMain);
  FreeAndNil(FSubCaptionFont);
  FreeAndNil(FGlyph);
  FreeAndNil(FValues);
  inherited;
end;

procedure TJDGauge.Paint;
var
  X: Integer;
  V: TJDGaugeValue;
  O: TJDGaugeBase;
  procedure DoValueBase;
  begin
    if FShowBase then begin
      //TODO: Add properties to base for line caps...
      O.Pen.SetLineCap(LineCap(V.CapStart), LineCap(V.CapStop), DashCapFlat);
      O.Pen.SetColor(ColorToGPColor(FColorMain.GetColor));
      O.Pen.SetWidth(FThickness);
      O.PaintValueBase(V);
    end;
  end;
  procedure DoPeak;
  begin
    if V.Peak.Enabled then begin
      //TODO: Add properties to peak for line caps...
      O.Pen.SetLineCap(LineCap(V.CapStart), LineCap(V.CapStop), DashCapFlat);
      O.Pen.SetColor(ColorToGPColor(V.Peak.Color.GetColor));
      O.Pen.SetWidth(V.Peak.Thickness);
      O.PaintPeak(V);
    end;
  end;
  procedure DoValue;
  begin
    O.Pen.SetLineCap(LineCap(V.CapStart), LineCap(V.CapStop), DashCapFlat);
    O.Pen.SetColor(ColorToGPColor(V.Color.GetColor));
    O.Pen.SetWidth(V.Thickness);
    O.PaintValue(V);
  end;
  procedure DoValueGlyph;
  begin
    if FShowValueGlyphs then begin
      O.PaintValueGlyph(V);
    end;
  end;
  procedure DoValueText;
  begin
    if FShowCaption or FShowValue then begin
      Canvas.Font.Assign(Font);
      Canvas.Brush.Style:= bsClear;
      Canvas.Pen.Style:= psClear;
      O.PaintText(V);
    end;
  end;
  procedure DoValueTicks;
  begin
    if V.FTicksMinor.Visible then begin
      O.PaintValueTicks(V.FTicksMinor, V);
    end;
    if V.FTicksMajor.Visible then begin
      O.PaintValueTicks(V.FTicksMajor, V);
    end;
  end;
  procedure DoGlyph;
  begin
    if FShowGlyph then begin
      Canvas.Font.Assign(Glyph.Font);
      O.PaintGlyph;
    end;
  end;
  procedure DoRect;
  begin
    if FShowRect then begin
      O.PaintRect;
    end;
  end;
  procedure DoCrosshairs;
  begin
    O.PaintCrosshairs;
  end;
begin
  if Application.Terminated then Exit;
  inherited;
  Canvas.Lock;
  try
    DrawParentImage(Self, Canvas);
    if Assigned(FGaugeObj) then begin
      O:= FGaugeObj;
      O.PaintStart;
      try
        O.PaintBackground;
        for X := 0 to FValues.Count-1 do begin
          V:= FValues[X];
          DoValueBase;
          if V.Peak.DrawOverValue then begin
            DoValue;
            DoPeak;
          end else begin
            DoPeak;
            DoValue;
          end;
          DoValueTicks;
          DoValueGlyph;
          DoValueText;
        end;
        DoGlyph;
        DoCrosshairs;
        DoRect;
      finally
        FGaugeObj.PaintStop;
      end;
    end;
  finally
    Canvas.Unlock;
  end;
end;

function TJDGauge.EnsureFirstValueExists: TJDGaugeValue;
begin
  //TODO: Figure out why this suddenly became necessary...
  Result:= nil;
  if Application.Terminated then Exit;  
  if FValues.Count = 0 then begin
    Result:= FValues.Add;
  end else begin
    Result:= FValues[0];
  end;
end;

function TJDGauge.GetMainValue: TJDGaugeValue;
begin
  Result:= EnsureFirstValueExists;
end;

procedure TJDGauge.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;
procedure TJDGauge.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if FGaugeObj = nil then Exit;
  if Button = TMouseButton.mbLeft then begin
    FClicking:= True;
    FClickPoint:= Point(X, Y);
  end;
end;

procedure TJDGauge.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  P: TJDPoint;
  E: TJDGaugeElement;
  V: TJDGaugeValue;
begin
  inherited;
  if FGaugeObj = nil then Exit;
  P:= Point(X, Y);
  FGaugeObj.HitTest(P, E, V);
  if (FHoverElement <> E) or (FHoverValue <> V) then begin
    FHoverElement:= E;
    FHoverValue:= V;
    Invalidate;
    if (E = geGlyph) and FShowGlyph then
      Screen.Cursor:= crHandPoint
    else begin
      if (E = TJDGaugeElement.geBase) then
        Screen.Cursor:= crCross
      else
        Screen.Cursor:= crDefault;
    end;
  end;
end;

procedure TJDGauge.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  P: TJDPoint;
  E: TJDGaugeElement;
  V: TJDGaugeValue;
begin
  inherited;
  if FGaugeObj = nil then Exit;
  if Button = TMouseButton.mbLeft then begin
    P:= Point(X, Y);
    FGaugeObj.HitTest(P, E, V);
    if FClicking and (E <> TJDGaugeElement.geNothing) then begin
      FClicking:= False;
      //TODO: Trigger element click event...
      case E of
        geNothing: ;
        geBackground: ;
        geBase: ;
        geGlyph: GlyphClicked;
        geCaption: CaptionClicked(V);
        geSubCaption: ;
        geValue: ValueClicked(V);
        geValueCaption: ;
        geValueGlyph: ;
      end;
    end;
  end;
end;

procedure TJDGauge.GlyphClicked;
begin
  if Assigned(FOnGlyphClick) then
    FOnGlyphClick(Self);
end;

procedure TJDGauge.ValueClicked(AValue: TJDGaugeValue);
begin
  if Assigned(FOnValueClick) then
    FOnValueClick(Self, AValue);
end;

procedure TJDGauge.CaptionClicked(AValue: TJDGaugeValue);
begin
  if Assigned(FOnCaptionClick) then
    FOnCaptionClick(Self, AValue);
end;

procedure TJDGauge.SetBaseAutoSize(const Value: Boolean);
begin
  if Value = FBaseAutoSize then Exit;
  FBaseAutoSize := Value;
  Invalidate;
end;

procedure TJDGauge.SetBaseSize(const Value: Single);
begin
  if Value = FBaseSize then Exit;
  FBaseSize := Value;
  Invalidate;
end;

procedure TJDGauge.SetCaptionAlign(const Value: TAlignment);
begin
  if Value = FCaptionAlign then Exit;
  FCaptionAlign := Value;
  Invalidate;
end;

procedure TJDGauge.SetCaptionMargin(const Value: Single);
begin
  if Value = FCaptionMargin then Exit;
  FCaptionMargin := Value;
  Invalidate;
end;

procedure TJDGauge.SetColorMain(const Value: TJDColorRef);
begin
  FColorMain.Assign(Value);
  Invalidate;
end;

procedure TJDGauge.SetCrosshairs(const Value: TJDGaugeCrosshairs);
begin
  FCrosshairs.Assign(Value);
  Invalidate;
end;

procedure TJDGauge.SetGlyph(const Value: TJDFontGlyph);
begin
  FGlyph.Assign(Value);
  Invalidate;
end;

procedure TJDGauge.SetGrouping(const Value: TJDGaugeGrouping);
begin
  if Value = FGrouping then Exit;
  FGrouping := Value;
  Invalidate;
end;

procedure TJDGauge.SetMainValue(const Value: TJDGaugeValue);
begin
  //TODO: ?
end;

procedure TJDGauge.SetShowBase(const Value: Boolean);
begin
  if Value = FShowBase then Exit;
  FShowBase := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowCaption(const Value: Boolean);
begin
  if Value = FShowCaption then Exit;
  FShowCaption := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowGlyph(const Value: Boolean);
begin
  if Value = FShowGlyph then Exit;
  FShowGlyph := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowRect(const Value: Boolean);
begin
  if Value = FShowRect then Exit;
  FShowRect := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowSubCaption(const Value: Boolean);
begin
  if Value = FShowSubCaption then Exit;
  FShowSubCaption := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowValue(const Value: Boolean);
begin
  if Value = FShowValue then Exit;
  FShowValue := Value;
  Invalidate;
end;

procedure TJDGauge.SetShowValueGlyphs(const Value: Boolean);
begin
  if Value = FShowValueGlyphs then Exit;
  FShowValueGlyphs := Value;
  Invalidate;
end;

procedure TJDGauge.SetSplit(const Value: Boolean);
begin
  if Value = FSplit then Exit;
  FSplit := Value;
  Invalidate;
end;

procedure TJDGauge.SetSubCaptionAlign(const Value: TAlignment);
begin
  if Value = FSubCaptionAlign then Exit;
  FSubCaptionAlign := Value;
  Invalidate;
end;

procedure TJDGauge.SetSubCaptionFont(const Value: TFont);
begin
  FSubCaptionFont.Assign(Value);
  Invalidate;
end;

procedure TJDGauge.SetSubCaptionMargin(const Value: Single);
begin
  if Value = FSubCaptionMargin then Exit;
  FSubCaptionMargin := Value;
  Invalidate;
end;

procedure TJDGauge.SetThickness(const Value: Single);
begin
  if Value = FThickness then Exit;
  FThickness:= Value;
  Invalidate;
end;

procedure TJDGauge.SetValueAlign(const Value: TAlignment);
begin
  if Value = FValueAlign then Exit;
  FValueAlign := Value;
  Invalidate;
end;

procedure TJDGauge.SetValueFormat(const Value: String);
begin
  FValueFormat := Value;
  Invalidate;
end;

procedure TJDGauge.SetValueMargin(const Value: Single);
begin
  if Value = FValueMargin then Exit;
  FValueMargin := Value;
  Invalidate;
end;

procedure TJDGauge.SetValues(const Value: TJDGaugeValues);
begin
  FValues.Assign(Value);
  Invalidate;
end;

procedure TJDGauge.ValueClick(Value: TJDGaugeValue);
begin
  if Assigned(FOnValueClick) then
    FOnValueClick(Self, Value);
end;

procedure TJDGauge.SetGaugeType(const Value: TJDGaugeTypeClass);
var
  L: TJDGaugeClassList;
  X: Integer;
  C: TJDGaugeBaseClass;
begin
  FGaugeType := Value;

  //Destroy any prior assigned object...
  FreeAndNil(FGaugeObj);

  //Create new object...
  L:= JDGaugeClasses;
  for X := 0 to L.Count-1 do begin
    C:= L[X];
    if C.GetCaption = Value then begin
      FGaugeObj:= C.Create(Self);
      Break;
    end;
  end;
  Invalidate;
end;

initialization
  if _JDGaugeClasses = nil then
    _JDGaugeClasses:= TJDGaugeClassList.Create;
finalization
  FreeAndNil(_JDGaugeClasses);
end.

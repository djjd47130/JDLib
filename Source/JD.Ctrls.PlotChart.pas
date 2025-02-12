unit JD.Ctrls.PlotChart;

(*

TJDPlotChart
Custom Control by Jerry Dodge

SUMMARY

Allows you to create a chart in run-time by simply dragging around
plot points, and double-clicking to either create or delete them.
Uses GDI+ for graphics, and provides many UI/UX options.

RULES

The following rules must apply for this control:
1 - Chart area must be calculated
    - Because of UI/UX settings, the actual chart area may vary
    - function ChartRect takes care of these rules by returning
      the bounds of the actual chart area.
2 - 3 Axis - Bottom (X), Left (Y), and Right (Z)
    - Bottom and Left Required - displays main data
    - Right Optional - displays secondary data
3 - Restrict points within chart area
    - X axis Required - must never allow past left or right
    - Y,Z axis Optional, Default False - allow past top or bottom if enabled
4 - Always have at least 1 line at all times
    - Deleting all points results in auto-creating new one
5 - Pin left and right points to left and right chart edges
    - Debating on whether to make this required or optional
6 - Left and right points follow each other on Y axis
    - Optional, Default False
7 - Prevent points from overlapping on X axis
    - Required, with behavioral options
      - Restrict: Don't allow a point to pass either neighboring points
      - Push Neighbor: Allow a point to "push" either neighboring point
      - Push All: Allow a point to "push" any conflicting neighboring points
8 - Different methods of changing plot data
    - Due to IDE behavior, interacting with chart in design-time must be
      very carefully done, if at all.
    - User is primarily expected to use Points (TJDPlotPoints) property.
    - All rules of user interacting with UI must also apply to editing properties.
      This is best done by enforcing rules in the properties to begin with,
      then making UI interaction assign those properties.



*)

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Types,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  JD.Common, JD.Graphics, JD.Ctrls,
  GDIPAPI, GDIPOBJ, GDIPUTIL;

type
  TJDPlotChart = class;
  TJDPlotPoint = class;
  TJDPlotPoints = class;
  TJDPlotChartOptionGroup = class;
  TJDPlotChartUI = class;
  TJDPlotChartUX = class;

  TJDPlotChartOverlap = (drRestrict, drPushNeighbor, drPushAll);

  /// <summary>
  /// Enum defining one of the possible axis.
  /// </summary>
  TJDPlotChartAxis = (
    /// <summary>
    /// Bottom (X) Axis
    /// </summary>
    caBottom,
    /// <summary>
    /// Left (Y) Axis
    /// </summary>
    caLeft,
    /// <summary>
    /// Right (Z) Axis
    /// </summary>
    caRight
    );

  /// <summary>
  /// Enum defining a variety of preset axis types.
  /// </summary>
  TJDPlotChartAxisType = (
    /// <summary>
    /// Default - Allow user to customize axis to any range.
    /// </summary>
    atCustom,
    /// <summary>
    /// Axis is treated as a percentage range.
    /// </summary>
    atPercent,
    /// <summary>
    /// Axis is treated as a date range.
    /// </summary>
    atDate,
    /// <summary>
    /// Axis is treated as a time range.
    /// </summary>
    atTime,
    /// <summary>
    /// Axis is treated as a currency range.
    /// </summary>
    atCurrency
    );

  /// <summary>
  /// Enum defining where to place labels on an axis
  /// </summary>
  TJDPlotChartLabelPosition = (
    /// <summary>
    /// Do not draw labels on axis.
    /// </summary>
    lpNone,
    /// <summary>
    /// Draw labels on the inside of the axis.
    /// </summary>
    lpInside,
    /// <summary>
    /// Draw labels on the outside of the axis.
    /// </summary>
    lpOutside
    );

  /// <summary>
  /// Enum defining the type of chart line to be drawn
  /// </summary>
  TJDPlotChartLineType = (ptSolid, ptDotted, ptDashed);

  /// <summary>
  /// Enum defining the type of chart point to be drawn
  /// </summary>
  TJDPlotChartPointType = (ptEllipse, ptRectangle, ptTriangle, ptHexagon);

  /// <summary>
  /// Event type related to a specific plot point.
  /// </summary>
  TJDPlotPointEvent = procedure(Sender: TObject; P: TJDPlotPoint) of object;


  
  /// <summary>
  /// Main TJDPlotChart control encapsulating user customization of plot points.
  /// </summary>
  TJDPlotChart = class(TJDControl)
  private
    FInitialized: Boolean;
    FGdiPlusStartupInput: GdiplusStartupInput;
    FBuffer: TBitmap;
    FUI: TJDPlotChartUI;
    FUX: TJDPlotChartUX;
    FPoints: TJDPlotPoints;
    FHoveringIndex: Integer;
    FDraggingIndex: Integer;
    FDragging: Boolean;
    FDraggingVertical: Boolean;
    FGhostPointVisible: Boolean;
    FGhostPlotPoint: TPointF;
    FOnPointAdded: TJDPlotPointEvent;
    FOnPointMoved: TJDPlotPointEvent;
    FOnPointDeleted: TJDPlotPointEvent;
    FOnHoverMousePoint: TJDPlotPointEvent;
    procedure SetUI(const Value: TJDPlotChartUI);
    function PlotPointToPoint(P: TJDPlotPoint): TPointF; overload;
    function PlotPointToPoint(P: TPointF): TPointF; overload;
    function PointToPlotPoint(P: TPointF): TPointF;
    procedure SetPoints(const Value: TJDPlotPoints);
    procedure CheckOverlapOnFly(Index: Integer);
    procedure SetUX(const Value: TJDPlotChartUX);
    procedure ClampPoint(Point: TJDPlotPoint);
    procedure EnforceLinkLeftAndRight(Point: TJDPlotPoint);
    procedure AdjustRightMostPoint;
    procedure PopulateSampleData;
    procedure SetOnHoverMousePoint(const Value: TJDPlotPointEvent);
  protected
    procedure InvalidateOptionGroup(AGroup: TJDPlotChartOptionGroup);

    procedure PointAdded(APoint: TJDPlotPoint); virtual;
    procedure PointMoved(APoint: TJDPlotPoint); virtual;
    procedure PointDeleted(APoint: TJDPlotPoint); virtual;

    procedure Paint; override;
    procedure Resize; override;
    procedure DblClick; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas;
    function ChartRect: TJDRect;

    procedure CreatePlotPoints(TimeStart, TimeStop: TTime; Perc: Single);
    function GetTimePerc(ATime: TTime): Single;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;

    property Cursor;
    property DoubleBuffered;
    property Font;
    property Hint;
    property ShowHint;

    property UI: TJDPlotChartUI read FUI write SetUI;
    property UX: TJDPlotChartUX read FUX write SetUX;

    property Points: TJDPlotPoints read FPoints write SetPoints;

    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;

    property OnPointAdded: TJDPlotPointEvent read FOnPointAdded write FOnPointAdded;
    property OnPointMoved: TJDPlotPointEvent read FOnPointMoved write FOnPointMoved;
    property OnPointDeleted: TJDPlotPointEvent read FOnPointDeleted write FOnPointDeleted;

    property OnHoverMousePoint: TJDPlotPointEvent read FOnHoverMousePoint write SetOnHoverMousePoint;

  end;

  /// <summary>
  /// Represents a single plot point on the chart.
  /// </summary>
  TJDPlotPoint = class(TCollectionItem)
  private
    FX: Single;
    FY: Single;
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
  protected
    function GetDisplayName: String; override;
  public
    procedure Invalidate;
    procedure SetPoint(const X, Y: Single; TriggerEvent: Boolean = True); overload;
    procedure SetPoint(const P: TPointF; TriggerEvent: Boolean = True); overload;
  published
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
  end;

  /// <summary>
  /// Represents a list of plot points on the chart, forming the plot line.
  /// </summary>
  TJDPlotPoints = class(TOwnedCollection)
  private
    function GetItem(const Index: Integer): TJDPlotPoint;
    procedure SetItem(const Index: Integer; const Value: TJDPlotPoint);
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJDPlotChart); reintroduce;
    procedure Invalidate;
    function Add: TJDPlotPoint;
    function Insert(const Index: Integer): TJDPlotPoint;
    property Items[const Index: Integer]: TJDPlotPoint read GetItem write SetItem; default;
  end;



////////////////////////////////////////////////////////////////////////////////
/// TODO: Migrate common concepts to reusable unit for other custom controls.
/// For example, TJDGauge or TJDFontButton could be enhanced with such concepts.
////////////////////////////////////////////////////////////////////////////////

  /// <summary>
  /// Base for all other options in UI / UX properties.
  /// </summary>
  TJDPlotChartOptionGroup = class(TPersistent)
  private
    FOwner: TJDPlotChart;
  public
    constructor Create(AOwner: TJDPlotChart); virtual;
    destructor Destroy; override;
    procedure Invalidate; virtual;
  end;



////////////////////////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////////////////////////

  /// <summary>
  /// Core base for any option group for drawing any surface in the UI.
  /// Provides Color and Alpha properties.
  /// </summary>
  TJDPlotChartUISurface = class(TJDPlotChartOptionGroup)
  private
    FColor: TJDColorRef;
    FAlpha: Byte;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetAlpha(const Value: Byte);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
    function MakeBrush: TGPSolidBrush; virtual;
    function MakePen: TGPPen; virtual;
  published
    property Color: TJDColorRef read FColor write SetColor;
    property Alpha: Byte read FAlpha write SetAlpha;
  end;

  /// <summary>
  /// UI options for control background.
  /// </summary>
  TJDPlotChartUIBackground = class(TJDPlotChartUISurface)
  private
    FTransparent: Boolean;
    procedure SetTransparent(const Value: Boolean);
  public
    constructor Create(AOwner: TJDPlotChart); override;
  published
    property Transparent: Boolean read FTransparent write SetTransparent;
  end;

  /// <summary>
  /// UI options for the in-fill beneath the plotted line.
  /// </summary>
  TJDPlotChartUIFill = class(TJDPlotChartUISurface)
  public
    constructor Create(AOwner: TJDPlotChart); override;
  end;

  /// <summary>
  /// UI options for the plotted line.
  /// </summary>
  TJDPlotChartUILine = class(TJDPlotChartUISurface)
  private
    FWidth: Single;
    FVisible: Boolean;
    procedure SetWidth(const Value: Single);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
    function MakePen: TGPPen; override;
  published
    property Width: Single read FWidth write SetWidth;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  /// <summary>
  /// UI options for the plotted points.
  /// </summary>
  TJDPlotChartUIPoint = class(TJDPlotChartOptionGroup)
  private
    FColor: TJDColorRef;
    FWidth: Single;
    FVisible: Boolean;
    FPointType: TJDPlotChartPointType;
    FAlpha: Byte;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetWidth(const Value: Single);
    procedure SetVisible(const Value: Boolean);
    procedure SetPointType(const Value: TJDPlotChartPointType);
    procedure SetAlpha(const Value: Byte);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
    function MakeBrush: TGPSolidBrush;
  published
    property Alpha: Byte read FAlpha write SetAlpha;
    property PointType: TJDPlotChartPointType read FPointType write SetPointType;
    property Width: Single read FWidth write SetWidth;
    property Color: TJDColorRef read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  /// <summary>
  /// UI options for a given axis.
  /// </summary>
  TJDPlotChartUIAxis = class(TJDPlotChartOptionGroup)
  private
    FLabels: TJDPlotChartLabelPosition;
    FBaseLine: TJDPlotChartUILine;
    FGridLines: TJDPlotChartUILine;
    procedure SetLabels(const Value: TJDPlotChartLabelPosition);
    procedure SetBaseLine(const Value: TJDPlotChartUILine);
    procedure SetGridLines(const Value: TJDPlotChartUILine);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    property Labels: TJDPlotChartLabelPosition read FLabels write SetLabels;
    property BaseLine: TJDPlotChartUILine read FBaseLine write SetBaseLine;
    property GridLines: TJDPlotChartUILine read FGridLines write SetGridLines;
  end;

  /// <summary>
  /// UI options for everything in the chart area.
  /// </summary>
  TJDPlotChartUIChart = class(TJDPlotChartOptionGroup)
  private
    FBorder: TJDPlotChartUILine;
    FColor: TJDColorRef;
    FTransparent: Boolean;
    FLine: TJDPlotChartUILine;
    FPoints: TJDPlotChartUIPoint;
    FAxisLeft: TJDPlotChartUIAxis;
    FAxisBottom: TJDPlotChartUIAxis;
    FFill: TJDPlotChartUIFill;
    FPadding: Single;
    FPointHover: TJDPlotChartUIPoint;
    FPointMouse: TJDPlotChartUIPoint;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetTransparent(const Value: Boolean);
    procedure SetBorder(const Value: TJDPlotChartUILine);
    procedure SetLine(const Value: TJDPlotChartUILine);
    procedure SetPoints(const Value: TJDPlotChartUIPoint);
    procedure SetAxisLeft(const Value: TJDPlotChartUIAxis);
    procedure SetAxisBottom(const Value: TJDPlotChartUIAxis);
    procedure SetFill(const Value: TJDPlotChartUIFill);
    procedure SetPadding(const Value: Single);
    procedure SetPointHover(const Value: TJDPlotChartUIPoint);
    procedure SetPointMouse(const Value: TJDPlotChartUIPoint);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    property AxisLeft: TJDPlotChartUIAxis read FAxisLeft write SetAxisLeft;
    property AxisBottom: TJDPlotChartUIAxis read FAxisBottom write SetAxisBottom;
    property Border: TJDPlotChartUILine read FBorder write SetBorder;
    property Color: TJDColorRef read FColor write SetColor;
    property Fill: TJDPlotChartUIFill read FFill write SetFill;
    property Line: TJDPlotChartUILine read FLine write SetLine;
    property Points: TJDPlotChartUIPoint read FPoints write SetPoints;
    property PointMouse: TJDPlotChartUIPoint read FPointMouse write SetPointMouse;
    property PointHover: TJDPlotChartUIPoint read FPointHover write SetPointHover;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
    property Padding: Single read FPadding write SetPadding;
  end;

  /// <summary>
  /// UI options for the entire control.
  /// </summary>
  TJDPlotChartUI = class(TJDPlotChartOptionGroup)
  private
    FBackground: TJDPlotChartUIBackground;
    FChartArea: TJDPlotChartUIChart;
    procedure SetBackground(const Value: TJDPlotChartUIBackground);
    procedure SetChartArea(const Value: TJDPlotChartUIChart);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    property Background: TJDPlotChartUIBackground read FBackground write SetBackground;
    property ChartArea: TJDPlotChartUIChart read FChartArea write SetChartArea;
    //Legend
    //Header
    //Footer
  end;



////////////////////////////////////////////////////////////////////////////////
/// UX
////////////////////////////////////////////////////////////////////////////////

  /// <summary>
  /// UX options for a given chart axis.
  /// </summary>
  TJDPlotChartUXAxis = class(TJDPlotChartOptionGroup)
  private
    FMax: Single;
    FMin: Single;
    FFormat: String;
    FFrequency: Single;
    FAxisType: TJDPlotChartAxisType;
    procedure SetFormat(const Value: String);
    procedure SetMax(const Value: Single);
    procedure SetMin(const Value: Single);
    procedure SetFrequency(const Value: Single);
    procedure SetAxisType(const Value: TJDPlotChartAxisType);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    /// <summary>
    /// A preset type of axis data (Default = Custom)
    /// </summary>
    property AxisType: TJDPlotChartAxisType read FAxisType write SetAxisType;
    /// <summary>
    /// Minimum range value to show on axis.
    /// </summary>
    property Min: Single read FMin write SetMin;
    /// <summary>
    /// Maximum range value to show on axis.
    /// </summary>
    property Max: Single read FMax write SetMax;
    /// <summary>
    /// Desired spacing between values shown on axis.
    /// </summary>
    property Frequency: Single read FFrequency write SetFrequency;
    /// <summary>
    /// The format used on a given value on axis values.
    /// </summary>
    property Format: String read FFormat write SetFormat;
  end;

  /// <summary>
  /// UX options for the overall chart area.
  /// </summary>
  TJDPlotChartUXChart = class(TJDPlotChartOptionGroup)
  private
    FOverlap: TJDPlotChartOverlap;
    FLinkLeftAndRight: Boolean;
    FSnapTolerance: Single;
    FAxisBottom: TJDPlotChartUXAxis;
    FAxisLeft: TJDPlotChartUXAxis;
    FAddPointAnywhere: Boolean;
    procedure SetOverlap(const Value: TJDPlotChartOverlap);
    procedure SetLinkLeftAndRight(const Value: Boolean);
    procedure SetSnapTolerance(const Value: Single);
    procedure SetAxisBottom(const Value: TJDPlotChartUXAxis);
    procedure SetAxisLeft(const Value: TJDPlotChartUXAxis);
    procedure SetAddPointAnywhere(const Value: Boolean);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    /// <summary>
    /// UX options for the bottom axis.
    /// </summary>
    property AxisBottom: TJDPlotChartUXAxis read FAxisBottom write SetAxisBottom;
    /// <summary>
    /// UX options for the left axis.
    /// </summary>
    property AxisLeft: TJDPlotChartUXAxis read FAxisLeft write SetAxisLeft;
    /// <summary>
    /// Controls how to manage a point overlapping another point.
    /// </summary>
    property Overlap: TJDPlotChartOverlap read FOverlap write SetOverlap;
    /// <summary>
    /// Links the Y position of the lar left and right points together
    /// to follow each other on the Y axis.
    /// </summary>
    property LinkLeftAndRight: Boolean read FLinkLeftAndRight write SetLinkLeftAndRight;
    /// <summary>
    /// Distance from plot line before auto-snapping to the line.
    /// </summary>
    property SnapTolerance: Single read FSnapTolerance write SetSnapTolerance;
    /// <summary>
    /// Allows user to create a new point in the chart at X position
    /// regardless of whether it's nearby an existing line.
    /// </summary>
    property AddPointAnywhere: Boolean read FAddPointAnywhere write SetAddPointAnywhere;
    // TODO: Grid snap...
  end;

  /// <summary>
  /// UX options for the entire control.
  /// </summary>
  TJDPlotChartUX = class(TJDPlotChartOptionGroup)
  private
    FChartArea: TJDPlotChartUXChart;
    procedure SetChartArea(const Value: TJDPlotChartUXChart);
  public
    constructor Create(AOwner: TJDPlotChart); override;
    destructor Destroy; override;
  published
    property ChartArea: TJDPlotChartUXChart read FChartArea write SetChartArea;
  end;

implementation

uses
  System.Math, System.StrUtils, System.DateUtils;

function PointLineDistance(P, A, B: TPointF): Single;
var
  AB, AP, BP: TPointF;
  AB_Dot_AB, AP_Dot_AB, BP_Dot_AB: Single;
begin
  AB := PointF(B.X - A.X, B.Y - A.Y);
  AP := PointF(P.X - A.X, P.Y - A.Y);
  BP := PointF(P.X - B.X, P.Y - B.Y);

  AB_Dot_AB := AB.X * AB.X + AB.Y * AB.Y;
  AP_Dot_AB := AP.X * AB.X + AP.Y * AB.Y;
  BP_Dot_AB := BP.X * AB.X + BP.Y * AB.Y;

  if AP_Dot_AB <= 0 then
    Result := Sqrt(AP.X * AP.X + AP.Y * AP.Y)
  else if BP_Dot_AB >= 0 then
    Result := Sqrt(BP.X * BP.X + BP.Y * BP.Y)
  else
    Result := Abs(AB.X * AP.Y - AB.Y * AP.X) / Sqrt(AB_Dot_AB);
end;

{ TJDPlotChart }

constructor TJDPlotChart.Create(AOwner: TComponent);
begin
  inherited;
  Parent := TWinControl(AOwner);

  FGdiPlusStartupInput.DebugEventCallback := nil;
  FGdiPlusStartupInput.SuppressBackgroundThread := False;
  FGdiPlusStartupInput.SuppressExternalCodecs := False;
  FGdiPlusStartupInput.GdiplusVersion := 1;
  GdiplusStartup(GdiPlusToken, @FGdiPlusStartupInput, nil);

  Width:= 300;
  Height:= 200;

  FPoints:= TJDPlotPoints.Create(Self);

  FHoveringIndex := -1;
  FDraggingIndex := -1;
  FDragging := False;
  FDraggingVertical:= False;

  FUI:= TJDPlotChartUI.Create(Self);
  FUX:= TJDPlotChartUX.Create(Self);

  FBuffer:= TBitmap.Create;
  FBuffer.SetSize(ClientWidth, ClientHeight);

  Font.Color:= clWhite;
  Font.Quality:= TFontQuality.fqAntialiased;
  Font.Size:= 7;

  //Sample data
  //CreatePlotPoints(IncHour(Now,-2), IncHour(Now,2), 30);
  PopulateSampleData;

  FInitialized:= True;

end;

destructor TJDPlotChart.Destroy;
begin

  FreeAndNil(FPoints);
  FreeAndNil(FBuffer);
  FreeAndNil(FUX);
  FreeAndNil(FUI);

  GdiplusShutdown(GdiPlusToken);

  inherited;
end;

procedure TJDPlotChart.PopulateSampleData;
var
  I: Integer;
  SamplePoint: TJDPlotPoint;
begin
  FPoints.Clear; // Clear any existing points

  // Add sample points to the chart
  for I := 0 to 9 do begin
    SamplePoint := FPoints.Add;
    SamplePoint.SetPoint(
      FUX.ChartArea.AxisBottom.Min + I * ((FUX.ChartArea.AxisBottom.Max - FUX.ChartArea.AxisBottom.Min) / 9),
      FUX.ChartArea.AxisLeft.Min + Random(Round(FUX.ChartArea.AxisLeft.Max - FUX.ChartArea.AxisLeft.Min))
    );
  end;

  Invalidate; // Redraw the chart
end;

procedure TJDPlotChart.CreatePlotPoints(TimeStart, TimeStop: TTime;
  Perc: Single);
var
  StartHour, StopHour: Single;
  Midnight: Boolean;
  procedure A(const AX, AY: Single);
  begin
    var I: TJDPlotPoint:= FPoints.Add;
    I.FX:= AX;
    I.FY:= AY;
  end;
begin
  StartHour := HourOf(TimeStart) + (MinuteOf(TimeStart) / 60);
  StopHour := HourOf(TimeStop) + (MinuteOf(TimeStop) / 60);

  Midnight := StopHour < StartHour; // Detect if times lapse over midnight

  FPoints.Clear;

  if Midnight then begin
    A(0, Perc);
    A(StopHour, Perc);
    A(StopHour, 100);
    A(StartHour, 100);
    A(StartHour, Perc);
    A(29.9999, Perc);
  end else begin
    A(0, 100);
    A(StartHour, 100);
    A(StartHour, Perc);
    A(StopHour, Perc);
    A(StopHour, 100);
    A(23.9999, 100);
  end;

  Invalidate;
end;

function TJDPlotChart.GetTimePerc(ATime: TTime): Single;
var
  TargetHour: Single;
  I: Integer;
  P1, P2: TJDPlotPoint;
  HourDiff, PercDiff: Single;
begin
  // Convert the time to an hour value (0-24 range)
  TargetHour := HourOf(ATime) + (MinuteOf(ATime) / 60) + (SecondOf(ATime) / 3600);

  // Find the interval that contains TargetHour
  for I := 0 to FPoints.Count - 2 do begin
    if (FPoints[I].X <= TargetHour) and (TargetHour <= FPoints[I + 1].X) then begin
      P1 := FPoints[I];
      P2 := FPoints[I + 1];

      // Calculate the percentage value using linear interpolation
      HourDiff := P2.X - P1.X;
      if HourDiff = 0 then
        Exit(P1.Y); // Avoid division by zero

      PercDiff := P2.Y - P1.Y;
      Result := P1.Y + ((TargetHour - P1.X) / HourDiff) * PercDiff;
      Exit;
    end;
  end;

  // If TargetHour is not within the range of FPoints, return 0 or a default value
  Result := 0;
end;

procedure TJDPlotChart.DblClick;
var
  MousePos: TPoint;
  ClickPoint: TPointF;
  Dist: Single;
  DeleteIndex, InsertIndex: Integer;
  NearestP1, NearestP2: TJDPlotPoint;
  T: Single;
begin
  inherited;

  MousePos := ScreenToClient(Mouse.CursorPos);
  ClickPoint := PointToPlotPoint(MousePos);
  DeleteIndex := -1;

  // Check if the double-click is near an existing point
  for var I := 0 to FPoints.Count - 1 do begin
    var P := PlotPointToPoint(FPoints[I] as TJDPlotPoint);
    Dist := Sqrt(Sqr(P.X - MousePos.X) + Sqr(P.Y - MousePos.Y));
    if Dist < FUX.ChartArea.SnapTolerance then begin
      DeleteIndex := I;
      Break;
    end;
  end;

  // If an existing point is found near the double-click, delete it
  if DeleteIndex <> -1 then begin
    FPoints.Delete(DeleteIndex);
    Invalidate;
    Exit;
  end;

  // Detect if double-click is near a line
  for var I := 0 to FPoints.Count - 2 do begin
    var P1 := PlotPointToPoint(FPoints[I] as TJDPlotPoint);
    var P2 := PlotPointToPoint(FPoints[I + 1] as TJDPlotPoint);

    // Check the proximity to the line segment P1-P2
    Dist := PointLineDistance(MousePos, P1, P2);
    if Dist < FUX.ChartArea.SnapTolerance then begin
      NearestP1 := FPoints[I] as TJDPlotPoint;
      NearestP2 := FPoints[I + 1] as TJDPlotPoint;

      // Calculate the closest point on the line segment to the mouse position
      var DX := P2.X - P1.X;
      var DY := P2.Y - P1.Y;
      var LineLenSquared := DX * DX + DY * DY;
      T := ((MousePos.X - P1.X) * DX + (MousePos.Y - P1.Y) * DY) / LineLenSquared;
      if T < 0 then T := 0;
      if T > 1 then T := 1;

      // Create the new point exactly on the line
      InsertIndex := I + 1;
      var NewPoint := TJDPlotPoint(FPoints.Insert(InsertIndex));
      NewPoint.X := NearestP1.X + T * (NearestP2.X - NearestP1.X);
      NewPoint.Y := NearestP1.Y + T * (NearestP2.Y - NearestP1.Y);

      Invalidate;

      Exit;
    end;
  end;

end;

procedure TJDPlotChart.InvalidateOptionGroup(AGroup: TJDPlotChartOptionGroup);
begin
  //TODO: Make this intelligent so only invalidate what needs to change...

  Invalidate;
end;

function TJDPlotChart.ChartRect: TJDRect;
var
  LabelOffsetBottom, LabelOffsetLeft: Integer;
begin
  // Initialize label offsets based on label positions
  LabelOffsetBottom := 0;
  LabelOffsetLeft := 0;

  // Adjust offsets based on label positions
  case FUI.ChartArea.AxisBottom.Labels of
    lpOutside: LabelOffsetBottom := 12;
  end;

  case FUI.ChartArea.AxisLeft.Labels of
    lpOutside: LabelOffsetLeft := 30;
  end;

  // Calculate the chart rect based on the current dimensions and offsets
  Result := ClientRect;
  Result.Left := Result.Left + LabelOffsetLeft + FUI.ChartArea.Padding;
  Result.Right := Result.Right - FUI.ChartArea.Padding;
  Result.Top := Result.Top + FUI.ChartArea.Padding;
  Result.Bottom := Result.Bottom - LabelOffsetBottom - FUI.ChartArea.Padding;
end;

procedure TJDPlotChart.Resize;
begin
  inherited;
  if not FInitialized then Exit;

  FBuffer.SetSize(ClientWidth, ClientHeight);
  Invalidate;
end;

procedure TJDPlotChart.SetOnHoverMousePoint(const Value: TJDPlotPointEvent);
begin
  FOnHoverMousePoint := Value;  
end;

procedure TJDPlotChart.SetPoints(const Value: TJDPlotPoints);
begin
  FPoints.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChart.SetUI(const Value: TJDPlotChartUI);
begin
  FUI.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChart.SetUX(const Value: TJDPlotChartUX);
begin
  FUX.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChart.CMMouseEnter(var Message: TMessage);
begin

  Invalidate;
end;

procedure TJDPlotChart.CMMouseLeave(var Message: TMessage);
begin
  FGhostPointVisible := False;

  Invalidate;
end;

procedure TJDPlotChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if FHoveringIndex <> -1 then begin
    FDraggingIndex := FHoveringIndex;
    FDragging := True;
    if (FDraggingIndex = 0) or (FDraggingIndex = FPoints.Count - 1) then begin
      // Allow vertical movement only for the first and last points
      FDraggingVertical := True;
    end else begin
      FDraggingVertical := False;
    end;
  end;

  Invalidate;
end;

procedure TJDPlotChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  HoverPoint: TPointF;
  NearestP1, NearestP2: TPointF;
  NewPoint: TPointF;
begin
  inherited;

  var R: TJDRect := ChartRect;
  var GhostFound := False;
  var NearPoint := False;

  HoverPoint := PointToPlotPoint(Point(X, Y));
  //if Assigned(FOnHoverMousePoint) then
  //  FOnHoverMousePoint(Self, HoverPoint);
  

  FHoveringIndex := -1;
  for var I := 0 to FPoints.Count - 1 do begin
    var P := PlotPointToPoint(FPoints[I]);
    if (Abs(P.X - X) <= 4) and (Abs(P.Y - Y) <= 4) then begin
      FHoveringIndex := I;
      NearPoint := True;
      Break;
    end;
  end;

  // Update plot point(s) based on rules
  if PtInRect(R, Point(X, Y)) or Dragging then begin

    if FDragging and (FDraggingIndex <> -1) then begin
      NewPoint := PointToPlotPoint(Point(X, Y));
      ClampPoint(FPoints[FDraggingIndex]);
      FPoints[FDraggingIndex].SetPoint(NewPoint, False);

      // Use the new point for status bar update
      HoverPoint := PlotPointToPoint(FPoints[FDraggingIndex]);
    end else begin
      HoverPoint := Point(X, Y);
    end;

    // Detect if hovering near a line
    for var I := 0 to FPoints.Count - 2 do begin
      var P1 := PlotPointToPoint(FPoints[I] as TJDPlotPoint);
      var P2 := PlotPointToPoint(FPoints[I + 1] as TJDPlotPoint);
      // Check the proximity to the line segment P1-P2
      var LineDist := PointLineDistance(Point(X, Y), P1, P2);
      if LineDist < FUX.ChartArea.SnapTolerance then begin
        GhostFound := True;
        NearestP1 := P1;
        NearestP2 := P2;
        // Calculate the closest point on the line segment to the mouse position
        var DX := P2.X - P1.X;
        var DY := P2.Y - P1.Y;
        var LineLenSquared := DX * DX + DY * DY;
        var T := ((X - P1.X) * DX + (Y - P1.Y) * DY) / LineLenSquared;
        if T < 0 then T := 0;
        if T > 1 then T := 1;
        FGhostPlotPoint.X := NearestP1.X + T * (NearestP2.X - NearestP1.X);
        FGhostPlotPoint.Y := NearestP1.Y + T * (NearestP2.Y - NearestP1.Y);
        Break;
      end;
    end;

    // Detect if hovering near a point
    if not NearPoint then begin
      if not GhostFound then begin
        // If not snapping to a line, place ghost point directly under the mouse cursor
        FGhostPlotPoint := PointToPlotPoint(Point(X, Y));
        GhostFound := True;
      end;
    end else begin
      GhostFound := False;
    end;

    FGhostPointVisible := GhostFound;
  end;

  Invalidate;
end;

procedure TJDPlotChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if FDragging and (FDraggingIndex <> -1) then begin
    PointMoved(FPoints[FDraggingIndex]); // Trigger event on release
    FDragging := False;
    FDraggingIndex := -1;
  end;

  // Other existing logic...
  Invalidate;
end;

procedure TJDPlotChart.EnforceLinkLeftAndRight(Point: TJDPlotPoint);
begin
  if FUX.ChartArea.LinkLeftAndRight then begin
    if Point.Index = 0 then
      FPoints[FPoints.Count - 1].SetPoint(FPoints[FPoints.Count - 1].X, Point.Y)
    else if Point.Index = FPoints.Count - 1 then
      FPoints[0].SetPoint(FPoints[0].X, Point.Y);
  end;
end;

procedure TJDPlotChart.ClampPoint(Point: TJDPlotPoint);
var
  ClampedX, ClampedY: Single;
begin
  ClampedX := Max(FUX.ChartArea.AxisBottom.FMin, Min(Point.X, FUX.ChartArea.AxisBottom.FMax));
  ClampedY := Max(FUX.ChartArea.AxisLeft.FMin, Min(Point.Y, FUX.ChartArea.AxisLeft.FMax));

  if Point.FX <> ClampedX then
    Point.FX := ClampedX;
  if Point.FY <> ClampedY then
    Point.FY := ClampedY;

  Invalidate;
end;

procedure TJDPlotChart.CheckOverlapOnFly(Index: Integer);
begin
  case FUX.ChartArea.Overlap of
    drRestrict:
      begin
        if Index > 0 then begin
          if FPoints[Index].X <= FPoints[Index - 1].X then
            FPoints[Index].X := FPoints[Index - 1].X + 0.01;
        end;
        if Index < FPoints.Count - 1 then begin
          if FPoints[Index].X >= FPoints[Index + 1].X then
            FPoints[Index].X := FPoints[Index + 1].X - 0.01;
        end;
      end;

    drPushNeighbor:
      begin
        if Index > 0 then begin
          if FPoints[Index].X <= FPoints[Index - 1].X then begin
            FPoints[Index - 1].X := FPoints[Index].X - 0.01;
            if FPoints[Index - 1].X <= FPoints[Index - 2].X then
              FPoints[Index - 1].X := FPoints[Index - 2].X + 0.01;
          end;
        end;
        if Index < FPoints.Count - 1 then begin
          if FPoints[Index].X >= FPoints[Index + 1].X then begin
            FPoints[Index + 1].X := FPoints[Index].X + 0.01;
            if FPoints[Index + 1].X >= FPoints[Index + 2].X then
              FPoints[Index + 1].X := FPoints[Index + 2].X - 0.01;
          end;
        end;
      end;

    drPushAll:
      begin
        if Index > 0 then begin
          for var I := Index - 1 downto 0 do begin
            if FPoints[I].X >= FPoints[I + 1].X then
              FPoints[I].X := FPoints[I + 1].X - 0.01;
          end;
        end;
        if Index < FPoints.Count - 1 then begin
          for var I := Index + 1 to FPoints.Count - 1 do begin
            if FPoints[I].X <= FPoints[I - 1].X then
              FPoints[I].X := FPoints[I - 1].X + 0.01;
          end;
        end;
      end;
  end;
end;

procedure TJDPlotChart.AdjustRightMostPoint;
var
  RightMostPoint: TJDPlotPoint;
begin
  if FPoints.Count > 0 then begin
    RightMostPoint := FPoints[FPoints.Count - 1];
    RightMostPoint.X := FUX.ChartArea.AxisBottom.Max; // Pin to the right edge
  end;
  Invalidate; // Redraw the chart
end;

procedure TJDPlotChart.Paint;
var
  G: TGPGraphics;

  function MakeColor(AColor: TJDColorRef; AAlpha: Byte): Cardinal;
  begin
    Result:= Winapi.GDIPAPI.MakeColor(AAlpha,
      GetRValue(AColor.GetJDColor),
      GetGValue(AColor.GetJDColor),
      GetBValue(AColor.GetJDColor));
  end;

  function MakeBrush(AColor: TJDColorRef; AAlpha: Byte): TGPSolidBrush;
  begin
    Result:= TGPSolidBrush.Create(MakeColor(AColor, AAlpha));
  end;

  function MakePen(AColor: TJDColorRef; AWidth: Single; AAlpha: Byte): TGPPen;
  begin
    Result:= TGPPen.Create(MakeColor(AColor, AAlpha), AWidth);
  end;

  procedure DrawBackground;
  var
    Brush: TGPSolidBrush;
  begin
    if FUI.Background.Transparent then begin
      JD.Graphics.DrawParentImage(Self, Canvas);
      JD.Graphics.DrawParentImage(Self, FBuffer.Canvas);
    end else begin
      Brush:= FUI.Background.MakeBrush;
      try
        G.FillRectangle(Brush, ClientRect.Left, ClientRect.Top, ClientRect.Right - ClientRect.Left, ClientRect.Bottom - ClientRect.Top);
      finally
        Brush.Free;
      end;
      //TODO: Border...
    end;
  end;

  procedure RenderText(X, Y: Single; const Text: string);
  var
    FontFamily: TGPFontFamily;
    GdiFont: TGPFont;
    SolidBrush: TGPSolidBrush;
    LayoutRect: TGPRectF;
  begin
    FontFamily := TGPFontFamily.Create('Arial');
    GdiFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPixel);
    SolidBrush := TGPSolidBrush.Create(Winapi.GDIPAPI.MakeColor(255, 255, 255, 255)); // White color
    try
      LayoutRect.X := X;
      LayoutRect.Y := Y;
      LayoutRect.Width := 40; // Narrower bounding box to better fit the labels
      LayoutRect.Height := 15; // Adjusted height for better text fit
      G.DrawString(PChar(Text), -1, GdiFont, LayoutRect, nil, SolidBrush);
    finally
      SolidBrush.Free;
      GdiFont.Free;
      FontFamily.Free;
    end;
  end;

  procedure DrawLines(AColor: TColor; AWidth: Single);
  var
    Pen: TGPPen;
  begin
    Pen := TGPPen.Create(Winapi.GDIPAPI.MakeColor(255, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)), AWidth);
    try
      Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      Pen.SetLineJoin(LineJoinRound);
      for var X := 0 to FPoints.Count - 2 do begin
        var P1 := PlotPointToPoint(FPoints[X]);
        var P2 := PlotPointToPoint(FPoints[X + 1]);
        G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);
      end;
    finally
      Pen.Free;
    end;
  end;

  procedure DrawPoints;
  var
    Z: Single;
    Brush: TGPSolidBrush;
  begin
    for var X := 0 to FPoints.Count - 1 do begin
      var P := PlotPointToPoint(FPoints[X]);
      if FHoveringIndex = X then begin
        // Hover Point
        Brush:= FUI.ChartArea.PointHover.MakeBrush;
        Z := FUI.ChartArea.PointHover.Width / 2;
      end else begin
        // Regular Point
        Brush:= FUI.ChartArea.Points.MakeBrush;
        Z := FUI.ChartArea.Points.Width / 2;
      end;
      try
        G.FillEllipse(Brush, P.X - Z, P.Y - Z, Z * 2, Z * 2);
      finally
        Brush.Free;
      end;
    end;
  end;

  procedure DrawGhostPoint;
  begin
    var Z: Single := FUI.ChartArea.PointMouse.Width / 2;
    if FGhostPointVisible and FUI.ChartArea.PointMouse.Visible then begin
      var P := PlotPointToPoint(FGhostPlotPoint);
      var Brush:= FUI.ChartArea.PointMouse.MakeBrush;
      try
        G.FillEllipse(Brush, P.X - Z, P.Y - Z, Z * 2, Z * 2);
      finally
        Brush.Free;
      end;
    end;
  end;

  procedure DrawAccentColor(AColor: TJDColorRef; AAlpha: Byte = 255);
  var
    Brush: TGPSolidBrush;
    Poly: array[0..3] of TGPPointF;
  begin
    Brush:= MakeBrush(AColor, AAlpha);
    try

      for var I := 0 to FPoints.Count - 2 do begin
        var P1 := PlotPointToPoint(FPoints[I]);
        var P2 := PlotPointToPoint(FPoints[I + 1]);

        // Define polygon under the line segment
        Poly[0].X := P1.X;
        Poly[0].Y := P1.Y;
        Poly[1].X := P2.X;
        Poly[1].Y := P2.Y;
        Poly[2].X := P2.X;
        Poly[2].Y := ChartRect.Bottom;
        Poly[3].X := P1.X;
        Poly[3].Y := ChartRect.Bottom;

        // Fill the polygon
        G.FillPolygon(Brush, PGPPointF(@Poly[0]), 4); // Explicitly cast to PGPPointF
      end;
    finally
      Brush.Free;
    end;
  end;




//The New Shit from AI

  procedure DrawBottomAxis;
  var
    Pen: TGPPen;
    I: Integer;
    Position: Single;
    LabelText: string;
  begin
    // Draw Bottom Axis Baseline
    Pen:= FUI.ChartArea.AxisBottom.BaseLine.MakePen;
    try
      var P1 := PointF(ChartRect.Left, ChartRect.Bottom); // Adjust this based on where the baseline should be
      var P2 := PointF(ChartRect.Right, ChartRect.Bottom);
      G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);
    finally
      Pen.Free;
    end;

    // Draw Vertical Grid Lines and Labels
    Pen:= FUI.ChartArea.AxisBottom.GridLines.MakePen;
    try
      for I := 0 to Round((FUX.ChartArea.AxisBottom.Max - FUX.ChartArea.AxisBottom.Min) / FUX.ChartArea.AxisBottom.Frequency) do begin
        Position := ChartRect.Left + I * (ChartRect.Width / ((FUX.ChartArea.AxisBottom.Max - FUX.ChartArea.AxisBottom.Min) / FUX.ChartArea.AxisBottom.Frequency));
        G.DrawLine(Pen, Position, ChartRect.Top, Position, ChartRect.Bottom);

        if FUI.ChartArea.AxisBottom.Labels <> lpNone then begin
          LabelText := FormatFloat(FUX.ChartArea.AxisBottom.Format, FUX.ChartArea.AxisBottom.Min + I * FUX.ChartArea.AxisBottom.Frequency);

          // Check Label Position
          if FUI.ChartArea.AxisBottom.Labels = lpInside then
            RenderText(Position - 10, ChartRect.Bottom - 20, LabelText) // Inside
          else
            RenderText(Position - 10, ChartRect.Bottom + 5, LabelText); // Outside
        end;
      end;
    finally
      Pen.Free;
    end;
  end;

  procedure DrawLeftAxis;
  var
    Pen: TGPPen;
    I: Integer;
    Position: Single;
    LabelText: string;
  begin
    // Draw Left Axis Baseline
    Pen:= FUI.ChartArea.AxisLeft.BaseLine.MakePen;
    try
      var P1 := PointF(ChartRect.Left, ChartRect.Top); // Adjust this based on where the baseline should be
      var P2 := PointF(ChartRect.Left, ChartRect.Bottom);
      G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);
    finally
      Pen.Free;
    end;

    // Draw Horizontal Grid Lines and Labels
    Pen:= FUI.ChartArea.AxisLeft.GridLines.MakePen;
    try
      for I := 0 to Round((FUX.ChartArea.AxisLeft.Max - FUX.ChartArea.AxisLeft.Min) / FUX.ChartArea.AxisLeft.Frequency) do begin
        Position := ChartRect.Bottom - I * (ChartRect.Height / ((FUX.ChartArea.AxisLeft.Max - FUX.ChartArea.AxisLeft.Min) / FUX.ChartArea.AxisLeft.Frequency));
        G.DrawLine(Pen, ChartRect.Left, Position, ChartRect.Right, Position);

        if FUI.ChartArea.AxisLeft.Labels <> lpNone then begin
          LabelText := FormatFloat(FUX.ChartArea.AxisLeft.Format, FUX.ChartArea.AxisLeft.Min + I * FUX.ChartArea.AxisLeft.Frequency);

          // Check Label Position
          if FUI.ChartArea.AxisLeft.Labels = lpInside then
            RenderText(ChartRect.Left + 5, Position - 10, LabelText) // Inside
          else
            RenderText(ChartRect.Left - 30, Position - 10, LabelText); // Outside
        end;
      end;
    finally
      Pen.Free;
    end;
  end;

begin
  inherited;

  G:= TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    try
      try
        DrawBackground;
        DrawAccentColor(FUI.ChartArea.Fill.Color,
          FUI.ChartArea.Fill.Alpha);
        //DrawVerticalGridLines;
        //DrawHorizontalGridLines;
        //DrawAxis;
        DrawBottomAxis;
        DrawLeftAxis;
        if FUI.ChartArea.Line.Visible then
          DrawLines(FUI.ChartArea.Line.Color.GetJDColor, FUI.ChartArea.Line.Width);
        if FUI.ChartArea.Points.Visible then
          DrawPoints;
        DrawGhostPoint;
      except
        on E: Exception do begin
          //TODO
        end;
      end;
    finally
      Canvas.Draw(0, 0, FBuffer);
    end;
  finally
    G.Free;
  end;
end;

function TJDPlotChart.PlotPointToPoint(P: TPointF): TPointF;
var
  R: TRectF;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / FUX.ChartArea.AxisBottom.FMax;
  YRatio := (R.Bottom - R.Top) / FUX.ChartArea.AxisLeft.FMax;

  // Translate coordinates
  Result.X := R.Left + P.X * XRatio;
  Result.Y := R.Bottom - P.Y * YRatio; // Y-axis is typically inverted
end;

function TJDPlotChart.PlotPointToPoint(P: TJDPlotPoint): TPointF;
begin
  Result:= PlotPointToPoint(PointF(P.X, P.Y));
end;

procedure TJDPlotChart.PointAdded(APoint: TJDPlotPoint);
begin
  if Assigned(FOnPointAdded) then
    FOnPointAdded(Self, APoint);
end;

procedure TJDPlotChart.PointMoved(APoint: TJDPlotPoint);
begin
  if Assigned(FOnPointMoved) then
    FOnPointMoved(Self, APoint);
end;

procedure TJDPlotChart.PointDeleted(APoint: TJDPlotPoint);
begin
  if Assigned(FOnPointDeleted) then
    FOnPointDeleted(Self, APoint);
end;

function TJDPlotChart.PointToPlotPoint(P: TPointF): TPointF;
var
  R: TRectF;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / FUX.ChartArea.AxisBottom.FMax;
  YRatio := (R.Bottom - R.Top) / FUX.ChartArea.AxisLeft.FMax;

  // Translate coordinates
  Result.X := (P.X - R.Left) / XRatio;
  Result.Y := (R.Bottom - P.Y) / YRatio; // Y-axis is typically inverted
end;

{ TJDPlotChartUI }

constructor TJDPlotChartUI.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FBackground:= TJDPlotChartUIBackground.Create(FOwner);
  FChartArea:= TJDPlotChartUIChart.Create(FOwner);

end;

destructor TJDPlotChartUI.Destroy;
begin

  FreeAndNil(FChartArea);
  FreeAndNil(FBackground);
  inherited;
end;

procedure TJDPlotChartUI.SetBackground(const Value: TJDPlotChartUIBackground);
begin
  FBackground.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUI.SetChartArea(const Value: TJDPlotChartUIChart);
begin
  FChartArea.Assign(Value);
  Invalidate;
end;

{ TJDPlotChartUIBackground }

constructor TJDPlotChartUIBackground.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FTransparent:= False;
  FColor.Color:= clBlack;
end;

procedure TJDPlotChartUIBackground.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  Invalidate;
end;

{ TJDPlotChartUIChart }

procedure TJDPlotChartUIChart.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

constructor TJDPlotChartUIChart.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FBorder:= TJDPlotChartUILine.Create(FOwner);
  FBorder.Color.Color:= $00535353;
  FBorder.Width:= 1;

  FColor:= TJDColorRef.Create;
  FColor.UseStandardColor:= False;
  FColor.Color:= clBlack;
  FColor.OnChange:= ColorChanged;

  FLine:= TJDPlotChartUILine.Create(FOwner);
  FLine.Color.Color:= clLime;
  FLine.Width:= 2;
  FLine.Visible:= True;

  FPoints:= TJDPlotChartUIPoint.Create(AOwner);
  FPoints.Color.Color:= clLime;
  FPoints.Width:= 10;
  FPoints.Visible:= True;

  FPointMouse:= TJDPlotChartUIPoint.Create(AOwner);
  FPointMouse.Color.Color:= clGreen;
  FPointMouse.Width:= 12;
  FPointMouse.Visible:= True;

  FPointHover:= TJDPlotChartUIPoint.Create(AOwner);
  FPointHover.Color.Color:= clRed;
  FPointHover.Width:= 12;
  FPointHover.Visible:= True;

  FAxisLeft:= TJDPlotChartUIAxis.Create(FOwner);
  FAxisBottom:= TJDPlotChartUIAxis.Create(FOwner);

  FFill:= TJDPlotChartUIFill.Create(FOwner);

  FPadding:= 15;

  FTransparent:= False;
end;

destructor TJDPlotChartUIChart.Destroy;
begin

  FreeAndNil(FFill);
  FreeAndNil(FAxisBottom);
  FreeAndNil(FAxisLeft);
  FreeAndNil(FPointHover);
  FreeAndNil(FPointMouse);
  FreeAndNil(FPoints);
  FreeAndNil(FLine);
  FreeAndNil(FBorder);
  FreeAndNil(FColor);
  inherited;
end;

procedure TJDPlotChartUIChart.SetAxisBottom(const Value: TJDPlotChartUIAxis);
begin
  FAxisBottom.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetAxisLeft(const Value: TJDPlotChartUIAxis);
begin
  FAxisLeft.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetBorder(
  const Value: TJDPlotChartUILine);
begin
  FBorder.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetFill(const Value: TJDPlotChartUIFill);
begin
  FFill.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetLine(const Value: TJDPlotChartUILine);
begin
  FLine.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetPadding(const Value: Single);
begin
  FPadding := Value;
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetPointHover(const Value: TJDPlotChartUIPoint);
begin
  FPointHover.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetPointMouse(const Value: TJDPlotChartUIPoint);
begin
  FPointMouse.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetPoints(const Value: TJDPlotChartUIPoint);
begin
  FPoints.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIChart.SetTransparent(const Value: Boolean);
begin
  FTransparent:= Value;
  Invalidate;
end;

{ TJDPlotChartUILine }

constructor TJDPlotChartUILine.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FColor.Color:= clSilver;
  FVisible:= True;
  FWidth:= 1;
end;

destructor TJDPlotChartUILine.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

function TJDPlotChartUILine.MakePen: TGPPen;
begin
  Result:= TGPPen.Create(Winapi.GDIPAPI.MakeColor(
    FAlpha, FColor.RGB.R, FColor.RGB.G, FColor.RGB.B),
    FWidth);
end;

procedure TJDPlotChartUILine.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  Invalidate;
end;

procedure TJDPlotChartUILine.SetWidth(const Value: Single);
begin
  FWidth:= Value;
  Invalidate;
end;

{ TJDPlotChartUIPoint }

procedure TJDPlotChartUIPoint.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

constructor TJDPlotChartUIPoint.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FColor:= TJDColorRef.Create;
  FColor.OnChange:= ColorChanged;
  FAlpha:= 255;
end;

destructor TJDPlotChartUIPoint.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

function TJDPlotChartUIPoint.MakeBrush: TGPSolidBrush;
begin
  Result:= TGPSolidBrush.Create(Winapi.GDIPAPI.MakeColor(FAlpha,
    Color.GetJDColor.Red,
    Color.GetJDColor.Green,
    Color.GetJDColor.Blue
    ));
end;

procedure TJDPlotChartUIPoint.SetAlpha(const Value: Byte);
begin
  FAlpha := Value;
  Invalidate;
end;

procedure TJDPlotChartUIPoint.SetColor(const Value: TJDColorRef);
begin
  FColor:= Value;
  Invalidate;
end;

procedure TJDPlotChartUIPoint.SetPointType(const Value: TJDPlotChartPointType);
begin
  FPointType := Value;
  Invalidate;
end;

procedure TJDPlotChartUIPoint.SetVisible(const Value: Boolean);
begin
  FVisible:= Value;
  Invalidate;
end;

procedure TJDPlotChartUIPoint.SetWidth(const Value: Single);
begin
  FWidth:= Value;
  Invalidate;
end;

{ TJDPlotChartUIAxis }

constructor TJDPlotChartUIAxis.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FBaseLine:= TJDPlotChartUILine.Create(FOwner);
  FBaseLine.Width:= 3;
  FBaseLine.Color.UseStandardColor:= False;
  FBaseLine.Color.Color:= clSilver;
  FBaseLine.Visible:= True;
  FBaseLine.Alpha:= 220;

  FGridLines:= TJDPlotChartUILine.Create(FOwner);
  FGridLines.Width:= 1;
  FGridLines.Color.UseStandardColor:= False;
  FGridLines.Color.Color:= clGray;
  FGridLines.Visible:= True;
  FGridLines.Alpha:= 180;

end;

destructor TJDPlotChartUIAxis.Destroy;
begin

  FreeAndNil(FGridLines);
  FreeAndNil(FBaseLine);
  inherited;
end;

procedure TJDPlotChartUIAxis.SetLabels(const Value: TJDPlotChartLabelPosition);
begin
  FLabels := Value;
  Invalidate;
end;

procedure TJDPlotChartUIAxis.SetBaseLine(const Value: TJDPlotChartUILine);
begin
  FBaseLine.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUIAxis.SetGridLines(const Value: TJDPlotChartUILine);
begin
  FGridLines.Assign(Value);
  Invalidate;
end;

{ TJDPlotPoint }

function TJDPlotPoint.GetDisplayName: String;
begin
  Result:= FormatFloat('0.0000', FX) + ' = ' + FormatFloat('0.0000', FY);
end;

procedure TJDPlotPoint.Invalidate;
begin
  TJDPlotChart(Collection.Owner).Invalidate;
end;

procedure TJDPlotPoint.SetPoint(const P: TPointF; TriggerEvent: Boolean = True);
begin
  SetPoint(P.X, P.Y, TriggerEvent);
end;

procedure TJDPlotPoint.SetPoint(const X, Y: Single; TriggerEvent: Boolean = True);
begin
  FX := X;
  FY := Y;

  TJDPlotChart(Collection.Owner).ClampPoint(Self);
  TJDPlotChart(Collection.Owner).CheckOverlapOnFly(Index);
  TJDPlotChart(Collection.Owner).EnforceLinkLeftAndRight(Self);

  if TriggerEvent then
    TJDPlotChart(Collection.Owner).PointMoved(Self);

  Invalidate;
end;

procedure TJDPlotPoint.SetX(const Value: Single);
begin
  if FX <> Value then
    SetPoint(Value, FY);
end;

procedure TJDPlotPoint.SetY(const Value: Single);
begin
  if FY <> Value then
    SetPoint(FX, Value);
end;

{ TJDPlotPoints }

function TJDPlotPoints.Add: TJDPlotPoint;
begin
  //TODO: Enforce rules...
  Result:= TJDPlotPoint(inherited Add);
  Invalidate;
end;

constructor TJDPlotPoints.Create(AOwner: TJDPlotChart);
begin
  inherited Create(AOwner, TJDPlotPoint);
end;

function TJDPlotPoints.GetItem(const Index: Integer): TJDPlotPoint;
begin
  Result:= TJDPlotPoint(inherited GetItem(Index));
end;

function TJDPlotPoints.Insert(const Index: Integer): TJDPlotPoint;
begin
  //TODO: Enforce rules...
  Result:= TJDPlotPoint(inherited Insert(Index));
end;

procedure TJDPlotPoints.Invalidate;
begin
  TJDPlotChart(Owner).Invalidate;
end;

procedure TJDPlotPoints.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
  //TODO: Enforce rules...
  case Action of
    cnAdded: begin
      TJDPlotChart(Owner).PointAdded(TJDPlotPoint(Item));
    end;
    cnExtracting, cnDeleting: begin
      TJDPlotChart(Owner).PointDeleted(TJDPlotPoint(Item));
    end;
  end;

  Invalidate;
end;

procedure TJDPlotPoints.SetItem(const Index: Integer;
  const Value: TJDPlotPoint);
begin
  //TODO: Enforce rules...
  inherited SetItem(Index, Value);
  Invalidate;
end;

procedure TJDPlotPoints.Update(Item: TCollectionItem);
begin
  inherited;
  //TODO: Enforce rules...
  Invalidate;
end;

{ TJDPlotChartOptionGroup }

constructor TJDPlotChartOptionGroup.Create(AOwner: TJDPlotChart);
begin
  FOwner:= AOwner;

end;

destructor TJDPlotChartOptionGroup.Destroy;
begin

  inherited;
end;

procedure TJDPlotChartOptionGroup.Invalidate;
begin
  FOwner.InvalidateOptionGroup(Self);
end;

{ TJDPlotChartUISurface }

procedure TJDPlotChartUISurface.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

constructor TJDPlotChartUISurface.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FColor:= TJDColorRef.Create;
  FColor.OnChange:= ColorChanged;
  FAlpha:= 255;
end;

destructor TJDPlotChartUISurface.Destroy;
begin
  FreeAndNil(FColor);
  inherited;
end;

function TJDPlotChartUISurface.MakeBrush: TGPSolidBrush;
begin
  Result:= TGPSolidBrush.Create(Winapi.GDIPAPI.MakeColor(
    FAlpha, FColor.RGB.R, FColor.RGB.G, FColor.RGB.B));
end;

function TJDPlotChartUISurface.MakePen: TGPPen;
begin
  Result:= TGPPen.Create(Winapi.GDIPAPI.MakeColor(
    FAlpha, FColor.RGB.R, FColor.RGB.G, FColor.RGB.B),
    1);
end;

procedure TJDPlotChartUISurface.SetAlpha(const Value: Byte);
begin
  FAlpha:= Value;
  Invalidate;
end;

procedure TJDPlotChartUISurface.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

{ TJDPlotChartUX }

constructor TJDPlotChartUX.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FChartArea:= TJDPlotChartUXChart.Create(FOwner);

end;

destructor TJDPlotChartUX.Destroy;
begin

  FreeAndNil(FChartArea);
  inherited;
end;

procedure TJDPlotChartUX.SetChartArea(const Value: TJDPlotChartUXChart);
begin
  FChartArea.Assign(Value);
  Invalidate;
end;

{ TJDPlotChartUXChart }

constructor TJDPlotChartUXChart.Create(AOwner: TJDPlotChart);
begin
  inherited;
  FAxisBottom:= TJDPlotChartUXAxis.Create(FOwner);
  FAxisBottom.Max:= 24;
  FAxisBottom.Frequency:= 2;
  FAxisLeft:= TJDPlotChartUXAxis.Create(FOwner);
  FAxisLeft.Max:= 100;
  FAxisLeft.Frequency:= 10;
  FSnapTolerance:= 8;

end;

destructor TJDPlotChartUXChart.Destroy;
begin
  FreeAndNil(FAxisLeft);
  FreeAndNil(FAxisBottom);

  inherited;
end;

procedure TJDPlotChartUXChart.SetAddPointAnywhere(const Value: Boolean);
begin
  FAddPointAnywhere := Value;
  Invalidate;
end;

procedure TJDPlotChartUXChart.SetAxisBottom(const Value: TJDPlotChartUXAxis);
begin
  FAxisBottom.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUXChart.SetAxisLeft(const Value: TJDPlotChartUXAxis);
begin
  FAxisLeft.Assign(Value);
  Invalidate;
end;

procedure TJDPlotChartUXChart.SetLinkLeftAndRight(const Value: Boolean);
begin
  FLinkLeftAndRight := Value;
  Invalidate;
end;

procedure TJDPlotChartUXChart.SetOverlap(const Value: TJDPlotChartOverlap);
begin
  FOverlap := Value;
  Invalidate;
end;

procedure TJDPlotChartUXChart.SetSnapTolerance(const Value: Single);
begin
  FSnapTolerance := Value;
  Invalidate;
end;

{ TJDPlotChartUXAxis }

constructor TJDPlotChartUXAxis.Create(AOwner: TJDPlotChart);
begin
  inherited;
  Self.FAxisType:= TJDPlotChartAxisType.atCustom;
  Self.FMin:= 0;
  Self.FMax:= 100;
  Self.FFormat:= '';
  Self.FFrequency:= 10;

end;

destructor TJDPlotChartUXAxis.Destroy;
begin

  inherited;
end;

procedure TJDPlotChartUXAxis.SetAxisType(const Value: TJDPlotChartAxisType);
begin
  FAxisType := Value;
  Invalidate;
end;

procedure TJDPlotChartUXAxis.SetFormat(const Value: String);
begin
  FFormat := Value;
  Invalidate;
end;

procedure TJDPlotChartUXAxis.SetMin(const Value: Single);
begin
  if FMin <> Value then begin
    FMin := Value;
    TJDPlotChart(FOwner).AdjustRightMostPoint; // Adjust right-most point
    Invalidate;
  end;
end;

procedure TJDPlotChartUXAxis.SetMax(const Value: Single);
begin
  if FMax <> Value then begin
    FMax := Value;
    TJDPlotChart(FOwner).AdjustRightMostPoint; // Adjust right-most point
    Invalidate;
  end;
end;

procedure TJDPlotChartUXAxis.SetFrequency(const Value: Single);
begin
  FFrequency := Value;
  Invalidate;
end;

{ TJDPlotChartUIFill }

constructor TJDPlotChartUIFill.Create(AOwner: TJDPlotChart);
begin
  inherited;
  Color.Color:= $00303030;
  Alpha:= 120;
end;

end.

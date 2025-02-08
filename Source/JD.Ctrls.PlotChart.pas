unit JD.Ctrls.PlotChart;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Types,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  JD.Common, JD.Graphics,

  GDIPAPI, GDIPOBJ, GDIPUTIL;


const
  AccentColor: TColor = $00282828;
  GridLineColor: TColor = $00373737;

type
  TJDPlotChart = class;

  TJDPlotChartUI = class;
  TJDPlotChartUIBackground = class;
  TJDPlotChartUILine = class;
  TJDPlotChartUIChart = class;


  TJDPlotChartAxisType = (atBasic, atPercent, atDate, atTime);

  TJDPlotChartLabelPosition = (lpNone, lpInside, lpOutside);


  TJDPlotPoint = record
    X: Single;
    Y: Single;
  end;



  TJDPlotChartUI = class(TPersistent)
  private
    FOwner: TJDPlotChart;
    FBackground: TJDPlotChartUIBackground;
    FChartArea: TJDPlotChartUIChart;
    procedure SetBackground(const Value: TJDPlotChartUIBackground);
    procedure SetChartArea(const Value: TJDPlotChartUIChart);
  public
    constructor Create(AOwner: TJDPlotChart);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Background: TJDPlotChartUIBackground read FBackground write SetBackground;
    property ChartArea: TJDPlotChartUIChart read FChartArea write SetChartArea;
  end;

  TJDPlotChartUIBackground = class(TPersistent)
  private
    FOwner: TJDPlotChartUI;
    FColor: TJDColorRef;
    FTransparent: Boolean;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetTransparent(const Value: Boolean);
  public
    constructor Create(AOwner: TJDPlotChartUI);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Color: TJDColorRef read FColor write SetColor;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;

  TJDPlotChartUILine = class(TPersistent)
  private
    FOwner: TJDPlotChartUI;
    FColor: TJDColorRef;
    FWidth: Single;
    FVisible: Boolean;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetWidth(const Value: Single);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TJDPlotChartUI);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Width: Single read FWidth write SetWidth;
    property Color: TJDColorRef read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TJDPlotChartPointType = (ptEllipse, ptRectangle, ptTriangle, ptHexagon);

  TJDPlotChartUIPoint = class(TPersistent)
  private
    FOwner: TJDPlotChartUI;
    FColor: TJDColorRef;
    FWidth: Single;
    FVisible: Boolean;
    FPointType: TJDPlotChartPointType;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetWidth(const Value: Single);
    procedure SetVisible(const Value: Boolean);
    procedure SetPointType(const Value: TJDPlotChartPointType);
  public
    constructor Create(AOwner: TJDPlotChartUI);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property PointType: TJDPlotChartPointType read FPointType write SetPointType;
    property Width: Single read FWidth write SetWidth;
    property Color: TJDColorRef read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TJDPlotChartUIChart = class(TPersistent)
  private
    FOwner: TJDPlotChartUI;
    FBorder: TJDPlotChartUILine;
    FColor: TJDColorRef;
    FTransparent: Boolean;
    FLine: TJDPlotChartUILine;
    FPoints: TJDPlotChartUIPoint;
    procedure ColorChanged(Sender: TObject);
    procedure SetColor(const Value: TJDColorRef);
    procedure SetTransparent(const Value: Boolean);
    procedure SetBorder(const Value: TJDPlotChartUILine);
    procedure SetLine(const Value: TJDPlotChartUILine);
    procedure SetPoints(const Value: TJDPlotChartUIPoint);
  public
    constructor Create(AOwner: TJDPlotChartUI);
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Border: TJDPlotChartUILine read FBorder write SetBorder;
    property Color: TJDColorRef read FColor write SetColor;
    property Line: TJDPlotChartUILine read FLine write SetLine;
    property Points: TJDPlotChartUIPoint read FPoints write SetPoints;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;



  TJDPlotChartAxisBottom = class(TPersistent)
  private
  public
  published
    //AxisType: TJDPlotChartAxisType
    //Labels: TJDPlotChartLabelPosition
    //Min: Single
    //Max: Single
  end;

  TJDPlotChartAxisLeft = class(TPersistent)

  end;



  TJDPlotChart = class(TCustomControl)
  private
    //FGdiPlusToken: ULONG;
    FGdiPlusStartupInput: GdiplusStartupInput;
    FBuffer: TBitmap;
    FUI: TJDPlotChartUI;
    FPoints: TArray<TJDPlotPoint>;
    FHoveringIndex: Integer;
    FDraggingIndex: Integer;
    FDragging: Boolean;
    FDraggingVertical: Boolean;
    FGhostPointVisible: Boolean;
    FGhostPlotPoint: TJDPlotPoint;
    procedure SetUI(const Value: TJDPlotChartUI);
    function PlotPointToPoint(P: TJDPlotPoint): TPointF;
    function PointToPlotPoint(P: TPointF): TJDPlotPoint;
  protected
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

    procedure LoadPlotPoints(Points: TArray<TJDPlotPoint>);
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

    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;

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

  FGdiPlusStartupInput.DebugEventCallback := nil;
  FGdiPlusStartupInput.SuppressBackgroundThread := False;
  FGdiPlusStartupInput.SuppressExternalCodecs := False;
  FGdiPlusStartupInput.GdiplusVersion := 1;
  GdiplusStartup(GdiPlusToken, @FGdiPlusStartupInput, nil);

  FUI:= TJDPlotChartUI.Create(Self);
  FBuffer:= TBitmap.Create;
  FBuffer.SetSize(ClientWidth, ClientHeight);

  Font.Color:= clWhite;
  Font.Quality:= TFontQuality.fqAntialiased;
  Font.Size:= 7;

  //Sample data
  CreatePlotPoints(IncHour(Now,-5), IncHour(Now,5), 30);
end;

destructor TJDPlotChart.Destroy;
begin

  FreeAndNil(FBuffer);
  FreeAndNil(FUI);

  GdiplusShutdown(GdiPlusToken);

  inherited;
end;

procedure TJDPlotChart.CreatePlotPoints(TimeStart, TimeStop: TTime;
  Perc: Single);
var
  StartHour, StopHour: Single;
  Midnight: Boolean;
begin
  StartHour := HourOf(TimeStart) + (MinuteOf(TimeStart) / 60);
  StopHour := HourOf(TimeStop) + (MinuteOf(TimeStop) / 60);

  Midnight := StopHour < StartHour; // Detect if times lapse over midnight

  if Midnight then begin
    SetLength(FPoints, 6);
    FPoints[0].X := 0;
    FPoints[0].Y := Perc; // 0 : 20
    FPoints[1].X := StopHour;
    FPoints[1].Y := Perc; // 9 : 20
    FPoints[2].X := StopHour;
    FPoints[2].Y := 100; // 9 : 100
    FPoints[3].X := StartHour;
    FPoints[3].Y := 100; // 21 : 100
    FPoints[4].X := StartHour;
    FPoints[4].Y := Perc; // 21 : 20
    FPoints[5].X := 23.9999;
    FPoints[5].Y := Perc; // 24 : 20
  end else begin
    SetLength(FPoints, 6);
    FPoints[0].X := 0;
    FPoints[0].Y := 100; // 0 : 100
    FPoints[1].X := StartHour;
    FPoints[1].Y := 100; // StartHour : 100
    FPoints[2].X := StartHour;
    FPoints[2].Y := Perc; // StartHour : Perc
    FPoints[3].X := StopHour;
    FPoints[3].Y := Perc; // StopHour : Perc
    FPoints[4].X := StopHour;
    FPoints[4].Y := 100; // StopHour : 100
    FPoints[5].X := 23.9999;
    FPoints[5].Y := 100; // 24 : 100
  end;

  Invalidate;
end;

procedure TJDPlotChart.DblClick;
var
  MousePos: TPoint;
  ClickPoint: TJDPlotPoint;
  MinDist, Dist: Single;
  DeleteIndex, InsertIndex: Integer;
  NearestP1, NearestP2: TJDPlotPoint;
  T: Single;
begin
  inherited;

  MousePos := ScreenToClient(Mouse.CursorPos);
  ClickPoint := PointToPlotPoint(MousePos);
  MinDist := 10; // Threshold distance to detect proximity to a point or line
  DeleteIndex := -1;

  // Check if the double-click is near an existing point
  for var I := 0 to Length(FPoints) - 1 do begin
    var P := PlotPointToPoint(FPoints[I]);
    Dist := Sqrt(Sqr(P.X - MousePos.X) + Sqr(P.Y - MousePos.Y));
    if Dist < MinDist then begin
      DeleteIndex := I;
      Break;
    end;
  end;

  // If an existing point is found near the double-click, delete it
  if DeleteIndex <> -1 then begin
    for var I := DeleteIndex to Length(FPoints) - 2 do
      FPoints[I] := FPoints[I + 1];
    SetLength(FPoints, Length(FPoints) - 1);
    Invalidate;
    Exit;
  end;

  // Detect if double-click is near a line
  for var I := 0 to Length(FPoints) - 2 do begin
    var P1 := PlotPointToPoint(FPoints[I]);
    var P2 := PlotPointToPoint(FPoints[I + 1]);

    // Check the proximity to the line segment P1-P2
    Dist := PointLineDistance(MousePos, P1, P2);
    if Dist < MinDist then begin
      NearestP1 := FPoints[I];
      NearestP2 := FPoints[I + 1];

      // Calculate the closest point on the line segment to the mouse position
      var DX := P2.X - P1.X;
      var DY := P2.Y - P1.Y;
      var LineLenSquared := DX * DX + DY * DY;
      T := ((MousePos.X - P1.X) * DX + (MousePos.Y - P1.Y) * DY) / LineLenSquared;
      if T < 0 then T := 0;
      if T > 1 then T := 1;

      // Create the new point exactly on the line
      var NewPoint: TJDPlotPoint;
      NewPoint.X := NearestP1.X + T * (NearestP2.X - NearestP1.X);
      NewPoint.Y := NearestP1.Y + T * (NearestP2.Y - NearestP1.Y);

      InsertIndex := I + 1;
      SetLength(FPoints, Length(FPoints) + 1);
      for var J := Length(FPoints) - 1 downto InsertIndex + 1 do
        FPoints[J] := FPoints[J - 1];
      FPoints[InsertIndex] := NewPoint;

      Invalidate;

      Exit;
    end;
  end;

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
  for I := 0 to Length(FPoints) - 2 do
  begin
    if (FPoints[I].X <= TargetHour) and (TargetHour <= FPoints[I + 1].X) then
    begin
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

procedure TJDPlotChart.LoadPlotPoints(Points: TArray<TJDPlotPoint>);
begin
  FPoints := Points;
  Invalidate;
end;

function TJDPlotChart.ChartRect: TJDRect;
begin
  Result:= ClientRect;
  //TODO
  Result.Left:= 30;
  Result.Right:= Result.Right - 12;
  Result.Top:= 12;
  Result.Bottom:= Result.Bottom - 30;
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
    if (FDraggingIndex = 0) or (FDraggingIndex = Length(FPoints) - 1) then begin
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
  R: TJDRect;
  HoverPoint: TPointF;
  //Dist: Single;
  MinDist: Single;
  NearestP1, NearestP2: TJDPlotPoint;
  GhostFound, NearPoint: Boolean;
begin
  inherited;

  R := ChartRect;
  GhostFound := False;
  NearPoint := False;
  MinDist := 10; // Threshold distance to detect proximity to a line

  FHoveringIndex := -1;
  for var I := 0 to Length(FPoints) - 1 do begin
    var P := PlotPointToPoint(FPoints[I]);
    if (Abs(P.X - X) <= 4) and (Abs(P.Y - Y) <= 4) then begin
      FHoveringIndex := I;
      NearPoint := True;
      Break;
    end;
  end;

  // Update StatusBar with hovered time and percentage or clear if outside
  if PtInRect(R, Point(X, Y)) or Dragging then begin
    if FDragging and (FDraggingIndex <> -1) then  begin
      var NewPoint := PointToPlotPoint(Point(X, Y));

      // Clamp to chart area
      if NewPoint.Y < 0 then
        NewPoint.Y := 0;
      if NewPoint.Y > 100 then
        NewPoint.Y := 100;

      if not FDraggingVertical then begin
        if NewPoint.X < 0 then
          NewPoint.X := 0;
        if NewPoint.X > 24 then
          NewPoint.X := 24;

        // Prevent dragging past neighboring points
        if (FDraggingIndex > 0) and (NewPoint.X <= FPoints[FDraggingIndex - 1].X) then
          NewPoint.X := FPoints[FDraggingIndex - 1].X + 0.01; // Small increment to prevent overlap
        if (FDraggingIndex < Length(FPoints) - 1) and (NewPoint.X >= FPoints[FDraggingIndex + 1].X) then
          NewPoint.X := FPoints[FDraggingIndex + 1].X - 0.01; // Small decrement to prevent overlap

        FPoints[FDraggingIndex] := NewPoint;
      end else begin
        // Adjust only the percentage (vertical position)
        FPoints[FDraggingIndex].Y := NewPoint.Y;

        // Move the other fixed point if dragging the first or last point
        if FDraggingIndex = 0 then
          FPoints[Length(FPoints) - 1].Y := NewPoint.Y
        else if FDraggingIndex = Length(FPoints) - 1 then
          FPoints[0].Y := NewPoint.Y;
      end;

      // Use the new point for status bar update
      HoverPoint := PlotPointToPoint(FPoints[FDraggingIndex]);
    end  else  begin
      HoverPoint := Point(X, Y);
    end;

    {
    // Ensure valid time before setting to status bar
    var StoppedPoint := PointToPlotPoint(HoverPoint);
    var Hour := Trunc(StoppedPoint.X);
    var Minute := Round(Frac(StoppedPoint.X) * 60);
    if Hour < 0 then Hour := 0;
    if Hour > 23 then Hour := 23;
    if Minute < 0 then Minute := 0;
    if Minute > 59 then Minute := 59;
    var HoverTime := EncodeTime(Hour, Minute, 0, 0);
    var HoverPerc := GetTimePerc(HoverTime);
    //Stat.Panels[0].Text := Format('Time: %s', [TimeToStr(HoverTime)]);
    //Stat.Panels[1].Text := Format('Percentage: %.2f%%', [HoverPerc]);
    }

    // Detect if hovering near a line
    for var I := 0 to Length(FPoints) - 2 do begin
      var P1 := PlotPointToPoint(FPoints[I]);
      var P2 := PlotPointToPoint(FPoints[I + 1]);
      // Check the proximity to the line segment P1-P2
      var LineDist := PointLineDistance(Point(X, Y), P1, P2);
      if LineDist < MinDist then begin
        GhostFound := True;
        NearestP1 := FPoints[I];
        NearestP2 := FPoints[I + 1];
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
  end else begin
    //Stat.Panels[0].Text := '';
    //Stat.Panels[1].Text := '';
    FGhostPointVisible := False;
  end;

  Invalidate;
end;

procedure TJDPlotChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if FDragging then begin
    FDragging := False;
    FDraggingIndex := -1;
    //TODO: Trigger event...
  end;

  Invalidate;
end;

procedure TJDPlotChart.Paint;
var
  W, H: Single;
  G: TGPGraphics;

  procedure Line(P1, P2: TPoint; AColor: TColor; AWidth: Integer = 1);
  var
    Pen: TGPPen;
  begin
    Pen := TGPPen.Create(MakeColor(255, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)), AWidth);
    try
      Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      Pen.SetLineJoin(LineJoinRound);
      G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);
    finally
      Pen.Free;
    end;
  end;

  procedure DrawBackground;
  var
    Brush: TGPSolidBrush;
  begin
    if FUI.Background.Transparent then begin
      JD.Graphics.DrawParentImage(Self, Canvas);
      JD.Graphics.DrawParentImage(Self, FBuffer.Canvas);
    end else begin
        // Create and set a solid brush with the background color
      Brush := TGPSolidBrush.Create(MakeColor(255, GetRValue(FUI.Background.Color.GetJDColor),
                                              GetGValue(FUI.Background.Color.GetJDColor),
                                              GetBValue(FUI.Background.Color.GetJDColor)));
      try
        G.FillRectangle(Brush, ClientRect.Left, ClientRect.Top, ClientRect.Right - ClientRect.Left, ClientRect.Bottom - ClientRect.Top);
      finally
        Brush.Free;
      end;
      //TODO: Border...
    end;
  end;

  {
  procedure DrawVerticalGridLines;
  var
    LabelFreq: Integer;
  begin
    W := (ChartRect.Right - ChartRect.Left) / 24; // Divide by 24 hours
    LabelFreq := 1; // Default frequency for labels
    if W < 20 then
      LabelFreq := 4 // If too small, label every 4 hours
    else if W < 40 then
      LabelFreq := 2; // If small, label every 2 hours

    for var X: Integer := 0 to 24 do begin
      var P1 := Point(ChartRect.Left + Round(X * W), ChartRect.Top);
      var P2 := Point(P1.X, ChartRect.Bottom);
      FBuffer.Canvas.Brush.Style := bsClear;
      Line(P1, P2, FUI.ChartArea.Border.Color.GetJDColor, Ceil(FUI.ChartArea.Border.Width));
      if (X mod LabelFreq = 0) and (X <> 0) and (X <> 24) then begin
        FBuffer.Canvas.Font.Assign(Font);
        //FBuffer.Canvas.Font.Color := clWhite;
        FBuffer.Canvas.TextOut(P1.X + 2, ChartRect.Bottom - 15, Format('%d %s', [IfThen(X > 12, X - 12, X), IfThen(X < 12, 'AM', 'PM')])); // AM/PM format without minutes
      end;
    end;
  end;
  }

  procedure DrawVerticalGridLines;
  var
    LabelFreq: Integer;
    Pen: TGPPen;
    FontFamily: TGPFontFamily;
    GdiFont: TGPFont;
    SolidBrush: TGPSolidBrush;
    LayoutRect: TGPRectF;
  begin
    W := (ChartRect.Right - ChartRect.Left) / 24; // Divide by 24 hours
    LabelFreq := 1; // Default frequency for labels
    if W < 20 then
      LabelFreq := 4 // If too small, label every 4 hours
    else if W < 40 then
      LabelFreq := 2; // If small, label every 2 hours

    Pen := TGPPen.Create(MakeColor(255, GetRValue(FUI.ChartArea.Border.Color.GetJDColor),
                                    GetGValue(FUI.ChartArea.Border.Color.GetJDColor),
                                    GetBValue(FUI.ChartArea.Border.Color.GetJDColor)), Ceil(FUI.ChartArea.Border.Width));
    try
      Pen.SetDashStyle(DashStyleSolid);

      for var X: Integer := 0 to 24 do
      begin
        var P1 := PointF(ChartRect.Left + Round(X * W), ChartRect.Top);
        var P2 := PointF(P1.X, ChartRect.Bottom);
        G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);

        if (X mod LabelFreq = 0) and (X <> 0) and (X <> 24) then
        begin
          FontFamily := TGPFontFamily.Create('Arial');
          GdiFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPixel);
          SolidBrush := TGPSolidBrush.Create(MakeColor(255, 255, 255, 255)); // White color
          try
            var Text := Format('%d %s', [IfThen(X > 12, X - 12, X), IfThen(X < 12, 'AM', 'PM')]); // AM/PM format without minutes
            LayoutRect.X := P1.X + 2;
            LayoutRect.Y := ChartRect.Bottom - 15;
            LayoutRect.Width := 100;
            LayoutRect.Height := 20; // Define the bounding box for the text
            G.DrawString(PChar(Text), -1, GdiFont, LayoutRect, nil, SolidBrush);
          finally
            SolidBrush.Free;
            GdiFont.Free;
            FontFamily.Free;
          end;
        end;
      end;
    finally
      Pen.Free;
    end;
  end;

  procedure DrawHorizontalGridLines;
  var
    LabelFreq: Integer;
    Pen: TGPPen;
    FontFamily: TGPFontFamily;
    GdiFont: TGPFont;
    SolidBrush: TGPSolidBrush;
    LayoutRect: TGPRectF;
  begin
    H := (ChartRect.Bottom - ChartRect.Top) / 10; // Divide by 10 (10% intervals)
    LabelFreq := 1; // Default frequency for labels
    if H < 10 then
      LabelFreq := 10; // If too small, label every 10%

    Pen := TGPPen.Create(MakeColor(255, GetRValue(FUI.ChartArea.Border.Color.GetJDColor),
                                    GetGValue(FUI.ChartArea.Border.Color.GetJDColor),
                                    GetBValue(FUI.ChartArea.Border.Color.GetJDColor)), Ceil(FUI.ChartArea.Border.Width));
    try
      Pen.SetDashStyle(DashStyleSolid);

      for var Y: Integer := 0 to 10 do
      begin
        var P1 := PointF(ChartRect.Left, ChartRect.Bottom - Round(Y * H));
        var P2 := PointF(ChartRect.Right, P1.Y);
        G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);

        if (Y mod LabelFreq = 0) and (Y <> 0) and (Y <> 10) then
        begin
          FontFamily := TGPFontFamily.Create('Arial');
          GdiFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPixel);
          SolidBrush := TGPSolidBrush.Create(MakeColor(255, 255, 255, 255)); // White color
          try
            var Text := Format('%d%%', [Y * 10]);
            LayoutRect.X := ChartRect.Left + 5;
            LayoutRect.Y := P1.Y - 10;
            LayoutRect.Width := 100;
            LayoutRect.Height := 20; // Define the bounding box for the text
            G.DrawString(PChar(Text), -1, GdiFont, LayoutRect, nil, SolidBrush);
          finally
            SolidBrush.Free;
            GdiFont.Free;
            FontFamily.Free;
          end;
        end;
      end;
    finally
      Pen.Free;
    end;
  end;

  procedure DrawLines(AColor: TColor; AWidth: Integer);
  var
    Pen: TGPPen;
  begin
    Pen := TGPPen.Create(MakeColor(255, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)), AWidth);
    try
      Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      Pen.SetLineJoin(LineJoinRound);

      for var X := 0 to Length(FPoints) - 2 do
      begin
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
    Z: Integer;
    Brush: TGPSolidBrush;
  begin
    Z := Ceil(FUI.ChartArea.Points.Width / 2);

    for var X := 0 to Length(FPoints) - 1 do
    begin
      var P := PlotPointToPoint(FPoints[X]);
      if FHoveringIndex = X then
        Brush := TGPSolidBrush.Create(MakeColor(255, 255, 0, 0)) // Red color
      else
        Brush := TGPSolidBrush.Create(MakeColor(255, GetRValue(FUI.ChartArea.Points.Color.GetJDColor),
                                                GetGValue(FUI.ChartArea.Points.Color.GetJDColor),
                                                GetBValue(FUI.ChartArea.Points.Color.GetJDColor)));
      try
        G.FillEllipse(Brush, P.X - Z, P.Y - Z, Z * 2, Z * 2);
      finally
        Brush.Free;
      end;
    end;
  end;

  function GetPolyUnderLine(P1, P2: TPointF): TArray<TGPPointF>;
  begin
    SetLength(Result, 4);
    Result[0] := MakePoint(P1.X, P1.Y);
    Result[1] := MakePoint(P2.X, P2.Y);
    Result[2] := MakePoint(P2.X, ChartRect.Bottom);
    Result[3] := MakePoint(P1.X, ChartRect.Bottom);
  end;

  procedure DrawAccentColor(AColor: TColor);
  var
    Brush: TGPSolidBrush;
    Poly: TArray<TGPPointF>;
  begin
    Brush := TGPSolidBrush.Create(MakeColor(255, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)));
    try
      for var I := 0 to Length(FPoints) - 2 do
      begin
        var P1 := PlotPointToPoint(FPoints[I]);
        var P2 := PlotPointToPoint(FPoints[I + 1]);
        Poly := GetPolyUnderLine(P1, P2);
        G.FillPolygon(Brush, PGPPoint(Poly), Length(Poly));
      end;
    finally
      Brush.Free;
    end;
  end;

  procedure DrawAxis;
  begin

    {
    // Draw Left Axis
    var P1 := Point(ChartRect.Left, ChartRect.Top);
    var P2 := Point(ChartRect.Left, ChartRect.Bottom);
    Line(P1, P2, clGray, 3); //TODO

    // Draw Bottom Axis
    P1 := Point(ChartRect.Left, ChartRect.Bottom);
    P2 := Point(ChartRect.Right, ChartRect.Bottom);
    Line(P1, P2, clGray, 3); //TODO
    }

    // Create Pen for Axis Lines
    var Pen: TGPPen;
    Pen := TGPPen.Create(MakeColor(255, GetRValue(clGray), GetGValue(clGray), GetBValue(clGray)), 3);
    try
      Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      Pen.SetLineJoin(LineJoinRound);

      // Draw Left Axis
      var P1 := PointF(ChartRect.Left, ChartRect.Top);
      var P2 := PointF(ChartRect.Left, ChartRect.Bottom);
      G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);

      // Draw Bottom Axis
      P1 := PointF(ChartRect.Left, ChartRect.Bottom);
      P2 := PointF(ChartRect.Right, ChartRect.Bottom);
      G.DrawLine(Pen, P1.X, P1.Y, P2.X, P2.Y);
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

    //TODO: Use GDI+ canvas!!!

    // Draw Background
    DrawBackground;

    // Draw color beneath plotted line
    DrawAccentColor(AccentColor); //TODO

    // Draw Grid Lines
    DrawVerticalGridLines;
    DrawHorizontalGridLines;
    DrawAxis;

    // Draw Line(s) and Points
    if FUI.ChartArea.Line.Visible then
      DrawLines(FUI.ChartArea.Line.Color.GetJDColor, Ceil(FUI.ChartArea.Line.Width));
    if FUI.ChartArea.Points.Visible then
      DrawPoints;

    // Draw Ghost Point if visible
    if FGhostPointVisible then
    begin
      var GP := PlotPointToPoint(FGhostPlotPoint);
      var Brush := TGPSolidBrush.Create(MakeColor(255, 0, 255, 255)); // Aqua color
      try
        G.FillEllipse(Brush, GP.X - 4, GP.Y - 4, 8, 8);
      finally
        Brush.Free;
      end;
    end;



    //Draw buffer to actual control canvas
    Canvas.Draw(0, 0, FBuffer);

  finally
    G.Free;
  end;
end;

function TJDPlotChart.PlotPointToPoint(P: TJDPlotPoint): TPointF;
var
  R: TRectF;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / 24;  // 24 hours in a day
  YRatio := (R.Bottom - R.Top) / 100; // Percentage from 0 to 100

  // Translate coordinates
  Result.X := R.Left + P.X * XRatio;
  Result.Y := R.Bottom - P.Y * YRatio; // Y-axis is typically inverted
end;

function TJDPlotChart.PointToPlotPoint(P: TPointF): TJDPlotPoint;
var
  R: TRectF;
  XRatio, YRatio: Single;
begin
  R := ChartRect;

  // Calculate the ratios
  XRatio := (R.Right - R.Left) / 24; // 24 hours in a day
  YRatio := (R.Bottom - R.Top) / 100; // Percentage from 0 to 100

  // Translate coordinates
  Result.X := (P.X - R.Left) / XRatio;
  Result.Y := (R.Bottom - P.Y) / YRatio; // Y-axis is typically inverted
end;

procedure TJDPlotChart.Resize;
begin
  inherited;
  FBuffer.SetSize(ClientWidth, ClientHeight);
  Invalidate;
end;

procedure TJDPlotChart.SetUI(const Value: TJDPlotChartUI);
begin
  FUI.Assign(Value);
  Invalidate;
end;

{ TJDPlotChartUI }

constructor TJDPlotChartUI.Create(AOwner: TJDPlotChart);
begin
  FOwner:= AOwner;
  FBackground:= TJDPlotChartUIBackground.Create(Self);
  FChartArea:= TJDPlotChartUIChart.Create(Self);

end;

destructor TJDPlotChartUI.Destroy;
begin

  FreeAndNil(FChartArea);
  FreeAndNil(FBackground);
  inherited;
end;

procedure TJDPlotChartUI.Invalidate;
begin
  FOwner.Invalidate;
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

procedure TJDPlotChartUIBackground.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

constructor TJDPlotChartUIBackground.Create(AOwner: TJDPlotChartUI);
begin
  FOwner:= AOwner;
  FColor:= TJDColorRef.Create;
  FColor.UseStandardColor:= False;
  FColor.Color:= clBlack;
  FColor.OnChange:= ColorChanged;
  FTransparent:= False;
end;

destructor TJDPlotChartUIBackground.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

procedure TJDPlotChartUIBackground.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDPlotChartUIBackground.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
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

constructor TJDPlotChartUIChart.Create(AOwner: TJDPlotChartUI);
begin
  FOwner:= AOwner;
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

  FTransparent:= False;
end;

destructor TJDPlotChartUIChart.Destroy;
begin

  FreeAndNil(FPoints);
  FreeAndNil(FLine);
  FreeAndNil(FBorder);
  FreeAndNil(FColor);
  inherited;
end;

procedure TJDPlotChartUIChart.Invalidate;
begin
  FOwner.Invalidate;
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

procedure TJDPlotChartUIChart.SetLine(const Value: TJDPlotChartUILine);
begin
  FLine.Assign(Value);
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

procedure TJDPlotChartUILine.ColorChanged(Sender: TObject);
begin
  Invalidate;
end;

constructor TJDPlotChartUILine.Create(AOwner: TJDPlotChartUI);
begin
  FOwner:= AOwner;
  FColor:= TJDColorRef.Create;
  FColor.Color:= clSilver;
  FColor.OnChange:= ColorChanged;
  FVisible:= True;
  FWidth:= 1;
end;

destructor TJDPlotChartUILine.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

procedure TJDPlotChartUILine.Invalidate;
begin
  FOwner.Invalidate;
end;

procedure TJDPlotChartUILine.SetColor(const Value: TJDColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
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

constructor TJDPlotChartUIPoint.Create(AOwner: TJDPlotChartUI);
begin
  FOwner:= AOwner;
  FColor:= TJDColorRef.Create;
  FColor.OnChange:= ColorChanged;

end;

destructor TJDPlotChartUIPoint.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

procedure TJDPlotChartUIPoint.Invalidate;
begin
  FOwner.Invalidate;
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

end.

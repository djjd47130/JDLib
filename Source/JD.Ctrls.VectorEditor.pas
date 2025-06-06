unit JD.Ctrls.VectorEditor;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes,
  System.Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics, Vcl.Controls,
  JD.Ctrls,
  JD.Common,
  JD.Graphics,
  XSuperObject,
  GDIPAPI, GDIPOBJ, GDIPUTIL,
  JD.Vector;

type

  /// <summary>
  ///   Renders a vector graphic to a control canvas.
  /// </summary>
  TJDVectorImage = class;



  TJDVectorImage = class(TJDControl)
  const
    DEF_PADDING = 10;
  private
    FGraphic: TJDVectorGraphic;
    FAlignX: TJDVectorAlign;
    FAlignY: TJDVectorAlign;
    FAutoSize: Boolean;
    FPadding: Single;
    FShowGrid: Boolean;
    FMouseDown: Boolean;
    FPointDown: TJDPoint;
    FPointUp: TJDPoint;
    FGridLines: TJDUIPen;
    FFrame: TJDUIPen;
    procedure GraphicChanged(Sender: TObject);
    procedure SetGraphic(const Value: TJDVectorGraphic);
    procedure SetAlignX(const Value: TJDVectorAlign);
    procedure SetAlignY(const Value: TJDVectorAlign);
    procedure SetAutoSize(const Value: Boolean); reintroduce;
    procedure SetPadding(const Value: Single);
    function ComputeAutoScale: Single;
    function GetPaddingStored: Boolean;
    procedure SetShowGrid(const Value: Boolean);
    procedure SetGridLines(const Value: TJDUIPen);
    procedure GridLinesChanged(Sender: TObject);
    procedure SetFrame(const Value: TJDUIPen);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function DrawRect: TJDRect;
  published
    property Align;
    property AlignX: TJDVectorAlign read FAlignX write SetAlignX default vaCenter;
    property AlignY: TJDVectorAlign read FAlignY write SetAlignY default vaCenter;
    property AlignWithMargins;
    property Anchors;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Color default clWhite;
    property DoubleBuffered;
    property Frame: TJDUIPen read FFrame write SetFrame;
    property Graphic: TJDVectorGraphic read FGraphic write SetGraphic;
    property GridLines: TJDUIPen read FGridLines write SetGridLines;
    property Margins;
    property Padding: Single read FPadding write SetPadding stored GetPaddingStored;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property Visible;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnEnter;
    property OnExit;

  end;

implementation

uses
  System.Math;

{ TJDVectorImage }

procedure TJDVectorImage.Click;
begin
  inherited;
  if Self.CanFocus then
    Self.SetFocus;
end;

function TJDVectorImage.ComputeAutoScale: Single;
var
  Bounds: TRect;
  AvailableWidth, AvailableHeight: Single;
  ScaleX, ScaleY: Single;
begin
  if not FAutoSize or (FGraphic = nil) then
    Exit(FGraphic.Scale); // Keep existing scale if AutoSize is off

  // Get graphic bounds based on its current scale
  Bounds := FGraphic.GetBounds; // Use base scale for accurate size

  // Determine the available space inside the control (account for padding)
  AvailableWidth := Width - (FPadding * 2);
  AvailableHeight := Height - (FPadding * 2);

  if Bounds.Width = 0 then
    Bounds.Width:= 1;
  if Bounds.Height = 0 then
    Bounds.Height:= 1;

  // Calculate potential scaling factors
  ScaleX := AvailableWidth / Bounds.Width;
  ScaleY := AvailableHeight / Bounds.Height;

  // Use the smaller scale to ensure the entire graphic fits
  Result := Min(ScaleX, ScaleY);
end;

constructor TJDVectorImage.Create(AOwner: TComponent);
begin
  inherited;
  FAutoSize:= True;
  FAlignX:= vaCenter;
  FAlignY:= vaCenter;
  FPadding:= DEF_PADDING;
  Color:= clWhite;

  FGraphic:= TJDVectorGraphic.Create(Self);
  FGraphic.OnChange:= GraphicChanged;

  FGridLines:= TJDUIPen.Create(Self);
  FGridLines.Width:= 1.0;
  FGridLines.Color.Color:= clDkGray;
  FGridLines.OnChange:= GridLinesChanged;

  FFrame:= TJDUIPen.Create(Self);
  FFrame.Width:= 1.7;
  FFrame.Color.Color:= clBlack;
  FFrame.OnChange:= GridLinesChanged;

end;

destructor TJDVectorImage.Destroy;
begin

  FreeAndNil(FFrame);
  FreeAndNil(FGridLines);
  FreeAndNil(FGraphic);
  inherited;
end;

procedure TJDVectorImage.GridLinesChanged(Sender: TObject);
begin
  Invalidate;
end;

function TJDVectorImage.GetPaddingStored: Boolean;
begin
  Result:= FPadding <> DEF_PADDING;
end;

procedure TJDVectorImage.GraphicChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TJDVectorImage.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if Button = TMouseButton.mbLeft then begin
    FMouseDown:= True;
    FPointDown.X:= X;
    FPointDown.Y:= Y;
  end;
end;

procedure TJDVectorImage.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TJDVectorImage.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if FMouseDown then begin
    FMouseDown:= False;
    FPointUp.X:= X;
    FPointUp.Y:= Y;
    //TODO
  end;
end;

function TJDVectorImage.DrawRect: TJDRect;
begin
  Result:= ClientRect;
  Result.Deflate(Padding, Padding);
end;

procedure TJDVectorImage.Paint;
var
  Bounds: TJDRect;
  OffsetX, OffsetY: Single;
  FinalScale: Single;
begin
  inherited;
  if FGraphic = nil then Exit;

  Bounds:= Self.ClientRect;

  // Create GDI+ Graphics object
  var C := TGPGraphics.Create(Canvas.Handle);
  try
    C.SetSmoothingMode(SmoothingModeAntiAlias);

    //Background
    Canvas.Brush.Style:= bsSolid;
    Canvas.Brush.Color:= Color;
    Canvas.Pen.Style:= psClear;
    Canvas.FillRect(Bounds);

    //Grid
    if FShowGrid then begin

      Bounds:= DrawRect;

      var Pen:= FGridLines.MakePen;
      Pen.SetDashStyle(DashStyle.DashStyleDash);
      Pen.SetDashOffset(3.0);

      var P1, P2: TJDPoint;

      var Spacing:= Bounds.Width / 10;
      P1.Y:= Bounds.Top;
      P2.Y:= Bounds.Bottom;
      for var X := 1 to 10 do begin
        P1.X:= Spacing * X + Bounds.Left;
        P2.X:= P1.X;
        if X = 5 then
          Pen.SetWidth(FGridLines.Width + 1)
        else
          Pen.SetWidth(FGridLines.Width);
        C.DrawLine(Pen, P1, P2);
      end;

      Spacing:= Bounds.Height / 10;
      P1.X:= Bounds.Left;
      P2.X:= Bounds.Right;
      for var X := 1 to 10 do begin
        P1.Y:= Spacing * X + Bounds.Top;
        P2.Y:= P1.Y;
        if X = 5 then
          Pen.SetWidth(FGridLines.Width + 1)
        else
          Pen.SetWidth(FGridLines.Width);
        C.DrawLine(Pen, P1, P2);
      end;

      //Draw frame
      Pen:= FFrame.MakePen;
      C.DrawRectangle(Pen, Bounds);

    end;


    //TODO: Add support for hierarchy of parts...

    // Determine the appropriate scaling
    FinalScale := ComputeAutoScale;
    OffsetX:= 0;
    OffsetY:= 0;

    // Get graphic bounds with computed scale
    Bounds := FGraphic.GetBounds(FinalScale);

    // Compute alignment offsets while considering the new scale
    case AlignX of
      vaLeading:  OffsetX := Round(FPadding - Bounds.Left);
      vaCenter:   OffsetX := ((Width - Bounds.Width) / 2) - Bounds.Left;
      vaTrailing: OffsetX := Round(Width - Bounds.Width - Bounds.Left - FPadding);
    end;

    case AlignY of
      vaLeading:  OffsetY := Round(FPadding - Bounds.Top);
      vaCenter:   OffsetY := ((Height - Bounds.Height) / 2) - Bounds.Top;
      vaTrailing: OffsetY := Round(Height - Bounds.Height - Bounds.Top - FPadding);
    end;

    // Render the actual graphic
    FGraphic.Render(C, OffsetX, OffsetY, FinalScale);

  finally
    C.Free;
  end;
end;

procedure TJDVectorImage.SetAlignX(const Value: TJDVectorAlign);
begin
  FAlignX := Value;
  Invalidate;
end;

procedure TJDVectorImage.SetAlignY(const Value: TJDVectorAlign);
begin
  FAlignY := Value;
  Invalidate;
end;

procedure TJDVectorImage.SetAutoSize(const Value: Boolean);
begin
  FAutoSize:= Value;
  Invalidate;
end;

procedure TJDVectorImage.SetFrame(const Value: TJDUIPen);
begin
  FFrame.Assign(Value);
  Invalidate;
end;

procedure TJDVectorImage.SetGraphic(const Value: TJDVectorGraphic);
begin
  FGraphic.Assign(Value);
  Invalidate;
end;

procedure TJDVectorImage.SetGridLines(const Value: TJDUIPen);
begin
  FGridLines := Value;
  Invalidate;
end;

procedure TJDVectorImage.SetPadding(const Value: Single);
begin
  FPadding := Value;
  Invalidate;
end;

procedure TJDVectorImage.SetShowGrid(const Value: Boolean);
begin
  FShowGrid := Value;
  Invalidate;
end;

end.

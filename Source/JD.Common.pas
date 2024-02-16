unit JD.Common;

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  ;

{$DEFINE USE_GDIP}

const
  ///  <summary>
  ///  Windows message for when color themes change.
  ///  </summary>
  WM_JD_COLORCHANGE = WM_USER + 42;

  ///  <summary>
  ///  Windows message when user drags window / control.
  ///  </summary>
  SC_DRAGMOVE = $F012;

type
  ///  <summary>
  ///  Base exception type for us across JDLib.
  ///  </summary>
  EJDException = Exception;

  ///  <summary>
  ///  Exception for when a value is out of a given range.
  ///  </summary>
  EJDOutOfRange = EJDException;

  PJDPoint = ^TJDPoint;
  ///  <summary>
  ///  Defines a standardized point with floating point values at its root.
  ///  </summary>
  TJDPoint = record
  private
    FX: Single;
    FY: Single;
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
  public
    class operator Implicit(Value: TJDPoint): TPoint;
    class operator Implicit(Value: TPoint): TJDPoint;
    class operator Implicit(Value: TJDPoint): TGPPointF;
    class operator Implicit(Value: TGPPointF): TJDPoint;
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
    procedure Move(const AmtX, AmtY: Single);
  end;

  PJDRect = ^TJDRect;
  ///  <summary>
  ///  Defines a standardized rectangle with floating point values at its root.
  ///  </summary>
  TJDRect = record
  private
    FRect: TRectF;
    function GetBottom: Single;
    function GetRight: Single;
    procedure SetHeight(const Value: Single);
    procedure SetWidth(const Value: Single);
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
    procedure SetBottom(const Value: Single);
    procedure SetRight(const Value: Single);
    function GetHeight: Single;
    function GetWidth: Single;
    function GetX: Single;
    function GetY: Single;
    function GetLeft: Single;
    function GetTop: Single;
    procedure SetLeft(const Value: Single);
    procedure SetTop(const Value: Single);
  public
    class operator Implicit(Value: TRect): TJDRect;
    class operator Implicit(Value: TJDRect): TRect;
    class operator Implicit(Value: TRectF): TJDRect;
    class operator Implicit(Value: TJDRect): TRectF;
    class operator Implicit(Value: TGPRectF): TJDRect;
    class operator Implicit(Value: TJDRect): TGPRectF;
    property X: Single read GetX write SetX;
    property Y: Single read GetY write SetY;
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;
    property Right: Single read GetRight write SetRight;
    property Bottom: Single read GetBottom write SetBottom;
    property Left: Single read GetLeft write SetLeft;
    property Top: Single read GetTop write SetTop;

    procedure Inflate(const AmtX, AmtY: Single);
    procedure Deflate(const AmtX, AmtY: Single);
    procedure Move(const AmtX, AmtY: Single);

    function TopLeft: TJDPoint;
    function TopRight: TJDPoint;
    function BottomLeft: TJDPoint;
    function BottomRight: TJDPoint;
    function Center: TJDPoint;
    function TopCenter: TJDPoint;
    function BottomCenter: TJDPoint;
    function LeftCenter: TJDPoint;
    function RightCenter: TJDPoint;

    function ContainsPoint(const P: TJDPoint): Boolean;
  end;

  ///  <summary>
  ///  Very core base for all custom JD components. This has the sole purpose
  ///  of forcing these units to be included in the uses clause automatically.
  ///  NOTE: Use TJDMessageComponent instead for Windows message handling.
  ///  </summary>
  TJDComponent = class(TComponent)
  end;

  ///  <summary>
  ///  Base component to efficiently receive Windows messages.
  ///  </summary>
  TJDMessageComponent = class(TJDComponent)
  private
    FHandle: HWND;
  protected
    procedure WndMethod(var Message: TMessage); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; virtual;
    property Handle: HWND read FHandle;
  end;

  ///  <summary>
  ///    Very core base for all custom JD controls. Gets inherited by
  ///    TJDControl in JD.Ctrls for the purpose of forcing these units
  ///    to be included in the uses clause automatically.
  ///  </summary>
  TJDCustomControl = class(TCustomControl)
  protected
    procedure WMColorChange(var Message: TMessage); message WM_JD_COLORCHANGE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

///  <summary>
///  Ensures an integer falls within a given min/max range.
///  </summary>
function IntRange(const Value, Min, Max: Integer): Integer;

function JDAlignmentToFlags(const AValue: TAlignment): Cardinal;

implementation

uses
  JD.Graphics;

function IntRange(const Value, Min, Max: Integer): Integer;
begin
  Result:= Value;
  if Result < Min then Result:= Min;
  if Result > Max then Result:= Max;
end;

function JDAlignmentToFlags(const AValue: TAlignment): Cardinal;
begin
  case AValue of
    taLeftJustify:  Result:= DT_LEFT;
    taRightJustify: Result:= DT_RIGHT;
    taCenter:       Result:= DT_CENTER;
    else            Result:= DT_LEFT;
  end;
end;

{ TJDMessageComponent }

constructor TJDMessageComponent.Create(AOwner: TComponent);
begin
  inherited;
  FHandle:= AllocateHwnd(WndMethod);
  ColorManager.RegisterComponent(Self);
end;

destructor TJDMessageComponent.Destroy;
begin
  ColorManager.UnregisterComponent(Self);
  DeallocateHWnd(FHandle);
  inherited;
end;

procedure TJDMessageComponent.Invalidate;
begin
  //Override expected
end;

procedure TJDMessageComponent.WndMethod(var Message: TMessage);
begin
  if Message.Msg = WM_JD_COLORCHANGE then begin
    Invalidate;
  end else begin
    //TODO: Is there anything else I need to do here?
    //inherited;
  end;
end;

{ TJDCustomControl }

constructor TJDCustomControl.Create(AOwner: TComponent);
begin
  inherited;
  ColorManager.RegisterControl(Self);
end;

destructor TJDCustomControl.Destroy;
begin
  ColorManager.UnregisterControl(Self);
  inherited;
end;

procedure TJDCustomControl.WMColorChange(var Message: TMessage);
begin
  Invalidate;
  Repaint;
  inherited;
end;

{ TJDPoint }

class operator TJDPoint.Implicit(Value: TJDPoint): TPoint;
begin
  Result.X:= Round(Value.X);
  Result.Y:= Round(Value.Y);
end;

class operator TJDPoint.Implicit(Value: TPoint): TJDPoint;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

class operator TJDPoint.Implicit(Value: TJDPoint): TGPPointF;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

class operator TJDPoint.Implicit(Value: TGPPointF): TJDPoint;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

procedure TJDPoint.Move(const AmtX, AmtY: Single);
begin
  Self.X:= Self.X + AmtX;
  Self.Y:= Self.Y + AmtY;
end;

procedure TJDPoint.SetX(const Value: Single);
begin
  FX := Value;
end;

procedure TJDPoint.SetY(const Value: Single);
begin
  FY := Value;
end;

{ TJDRect }

class operator TJDRect.Implicit(Value: TRect): TJDRect;
begin
  Result.X:= Value.Left;
  Result.Y:= Value.Top;
  Result.Width:= Value.Width;
  Result.Height:= Value.Height;
end;

class operator TJDRect.Implicit(Value: TJDRect): TRect;
begin
  Result.Left:= Round(Value.X);
  Result.Top:= Round(Value.Y);
  Result.Right:= Round(Value.Right);
  Result.Bottom:= Round(Value.Bottom);
end;

class operator TJDRect.Implicit(Value: TRectF): TJDRect;
begin
  Result.FRect:= Value;
end;

class operator TJDRect.Implicit(Value: TJDRect): TRectF;
begin
  Result:= Value.FRect;
end;

class operator TJDRect.Implicit(Value: TGPRectF): TJDRect;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
  Result.Width:= Value.Width;
  Result.Height:= Value.Height;
end;

class operator TJDRect.Implicit(Value: TJDRect): TGPRectF;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
  Result.Width:= Value.Width;
  Result.Height:= Value.Height;
end;

procedure TJDRect.Inflate(const AmtX, AmtY: Single);
begin
  FRect.Inflate(AmtX, AmtY);
end;

procedure TJDRect.Move(const AmtX, AmtY: Single);
begin
  X:= X + AmtX;
  Y:= Y + AmtY;
end;

function TJDRect.GetBottom: Single;
begin
  Result:= FRect.Bottom;
end;

function TJDRect.GetHeight: Single;
begin
  Result:= FRect.Height;
end;

function TJDRect.GetRight: Single;
begin
  Result:= FRect.Right;
end;

function TJDRect.GetWidth: Single;
begin
  Result:= FRect.Width;
end;

function TJDRect.GetX: Single;
begin
  Result:= FRect.Left;
end;

function TJDRect.GetY: Single;
begin
  Result:= FRect.Top;
end;

procedure TJDRect.SetRight(const Value: Single);
begin
  FRect.Right:= Value;
end;

procedure TJDRect.SetBottom(const Value: Single);
begin
  FRect.Bottom:= Value;
end;

procedure TJDRect.SetHeight(const Value: Single);
begin
  FRect.Height := Value;
end;

function TJDRect.GetTop: Single;
begin
  Result:= Y;
end;

function TJDRect.GetLeft: Single;
begin
  Result:= X;
end;

procedure TJDRect.SetTop(const Value: Single);
begin
  Y:= Value;
end;

procedure TJDRect.SetLeft(const Value: Single);
begin
  X:= Value;
end;

procedure TJDRect.SetWidth(const Value: Single);
begin
  FRect.Width := Value;
end;

procedure TJDRect.SetX(const Value: Single);
begin
  FRect.Left := Value;
end;

procedure TJDRect.SetY(const Value: Single);
begin
  FRect.Top := Value;
end;

function TJDRect.BottomLeft: TJDPoint;
begin
  Result.X:= Self.X;
  Result.Y:= Self.Bottom;
end;

function TJDRect.BottomRight: TJDPoint;
begin
  Result.X:= Self.Right;
  Result.Y:= Self.Bottom;
end;

function TJDRect.TopLeft: TJDPoint;
begin
  Result.X:= Self.X;
  Result.Y:= Self.Y;
end;

function TJDRect.TopRight: TJDPoint;
begin
  Result.X:= Self.Right;
  Result.Y:= Self.Y;
end;

function TJDRect.Center: TJDPoint;
begin
  Result.X:= Self.X + (Self.Width / 2);
  Result.Y:= Self.Y + (Self.Height / 2);
end;

function TJDRect.ContainsPoint(const P: TJDPoint): Boolean;
begin
  Result:= (P.X >= Left) and (P.X <= Right) and
    (P.Y >= Top) and (P.Y <= Bottom);
end;

procedure TJDRect.Deflate(const AmtX, AmtY: Single);
begin
  Inflate(-AmtX, -AmtY);
end;

function TJDRect.TopCenter: TJDPoint;
begin
  Result:= Center;
  Result.Y:= Top;
end;

function TJDRect.BottomCenter: TJDPoint;
begin
  Result:= Center;
  Result.Y:= Bottom;
end;

function TJDRect.LeftCenter: TJDPoint;
begin
  Result:= Center;
  Result.X:= Left;
end;

function TJDRect.RightCenter: TJDPoint;
begin
  Result:= Center;
  Result.X:= Right;
end;

end.

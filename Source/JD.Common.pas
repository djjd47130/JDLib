unit JD.Common;

interface

{$IF CompilerVersion >= 20.0} // 20.0 corresponds to Delphi 2009
  {$DEFINE USE_GDIP}
{$IFEND}

uses
  System.Classes, System.SysUtils, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls
  {$IFDEF USE_GDIP}
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  {$ENDIF}
  ;

const
  ///  <summary>
  ///  Windows message for when style or color themes change.
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
  PJDRect = ^TJDRect;

  ///  <summary>
  ///  Defines a standardized point with floating point values at its root.
  ///  Allows for implicitly casting to and from TPoint and TGPPointF;
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
    class operator Implicit(Value: TJDPoint): TPointF;
    class operator Implicit(Value: TPointF): TJDPoint;
    {$IFDEF USE_GDIP}
    class operator Implicit(Value: TJDPoint): TGPPointF;
    class operator Implicit(Value: TGPPointF): TJDPoint;
    {$ENDIF}
    class function Create(const X, Y: Single): TJDPoint; static;
    procedure Move(const AmtX, AmtY: Single);
    function AsText(const Labels: Boolean = True; const Fmt: String = '0.###'): String;
    //function InRect(const R: TJDRect): Boolean; //TODO: How to reference TJDRect? PJDRect?
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
  end;
  TJDPoints = TArray<TJDPoint>;

  ///  <summary>
  ///  Defines a standardized rectangle with floating point values at its root.
  ///  Allows implicitly casting to and from TRect, TRectF, and TGPRect.
  ///  </summary>
  TJDRect = record
  private
    FRect: TRectF;
    FOnChange: TNotifyEvent;
    function GetBottom: Single;
    function GetRight: Single;
    procedure SetHeight(const Value: Single);
    procedure SetWidth(const Value: Single);
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
    procedure SetBottom(const Value: Single);
    procedure SetRight(const Value: Single);
    procedure SetLeft(const Value: Single);
    procedure SetTop(const Value: Single);
    function GetHeight: Single;
    function GetWidth: Single;
    function GetX: Single;
    function GetY: Single;
    function GetLeft: Single;
    function GetTop: Single;
  public
    class operator Implicit(Value: TRect): TJDRect;
    class operator Implicit(Value: TJDRect): TRect;
    class operator Implicit(Value: TRectF): TJDRect;
    class operator Implicit(Value: TJDRect): TRectF;
    {$IFDEF USE_GDIP}
    class operator Implicit(Value: TGPRectF): TJDRect;
    class operator Implicit(Value: TJDRect): TGPRectF;
    {$ENDIF}
    property X: Single read GetX write SetX;
    property Y: Single read GetY write SetY;
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;
    property Right: Single read GetRight write SetRight;
    property Bottom: Single read GetBottom write SetBottom;
    property Left: Single read GetLeft write SetLeft;
    property Top: Single read GetTop write SetTop;

    class function Create(const Left, Top, Right, Bottom: Single): TJDRect; static;
    procedure Inflate(const AmtX, AmtY: Single);
    procedure Deflate(const AmtX, AmtY: Single);
    procedure Move(const AmtX, AmtY: Single);

    //TODO: Turn these into read/write properties?
    //  No, because published records do not behave as needed.
    //  This would call for a TPersistent descendent instead,
    //  in order to respect property streaming and assigning,
    //  because "GetSomeRecord" returns a COPY, and all edits
    //  are performed on that copy, and not on the original property.
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

    procedure Invalidate;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
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



function SetThreadDescription(hThread: THandle; lpThreadDescription: WideString): HRESULT; stdcall;
  external kernel32 name 'SetThreadDescription';


///  <summary>
///  Ensures an integer falls within a given min/max range.
///  </summary>
function IntRange(const Value, Min, Max: Integer): Integer;

/// <summary>
/// Calculates an absolute pixel point based on a center point, distance (radius), and degrees.
/// TODO: There's a newer version of this somewhere along with a reverse version...
/// </summary>
//function PointAroundCircle(Center: TJDPoint; Distance: Currency; Degrees: Currency): TJDPoint;

/// <summary>
/// Translates TAlignment enum into WinAPI DT_ representation.
/// </summary>
function JDAlignmentToFlags(const AValue: TAlignment): Cardinal;



/// <summary>
/// Creates a TJDPoint based on X/Y coordinates.
/// </summary>
function JDPoint(const X, Y: Single): TJDPoint; overload;
/// <summary>
/// Creates a TJDPoint based on X/Y coordinates.
/// </summary>
function JDPoint(const X, Y: Integer): TJDPoint; overload;

/// <summary>
/// Creates a TJDRect based on edge coordinates.
/// </summary>
function JDRect(const Left, Top, Right, Bottom: Single): TJDRect; overload;
/// <summary>
/// Creates a TJDRect based on edge coordinates.
/// </summary>
function JDRect(const Left, Top, Right, Bottom: Integer): TJDRect; overload;
/// <summary>
/// Creates a TJDRect based on Top-Left and Bottom-Right points.
/// </summary>
function JDRect(const TopLeft, BottomRight: TJDPoint): TJDRect; overload;
/// <summary>
/// Creates a TJDRect based on dimensions and center position.
/// </summary>
function JDRect(const Width, Height: Single; const Center: TJDPoint): TJDRect; overload;
/// <summary>
/// Creates a TJDRect based on dimensions and center position.
/// </summary>
function JDRect(const Width, Height: Integer; const Center: TJDPoint): TJDRect; overload;

function PosOf(const AValue: Integer): Integer; overload;
function NegOf(const AValue: Integer): Integer; overload;
function PosOf(const AValue: Currency): Currency; overload;
function NegOf(const AValue: Currency): Currency; overload;

implementation

uses
  JD.Graphics;

function IntRange(const Value, Min, Max: Integer): Integer;
begin
  Result:= Value;
  if Result < Min then Result:= Min;
  if Result > Max then Result:= Max;
end;

{
function PointAroundCircle(Center: TJDPoint; Distance: Currency; Degrees: Currency): TJDPoint;
var
  Radians: Real;
begin
  //TODO: Change input from "Degrees" to "Radians" to eliminate the need for
  //  a variable, this reducing heap allocation and increasing performance.

  //Convert angle from degrees to radians; Subtract 135 to bring position to 0 Degrees
  Radians:= (Degrees - 135) * Pi / 180;
  Result.X:= Distance*Cos(Radians)-Distance*Sin(Radians)+Center.X;
  Result.Y:= Distance*Sin(Radians)+Distance*Cos(Radians)+Center.Y;
end;
}

function JDAlignmentToFlags(const AValue: TAlignment): Cardinal;
begin
  case AValue of
    taLeftJustify:  Result:= DT_LEFT;
    taRightJustify: Result:= DT_RIGHT;
    taCenter:       Result:= DT_CENTER;
    else            Result:= DT_LEFT;
  end;
end;

function JDPoint(const X, Y: Single): TJDPoint;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

function JDPoint(const X, Y: Integer): TJDPoint;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

function JDRect(const Left, Top, Right, Bottom: Single): TJDRect;
begin
  Result.Left:= Left;
  Result.Top:= Top;
  Result.Right:= Right;
  Result.Bottom:= Bottom;
end;

function JDRect(const Left, Top, Right, Bottom: Integer): TJDRect;
begin
  Result.Left:= Left;
  Result.Top:= Top;
  Result.Right:= Right;
  Result.Bottom:= Bottom;
end;

function JDRect(const TopLeft, BottomRight: TJDPoint): TJDRect;
begin
  Result.Left:= TopLeft.X;
  Result.Top:= TopLeft.Y;
  Result.Right:= BottomRight.X;
  Result.Bottom:= BottomRight.Y;
end;

function JDRect(const Width, Height: Single; const Center: TJDPoint): TJDRect;
var
  OX, OY: Single;
begin
  OX:= (Width - Center.X);
  OY:= (Height - Center.Y);
  Result.Left:= OX;
  Result.Top:= OY;
  Result.Right:= OX + Width;
  Result.Bottom:= OY + Height;
end;

function JDRect(const Width, Height: Integer; const Center: TJDPoint): TJDRect;
var
  OX, OY: Single;
begin
  OX:= (Width - Center.X);
  OY:= (Height - Center.Y);
  Result.Left:= OX;
  Result.Top:= OY;
  Result.Right:= OX + Width;
  Result.Bottom:= OY + Height;
end;

function PosOf(const AValue: Integer): Integer;
begin
  Result:= AValue;
  if Result < 0 then
    Result:= -Result;
end;

function NegOf(const AValue: Integer): Integer;
begin
  Result:= AValue;
  if Result > 0 then
    Result:= -Result;
end;

function PosOf(const AValue: Currency): Currency;
begin
  Result:= AValue;
  if Result < 0 then
    Result:= -Result;
end;

function NegOf(const AValue: Currency): Currency;
begin
  Result:= AValue;
  if Result > 0 then
    Result:= -Result;
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

class function TJDPoint.Create(const X, Y: Single): TJDPoint;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

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

class operator TJDPoint.Implicit(Value: TPointF): TJDPoint;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

class operator TJDPoint.Implicit(Value: TJDPoint): TPointF;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

class operator TJDPoint.Implicit(Value: TJDPoint): TGPPointF;
begin
  Result.X:= Value.X;
  Result.Y:= Value.Y;
end;

function TJDPoint.AsText(const Labels: Boolean = True; const Fmt: String = '0.###'): String;
begin
  var SX:= FormatFloat(Fmt, X);
  var SY:= FormatFloat(Fmt, Y);
  if Labels then begin
    Result:= 'X: '+SX + ', Y: ' + SY;
  end else begin
    Result:= SX + ', ' + SY;
  end;
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

{$IFDEF USE_GDIP}
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
{$ENDIF}

procedure TJDRect.Inflate(const AmtX, AmtY: Single);
begin
  FRect.Inflate(AmtX, AmtY);
  Invalidate;
end;

procedure TJDRect.Invalidate;
begin
  //if Assigned(FOnChange) then
    //FOnChange(nil);
end;

procedure TJDRect.Move(const AmtX, AmtY: Single);
begin
  X:= X + AmtX;
  Y:= Y + AmtY;
  Invalidate;
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
  Invalidate;
end;

procedure TJDRect.SetBottom(const Value: Single);
begin
  FRect.Bottom:= Value;
  Invalidate;
end;

procedure TJDRect.SetHeight(const Value: Single);
begin
  FRect.Height := Value;
  Invalidate;
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
  Invalidate;
end;

procedure TJDRect.SetLeft(const Value: Single);
begin
  X:= Value;
  Invalidate;
end;

procedure TJDRect.SetWidth(const Value: Single);
begin
  FRect.Width := Value;
  Invalidate;
end;

procedure TJDRect.SetX(const Value: Single);
begin
  FRect.Left := Value;
  Invalidate;
end;

procedure TJDRect.SetY(const Value: Single);
begin
  FRect.Top := Value;
  Invalidate;
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

class function TJDRect.Create(const Left, Top, Right, Bottom: Single): TJDRect;
begin
  Result.Left:= Left;
  Result.Top:= Top;
  Result.Right:= Right;
  Result.Bottom:= Bottom;
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

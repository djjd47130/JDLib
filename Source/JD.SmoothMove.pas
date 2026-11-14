unit JD.SmoothMove;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls,
  JD.Common;

type
  ///  <summary>
  ///  Defines the effect of the animation.
  ///  </summary>
  TJDSmoothMoveEffect = (seNone, seNormal, seSmooth);

  ///  <summary>
  ///  Event triggered upon value changes depending on effect type.
  ///  </summary>
  TJDSmoothMoveEvent = procedure(Sender: TObject; const Position: Double) of object;

const
  SM_DEF_DELAY = 15;
  SM_DEF_VALUE = 100.0;
  SM_DEF_STEP = 15.0;
  SM_DEF_EFFECT = seNormal;
  SM_DEF_ENABLED = True;

type
  TJDSmoothMoveThread = class;
  TJDSmoothMove = class;

  ///  <summary>
  ///  Dedicated thread for the TJDSmoothMove component.
  ///  </summary>
  TJDSmoothMoveThread = class(TThread)
  private
    FDelay: Integer;
    FOnValue: TNotifyEvent;
    // FIX (review §3.33): back-reference to the component that owns this
    // thread, so Execute can check whether anything is actually animating
    // (FInvalidated) before waking the main thread with Synchronize.
    FSmoothMove: TJDSmoothMove;
    procedure SetDelay(const Value: Integer);
    procedure DoOnValue;
  protected
    procedure Execute; override;
  public
    constructor Create(ASmoothMove: TJDSmoothMove); reintroduce;
    destructor Destroy; override;
  public
    property Delay: Integer read FDelay write SetDelay;
  public
    property OnValue: TNotifyEvent read FOnValue write FOnValue;
  end;

  ///  <summary>
  ///  Designed for animation of values to provide a sliding effect of UI controls.
  ///  Can be used for other purposes. Used as a VCL alternative for the
  ///  Float Animations as found in the Firemonkey framework.
  ///  </summary>
  ///  <remarks>
  ///  This component is event driven. Be sure to assign a handler for the
  ///  OnValue event. This will be triggered for every change of the value.
  ///  Use this handler to update the position or otherwise value of whatever
  ///  this component is supposed to control.
  ///  </remarks>
  TJDSmoothMove = class(TComponent)
  private
    FThread: TJDSmoothMoveThread;
    // FIX (review §3.33): the Delay value kept here on the component as
    // well as on the thread. At design time there is no thread (see
    // Create), so the Object Inspector still needs somewhere to read and
    // write Delay. At run time the thread holds the live copy.
    FDelay: Integer;
    FInvalidated: Boolean;
    FEnabled: Boolean;
    FValue: Double;
    FPosition: Double;
    FOnValue: TJDSmoothMoveEvent;
    FStep: Double;
    FEffect: TJDSmoothMoveEffect;
    procedure TimerExec(Sender: TObject);
    procedure SetValue(const Value: Double);
    function GetDelay: Integer;
    procedure SetDelay(const Value: Integer);
    procedure SetStep(const Value: Double);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetEffect(const Value: TJDSmoothMoveEffect);
  protected
    procedure DoOnValue; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public

    ///<summary>
    ///  Returns the current position.
    ///</summary>
    property Position: Double read FPosition;

    ///<summary>
    ///  Forcefully sets the current position to the desired value.
    ///</summary>
    procedure Reset;

  published

    ///<summary>
    ///  Controls the amount of time between each modification of the position.
    ///</summary>
    property Delay: Integer read GetDelay write SetDelay default SM_DEF_DELAY;

    ///<summary>
    ///  Controls the type of animation effect.
    ///</summary>
    property Effect: TJDSmoothMoveEffect read FEffect write SetEffect default SM_DEF_EFFECT;

    ///<summary>
    ///  Controls whether to enable the animation.
    ///</summary>
    property Enabled: Boolean read GetEnabled write SetEnabled default SM_DEF_ENABLED;

    ///<summary>
    ///  Controls how much to modify the position on each modification.
    ///</summary>
    property Step: Double read FStep write SetStep;

    ///<summary>
    ///  Specifies the desired target value.
    ///</summary>
    property Value: Double read FValue write SetValue;

  published

    ///<summary>
    ///  Triggered upon each modification of the current position.
    ///</summary>
    property OnValue: TJDSmoothMoveEvent read FOnValue write FOnValue;

  end;

implementation

{ TSmoothMoveThread }

constructor TJDSmoothMoveThread.Create(ASmoothMove: TJDSmoothMove);
begin
  inherited Create(False);
  FSmoothMove:= ASmoothMove;
  FDelay:= 100;
end;

destructor TJDSmoothMoveThread.Destroy;
begin

  inherited;
end;

procedure TJDSmoothMoveThread.DoOnValue;
begin
  if Assigned(FOnValue) then
    FOnValue(Self);
end;

procedure TJDSmoothMoveThread.Execute;
var
  HasWork: Boolean;
begin
  while not Terminated do begin
    // FIX (review §3.33): check first whether anything is animating, and
    // only then wake the main thread. Before this, the thread called
    // Synchronize every 15 ms forever, even when idle - the "nothing to
    // do" check only happened afterwards, on the main thread side, inside
    // TimerExec. Now an idle thread just sleeps 100 ms and looks again.
    // FInvalidated/FEnabled live on the component (same unit, so this
    // thread can read its private fields). A Boolean read is atomic, so
    // the worst case is starting an animation one 100 ms tick late.
    // (The nil check is kept separate on purpose so this stays safe even
    // if boolean short-circuit evaluation is ever switched off.) If the
    // component reference is ever nil, fall back to always syncing.
    HasWork:= (FSmoothMove = nil);
    if not HasWork then
      HasWork:= FSmoothMove.FInvalidated and FSmoothMove.FEnabled;
    if HasWork then begin
      try
        Synchronize(DoOnValue);
      finally
        Sleep(FDelay);
      end;
    end else begin
      Sleep(100);
    end;
  end;
end;

procedure TJDSmoothMoveThread.SetDelay(const Value: Integer);
begin
  if Value < 1 then
    FDelay:= 1
  else
    FDelay := Value;
end;

{ TJDSmoothMove }

constructor TJDSmoothMove.Create(AOwner: TComponent);
begin
  inherited;
  FDelay:= SM_DEF_DELAY;
  FStep:= SM_DEF_STEP;
  FValue:= SM_DEF_VALUE;
  FPosition:= SM_DEF_VALUE;
  FEffect:= SM_DEF_EFFECT;
  FEnabled:= SM_DEF_ENABLED;
  FInvalidated:= True;
  // FIX (review §3.33): do not create/start the animation thread at design
  // time - it would run inside the Delphi IDE. Note the Owner check:
  // csDesigning is not always set on the component itself yet while its
  // constructor runs, but the Owner (the form) already has it. With no
  // thread, GetDelay/SetDelay below use the FDelay field, and the
  // destructor skips the thread shutdown.
  if not (csDesigning in ComponentState) and
    not ((AOwner <> nil) and (csDesigning in AOwner.ComponentState)) then
  begin
    FThread:= TJDSmoothMoveThread.Create(Self);
    FThread.OnValue:= TimerExec;
    FThread.Delay:= FDelay;
  end;
end;

destructor TJDSmoothMove.Destroy;
begin
  // NOTE (review §3.33): Terminate + WaitFor has a small known deadlock
  // window - if the worker happens to be inside Synchronize at the exact
  // moment the main thread enters WaitFor, each waits for the other. In
  // practice the window is tiny, so this is accepted as-is rather than
  // restructured. No thread exists at design time, so guard against nil.
  if Assigned(FThread) then begin
    FThread.Terminate;
    FThread.WaitFor;
    FThread.Free;
  end;
  inherited;
end;

procedure TJDSmoothMove.DoOnValue;
begin
  if Assigned(FOnValue) then
    FOnValue(Self, FPosition);
end;

function TJDSmoothMove.GetDelay: Integer;
begin
  // FIX (review §3.33): no thread exists at design time, so read the
  // component's own copy of the value instead of dereferencing nil.
  if not Assigned(FThread) then begin
    Result:= FDelay;
    Exit;
  end;
  Result:= FThread.Delay;
end;

function TJDSmoothMove.GetEnabled: Boolean;
begin
  Result:= FEnabled;
end;

procedure TJDSmoothMove.Reset;
begin
  FPosition:= FValue;
  FInvalidated:= False;
  DoOnValue;
end;

procedure TJDSmoothMove.SetDelay(const Value: Integer);
begin
  // FIX (review §3.33): keep the component's own copy in step (it is the
  // only copy at design time), clamped to >= 1 like the thread's setter,
  // then push it to the thread if there is one.
  if Value < 1 then
    FDelay:= 1
  else
    FDelay:= Value;
  if Assigned(FThread) then
    FThread.Delay:= FDelay;
  FInvalidated:= True;
end;

procedure TJDSmoothMove.SetEffect(const Value: TJDSmoothMoveEffect);
begin
  FEffect := Value;
end;

procedure TJDSmoothMove.SetEnabled(const Value: Boolean);
begin
  FEnabled:= Value;
  FInvalidated:= True;
end;

procedure TJDSmoothMove.SetStep(const Value: Double);
begin
  // FIX (review §3.33): Step is a Double, and 0 (or a negative value) means
  // the position can never reach its target, so FInvalidated stays True
  // and OnValue fires every tick forever. Clamp bad values to a small
  // positive step instead of accepting them.
  if Value <= 0 then
    FStep:= 0.01
  else
    FStep:= Value;
  FInvalidated:= True;
end;

procedure TJDSmoothMove.SetValue(const Value: Double);
begin
  FValue := Value;
  FInvalidated:= True;
end;

procedure TJDSmoothMove.TimerExec(Sender: TObject);
var
  TempStep: Double;
  Dist: Double;
begin
  if not FEnabled then Exit;

  if FInvalidated then begin

    case FEffect of
      seNone: begin
        //No animation, just change value
        FPosition:= FValue;
        FInvalidated:= False;
      end;
      seNormal: begin
        //Evenly increase/decrease value
        if (FPosition >= FValue - FStep) and (FPosition <= FValue + FStep) then begin
          FPosition:= FValue;
          FInvalidated:= False;
        end;
        if FPosition > Value then begin
          FPosition:= FPosition - FStep;
        end else
        if FPosition < Value then begin
          FPosition:= FPosition + FStep;
        end;
      end;
      seSmooth: begin
        //Slow down and snap into place

        //TODO: Modify calculation to be more efficient and smooth

        if FPosition > FValue then
          Dist:= FPosition - FValue
        else
          Dist:= FValue - FPosition;

        if Dist < (FStep * 2) then begin
          TempStep:= FStep / 6;
        end else
        if Dist < (FStep * 4) then begin
          TempStep:= FStep / 4;
        end else
        if Dist < (FStep * 6) then begin
          TempStep:= FStep / 2;
        end else begin
          TempStep:= FStep;
        end;

        if (FPosition >= FValue - TempStep) and (FPosition <= FValue + TempStep) then begin
          FPosition:= FValue;
          FInvalidated:= False;
        end;
        if FPosition > Value then begin
          FPosition:= FPosition - TempStep;
        end else
        if FPosition < Value then begin
          FPosition:= FPosition + TempStep;
        end;

      end;
    end;

    DoOnValue;
  end;
end;

end.

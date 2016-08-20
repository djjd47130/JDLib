unit JD.SmoothMove;

(*
  JD Smooth Move Component (TSmoothMove)

  Designed for animation of values to provide a sliding effect of UI controls.
  Can be used for other purposes. Used as a VCL alternative for the
  Float Animations as found in the Firemonkey framework.

  This component is event driven. Be sure to assign a handler for the
  OnValue event. This will be triggered for every change of the value.
  Use this handler to update the position or otherwise value of whatever
  this component is supposed to control.
*)

interface

uses
  System.SysUtils, System.Classes;

type
  TSmoothMoveEffect = (seNone, seNormal, seSmooth);

  TSmoothMoveEvent = procedure(Sender: TObject; const Position: Double) of object;

const
  SM_DEF_DELAY = 15;
  SM_DEF_VALUE = 100.0;
  SM_DEF_STEP = 15.0;
  SM_DEF_EFFECT = seNormal;
  SM_DEF_ENABLED = True;

type
  TSmoothMoveThread = class;
  TSmoothMove = class;

  TSmoothMoveThread = class(TThread)
  private
    FDelay: Integer;
    FOnValue: TNotifyEvent;
    procedure SetDelay(const Value: Integer);
    procedure DoOnValue;
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  public
    property Delay: Integer read FDelay write SetDelay;
  public
    property OnValue: TNotifyEvent read FOnValue write FOnValue;
  end;

  TSmoothMove = class(TComponent)
  private
    FThread: TSmoothMoveThread;
    FInvalidated: Boolean;
    FEnabled: Boolean;
    FValue: Double;
    FPosition: Double;
    FOnValue: TSmoothMoveEvent;
    FStep: Double;
    FEffect: TSmoothMoveEffect;
    procedure TimerExec(Sender: TObject);
    procedure SetValue(const Value: Double);
    function GetDelay: Integer;
    procedure SetDelay(const Value: Integer);
    procedure SetStep(const Value: Double);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetEffect(const Value: TSmoothMoveEffect);
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
    property Effect: TSmoothMoveEffect read FEffect write SetEffect default SM_DEF_EFFECT;

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
    property OnValue: TSmoothMoveEvent read FOnValue write FOnValue;

  end;

implementation

{ TSmoothMoveThread }

constructor TSmoothMoveThread.Create;
begin
  inherited Create(False);
  FDelay:= 100;
end;

destructor TSmoothMoveThread.Destroy;
begin

  inherited;
end;

procedure TSmoothMoveThread.DoOnValue;
begin
  if Assigned(FOnValue) then
    FOnValue(Self);
end;

procedure TSmoothMoveThread.Execute;
begin
  while not Terminated do begin
    try
      Synchronize(DoOnValue);
    finally
      Sleep(FDelay);
    end;
  end;
end;

procedure TSmoothMoveThread.SetDelay(const Value: Integer);
begin
  if Value < 1 then
    FDelay:= 1
  else
    FDelay := Value;
end;

{ TSmoothMove }

constructor TSmoothMove.Create(AOwner: TComponent);
begin
  inherited;
  FThread:= TSmoothMoveThread.Create;
  FThread.OnValue:= TimerExec;
  FThread.Delay:= SM_DEF_DELAY;
  FStep:= SM_DEF_STEP;
  FValue:= SM_DEF_VALUE;
  FPosition:= SM_DEF_VALUE;
  FEffect:= SM_DEF_EFFECT;
  FEnabled:= SM_DEF_ENABLED;
  FInvalidated:= True;
end;

destructor TSmoothMove.Destroy;
begin
  FThread.Terminate;
  FThread.WaitFor;
  FThread.Free;
  inherited;
end;

procedure TSmoothMove.DoOnValue;
begin
  if Assigned(FOnValue) then
    FOnValue(Self, FPosition);
end;

function TSmoothMove.GetDelay: Integer;
begin
  Result:= FThread.Delay;
end;

function TSmoothMove.GetEnabled: Boolean;
begin
  Result:= FEnabled;
end;

procedure TSmoothMove.Reset;
begin
  FPosition:= FValue;
  FInvalidated:= False;
  DoOnValue;
end;

procedure TSmoothMove.SetDelay(const Value: Integer);
begin
  FThread.Delay:= Value;
  FInvalidated:= True;
end;

procedure TSmoothMove.SetEffect(const Value: TSmoothMoveEffect);
begin
  FEffect := Value;
end;

procedure TSmoothMove.SetEnabled(const Value: Boolean);
begin
  FEnabled:= Value;
  FInvalidated:= True;
end;

procedure TSmoothMove.SetStep(const Value: Double);
begin
  FStep := Value;
  FInvalidated:= True;
end;

procedure TSmoothMove.SetValue(const Value: Double);
begin
  FValue := Value;
  FInvalidated:= True;
end;

procedure TSmoothMove.TimerExec(Sender: TObject);
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

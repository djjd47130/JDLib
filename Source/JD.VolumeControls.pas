unit JD.VolumeControls;

//Source: https://stackoverflow.com/q/66630233/988445
//WinAPI Docs: https://learn.microsoft.com/en-us/windows/win32/api/endpointvolume/nf-endpointvolume-iaudioendpointvolume-setmastervolumelevel

//TODO: Change to support all platforms...

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  ActiveX, ComObj,
  JD.Common,
  Winapi.MMSystem;

const
  CLASS_IMMDeviceEnumerator : TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  IID_IMMDeviceEnumerator : TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
  IID_IAudioEndpointVolume : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';

  WM_VOLNOTIFY = WM_USER + 1;


type

  { WinAPI Wrapper}

  PAUDIO_VOLUME_NOTIFICATION_DATA = ^AUDIO_VOLUME_NOTIFICATION_DATA;
  AUDIO_VOLUME_NOTIFICATION_DATA = record
    guidEventContext: TGUID;
    bMuted: BOOL;
    fMasterVolume: Single;
    nChannels: UINT;
    afChannelVolumes: Single;
  end;

  IAudioEndpointVolumeCallback = interface(IUnknown)
    ['{657804FA-D6AD-4496-8A60-352752AF4F89}']
    function OnNotify(pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT; stdcall;
  end;

  IAudioEndpointVolume = interface(IUnknown)
    ['{5CDF2C82-841E-4546-9722-0CF74078229A}']
    function RegisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): HRESULT; stdcall;
    function UnregisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): HRESULT; stdcall;
    function GetChannelCount(out PInteger): HRESULT; stdcall;
    function SetMasterVolumeLevel(fLevelDB: single; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetMasterVolumeLevelScalar(fLevelDB: single; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMasterVolumeLevel(out fLevelDB: single): HRESULT; stdcall;
    function GetMasterVolumeLevelScaler(out fLevelDB: single): HRESULT; stdcall;
    function SetChannelVolumeLevel(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetChannelVolumeLevelScalar(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetChannelVolumeLevel(nChannel: Integer; out fLevelDB: double): HRESULT; stdcall;
    function GetChannelVolumeLevelScalar(nChannel: Integer; out fLevel: double): HRESULT; stdcall;
    function SetMute(bMute: Boolean; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMute(out bMute: Boolean): HRESULT; stdcall;
    function GetVolumeStepInfo(pnStep: Integer; out pnStepCount: Integer): HRESULT; stdcall;
    function VolumeStepUp(pguidEventContext: PGUID): HRESULT; stdcall;
    function VolumeStepDown(pguidEventContext: PGUID): HRESULT; stdcall;
    function QueryHardwareSupport(out pdwHardwareSupportMask): HRESULT; stdcall;
    function GetVolumeRange(out pflVolumeMindB: double; out pflVolumeMaxdB: double; out pflVolumeIncrementdB: double): HRESULT; stdcall;
  end;

  IAudioMeterInformation = interface(IUnknown)
  ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
  end;

  IPropertyStore = interface(IUnknown)
  end;

  IMMDevice = interface(IUnknown)
  ['{D666063F-1587-4E43-81F1-B948E807363F}']
    function Activate(const refId: TGUID; dwClsCtx: DWORD;  pActivationParams: PInteger; out pEndpointVolume: IAudioEndpointVolume): HRESULT; stdCall;
    function OpenPropertyStore(stgmAccess: DWORD; out ppProperties: IPropertyStore): HRESULT; stdcall;
    function GetId(out ppstrId: PLPWSTR): HRESULT; stdcall;
    function GetState(out State: Integer): HRESULT; stdcall;
  end;

  IMMDeviceCollection = interface(IUnknown)
  ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
  end;

  IMMNotificationClient = interface(IUnknown)
  ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
  end;

  IMMDeviceEnumerator = interface(IUnknown)
  ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(dataFlow: TOleEnum; deviceState: SYSUINT; DevCollection: IMMDeviceCollection): HRESULT; stdcall;
    function GetDefaultAudioEndpoint(EDF: SYSUINT; ER: SYSUINT; out Dev :IMMDevice ): HRESULT; stdcall;
    function GetDevice(pwstrId: pointer; out Dev: IMMDevice): HRESULT; stdcall;
    function RegisterEndpointNotificationCallback(pClient: IMMNotificationClient): HRESULT; stdcall;
  end;


  { Custom Component }

  ///  <summary>
  ///  Monitors and controls the system's master volume level and mute state.
  ///  </summary>
  TJDVolumeControls = class;

  TJDVolumeEvent = procedure(Sender: TObject; const Volume: Integer) of object;

  TJDMuteEvent = procedure(Sender: TObject; const Muted: Boolean) of object;

  TJDVolumeControls = class(TJDMessageComponent, IAudioEndpointVolumeCallback)
  private
    FDeviceEnumerator: IMMDeviceEnumerator;
    FMMDevice: IMMDevice;
    FAudioEndpointVolume: IAudioEndpointVolume;
    FLastVolume: Integer;
    FLastMute: Boolean;
    FOnMuteChanged: TJDMuteEvent;
    FOnVolumeChanged: TJDVolumeEvent;
    function OnNotify(pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT;
      stdcall;
    procedure SetMute(const Value: Boolean);
    procedure SetVolume(const Value: Integer);
  protected
    procedure WMVolNotify(var Msg: TMessage); message WM_VOLNOTIFY;
    procedure WndMethod(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    ///  <summary>
    ///  Increases the system volume.
    ///  </summary>
    procedure VolUp;
    ///  <summary>
    ///  Decreases the system volume.
    ///  </summary>
    procedure VolDown;
  published
    ///  <summary>
    ///  Reads and write the system volume.
    ///  </summary>
    property Volume: Integer read FLastVolume write SetVolume;
    ///  <summary>
    ///  Reads and writes the system mute state.
    ///  </summary>
    property Muted: Boolean read FLastMute write SetMute;
    ///  <summary>
    ///  Triggered when the system volume changes.
    ///  </summary>
    property OnVolumeChanged: TJDVolumeEvent read FOnVolumeChanged write FOnVolumeChanged;
    ///  <summary>
    ///  Triggered when the system mute state changes.
    ///  </summary>
    property OnMuteChanged: TJDMuteEvent read FOnMuteChanged write FOnMuteChanged;
  end;

implementation

{ TJDVolumeControls }

constructor TJDVolumeControls.Create(AOwner: TComponent);
var
  sVal: Single;
  bVal: Boolean;
begin
  inherited;
  if not Succeeded(CoInitialize(nil)) then
    ExitProcess(1); //TODO: But why?

  OleCheck(CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER,
    IID_IMMDeviceEnumerator, FDeviceEnumerator));
  OleCheck(FDeviceEnumerator.GetDefaultAudioEndpoint(0, 0, FMMDevice));
  OleCheck(FMMDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, FAudioEndpointVolume));
  OleCheck(FAudioEndpointVolume.RegisterControlChangeNotify(Self));

  if FAudioEndpointVolume.GetMasterVolumeLevelScaler(sVal) = S_OK then begin
    FLastVolume:= Round(sVal * 100);
  end;

  if FAudioEndpointVolume.GetMute(bVal) = S_OK then begin
    FLastMute:= bVal;
  end;
end;

destructor TJDVolumeControls.Destroy;
begin
  CoUninitialize;
  inherited;
end;

function TJDVolumeControls.OnNotify(
  pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT;
begin
  if pNotify = nil then
    Exit(E_POINTER);
  try
    PostMessage(Handle, WM_VOLNOTIFY, WPARAM(pNotify.bMuted <> False), LPARAM(Round(100 * pNotify.fMasterVolume)));
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

procedure TJDVolumeControls.SetMute(const Value: Boolean);
var
  bVal: BOOL;
begin
  if (csLoading in ComponentState) then
    Exit;
  bVal:= Value;
  if FAudioEndpointVolume.SetMute(bVal, nil) = S_OK then begin
    FLastMute := Value;
    if Assigned(FOnMuteChanged) then
      FOnMuteChanged(Self, Value);
  end;
end;

procedure TJDVolumeControls.SetVolume(const Value: Integer);
var
  sVal: Single;
begin
  if (csLoading in ComponentState) then
    Exit;
  if Muted then
    Muted:= False;
  sVal:= Value / 100;
  if FAudioEndpointVolume.SetMasterVolumeLevelScalar(sVal, nil) = S_OK then begin
    FLastVolume := Value;
    if Assigned(FOnVolumeChanged) then
      FOnVolumeChanged(Self, Value);
  end;
end;

procedure TJDVolumeControls.VolDown;
begin
  Volume:= Volume - 2;
end;

procedure TJDVolumeControls.VolUp;
begin
  Volume:= Volume + 2;
end;

procedure TJDVolumeControls.WMVolNotify(var Msg: TMessage);
begin
  var LMute := Msg.WParam <> 0;
  var LVolume := Msg.LParam;

  if LVolume <> FLastVolume then begin
    FLastVolume:= LVolume;
    if Assigned(FOnVolumeChanged) then
      FOnVolumeChanged(Self, LVolume);
  end;

  if LMute <> FLastMute then begin
    FLastMute:= LMute;
    if Assigned(FOnMuteChanged) then
      FOnMuteChanged(Self, LMute);
  end;

end;

procedure TJDVolumeControls.WndMethod(var Message: TMessage);
begin
  if Message.Msg = WM_VOLNOTIFY then begin
    WMVolNotify(Message);
  end else
    inherited;
end;

end.

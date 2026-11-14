unit JD.VolumeControls;

//Source: https://stackoverflow.com/q/66630233/988445
//WinAPI Docs: https://learn.microsoft.com/en-us/windows/win32/api/endpointvolume/nf-endpointvolume-iaudioendpointvolume-setmastervolumelevel

//TODO: Change to support all platforms...

//Multi-device fix (Nov 2026):
//  The original version of this component called GetDefaultAudioEndpoint
//  ONCE in the constructor and then only ever talked to that one device.
//  If Windows switched the default output (plug in headphones, switch to
//  a Bluetooth speaker, change the default in Sound settings), the
//  component kept enforcing the OLD device and the new one ran free.
//  This version enumerates ALL active render endpoints, follows the
//  default device when it changes, and can clamp the volume on every
//  device you select - all of them, just the default, or a picked list.
//  The original Volume / Muted / OnVolumeChanged API is unchanged and
//  still reflects the (current) default device, so existing apps keep
//  working exactly as before.
//  The Core Audio interface declarations below were also fixed to match
//  the real Windows API: IMMDeviceCollection was empty, EnumAudioEndpoints
//  could not return a collection, and IPropertyStore had no methods at
//  all, which is why enumerating devices was impossible before.

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

  // EDataFlow values - which direction the audio flows
  TMD_DATAFLOW_RENDER = 0;    // Speakers / headphones - audio flows OUT to a device
  TMD_DATAFLOW_CAPTURE = 1;   // Microphone - audio flows IN from a device
  TMD_DATAFLOW_ALL = 2;

  // ERole values - what the default device is used for
  TMD_ROLE_CONSOLE = 0;       // Games, system sounds - the normal "default device"
  TMD_ROLE_MULTIMEDIA = 1;    // Music, movies
  TMD_ROLE_COMMUNICATIONS = 2;// Voice calls

  // DEVICE_STATE values - which devices EnumAudioEndpoints returns
  TMD_DEVICE_STATE_ACTIVE = $00000001;   // Plugged in and ready - the only ones we care about
  TMD_DEVICE_STATE_DISABLED = $00000002;
  TMD_DEVICE_STATE_NOTPRESENT = $00000004;
  TMD_DEVICE_STATE_UNPLUGGED = $00000008;

  // IPropertyStore access mode
  TMD_STGM_READ = $00000000;

  // PROPVARIANT type for a null-terminated wide string
  TMD_VT_LPWSTR = 31;

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
    function GetChannelCount(out pnChannelCount: UINT): HRESULT; stdcall;
    function SetMasterVolumeLevel(fLevelDB: Single; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetMasterVolumeLevelScalar(fLevel: Single; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMasterVolumeLevel(out fLevelDB: Single): HRESULT; stdcall;
    function GetMasterVolumeLevelScalar(out fLevel: Single): HRESULT; stdcall;
    function SetChannelVolumeLevel(nChannel: UINT; fLevelDB: Single; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetChannelVolumeLevelScalar(nChannel: UINT; fLevel: Single; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetChannelVolumeLevel(nChannel: UINT; out fLevelDB: Single): HRESULT; stdcall;
    function GetChannelVolumeLevelScalar(nChannel: UINT; out fLevel: Single): HRESULT; stdcall;
    function SetMute(bMute: BOOL; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMute(out bMute: BOOL): HRESULT; stdcall;
    function GetVolumeStepInfo(out pnStep: UINT; out pnStepCount: UINT): HRESULT; stdcall;
    function VolumeStepUp(pguidEventContext: PGUID): HRESULT; stdcall;
    function VolumeStepDown(pguidEventContext: PGUID): HRESULT; stdcall;
    function QueryHardwareSupport(out pdwHardwareSupportMask: DWORD): HRESULT; stdcall;
    function GetVolumeRange(out pflVolumeMindB: Single; out pflVolumeMaxdB: Single; out pflVolumeIncrementdB: Single): HRESULT; stdcall;
  end;

  IAudioMeterInformation = interface(IUnknown)
  ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
  end;

  // PROPERTYKEY identifies one property in a device's property store
  // (for example the friendly name shown in Windows Sound settings).
  TJDPropertyKey = record
    fmtid: TGUID;
    pid: DWORD;
  end;

  // Minimal PROPVARIANT - just enough to read a string value out of a
  // property store. The real PROPVARIANT is a 16-byte union; the string
  // pointer lives at offset 8 when vt = VT_LPWSTR.
  TJDPropVariant = record
    vt: Word;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      0: (pwszVal: PWideChar);
      1: (ullVal: UInt64);
  end;

  IPropertyStore = interface(IUnknown)
    ['{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}']
    function GetCount(out cProps: DWORD): HRESULT; stdcall;
    function GetAt(iProp: DWORD; out pkey: TJDPropertyKey): HRESULT; stdcall;
    function GetValue(const key: TJDPropertyKey; out pv: TJDPropVariant): HRESULT; stdcall;
    function SetValue(const key: TJDPropertyKey; const propvar: TJDPropVariant): HRESULT; stdcall;
    function Commit: HRESULT; stdcall;
  end;

  IMMDevice = interface(IUnknown)
  ['{D666063F-1587-4E43-81F1-B948E807363F}']
    function Activate(const refId: TGUID; dwClsCtx: DWORD;  pActivationParams: PInteger; out pEndpointVolume: IAudioEndpointVolume): HRESULT; stdCall;
    function OpenPropertyStore(stgmAccess: DWORD; out ppProperties: IPropertyStore): HRESULT; stdcall;
    function GetId(out ppstrId: PLPWSTR): HRESULT; stdcall;
    function GetState(out State: DWORD): HRESULT; stdcall;
  end;

  IMMDeviceCollection = interface(IUnknown)
  ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
    function GetCount(out pcDevices: UINT): HRESULT; stdcall;
    function Item(nDevice: UINT; out ppDevice: IMMDevice): HRESULT; stdcall;
  end;

  IMMNotificationClient = interface(IUnknown)
  ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
  end;

  IMMDeviceEnumerator = interface(IUnknown)
  ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(dataFlow: Integer; deviceState: DWORD; out DevCollection: IMMDeviceCollection): HRESULT; stdcall;
    function GetDefaultAudioEndpoint(EDF: Integer; ER: Integer; out Dev :IMMDevice ): HRESULT; stdcall;
    function GetDevice(pwstrId: PWideChar; out Dev: IMMDevice): HRESULT; stdcall;
    function RegisterEndpointNotificationCallback(pClient: IMMNotificationClient): HRESULT; stdcall;
    function UnregisterEndpointNotificationCallback(pClient: IMMNotificationClient): HRESULT; stdcall;
  end;


  { Custom Component }

  ///  <summary>
  ///  Monitors and controls the system's master volume level and mute state.
  ///  </summary>
  TJDVolumeControls = class;

  TJDVolumeEvent = procedure(Sender: TObject; const Volume: Integer) of object;

  TJDMuteEvent = procedure(Sender: TObject; const Muted: Boolean) of object;

  // Which devices EnforceMaxVolume clamps...
  TJDVolumeDeviceMode = (
    vdmAll,         // Every active output device (speakers, headphones, Bluetooth, ...)
    vdmDefaultOnly, // Only the current Windows default output device
    vdmSelected     // Only the devices listed in SelectedDeviceIds
  );

  // One audio output device, as returned by EnumerateDevices...
  TJDAudioDeviceInfo = record
    Id: string;           // Windows device ID - stable, use this to identify a device
    FriendlyName: string; // Human name, as shown in Windows Sound settings
    IsDefault: Boolean;   // True when this is the current default output device
    Volume: Integer;      // Current master volume 0..100 (-1 when it could not be read)
  end;

  TJDAudioDeviceInfoArray = array of TJDAudioDeviceInfo;

  TJDVolumeControls = class(TJDMessageComponent, IAudioEndpointVolumeCallback)
  private
    FDeviceEnumerator: IMMDeviceEnumerator;
    FMMDevice: IMMDevice;
    FAudioEndpointVolume: IAudioEndpointVolume;
    FLastVolume: Integer;
    FLastMute: Boolean;
    FOnMuteChanged: TJDMuteEvent;
    FOnVolumeChanged: TJDVolumeEvent;
    // Multi-device support...
    FDeviceMode: TJDVolumeDeviceMode;
    FSelectedDeviceIds: TStringList;
    FBoundDeviceId: string;
    FScopedDeviceCount: Integer;
    FLastClampedCount: Integer;
    function OnNotify(pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT;
      stdcall;
    procedure SetMute(const Value: Boolean);
    procedure SetVolume(const Value: Integer);
    procedure SetDeviceMode(const Value: TJDVolumeDeviceMode);
    function GetDeviceId(const Dev: IMMDevice): string;
    function GetDeviceFriendlyName(const Dev: IMMDevice): string;
    function FindDevice(const DeviceId: string): IMMDevice;
    function IsDeviceSelected(const DeviceId: string): Boolean;
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
    ///  <summary>
    ///  Re-binds the volume/mute monitor to the current default output
    ///  device, if Windows has switched it since the component was created
    ///  (or since the last call). Cheap to call - does nothing when the
    ///  default device has not changed.
    ///  </summary>
    procedure RefreshDefaultDevice;
    ///  <summary>
    ///  Returns every active audio output device, with its friendly name,
    ///  current volume and whether it is the default device.
    ///  </summary>
    function EnumerateDevices: TJDAudioDeviceInfoArray;
    ///  <summary>
    ///  Returns the Windows device ID of the current default output device
    ///  ('' when it could not be determined).
    ///  </summary>
    function GetDefaultDeviceId: string;
    ///  <summary>
    ///  Reads the master volume (0..100) of one device by ID.
    ///  Returns -1 when the device cannot be found or read.
    ///  </summary>
    function GetDeviceVolume(const DeviceId: string): Integer;
    ///  <summary>
    ///  Sets the master volume (0..100) of one device by ID.
    ///  Returns False when the device cannot be found or written.
    ///  </summary>
    function SetDeviceVolume(const DeviceId: string; const Volume: Integer): Boolean;
    ///  <summary>
    ///  Turns down every device in scope (see DeviceMode) that is louder
    ///  than MaxVol. Returns how many devices were actually turned down.
    ///  ScopedDeviceCount tells you how many devices were in scope.
    ///  </summary>
    function EnforceMaxVolume(const MaxVol: Integer): Integer;
    ///  <summary>
    ///  Device IDs to enforce when DeviceMode is vdmSelected. IDs of
    ///  devices that are currently unplugged are simply skipped.
    ///  </summary>
    property SelectedDeviceIds: TStringList read FSelectedDeviceIds;
    ///  <summary>
    ///  How many devices were in scope the last time EnforceMaxVolume ran.
    ///  </summary>
    property ScopedDeviceCount: Integer read FScopedDeviceCount;
    ///  <summary>
    ///  How many devices were actually turned down the last time
    ///  EnforceMaxVolume ran.
    ///  </summary>
    property LastClampedCount: Integer read FLastClampedCount;
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
    ///  Which devices EnforceMaxVolume clamps: all of them, only the
    ///  default, or only the ones in SelectedDeviceIds.
    ///  </summary>
    property DeviceMode: TJDVolumeDeviceMode read FDeviceMode write SetDeviceMode default vdmAll;
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

// PropVariantClear frees the memory inside a PROPVARIANT (for example the
// string returned by IPropertyStore.GetValue). It lives in ole32.dll.
function PropVariantClear(var pvar: TJDPropVariant): HRESULT; stdcall; external 'ole32.dll' name 'PropVariantClear';

const
  // PKEY_Device_FriendlyName = {a45c254e-df1c-4efd-8020-67d146a850e0}, pid 14.
  // This is the "Speakers (Realtek Audio)" style name Windows shows for a
  // device in Sound settings.
  PKEY_Device_FriendlyName_FmtId: TGUID = '{a45c254e-df1c-4efd-8020-67d146a850e0}';
  PKEY_Device_FriendlyName_Pid = 14;

constructor TJDVolumeControls.Create(AOwner: TComponent);
var
  sVal: Single;
  bVal: BOOL;
begin
  inherited;
  // List of device IDs to enforce in vdmSelected mode (empty = none picked yet).
  FSelectedDeviceIds:= TStringList.Create;
  FDeviceMode:= vdmAll;
  if not Succeeded(CoInitialize(nil)) then
    ExitProcess(1); //TODO: But why?

  OleCheck(CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER,
    IID_IMMDeviceEnumerator, FDeviceEnumerator));
  OleCheck(FDeviceEnumerator.GetDefaultAudioEndpoint(0, 0, FMMDevice));
  OleCheck(FMMDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, FAudioEndpointVolume));
  OleCheck(FAudioEndpointVolume.RegisterControlChangeNotify(Self));

  // Remember which device we bound to, so RefreshDefaultDevice can tell
  // later whether Windows has switched the default away from it.
  FBoundDeviceId:= GetDeviceId(FMMDevice);

  if FAudioEndpointVolume.GetMasterVolumeLevelScalar(sVal) = S_OK then begin
    FLastVolume:= Round(sVal * 100);
  end;

  if FAudioEndpointVolume.GetMute(bVal) = S_OK then begin
    FLastMute:= bVal <> False;
  end;
end;

destructor TJDVolumeControls.Destroy;
begin
  // Stop listening for volume changes on the bound device, then let go of
  // the COM interfaces before COM itself is shut down.
  if Assigned(FAudioEndpointVolume) then
    FAudioEndpointVolume.UnregisterControlChangeNotify(Self);
  FAudioEndpointVolume:= nil;
  FMMDevice:= nil;
  FDeviceEnumerator:= nil;
  FreeAndNil(FSelectedDeviceIds);
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

procedure TJDVolumeControls.SetDeviceMode(const Value: TJDVolumeDeviceMode);
begin
  FDeviceMode:= Value;
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

function TJDVolumeControls.GetDeviceId(const Dev: IMMDevice): string;
var
  IdStr: PLPWSTR;
begin
  Result:= '';
  if not Assigned(Dev) then Exit;
  IdStr:= nil;
  if Dev.GetId(IdStr) <> S_OK then Exit;
  // GetId hands us a string Windows allocated - we own it now, so we
  // must free it with CoTaskMemFree when we are done with it.
  try
    if Assigned(IdStr) then
      Result:= string(IdStr^);
  finally
    if Assigned(IdStr) then
      CoTaskMemFree(IdStr);
  end;
end;

function TJDVolumeControls.GetDeviceFriendlyName(const Dev: IMMDevice): string;
var
  Store: IPropertyStore;
  Key: TJDPropertyKey;
  PropVar: TJDPropVariant;
begin
  Result:= '';
  if not Assigned(Dev) then Exit;
  // Open the device's read-only property store...
  if Dev.OpenPropertyStore(TMD_STGM_READ, Store) <> S_OK then Exit;
  if not Assigned(Store) then Exit;
  // ...and ask it for the friendly name ("Speakers (Realtek Audio)").
  Key.fmtid:= PKEY_Device_FriendlyName_FmtId;
  Key.pid:= PKEY_Device_FriendlyName_Pid;
  FillChar(PropVar, SizeOf(PropVar), 0);
  if Store.GetValue(Key, PropVar) <> S_OK then Exit;
  try
    if (PropVar.vt = TMD_VT_LPWSTR) and Assigned(PropVar.pwszVal) then
      Result:= string(PropVar.pwszVal);
  finally
    // GetValue allocated the string - PropVariantClear gives it back.
    PropVariantClear(PropVar);
  end;
end;

function TJDVolumeControls.FindDevice(const DeviceId: string): IMMDevice;
begin
  Result:= nil;
  if not Assigned(FDeviceEnumerator) then Exit;
  if DeviceId = '' then Exit;
  // GetDevice looks a device up by the ID string GetId returned earlier.
  if FDeviceEnumerator.GetDevice(PWideChar(DeviceId), Result) <> S_OK then
    Result:= nil;
end;

// Is this device ID on the selected list? Compared without caring about
// upper/lower case, so a registry value typed by hand still matches.
function TJDVolumeControls.IsDeviceSelected(const DeviceId: string): Boolean;
var
  I: Integer;
begin
  Result:= False;
  for I:= 0 to FSelectedDeviceIds.Count - 1 do begin
    if SameText(FSelectedDeviceIds[I], DeviceId) then begin
      Result:= True;
      Exit;
    end;
  end;
end;

procedure TJDVolumeControls.RefreshDefaultDevice;
var
  Dev: IMMDevice;
  EpVol: IAudioEndpointVolume;
  NewId: string;
  sVal: Single;
  bVal: BOOL;
begin
  if not Assigned(FDeviceEnumerator) then Exit;
  if FDeviceEnumerator.GetDefaultAudioEndpoint(TMD_DATAFLOW_RENDER, TMD_ROLE_CONSOLE, Dev) <> S_OK then Exit;
  if not Assigned(Dev) then Exit;
  NewId:= GetDeviceId(Dev);
  // Same device as before? Nothing to do - this is the common case, and
  // why calling this often (for example from EnforceMaxVolume) is cheap.
  if (NewId = '') or (NewId = FBoundDeviceId) then Exit;
  // The default moved - activate the NEW device first, so if anything
  // fails we keep listening to the old one instead of ending up deaf.
  if Dev.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, EpVol) <> S_OK then Exit;
  if not Assigned(EpVol) then Exit;
  if Assigned(FAudioEndpointVolume) then
    FAudioEndpointVolume.UnregisterControlChangeNotify(Self);
  FMMDevice:= Dev;
  FAudioEndpointVolume:= EpVol;
  FBoundDeviceId:= NewId;
  FAudioEndpointVolume.RegisterControlChangeNotify(Self);
  // Refresh the cached volume / mute so Volume / Muted stay truthful.
  if FAudioEndpointVolume.GetMasterVolumeLevelScalar(sVal) = S_OK then
    FLastVolume:= Round(sVal * 100);
  if FAudioEndpointVolume.GetMute(bVal) = S_OK then
    FLastMute:= bVal <> False;
end;

function TJDVolumeControls.GetDefaultDeviceId: string;
var
  Dev: IMMDevice;
begin
  Result:= '';
  if not Assigned(FDeviceEnumerator) then Exit;
  if FDeviceEnumerator.GetDefaultAudioEndpoint(TMD_DATAFLOW_RENDER, TMD_ROLE_CONSOLE, Dev) <> S_OK then Exit;
  Result:= GetDeviceId(Dev);
end;

function TJDVolumeControls.EnumerateDevices: TJDAudioDeviceInfoArray;
var
  Coll: IMMDeviceCollection;
  Count: UINT;
  I: Integer;
  Dev: IMMDevice;
  EpVol: IAudioEndpointVolume;
  DefaultId: string;
  Used: Integer;
  sVal: Single;
begin
  Result:= nil;
  // While we are here, keep the legacy default-device binding fresh,
  // so Volume / Muted / OnVolumeChanged keep tracking the real default.
  RefreshDefaultDevice;
  if not Assigned(FDeviceEnumerator) then Exit;
  // Ask Windows for every output device that is plugged in and enabled.
  // (Disabled / unplugged devices are left out on purpose - there is no
  // volume to enforce on a device that cannot make sound.)
  if FDeviceEnumerator.EnumAudioEndpoints(TMD_DATAFLOW_RENDER, TMD_DEVICE_STATE_ACTIVE, Coll) <> S_OK then Exit;
  if not Assigned(Coll) then Exit;
  if Coll.GetCount(Count) <> S_OK then Exit;
  DefaultId:= GetDefaultDeviceId;
  SetLength(Result, Count);
  Used:= 0;
  for I:= 0 to Integer(Count) - 1 do begin
    if Coll.Item(UINT(I), Dev) <> S_OK then Continue;
    if not Assigned(Dev) then Continue;
    Result[Used].Id:= GetDeviceId(Dev);
    if Result[Used].Id = '' then Continue;
    Result[Used].FriendlyName:= GetDeviceFriendlyName(Dev);
    // No friendly name? Fall back to the device ID so the list still
    // shows something identifiable.
    if Result[Used].FriendlyName = '' then
      Result[Used].FriendlyName:= Result[Used].Id;
    Result[Used].IsDefault:= SameText(Result[Used].Id, DefaultId);
    // Read this device's own master volume (each device has its own).
    Result[Used].Volume:= -1;
    if Dev.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, EpVol) = S_OK then begin
      if Assigned(EpVol) and (EpVol.GetMasterVolumeLevelScalar(sVal) = S_OK) then
        Result[Used].Volume:= Round(sVal * 100);
    end;
    Inc(Used);
  end;
  // Drop any slots left empty by devices we had to skip.
  SetLength(Result, Used);
end;

function TJDVolumeControls.GetDeviceVolume(const DeviceId: string): Integer;
var
  Dev: IMMDevice;
  EpVol: IAudioEndpointVolume;
  sVal: Single;
begin
  Result:= -1;
  Dev:= FindDevice(DeviceId);
  if not Assigned(Dev) then Exit;
  if Dev.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, EpVol) <> S_OK then Exit;
  if not Assigned(EpVol) then Exit;
  if EpVol.GetMasterVolumeLevelScalar(sVal) = S_OK then
    Result:= Round(sVal * 100);
end;

function TJDVolumeControls.SetDeviceVolume(const DeviceId: string; const Volume: Integer): Boolean;
var
  Dev: IMMDevice;
  EpVol: IAudioEndpointVolume;
  sVal: Single;
  Vol: Integer;
begin
  Result:= False;
  // Clamp to a sane range - Windows expects 0.0..1.0, and a value outside
  // 0..100 would be a bug in the caller, not something to pass on.
  Vol:= Volume;
  if Vol < 0 then Vol:= 0;
  if Vol > 100 then Vol:= 100;
  Dev:= FindDevice(DeviceId);
  if not Assigned(Dev) then Exit;
  if Dev.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, EpVol) <> S_OK then Exit;
  if not Assigned(EpVol) then Exit;
  sVal:= Vol / 100;
  Result:= EpVol.SetMasterVolumeLevelScalar(sVal, nil) = S_OK;
  // If we just changed the default device, keep the legacy Volume
  // property in sync so the gauge stays truthful right away.
  // (The volume-change callback normally does this for us a moment
  // later, but this makes it immediate.)
  if Result and SameText(DeviceId, FBoundDeviceId) then
    FLastVolume:= Vol;
end;

function TJDVolumeControls.EnforceMaxVolume(const MaxVol: Integer): Integer;
var
  Devices: TJDAudioDeviceInfoArray;
  I: Integer;
  InScope: Boolean;
begin
  Result:= 0;
  FScopedDeviceCount:= 0;
  FLastClampedCount:= 0;
  Devices:= EnumerateDevices;
  for I:= 0 to High(Devices) do begin
    // Work out whether this device is in scope for the current mode...
    case FDeviceMode of
      vdmAll: InScope:= True;
      vdmDefaultOnly: InScope:= Devices[I].IsDefault;
      vdmSelected: InScope:= IsDeviceSelected(Devices[I].Id);
    else
      InScope:= True;
    end;
    if not InScope then Continue;
    Inc(FScopedDeviceCount);
    // ...and turn it down if it is louder than the max. Devices whose
    // volume could not be read (-1) are left alone.
    if (Devices[I].Volume > MaxVol) and SetDeviceVolume(Devices[I].Id, MaxVol) then begin
      Inc(Result);
      Inc(FLastClampedCount);
    end;
  end;
end;

end.

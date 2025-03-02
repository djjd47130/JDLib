unit JD.VolumeControls2;

interface


uses
  System.Classes, System.SysUtils, System.Types,
  System.StrUtils, System.Math,
{$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages,
  Winapi.MMSystem, System.Win.ComObj, Winapi.ActiveX, Winapi.PropSys, Winapi.ShlObj
{$ENDIF}
{$IFDEF MACOS}
  Macapi.CoreAudio, Macapi.CoreFoundation
{$ENDIF}
{$IFDEF ANDROID}
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, FMX.Helpers.Android
{$ENDIF}
{$IFDEF IOS}
  iOSapi.MediaPlayer, iOSapi.AVFoundation, iOSapi.Foundation, iOSapi.CocoaTypes, Macapi.ObjCRuntime, Macapi.ObjectiveC
{$ENDIF}
;



{$IFDEF MSWINDOWS}


const
  CLASS_IMMDeviceEnumerator : TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  IID_IMMDeviceEnumerator : TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
  IID_IAudioEndpointVolume : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';

  // CLSID for MMDeviceEnumerator
  CLSID_MMDeviceEnumerator: TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';

  // IID for IAudioSessionManager2
  IID_IAudioSessionManager2: TGUID = '{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}';

  // IID for IAudioSessionEnumerator
  IID_IAudioSessionEnumerator: TGUID = '{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}';

  // IID for IAudioSessionControl
  IID_IAudioSessionControl: TGUID = '{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}';

  // IID for IAudioSessionControl2
  IID_IAudioSessionControl2: TGUID = '{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}';

  // IID for ISimpleAudioVolume
  IID_ISimpleAudioVolume: TGUID = '{87CE5498-68D6-44E5-9215-6DA47EF883D8}';


  WM_VOLNOTIFY = WM_USER + 1;
{$ENDIF}


type

{$IFDEF MSWINDOWS}

  { WinAPI Wrapper}

  LPCGUID = ^TGUID;

  EDataFlow = (
    eRender = 0,      // Audio rendering stream. Audio data flows from the application to the audio endpoint device.
    eCapture,         // Audio capture stream. Audio data flows from the audio endpoint device to the application.
    eAll,             // Audio rendering or capture stream.
    EDataFlow_enum_count // Number of members in the enumeration.
  );

  ERole = (
    eConsole = 0,         // The audio endpoint device is to be used for games, system sounds, and voice commands.
    eMultimedia,          // The audio endpoint device is to be used for music, movies, and live music recording.
    eCommunications,      // The audio endpoint device is to be used for voice communications (e.g., VoIP).
    ERole_enum_count      // Number of members in the enumeration.
  );


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





  // IAudioSessionControl Interface
  IAudioSessionControl = interface(IUnknown)
    ['{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}']
    function GetState(out State: Integer): HRESULT; stdcall;
    function GetDisplayName(out DisplayName: PWideChar): HRESULT; stdcall;
    function SetDisplayName(DisplayName: PWideChar; EventContext: LPCGUID): HRESULT; stdcall;
    function GetIconPath(out IconPath: PWideChar): HRESULT; stdcall;
    function SetIconPath(IconPath: PWideChar; EventContext: LPCGUID): HRESULT; stdcall;
    function GetGroupingParam(out GroupingParam: TGUID): HRESULT; stdcall;
    function SetGroupingParam(GroupingParam: LPCGUID; EventContext: LPCGUID): HRESULT; stdcall;
    function RegisterAudioSessionNotification(NewNotifications: IUnknown): HRESULT; stdcall;
    function UnregisterAudioSessionNotification(NewNotifications: IUnknown): HRESULT; stdcall;
  end;

  // IAudioSessionEnumerator Interface
  IAudioSessionEnumerator = interface(IUnknown)
    ['{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}']
    function GetCount(out SessionCount: Integer): HRESULT; stdcall;
    function GetSession(SessionCount: Integer; out Session: IAudioSessionControl): HRESULT; stdcall;
  end;

  // IAudioSessionManager2 Interface
  IAudioSessionManager2 = interface(IUnknown)
    ['{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}']
    function GetSessionEnumerator(out SessionEnum: IAudioSessionEnumerator): HRESULT; stdcall;
    function RegisterSessionNotification(SessionNotification: IUnknown): HRESULT; stdcall;
    function UnregisterSessionNotification(SessionNotification: IUnknown): HRESULT; stdcall;
    function RegisterDuckNotification(SessionID: LPCGUID; DuckNotification: IUnknown): HRESULT; stdcall;
    function UnregisterDuckNotification(DuckNotification: IUnknown): HRESULT; stdcall;
  end;

  // IAudioSessionControl2 Interface
  IAudioSessionControl2 = interface(IAudioSessionControl)
    ['{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}']
    function GetSessionIdentifier(out RetVal: PWideChar): HRESULT; stdcall;
    function GetSessionInstanceIdentifier(out RetVal: PWideChar): HRESULT; stdcall;
    function GetProcessId(out RetVal: DWORD): HRESULT; stdcall;
    function IsSystemSoundsSession: HRESULT; stdcall;
    function SetDuckingPreference(OptOut: LongBool): HRESULT; stdcall;
  end;

  // ISimpleAudioVolume Interface
  ISimpleAudioVolume = interface(IUnknown)
    ['{87CE5498-68D6-44E5-9215-6DA47EF883D8}']
    function SetMasterVolume(fLevel: Single; EventContext: LPCGUID): HRESULT; stdcall;
    function GetMasterVolume(out fLevel: Single): HRESULT; stdcall;
    function SetMute(bMute: LongBool; EventContext: LPCGUID): HRESULT; stdcall;
    function GetMute(out bMute: LongBool): HRESULT; stdcall;
  end;


{$ENDIF}



  { Custom Component }

  ///  <summary>
  ///  Monitors and controls the system's master volume level and mute state.
  ///  </summary>
  TJDVolumeControls = class;

  TJDVolumeEvent = procedure(Sender: TObject; const Volume: Integer) of object;

  TJDMuteEvent = procedure(Sender: TObject; const Muted: Boolean) of object;

  TJDVolumeControls = class(TComponent)
  private
    FLastVolume: Integer;
    FLastMute: Boolean;
    FOnMuteChanged: TJDMuteEvent;
    FOnVolumeChanged: TJDVolumeEvent;
    procedure SetMute(const Value: Boolean);
    procedure SetVolume(const Value: Integer);
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

procedure SetVolume(Volume: Single);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := Round(Volume * $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}
  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyVolumeScalar, 0, nil, SizeOf(Volume), @Volume);
  {$ENDIF}
  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC, Round(Volume * AudioManager.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC)), 0);
  {$ENDIF}
  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setPreferredOutputNumberOfChannels(1, nil);
  AudioSession.setPreferredInputNumberOfChannels(1, nil);
  AudioSession.setPreferredSampleRate(44100, nil);
  AudioSession.setPreferredIOBufferDuration(0.005, nil);
  AudioSession.setActive(true, nil);
  AudioSession.setOutputVolume(Volume, nil);
  {$ENDIF}
end;

function GetVolume: Single;
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD;
  waveOutGetVolume(0, @VolumeValue);
  Result := (VolumeValue and $FFFF) / $FFFF;
  {$ENDIF}
  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectGetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyVolumeScalar, 0, nil, SizeOf(Result), @Result);
  {$ENDIF}
  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  Result := AudioManager.getStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC) / AudioManager.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC);
  {$ENDIF}
  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  Result := AudioSession.outputVolume;
  {$ENDIF}
end;

procedure SetMute(Mute: Boolean);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := IfThen(Mute, 0, $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}
  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  var IsMuted: UInt32 := IfThen(Mute, 1, 0);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyMute, 0, nil, SizeOf(IsMuted), @IsMuted);
  {$ENDIF}
  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC, Mute);
  {$ENDIF}
  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(True, nil);
  var AudioOutput: AVAudioOutputNode := TAVAudioEngine.Wrap(TAVAudioEngine.OCClass.mainMixerNode).outputNode;
  AudioOutput.setVolume(IfThen(Mute, 0.0, 1.0));
  {$ENDIF}
end;

function IsMuted: Boolean;
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD;
  waveOutGetVolume(0, @VolumeValue);
  Result := (VolumeValue and $FFFF) = 0;
  {$ENDIF}
  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  var IsMuted: UInt32;
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectGetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyMute, 0, nil, SizeOf(IsMuted), @IsMuted);
  Result := IsMuted = 1;
  {$ENDIF}
  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  Result := AudioManager.isStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC);
  {$ENDIF}
  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(True, nil);
  Result := AudioSession.outputVolume = 0.0;
  {$ENDIF}
end;





procedure InitJDVolCtrl;
{$IFDEF IOS}
var
  AudioSession: AVAudioSession;
{$ENDIF}
begin
{$IFDEF MACOS}
  // Placeholder for CoreAudio initialization if needed
{$ENDIF}
{$IFDEF IOS}
  AudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(true, nil);
{$ENDIF}
end;

procedure UninitJDVolCtrl;
{$IFDEF IOS}
var
  AudioSession: AVAudioSession;
{$ENDIF}
begin
{$IFDEF MACOS}
  // Placeholder for CoreAudio finalization if needed
{$ENDIF}
{$IFDEF IOS}
  AudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(false, nil);
{$ENDIF}
end;




{ Application audio session specific volume and mute control }

{$IFDEF MSWINDOWS}
procedure SetApplicationVolume(const AppName: string; Volume: Single);
var
  DeviceEnumerator: IMMDeviceEnumerator;
  DefaultDevice: IMMDevice;
  AudioEndpointVolume: IAudioEndpointVolume;
  SessionEnumerator: IAudioSessionEnumerator;
  Session: IAudioSessionControl;
  SessionControl: IAudioSessionControl2;
  SimpleVolume: ISimpleAudioVolume;
  Count, i: Integer;
  DisplayName: PWideChar;
begin
  CoInitialize(nil);
  try
    CoCreateInstance(CLSID_MMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, DeviceEnumerator);
    DeviceEnumerator.GetDefaultAudioEndpoint(Cardinal(eRender), Cardinal(eConsole), DefaultDevice);
    DefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, AudioEndpointVolume);

    for i := 0 to Count - 1 do
    begin
      SessionEnumerator.GetSession(i, Session);
      Session.QueryInterface(IID_IAudioSessionControl2, SessionControl);
      SessionControl.GetDisplayName(DisplayName);

      if WideCharToString(DisplayName) = AppName then
      begin
        Session.QueryInterface(IID_ISimpleAudioVolume, SimpleVolume);
        SimpleVolume.SetMasterVolume(Volume, nil);
        Break;
      end;
    end;

  finally
    CoUninitialize;
  end;
end;

function GetApplicationVolume(const AppName: string): Single;
var
  DeviceEnumerator: IMMDeviceEnumerator;
  DefaultDevice: IMMDevice;
  AudioEndpointVolume: IAudioEndpointVolume;
  SessionEnumerator: IAudioSessionEnumerator;
  Session: IAudioSessionControl;
  SessionControl: IAudioSessionControl2;
  SimpleVolume: ISimpleAudioVolume;
  Count, i: Integer;
  DisplayName: PWideChar;
begin
  Result := -1;
  CoInitialize(nil);
  try
    CoCreateInstance(CLSID_MMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, DeviceEnumerator);
    DeviceEnumerator.GetDefaultAudioEndpoint(Cardinal(eRender), Cardinal(eConsole), DefaultDevice);
    DefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, AudioEndpointVolume);

    for i := 0 to Count - 1 do
    begin
      SessionEnumerator.GetSession(i, Session);
      Session.QueryInterface(IID_IAudioSessionControl2, SessionControl);
      SessionControl.GetDisplayName(DisplayName);

      if WideCharToString(DisplayName) = AppName then
      begin
        Session.QueryInterface(IID_ISimpleAudioVolume, SimpleVolume);
        SimpleVolume.GetMasterVolume(Result);
        Break;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure SetApplicationMute(const AppName: string; Mute: Boolean);
var
  DeviceEnumerator: IMMDeviceEnumerator;
  DefaultDevice: IMMDevice;
  AudioEndpointVolume: IAudioEndpointVolume;
  SessionEnumerator: IAudioSessionEnumerator;
  Session: IAudioSessionControl;
  SessionControl: IAudioSessionControl2;
  SimpleVolume: ISimpleAudioVolume;
  Count, i: Integer;
  DisplayName: PWideChar;
begin
  CoInitialize(nil);
  try
    CoCreateInstance(CLSID_MMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, DeviceEnumerator);
    DeviceEnumerator.GetDefaultAudioEndpoint(Cardinal(eRender), Cardinal(eConsole), DefaultDevice);
    DefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, AudioEndpointVolume);

    for i := 0 to Count - 1 do
    begin
      SessionEnumerator.GetSession(i, Session);
      Session.QueryInterface(IID_IAudioSessionControl2, SessionControl);
      SessionControl.GetDisplayName(DisplayName);

      if WideCharToString(DisplayName) = AppName then
      begin
        Session.QueryInterface(IID_ISimpleAudioVolume, SimpleVolume);
        SimpleVolume.SetMute(Mute, nil);
        Break;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

function IsApplicationMuted(const AppName: string): Boolean;
var
  DeviceEnumerator: IMMDeviceEnumerator;
  DefaultDevice: IMMDevice;
  AudioEndpointVolume: IAudioEndpointVolume;
  SessionEnumerator: IAudioSessionEnumerator;
  Session: IAudioSessionControl;
  SessionControl: IAudioSessionControl2;
  SimpleVolume: ISimpleAudioVolume;
  Count, i: Integer;
  DisplayName: PWideChar;
  IsMuted: BOOL;
begin
  Result := False;
  CoInitialize(nil);
  try
    CoCreateInstance(CLSID_MMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, DeviceEnumerator);
    DeviceEnumerator.GetDefaultAudioEndpoint(Cardinal(eRender), Cardinal(eConsole), DefaultDevice);
    DefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, AudioEndpointVolume);

    for i := 0 to Count - 1 do
    begin
      SessionEnumerator.GetSession(i, Session);
      Session.QueryInterface(IID_IAudioSessionControl2, SessionControl);
      SessionControl.GetDisplayName(DisplayName);

      if WideCharToString(DisplayName) = AppName then
      begin
        Session.QueryInterface(IID_ISimpleAudioVolume, SimpleVolume);
        SimpleVolume.GetMute(IsMuted);
        Result:= IsMuted;
        Break;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

//TODO: List application audio sessions...

function ListAudioSessions(AList: TStrings): Boolean;
var
  DeviceEnumerator: IMMDeviceEnumerator;
  DefaultDevice: IMMDevice;
  AudioEndpointVolume: IAudioEndpointVolume;
  SessionEnumerator: IAudioSessionEnumerator;
  Session: IAudioSessionControl;
  SessionControl: IAudioSessionControl2;
  //SimpleVolume: ISimpleAudioVolume;
  SessionManager: IAudioSessionManager2;
  Count, i: Integer;
  DisplayName: PWideChar;
begin
  try
    CoInitialize(nil);
    try
      CoCreateInstance(CLSID_MMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, DeviceEnumerator);
      DeviceEnumerator.GetDefaultAudioEndpoint(Cardinal(eRender), Cardinal(eConsole), DefaultDevice);
      DefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, AudioEndpointVolume);
      SessionManager.GetSessionEnumerator(SessionEnumerator);
      SessionEnumerator.GetCount(Count);

      AList.Clear;
      for i := 0 to Count - 1 do begin
        SessionEnumerator.GetSession(i, Session);
        Session.QueryInterface(IID_IAudioSessionControl2, SessionControl);
        SessionControl.GetDisplayName(DisplayName);
        AList.Add(WideCharToString(DisplayName));
      end;

      Result := True;
    finally
      CoUninitialize;
    end;
  except
    on E: Exception do begin
      Result:= False;
    end;
  end;
end;




{$ENDIF}



{$IFDEF ANDROID}

procedure TAudioControl.SetApplicationVolume(const AppName: string; const Volume: Integer);
var
  Sessions: JList;
  Session: JMediaController;
  Attributes: JAudioAttributes;
  i: Integer;
begin
  Sessions := FMediaSessionManager.getActiveSessions(nil);
  for i := 0 to Sessions.size - 1 do
  begin
    Session := TJMediaController.Wrap((Sessions.get(i) as ILocalObject).GetObjectID);
    if JStringToString(Session.getPackageName) = AppName then
    begin
      Attributes := Session.getPlaybackInfo.getAudioAttributes;
      if (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_MEDIA) or
         (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_GAME) then
      begin
        FAudioManager.setStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC, Volume, 0);
      end;
    end;
  end;
end;

function TAudioControl.GetApplicationVolume(const AppName: string): Integer;
var
  Sessions: JList;
  Session: JMediaController;
  Attributes: JAudioAttributes;
  i: Integer;
begin
  Sessions := FMediaSessionManager.getActiveSessions(nil);
  for i := 0 to Sessions.size - 1 do
  begin
    Session := TJMediaController.Wrap((Sessions.get(i) as ILocalObject).GetObjectID);
    if JStringToString(Session.getPackageName) = AppName then
    begin
      Attributes := Session.getPlaybackInfo.getAudioAttributes;
      if (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_MEDIA) or
         (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_GAME) then
      begin
        Result := FAudioManager.getStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC);
        Exit;
      end;
    end;
  end;
  Result := -1;
end;

procedure TAudioControl.SetApplicationMute(const AppName: string; const Mute: Boolean);
var
  Sessions: JList;
  Session: JMediaController;
  Attributes: JAudioAttributes;
  i: Integer;
begin
  Sessions := FMediaSessionManager.getActiveSessions(nil);
  for i := 0 to Sessions.size - 1 do
  begin
    Session := TJMediaController.Wrap((Sessions.get(i) as ILocalObject).GetObjectID);
    if JStringToString(Session.getPackageName) = AppName then
    begin
      Attributes := Session.getPlaybackInfo.getAudioAttributes;
      if (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_MEDIA) or
         (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_GAME) then
      begin
        if Mute then
          FAudioManager.adjustStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC,
                                           TJAudioManager.JavaClass.ADJUST_MUTE, 0)
        else
          FAudioManager.adjustStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC,
                                           TJAudioManager.JavaClass.ADJUST_UNMUTE, 0);
      end;
    end;
  end;
end;

function TAudioControl.IsApplicationMuted(const AppName: string): Boolean;
var
  Sessions: JList;
  Session: JMediaController;
  Attributes: JAudioAttributes;
  i: Integer;
begin
  Sessions := FMediaSessionManager.getActiveSessions(nil);
  for i := 0 to Sessions.size - 1 do
  begin
    Session := TJMediaController.Wrap((Sessions.get(i) as ILocalObject).GetObjectID);
    if JStringToString(Session.getPackageName) = AppName then
    begin
      Attributes := Session.getPlaybackInfo.getAudioAttributes;
      if (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_MEDIA) or
         (Attributes.getUsage = TJAudioAttributes.JavaClass.USAGE_GAME) then
      begin
        Result := FAudioManager.isStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC);
        Exit;
      end;
    end;
  end;
  Result := False;
end;

function TAudioControl.GetControllableApps(AList: TStrings): Boolean;
var
  Sessions: JList;
  Session: JMediaController;
  i: Integer;
begin
  AList.Clear;
  Sessions := FMediaSessionManager.getActiveSessions(nil);
  for i := 0 to Sessions.size - 1 do
  begin
    Session := TJMediaController.Wrap((Sessions.get(i) as ILocalObject).GetObjectID);
    AList.Add(JStringToString(Session.getPackageName));
  end;
  Result := True;
end;


{$ENDIF}










{ TJDVolumeControls }

constructor TJDVolumeControls.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF MSWINDOWS}
  CoInitialize(nil);

  {$ENDIF}
  {$IFDEF MACOS}

  {$ENDIF}
  {$IFDEF ANDROID}

  {$ENDIF}
  {$IFDEF IOS}

  {$ENDIF}
end;

destructor TJDVolumeControls.Destroy;
begin

  {$IFDEF MSWINDOWS}

  CoUninitialize;
  {$ENDIF}
  {$IFDEF MACOS}

  {$ENDIF}
  {$IFDEF ANDROID}

  {$ENDIF}
  {$IFDEF IOS}

  {$ENDIF}
  inherited;
end;

procedure TJDVolumeControls.SetMute(const Value: Boolean);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := IfThen(Muted, 0, $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  var IsMuted: UInt32 := IfThen(Muted, 1, 0);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyMute, 0, nil, SizeOf(IsMuted), @IsMuted);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamMute(TJAudioManager.JavaClass.STREAM_MUSIC, Muted);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(True, nil);
  var AudioOutput: AVAudioOutputNode := TAVAudioEngine.Wrap(TAVAudioEngine.OCClass.mainMixerNode).outputNode;
  AudioOutput.setVolume(IfThen(Muted, 0.0, 1.0));
  {$ENDIF}

end;

procedure TJDVolumeControls.SetVolume(const Value: Integer);
begin
  {$IFDEF MSWINDOWS}
  // Windows-specific code
  var VolumeValue: DWORD := Round(Volume * $FFFF);
  waveOutSetVolume(0, VolumeValue or (VolumeValue shl 16));
  {$ENDIF}

  {$IFDEF MACOS}
  // macOS-specific code
  var DefaultOutputDeviceID: AudioDeviceID;
  var Size: UInt32 := SizeOf(DefaultOutputDeviceID);
  AudioObjectGetPropertyData(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, 0, nil, Size, @DefaultOutputDeviceID);
  AudioObjectSetPropertyData(DefaultOutputDeviceID, kAudioDevicePropertyVolumeScalar, 0, nil, SizeOf(Volume), @Volume);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Android-specific code
  var AudioManager: JAudioManager := TJAudioManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.AUDIO_SERVICE) as ILocalObject).GetObjectID);
  AudioManager.setStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC, Round(Volume * AudioManager.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC)), 0);
  {$ENDIF}

  {$IFDEF IOS}
  // iOS-specific code
  var AudioSession: AVAudioSession := TAVAudioSession.Wrap(TAVAudioSession.OCClass.sharedInstance);
  AudioSession.setActive(true, nil);
  var AudioOutput: AVAudioOutputNode := TAVAudioEngine.Wrap(TAVAudioEngine.OCClass.mainMixerNode).outputNode;
  AudioOutput.setVolume(Volume);
  {$ENDIF}

end;

procedure TJDVolumeControls.VolDown;
begin
  Volume:= Volume - 2;
end;

procedure TJDVolumeControls.VolUp;
begin
  Volume:= Volume + 2;
end;

initialization
  InitJDVolCtrl;

finalization
  UninitJDVolCtrl;

end.
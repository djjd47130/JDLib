unit JD.SysMon;

interface

// NOTE (review §5): System.Generics.Collections and Winapi.TlHelp32 were
// dropped from the uses clause below - the deleted duplicate CPU methods
// were their only users (TArray and the toolhelp snapshot calls), so
// keeping them would just add "unused unit" hints.
uses
  System.Classes, System.SysUtils, System.DateUtils, System.IOUtils,
  System.Variants, System.Types, System.SyncObjs,
  Winapi.PsAPI, Winapi.ShellAPI,
  Winapi.Windows, Winapi.ActiveX, ComObj,
  JD.Common, JD.SysMon.Utils;

type
  TJDSystemMonitorThread = class;
  TJDSystemMonitor = class;

  TJDSystemMonitorCPUEvent = procedure(Sender: TObject; CPU: TJDSystemMonitorCPUInfo) of object;

  TJDSystemMonitorRAMEvent = procedure(Sender: TObject; RAM: TJDSystemMonitorRAMInfo) of object;

  TJDSystemMonitorDriveEvent = procedure(Sender: TObject; Drive: TJDSystemMonitorDriveInfo) of object;

  TJDSystemMonitorThread = class(TThread)
  private
    // NOTE (review §5): this thread used to have its own copy of the CPU
    // measuring code (GetRunningProcessIDs / GetProcessCpuUsagePct /
    // GetTotalCpuUsagePct plus its own process cache), duplicating the
    // global versions in JD.SysMon.Utils almost line for line. Those
    // duplicates are deleted now - reporting already used the Utils
    // versions (ReportCPU calls GetCPUInfo from JD.SysMon.Utils), so the
    // thread's copies were effectively dead code.
    FLastCPU: TDateTime;
    FLastRAM: TDateTime;
    FLastDrive: TDateTime;
    FLastDriveInfo: TJDSystemMonitorDriveInfoArray;
    FPropLock: TCriticalSection;
    FSYNC_CPU: TJDSystemMonitorCPUInfo;
    FSYNC_RAM: TJDSystemMonitorRAMInfo;
    FSYNC_Drive: TJDSystemMonitorDriveInfo;
    FCPUInterval: Integer;
    FDriveInterval: Integer;
    FRAMInterval: Integer;
    FOnCPUInfo: TJDSystemMonitorCPUEvent;
    FOnRAMInfo: TJDSystemMonitorRAMEvent;
    FOnDriveInfo: TJDSystemMonitorDriveEvent;
    FOnDriveAdded: TJDSystemMonitorDriveEvent;
    FOnDriveRemoved: TJDSystemMonitorDriveEvent;
    //Synchronized Event Triggers
    procedure SYNC_OnCPUInfo;
    procedure SYNC_OnRAMInfo;
    procedure SYNC_OnDriveInfo;
    procedure SYNC_OnDriveAdded;
    procedure SYNC_OnDriveRemoved;
    //Main Triggers
    procedure ReportCPU;
    procedure ReportRAM;
    procedure ReportDrives;
    //Property Setters
    procedure SetCPUInterval(const Value: Integer);
    procedure SetDriveInterval(const Value: Integer);
    procedure SetRAMInterval(const Value: Integer);
    //Drive Related
    procedure RemoveAllDrives;
    //CPU Related
    // (CPU measuring lives in JD.SysMon.Utils now - see the note at the
    // top of this class. GetCPUInfo in that unit calls the shared
    // GetTotalCpuUsagePct, so this thread needs no CPU code of its own.)
    function ShouldReport(var Int: Integer; var Last: TDateTime;
      Cond: Boolean = True): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure LockProps;
    procedure UnlockProps;
    property CPUInterval: Integer read FCPUInterval write SetCPUInterval;
    property RAMInterval: Integer read FRAMInterval write SetRAMInterval;
    property DriveInterval: Integer read FDriveInterval write SetDriveInterval;

    property OnCPUInfo: TJDSystemMonitorCPUEvent read FOnCPUInfo write FOnCPUInfo;
    property OnRAMInfo: TJDSystemMonitorRAMEvent read FOnRAMInfo write FOnRAMInfo;
    property OnDriveInfo: TJDSystemMonitorDriveEvent read FOnDriveInfo write FOnDriveInfo;
    property OnDriveAdded: TJDSystemMonitorDriveEvent read FOnDriveAdded write FOnDriveAdded;
    property OnDriveRemoved: TJDSystemMonitorDriveEvent read FOnDriveRemoved write FOnDriveRemoved;
  end;

  TJDSystemMonitor = class(TJDMessageComponent)
  private
    FThread: TJDSystemMonitorThread;
    // FIX (review §10): the interval values are kept here on the component
    // as well as on the thread. At design time there is no thread (see
    // Create), so the Object Inspector still needs somewhere to read and
    // write these values. At run time the thread holds the live copy and
    // these fields just mirror it.
    FCPUInterval: Integer;
    FRAMInterval: Integer;
    FDriveInterval: Integer;
    FOnCPUInfo: TJDSystemMonitorCPUEvent;
    FOnRAMInfo: TJDSystemMonitorRAMEvent;
    FOnDriveInfo: TJDSystemMonitorDriveEvent;
    FOnDriveAdded: TJDSystemMonitorDriveEvent;
    FOnDriveRemoved: TJDSystemMonitorDriveEvent;
    function GetCPUInterval: Integer;
    function GetDriveInterval: Integer;
    function GetRAMInterval: Integer;
    procedure SetCPUInterval(const Value: Integer);
    procedure SetDriveInterval(const Value: Integer);
    procedure SetRAMInterval(const Value: Integer);
    procedure ThreadCPUInfo(Sender: TObject; Info: TJDSystemMonitorCPUInfo);
    procedure ThreadRAMInfo(Sender: TObject; Info: TJDSystemMonitorRAMInfo);
    procedure ThreadDriveInfo(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
    procedure ThreadDriveAdded(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
    procedure ThreadDriveRemoved(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CPUInterval: Integer read GetCPUInterval write SetCPUInterval;
    property RAMInterval: Integer read GetRAMInterval write SetRAMInterval;
    property DriveInterval: Integer read GetDriveInterval write SetDriveInterval;

    property OnCPUInfo: TJDSystemMonitorCPUEvent read FOnCPUInfo write FOnCPUInfo;
    property OnRAMInfo: TJDSystemMonitorRAMEvent read FOnRAMInfo write FOnRAMInfo;
    property OnDriveInfo: TJDSystemMonitorDriveEvent read FOnDriveInfo write FOnDriveInfo;
    property OnDriveAdded: TJDSystemMonitorDriveEvent read FOnDriveAdded write FOnDriveAdded;
    property OnDriveRemoved: TJDSystemMonitorDriveEvent read FOnDriveRemoved write FOnDriveRemoved;
   end;

implementation

{ TJDSystemMonitorThread }

constructor TJDSystemMonitorThread.Create;
begin
  inherited Create(False);
  FPropLock:= TCriticalSection.Create;
  FCPUInterval:= 300;
  FRAMInterval:= 500;
  FDriveInterval:= 5000;
end;

destructor TJDSystemMonitorThread.Destroy;
begin
  FreeAndNil(FPropLock);
  inherited;
end;

function TJDSystemMonitorThread.ShouldReport(var Int: Integer; var Last: TDateTime;
  Cond: Boolean = True): Boolean;
var
  I: Integer;
begin
  Result:= False;
  LockProps;
  try
    I:= Int;
  finally
    UnlockProps
  end;
  if MilliSecondsBetween(Now, Last) >= I then begin
    Last:= Now;
    Result:= Cond;
  end;
end;

// FIX (review §5): the old commented-out version of this method (the
// pre-ShouldReport code) was deleted - it was dead code, the live code
// below does the same job. GetCPUInfo comes from JD.SysMon.Utils.
procedure TJDSystemMonitorThread.ReportCPU;
begin
  try
    if ShouldReport(FCPUInterval, FLastCPU, Assigned(FOnCPUInfo)) then begin
      FSYNC_CPU:= GetCPUInfo;
      Synchronize(SYNC_OnCPUInfo);
    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

// FIX (review §5): the old commented-out version of this method (the
// pre-ShouldReport code) was deleted - it was dead code, the live code
// above it does the same job.
procedure TJDSystemMonitorThread.ReportRAM;
begin
  try
    if ShouldReport(FRAMInterval, FLastRAM, Assigned(FOnRAMInfo)) then begin
      FSYNC_RAM:= GetRAMInfo;
      Synchronize(SYNC_OnRAMInfo);
    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

// FIX (review §5): the old commented-out copy of this method (the
// pre-ShouldReport version that used to sit below the live code) was
// deleted - it was dead code, the live code does the same job.
procedure TJDSystemMonitorThread.ReportDrives;
var
  DA: TJDSystemMonitorDriveInfoArray;
  X, Y: Integer;
  E: Boolean;
begin
  try
    if ShouldReport(FDriveInterval, FLastDrive, (Assigned(FOnDriveInfo) or
      Assigned(FOnDriveAdded) or Assigned(FOnDriveRemoved))) then
    begin
      DA:= GetAllDriveInfo;
      FLastDrive:= Now;

      //Scan for removed drives...
      if Assigned(FOnDriveRemoved) then begin
        for X := 0 to Length(FLastDriveInfo)-1 do begin
          FSYNC_Drive:= FLastDriveInfo[X];
          E:= False;
          for Y := 0 to Length(DA)-1 do begin
            if FSYNC_Drive.DriveLetter = DA[Y].DriveLetter then begin
              E:= True;
              Break;
            end;
          end;
          if not E then begin
            //Does not exist in new list, has been removed...
            Synchronize(SYNC_OnDriveRemoved);
          end;
        end;
      end;

      //Scan for new drives...
      if Assigned(FOnDriveAdded) then begin
        for X := 0 to Length(DA)-1 do begin
          FSYNC_Drive:= DA[X];
          E:= False;
          for Y := 0 to Length(FLastDriveInfo)-1 do begin
            if FSYNC_Drive.DriveLetter = FLastDriveInfo[Y].DriveLetter then begin
              E:= True;
              Break;
            end;
          end;
          if not E then begin
            //Does not exist in the old list, has been added...
            Synchronize(SYNC_OnDriveAdded);
          end;
        end;
      end;

      //Trigger events...
      if Assigned(FOnDriveInfo) then begin
        for X := 0 to Length(DA)-1 do begin
          FSYNC_Drive:= DA[X];
          Synchronize(SYNC_OnDriveInfo);
        end;
      end;

      //Save last drive info array...
      FLastDriveInfo:= DA;

    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

procedure TJDSystemMonitorThread.RemoveAllDrives;
var
  X: Integer;
begin
  // FIX (review §3.31) - deliberately left disabled, do not just re-enable:
  // This runs from Execute's finally block while the thread is shutting
  // down. The Synchronize() below waits for the main thread to run
  // SYNC_OnDriveRemoved, but by then the main thread is blocked inside
  // WaitFor in TJDSystemMonitor.Destroy - so each thread waits for the
  // other and shutdown access-violates. TThread.Queue is not a safe swap
  // either: a queued call would only run after WaitFor returns, by which
  // time this thread object has been freed, so it would run on a dead
  // object. Until drive-removal is reworked to fire from the main thread
  // (in the component's destructor, before the thread is stopped), no
  // "drive removed" events are fired for drives still present at shutdown
  // - which is harmless, the component is going away anyway.
  Exit;

  for X := 0 to Length(FLastDriveInfo)-1 do begin
    FSYNC_Drive:= FLastDriveInfo[X];
    Synchronize(SYNC_OnDriveRemoved);
  end;
  Setlength(FLastDriveInfo, 0);
end;

procedure TJDSystemMonitorThread.SetCPUInterval(const Value: Integer);
begin
  // FIX (review §3.30): never allow an interval below 50 ms. With 0 (or a
  // negative value) ShouldReport would fire on every loop iteration, and
  // each CPU report opens every process on the system - one bad property
  // value could peg the CPU. 50 ms is also the thread's tick (see Execute).
  if Value < 50 then
    FCPUInterval := 50
  else
    FCPUInterval := Value;
end;

procedure TJDSystemMonitorThread.SetDriveInterval(const Value: Integer);
begin
  // FIX (review §3.30): same 50 ms minimum as SetCPUInterval - a 0 or
  // negative interval would make ShouldReport fire on every loop iteration.
  if Value < 50 then
    FDriveInterval := 50
  else
    FDriveInterval := Value;
end;

procedure TJDSystemMonitorThread.SetRAMInterval(const Value: Integer);
begin
  // FIX (review §3.30): same 50 ms minimum as SetCPUInterval - a 0 or
  // negative interval would make ShouldReport fire on every loop iteration.
  if Value < 50 then
    FRAMInterval := 50
  else
    FRAMInterval := Value;
end;

procedure TJDSystemMonitorThread.SYNC_OnCPUInfo;
begin
  if Assigned(FOnCPUInfo) then
    FOnCPUInfo(Self, FSYNC_CPU);
end;

procedure TJDSystemMonitorThread.SYNC_OnRAMInfo;
begin
  if Assigned(FOnRAMInfo) then
    FOnRAMInfo(Self, FSYNC_RAM);
end;

procedure TJDSystemMonitorThread.SYNC_OnDriveInfo;
begin
  if Assigned(FOnDriveInfo) then
    FOnDriveInfo(Self, FSYNC_Drive);
end;

procedure TJDSystemMonitorThread.SYNC_OnDriveAdded;
begin
  if Assigned(FOnDriveAdded) then
    FOnDriveAdded(Self, FSYNC_Drive);
end;

procedure TJDSystemMonitorThread.SYNC_OnDriveRemoved;
begin
  if Assigned(FOnDriveRemoved) then
    FOnDriveRemoved(Self, FSYNC_Drive);
end;

procedure TJDSystemMonitorThread.Execute;
begin
  CoInitialize(nil);
  // FIX (review §5): the thread no longer keeps its own process-CPU cache
  // and no longer primes one here. The shared cache lives in
  // JD.SysMon.Utils and is filled on first use by GetCPUInfo instead -
  // the very first CPU reading may be approximate because of that.
  FLastCPU:= 0;
  FLastRAM:= 0;
  FLastDrive:= 0;
  try
    while not Terminated do begin
      try
        ReportCPU;
        ReportRAM;
        ReportDrives;
      except
        on E: Exception do begin
          //TODO
        end;
      end;
      // FIX (review §3.30): was Sleep(1) - a 1000 Hz wakeup for work that
      // only happens every 50+ ms. Sleep(50) is plenty: ShouldReport only
      // fires once the full interval has passed, so reporting timing is
      // unchanged, and the smallest allowed interval is 50 ms anyway.
      Sleep(50);
    end;
  finally
    RemoveAllDrives;
    CoUninitialize;
  end;
end;

procedure TJDSystemMonitorThread.UnlockProps;
begin
  FPropLock.Leave;
end;

procedure TJDSystemMonitorThread.LockProps;
begin
  FPropLock.Enter;
end;

{ FIX (review §5): the thread's own copies of GetRunningProcessIDs,
  GetProcessCpuUsagePct, DeleteNonExistingProcessIDsFromCache and
  GetTotalCpuUsagePct used to live here. They duplicated the global
  versions in JD.SysMon.Utils almost line for line, and the thread's
  copies were effectively dead: reporting already called the Utils
  versions (via GetCPUInfo). They are deleted now - the thread just
  uses the JD.SysMon.Utils functions. }

{ TJDSystemMonitor }

constructor TJDSystemMonitor.Create(AOwner: TComponent);
begin
  inherited;
  // FIX (review §10): do not start the monitor thread at design time - it
  // would run inside the Delphi IDE and poll the system there. Note the
  // Owner check: csDesigning is not always set on the component itself yet
  // while its constructor runs, but the Owner (the form) already has it.
  // With no thread, the interval getters/setters below use the
  // FCPUInterval etc. fields, so the Object Inspector still works.
  FCPUInterval:= 300;
  FRAMInterval:= 500;
  FDriveInterval:= 5000;
  if not (csDesigning in ComponentState) and
    not ((AOwner <> nil) and (csDesigning in AOwner.ComponentState)) then
  begin
    FThread:= TJDSystemMonitorThread.Create;
    FThread.OnCPUInfo:= ThreadCPUInfo;
    FThread.OnRAMInfo:= ThreadRAMInfo;
    FThread.OnDriveInfo:= ThreadDriveInfo;
    FThread.OnDriveAdded:= ThreadDriveAdded;
    FThread.OnDriveRemoved:= ThreadDriveRemoved;
    FThread.CPUInterval:= FCPUInterval;
    FThread.RAMInterval:= FRAMInterval;
    FThread.DriveInterval:= FDriveInterval;
  end;
end;

destructor TJDSystemMonitor.Destroy;
begin
  // NOTE (review §3.33): Terminate + WaitFor has a small known deadlock
  // window - if the worker happens to be inside Synchronize at the exact
  // moment the main thread enters WaitFor, each waits for the other. In
  // practice the window is tiny and the thread only synchronizes briefly,
  // so this is accepted as-is rather than restructured. (RemoveAllDrives
  // is disabled for the related shutdown problem - see its comment.)
  // No thread exists at design time, so guard against nil here.
  if Assigned(FThread) then begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  inherited;
end;

function TJDSystemMonitor.GetCPUInterval: Integer;
begin
  // FIX (review §10): no thread exists at design time, so read the
  // component's own copy of the value instead of dereferencing nil.
  if not Assigned(FThread) then begin
    Result:= FCPUInterval;
    Exit;
  end;
  FThread.LockProps;
  try
    Result:= FThread.CPUInterval;
  finally
    FThread.UnlockProps;
  end;
end;

function TJDSystemMonitor.GetDriveInterval: Integer;
begin
  // FIX (review §10): no thread exists at design time, so read the
  // component's own copy of the value instead of dereferencing nil.
  if not Assigned(FThread) then begin
    Result:= FDriveInterval;
    Exit;
  end;
  FThread.LockProps;
  try
    Result:= FThread.DriveInterval;
  finally
    FThread.UnlockProps;
  end;
end;

function TJDSystemMonitor.GetRAMInterval: Integer;
begin
  // FIX (review §10): no thread exists at design time, so read the
  // component's own copy of the value instead of dereferencing nil.
  if not Assigned(FThread) then begin
    Result:= FRAMInterval;
    Exit;
  end;
  FThread.LockProps;
  try
    Result:= FThread.RAMInterval;
  finally
    FThread.UnlockProps;
  end;
end;

procedure TJDSystemMonitor.SetCPUInterval(const Value: Integer);
begin
  // FIX (review §3.30/§10): keep the component's own copy in step (it is
  // the only copy at design time), clamped to the same 50 ms minimum as
  // the thread's setter, then push it to the thread if there is one.
  if Value < 50 then
    FCPUInterval:= 50
  else
    FCPUInterval:= Value;
  if Assigned(FThread) then begin
    FThread.LockProps;
    try
      FThread.CPUInterval:= FCPUInterval;
    finally
      FThread.UnlockProps;
    end;
  end;
end;

procedure TJDSystemMonitor.SetDriveInterval(const Value: Integer);
begin
  // FIX (review §3.30/§10): keep the component's own copy in step (it is
  // the only copy at design time), clamped to the same 50 ms minimum as
  // the thread's setter, then push it to the thread if there is one.
  if Value < 50 then
    FDriveInterval:= 50
  else
    FDriveInterval:= Value;
  if Assigned(FThread) then begin
    FThread.LockProps;
    try
      FThread.DriveInterval:= FDriveInterval;
    finally
      FThread.UnlockProps;
    end;
  end;
end;

procedure TJDSystemMonitor.SetRAMInterval(const Value: Integer);
begin
  // FIX (review §3.30/§10): keep the component's own copy in step (it is
  // the only copy at design time), clamped to the same 50 ms minimum as
  // the thread's setter, then push it to the thread if there is one.
  if Value < 50 then
    FRAMInterval:= 50
  else
    FRAMInterval:= Value;
  if Assigned(FThread) then begin
    FThread.LockProps;
    try
      FThread.RAMInterval:= FRAMInterval;
    finally
      FThread.UnlockProps;
    end;
  end;
end;

procedure TJDSystemMonitor.ThreadCPUInfo(Sender: TObject; Info: TJDSystemMonitorCPUInfo);
begin
  if Assigned(FOnCPUInfo) then
    FOnCPUInfo(Self, Info);
end;

procedure TJDSystemMonitor.ThreadRAMInfo(Sender: TObject; Info: TJDSystemMonitorRAMInfo);
begin
  if Assigned(FOnRAMInfo) then
    FOnRAMInfo(Self, Info);
end;

procedure TJDSystemMonitor.ThreadDriveInfo(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
begin
  if Assigned(FOnDriveInfo) then
    FOnDriveInfo(Self, Info);
end;

procedure TJDSystemMonitor.ThreadDriveAdded(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
begin
  if Assigned(FOnDriveAdded) then
    FOnDriveAdded(Self, Info);
end;

procedure TJDSystemMonitor.ThreadDriveRemoved(Sender: TObject; Info: TJDSystemMonitorDriveInfo);
begin
  if Assigned(FOnDriveRemoved) then
    FOnDriveRemoved(Self, Info);
end;

end.

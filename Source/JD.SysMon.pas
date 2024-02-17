unit JD.SysMon;

interface

uses
  System.Classes, System.SysUtils, System.DateUtils, System.IOUtils,
  System.Variants, System.Generics.Collections, System.Types, System.SyncObjs,
  Winapi.PsAPI, Winapi.TlHelp32, Winapi.ShellAPI,
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
    FLatestProcessCpuUsageCache: TProcessCpuUsageList;
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
    procedure DeleteNonExistingProcessIDsFromCache(
      const RunningProcessIDs: TArray<TProcessID>);
    function GetProcessCpuUsagePct(ProcessID: TProcessID): Double;
    function GetRunningProcessIDs: TArray<TProcessID>;
    function GetTotalCpuUsagePct: Double;
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

procedure TJDSystemMonitorThread.ReportCPU;
//var
  //Interval: Integer;
begin
  try
    //if Assigned(FOnCPUInfo) then begin
      if ShouldReport(FCPUInterval, FLastCPU, Assigned(FOnCPUInfo)) then begin
        FSYNC_CPU:= GetCPUInfo;
        Synchronize(SYNC_OnCPUInfo);
      end;

      {
      LockProps;
      try
        Interval:= FCPUInterval;
      finally
        UnlockProps;
      end;
      if MilliSecondsBetween(Now, FLastCPU) >= Interval then begin
        FSYNC_CPU:= GetCPUInfo;
        FLastCPU:= Now;
        Synchronize(SYNC_OnCPUInfo);
      end;
      }
    //end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

procedure TJDSystemMonitorThread.ReportRAM;
//var
  //Interval: Integer;
begin
  try
    if ShouldReport(FRAMInterval, FLastRAM, Assigned(FOnRAMInfo)) then begin
      FSYNC_RAM:= GetRAMInfo;
      Synchronize(SYNC_OnRAMInfo);
    end;
    {
    if Assigned(FOnRAMInfo) then begin
      LockProps;
      try
        Interval:= FRAMInterval;
      finally
        UnlockProps;
      end;
      if MilliSecondsBetween(Now, FLastRAM) >= Interval then begin
        FSYNC_RAM:= GetRAMInfo;
        FLastRAM:= Now;
        Synchronize(SYNC_OnRAMInfo);
      end;
    end;
    }
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

procedure TJDSystemMonitorThread.ReportDrives;
var
  //Interval: Integer;
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


    {
    LockProps;
    try
      Interval:= FDriveInterval;
    finally
      UnlockProps;
    end;
    if MilliSecondsBetween(Now, FLastDrive) >= Interval then begin
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
    }
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
  Exit;
  //TODO: Fix access violation...

  for X := 0 to Length(FLastDriveInfo)-1 do begin
    FSYNC_Drive:= FLastDriveInfo[X];
    Synchronize(SYNC_OnDriveRemoved);
  end;
  Setlength(FLastDriveInfo, 0);
end;

procedure TJDSystemMonitorThread.SetCPUInterval(const Value: Integer);
begin
  FCPUInterval := Value;
end;

procedure TJDSystemMonitorThread.SetDriveInterval(const Value: Integer);
begin
  FDriveInterval := Value;
end;

procedure TJDSystemMonitorThread.SetRAMInterval(const Value: Integer);
begin
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
  FLatestProcessCpuUsageCache := TProcessCpuUsageList.Create( [ doOwnsValues ] );
  FLastCPU:= 0;
  FLastRAM:= 0;
  FLastDrive:= 0;
  GetTotalCpuUsagePct;
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
      Sleep(1);
    end;
  finally
    RemoveAllDrives;
    FLatestProcessCpuUsageCache.Free;
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

function TJDSystemMonitorThread.GetRunningProcessIDs: TArray<TProcessID>;
var
  SnapProcHandle: THandle;
  ProcEntry: TProcessEntry32;
  NextProc: Boolean;
begin
  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if SnapProcHandle <> INVALID_HANDLE_VALUE then
  begin
    try
      ProcEntry.dwSize := SizeOf(ProcEntry);
      NextProc := Process32First(SnapProcHandle, ProcEntry);
      while NextProc do
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := ProcEntry.th32ProcessID;
        NextProc := Process32Next(SnapProcHandle, ProcEntry);
      end;
    finally
      CloseHandle(SnapProcHandle);
    end;
    TArray.Sort<TProcessID>(Result);
  end;
end;

function TJDSystemMonitorThread.GetProcessCpuUsagePct(ProcessID: TProcessID): Double;
  function SubtractFileTime(FileTime1: TFileTIme; FileTime2: TFileTIme): TFileTIme;
  begin
    Result := TFileTIme(Int64(FileTime1) - Int64(FileTime2));
  end;
var
  ProcessCpuUsage: TProcessCpuUsage;
  ProcessHandle: THandle;
  SystemTimes: TSystemTimesRec;
  SystemDiffTimes: TSystemTimesRec;
  ProcessDiffTimes: TProcessTimesRec;
  ProcessTimes: TProcessTimesRec;
  SystemTimesIdleTime: TFileTime;
  ProcessTimesCreationTime: TFileTime;
  ProcessTimesExitTime: TFileTime;
begin
  Result := 0.0;
  FLatestProcessCpuUsageCache.TryGetValue(ProcessID, ProcessCpuUsage);
  if ProcessCpuUsage = nil then begin
    ProcessCpuUsage := TProcessCpuUsage.Create;
    FLatestProcessCpuUsageCache.Add(ProcessID, ProcessCpuUsage);
  end;
  // method from:
  // http://www.philosophicalgeek.com/2009/01/03/determine-cpu-usage-of-current-process-c-and-c/
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessID);
  if ProcessHandle <> 0 then begin
    try
      if Winapi.Windows.GetSystemTimes(SystemTimesIdleTime, SystemTimes.KernelTime, SystemTimes.UserTime) then
      begin
        SystemDiffTimes.KernelTime := SubtractFileTime(SystemTimes.KernelTime,
          ProcessCpuUsage.LastSystemTimes.KernelTime);
        SystemDiffTimes.UserTime := SubtractFileTime(SystemTimes.UserTime,
          ProcessCpuUsage.LastSystemTimes.UserTime);
        ProcessCpuUsage.LastSystemTimes := SystemTimes;
        if GetProcessTimes(ProcessHandle, ProcessTimesCreationTime,
          ProcessTimesExitTime, ProcessTimes.KernelTime, ProcessTimes.UserTime) then
        begin
          ProcessDiffTimes.KernelTime := SubtractFileTime(ProcessTimes.KernelTime,
            ProcessCpuUsage.LastProcessTimes.KernelTime);
          ProcessDiffTimes.UserTime := SubtractFileTime(ProcessTimes.UserTime,
            ProcessCpuUsage.LastProcessTimes.UserTime);
          ProcessCpuUsage.LastProcessTimes := ProcessTimes;
          if (Int64(SystemDiffTimes.KernelTime) + Int64(SystemDiffTimes.UserTime)) > 0 then
            Result := (Int64(ProcessDiffTimes.KernelTime) +
              Int64(ProcessDiffTimes.UserTime)) / (Int64(SystemDiffTimes.KernelTime) +
              Int64(SystemDiffTimes.UserTime)) * 100;
        end;
      end;
    finally
      CloseHandle(ProcessHandle);
    end;
  end;
end;

procedure TJDSystemMonitorThread.DeleteNonExistingProcessIDsFromCache(const RunningProcessIDs : TArray<TProcessID>);
var
  FoundKeyIdx: Integer;
  Keys: TArray<TProcessID>;
  n: Integer;
begin
  Keys := FLatestProcessCpuUsageCache.Keys.ToArray;
  for n := Low(Keys) to High(Keys) do begin
    if not TArray.BinarySearch<TProcessID>(RunningProcessIDs, Keys[n], FoundKeyIdx) then
      FLatestProcessCpuUsageCache.Remove(Keys[n]);
  end;
end;

function TJDSystemMonitorThread.GetTotalCpuUsagePct: Double;
var
  ProcessID: TProcessID;
  RunningProcessIDs : TArray<TProcessID>;
begin
  Result := 0.0;
  RunningProcessIDs := GetRunningProcessIDs;
  DeleteNonExistingProcessIDsFromCache(RunningProcessIDs);
  for ProcessID in RunningProcessIDs do
    Result := Result + GetProcessCpuUsagePct( ProcessID );
end;

{ TJDSystemMonitor }

constructor TJDSystemMonitor.Create(AOwner: TComponent);
begin
  inherited;
  FThread:= TJDSystemMonitorThread.Create;
  FThread.OnCPUInfo:= ThreadCPUInfo;
  FThread.OnRAMInfo:= ThreadRAMInfo;
  FThread.OnDriveInfo:= ThreadDriveInfo;
  FThread.OnDriveAdded:= ThreadDriveAdded;
  FThread.OnDriveRemoved:= ThreadDriveRemoved;
end;

destructor TJDSystemMonitor.Destroy;
begin
  FThread.Terminate;
  FThread.WaitFor;
  FreeAndNil(FThread);
  inherited;
end;

function TJDSystemMonitor.GetCPUInterval: Integer;
begin
  FThread.LockProps;
  try
    Result:= FThread.CPUInterval;
  finally
    FThread.UnlockProps;
  end;
end;

function TJDSystemMonitor.GetDriveInterval: Integer;
begin
  FThread.LockProps;
  try
    Result:= FThread.DriveInterval;
  finally
    FThread.UnlockProps;
  end;
end;

function TJDSystemMonitor.GetRAMInterval: Integer;
begin
  FThread.LockProps;
  try
    Result:= FThread.RAMInterval;
  finally
    FThread.UnlockProps;
  end;
end;

procedure TJDSystemMonitor.SetCPUInterval(const Value: Integer);
begin
  FThread.LockProps;
  try
    FThread.CPUInterval:= Value;
  finally
    FThread.UnlockProps;
  end;
end;

procedure TJDSystemMonitor.SetDriveInterval(const Value: Integer);
begin
  FThread.LockProps;
  try
    FThread.DriveInterval:= Value;
  finally
    FThread.UnlockProps;
  end;
end;

procedure TJDSystemMonitor.SetRAMInterval(const Value: Integer);
begin
  FThread.LockProps;
  try
    FThread.RAMInterval:= Value;
  finally
    FThread.UnlockProps;
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

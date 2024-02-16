unit JD.SysMon;

interface

uses
  System.Classes, System.SysUtils, System.DateUtils, System.IOUtils,
  System.Variants, System.Generics.Collections, System.Types, System.SyncObjs,
  Winapi.Windows, Winapi.ActiveX,
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
    procedure SYNC_OnCPUInfo;
    procedure SYNC_OnRAMInfo;
    procedure SYNC_OnDriveInfo;
    procedure SYNC_OnDriveAdded;
    procedure SYNC_OnDriveRemoved;
    procedure ReportCPU;
    procedure ReportRAM;
    procedure ReportDrives;
    procedure SetCPUInterval(const Value: Integer);
    procedure SetDriveInterval(const Value: Integer);
    procedure SetRAMInterval(const Value: Integer);
    procedure RemoveAllDrives;
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

procedure TJDSystemMonitorThread.ReportCPU;
var
  Interval: Integer;
begin
  try
    if Assigned(FOnCPUInfo) then begin
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
    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

procedure TJDSystemMonitorThread.ReportRAM;
var
  Interval: Integer;
begin
  try
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
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

procedure TJDSystemMonitorThread.ReportDrives;
var
  Interval: Integer;
  DA: TJDSystemMonitorDriveInfoArray;
  X, Y: Integer;
  E: Boolean;
begin
  try
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

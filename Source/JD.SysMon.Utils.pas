unit JD.SysMon.Utils;

interface

{
  Unit originally grabbed from the following Stack Overflow answer:
  https://stackoverflow.com/questions/33571061/get-the-percentage-of-total-cpu-usage

  Many changes and additions since then, including RAM, Storage, OS info, etc.

  Disk space: https://stackoverflow.com/questions/6383598/delphi-how-to-get-total-disk-space-of-windows-drive

  Strictly speaking, this itself can be encapsulated inside of a thread with
  a delay which can trigger events, similar to a timer, informing of the
  latest processer usage of the computer. It's also anticipated to break
  down the usage of each individual CPU core, instead of overall.
  The mechanism used already supports monitoring the usage of a particular
  process, so it may be optimized to only this process.
}

uses
  System.Classes, System.SysUtils, System.DateUtils, System.IOUtils,
  System.Variants, System.Generics.Collections, System.Types,
  System.SyncObjs, System.Win.Registry,
  Winapi.Windows, Winapi.PsAPI, Winapi.TlHelp32, Winapi.ShellAPI,
  Vcl.Dialogs,
  ActiveX, ComObj,
  JD.Common;

type
  TJDSystemMonitorCPUInfo = record
    ProcessCount: Integer;
    ThreadCount: Integer;
    UsagePerc: Single;
    CPUName: String;
    LogicalCores: Integer;
  end;

  TJDSystemMonitorRAMInfo = record
    SizeTotal: Int64;
    SizeUsed: Int64;
    SizeFree: Int64;
    UsagePerc: Single;
  end;

  PJDSystemMonitorDriveInfo = ^TJDSystemMonitorDriveInfo;
  TJDSystemMonitorDriveInfo = record
    DriveLetter: String;
    DriveName: String;
    DriveType: String;
    DriveIcon: HICON;
    SizeTotal: Int64;
    SizeUsed: Int64;
    SizeFree: Int64;
    UsagePerc: Single;
  end;

  TJDSystemMonitorDriveInfoArray = array of TJDSystemMonitorDriveInfo;

  TJDSystemMonitorOSInfo = record
    Caption: String;
    Vendor: String;
    Version: String;
    Build: String;
    Architecture: String;
  end;

  // NOTE (review §3.32): tuCelcius/tuFarenheit are misspelled, but they
  // are public API so they stay working. New code should use the
  // correctly spelled tuCelsius/tuFahrenheit aliases declared below
  // with the consts.
  TJDSystemMonitorTempUnit = (tuCelcius, tuFarenheit);

  TJDSystemMonitorTempInfo = record
    CPUTemp: Integer;
    PCHTemp: Integer;
    //TODO
  end;

  TJDSystemMonitorInfoPart = (ipCPU, ipRAM, ipDrives, ipOS, ipTemps);
  TJDSystemMonitorInfoParts = set of TJDSystemMonitorInfoPart;

  TJDSystemMonitorInfo = record
    Available: TJDSystemMonitorInfoParts;
    CPU: TJDSystemMonitorCPUInfo;
    RAM: TJDSystemMonitorRAMInfo;
    Drives: TJDSystemMonitorDriveInfoArray;
    OS: TJDSystemMonitorOSInfo;
    Temps: TJDSystemMonitorTempInfo;
  end;

const
  ALL_INFO_PARTS = [ipCPU, ipRAM, ipDrives, ipOS, ipTemps];

  // FIX (review §3.32): correctly spelled aliases for the misspelled
  // tuCelcius/tuFarenheit enum values. These are plain constants with the
  // same values, so old and new names are interchangeable. The old names
  // are kept (not removed) because other code may already use them.
  tuCelsius = tuCelcius;
  tuFahrenheit = tuFarenheit;

type
  TProcessID = DWORD;

  TSystemTimesRec = record
    KernelTime: TFileTime;
    UserTime: TFileTime;
  end;

  TProcessTimesRec = record
    KernelTime: TFileTime;
    UserTime: TFileTime;
  end;

  TProcessCpuUsage = class
    LastSystemTimes: TSystemTimesRec;
    LastProcessTimes: TProcessTimesRec;
    ProcessCPUusagePercentage: Double;
  end;

  TProcessCpuUsageList = TObjectDictionary<TProcessID, TProcessCpuUsage>;


type
  // FIX (review §3.32): jdTeraBytes/jdPetaBytes added so multi-TB drives
  // stop displaying as e.g. "1,862.0 GB". They are appended at the end so
  // the existing values keep their ordinals.
  TJDDataScale = (jdAuto, jdBytes, jdKiloBytes, jdMegaBytes, jdGigaBytes,
    jdTeraBytes, jdPetaBytes);



///  <summary>
///  Returns a string representing a given amount of data.
///  </summary>
function DataSizeStr(const AVal: Int64; const AScale: TJDDataScale = jdAuto): String;

///  <summary>
///  Returns an array of available drives on the system.
///  </summary>
function GetDrives: TStringDynArray;

///  <summary>
///    Returns the current percentage of usage of the computer's processor(s).
///  </summary>
function GetTotalCpuUsagePct: Double;

///  <summary>
///    Returns the current percentage of usage of the computer's memory.
///  </summary>
function GetTotalRamUsagePct: Single;

///  <summary>
///    Returns the current percentage of space used on a disk.
///  </summary>
function GetDriveSpaceUsedPct(const Drive: Integer): Single;

///  <summary>
///  Returns information about the current CPU state.
///  </summary>
function GetCPUInfo: TJDSystemMonitorCPUInfo;

///  <summary>
///  Returns information about the current RAM state.
///  </summary>
function GetRAMInfo: TJDSystemMonitorRAMInfo;

///  <summary>
///  Returns information about the current state of a drive by its letter.
///  </summary>
function GetDriveInfo(const Ltr: String): TJDSystemMonitorDriveInfo;

///  <summary>
///  Returns information about all drives by their drive letter.
///  </summary>
function GetAllDriveInfo: TJDSystemMonitorDriveInfoArray;

///  <summary>
///  Returns information about the operation system.
///  </summary>
function GetOSInfo: TJDSystemMonitorOSInfo;

///  <summary>
///  Returns information about current system temperatures.
///  </summary>
function GetTempInfo: TJDSystemMonitorTempInfo;

///  <summary>
///
///  </summary>
function GetSysInfo(const AParts: TJDSystemMonitorInfoParts = ALL_INFO_PARTS): TJDSystemMonitorInfo;


implementation


function DataSizeStr(const AVal: Int64; const AScale: TJDDataScale = jdAuto): String;
const
  NUM_FORMAT = '#,##0.0';
  JD_FACTOR = 1024;
  JD_KILOBYTE = JD_FACTOR;
  JD_MEGABYTE = JD_FACTOR * JD_KILOBYTE;
  JD_GIGABYTE = JD_FACTOR * JD_MEGABYTE;
  // FIX (review §3.32): TB and PB need Int64 math - a plain
  // JD_FACTOR * JD_GIGABYTE overflows a 32-bit Integer. Casting the 1024
  // to Int64 first makes the whole multiply 64-bit.
  // (https://stackoverflow.com/questions/10302910/how-to-declare-an-int64-constant)
  JD_TERABYTE = Int64(JD_FACTOR) * JD_GIGABYTE;
  JD_PETABYTE = Int64(JD_FACTOR) * JD_TERABYTE;
begin
  if AScale = jdAuto then begin
    if AVal < JD_KILOBYTE then begin
      Result:= FormatFloat(NUM_FORMAT, AVal) + ' B';
    end else
    if AVal < JD_MEGABYTE then begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_KILOBYTE)) + ' KB';
    end else
    if AVal < JD_GIGABYTE then begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_MEGABYTE)) + ' MB';
    end else
    // FIX (review §3.32): TB/PB ranges added - before this, anything over
    // 1 TB just showed as a huge number of GB.
    if AVal < JD_TERABYTE then begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_GIGABYTE)) + ' GB';
    end else
    if AVal < JD_PETABYTE then begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_TERABYTE)) + ' TB';
    end else begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_PETABYTE)) + ' PB';
    end;
  end else begin
    case AScale of
      jdBytes: begin
        Result:= FormatFloat(NUM_FORMAT, AVal) + ' B';
      end;
      jdKiloBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_KILOBYTE)) + ' KB';
      end;
      jdMegaBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_MEGABYTE)) + ' MB';
      end;
      jdGigaBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_GIGABYTE)) + ' GB';
      end;
      // FIX (review §3.32): TB/PB branches, uncommented now that the
      // JD_TERABYTE/JD_PETABYTE constants exist (see above).
      jdTeraBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_TERABYTE)) + ' TB';
      end;
      jdPetaBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_PETABYTE)) + ' PB';
      end;
    end;
  end;
end;



//Disk Usage

function GetDrives: TStringDynArray;
begin
  Result:= System.IOUtils.TDirectory.GetLogicalDrives;
end;

function GetDriveCount: Integer;
begin
  Result:= Length(GetDrives);
end;

function GetDriveCapacity(const Drive: Integer): Int64;
begin
  Result:= DiskSize(Drive);
end;

function GetDriveSpaceFree(const Drive: Integer): Int64;
begin
  Result:= DiskFree(Drive);
end;

function GetDriveSpaceUsed(const Drive: Integer): Int64;
begin
  Result:= GetDriveCapacity(Drive) - GetDriveSpaceFree(Drive);
end;

function GetDriveSpaceUsedPct(const Drive: Integer): Single;
var
  U, C: Int64;
begin
  try
    U:= GetDriveSpaceUsed(Drive);
    C:= GetDriveCapacity(Drive);
    Result:= (U / C) * 100;
  except
    Result:= -1;
  end;
end;

function GetDriveInfo(const Ltr: String): TJDSystemMonitorDriveInfo;
var
  FreeAvailable, TotalSpace: Int64;
  FI: TSHFileInfo;
  Res: DWORD_PTR;
begin
  Result.DriveLetter:= Ltr;
  Result.DriveName:= '';
  Result.DriveType:= '';
  Result.DriveIcon:= 0;
  Result.SizeTotal:= 0;
  Result.SizeUsed:= 0;
  Result.SizeFree:= 0;
  Result.UsagePerc:= 0;

  //Docs: https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shgetfileinfoa
  //Related: https://stackoverflow.com/questions/21885962/delphi-calling-shgetfileinfo-from-a-thread-fails
  Res:= SHGetFileInfo(PChar(Ltr+':\'), 0, FI, SizeOf(FI), SHGFI_DISPLAYNAME or SHGFI_TYPENAME);
  if Res <> 0 then begin
    Result.DriveName:= FI.szDisplayName;
    Result.DriveType:= FI.szTypeName;
  end;

  //NOTE: DO NOT use version in WinAPI unit, signature is incorrect!
  if System.SysUtils.GetDiskFreeSpaceEx(PChar(Ltr+':\'), FreeAvailable, TotalSpace, nil) then begin
    Result.SizeTotal:= TotalSpace;
    Result.SizeFree:= FreeAvailable;
    Result.SizeUsed:= TotalSpace - FreeAvailable;
    Result.UsagePerc:= (Result.SizeUsed / Result.SizeTotal) * 100;
  end;

end;

function GetAllDriveInfo: TJDSystemMonitorDriveInfoArray;
var
  A: TStringDynArray;
  X: Integer;
  Ltr: String;
begin
  A:= GetDrives;
  SetLength(Result, Length(A));
  for X := 0 to Length(A)-1 do begin
    Ltr:= A[X][1];
    Result[X]:= GetDriveInfo(Ltr);
  end;
end;


//CPU Usage

var
  LatestProcessCpuUsageCache : TProcessCpuUsageList;
  // FIX (review §3.32): one lock guarding the cache above AND the CPU
  // name/core cache below. GetCPUInfo can be called from the monitor
  // thread and from the main thread (an app calling it directly), and
  // TObjectDictionary is not thread-safe. Created in initialization,
  // freed in finalization. The code is arranged so the lock is never
  // taken twice on the same call path (see GetCPUInfo).
  ProcessCpuUsageCacheLock: TCriticalSection;
  // FIX (review §3.31): the CPU name and core count never change while
  // Windows is running, so read them from the registry once and keep them
  // here instead of re-reading on every GetCPUInfo call (every 300 ms).
  CachedCPUName: String;
  CachedLogicalCores: Integer;
  CPUInfoCached: Boolean;
  // FIX (review §3.32): remembers whether the CoInitialize in
  // initialization actually succeeded - finalization must only call
  // CoUninitialize if it did, or COM's init count gets unbalanced.
  SysMonCoInitialized: Boolean;

function GetRunningProcessIDs: TArray<TProcessID>;
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

function GetProcessCpuUsagePct(ProcessID: TProcessID): Double;
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
  LatestProcessCpuUsageCache.TryGetValue(ProcessID, ProcessCpuUsage);
  if ProcessCpuUsage = nil then begin
    ProcessCpuUsage := TProcessCpuUsage.Create;
    LatestProcessCpuUsageCache.Add(ProcessID, ProcessCpuUsage);
  end;
  // method from:
  // http://www.philosophicalgeek.com/2009/01/03/determine-cpu-usage-of-current-process-c-and-c/
  // FIX (review §3.31): was PROCESS_QUERY_INFORMATION or PROCESS_VM_READ.
  // GetProcessTimes only needs PROCESS_QUERY_INFORMATION - asking for
  // PROCESS_VM_READ as well makes OpenProcess fail on protected/elevated
  // processes, which then get silently skipped and the total undercounts.
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, ProcessID);
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

procedure DeleteNonExistingProcessIDsFromCache(const RunningProcessIDs : TArray<TProcessID>);
var
  FoundKeyIdx: Integer;
  Keys: TArray<TProcessID>;
  n: Integer;
begin
  Keys := LatestProcessCpuUsageCache.Keys.ToArray;
  for n := Low(Keys) to High(Keys) do begin
    if not TArray.BinarySearch<TProcessID>(RunningProcessIDs, Keys[n], FoundKeyIdx) then
      LatestProcessCpuUsageCache.Remove(Keys[n]);
  end;
end;

function GetTotalCpuUsagePct: Double;
var
  ProcessID: TProcessID;
  RunningProcessIDs : TArray<TProcessID>;
begin
  // FIX (review §3.32): the whole measurement runs under the cache lock.
  // GetProcessCpuUsagePct and DeleteNonExistingProcessIDsFromCache are
  // only called from here (they are not in the interface section), so one
  // lock here covers every read/write of LatestProcessCpuUsageCache, and
  // GetCPUInfo is covered too because it calls this function.
  // NOTE: the first call primes the cache baselines (they start at zero),
  // so the very first sample may be approximate - that is expected, the
  // eager priming call that used to run in initialization is gone (it
  // opened every process at unit-load time for any app using this unit).
  ProcessCpuUsageCacheLock.Enter;
  try
    Result := 0.0;
    RunningProcessIDs := GetRunningProcessIDs;
    DeleteNonExistingProcessIDsFromCache(RunningProcessIDs);
    for ProcessID in RunningProcessIDs do
      Result := Result + GetProcessCpuUsagePct( ProcessID );
  finally
    ProcessCpuUsageCacheLock.Leave;
  end;
end;

function GetCPUInfo: TJDSystemMonitorCPUInfo;
var
  R: TRegistry;
  K: String;
  L: TStringList;
begin
  Result.ProcessCount:= 0; //TODO
  Result.ThreadCount:= 0; //TODO
  // NOTE: this runs first, before the lock below is taken, so the cache
  // lock is never held twice on one call path (GetTotalCpuUsagePct takes
  // the same lock internally).
  Result.UsagePerc:= GetTotalCpuUsagePct;
  // FIX (review §3.31): the CPU name and core count are read from the
  // registry once and cached in CachedCPUName/CachedLogicalCores - they
  // never change while Windows is running, so re-reading them on every
  // call (every 300 ms) was wasted work.
  ProcessCpuUsageCacheLock.Enter;
  try
    if not CPUInfoCached then begin
      CachedCPUName:= '';
      CachedLogicalCores:= 0;
      R:= TRegistry.Create(KEY_READ);
      try
        R.RootKey:= HKEY_LOCAL_MACHINE;
        K:= 'HARDWARE\DESCRIPTION\System\CentralProcessor\0';
        if R.KeyExists(K) then begin
          if R.OpenKey(K, False) then begin
            try
              if R.ValueExists('ProcessorNameString') then begin
                CachedCPUName:= R.ReadString('ProcessorNameString');
              end;
            finally
              R.CloseKey;
            end;
          end;
        end;
        K:= 'HARDWARE\DESCRIPTION\System\CentralProcessor';
        if R.KeyExists(K) then begin
          if R.OpenKey(K, False) then begin
            try
              L:= TStringList.Create;
              try
                R.GetKeyNames(L);
                CachedLogicalCores:= L.Count;
              finally
                L.Free;
              end;
            finally
              R.CloseKey;
            end;
          end;
        end;
      finally
        R.Free;
      end;
      CPUInfoCached:= True;
    end;
    Result.CPUName:= CachedCPUName;
    Result.LogicalCores:= CachedLogicalCores;
  finally
    ProcessCpuUsageCacheLock.Leave;
  end;
end;


//RAM Usage

function GetTotalRamUsagePct: Single;
var
  MS_Ex : MemoryStatusEx;
begin
  Result:= 0.0;
  FillChar(MS_Ex, SizeOf(MemoryStatusEx), #0);
  MS_Ex.dwLength:= SizeOf(MemoryStatusEx);
  if GlobalMemoryStatusEx(MS_Ex) then
    Result:= MS_Ex.dwMemoryLoad;
end;

function GetRAMInfo: TJDSystemMonitorRAMInfo;
var
  MS_Ex : MemoryStatusEx;
begin
  // FIX (review §3.32): zero the result first. If GlobalMemoryStatusEx
  // fails below, the fields were never assigned and the caller got
  // garbage. Now a failure returns zeros. (FillChar is safe here because
  // this record holds only numbers, no strings.)
  FillChar(Result, SizeOf(Result), 0);
  FillChar(MS_Ex, SizeOf(MemoryStatusEx), #0);
  MS_Ex.dwLength:= SizeOf(MemoryStatusEx);
  if GlobalMemoryStatusEx(MS_Ex) then begin
    Result.SizeTotal:= MS_Ex.ullTotalPhys;
    Result.SizeFree:= MS_Ex.ullAvailPhys;
    Result.SizeUsed:= Result.SizeTotal - Result.SizeFree;
    Result.UsagePerc:= (Result.SizeUsed / Result.SizeTotal) * 100;
  end;
end;


//OS Info

function GetOSInfo: TJDSystemMonitorOSInfo;
var
  A: TOSVersion.TArchitecture;
begin
  // FIX (review §3.32): same uninitialized-result problem as GetSysInfo -
  // Vendor and Build were never assigned at all, and Architecture was
  // only set by the case below. Default them first so a caller never
  // reads garbage.
  Result.Vendor:= '';
  Result.Build:= '';
  Result.Architecture:= '';
  Result.Caption:= TOSVersion.ToString;
  Result.Version:= IntToStr(TOSVersion.Major);
  A:= TOSVersion.Architecture;
  case A of
    arIntelX86: Result.Architecture:= 'Intel 32bit';
    arIntelX64: Result.Architecture:= 'Intel 64bit';
    arARM32:    Result.Architecture:= 'ARM 32bit';
    arARM64:    Result.Architecture:= 'ARM 64bit';
  end;

  //TODO


end;


//Temperature Info

function GetTempInfo: TJDSystemMonitorTempInfo;
begin
  //TODO: still a stub - no real temperature reading yet.
  // FIX (review §3.32): PCHTemp was never assigned at all, so callers got
  // garbage for it. Both fields are zeroed now so the stub is complete.
  Result.CPUTemp:= 0;
  Result.PCHTemp:= 0;
end;


//All System Info

function GetSysInfo(const AParts: TJDSystemMonitorInfoParts = ALL_INFO_PARTS): TJDSystemMonitorInfo;
begin
  // FIX (review §3.32): initialize every part to a safe default first,
  // even parts the caller did not ask for. Before this, any part not in
  // AParts was left uninitialized and the caller got garbage numbers.
  // (No FillChar here - this record holds strings and a dynamic array,
  // which must not be zeroed that way - so each field is set out.)
  Result.Available:= AParts;
  Result.CPU.ProcessCount:= 0;
  Result.CPU.ThreadCount:= 0;
  Result.CPU.UsagePerc:= 0;
  Result.CPU.CPUName:= '';
  Result.CPU.LogicalCores:= 0;
  Result.RAM.SizeTotal:= 0;
  Result.RAM.SizeUsed:= 0;
  Result.RAM.SizeFree:= 0;
  Result.RAM.UsagePerc:= 0;
  SetLength(Result.Drives, 0);
  Result.OS.Caption:= '';
  Result.OS.Vendor:= '';
  Result.OS.Version:= '';
  Result.OS.Build:= '';
  Result.OS.Architecture:= '';
  Result.Temps.CPUTemp:= 0;
  Result.Temps.PCHTemp:= 0;
  if ipCPU in AParts then
    Result.CPU:= GetCPUInfo;
  if ipRAM in AParts then
    Result.RAM:= GetRAMInfo;
  if ipDrives in AParts then
    Result.Drives:= GetAllDriveInfo;
  if ipOS in AParts then
    Result.OS:= GetOSInfo;
  if ipTemps in AParts then
    Result.Temps:= GetTempInfo;
end;




initialization
  // FIX (review §3.32): remember whether CoInitialize actually worked.
  // If the app already initialized COM a different way this call fails,
  // and calling CoUninitialize anyway in finalization would unbalance
  // COM's init count. Succeeded() covers S_FALSE too (already initialized
  // on this thread still needs a matching CoUninitialize).
  SysMonCoInitialized:= Succeeded(CoInitialize(nil));
  ProcessCpuUsageCacheLock:= TCriticalSection.Create;
  LatestProcessCpuUsageCache := TProcessCpuUsageList.Create( [ doOwnsValues ] );
  // NOTE: the eager GetTotalCpuUsagePct call that used to run here is
  // gone on purpose - it opened every process on the system at unit-load
  // time, so any app that merely used this unit paid that startup cost.
  // The cache is primed lazily on the first GetCPUInfo / GetTotalCpuUsagePct
  // call instead; that first sample may be approximate.
finalization
  LatestProcessCpuUsageCache.Free;
  ProcessCpuUsageCacheLock.Free;
  if SysMonCoInitialized then
    CoUninitialize;
end.

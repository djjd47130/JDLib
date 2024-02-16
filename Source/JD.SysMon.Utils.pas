unit JD.SysMon.Utils;

interface

{
  Unit originally grabbed from the following Stack Overflow answer:
  https://stackoverflow.com/questions/33571061/get-the-percentage-of-total-cpu-usage

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
  System.Win.Registry,
  Winapi.Windows, Winapi.PsAPI, Winapi.TlHelp32, Winapi.ShellAPI,
  Vcl.Dialogs,
  ActiveX, ComObj,
  JD.Common;

type
  TProcessID = DWORD;

  TSystemTimesRec = record
    KernelTime: TFileTIme;
    UserTime: TFileTIme;
  end;

  TProcessTimesRec = record
    KernelTime: TFileTIme;
    UserTime: TFileTIme;
  end;

  TProcessCpuUsage = class
    LastSystemTimes: TSystemTimesRec;
    LastProcessTimes: TProcessTimesRec;
    ProcessCPUusagePercentage: Double;
  end;

  TProcessCpuUsageList = TObjectDictionary<TProcessID, TProcessCpuUsage>;

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

  TJDSystemMonitorTempUnit = (tuCelcius, tuFarenheit);

  TJDSystemMonitorTempInfo = record
    CPUTemp: Integer;
    PCHTemp: Integer;
    //TODO
  end;

  TJDSystemMonitorInfo = record
    CPU: TJDSystemMonitorCPUInfo;
    RAM: TJDSystemMonitorRAMInfo;
    Drives: TJDSystemMonitorDriveInfoArray;
    OS: TJDSystemMonitorOSInfo;
    Temps: TJDSystemMonitorTempInfo;
  end;


type
  TJDDataScale = (jdAuto, jdBytes, jdKiloBytes, jdMegaBytes, jdGigaBytes
    //TODO
    //, jdTeraBytes, jdPetaBytes
    );



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
function GetSysInfo: TJDSystemMonitorInfo;


implementation


function DataSizeStr(const AVal: Int64; const AScale: TJDDataScale = jdAuto): String;
const
  NUM_FORMAT = '#,##0.0';
  JD_FACTOR = 1024;
  JD_KILOBYTE = JD_FACTOR;
  JD_MEGABYTE = JD_FACTOR * JD_KILOBYTE;
  JD_GIGABYTE = JD_FACTOR * JD_MEGABYTE;
  //TODO: https://stackoverflow.com/questions/10302910/how-to-declare-an-int64-constant
  //JD_TERABYTE = JD_FACTOR * JD_GIGABYTE;
  //JD_PETABYTE = JD_FACTOR * JD_TERABYTE;
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
    end else begin
      Result:= FormatFloat(NUM_FORMAT, (AVal / JD_GIGABYTE)) + ' GB';
      //TODO
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
      {
      //TODO
      jdTeraBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_TERABYTE)) + ' TB';
      end;
      jdPetaBytes: begin
        Result:= FormatFloat(NUM_FORMAT, (AVal / JD_PETABYTE)) + ' PB';
      end;
      }
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
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessID);
  if ProcessHandle <> 0 then begin
    try
      if GetSystemTimes(SystemTimesIdleTime, SystemTimes.KernelTime, SystemTimes.UserTime) then
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
  Result := 0.0;
  RunningProcessIDs := GetRunningProcessIDs;
  DeleteNonExistingProcessIDsFromCache(RunningProcessIDs);
  for ProcessID in RunningProcessIDs do
    Result := Result + GetProcessCpuUsagePct( ProcessID );
end;

function GetCPUInfo: TJDSystemMonitorCPUInfo;
var
  R: TRegistry;
  K: String;
  L: TStringList;
begin
  Result.ProcessCount:= 0; //TODO
  Result.ThreadCount:= 0; //TODO
  Result.UsagePerc:= GetTotalCpuUsagePct;
  Result.CPUName:= '';
  Result.LogicalCores:= 0;
  R:= TRegistry.Create(KEY_READ);
  try
    R.RootKey:= HKEY_LOCAL_MACHINE;
    K:= 'HARDWARE\DESCRIPTION\System\CentralProcessor\0';
    if R.KeyExists(K) then begin
      if R.OpenKey(K, False) then begin
        try
          if R.ValueExists('ProcessorNameString') then begin
            Result.CPUName:= R.ReadString('ProcessorNameString');
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
            Result.LogicalCores:= L.Count;
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
  //TODO
  Result.CPUTemp:= 0;

end;


//All System Info

function GetSysInfo: TJDSystemMonitorInfo;
begin
  Result.CPU:= GetCPUInfo;
  Result.RAM:= GetRAMInfo;
  Result.Drives:= GetAllDriveInfo;
  Result.OS:= GetOSInfo;
  Result.Temps:= GetTempInfo;
end;




initialization
  CoInitialize(nil);
  LatestProcessCpuUsageCache := TProcessCpuUsageList.Create( [ doOwnsValues ] );
  GetTotalCpuUsagePct;
finalization
  LatestProcessCpuUsageCache.Free;
  CoUninitialize;
end.

unit JD.Logs;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.SyncObjs,
  System.TypInfo, System.StrUtils;

type
  /// <summary>
  /// Defines the severity level of a log entry.
  /// </summary>
  TJDLogLevel = (
    /// <summary>Critical error messages.</summary>
    llCritical,
    /// <summary>Error messages.</summary>
    llError,
    /// <summary>Warning messages.</summary>
    llWarning,
    /// <summary>Informational messages.</summary>
    llInformation,
    /// <summary>Verbose (debug) messages.</summary>
    llVerbose
  );

  /// <summary>
  /// Set of log levels for filtering.
  /// </summary>
  TJDLogLevels = set of TJDLogLevel;

const
  JD_LOG_FILE_FORMAT_MARKER = 'JDLG';
  JD_LOG_FILE_VERSION = 1.0;
  JD_LOG_DEFAULT_LEVELS = [llCritical, llError, llWarning, llInformation];
  JD_LOG_DEFAULT_CATEGORY = 'General';
  JD_LOG_FILE_READONLY_DEFAULT = False;
  JD_LOG_QUEUE_SIZE = 100;
  // FIX (§3.9): this was 0, so the worker thread looped PumpLogs/FlushLoggers
  // with only Sleep(0) between passes - Sleep(0) just yields, so the thread
  // spun as fast as it could and pinned a whole CPU core. 10 ms is still
  // plenty fast for a logger and drops the idle cost to almost nothing.
  JD_LOG_THREAD_SLEEP_MS = 10;
  // FIX (§3.11): how long PostLog waits for room in the queue before giving up
  // and dropping the entry instead of blocking the calling thread forever.
  JD_LOG_PUSH_TIMEOUT_MS = 100;
  // FIX (§3.12): max number of entries kept in the in-memory history list
  // (FLog). It used to grow forever - every log entry ever posted stayed in
  // memory for the whole life of the app. Oldest entries are now dropped.
  JD_LOG_MAX_HISTORY = 10000;
  JD_LOG_FILE_HEADER_SIZE = 256;

type
  TJDLogItem = class;
  TJDLog = class;
  TJDLogger = class;
  TJDFileLogger = class;

  /// <summary>
  /// Event type triggered when a log entry is processed.
  /// NOTE: this fires on the logging engine's WORKER thread, not the main
  /// thread. A handler must not touch the UI (or any other VCL control)
  /// directly - use TThread.Queue/TThread.Synchronize, or set the logger's
  /// SynchronizedEvents property to True to have OnLog delivered on the
  /// main thread instead.
  /// </summary>
  TJDLogEvent = procedure(Sender: TObject; Item: TJDLogItem) of object;

  /// <summary>
  /// Represents a single log entry.
  /// </summary>
  TJDLogItem = class(TObject)
  private
    FLevel: TJDLogLevel;
    FMsg: string;
    FTimestamp: TDateTime;
    FCategory: string;
    FTags: TStringList;
    procedure SetLevel(const Value: TJDLogLevel);
    procedure SetMsg(const Value: string);
    procedure SetTimestamp(const Value: TDateTime);
    function GetTags: TStrings;
    procedure SetTags(const Value: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    property Level: TJDLogLevel read FLevel write SetLevel;
    property Timestamp: TDateTime read FTimestamp write SetTimestamp;
    property Msg: string read FMsg write SetMsg;
    property Category: string read FCategory write FCategory;
    property Tags: TStrings read GetTags write SetTags;
    function ToSingleLineString: string;
    procedure FromSingleLineString(const ALine: string);
  end;

  /// <summary>
  /// A list of log entries.
  /// </summary>
  TJDLogItemList = TObjectList<TJDLogItem>;

  /// <summary>
  /// Global logging engine which processes log entries and dispatches them
  /// to registered logger components. It also instructs each registered logger
  /// to flush its internal buffers periodically.
  /// </summary>
  TJDLog = class(TThread)
  private
    FLog: TJDLogItemList;
    FLoggers: TObjectList<TJDLogger>;
    FLock: TCriticalSection;
    // FIX (§3.13): FLoggers used to be touched with no lock at all - the main
    // thread adds/removes loggers while the worker thread iterates the list,
    // so destroying a logger at the wrong moment was an access violation.
    // This lock guards RegisterLogger/UnregisterLogger, and DoOnLog/
    // FlushLoggers take a snapshot copy under it (see those methods).
    FLoggersLock: TCriticalSection;
    FLogQueue: TThreadedQueue<TJDLogItem>;
    // FIX (§3.11): how many log entries were dropped because the queue stayed
    // full past the push timeout. Read it through DroppedCount.
    FDroppedCount: Integer;
    procedure PumpLogs;
  protected
    procedure DoOnLog(Item: TJDLogItem); virtual;
    procedure Execute; override;
    procedure FlushLoggers; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// How many log entries were dropped because the queue stayed full past
    /// the push timeout (see JD_LOG_PUSH_TIMEOUT_MS). A rising number means
    /// the loggers can't keep up with the rate of logging.
    /// </summary>
    property DroppedCount: Integer read FDroppedCount;
    function LockLog: TJDLogItemList;
    procedure UnlockLog;
    procedure RegisterLogger(ALogger: TJDLogger);
    procedure UnregisterLogger(ALogger: TJDLogger);

    function PostLog(const ALevel: TJDLogLevel; const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
    function PostLogCritical(const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
    function PostLogError(const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
    function PostLogWarning(const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
    function PostLogInformation(const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
    function PostLogVerbose(const AMsg: string;
      ACategory: string = JD_LOG_DEFAULT_CATEGORY; ATags: TArray<string> = []): TJDLogItem;
  end;

////////////////////////////////////////////////////////////////////////////////
/// Loggers
////////////////////////////////////////////////////////////////////////////////

  /// <summary>
  /// Base logger component that receives dispatched log entries.
  /// Provides virtual methods DoLog (for processing a log entry) and DoFlush
  /// (for flushing internal buffers) so that descendant classes can implement
  /// custom handling logic.
  /// Use OnLog event to capture incoming logs on a basic level.
  /// NOTE: DoLog and OnLog run on the logging engine's worker thread, not the
  /// main thread - see the OnLog property (and SynchronizedEvents) for details.
  /// </summary>
  TJDLogger = class(TComponent)
  private
    FLogLevels: TJDLogLevels;
    FOnLog: TJDLogEvent;
    // FIX (§3.13): when True, OnLog is delivered on the main thread via
    // TThread.Queue instead of on the logging worker thread. Default False
    // keeps the old behaviour (faster, but the handler must not touch the UI).
    FSynchronizedEvents: Boolean;
    procedure SetLogLevels(const Value: TJDLogLevels);
    function IsLogLevelsStored: Boolean;
  protected
    procedure HandleLogItem(Item: TJDLogItem);
    procedure DoLog(Item: TJDLogItem); virtual;
    procedure DoFlush; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property LogLevels: TJDLogLevels read FLogLevels write SetLogLevels
      stored IsLogLevelsStored default JD_LOG_DEFAULT_LEVELS;

    /// <summary>
    /// Fires for each log entry this logger accepts. WARNING: by default this
    /// fires on the logging engine's worker thread, so a handler must NOT
    /// touch the UI directly. Set SynchronizedEvents to True to have it
    /// delivered on the main thread instead.
    /// </summary>
    property OnLog: TJDLogEvent read FOnLog write FOnLog;

    /// <summary>
    /// When True, OnLog is delivered on the main thread (via TThread.Queue),
    /// so handlers may safely touch the UI. When False (default), OnLog fires
    /// on the worker thread and handlers must not touch the UI.
    /// NOTE: the logger and the handler's owning object must outlive delivery
    /// - don't free a form/component that handles OnLog while queued events
    /// may still be pending for it.
    /// </summary>
    property SynchronizedEvents: Boolean read FSynchronizedEvents write FSynchronizedEvents default False;
  end;

  /// <summary>
  /// File header structure for the log file.
  /// Contains a 4 byte format marker, a version number, a total entry count,
  /// and padding to reach 256 bytes.
  /// </summary>
  TJDLogFileHeader = packed record
    Format: array[0..3] of AnsiChar;
    Version: Single;
    Count: Int64;
    Padding: array[0..239] of Byte;
  end;

  /// <summary>
  /// Logger component that writes log entries to a file.
  /// It buffers new entries in a TStringList (with its own critical section)
  /// and maintains a cache of logs. The file is updated with a header (of type
  /// TJDLogFileHeader) and plain text log lines. The Active property triggers
  /// file open/close; new logs are buffered if not in ReadOnly mode.
  /// </summary>
  TJDFileLogger = class(TJDLogger)
  private
    FActive: Boolean;
    FHeader: TJDLogFileHeader;
    FReadOnly: Boolean;
    FFileName: TFileName;
    FFileStream: TFileStream;
    FFileLock: TCriticalSection;
    FBuffer: TStringList;
    FBufferLock: TCriticalSection;
    procedure OpenFile;
    procedure CloseFile;
    procedure FlushBuffer;
    procedure SetActive(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetFileName(const Value: TFileName);
  protected
    procedure DoLog(Item: TJDLogItem); override;
    procedure DoFlush; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Count: Integer;
    function GetItemStr(const Index: Integer): String;
    function GetItem(const Index: Integer; var Item: TJDLogItem): Boolean;

  published
    property Active: Boolean read FActive write SetActive;
    property FileName: TFileName read FFileName write SetFileName;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly
      default JD_LOG_FILE_READONLY_DEFAULT;
  end;

  /// <summary>
  /// Logger component that writes log entries to a console window.
  /// </summary>
  TJDConsoleLogger = class(TJDLogger)
  protected
    procedure DoLog(Item: TJDLogItem); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

/// <summary>
/// Returns the global logging engine instance.
/// Returns nil after unit finalization (during shutdown) - callers must check.
/// </summary>
function JDLog: TJDLog;

implementation

var
  _JDLog: TJDLog;
  // FIX (§3.13): guards the lazy creation of the global engine below. Without
  // a lock, two threads calling JDLog() at the same time could each create an
  // engine - one would leak, along with its worker thread. Created in
  // initialization, freed in finalization.
  _JDLogLock: TCriticalSection;
  // FIX (§3.13): set to True in finalization, before the engine is freed.
  // After that point JDLog() returns nil instead of creating a brand-new
  // logging thread during shutdown (which would never be freed). A TJDLogger
  // destroyed after finalization must cope with a nil engine - see
  // TJDLogger.Create/Destroy.
  _JDLogFinalized: Boolean;

function JDLog: TJDLog;
begin
  // Already shutting down - don't create a new engine, just report none.
  // (This check also runs before touching _JDLogLock, so it is safe even
  // after finalization has freed the lock.)
  if _JDLogFinalized then
    Exit(nil);
  // Double-checked locking: the fast path (engine already exists) needs no
  // lock; only creation takes the lock, and re-checks inside it.
  if _JDLog = nil then
  begin
    _JDLogLock.Enter;
    try
      if (_JDLog = nil) and (not _JDLogFinalized) then
        _JDLog := TJDLog.Create;
    finally
      _JDLogLock.Leave;
    end;
  end;
  Result := _JDLog;
end;

{ TJDLogItem }

constructor TJDLogItem.Create;
begin
  inherited Create;
  FTimestamp := Now;
  FCategory := '';
  FTags := TStringList.Create;
end;

destructor TJDLogItem.Destroy;
begin
  FTags.Free;
  inherited;
end;

procedure TJDLogItem.SetLevel(const Value: TJDLogLevel);
begin
  FLevel := Value;
end;

procedure TJDLogItem.SetMsg(const Value: string);
begin
  FMsg := Value;
end;

procedure TJDLogItem.SetTimestamp(const Value: TDateTime);
begin
  FTimestamp := Value;
end;

function TJDLogItem.GetTags: TStrings;
begin
  Result := FTags;
end;

procedure TJDLogItem.SetTags(const Value: TStrings);
begin
  FTags.Assign(Value);
end;

function TJDLogItem.ToSingleLineString: string;
var
  sDate, sLevel, sTags: string;
begin
  sDate := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', FTimestamp);
  sLevel := GetEnumName(TypeInfo(TJDLogLevel), Ord(FLevel));
  if (Length(sLevel) > 2) and (Copy(sLevel, 1, 2) = 'll') then
    Delete(sLevel, 1, 2);
  sTags := FTags.CommaText; // Tags concatenated with commas
  // Output format: Date|Level|Category|Msg|Tags
  // FIX (§3.40): the format is pipe-delimited with no escaping, so a '|'
  // inside a message or category used to shift every field after it and
  // FromSingleLineString would misparse the line (or raise). '|' is now
  // written out as '/' in the message and category fields, so a line can
  // never gain extra fields. (Tags are the last field, so a '|' there is
  // harmless - it has nothing after it to shift.)
  Result := sDate + '|' + sLevel + '|' +
    StringReplace(FCategory, '|', '/', [rfReplaceAll]) + '|' +
    StringReplace(FMsg, '|', '/', [rfReplaceAll]) + '|' + sTags;
end;

procedure TJDLogItem.FromSingleLineString(const ALine: string);
var
  p1, p2, p3, p4: Integer;
  sDate, sLevel, sCategory, sMsg, sTags: string;
  dt: TDateTime;
  enumStr: string;
  levelValue: Integer;
begin
  // Expecting format: Date|Level|Category|Msg|Tags
  p1 := Pos('|', ALine);
  if p1 = 0 then
    raise Exception.Create('Invalid log format: missing first delimiter.');
  sDate := Copy(ALine, 1, p1 - 1);

  p2 := PosEx('|', ALine, p1 + 1);
  if p2 = 0 then
    raise Exception.Create('Invalid log format: missing second delimiter.');
  sLevel := Copy(ALine, p1 + 1, p2 - p1 - 1);

  p3 := PosEx('|', ALine, p2 + 1);
  if p3 = 0 then
    raise Exception.Create('Invalid log format: missing third delimiter.');
  sCategory := Copy(ALine, p2 + 1, p3 - p2 - 1);

  p4 := PosEx('|', ALine, p3 + 1);
  if p4 = 0 then
    raise Exception.Create('Invalid log format: missing fourth delimiter.');
  sMsg := Copy(ALine, p3 + 1, p4 - p3 - 1);

  sTags := Copy(ALine, p4 + 1, Length(ALine) - p4);

  // FIX (§3.40): StrToDateTime raised on any unparseable date, which killed
  // the whole read. TryStrToDateTime returns False instead, and we fall back
  // to 0 (a blank date) so a corrupt line still loads with its other fields.
  if not TryStrToDateTime(sDate, dt) then
    dt := 0;
  enumStr := 'll' + sLevel;
  levelValue := GetEnumValue(TypeInfo(TJDLogLevel), enumStr);
  if levelValue = -1 then
    raise Exception.Create('Invalid log level: ' + sLevel);
  FTimestamp := dt;
  FLevel := TJDLogLevel(levelValue);
  FCategory := sCategory;
  FMsg := sMsg;
  FTags.CommaText := sTags;
end;

{ TJDLog }

constructor TJDLog.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FLock := TCriticalSection.Create;
  // FIX (§3.13): the lock that guards the FLoggers list - see FLoggersLock.
  FLoggersLock := TCriticalSection.Create;
  FLog := TJDLogItemList.Create(True);
  FLoggers := TObjectList<TJDLogger>.Create(False);
  FLogQueue := TThreadedQueue<TJDLogItem>.Create(JD_LOG_QUEUE_SIZE);
end;

destructor TJDLog.Destroy;
begin
  Terminate;
  WaitFor;
  FlushLoggers;
  FreeAndNil(FLogQueue);
  FreeAndNil(FLoggers);
  FreeAndNil(FLog);
  FreeAndNil(FLock);
  // FIX (§3.13): freed last - FlushLoggers above still uses it.
  FreeAndNil(FLoggersLock);
  inherited;
end;

procedure TJDLog.Execute;
begin
  while not Terminated do begin
    // FIX (§3.10): a logging thread must never die from a bad entry. There
    // used to be no try/except anywhere in this loop, so one raising logger
    // (e.g. TJDConsoleLogger's WriteLn in a GUI app with no console, or a
    // user's OnLog handler raising) killed the whole engine silently - and
    // then the queue filled up and every thread that logged blocked forever.
    // Now a bad entry is swallowed and the thread carries on with the next one.
    try
      if FLogQueue.QueueSize > 0 then begin
        PumpLogs;
      end;
      FlushLoggers;
    except
      // Deliberately swallowed - see the comment above.
    end;
    Sleep(JD_LOG_THREAD_SLEEP_MS);
  end;
end;

procedure TJDLog.PumpLogs;
var
  WaitResult: TWaitResult;
  LogItem: TJDLogItem;
begin
  while FLogQueue.QueueSize > 0 do begin
    WaitResult := FLogQueue.PopItem(LogItem);
    if WaitResult = TWaitResult.wrSignaled then begin
      FLock.Enter;
      try
        FLog.Add(LogItem);
        // FIX (§3.12): keep the in-memory history bounded - once we are over
        // the cap, drop the oldest entries. FLog is an owning list, so
        // Delete frees the dropped items.
        while FLog.Count > JD_LOG_MAX_HISTORY do
          FLog.Delete(0);
      finally
        FLock.Leave;
      end;
      DoOnLog(LogItem);
    end else begin
      Sleep(JD_LOG_THREAD_SLEEP_MS);
    end;
  end;
end;

procedure TJDLog.DoOnLog(Item: TJDLogItem);
var
  // FIX (§3.13): we take a snapshot copy of the logger list under the lock
  // and then call the loggers OUTSIDE the lock. Holding the lock while
  // calling user code (a logger's DoLog/OnLog) could deadlock if that code
  // tried to register/unregister a logger, and it would stall every other
  // thread that logs. Note this still can't protect against a logger being
  // destroyed mid-delivery - destroy loggers only when nothing is logging.
  Snapshot: TList<TJDLogger>;
  i: Integer;
begin
  Snapshot := TList<TJDLogger>.Create;
  try
    FLoggersLock.Enter;
    try
      for i := 0 to FLoggers.Count - 1 do
        Snapshot.Add(FLoggers[i]);
    finally
      FLoggersLock.Leave;
    end;
    for i := 0 to Snapshot.Count - 1 do
      Snapshot[i].HandleLogItem(Item);
  finally
    Snapshot.Free;
  end;
end;

function TJDLog.LockLog: TJDLogItemList;
begin
  FLock.Enter;
  Result := FLog;
end;

procedure TJDLog.UnlockLog;
begin
  FLock.Leave;
end;

function TJDLog.PostLog(const ALevel: TJDLogLevel; const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
var
  Tag: string;
begin
  Result := TJDLogItem.Create;
  Result.Msg := AMsg;
  Result.Level := ALevel;
  Result.Category := ACategory;
  for Tag in ATags do
    Result.Tags.Add(Tag);
  // FIX (§3.11): PushItem used to block forever when the queue was full, so
  // one stuck worker thread could freeze any thread that logged - including
  // the UI thread. Now we wait only JD_LOG_PUSH_TIMEOUT_MS; if there is
  // still no room, the entry is dropped (and counted) instead of freezing
  // the caller. The dropped item is freed here, and nil is returned.
  if FLogQueue.PushItem(Result, JD_LOG_PUSH_TIMEOUT_MS) <> TWaitResult.wrSignaled then
  begin
    Result.Free;
    Result := nil;
    TInterlocked.Increment(FDroppedCount);
  end;
end;

function TJDLog.PostLogCritical(const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
begin
  Result := PostLog(llCritical, AMsg, ACategory, ATags);
end;

function TJDLog.PostLogError(const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
begin
  Result := PostLog(llError, AMsg, ACategory, ATags);
end;

function TJDLog.PostLogWarning(const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
begin
  Result := PostLog(llWarning, AMsg, ACategory, ATags);
end;

function TJDLog.PostLogInformation(const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
begin
  Result := PostLog(llInformation, AMsg, ACategory, ATags);
end;

function TJDLog.PostLogVerbose(const AMsg: string;
  ACategory: string; ATags: TArray<string>): TJDLogItem;
begin
  Result := PostLog(llVerbose, AMsg, ACategory, ATags);
end;

procedure TJDLog.RegisterLogger(ALogger: TJDLogger);
begin
  // FIX (§3.13): guard the list - the worker thread iterates it while the
  // main thread adds/removes loggers (see FLoggersLock).
  FLoggersLock.Enter;
  try
    FLoggers.Add(ALogger);
  finally
    FLoggersLock.Leave;
  end;
end;

procedure TJDLog.UnregisterLogger(ALogger: TJDLogger);
var
  I: Integer;
begin
  // FIX (§3.13): same lock as RegisterLogger - see FLoggersLock.
  FLoggersLock.Enter;
  try
    I := FLoggers.IndexOf(ALogger);
    if I >= 0 then
      FLoggers.Delete(I);
  finally
    FLoggersLock.Leave;
  end;
end;

procedure TJDLog.FlushLoggers;
var
  // FIX (§3.13): same snapshot trick as DoOnLog - copy the list under the
  // lock, then call the loggers outside it, so user code in DoFlush can
  // never deadlock against RegisterLogger/UnregisterLogger.
  Snapshot: TList<TJDLogger>;
  i: Integer;
begin
  Snapshot := TList<TJDLogger>.Create;
  try
    FLoggersLock.Enter;
    try
      for i := 0 to FLoggers.Count - 1 do
        Snapshot.Add(FLoggers[i]);
    finally
      FLoggersLock.Leave;
    end;
    for i := 0 to Snapshot.Count - 1 do
      Snapshot[i].DoFlush;
  finally
    Snapshot.Free;
  end;
end;

{ TJDLogger }

constructor TJDLogger.Create(AOwner: TComponent);
var
  // FIX (§3.13): JDLog() can return nil once the unit has been finalized
  // (during shutdown), so grab it once and check before using it - calling
  // RegisterLogger on a nil engine would be an access violation.
  LLog: TJDLog;
begin
  inherited Create(AOwner);
  FLogLevels := JD_LOG_DEFAULT_LEVELS;
  LLog := JDLog;
  if Assigned(LLog) then
    LLog.RegisterLogger(Self);
end;

destructor TJDLogger.Destroy;
var
  // FIX (§3.13): same nil check as the constructor - a logger destroyed after
  // finalization must not resurrect (or crash on) the logging engine.
  LLog: TJDLog;
begin
  LLog := JDLog;
  if Assigned(LLog) then
    LLog.UnregisterLogger(Self);
  inherited;
end;

procedure TJDLogger.SetLogLevels(const Value: TJDLogLevels);
begin
  FLogLevels := Value;
end;

function TJDLogger.IsLogLevelsStored: Boolean;
begin
  Result := FLogLevels <> JD_LOG_DEFAULT_LEVELS;
end;

procedure TJDLogger.HandleLogItem(Item: TJDLogItem);
begin
  if not (Item.Level in FLogLevels) then Exit;
  DoLog(Item);
end;

procedure TJDLogger.DoLog(Item: TJDLogItem);
var
  // FIX (§3.13): used only when SynchronizedEvents is True (see below).
  LHandler: TJDLogEvent;
  LSender: TObject;
  LCopy: TJDLogItem;
begin
  if not Assigned(FOnLog) then
    Exit;
  if FSynchronizedEvents then
  begin
    // Deliver OnLog on the MAIN thread instead of the logging worker thread,
    // so the handler may safely touch the UI. Two safety details:
    // - We queue a COPY of the item, not the engine-owned one: the engine
    //   may free its item (history cap, shutdown) before the main thread
    //   gets around to running the queued call, which would leave a dangling
    //   pointer. The copy is freed right after the handler runs.
    // - The queued code only passes the logger along as the Sender argument
    //   and never reads any of its fields. Even so, the logger and the
    //   handler's owning object (usually a form) must outlive delivery -
    //   don't free them with queued log events still pending.
    LHandler := FOnLog;
    LSender := Self;
    LCopy := TJDLogItem.Create;
    LCopy.Level := Item.Level;
    LCopy.Timestamp := Item.Timestamp;
    LCopy.Msg := Item.Msg;
    LCopy.Category := Item.Category;
    LCopy.Tags.Assign(Item.Tags);
    TThread.Queue(nil,
      procedure
      begin
        try
          LHandler(LSender, LCopy);
        finally
          LCopy.Free;
        end;
      end);
  end
  else
    // Default behaviour (unchanged): OnLog fires right here, on the logging
    // engine's worker thread. Handlers must NOT touch the UI directly.
    FOnLog(Self, Item);
  // Override to add additional custom handling.
end;

procedure TJDLogger.DoFlush;
begin
  // Base implementation does nothing.
  // Optionally used to flush any queued data before closing.
end;

{ TJDFileLogger }

constructor TJDFileLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive := False;
  FReadOnly := JD_LOG_FILE_READONLY_DEFAULT;
  FFileName := '';
  FFileStream := nil;
  FFileLock := TCriticalSection.Create;
  FBuffer := TStringList.Create;
  FBufferLock := TCriticalSection.Create;
  //FCachedLogs := TJDLogItemList.Create(True);
end;

destructor TJDFileLogger.Destroy;
begin
  if FActive then CloseFile;
  FBuffer.Free;
  FBufferLock.Free;
  FFileLock.Free;
  //FCachedLogs.Free;
  inherited;
end;

function TJDFileLogger.Count: Integer;
begin
  //Ensure file has been fully written...
  if not FActive then
    raise Exception.Create('Cannot get count when not active.');
  FlushBuffer;

  //Read resulting value...
  FFileLock.Enter;
  try
    Result:= FHeader.Count;
  finally
    FFileLock.Leave;
  end;
end;

procedure TJDFileLogger.SetActive(const Value: Boolean);
begin
  if Value = FActive then Exit;
  if Value then begin
    OpenFile;
    FActive := True;
  end else begin
    CloseFile;
    FActive := False;
  end;
end;

procedure TJDFileLogger.SetReadOnly(const Value: Boolean);
begin
  if FActive then
    raise Exception.Create('Cannot change ReadOnly property while active.');
  FReadOnly := Value;
end;

procedure TJDFileLogger.SetFileName(const Value: TFileName);
begin
  if FActive then
    raise Exception.Create('Cannot change FileName property while active.');
  FFileName := Value;
end;

procedure TJDFileLogger.OpenFile;
begin
  if FActive then
    raise Exception.Create('Cannot open file while already active.');
  try
    if FileExists(FFileName) then begin
      //Load from existing file
      FFileStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
      if FFileStream.Size >= SizeOf(TJDLogFileHeader) then begin
        //Read file header...
        FFileStream.Position := 0;
        FFileStream.ReadBuffer(FHeader, SizeOf(TJDLogFileHeader));
        //Validate format identifier...
        if not (FHeader.Format = JD_LOG_FILE_FORMAT_MARKER) then
          raise Exception.Create('Invalid log file format.');
      end else begin
        //Create file header...
        FillChar(FHeader, SizeOf(TJDLogFileHeader), 0);
      FHeader.Format:= JD_LOG_FILE_FORMAT_MARKER;
        FHeader.Version := JD_LOG_FILE_VERSION;
        FHeader.Count := 0;
        FFileStream.Position := 0;
        FFileStream.WriteBuffer(FHeader, SizeOf(TJDLogFileHeader));
      end;
    end else begin
      //Create a new file
      FFileStream := TFileStream.Create(FFileName, fmCreate or fmOpenReadWrite or fmShareDenyNone);
      FillChar(FHeader, SizeOf(TJDLogFileHeader), 0);
      FHeader.Format:= JD_LOG_FILE_FORMAT_MARKER;
      FHeader.Version := JD_LOG_FILE_VERSION;
      FHeader.Count := 0;
      FFileStream.Position := 0;
      FFileStream.WriteBuffer(FHeader, SizeOf(TJDLogFileHeader));
    end;
  except
    on E: Exception do
    begin
      // FIX (§3.40): if we got part-way through opening (the stream was
      // created, then the header check failed), the old code re-raised
      // without freeing the stream - a leaked file handle, and a second
      // Active := True attempt would trip over the stale stream. Free it
      // first, then re-raise as before.
      FreeAndNil(FFileStream);
      raise Exception.Create('Error opening file: ' + E.Message);
    end;
  end;
end;

procedure TJDFileLogger.CloseFile;
begin
  if not FActive then
    raise Exception.Create('Cannot close when not active.');
  FlushBuffer;
  FreeAndNil(FFileStream);
end;

procedure TJDFileLogger.FlushBuffer;
var
  TempList: TStringList;
  i: Integer;
  LineBytes: TBytes;
begin
  if not FActive then
    raise Exception.Create('Cannot flush buffer when not active.');
  TempList := TStringList.Create;
  try

    //Extract contents of buffer into temporary list
    FBufferLock.Enter;
    try
      if FBuffer.Count = 0 then
        Exit;
      TempList.Assign(FBuffer);
      FBuffer.Clear;
    finally
      FBufferLock.Leave;
    end;

    //Write temporary list to file
    FFileLock.Enter;
    try
      try
        if Assigned(FFileStream) then begin
          //Rewrite file header...
          FFileStream.Position := 0;
          FFileStream.ReadBuffer(FHeader, SizeOf(TJDLogFileHeader));
          Inc(FHeader.Count, TempList.Count);
          FFileStream.Position := 0;
          FFileStream.WriteBuffer(FHeader, SizeOf(TJDLogFileHeader));
          //Append buffer to end of file...
          FFileStream.Position := FFileStream.Size;
          for i := 0 to TempList.Count - 1 do begin
            LineBytes := TEncoding.UTF8.GetBytes(TempList[i] + sLineBreak);
            FFileStream.WriteBuffer(LineBytes[0], Length(LineBytes));
          end;
        end;
      except
        on E: Exception do
          raise Exception.Create('Error flushing buffer: ' + E.Message);
      end;
    finally
      FFileLock.Leave;
    end;

  finally
    TempList.Free;
  end;
end;

function TJDFileLogger.GetItemStr(const Index: Integer): string;
var
  OldPos: Int64;
  Reader: TStreamReader;
  CurrentIndex: Integer;
  Line: string;
begin
  Result := '';
  //Ensure buffer is saved to file first...
  FlushBuffer;
  FFileLock.Enter;
  try
    if not Assigned(FFileStream) then
      Exit;
    // Cache current stream position.
    OldPos := FFileStream.Position;
    try
      // Skip the header by setting the position to after the header.
      FFileStream.Position := JD_LOG_FILE_HEADER_SIZE;
      Reader := TStreamReader.Create(FFileStream, TEncoding.UTF8, False);
      try
        CurrentIndex := 0;
        while not Reader.EndOfStream do begin
          Line := Reader.ReadLine;
          if CurrentIndex = Index then begin
            Result := Line;
            Break;  // Found the desired line.
          end;
          Inc(CurrentIndex);
        end;
      finally
        Reader.Free;
      end;
    finally
      // Restore the original stream position.
      FFileStream.Position := OldPos;
    end;
  finally
    FFileLock.Leave;
  end;
end;

function TJDFileLogger.GetItem(const Index: Integer; var Item: TJDLogItem): Boolean;
var
  sLine: string;
begin
  sLine := GetItemStr(Index);
  if sLine <> '' then
  begin
    Item := TJDLogItem.Create;
    try
      Item.FromSingleLineString(sLine);
      Result := True;
    except
      // FIX (§3.40): the old code freed the item but left the caller's var
      // pointing at the freed object - a dangling pointer. Nil it so the
      // caller can never use it after the exception.
      Item.Free;
      Item := nil;
      raise;
    end;
  end
  else
    Result := False;
end;

procedure TJDFileLogger.DoLog(Item: TJDLogItem);
var
  sLine: string;
begin
  if not FActive then Exit;
  sLine := Item.ToSingleLineString;
  if not FReadOnly then begin
    FBufferLock.Enter;
    try
      FBuffer.Add(sLine);
    finally
      FBufferLock.Leave;
    end;
    //FCachedLogs.Add(TJDLogItem.Create);
  end;
end;

procedure TJDFileLogger.DoFlush;
begin
  if FActive and (not FReadOnly) then
    FlushBuffer;
end;

{ TJDConsoleLogger }

constructor TJDConsoleLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Initialization if necessary
end;

destructor TJDConsoleLogger.Destroy;
begin
  // Cleanup if necessary
  inherited;
end;

procedure TJDConsoleLogger.DoLog(Item: TJDLogItem);
begin
  inherited;
  // Output log to the console
  WriteLn(Format('%s [%s] (%s): %s', [
    FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Item.Timestamp),
    GetEnumName(TypeInfo(TJDLogLevel), Ord(Item.Level)),
    Item.Category,
    Item.Msg
  ]));

  // If the log entry has tags, output them on a separate line
  if Item.Tags.Count > 0 then
    WriteLn('  Tags: ' + Item.Tags.CommaText);
end;

initialization
  _JDLog := nil;
  _JDLogLock := TCriticalSection.Create;
  _JDLogFinalized := False;
finalization
  // Mark finalized BEFORE freeing the engine, so any JDLog() call from here
  // on returns nil instead of creating a new engine during shutdown (and
  // never touches the lock after it is freed - see JDLog()).
  _JDLogFinalized := True;
  FreeAndNil(_JDLog);
  FreeAndNil(_JDLogLock);
end.


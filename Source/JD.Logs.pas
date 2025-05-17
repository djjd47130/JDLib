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
  JD_LOG_THREAD_SLEEP_MS = 0;
  JD_LOG_FILE_HEADER_SIZE = 256;

type
  TJDLogItem = class;
  TJDLog = class;
  TJDLogger = class;
  TJDFileLogger = class;

  /// <summary>
  /// Event type triggered when a log entry is processed.
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
    FLogQueue: TThreadedQueue<TJDLogItem>;
    procedure PumpLogs;
  protected
    procedure DoOnLog(Item: TJDLogItem); virtual;
    procedure Execute; override;
    procedure FlushLoggers; virtual;
  public
    constructor Create;
    destructor Destroy; override;
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
  /// </summary>
  TJDLogger = class(TComponent)
  private
    FLogLevels: TJDLogLevels;
    FOnLog: TJDLogEvent;
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

    property OnLog: TJDLogEvent read FOnLog write FOnLog;
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
/// </summary>
function JDLog: TJDLog;

implementation

var
  _JDLog: TJDLog;

function JDLog: TJDLog;
begin
  if _JDLog = nil then
    _JDLog := TJDLog.Create;
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
  Result := sDate + '|' + sLevel + '|' + FCategory + '|' + FMsg + '|' + sTags;
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

  dt := StrToDateTime(sDate);
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
  inherited;
end;

procedure TJDLog.Execute;
begin
  while not Terminated do begin
    if FLogQueue.QueueSize > 0 then begin
      PumpLogs;
    end;
    FlushLoggers;
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
  i: Integer;
begin
  for i := 0 to FLoggers.Count - 1 do
    FLoggers[i].HandleLogItem(Item);
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
  FLogQueue.PushItem(Result);
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
  FLoggers.Add(ALogger);
end;

procedure TJDLog.UnregisterLogger(ALogger: TJDLogger);
var
  I: Integer;
begin
  I := FLoggers.IndexOf(ALogger);
  if I >= 0 then
    FLoggers.Delete(I);
end;

procedure TJDLog.FlushLoggers;
var
  i: Integer;
begin
  for i := 0 to FLoggers.Count - 1 do
    FLoggers[i].DoFlush;
end;

{ TJDLogger }

constructor TJDLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogLevels := JD_LOG_DEFAULT_LEVELS;
  JDLog.RegisterLogger(Self);
end;

destructor TJDLogger.Destroy;
begin
  JDLog.UnregisterLogger(Self);
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
begin
  if Assigned(FOnLog) then
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
      raise Exception.Create('Error opening file: ' + E.Message);
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
      Item.Free;
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
finalization
  FreeAndNil(_JDLog);
end.


unit JD.Favicons;

(*

JD Favicon Library
Fetch favicon images for any given website / domain

Features:
- Utilizes Google's favicon API
- Images cached in memory for quick access
- Images cached to disk for later access
- Cache expiration mechanism
- Automatically populates TImageList(s)
- Automatically resizes image as necessary



*)

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics, Vcl.ImgList, Vcl.Imaging.PngImage, Vcl.Imaging.Jpeg,
  Vcl.Controls,
  IdHTTP, IdURI,
  JD.Common;

type
  TJDFaviconRef = class;
  TJDFavicons = class;

  TJDFaviconFetchMode = (fmLocal, fmDirect, fmGoogle);

  //Used for pre-fetch to manually supply favicon instead of downloading...
  TJDFaviconEvent = procedure(Sender: TObject; const URI: String;
    Ref: TJDFaviconRef; var Handled: Boolean) of object;

  TJDFaviconRef = class(TObject)
  private
    FOwner: TJDFavicons;
    FProtocol: String;
    FDomain: String;
    FGraphic: TBitmap;
    FImageIndex: Integer;
    procedure SetDomain(const Value: String);
    procedure SetProtocol(const Value: String);
    procedure SetImageIndex(const Value: Integer);
  public
    constructor Create(AOwner: TJDFavicons); virtual;
    destructor Destroy; override;
    property Protocol: String read FProtocol write SetProtocol;
    property Domain: String read FDomain write SetDomain;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    // Internal accessors:
    property Graphic: TBitmap read FGraphic; // kept as 32-bit ARGB
  end;

  TJDFaviconImageList = class(TCollectionItem)
  private
    FImageList: TImageList;
    procedure SetImageList(const Value: TImageList);
  public
    constructor Create(Collection: TCollection); override;
  published
    property ImageList: TImageList read FImageList write SetImageList;
  end;

  TJDFaviconImageLists = class(TOwnedCollection)
  public
    constructor Create(AOwner: TJDFavicons);
    function Add: TJDFaviconImageList;
  end;

  TJDFavicons = class(TComponent)
  private
    FRefs: TObjectList<TJDFaviconRef>;
    FImageLists: TJDFaviconImageLists;
    FOnLookupFavicon: TJDFaviconEvent;
    FMode: TJDFaviconFetchMode;
    procedure SetMode(const Value: TJDFaviconFetchMode);
    procedure SetImageLists(const Value: TJDFaviconImageLists);
  protected
    procedure DoLookupFavicon(const URI: String; Ref: TJDFaviconRef); virtual;
    procedure InsertIntoImageLists(Source: TGraphic; var Index: Integer); virtual;
    procedure PopulateImageList(AImageList: TImageList); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetFavicon(const URI: String): TJDFaviconRef; virtual;
    procedure DownloadFavicon(const Domain: String; const Size: Integer; Graphic: TGraphic);
  published
    property ImageLists: TJDFaviconImageLists read FImageLists write SetImageLists;
    property Mode: TJDFaviconFetchMode read FMode write SetMode;

    property OnLookupFavicon: TJDFaviconEvent read FOnLookupFavicon write FOnLookupFavicon;
  end;

function FetchFaviconGoogleAPI(var Picture: TPicture;
  const Domain: String; const Size: Integer = 16): Boolean;

implementation

uses
  System.Net.URLClient,
  System.Net.HttpClient,
  System.NetEncoding,
  System.IOUtils,
  System.Math,
  Vcl.GraphUtil;

type
  TScopedBitmap = record
    Bmp: TBitmap;
    class function CreateSized(const W, H: Integer): TScopedBitmap; static;
    procedure Release;
  end;

function NormalizeDomain(const Input: string): string;
var
  U: TURI;
  Temp, Host: string;
begin
  Temp := Trim(Input);
  if Temp = '' then
    Exit('');

  if not Temp.Contains('://') then
    Temp := 'http://' + Temp;

  try
    U := TURI.Create(Temp);
    Host := LowerCase(U.Host);
  except
    on E: Exception do
      Host := LowerCase(Temp);
  end;

  if Host.StartsWith('www.') then
    Delete(Host, 1, 4);

  Result := Host.TrimRight(['/']);
end;

function SanitizeFileName(const S: string): string;
const
  Invalid: array[0..8] of Char = ('\', '/', ':', '*', '?', '"', '<', '>', '|');
var
  R: string;
  C: Char;
begin
  R := S;
  for C in Invalid do
    R := R.Replace(C, '_');
  Result := R;
end;

function DefaultCacheFolder: string;
begin
  // Windows-friendly default under Local AppData. Cross-platform falls back gracefully.
  // Example: C:\Users\<User>\AppData\Local\JD\Favicons
  Result := TPath.Combine(TPath.GetHomePath, TPath.Combine('AppData\Local', TPath.Combine('JD', 'Favicons')));
  TDirectory.CreateDirectory(Result);
end;

function DomainCacheFileName(const Domain: string; const Size: Integer): string;
begin
  Result := TPath.Combine(DefaultCacheFolder, Format('%s_%d.png', [SanitizeFileName(Domain), Size]));
end;

procedure SaveBitmapAsPng(const FileName: string; const Bmp: TBitmap);
var
  Png: TPngImage;
begin
  Png := TPngImage.Create;
  try
    Png.Assign(Bmp);
    TDirectory.CreateDirectory(TPath.GetDirectoryName(FileName));
    Png.SaveToFile(FileName);
  finally
    Png.Free;
  end;
end;

function LoadPngAsBitmap(const FileName: string; TargetSize: TSize): TBitmap;
var
  Png: TPngImage;
  Bmp: TBitmap;
  Dest: TBitmap;
begin
  Result := nil;
  if not TFile.Exists(FileName) then
    Exit;

  Png := TPngImage.Create;
  try
    Png.LoadFromFile(FileName);

    Bmp := TBitmap.Create;
    try
      Bmp.PixelFormat := pf32bit;
      Bmp.AlphaFormat := afPremultiplied;
      Bmp.SetSize(Png.Width, Png.Height);
      Bmp.Canvas.Brush.Style := bsClear;
      Bmp.Canvas.Draw(0, 0, Png);

      // If no resize needed, return directly
      if (Bmp.Width = TargetSize.cx) and (Bmp.Height = TargetSize.cy) then
        Exit(Bmp);

      // Scale to target
      Dest := TBitmap.Create;
      try
        Dest.PixelFormat := pf32bit;
        Dest.AlphaFormat := afPremultiplied;
        Dest.SetSize(TargetSize.cx, TargetSize.cy);
        Dest.Canvas.Brush.Style := bsClear;
        Dest.Canvas.Brush.Color := clNone;
        Dest.Canvas.FillRect(Rect(0, 0, Dest.Width, Dest.Height));
        Dest.Canvas.StretchDraw(Rect(0, 0, Dest.Width, Dest.Height), Bmp);
        Result := Dest;
        Exit;
      finally
        Bmp.Free;
      end;
    except
      Bmp.Free;
      raise;
    end;
  finally
    Png.Free;
  end;
end;

procedure EnsureBitmap32(var Bmp: TBitmap; const W, H: Integer);
begin
  if Bmp = nil then
    Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf32bit;
  Bmp.AlphaFormat := afPremultiplied;
  Bmp.SetSize(W, H);
end;

function GraphicToBitmap32(const G: TGraphic; const W, H: Integer): TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf32bit;
    Result.AlphaFormat := afPremultiplied;
    Result.SetSize(W, H);
    Result.Canvas.Brush.Style := bsClear;
    Result.Canvas.Brush.Color := clNone;
    Result.Canvas.FillRect(Rect(0, 0, W, H));
    Result.Canvas.StretchDraw(Rect(0, 0, W, H), G);
  except
    Result.Free;
    raise;
  end;
end;

function TryDownloadURLToPicture(const Url: string; Pic: TPicture): Boolean;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
  MS: TMemoryStream;
begin
  Result := False;
  Http := THTTPClient.Create;
  try
    Http.UserAgent := 'Delphi/10.4 (JD.Favicons)';
    Http.ConnectionTimeout := 4000;
    Http.ResponseTimeout := 6000;
    MS := TMemoryStream.Create;
    try
      Resp := Http.Get(Url, MS);
      if (Resp.StatusCode >= 200) and (Resp.StatusCode < 300) and (MS.Size > 0) then
      begin
        MS.Position := 0;
        try
          Pic.LoadFromStream(MS);
          Result := Assigned(Pic.Graphic) and not Pic.Graphic.Empty;
        except
          Result := False;
          Pic.Assign(nil);
        end;
      end;
    finally
      MS.Free;
    end;
  finally
    Http.Free;
  end;
end;

function TryFetchDirectFavicon(const Domain: string; out Pic: TPicture): Boolean;
var
  Host: string;
  Urls: TArray<string>;
  P: TPicture;
  U: string;
begin
  Result := False;
  Pic := nil;
  Host := NormalizeDomain(Domain);
  if Host = '' then Exit;

  Urls := [
    Format('https://%s/favicon.ico', [Host]),
    Format('http://%s/favicon.ico', [Host]),
    Format('https://%s/apple-touch-icon.png', [Host]),
    Format('http://%s/apple-touch-icon.png', [Host])
  ];

  P := TPicture.Create;
  try
    for U in Urls do
    begin
      if TryDownloadURLToPicture(U, P) then
      begin
        Pic := TPicture.Create;
        Pic.Assign(P.Graphic);
        Exit(True);
      end;
    end;
  finally
    P.Free;
  end;
end;

// Deterministic pastel color from a string
function HashColor(const S: string): TColor;
var
  H: Cardinal;
  C: Char;
begin
  H := 2166136261;
  for C in S do
  begin
    H := H xor Ord(C);
    H := H * 16777619;
  end;
  // Map to soft hues
  Result := RGB(Byte((H shr 16) and $7F) + 64, Byte((H shr 8) and $7F) + 64, Byte(H and $7F) + 64);
end;

procedure MakePlaceholderIcon(const TextKey: string; const W, H: Integer; out Bmp: TBitmap);
var
  BG, FG: TColor;
  R: TRect;
  S: string;
  FontSize: Integer;
begin
  EnsureBitmap32(Bmp, W, H);
  BG := HashColor(TextKey);
  FG := clWhite;

  R := Rect(0, 0, W, H);
  Bmp.Canvas.Brush.Color := BG;
  Bmp.Canvas.FillRect(R);

  // First significant letter
  S := '';
  for var C in TextKey do
    if CharInSet(C, ['a'..'z','A'..'Z','0'..'9']) then
    begin
      S := UpperCase(C);
      Break;
    end;
  if S = '' then S := '#';

  // Scale font to fit
  FontSize := Max(10, Round(H * 0.55));
  Bmp.Canvas.Brush.Style := bsClear;
  Bmp.Canvas.Font.Color := FG;
  Bmp.Canvas.Font.Size := FontSize;
  Bmp.Canvas.Font.Style := [fsBold];

  DrawText(Bmp.Canvas.Handle, PChar(S), Length(S), R,
    DT_SINGLELINE or DT_CENTER or DT_VCENTER);
end;

//https://medium.com/medialesson/use-a-hidden-google-api-to-load-favicons-fa945d0ba442
function FetchFaviconGoogleAPI(var Picture: TPicture;
  const Domain: String; const Size: Integer = 16): Boolean;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
  MS: TMemoryStream;
  Url, Host: string;
  S: Integer;
begin
  Result := False;

  Host := NormalizeDomain(Domain);
  if Host = '' then
    Exit;

  // Clamp the size to a practical range
  S := IntRange(Size, 16, 256);
  Url := Format('https://www.google.com/s2/favicons?domain=%s&sz=%d', [Host, S]);

  if Picture = nil then
    Picture := TPicture.Create;

  Http := THTTPClient.Create;
  try
    Http.UserAgent := 'Delphi/10.4 (FaviconFetcher)';
    Http.ConnectionTimeout := 4000;
    Http.ResponseTimeout := 6000;

    MS := TMemoryStream.Create;
    try
      Resp := Http.Get(Url, MS);
      if (Resp.StatusCode >= 200) and (Resp.StatusCode < 300) then
      begin
        MS.Position := 0;
        try
          Picture.LoadFromStream(MS);
          Result := Assigned(Picture.Graphic) and not Picture.Graphic.Empty;
          if not Result then
            Picture.Assign(nil);
        except
          Picture.Assign(nil);
          Result := False;
        end;
      end
      else
      begin
        Picture.Assign(nil);
        Result := False;
      end;
    finally
      MS.Free;
    end;
  finally
    Http.Free;
  end;
end;

{ TScopedBitmap }

class function TScopedBitmap.CreateSized(const W, H: Integer): TScopedBitmap;
begin
  Result.Bmp := TBitmap.Create;
  Result.Bmp.PixelFormat := pf32bit;
  Result.Bmp.AlphaFormat := afPremultiplied;
  Result.Bmp.SetSize(W, H);
end;

procedure TScopedBitmap.Release;
begin
  FreeAndNil(Bmp);
end;

{ TJDFaviconRef }

constructor TJDFaviconRef.Create(AOwner: TJDFavicons);
begin
  FOwner := AOwner;
  FGraphic := TBitmap.Create;
  FGraphic.PixelFormat := pf32bit;
  FGraphic.AlphaFormat := afPremultiplied;
  FImageIndex := -1;
end;

destructor TJDFaviconRef.Destroy;
begin
  FreeAndNil(FGraphic);
  inherited;
end;

procedure TJDFaviconRef.SetDomain(const Value: String);
begin
  FDomain := Value;
end;

procedure TJDFaviconRef.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TJDFaviconRef.SetProtocol(const Value: String);
begin
  FProtocol := Value;
end;

{ TJDFavicons }

constructor TJDFavicons.Create(AOwner: TComponent);
begin
  inherited;
  FRefs := TObjectList<TJDFaviconRef>.Create(True);
  FImageLists := TJDFaviconImageLists.Create(Self);
  FMode := fmDirect;
end;

destructor TJDFavicons.Destroy;
begin
  FreeAndNil(FRefs);
  FreeAndNil(FImageLists);
  inherited;
end;

procedure TJDFavicons.DoLookupFavicon(const URI: String; Ref: TJDFaviconRef);
var
  Handled: Boolean;
  U: TIdURI;
  Host: string;
  SizeToUse: Integer;
  Pic: TPicture;
  Bmp: TBitmap;
  Idx: Integer;
  CacheFile: string;
  ImgSize: TSize;
begin
  // Parse target
  U := TIdURI.Create(URI);
  try
    Ref.Protocol := LowerCase(U.Protocol);
    Host := NormalizeDomain(U.Host);
    Ref.Domain := Host;
  finally
    U.Free;
  end;

  // Choose a representative size from first imagelist (default to 16x16)
  ImgSize := TSize.Create(16, 16);
  for var I := 0 to FImageLists.Count - 1 do
  begin
    if Assigned(TJDFaviconImageList(FImageLists.Items[I]).ImageList) then
    begin
      ImgSize.cx := TJDFaviconImageList(FImageLists.Items[I]).ImageList.Width;
      ImgSize.cy := TJDFaviconImageList(FImageLists.Items[I]).ImageList.Height;
      Break;
    end;
  end;
  SizeToUse := Max(ImgSize.cx, ImgSize.cy);

  // 1) Let client override if desired
  Handled := False;
  if Assigned(FOnLookupFavicon) then
    FOnLookupFavicon(Self, URI, Ref, Handled);
  if Handled and (not Ref.Graphic.Empty) then
  begin
    Idx := -1;
    InsertIntoImageLists(Ref.Graphic, Idx);
    Ref.ImageIndex := Idx;
    Exit;
  end;

  // 2) Try cache
  CacheFile := DomainCacheFileName(Host, SizeToUse);
  if TFile.Exists(CacheFile) then
  begin
    Bmp := LoadPngAsBitmap(CacheFile, ImgSize);
    try
      if Assigned(Bmp) then
      begin
        Ref.Graphic.Assign(Bmp);
        Idx := -1;
        InsertIntoImageLists(Ref.Graphic, Idx);
        Ref.ImageIndex := Idx;
        Exit;
      end;
    finally
      Bmp.Free;
    end;
  end;

  // 3) Fetch according to mode, with sensible fallback where appropriate
  Pic := nil;
  try
    case FMode of
      fmLocal:
        begin
          // local only -> placeholder if not found
        end;
      fmDirect:
        begin
          if not TryFetchDirectFavicon(Host, Pic) then
          begin
            // Fallback to Google service
            if not FetchFaviconGoogleAPI(Pic, Host, SizeToUse) then
              Pic := nil;
          end;
        end;
      fmGoogle:
        begin
          if not FetchFaviconGoogleAPI(Pic, Host, SizeToUse) then
            Pic := nil;
        end;
    end;

    if Assigned(Pic) and Assigned(Pic.Graphic) and not Pic.Graphic.Empty then
    begin
      // Convert to sized bitmap
      Bmp := GraphicToBitmap32(Pic.Graphic, ImgSize.cx, ImgSize.cy);
      try
        Ref.Graphic.Assign(Bmp);
        // Save to cache
        try
          //SaveBitmapAsPng(CacheFile, Ref.Graphic);
        except
          // ignore cache failures
        end;
      finally
        Bmp.Free;
      end;
    end
    else
    begin
      // Placeholder
      MakePlaceholderIcon(Host, ImgSize.cx, ImgSize.cy, Bmp);
      try
        Ref.Graphic.Assign(Bmp);
      finally
        Bmp.Free;
      end;
    end;

    // Insert into imagelists
    Idx := -1;
    InsertIntoImageLists(Ref.Graphic, Idx);
    Ref.ImageIndex := Idx;
  finally
    Pic.Free;
  end;
end;

function TJDFavicons.GetFavicon(const URI: String): TJDFaviconRef;
var
  U: TIdURI;
begin
  Result := nil;
  U := TIdURI.Create(URI);
  try
    //Return cached object if exists...
    for var X := 0 to FRefs.Count - 1 do
    begin
      var R := FRefs[X];
      if SameText(R.Protocol, U.Protocol) and SameText(R.Domain, U.Host) then
      begin
        Result := R;
        Break;
      end;
    end;

    //Otherwise, proceed with fetching...
    if Result = nil then
    begin
      var R := TJDFaviconRef.Create(Self);
      try
        DoLookupFavicon(URI, R);
        Result := R;
      finally
        FRefs.Add(R);
      end;
    end;

  finally
    U.Free;
  end;
end;

procedure TJDFavicons.DownloadFavicon(const Domain: String; const Size: Integer;
  Graphic: TGraphic);
var
  Pic: TPicture;
  Host: string;
  Bmp: TBitmap;
  CacheFile: string;
  SizeClamped: Integer;
begin
  if Graphic = nil then
    raise Exception.Create('Graphic object cannot be nil!');

  Host := NormalizeDomain(Domain);
  if Host = '' then
    raise Exception.Create('Invalid domain.');

  SizeClamped := IntRange(Size, 16, 256);
  CacheFile := DomainCacheFileName(Host, SizeClamped);

  // Attempt cache first
  if TFile.Exists(CacheFile) then
  begin
    Bmp := LoadPngAsBitmap(CacheFile, TSize.Create(SizeClamped, SizeClamped));
    try
      if Assigned(Bmp) then
      begin
        Graphic.Assign(Bmp);
        Exit;
      end;
    finally
      Bmp.Free;
    end;
  end;

  Pic := nil;
  try
    case FMode of
      fmLocal:
        begin
          // local only -> fallback to placeholder
        end;
      fmDirect:
        begin
          if not TryFetchDirectFavicon(Host, Pic) then
          begin
            // fallback
            if not FetchFaviconGoogleAPI(Pic, Host, SizeClamped) then
              Pic := nil;
          end;
        end;
      fmGoogle:
        begin
          if not FetchFaviconGoogleAPI(Pic, Host, SizeClamped) then
            Pic := nil;
        end;
    end;

    if Assigned(Pic) and Assigned(Pic.Graphic) and not Pic.Graphic.Empty then
    begin
      Bmp := GraphicToBitmap32(Pic.Graphic, SizeClamped, SizeClamped);
      try
        // Cache as PNG
        try
          //SaveBitmapAsPng(CacheFile, Bmp);
        except
          // ignore cache write errors
        end;
        Graphic.Assign(Bmp);
        Exit;
      finally
        Bmp.Free;
      end;
    end;
  finally
    Pic.Free;
  end;

  // Placeholder on failure
  MakePlaceholderIcon(Host, SizeClamped, SizeClamped, Bmp);
  try
    Graphic.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure TJDFavicons.InsertIntoImageLists(Source: TGraphic; var Index: Integer);
var
  MasterIndex: Integer;
  FirstList: TImageList;
  Sized: TBitmap;
begin
  MasterIndex := -1;
  //FirstList := nil;

  // Establish master index using the first available imagelist
  for var I := 0 to FImageLists.Count - 1 do
  begin
    var Item := TJDFaviconImageList(FImageLists.Items[I]);
    if Assigned(Item.ImageList) then
    begin
      FirstList := Item.ImageList;
      MasterIndex := FirstList.Count;
      Break;
    end;
  end;

  if MasterIndex < 0 then
  begin
    // No imagelists registered; nothing to insert
    Index := -1;
    Exit;
  end;

  // Add to all registered imagelists in lockstep
  for var I := 0 to FImageLists.Count - 1 do
  begin
    var Item := TJDFaviconImageList(FImageLists.Items[I]);
    if not Assigned(Item.ImageList) then
      Continue;

    Sized := GraphicToBitmap32(Source,
      Item.ImageList.Width, Item.ImageList.Height);
    try
      // Ensure alpha-aware
      Item.ImageList.ColorDepth := cd32Bit;
      Item.ImageList.DrawingStyle := dsTransparent;
      Item.ImageList.Masked := False;

      // Keep indices consistent by adding exactly one per list in order.
      Item.ImageList.Add(Sized, nil);
    finally
      Sized.Free;
    end;
  end;

  Index := MasterIndex;
end;

procedure TJDFavicons.PopulateImageList(AImageList: TImageList);
begin
  if AImageList = nil then
    Exit;
  AImageList.Clear;

  AImageList.ColorDepth := cd32Bit;
  AImageList.DrawingStyle := dsTransparent;
  AImageList.Masked := False;

  for var R in FRefs do
  begin
    if (R <> nil) and Assigned(R.Graphic) and not R.Graphic.Empty then
    begin
      var Sized := GraphicToBitmap32(R.Graphic, AImageList.Width, AImageList.Height);
      try
        AImageList.Add(Sized, nil);
      finally
        Sized.Free;
      end;
    end
    else
    begin
      // Keep index alignment even if missing graphic: insert placeholder
      var Ph: TBitmap := nil;
      try
        MakePlaceholderIcon(R.Domain, AImageList.Width, AImageList.Height, Ph);
        AImageList.Add(Ph, nil);
      finally
        Ph.Free;
      end;
    end;
  end;
end;

procedure TJDFavicons.SetImageLists(const Value: TJDFaviconImageLists);
begin
  if Value = nil then
  begin
    FImageLists.Clear;
    Exit;
  end;
  FImageLists.Assign(Value);
end;

procedure TJDFavicons.SetMode(const Value: TJDFaviconFetchMode);
begin
  FMode := Value;
end;

{ TJDFaviconImageList }

constructor TJDFaviconImageList.Create(Collection: TCollection);
begin
  inherited;
  FImageList := nil;
end;

procedure TJDFaviconImageList.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
end;

{ TJDFaviconImageLists }

constructor TJDFaviconImageLists.Create(AOwner: TJDFavicons);
begin
  inherited Create(AOwner, TJDFaviconImageList);
end;

function TJDFaviconImageLists.Add: TJDFaviconImageList;
begin
  Result := TJDFaviconImageList(inherited Add);
end;

end.


unit JD.Ctrls;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  Vcl.Controls,
  Vcl.Graphics
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  , JD.Common
  , JD.Graphics
  ;

//TODO: Change all library's custom controls to inherit from these standards...

type
  TJDControl = class;


  ///  <summary>
  ///  Base class for all JD custom controls.
  ///  Currently for the sole purpose of automatically adding this unit
  ///  to the uses clause of any form which uses a JD custom control.
  ///  Also applies to TJDCustomControl as defined in JD.Common. This way,
  ///  whenver any JD custom control is implemented on any form, both
  ///  JD.Ctrls and JD.Common are automatically included in the uses clause.
  ///  </summary>
  TJDControl = class(TJDCustomControl)

  end;




//NEW CONCEPT

type
  TJDUIBrush = class;
  TJDUIPen = class;
  TJDUILayer = class;
  TJDUILayers = class;
  TJDUICanvas = class;
  TJDUIControl = class;


  TJDUIBrushType = (
   btSolidColor,
   btHatchFill,
   btTextureFill,
   btPathGradient,
   btLinearGradient
  );

  TJDUILayerEvent = procedure(Sender: TObject; Layer: TJDUILayer) of object;

  TJDUILayerPaintEvent = procedure(Sender: TObject; Layer: TJDUILayer;
    Canvas: TJDUICanvas) of object;

  TJDUIRectVarEvent = procedure(Sender: TObject; var R: TJDRect) of object;

  TJDUIBrushClass = class of TJDUIBrush;

  TJDUIBrush = class(TPersistent)
  private
    FOwner: TPersistent;
    FColor: TJDAlphaColorRef;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TJDAlphaColorRef);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); virtual;
    destructor Destroy; override;
    procedure Invalidate;
    function MakeBrush: TGPSolidBrush; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TJDAlphaColorRef read FColor write SetColor;
  end;

  TJDUISolidBrush = class(TJDUIBrush)
  private
  end;

  TJDUIPen = class(TPersistent)
  private
    FOwner: TPersistent;
    FColor: TJDAlphaColorRef;
    FWidth: Single;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TJDAlphaColorRef);
    procedure SetWidth(const Value: Single);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); virtual;
    destructor Destroy; override;
    procedure Invalidate;
    function MakePen: TGPPen; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TJDAlphaColorRef read FColor write SetColor;
    property Width: Single read FWidth write SetWidth;
  end;

  TJDBitmap = class(TPersistent)
  private
    FOwner: TPersistent;
    FBmp: TBitmap;
    FCanvas: TJDUICanvas;
    //FWidth: Single;
    //FHeight: Single;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); virtual;
    destructor Destroy; override;
    property Canvas: TJDUICanvas read FCanvas;
  end;



  TJDUILayer = class(TCollectionItem)
  private
    FBuffer: TBitmap;
    FCanvas: TJDUICanvas;
    FName: String;
    FCanvasLock: TCriticalSection;
    FOnPaint: TJDUILayerPaintEvent;
    FVisible: Boolean;
    FInvalidated: Boolean;
    procedure SetName(const Value: String);
    procedure SetVisible(const Value: Boolean);
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function Owner: TJDUILayers;
    procedure InvalidateLayer;
    function LockCanvas: TJDUICanvas; virtual;
    procedure UnlockCanvas; virtual;
    procedure Paint; virtual;
  published
    property Name: String read FName write SetName;
    property Visible: Boolean read FVisible write SetVisible;

    property OnPaint: TJDUILayerPaintEvent read FOnPaint write FOnPaint;
  end;

  TJDUILayers = class(TOwnedCollection)
  private
    FOnGetClientRect: TJDUIRectVarEvent;
    function GetItems(const Index: Integer): TJDUILayer;
    procedure SetItems(const Index: Integer; const Value: TJDUILayer);
  protected
    procedure GetClientRect(var R: TJDRect); virtual;
  public
    constructor Create(AOwner: TPersistent); reintroduce;
    destructor Destroy; override;
    procedure Invalidate;

    procedure PaintTo(ACanvas: TJDUICanvas; const X, Y: Single); virtual;

    property Items[const Index: Integer]: TJDUILayer read GetItems write SetItems; default;

  published
    property OnGetClientRect: TJDUIRectVarEvent read FOnGetClientRect write FOnGetClientRect;
  end;

  /// <summary>
  /// Experimental canvas concept for custom controls, using GDI+.
  /// Considering attaching it to TJDCustomControl, but need to
  /// carefully consider implementation based on its complex nature.
  /// For example, window handles being destroyed / recreated.
  /// </summary>
  TJDUICanvas = class(TPersistent)
  private
    FOwner: TPersistent;
    FCanvas: TCanvas;
    FCreatedCanvas: Boolean;
    FGPCanvas: TGPGraphics;
    FPainting: Boolean;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent; ACanvas: TCanvas);
    destructor Destroy; override;
    procedure BeginPaint;
    procedure EndPaint;
    property Canvas: TCanvas read FCanvas;
    property GPCanvas: TGPGraphics read FGPCanvas;
    function ClipRect: TJDRect;

    //TODO: Drawing routines...
    procedure DrawLine(Pen: TJDUIPen; P1, P2: TJDPoint); virtual;

  published

  end;

  /// <summary>
  /// NEW CONCEPT
  /// Base control for anything using new TJDUICanvas concept
  /// </summary>
  TJDUIControl = class(TJDCustomControl)
  private
    FJDCanvas: TJDUICanvas;
    FLayers: TJDUILayers;
    procedure SetJDCanvas(const Value: TJDUICanvas);
    procedure SetLayers(const Value: TJDUILayers);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property JDCanvas: TJDUICanvas read FJDCanvas write SetJDCanvas;
    property Layers: TJDUILayers read FLayers write SetLayers;
  end;

implementation

{ TJDUIBrush }

constructor TJDUIBrush.Create(AOwner: TPersistent);
begin
  FOwner:= AOwner;
  FColor:= TJDAlphaColorRef.Create;

end;

destructor TJDUIBrush.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

function TJDUIBrush.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TJDUIBrush.Invalidate;
begin

end;

function TJDUIBrush.MakeBrush: TGPSolidBrush;
begin
  var C: TJDColor:= FColor.GetJDColor;
  Result:= TGPSolidBrush.Create(C.GDIPColor);
end;

procedure TJDUIBrush.SetColor(const Value: TJDAlphaColorRef);
begin
  FColor.Assign(Value);
end;

{ TJDUIPen }

constructor TJDUIPen.Create(AOwner: TPersistent);
begin
  FOwner:= AOwner;
  FColor:= TJDAlphaColorRef.Create;
  FWidth:= 1;

end;

function TJDUIPen.MakePen: TGPPen;
var
  C: TJDColor;
begin
  C:= FColor.GetJDColor;
  Result:= TGPPen.Create(C.GDIPColor, FWidth);
  //TODO: Implement more properties as TGPPen supports...

end;

destructor TJDUIPen.Destroy;
begin

  FreeAndNil(FColor);
  inherited;
end;

function TJDUIPen.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TJDUIPen.Invalidate;
begin

end;

procedure TJDUIPen.SetColor(const Value: TJDAlphaColorRef);
begin
  FColor.Assign(Value);
  Invalidate;
end;

procedure TJDUIPen.SetWidth(const Value: Single);
begin
  FWidth := Value;
  Invalidate;
end;

{ TJDUICanvas }

constructor TJDUICanvas.Create(AOwner: TPersistent; ACanvas: TCanvas);
begin
  FOwner:= AOwner;
  if Assigned(ACanvas) then begin
    FCanvas:= ACanvas;
    FCreatedCanvas:= False;
  end else begin
    FCanvas:= TCanvas.Create;
    //TODO
    FCreatedCanvas:= True;
  end;
end;

destructor TJDUICanvas.Destroy;
begin
  if FCreatedCanvas then
    FreeAndNil(FCanvas);
  inherited;
end;

procedure TJDUICanvas.DrawLine(Pen: TJDUIPen; P1, P2: TJDPoint);
begin
  FGPCanvas.DrawLine(Pen.MakePen, P1.X, P1.Y, P2.X, P2.Y);
end;

procedure TJDUICanvas.BeginPaint;
begin
  FPainting:= True;
  FGPCanvas:= TGPGraphics.Create(FCanvas.Handle);
end;

procedure TJDUICanvas.EndPaint;
begin
  FPainting:= False;
  FreeAndNil(FGPCanvas);
end;

function TJDUICanvas.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

function TJDUICanvas.ClipRect: TJDRect;
begin
  Result:= FCanvas.ClipRect;
end;

{ TJDUIControl }

constructor TJDUIControl.Create(AOwner: TComponent);
begin
  inherited;
  FJDCanvas:= TJDUICanvas.Create(Self, Self.Canvas);
  FLayers:= TJDUILayers.Create(Self);

end;

destructor TJDUIControl.Destroy;
begin

  FreeAndNil(FLayers);
  FreeAndNil(FJDCanvas);
  inherited;
end;

procedure TJDUIControl.Paint;
begin
  inherited;

  FLayers.PaintTo(FJDCanvas, 0, 0);

end;

procedure TJDUIControl.SetJDCanvas(const Value: TJDUICanvas);
begin
  FJDCanvas.Assign(Value);
  Invalidate;
end;

procedure TJDUIControl.SetLayers(const Value: TJDUILayers);
begin
  FLayers.Assign(Value);
  Invalidate;
end;

{ TJDUILayer }

constructor TJDUILayer.Create(Collection: TCollection);
begin
  inherited;
  FCanvasLock := TCriticalSection.Create;
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit; // Ensure proper pixel format for transparency
  //FBuffer.SetSize(Width, Height); // Set appropriate dimensions - TODO
  FCanvas := TJDUICanvas.Create(Self, FBuffer.Canvas);

end;


destructor TJDUILayer.Destroy;
begin

  FreeAndNil(FCanvas);
  FreeAndNil(FBuffer);
  FreeAndNil(FCanvasLock);
  inherited;
end;

function TJDUILayer.GetDisplayName: String;
begin
  Result:= Name;
end;

procedure TJDUILayer.InvalidateLayer;
begin
  FInvalidated:= True;

  //TODO: Now Paint will always be called so long as it's active...

  {
  var C:= LockCanvas;
  try
    C.BeginPaint;
    try
      Paint;
    finally
      C.EndPaint;
    end;
  finally
    UnlockCanvas;
  end;
  }
end;

function TJDUILayer.LockCanvas: TJDUICanvas;
begin
  FCanvasLock.Enter;
  Result:= FCanvas;
end;

function TJDUILayer.Owner: TJDUILayers;
begin
  Result:= TJDUILayers(Collection);
end;

procedure TJDUILayer.Paint;
begin
  if FInvalidated then begin
    if Assigned(Self.FOnPaint) then
      FOnPaint(Self, Self, FCanvas);
    FInvalidated:= False;
  end;
end;

procedure TJDUILayer.SetName(const Value: String);
begin
  FName := Value;
  InvalidateLayer;
end;

procedure TJDUILayer.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  InvalidateLayer;
end;

procedure TJDUILayer.UnlockCanvas;
begin
  FCanvasLock.Leave;
end;

{ TJDUILayers }

constructor TJDUILayers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJDUILayer);

end;

destructor TJDUILayers.Destroy;
begin

  inherited;
end;

procedure TJDUILayers.GetClientRect(var R: TJDRect);
begin
  if Owner is TControl then begin
    R:= (Owner as TControl).ClientRect;
  end else begin
    R.X:= 0;
    R.Y:= 0;
    R.Width:= 100;
    R.Height:= 100;
  end;

  if Assigned(FOnGetClientRect) then begin
    FOnGetClientRect(Self, R)
  end;
end;

function TJDUILayers.GetItems(const Index: Integer): TJDUILayer;
begin
  Result:= TJDUILayer(inherited GetItem(Index));
end;

procedure TJDUILayers.Invalidate;
begin
  //TODO: Notify owner...

end;

procedure TJDUILayers.PaintTo(ACanvas: TJDUICanvas; const X, Y: Single);
var
  CR: TJDRect;
begin
  GetClientRect(CR);
  ACanvas.Canvas.FillRect(CR); // Clear the canvas

  //TODO: Make this the central method to merge all layers together...
  //IMPORTANT: Use GDI+ with transparency!!!
  for var I: Integer := 0 to Count-1 do begin
    var L: TJDUILayer:= Items[I];
    if L.Visible then begin
      var C: TJDUICanvas:= L.LockCanvas;
      try
        //TODO: Paint FBuffer onto ACanvas...
        C.BeginPaint;
        try
          var Img: TGPBitmap:= TGPBitmap.Create (L.FBuffer.Handle, L.FBuffer.Palette);
          try
            C.GPCanvas.DrawImage(Img, CR);
          finally
            Img.Free;
          end;
        finally
          C.EndPaint;
        end;
      finally
        L.UnlockCanvas;
      end;
    end;
  end;
end;

procedure TJDUILayers.SetItems(const Index: Integer; const Value: TJDUILayer);
begin
  inherited SetItem(Index, Value);
end;

{ TJDBitmap }

constructor TJDBitmap.Create(AOwner: TPersistent);
begin
  FOwner:= AOwner;
  FBmp:= TBitmap.Create;
  FCanvas:= TJDUICanvas.Create(Self, FBmp.Canvas);

end;

destructor TJDBitmap.Destroy;
begin

  FreeAndNil(FCanvas);
  FreeAndNil(FBmp);
  inherited;
end;

function TJDBitmap.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

end.

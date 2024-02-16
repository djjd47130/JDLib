unit JD.Ctrls.BtnList;

interface

uses
  Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  System.Classes, System.SysUtils, System.Generics.Collections,
  JD.Ctrls, JD.Ctrls.FontButton, JD.Graphics;

type
  ///  <summary>
  ///  Represents a specific button in the TJDButtonList control.
  ///  </summary>
  TJDButtonsItem = class;

  ///  <summary>
  ///  A collection of TJDButtonsItem objects, owned by a TJDButtons control.
  ///  </summary>
  TJDButtonsItems = class;

  ///  <summary>
  ///  Groups together several buttons in a single control.
  ///  </summary>
  TJDButtons = class;


  TJDButtonsItem = class(TCollectionItem)
  private
    FCaption: String;
    FTag: Integer;
    procedure SetCaption(const Value: String);
    procedure SetTag(const Value: Integer);
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Invalidate;
  published
    property Caption: String read FCaption write SetCaption;
    //TODO: Font Glyph...
    //TODO: Overlay Glyph...
    property Tag: Integer read FTag write SetTag;
  end;

  TJDButtonsItems = class(TOwnedCollection)
  private
  public
    constructor Create(AOwner: TJDButtons); reintroduce;
    destructor Destroy; override;
  end;

  TJDButtons = class(TScrollingWinControl)
  private
    FItems: TJDButtonsItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    //TODO
  end;

implementation

{ TJDButtonListItem }

constructor TJDButtonsItem.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);

end;

destructor TJDButtonsItem.Destroy;
begin

  inherited;
end;

procedure TJDButtonsItem.Invalidate;
begin
  TJDButtons(TJDButtonsItems(Self.GetOwner).Owner).Invalidate;
end;

procedure TJDButtonsItem.SetCaption(const Value: String);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TJDButtonsItem.SetTag(const Value: Integer);
begin
  FTag := Value;
  Invalidate;
end;

{ TJDButtonsItems }

constructor TJDButtonsItems.Create(AOwner: TJDButtons);
begin
  inherited Create(AOwner, TJDButtonsItem);

end;

destructor TJDButtonsItems.Destroy;
begin

  inherited;
end;

{ TJDButtons }

constructor TJDButtons.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TJDButtonsItems.Create(Self);

end;

destructor TJDButtons.Destroy;
begin

  FreeAndNil(FItems);
  inherited;
end;

end.

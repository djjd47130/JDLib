unit JD.Ctrls.GlyphListEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DesignEditors, DesignIntf, ColnEdit,
  JD.Graphics, JD.FontGlyphs, Vcl.ComCtrls;

type
  TGlyphListEditor = class(TForm)
    ListView1: TListView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GlyphListEditor: TGlyphListEditor;

implementation

{$R *.dfm}


type
  TFontGlyphEditor = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TGlyphListComponentEditor = class(TComponentEditor)
  private
    procedure ExecEditor;
  protected
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;
  end;

{ TFontGlyphEditor }

procedure TFontGlyphEditor.Edit;
var
  F: TGlyphListEditor;
  //P: TJDFontGlyphRef;
begin
  //Initialize the property editor window
  //TODO: Why is this commented out?

  //P:= TJDFontGlyphRef(Self.GetOrdValue);

  F:= TGlyphListEditor.Create(Application);
  try
    //F.CharFont.Name:= P.FontName;
    //F.Char:= P.Glyph;
    if F.ShowModal = mrOK then begin
      //P.FontName:= F.CharFont.Name;
      //P.Glyph:= F.Char;
    end;
  finally
    F.Free;
  end;
end;

function TFontGlyphEditor.GetAttributes: TPropertyAttributes;
begin
  //Makes the small button show to the right of the property
  Result := inherited GetAttributes + [paDialog];
end;

{ TGlyphListComponentEditor }

constructor TGlyphListComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TGlyphListComponentEditor.Destroy;
begin

  inherited;
end;

procedure TGlyphListComponentEditor.ExecEditor;
begin
  //ShowCollectionEditor(Designer, Component, TRMProFontGlyphList(Component).Glyphs, 'Glyphs');
end;

procedure TGlyphListComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TGlyphListComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Glyphs';
  end;
end;

function TGlyphListComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

procedure Register;
begin
  //RegisterPropertyEditor(TypeInfo(TRMProFontGlyphList), nil, '', TFontGlyphEditor);
  //RegisterComponentEditor(TRMProFontGlyphs, TFontGlyphComponentEditor);
end;

end.

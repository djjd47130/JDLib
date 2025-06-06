unit JD.VectorEditors;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Forms, Vcl.Controls,
  DesignEditors, DesignIntf,
  JD.Vector,
  JD.Ctrls.VectorEditor,
  JD.VectorGraphicEditor;

type
  TJDVectorGraphicEditor = class(TClassProperty)
  private
    procedure EditJDVectorGraphic;
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TJDVectorImageComponentEditor = class(TComponentEditor)
  private
    procedure ExecEditor;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;

    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TJDVectorGraphic), nil, '', TJDVectorGraphicEditor);
  RegisterComponentEditor(TJDVectorImage, TJDVectorImageComponentEditor);
end;

{ TJDVectorGraphicEditor }

procedure TJDVectorGraphicEditor.Edit;
var
  ClassName: String;
begin
  //Initialize the property editor window depending on property type
  ClassName:= GetPropType.TypeData.ClassType.ClassName;
  if SameText(ClassName, 'TJDVectorGraphic') then begin
    EditJDVectorGraphic;
  end;
end;

procedure TJDVectorGraphicEditor.EditJDVectorGraphic;
var
  Frm: TfrmJDVectorEditor;
  Prop: TJDVectorGraphic;
begin
  Prop:= TJDVectorGraphic(Self.GetOrdValue);

  Frm:= TfrmJDVectorEditor.Create(Application);
  try
    Frm.LoadGraphic(Prop);
    if Frm.ShowModal = mrOK then begin
      Prop.Assign(Frm.Img.Graphic);
    end;
  finally
    Frm.Free;
  end;
end;

function TJDVectorGraphicEditor.GetAttributes: TPropertyAttributes;
begin
  //Makes the small button show to the right of the property
  Result := inherited GetAttributes + [paDialog];
end;

{ TJDVectorImageComponentEditor }

constructor TJDVectorImageComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TJDVectorImageComponentEditor.Destroy;
begin

  inherited;
end;

procedure TJDVectorImageComponentEditor.ExecEditor;
var
  Frm: TfrmJDVectorEditor;
  //Prop: TJDVectorGraphic;
begin
  //Prop:= TJDVectorImage(Self.Component).Graphic;

  Frm:= TfrmJDVectorEditor.Create(Application);
  try
    Frm.LoadGraphic(TJDVectorImage(Component).Graphic);
    if Frm.ShowModal = mrOK then begin
      TJDVectorImage(Component).Graphic.Assign(Frm.Img.Graphic);
    end;
  finally
    Frm.Free;
  end;
end;

procedure TJDVectorImageComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TJDVectorImageComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Vector Graphic';
  end;
end;

function TJDVectorImageComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

end.

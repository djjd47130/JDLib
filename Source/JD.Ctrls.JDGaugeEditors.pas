unit JD.Ctrls.JDGaugeEditors;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  JD.Ctrls.Gauges, JD.Ctrls.Gauges.Objects,
  DesignEditors, DesignIntf, VCLEditors, ColnEdit;

type

  ///  <summary>
  ///  Property editor for TJDGaugeTypeClass properties.
  ///  Allows for dynamically selecting an available gauge type
  ///  by using units which implement and register custom gauges.
  ///  </summary>
  TJDGaugeTypeProperty = class(TStringProperty)
  private
    procedure AttachType(AClass: TJDGaugeBaseClass);
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: String; override;
    procedure SetValue(const Value: String); override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TJDGaugeComponentEditor = class(TComponentEditor)
  private
    procedure ExecEditor;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;

    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(Typeinfo(TJDGaugeTypeClass), TJDGauge, 'GaugeType', TJDGaugeTypeProperty);
  RegisterComponentEditor(TJDGauge, TJDGaugeComponentEditor);
end;

{ TJDGaugeTypeProperty }

procedure TJDGaugeTypeProperty.GetValues(Proc: TGetStrProc);
var
  L: TJDGaugeClassList;
  X: Integer;
  C: TJDGaugeBaseClass;
begin
  L:= JDGaugeClasses;
  for X := 0 to L.Count-1 do begin
    C:= L[X];
    Proc(C.GetCaption);
  end;
end;

function TJDGaugeTypeProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paValueList] - [paValueEditable];
end;

function TJDGaugeTypeProperty.GetValue: String;
begin
  Result:= inherited GetValue;
end;

procedure TJDGaugeTypeProperty.SetValue(const Value: String);
var
  L: TJDGaugeClassList;
  X: Integer;
  C: TJDGaugeBaseClass;
begin
  L:= JDGaugeClasses;
  for X := 0 to L.Count-1 do begin
    C:= L[X];
    if C.GetCaption = Value then begin
      inherited SetValue(Value);
      AttachType(C);
      Break;
    end;
  end;
end;

procedure TJDGaugeTypeProperty.AttachType(AClass: TJDGaugeBaseClass);
begin
  //TODO: Attach corresponding object to control...

end;

{ TJDGaugeComponentEditor }

constructor TJDGaugeComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TJDGaugeComponentEditor.Destroy;
begin

  inherited;
end;

procedure TJDGaugeComponentEditor.ExecEditor;
begin
  ShowCollectionEditor(Designer, Component, TJDGauge(Component).Values, 'Values');
end;

procedure TJDGaugeComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TJDGaugeComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Values';
  end;
end;

function TJDGaugeComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

end.

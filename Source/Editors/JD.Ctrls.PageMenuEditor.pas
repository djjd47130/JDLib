unit JD.Ctrls.PageMenuEditor;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Dialogs,
  DesignEditors, DesignIntf, ColnEdit,
  JD.Ctrls.PageMenu;

procedure Register;

implementation

type
  TJDPageMenuComponentEditor = class(TComponentEditor)
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

{ TJDPageMenuComponentEditor }

constructor TJDPageMenuComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TJDPageMenuComponentEditor.Destroy;
begin

  inherited;
end;

procedure TJDPageMenuComponentEditor.ExecEditor;
begin
  ShowCollectionEditor(Designer, Component, TJDPageMenu(Component).Items, 'Items');
end;

procedure TJDPageMenuComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TJDPageMenuComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Items';
  end;
end;

function TJDPageMenuComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

procedure Register;
begin
  RegisterComponentEditor(TJDPageMenu, TJDPageMenuComponentEditor);
end;

end.

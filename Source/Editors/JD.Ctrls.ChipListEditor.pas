unit JD.Ctrls.ChipListEditor;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Dialogs,
  DesignEditors, DesignIntf, ColnEdit,
  JD.Ctrls.ChipList;

procedure Register;

implementation

type
  TJDChipListComponentEditor = class(TComponentEditor)
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

{ TJDChipListComponentEditor }

constructor TJDChipListComponentEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited;

end;

destructor TJDChipListComponentEditor.Destroy;
begin

  inherited;
end;

procedure TJDChipListComponentEditor.ExecEditor;
begin
  ShowCollectionEditor(Designer, Component, TJDChipList(Component).Items, 'Items');
end;

procedure TJDChipListComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: begin
      ExecEditor;
    end;
  end;
end;

function TJDChipListComponentEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result:= 'Edit Items';
  end;
end;

function TJDChipListComponentEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

procedure Register;
begin
  RegisterComponentEditor(TJDChipList, TJDChipListComponentEditor);
end;

end.

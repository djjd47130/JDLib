unit JD.Ctrls.WinControlHelper;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Controls,
  DesignEditors, DesignIntf;

type
  TControlHelper = class(TControl)
  private
    FLockChildren: Boolean;
    procedure SetLockChildren(const Value: Boolean);
    function GetLockChildren: Boolean;
  protected
    procedure DefineProperties(Filer: TFiler); override;
  published
    property LockChildren: Boolean read GetLockChildren write SetLockChildren;
  end;

  TAddPropertyFilter = class(TSelectionEditor, ISelectionPropertyFilter)
    procedure FilterProperties(const ASelection: IDesignerSelections; const
      ASelectionProperties: IInterfaceList);
  end;

implementation

{ TControlHelper }

procedure TControlHelper.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

function TControlHelper.GetLockChildren: Boolean;
begin
  Result:= FLockChildren;
end;

procedure TControlHelper.SetLockChildren(const Value: Boolean);
begin
  FLockChildren:= Value;
end;



procedure Register;
begin
  DesignIntf.RegisterSelectionEditor(TControl, TAddPropertyFilter);
end;


{ TAddPropertyFilter }

procedure TAddPropertyFilter.FilterProperties(
  const ASelection: IDesignerSelections;
  const ASelectionProperties: IInterfaceList);

begin

end;

end.

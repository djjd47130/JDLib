unit JD.Graphics.DWScript;

interface

{$DEFINE USE_GDIP}

uses
  System.SysUtils, System.Classes,
  dwsComp, dwsClasses, dwsUtils,
  dwsRTTIConnector,
  Vcl.Graphics
  {$IFDEF USE_GDIP}
  , GDIPAPI, GDIPOBJ, GDIPUTIL
  {$ENDIF}
  , JD.Common, JD.Graphics
  ;

type

  TdmJDGraphicsDWScript = class(TDataModule)
    DWS: TDelphiWebScript;
    dwsRTTIConnector1: TdwsRTTIConnector;
    dwsUnit1: TdwsUnit;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmJDGraphicsDWScript: TdmJDGraphicsDWScript;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmJDGraphicsDWScript.DataModuleCreate(Sender: TObject);
begin
  // Initialize the RTTI connector
  dwsRTTIConnector1.Script := DWS;


end;

end.

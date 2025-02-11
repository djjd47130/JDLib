unit JD.ColorPropEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DesignEditors, DesignIntf, VCLEditors,
  JD.Graphics;

type
  TJDColorProperty = class(TColorProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: String; override;
    procedure SetValue(const Value: String); override;
    //procedure ListDrawValue(); override;
    //procedure PropDrawValue(); override;
  end;

  TfrmJDColorPropEdit = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmJDColorPropEdit: TfrmJDColorPropEdit;

procedure Register;

implementation

{$R *.dfm}

procedure Register;
begin
  //TODO: Figure out why this doesn't work
  //Trying to access any component which consists of this property type
  //  results in infinite exceptions "Neutral is not a valid integer value".
  //RegisterPropertyEditor(Typeinfo(TJDStandardColor), nil, '', TJDColorProperty);
end;

{ TJDColorProperty }

procedure TJDColorProperty.GetValues(Proc: TGetStrProc);
begin
  //Vcl.Graphics.GetColorValues(Proc);
  //fcNeutral, fcLtGray, fcMdGray, fcDkGray, fcBlue, fcGreen, fcRed, fcYellow, fcOrange, fcPurple
  Proc('Neutral');
  Proc('Light Gray');
  Proc('Med Gray');
  Proc('Dark Gray');
  Proc('Blue');
  Proc('Green');
  Proc('Red');
  Proc('Yellow');
  Proc('Orange');
  Proc('Purple');
end;

function TJDColorProperty.GetValue: String;
begin
  if TJDStandardColor(GetOrdValue) = fcNeutral then
    Result := 'Neutral'
  else
    Result := inherited GetValue;
end;

procedure TJDColorProperty.SetValue(const Value: String);
begin
  if AnsiSameText(Value, 'Neutral') then
    SetOrdValue(Integer(fcNeutral))
  else
    inherited SetValue(Value);
end;

end.

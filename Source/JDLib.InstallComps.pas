unit JDLib.InstallComps;

interface

uses
  System.Classes,
  JD.Ctrls.FontButton,
  JD.Ctrls.SideMenu,
  JD.SmoothMove,
  JD.PageMenu,
  JD.ImageGrid,
  JD.Weather;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JD Components',
    [TFontButton, TSmoothMove, TPageMenu, TImageGrid, TSideMenu, TJDWeather]);
end;

end.

unit JDLib.InstallComps;

interface

uses
  System.Classes,
  JD.Ctrls.FontButton,
  JD.Ctrls.LeftToolbar,
  JD.SmoothMove,
  JD.PageMenu,
  JD.ImageGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JD Components',
    [TFontButton, TSmoothMove, TPageMenu, TImageGrid, TLeftToolbar]);
end;

end.

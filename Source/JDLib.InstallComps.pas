unit JDLib.InstallComps;

interface

uses
  System.Classes,
  JD.Ctrls,
  JD.SmoothMove,
  JD.FontGlyphs,
  JD.VolumeControls,
  JD.SysMon,
  JD.Ctrls.FontButton,
  JD.Ctrls.SideMenu,
  JD.Ctrls.PageMenu,
  JD.Ctrls.ControlList,
  JD.Ctrls.ImageGrid,
  JD.Ctrls.Gauges;

const
  JD_TAB_CAPTION = 'JD Components';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents(JD_TAB_CAPTION,
    [TJDFontButton, TJDFontGlyphs, TJDSmoothMove, TJDPageMenu, TJDSideMenu,
    TJDGauge, TJDVolumeControls, TJDSystemMonitor]);
end;

end.

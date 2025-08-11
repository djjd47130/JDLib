unit JDLib.InstallComps;

interface

uses
  System.Classes,
  JD.Logs,
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
  JD.Ctrls.Gauges,
  JD.Ctrls.PlotChart,
  JD.Vector,
  JD.Ctrls.VectorEditor,
  JD.Ctrls.ChipList,
  JD.Ctrls.ListBox,
  JD.Favicons;

const
  JD_TAB_CAPTION = 'JD Components';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents(JD_TAB_CAPTION,
    [TJDFontButton, TJDFontGlyphs, TJDSmoothMove, TJDPageMenu, TJDSideMenu,
    TJDGauge, TJDVolumeControls, TJDSystemMonitor, TJDPlotChart,
    TJDVectorImage, TJDLogger, TJDFileLogger, TJDConsoleLogger, TJDChipList,
    TImageGrid, TJDListBox, TJDFavicons]);
end;

end.

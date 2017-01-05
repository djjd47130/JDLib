unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  JD.Weather, Vcl.ComCtrls, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList;

type
  TfrmMain = class(TForm)
    Weather: TJDWeather;
    lstCurrent: TListView;
    pRight: TPanel;
    lstForecast: TListView;
    lstAlerts: TListView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    imgCurrent: TImageList;
    imgForecast: TImageList;
    imgMap: TImage;
    procedure FormCreate(Sender: TObject);
    procedure WeatherConditions(Sender: TObject; const Conditions: IWeatherConditions);
    procedure WeatherForecast(Sender: TObject; const Forecast: IWeatherForecast);
    procedure WeatherAlerts(Sender: TObject; const Alerts: IWeatherAlerts);
    procedure WeatherMaps(Sender: TObject; const Image: IWeatherMaps);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //ReportMemoryLeaksOnShutdown:= True;
  pRight.Align:= alClient;
  lstForecast.Align:= alClient;
  Width:= 950;
  Height:= 650;
end;

procedure TfrmMain.WeatherConditions(Sender: TObject; const Conditions: IWeatherConditions);
var
  B: TBitmap;
  procedure AC(const N, V: String; const Img: Integer = -1);
  var
    I: TListItem;
  begin
    I:= lstCurrent.Items.Add;
    I.Caption:= N;
    I.SubItems.Add(V);
    I.ImageIndex:= Img;
  end;
begin
  lstCurrent.Items.BeginUpdate;
  try
    lstCurrent.Items.Clear;
    imgCurrent.Clear;

    B:= TBitmap.Create;
    try
      if Assigned(Conditions.Picture.Graphic) then begin
        B.Assign(Conditions.Picture.Graphic);
        imgCurrent.Add(B, nil);
        AC('Location', Conditions.Location.DisplayName, 0);
      end else begin
        AC('Location', Conditions.Location.DisplayName, -1);
      end;
    finally
      B.Free;
    end;

    AC('Coords', FormatFloat('0.0000', Conditions.Location.Longitude)+', '+
      FormatFloat('0.0000', Conditions.Location.Latitude));
    AC('Country', Conditions.Location.Country);
    AC('Temp', FormatFloat('0.0', Conditions.Temp)+'° F');
    AC('Wind', DegreeToDir(Conditions.WindDir)+' @ '+FormatFloat('0.0', Conditions.WindSpeed)+' MPH');
    AC('Relative Humidity', FormatFloat('0.0', Conditions.Humidity));
    AC('Dew Point', FormatFloat('0.0', Conditions.DewPoint)+'° F');
    AC('Air Pressure', FormatFloat('0.0', Conditions.Pressure));
    AC('Visibility', FormatFloat('0.0', Conditions.Visibility)+' Miles');
    AC('Condition', Conditions.Condition);
    AC('Description', Conditions.Description);

  finally
    lstCurrent.Items.EndUpdate;
  end;
end;

procedure TfrmMain.WeatherForecast(Sender: TObject;
  const Forecast: IWeatherForecast);
var
  X: Integer;
  F: IWeatherForecastItem;
  B: TBitmap;
  procedure AF(const DT: TDateTime; const C, D: String; const Img: Integer);
  var
    I: TListItem;
  begin
    I:= lstForecast.Items.Add;
    //I.Caption:= FormatDateTime('m/d/yy h:nn AMPM', DT);
    I.Caption:= C;
    //I.SubItems.Add(C);
    I.SubItems.Add(D);
    I.ImageIndex:= Img;
  end;
begin
  lstForecast.Items.BeginUpdate;
  try
    lstForecast.Items.Clear;
    imgForecast.Clear;

    B:= TBitmap.Create;
    try
      for X := 0 to Forecast.Count-1 do begin
        F:= Forecast.Items[X];
        B.Assign(F.Picture.Graphic);
        imgForecast.Add(B, nil);
        AF(F.DateTime, F.Condition, F.Description, X);
      end;
    finally
      B.Free;
    end;

  finally
    lstForecast.Items.EndUpdate;
  end;
end;

procedure TfrmMain.WeatherAlerts(Sender: TObject; const Alerts: IWeatherAlerts);
var
  X: Integer;
  A: IWeatherAlert;
  procedure AA(const DT, Exp: TDateTime; const C, D: String);
  var
    I: TListItem;
  begin
    I:= lstAlerts.Items.Add;
    I.Caption:= FormatDateTime('m/d/yy h:nn AMPM', DT);
    I.SubItems.Add(FormatDateTime('m/d/yy h:nn AMPM', Exp));
    I.SubItems.Add(C);
    I.SubItems.Add(D);
  end;
begin
  lstAlerts.Items.BeginUpdate;
  try
    lstAlerts.Items.Clear;

    for X := 0 to Alerts.Count-1 do begin
      A:= Alerts.Items[X];
      AA(A.DateTime, A.Expires, A.Description, A.Msg);
    end;

  finally
    lstAlerts.Items.EndUpdate;
  end;
end;

procedure TfrmMain.WeatherMaps(Sender: TObject; const Image: IWeatherMaps);
begin
  imgMap.Picture.Assign(Image.Maps[TWeatherMapType.mpSatelliteRadar]);
end;

end.

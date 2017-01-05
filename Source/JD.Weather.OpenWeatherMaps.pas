unit JD.Weather.OpenWeatherMaps;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TOWMEndpoint = (oeConditions, oeForecast, oeAlerts, oeMaps);

  TOWMWeatherThread = class(TJDWeatherThread)
  public
    function GetEndpointUrl(const Endpoint: TOWMEndpoint): String;
  public
    function Support: TWeatherThreadFunctions; override;
    function GetUrl: String; override;
    function DoAll(Conditions: TWeatherConditions; Forecast: TWeatherForecast;
      ForecastDaily: TWeatherForecast; ForecastHourly: TWeatherForecast;
      Alerts: TWeatherAlerts; Maps: TWeatherMaps): Boolean; override;
    function DoConditions(Conditions: TWeatherConditions): Boolean; override;
    function DoForecast(Forecast: TWeatherForecast): Boolean; override;
    function DoForecastHourly(Forecast: TWeatherForecast): Boolean; override;
    function DoForecastDaily(Forecast: TWeatherForecast): Boolean; override;
    function DoAlerts(Alerts: TWeatherAlerts): Boolean; override;
    function DoMaps(Maps: TWeatherMaps): Boolean; override;
  end;



implementation

uses
  DateUtils, StrUtils, Math;

{ TOWMWeatherThread }

function TOWMWeatherThread.Support: TWeatherThreadFunctions;
begin
  Result:= [tfConditionByZip, tfConditionByCoords, tfConditionByCity,
    tfConditionByIP, tafForecastByZip, tfForecastByCoords, tfForecastByCity,
    tfForecastByIP, tfMapsByZip, tfMapsByCoords, tfMapsByCity,
    tfMapsByIP];
end;

function TOWMWeatherThread.GetEndpointUrl(const Endpoint: TOWMEndpoint): String;
begin
  case Endpoint of
    oeConditions: Result:= 'weather';
    oeForecast:   Result:= 'forecast';
    oeAlerts:     Result:= 'alerts'; //TODO
    oeMaps:       Result:= 'maps'; //TODO
  end;
  Result:= GetUrl + Result + '?appid='+Owner.Key;
  case Owner.Units of
    wuKelvin:   ;
    wuImperial: Result:= Result + '&units=imperial';
    wuMetric:   Result:= Result + '&units=metric';
  end;
end;

function TOWMWeatherThread.GetUrl: String;
begin
  Result:= 'http://api.openweathermap.org/data/2.5/';
end;

function TOWMWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
begin
  Result:= False;
  //NOT SUPPORTED
end;

function TOWMWeatherThread.DoAll(Conditions: TWeatherConditions; Forecast,
  ForecastDaily, ForecastHourly: TWeatherForecast; Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

function TOWMWeatherThread.DoConditions(
  Conditions: TWeatherConditions): Boolean;
begin
  Result:= False;

end;

function TOWMWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TOWMWeatherThread.DoForecastDaily(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TOWMWeatherThread.DoForecastHourly(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TOWMWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

end.

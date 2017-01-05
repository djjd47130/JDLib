unit JD.Weather.Foreca;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TForecaWeatherThread = class(TJDWeatherThread)
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

{ TForecaWeatherThread }

function TForecaWeatherThread.Support: TWeatherThreadFunctions;
begin
  Result:= [];
end;

function TForecaWeatherThread.GetUrl: String;
begin
  Result:= 'http://apitest.foreca.net/';
  Result:= Result + '?key='+Owner.Key;
  Result:= Result + '&format=json';
  //http://apitest.foreca.net/?lon=24.934&lat=60.1755&key=yxDYDu3IIlRJzjBVaoje7jtLa4A&format=json
end;

function TForecaWeatherThread.DoAll(Conditions: TWeatherConditions; Forecast,
  ForecastDaily, ForecastHourly: TWeatherForecast; Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoConditions(Conditions: TWeatherConditions): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoForecastDaily(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoForecastHourly(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
begin
  Result:= False;

end;

function TForecaWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

end.

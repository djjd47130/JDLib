unit JD.Weather.NWS;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TNWSWeatherThread = class(TJDWeatherThread)
  public

  public
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

{ TNWSWeatherThread }

function TNWSWeatherThread.GetUrl: String;
begin
  Result:= ''; //TODO
end;

function TNWSWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoAll(Conditions: TWeatherConditions; Forecast,
  ForecastDaily, ForecastHourly: TWeatherForecast; Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoConditions(
  Conditions: TWeatherConditions): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoForecastDaily(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoForecastHourly(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNWSWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

end.

unit JD.Weather.NOAA;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TNOAAEndpoint = (noeDatasets, noeDataCategories, noeDataTypes, noeLocationCategories,
    noeLocations, noeStations, noeData);

  TNOAAWeatherThread = class(TJDWeatherThread)
  public
    function GetEndpointUrl(const Endpoint: TNOAAEndpoint): String;
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

{ TNOAAWeatherThread }

function TNOAAWeatherThread.Support: TWeatherThreadFunctions;
begin
  Result:= [tfConditionByZip, tfConditionByCoords, tfConditionByCity,
    tfConditionByIP, tafForecastByZip, tfForecastByCoords, tfForecastByCity, tfForecastByIP,
    tfAlertsByZip, tfAlertsByCoords, tfAlertsByCity, tfAlertsByIP, tfMapsByZip,
    tfMapsByCoords, tfMapsByCity, tfMapsByIP];
end;

function TNOAAWeatherThread.GetUrl: String;
begin
  Result:= 'http://www.ncdc.noaa.gov/cdo-web/api/v2/';
end;

function TNOAAWeatherThread.GetEndpointUrl(
  const Endpoint: TNOAAEndpoint): String;
begin
  Result:= GetUrl;
  case Endpoint of
    noeDatasets:            Result:= Result + 'datasets/';
    noeDataCategories:      Result:= Result + 'datacategories/';
    noeDataTypes:           Result:= Result + 'datatypes/';
    noeLocationCategories:  Result:= Result + 'locationcategories/';
    noeLocations:           Result:= Result + 'locations/';
    noeStations:            Result:= Result + 'stations/';
    noeData:                Result:= Result + 'data/';
  end;
end;

function TNOAAWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoAll(Conditions: TWeatherConditions; Forecast,
  ForecastDaily, ForecastHourly: TWeatherForecast; Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoConditions(
  Conditions: TWeatherConditions): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoForecastDaily(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoForecastHourly(
  Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TNOAAWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

end.

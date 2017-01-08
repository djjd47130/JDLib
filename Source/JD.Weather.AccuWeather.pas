unit JD.Weather.AccuWeather;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TAWEndpoint = (aeLocations, aeConditions, aeAlerts, aeDailyIndices,
    aeAlarms, aeClimo, aeTropical, aeTidal, aeDaily, aeHourly, aeImagery,
    aeTranslate, aeLocal);

  TAWWeatherThread = class(TJDWeatherThread)
  private
    FLocationKey: String;
    FLocationType: TJDWeatherLocationType;
    FLocation1: String;
    FLocation2: String;
    FLocation: ISuperObject;
    function Get(const U: String): ISuperObject;
  public
    function GetEndpointUrl(const Endpoint: TAWEndpoint;
      const S: String): String;
    procedure InvalidateLocation;
    procedure CheckLocation;
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

{ TAWWeatherThread }

function TAWWeatherThread.GetEndpointUrl(const Endpoint: TAWEndpoint;
  const S: String): String;
begin
  case Endpoint of
    aeLocations:    Result:= 'locations/v1/';
    aeConditions:   Result:= 'currentconditions/v1/';
    aeAlerts:       Result:= 'alerts/v1/';
    aeDailyIndices: Result:= 'indices/v1/';
    aeAlarms:       Result:= 'alarms/v1/';
    aeClimo:        Result:= 'climo/v1/';
    aeTropical:     Result:= 'tropical/v1/';
    aeTidal:        Result:= 'tidal/v1/';
    aeDaily:        Result:= 'forecasts/v1/daily/';
    aeHourly:       Result:= 'forecasts/v1/hourly/';
    aeImagery:      Result:= 'imagery/v1/';
    aeTranslate:    Result:= 'translations/v1/';
    aeLocal:        Result:= 'localweather/v1/';
  end;
  Result:= GetUrl + Result;
  Result:= Result + S + '.json?apikey='+Owner.Key;

//http://api.accuweather.com/alerts/v1/334907.json?apikey={your key}&details=true

//http://api.accuweather.com/locations/v1/cities/geoposition/search.json?q=40.59, -73.58&apikey={your key}

// http://api.accuweather.com/
// locations/
// v1/cities/geoposition/search
// .json
// ?apikey={your key}
// &q=40.59, -73.58

end;

function TAWWeatherThread.GetUrl: String;
begin
  Result:= 'http://apidev.accuweather.com/';
end;

procedure TAWWeatherThread.CheckLocation;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  if FLocationKey <> '' then Exit;

  //TODO: Connect to API and identify location
  //Save location identifier to FLocationKey

  case Owner.LocationType of
    wlZip:        U:= GetEndpointUrl(TAWEndpoint.aeLocations,
      'poastalcodes/search')+'&q='+FLocation1;
    wlCityState:  U:= GetEndpointUrl(TAWEndpoint.aeLocations,
      'cities/US/search')+'&q='+FLocation1+','+FLocation2;
    wlCoords:     U:= GetEndpointUrl(TAWEndpoint.aeLocations,
      'cities/geoposition/search')+'&q='+FLocation1+','+FLocation2;
    wlAutoIP:     U:= GetEndpointUrl(TAWEndpoint.aeLocations,
      'cities/ipaddress')+'&q='+FLocation1;
  end;

  S:= Web.Get(U);
  O:= SO(S);
  if Assigned(O) then begin
    FLocation:= O;
    FLocationKey:= O.S['Key'];

  end;

end;

procedure TAWWeatherThread.InvalidateLocation;
begin
  FLocationKey:= '';
end;

function TAWWeatherThread.Get(const U: String): ISuperObject;
var
  S: String;
begin
  Result:= nil;
  S:= Web.Get(U);
  Result:= SO(S);
end;

function TAWWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
var
  U: String;
  S1, S2: String;
  O: ISuperObject;
begin
  Result:= False;
  S1:= Owner.LocationDetail1;
  S2:= Owner.LocationDetail2;
  if Owner.LocationType <> FLocationType then begin
    FLocationType:= Owner.LocationType;
    InvalidateLocation;
  end;
  if S1 <> FLocation1 then begin
    FLocation1:= S1;
    InvalidateLocation;
  end;
  if S2 <> FLocation2 then begin
    FLocation2:= S2;
    InvalidateLocation;
  end;
  CheckLocation;

  U:= Self.GetEndpointUrl(TAWEndpoint.aeAlerts, FLocationKey);
  O:= Get(U);

  //TODO: Populate alerts structure

end;

function TAWWeatherThread.DoAll(Conditions: TWeatherConditions; Forecast,
  ForecastDaily, ForecastHourly: TWeatherForecast; Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

function TAWWeatherThread.DoConditions(Conditions: TWeatherConditions): Boolean;
begin
  Result:= False;

end;

function TAWWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TAWWeatherThread.DoForecastDaily(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TAWWeatherThread.DoForecastHourly(Forecast: TWeatherForecast): Boolean;
begin
  Result:= False;

end;

function TAWWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
begin
  Result:= False;

end;

end.

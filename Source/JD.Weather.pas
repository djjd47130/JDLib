unit JD.Weather;

(*
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

  ▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓    ▓▓▓▓▓▓          ▓▓▓      ▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓
  ▓▓▓    ▓▓▓  ▓▓▓       ▓▓▓▓  ▓▓▓▓  ▓▓▓  ▓▓▓        ▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓       ▓▓▓
  ▓▓▓    ▓▓▓  ▓▓▓       ▓▓▓    ▓▓▓  ▓▓▓   ▓▓▓       ▓▓▓  ▓▓  ▓▓▓  ▓▓▓       ▓▓▓
  ▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓  ▓▓▓   ▓▓▓       ▓▓▓  ▓▓  ▓▓▓  ▓▓▓▓▓▓▓   ▓▓▓
  ▓▓▓   ▓▓▓   ▓▓▓       ▓▓▓    ▓▓▓  ▓▓▓   ▓▓▓       ▓▓▓      ▓▓▓  ▓▓▓       ▓▓▓
  ▓▓▓    ▓▓▓  ▓▓▓       ▓▓▓    ▓▓▓  ▓▓▓  ▓▓▓        ▓▓▓      ▓▓▓  ▓▓▓
  ▓▓▓    ▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓    ▓▓▓  ▓▓▓▓▓▓          ▓▓▓      ▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

  JD Weather
  by Jerry Dodge

  Component: TJDWeather
  - Encapsulates entire API wrapper system to pull weather data from various
    different weather APIs.
  - Adapts a standard structure to multiple different weather services
  - Dedicated thread to perform periodic checks on a given interval
  - Events triggered upon changes on conditions, forecast, alerts, and maps

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

  How to use:
  - Subscribe to one of the supported services
  - Acquire an API Key which authenticates your account
  - Select the service by assigning TJDWeather.Service
  - Enter your API Key by assigning TJDWeather.Key
  - Specify the frequency of each different weather information type
      NOTE: The numbers are seconds between calls
      IMPORTANT: Depending on which service you choose, your account will be likely
      limited to a certain number of requests in a given day. Therefore, it is
      very important to adjust these frequency properties to correspond with
      your particular account's capabilities. Sometimes, this may mean
      ten to twenty minutes between checks for weather, if your account
      has a low limit, or if you use the app in multiple places.
  - Select your desired location by assigning TJDWeather.LocationType
    - wlAutoIP: Automatically detects your location based on your IP Address
    - wlCityState: Assign City to "LocationDetail1" and State to "LocationDetail2"
    - wlZip: Assign Zip Code to "LocationDetail1"
    - wlCoords: Assign Longitude to "LocationDetail1" and Latitude to "LocationDetail2"
        NOTE: Format of each property must be with numeric digits such as:
        45.9764
        -15.9724
  - Assign event handlers to the desired weather information
      NOTE: Weather information is actually provided when these events are fired.
      You are responsible to acquire a copy of the corresponding weather interface
      from the event handler's parameters and store your own reference.
      These interfaces are by default reference-counted.

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

  SUPPORTED WEATHER SERVICES:

  - Weather Underground
    - https://www.wunderground.com/weather/api/d/docs?d=index
    - Implemented in JD.Weather.WUnderground.pas
    - Location by Zip, City/State, IP, Coords
    - Current Conditions
    - Forecast - 8 Half Days
    - Forecast - 4, 10 Days
    - Forecast - 10, 20 Hours
    - Alerts
    - Alerts with Storm Info
    - Maps - Satellite
    - Maps - Radar

  - [Coming Soon] Open Weather Maps
    - https://openweathermap.org/api
    - Implemented in JD.Weather.OpenWeatherMaps.pas
    - Location by Zip, City/State, Coords
    - Current Conditions
    - Forecast - 40 x 3hrs (5 Days)
    - Maps - Satellite
    - Maps - Radar
    - UNSUPPORTED:
      - Forecast - Hourly
      - Alerts

  - [Coming Soon] Accu Weather
    - http://apidev.accuweather.com/developers/
    - Implemented in JD.Weather.AccuWeather.pas
    - NOTE: There is no straight-forward way to acquire API Key. I've emailed
      twice and still have no response.
    - Location by Zip, City/State, Coords
    - Current Conditions
    - Forecast - 1, 12, 24, 72, 120, 240 Hours
    - Forecast - 1, 5, 10, 15, 25 Days
    - Alerts
    - Maps - Satellite
    - Maps - Radar

  - [Coming Soon] Foreca
    - http://corporate.foreca.com/en/products-services/data/weather-api
    - Implemented in JD.Weather.Foreca.pas
    - Location by Coords
    - Current Conditions
    - Forecast - 56 Hours
    - Forecast - 10 Days

  - [Coming Soon] National Weather Service
    - http://forecast-v3.weather.gov/documentation
    - Implemented in JD.Weather.NWS.pas
    - May remove - looks like just raw current weather station data

  - [Coming Soon] NOAA
    - https://www.ncdc.noaa.gov/cdo-web/webservices/v2#gettingStarted
    - Implemented in JD.Weather.NOAA.pas
    - May remove - looks like just raw current weather station data

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

  TODO:
  - Implement "Supported..." functions to reflect what each service supports
  - Implement caching of weather data as to not fetch too often
  - Implement weather maps
    - Radar
    - Satellite
    - Radar AND Satellite Combined
  - Standardize the forecast formats
    - Hourly - X number of hours
    - Daily - X number of days
    - Summary - Half day, plain text
  - Detect coordinates based on IP
    - Supposedly location services does this, but doesn't work in some cases...
  - Finish implementing all services

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
*)

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  SuperObject,
  IdHTTP;

const
  clOrange = $00003AB3;
  clLightOrange = $002F73FF;
  clIceBlue = $00FFFFD2;
  clLightRed = $00B0B0FF;

type

  ///<summary>
  ///  Specifies a particular weather info service provider.
  ///</summary>
  TWeatherService = (wsOpenWeatherMap, wsWUnderground, wsNWS,
    wsNOAA, wsAccuWeather, wsForeca);

  ///<summary>
  ///  Specifies different types of measurement units.
  ///</summary>
  TWeatherUnits = (wuKelvin, wuImperial, wuMetric);

  ///<summary>
  ///  Specifies different types of weather alerts.
  ///</summary>
  TWeatherAlertType = (waNone, waHurricaneStat, waTornadoWarn, waTornadoWatch, waSevThundWarn,
    waSevThundWatch, waWinterAdv, waFloodWarn, waFloodWatch, waHighWind, waSevStat,
    waHeatAdv, waFogAdv, waSpecialStat, waFireAdv, waVolcanicStat, waHurricaneWarn,
    waRecordSet, waPublicRec, waPublicStat);

  ///<summary>
  ///  Specifies different types of weather phenomena.
  ///</summary>
  TWeatherAlertPhenomena = (wpWind, wpHeat, wpSmallCraft);

  ///<summary>
  ///  Specifies whether it's day or night.
  ///</summary>
  TDayNight = (dnDay, dnNight);

  ///<summary>
  ///  Specifies the type of cloud cover.
  ///</summary>
  TCloudCode = (ccClear = 0, ccAlmostClear = 1, ccHalfCloudy = 2, ccBroken = 3,
    ccOvercast = 4, ccThinClouds = 5, ccFog = 6);

  ///<summary>
  ///  Specifies the level of precipitation.
  ///</summary>
  TPrecipCode = (pcNone = 0, pcSlight = 1, pcShowers = 2, pcPrecip = 3, pcThunder = 4);

  ///<summary>
  ///  Specifies the type of precipitation.
  ///</summary>
  TPrecipTypeCode = (ptRain = 0, ptSleet = 1, ptSnow = 2);

  ///<summary>
  ///  Represents standard weather condition information, and is
  ///  interchangable with a standard string format.
  ///</summary>
  TWeatherCode = record
  public
    DayNight: TDayNight;
    Clouds: TCloudCode;
    Precip: TPrecipCode;
    PrecipType: TPrecipTypeCode;
    class operator Implicit(const Value: TWeatherCode): String;
    class operator Implicit(const Value: String): TWeatherCode;
    class operator Implicit(const Value: TWeatherCode): Integer;
    class operator Implicit(const Value: Integer): TWeatherCode;
    function Description: String;
    function Name: String;
    function DayNightStr: String;
  end;

//Interface Definitions

{$REGION "Interface Definitions"}

  IWeatherLocation = interface
    function GetDisplayName: WideString;
    function GetCity: WideString;
    function GetState: WideString;
    function GetStateAbbr: WideString;
    function GetCountry: WideString;
    function GetCountryAbbr: WideString;
    function GetLongitude: Double;
    function GetLatitude: Double;
    function GetElevation: Double;
    function GetZipCode: WideString;
    property DisplayName: WideString read GetDisplayName;
    property City: WideString read GetCity;
    property State: WideString read GetState;
    property StateAbbr: WideString read GetStateAbbr;
    property Country: WideString read GetCountry;
    property CountryAbbr: WideString read GetCountryAbbr;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
    property Elevation: Double read GetElevation;
    property ZipCode: WideString read GetZipCode;
  end;

  TWeatherConditionsProp = (cpPressureMB, cpPressureIn, cpWindDir, cpWindSpeed,
    cpHumidity, cpVisibility, cpDewPoint, cpHeatIndex, cpWindGust, cpWindChill,
    cpFeelsLike, cpSolarRad, cpUV, cpTemp, cpTempMin, cpTempMax, cpPrecip,
    cpIcon, cpCaption, cpDescription, cpStation, cpClouds,
    cpRain, cpSnow, cpSunrise, cpSunset);
  TWeatherConditionsProps = set of TWeatherConditionsProp;

  IWeatherConditions = interface
    function GetPicture: TPicture;
    function GetLocation: IWeatherLocation;
    function GetDateTime: TDateTime;
    function GetTemp: Single;
    function GetHumidity: Single;
    function GetPressure: Single;
    function GetCondition: WideString;
    function GetDescription: WideString;
    function GetWindDir: Single;
    function GetWindSpeed: Single;
    function GetVisibility: Single;
    function GetDewPoint: Single;
    function SupportedProps: TWeatherConditionsProps;
    property Picture: TPicture read GetPicture;
    property Location: IWeatherLocation read GetLocation;
    property DateTime: TDateTime read GetDateTime;
    property Temp: Single read GetTemp;
    property Humidity: Single read GetHumidity;
    property Pressure: Single read GetPressure;
    property Condition: WideString read GetCondition;
    property Description: WideString read GetDescription;
    property WindSpeed: Single read GetWindSpeed;
    property WindDir: Single read GetWindDir;
    property Visibility: Single read GetVisibility;
    property DewPoint: Single read GetDewPoint;
  end;

  TWeatherForecastProp = (fpPressureMB, fpPressureIn, fpWindDir, fpWindSpeed,
    fpHumidity, fpVisibility, fpDewPoint, fpHeatIndex, fpWindGust, fpWindChill,
    fpFeelsLike, fpSolarRad, fpUV, fpTemp, fpTempMin, fpTempMax, fpCaption,
    fpDescription, fpIcon, fpGroundPressure, fpSeaPressure, fpPrecip, fpURL, fpDaylight);
  TWeatherForecastProps = set of TWeatherForecastProp;

  IWeatherForecastItem = interface
    function GetPicture: TPicture;
    function GetDateTime: TDateTime;
    function GetTemp: Single;
    function GetTempMax: Single;
    function GetTempMin: Single;
    function GetHumidity: Single;
    function GetPressure: Single;
    function GetCondition: WideString;
    function GetDescription: WideString;
    function GetWindDir: Single;
    function GetWindSpeed: Single;
    function GetVisibility: Single;
    function GetDewPoint: Single;
    function SupportedProps: TWeatherForecastProps;
    property Picture: TPicture read GetPicture;
    property DateTime: TDateTime read GetDateTime;
    property Temp: Single read GetTemp;
    property TempMin: Single read GetTempMin;
    property TempMax: Single read GetTempMax;
    property Humidity: Single read GetHumidity;
    property Pressure: Single read GetPressure;
    property Condition: WideString read GetCondition;
    property Description: WideString read GetDescription;
    property WindSpeed: Single read GetWindSpeed;
    property WindDir: Single read GetWindDir;
    property Visibility: Single read GetVisibility;
    property DewPoint: Single read GetDewPoint;
  end;

  IWeatherForecast = interface
    function GetLocation: IWeatherLocation;
    function GetItem(const Index: Integer): IWeatherForecastItem;
    function Count: Integer;
    function MinTemp: Single;
    function MaxTemp: Single;
    property Location: IWeatherLocation read GetLocation;
    property Items[const Index: Integer]: IWeatherForecastItem read GetItem; default;
  end;

  IWeatherAlertZone = interface
    function GetState: WideString;
    function GetZone: WideString;
    property State: WideString read GetState;
    property Zone: WideString read GetZone;
  end;

  IWeatherAlertZones = interface
    function GetItem(const Index: Integer): IWeatherAlertZone;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherAlertZone read GetItem; default;
  end;

  IWeatherStormVertex = interface
    function GetLongitude: Double;
    function GetLatitude: Double;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
  end;

  IWeatherStormVerticies = interface
    function GetItem(const Index: Integer): IWeatherStormVertex;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherStormVertex read GetItem; default;
  end;

  IWeatherAlertStorm = interface
    function GetDateTime: TDateTime;
    function GetDirection: Single;
    function GetSpeed: Single;
    function GetLongitude: Double;
    function GetLatitude: Double;
    function GetVerticies: IWeatherStormVerticies;
    property DateTime: TDateTime read GetDateTime;
    property Direction: Single read GetDirection;
    property Speed: Single read GetDirection;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
    property Verticies: IWeatherStormVerticies read GetVerticies;
  end;

  TWeatherAlertProp = (apZones, apVerticies, apStorm, apType, apDescription,
    apExpires, apMessage, apPhenomena, apSignificance);
  TWeatherAlertProps = set of TWeatherAlertProp;

  IWeatherAlert = interface
    function GetAlertType: TWeatherAlertType;
    function GetDescription: WideString;
    function GetDateTime: TDateTime;
    function GetExpires: TDateTime;
    function GetMsg: WideString;
    function GetPhenomena: WideString;
    function GetSignificance: WideString;
    function GetZones: IWeatherAlertZones;
    function GetStorm: IWeatherAlertStorm;
    function SupportedFunctions: TWeatherAlertProps;
    property AlertType: TWeatherAlertType read GetAlertType;
    property Description: WideString read GetDescription;
    property DateTime: TDateTime read GetDateTime;
    property Expires: TDateTime read GetExpires;
    property Msg: WideString read GetMsg;
    property Phenomena: WideString read GetPhenomena;
    property Significance: WideString read GetSignificance;
    property Zones: IWeatherAlertZones read GetZones;
    property Storm: IWeatherAlertStorm read GetStorm;
  end;

  IWeatherAlerts = interface
    function GetItem(const Index: Integer): IWeatherAlert;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherAlert read GetItem; default;
  end;

  TWeatherMapType = (mpSatellite, mpRadar, mpSatelliteRadar, mpRadarClouds,
    mpClouds, mpTemp, mpTempChange, mpSnowCover, mpPrecip, mpAlerts, mpHeatIndex,
    mpDewPoint, mpWindChill, mpPressureSea, mpWind,
    mpAniSatellite, mpAniRadar, mpAniSatelliteRadar);
  TWeatherMapTypes = set of TWeatherMapType;

  IWeatherMaps = interface
    function GetMap(const MapType: TWeatherMapType): TPicture;
    function SupportedFunctions: TWeatherMapTypes;
    property Maps[const MapType: TWeatherMapType]: TPicture read GetMap;
  end;

{$ENDREGION}







//Interface Implementation Objects

{$REGION "Interface Implementation Objects"}

  { Interface Implementation Objects }

  TJDWeatherThread = class;

  TWeatherLocation = class(TInterfacedObject, IWeatherLocation)
  public
    FDisplayName: WideString;
    FCity: WideString;
    FState: WideString;
    FStateAbbr: WideString;
    FCountry: WideString;
    FCountryAbbr: WideString;
    FLongitude: Double;
    FLatitude: Double;
    FElevation: Double;
    FZipCode: WideString;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetDisplayName: WideString;
    function GetCity: WideString;
    function GetState: WideString;
    function GetStateAbbr: WideString;
    function GetCountry: WideString;
    function GetCountryAbbr: WideString;
    function GetLongitude: Double;
    function GetLatitude: Double;
    function GetElevation: Double;
    function GetZipCode: WideString;
    property DisplayName: WideString read GetDisplayName;
    property City: WideString read GetCity;
    property State: WideString read GetState;
    property StateAbbr: WideString read GetStateAbbr;
    property Country: WideString read GetCountry;
    property CountryAbbr: WideString read GetCountryAbbr;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
    property Elevation: Double read GetElevation;
    property ZipCode: WideString read GetZipCode;
  end;

  TWeatherConditions = class(TInterfacedObject, IWeatherConditions)
  public
    FPicture: TPicture;
    FOwner: TJDWeatherThread;
    FLocation: TWeatherLocation;
    FDateTime: TDateTime;
    FTemp: Single;
    FHumidity: Single;
    FPressure: Single;
    FCondition: WideString;
    FDescription: WideString;
    FWindSpeed: Single;
    FWindDir: Single;
    FVisibility: Single;
    FDewPoint: Single;
  public
    constructor Create(AOwner: TJDWeatherThread);
    destructor Destroy; override;
  public
    function GetPicture: TPicture;
    function GetLocation: IWeatherLocation;
    function GetDateTime: TDateTime;
    function GetTemp: Single;
    function GetHumidity: Single;
    function GetPressure: Single;
    function GetCondition: WideString;
    function GetDescription: WideString;
    function GetWindDir: Single;
    function GetWindSpeed: Single;
    function GetVisibility: Single;
    function GetDewPoint: Single;
    function SupportedProps: TWeatherConditionsProps;
    property Picture: TPicture read GetPicture;
    property Location: IWeatherLocation read GetLocation;
    property DateTime: TDateTime read GetDateTime;
    property Temp: Single read GetTemp;
    property Humidity: Single read GetHumidity;
    property Pressure: Single read GetPressure;
    property Condition: WideString read GetCondition;
    property Description: WideString read GetDescription;
    property WindSpeed: Single read GetWindSpeed;
    property WindDir: Single read GetWindDir;
    property Visibility: Single read GetVisibility;
    property DewPoint: Single read GetDewPoint;
  end;

  TWeatherForecast = class;

  TWeatherForecastItem = class(TInterfacedObject, IWeatherForecastItem)
  public
    FOwner: TWeatherForecast;
    FPicture: TPicture;
    FDateTime: TDateTime;
    FTemp: Single;
    FTempMin: Single;
    FTempMax: Single;
    FHumidity: Single;
    FPressure: Single;
    FCondition: WideString;
    FDescription: WideString;
    FWindSpeed: Single;
    FWindDir: Single;
    FVisibility: Single;
    FDewPoint: Single;
  public
    constructor Create(AOwner: TWeatherForecast);
    destructor Destroy; override;
  public
    function GetPicture: TPicture;
    function GetDateTime: TDateTime;
    function GetTemp: Single;
    function GetTempMax: Single;
    function GetTempMin: Single;
    function GetHumidity: Single;
    function GetPressure: Single;
    function GetCondition: WideString;
    function GetDescription: WideString;
    function GetWindDir: Single;
    function GetWindSpeed: Single;
    function GetVisibility: Single;
    function GetDewPoint: Single;
    function SupportedProps: TWeatherForecastProps;
    property Picture: TPicture read GetPicture;
    property DateTime: TDateTime read GetDateTime;
    property Temp: Single read GetTemp;
    property TempMin: Single read GetTempMin;
    property TempMax: Single read GetTempMax;
    property Humidity: Single read GetHumidity;
    property Pressure: Single read GetPressure;
    property Condition: WideString read GetCondition;
    property Description: WideString read GetDescription;
    property WindSpeed: Single read GetWindSpeed;
    property WindDir: Single read GetWindDir;
    property Visibility: Single read GetVisibility;
    property DewPoint: Single read GetDewPoint;
  end;

  TWeatherForecast = class(TInterfacedObject, IWeatherForecast)
  public
    FOwner: TJDWeatherThread;
    FItems: TList<IWeatherForecastItem>;
    FLocation: TWeatherLocation;
    procedure Clear;
  public
    constructor Create(AOwner: TJDWeatherThread);
    destructor Destroy; override;
  public
    function GetLocation: IWeatherLocation;
    function GetItem(const Index: Integer): IWeatherForecastItem;
    function Count: Integer;
    function MinTemp: Single;
    function MaxTemp: Single;
    property Location: IWeatherLocation read GetLocation;
    property Items[const Index: Integer]: IWeatherForecastItem read GetItem; default;
  end;

  TWeatherStormVertex = class(TInterfacedObject, IWeatherStormVertex)
  public
    FLongitude: Double;
    FLatitude: Double;
  public
    function GetLongitude: Double;
    function GetLatitude: Double;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
  end;

  TWeatherStormVerticies = class(TInterfacedObject, IWeatherStormVerticies)
  public
    FItems: TList<IWeatherStormVertex>;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetItem(const Index: Integer): IWeatherStormVertex;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherStormVertex read GetItem; default;
  end;

  TWeatherAlertStorm = class(TInterfacedObject, IWeatherAlertStorm)
  public
    FDateTime: TDateTime;
    FDirection: Single;
    FSpeed: Single;
    FLongitude: Double;
    FLatitude: Double;
    FVerticies: TWeatherStormVerticies;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetDateTime: TDateTime;
    function GetDirection: Single;
    function GetSpeed: Single;
    function GetLongitude: Double;
    function GetLatitude: Double;
    function GetVerticies: IWeatherStormVerticies;
    property DateTime: TDateTime read GetDateTime;
    property Direction: Single read GetDirection;
    property Speed: Single read GetDirection;
    property Longitude: Double read GetLongitude;
    property Latitude: Double read GetLatitude;
    property Verticies: IWeatherStormVerticies read GetVerticies;
  end;

  TWeatherAlertZone = class(TInterfacedObject, IWeatherAlertZone)
  public
    FState: WideString;
    FZone: WideString;
  public
    function GetState: WideString;
    function GetZone: WideString;
    property State: WideString read GetState;
    property Zone: WideString read GetZone;
  end;

  TWeatherAlertZones = class(TInterfacedObject, IWeatherAlertZones)
  public
    FItems: TList<TWeatherAlertZone>;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetItem(const Index: Integer): IWeatherAlertZone;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherAlertZone read GetItem; default;
  end;

  TWeatherAlert = class(TInterfacedObject, IWeatherAlert)
  public
    FOwner: TJDWeatherThread;
    FAlertType: TWeatherAlertType;
    FDescription: WideString;
    FDateTime: TDateTime;
    FExpires: TDateTime;
    FMsg: WideString;
    FPhenomena: WideString;
    FSignificance: WideString;
    FZones: TWeatherAlertZones;
    FStorm: TWeatherAlertStorm;
  public
    constructor Create(AOwner: TJDWeatherThread);
    destructor Destroy; override;
  public
    function GetAlertType: TWeatherAlertType;
    function GetDescription: WideString;
    function GetDateTime: TDateTime;
    function GetExpires: TDateTime;
    function GetMsg: WideString;
    function GetPhenomena: WideString;
    function GetSignificance: WideString;
    function GetZones: IWeatherAlertZones;
    function GetStorm: IWeatherAlertStorm;
    function SupportedFunctions: TWeatherAlertProps;
    property AlertType: TWeatherAlertType read GetAlertType;
    property Description: WideString read GetDescription;
    property DateTime: TDateTime read GetDateTime;
    property Expires: TDateTime read GetExpires;
    property Msg: WideString read GetMsg;
    property Phenomena: WideString read GetPhenomena;
    property Significance: WideString read GetSignificance;
    property Zones: IWeatherAlertZones read GetZones;
    property Storm: IWeatherAlertStorm read GetStorm;
  end;

  TWeatherAlerts = class(TInterfacedObject, IWeatherAlerts)
  public
    FItems: TList<IWeatherAlert>;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetItem(const Index: Integer): IWeatherAlert;
    function Count: Integer;
    property Items[const Index: Integer]: IWeatherAlert read GetItem; default;
  end;

  TMapArray = array[TWeatherMapType] of TPicture;

  TWeatherMaps = class(TInterfacedObject, IWeatherMaps)
  public
    FOwner: TJDWeatherThread;
    FMaps: TMapArray;
  public
    constructor Create(AOwner: TJDWeatherThread);
    destructor Destroy; override;
  public
    function GetMap(const MapType: TWeatherMapType): TPicture;
    function SupportedFunctions: TWeatherMapTypes;
    property Maps[const MapType: TWeatherMapType]: TPicture read GetMap;
  end;

{$ENDREGION}









//Weather Thread Base

{$REGION "Weather Thread Base"}

  TJDWeatherLocationType = (wlZip, wlCityState, wlCoords, wlAutoIP);

  TWeatherConditionsEvent = procedure(Sender: TObject; const Conditions: IWeatherConditions) of object;

  TWeatherForecastEvent = procedure(Sender: TObject; const Forecast: IWeatherForecast) of object;

  TWeatherAlertEvent = procedure(Sender: TObject; const Alert: IWeatherAlerts) of object;

  TWeatherMapEvent = procedure(Sender: TObject; const Image: IWeatherMaps) of object;

  TJDWeather = class;

  TWeatherThreadFunction = (tfConditionByZip, tfConditionByCoords, tfConditionByCity,
    tfConditionByIP, tafForecastByZip, tfForecastByCoords, tfForecastByCity, tfForecastByIP,
    tfAlertsByZip, tfAlertsByCoords, tfAlertsByCity, tfAlertsByIP, tfMapsByZip,
    tfMapsByCoords, tfMapsByCity, tfMapsByIP);
  TWeatherThreadFunctions = set of TWeatherThreadFunction;

  TJDWeatherThread = class(TThread)
  private
    FOwner: TJDWeather;
    FWeb: TIdHTTP;
    FLastAll: TDateTime;
    FConditions: TWeatherConditions;
    FLastConditions: TDateTime;
    FForecast: TWeatherForecast;
    FLastForecast: TDateTime;
    FForecastHourly: TWeatherForecast;
    FLastForecastHourly: TDateTime;
    FForecastDaily: TWeatherForecast;
    FLastForecastDaily: TDateTime;
    FMaps: TWeatherMaps;
    FLastMaps: TDateTime;
    FAlerts: TWeatherAlerts;
    FLastAlerts: TDateTime;
    FOnConditions: TWeatherConditionsEvent;
    FOnForecast: TWeatherForecastEvent;
    FOnForecastDaily: TWeatherForecastEvent;
    FOnForecastHourly: TWeatherForecastEvent;
    FOnAlerts: TWeatherAlertEvent;
    FOnMaps: TWeatherMapEvent;
    procedure CheckAll;
    procedure CheckConditions;
    procedure CheckForecast;
    procedure CheckForecastHourly;
    procedure CheckForecastDaily;
    procedure CheckAlerts;
    procedure CheckMaps;
  protected
    procedure Execute; override;
    procedure Process;
    procedure SYNC_DoOnConditions;
    procedure SYNC_DoOnForecast;
    procedure SYNC_DoOnForecastHourly;
    procedure SYNC_DoOnForecastDaily;
    procedure SYNC_DoOnAlerts;
    procedure SYNC_DoOnMaps;
  public
    constructor Create(AOwner: TJDWeather); reintroduce;
    destructor Destroy; override;
    function Owner: TJDWeather;
    function Web: TIdHTTP;
    function LoadPicture(const U: String; const P: TPicture): Boolean;
  public
    property OnConditions: TWeatherConditionsEvent read FOnConditions write FOnConditions;
    property OnForecast: TWeatherForecastEvent read FOnForecast write FOnForecast;
    property OnForecastHourly: TWeatherForecastEvent read FOnForecastHourly write FOnForecastHourly;
    property OnForecastDaily: TWeatherForecastEvent read FOnForecastDaily write FOnForecastDaily;
    property OnAlerts: TWeatherAlertEvent read FOnAlerts write FOnAlerts;
    property OnMaps: TWeatherMapEvent read FOnMaps write FOnMaps;
  public
    function Support: TWeatherThreadFunctions; virtual; abstract;
    function GetUrl: String; virtual; abstract;
    function DoAll(Conditions: TWeatherConditions; Forecast: TWeatherForecast;
      ForecastDaily: TWeatherForecast; ForecastHourly: TWeatherForecast;
      Alerts: TWeatherAlerts; Maps: TWeatherMaps): Boolean; virtual; abstract;
    function DoConditions(Conditions: TWeatherConditions): Boolean; virtual; abstract;
    function DoForecast(Forecast: TWeatherForecast): Boolean; virtual; abstract;
    function DoForecastHourly(Forecast: TWeatherForecast): Boolean; virtual; abstract;
    function DoForecastDaily(Forecast: TWeatherForecast): Boolean; virtual; abstract;
    function DoAlerts(Alerts: TWeatherAlerts): Boolean; virtual; abstract;
    function DoMaps(Maps: TWeatherMaps): Boolean; virtual; abstract;
  end;

{$ENDREGION}












//Main TJDWeather Component

{$REGION "Main TJDWeather Component"}

  ///<summary>
  ///  Encapsulates multiple weather service info providers into a single
  ///  standardized multi-threaded component.
  ///</summary>
  TJDWeather = class(TComponent)
  private
    FThread: TJDWeatherThread;
    FService: TWeatherService;
    FActive: Boolean;
    FAllFreq: Integer;
    FConditionFreq: Integer;
    FForecastFreq: Integer;
    FMapsFreq: Integer;
    FAlertsFreq: Integer;
    FOnConditions: TWeatherConditionsEvent;
    FOnForecast: TWeatherForecastEvent;
    FOnAlerts: TWeatherAlertEvent;
    FOnMaps: TWeatherMapEvent;
    FKey: String;
    FLocationType: TJDWeatherLocationType;
    FLocationDetail2: String;
    FLocationDetail1: String;
    FUnits: TWeatherUnits;
    FAllAtOnce: Boolean;
    FOnForecastDaily: TWeatherForecastEvent;
    FOnForecastHourly: TWeatherForecastEvent;
    FWantedMaps: TWeatherMapTypes;
    procedure EnsureThread;
    procedure DestroyThread;
    procedure ThreadConditions(Sender: TObject; const Conditions: IWeatherConditions);
    procedure ThreadForecast(Sender: TObject; const Forecast: IWeatherForecast);
    procedure ThreadForecastHourly(Sender: TObject; const Forecast: IWeatherForecast);
    procedure ThreadForecastDaily(Sender: TObject; const Forecast: IWeatherForecast);
    procedure ThreadAlerts(Sender: TObject; const Alert: IWeatherAlerts);
    procedure ThreadMaps(Sender: TObject; const Maps: IWeatherMaps);
    procedure SetService(const Value: TWeatherService);
    procedure SetConditionFreq(const Value: Integer);
    procedure SetForecastFreq(const Value: Integer);
    procedure SetActive(const Value: Boolean);
    procedure SetMapsFreq(const Value: Integer);
    procedure SetKey(const Value: String);
    procedure SetLocationType(const Value: TJDWeatherLocationType);
    procedure SetLocationDetail1(const Value: String);
    procedure SetLocationDetail2(const Value: String);
    procedure SetAlertsFreq(const Value: Integer);
    procedure SetUnits(const Value: TWeatherUnits);
    procedure SetAllFreq(const Value: Integer);
    procedure SetAllAtOnce(const Value: Boolean);
    procedure SetWantedMaps(const Value: TWeatherMapTypes);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
  published
    ///<summary>
    ///  Identifies the desired weather service provider to use.
    ///  Be sure to use an appropriate API Key for the chosen service
    ///  and provide it in the "Key" property.
    ///</summary>
    property Service: TWeatherService read FService write SetService;

    ///<summary>
    ///  Combines all different weather information into single increments.
    ///  This drastically saves on the number of API calls for those services
    ///  which have strict limitations.
    ///</summary>
    property AllAtOnce: Boolean read FAllAtOnce write SetAllAtOnce;

    ///<summary>
    ///  Specifies whether or not the component is active. Enabling will begin
    ///  fetching weather information from the service, and disabling will
    ///  stop it. NOTE: Active has no effect in design-time.
    ///</summary>
    property Active: Boolean read FActive write SetActive;

    ///<summary>
    ///  Number of seconds between performing full checks of all pieces
    ///  of weather information. All other specific frequencies are ignored
    ///  when "AllAtOnce" is enabled, and this is used instead.
    ///</summary>
    property AllFreq: Integer read FAllFreq write SetAllFreq;

    ///<summary>
    ///  Number of seconds between performing checks for Current Conditions.
    ///</summary>
    property ConditionFreq: Integer read FConditionFreq write SetConditionFreq;

    ///<summary>
    ///  Number of seconds between performing checks for Forecasts.
    ///</summary>
    property ForecastFreq: Integer read FForecastFreq write SetForecastFreq;

    ///<summary>
    ///  Number of seconds between performing checks for Maps.
    ///</summary>
    property MapsFreq: Integer read FMapsFreq write SetMapsFreq;

    ///<summary>
    ///  Number of seconds between performing checks for Alerts.
    ///</summary>
    property AlertsFreq: Integer read FAlertsFreq write SetAlertsFreq;

    ///<summary>
    ///  The API Key issued from the chosen weather service provider. When
    ///  changing "Service", this key must also change to correspond.
    ///</summary>
    property Key: String read FKey write SetKey;

    ///<summary>
    ///  The method of specifying the current location for weather information.
    ///  Changing this value requires updating the values in:
    ///  LocationDetail1
    ///  LocationDetail2
    ///</summary>
    property LocationType: TJDWeatherLocationType read FLocationType write SetLocationType;

    ///<summary>
    ///  The first piece of information to identify the location
    ///  - Zip Code
    ///  - Longitude Coordinate
    ///  - City
    ///  - IP Address [NOT YET SUPPORTED]
    ///</summary>
    property LocationDetail1: String read FLocationDetail1 write SetLocationDetail1;

    ///<summary>
    ///  The second piece of information to identify the location
    ///  - Latitude Coordinate
    ///  - State
    ///</summary>
    property LocationDetail2: String read FLocationDetail2 write SetLocationDetail2;

    ///<summary>
    ///  Unit of measurement
    ///  - Kelvin [NOT SUPPORTED]
    ///  - Imperial - Ferenheit, Feet, Inches, Miles...
    ///  - Metric - Celcius, Meters, Centimeters, Kilometers...
    ///</summary>
    property Units: TWeatherUnits read FUnits write SetUnits;

    property WantedMaps: TWeatherMapTypes read FWantedMaps write SetWantedMaps;




    ///<summary>
    ///  Triggered when new weather conditions are available.
    ///</summary>
    property OnConditions: TWeatherConditionsEvent read FOnConditions write FOnConditions;

    ///<summary>
    ///  Triggered when new weather forecasts are available.
    ///</summary>
    property OnForecast: TWeatherForecastEvent read FOnForecast write FOnForecast;

    ///<summary>
    ///  Triggered when new weather forecasts are available.
    ///</summary>
    property OnForecastHourly: TWeatherForecastEvent read FOnForecastHourly write FOnForecastHourly;

    ///<summary>
    ///  Triggered when new weather forecasts are available.
    ///</summary>
    property OnForecastDaily: TWeatherForecastEvent read FOnForecastDaily write FOnForecastDaily;

    ///<summary>
    ///  Triggered when new weather alerts are available.
    ///</summary>
    property OnAlerts: TWeatherAlertEvent read FOnAlerts write FOnAlerts;

    ///<summary>
    ///  Triggered when new weather maps are available.
    ///</summary>
    property OnMaps: TWeatherMapEvent read FOnMaps write FOnMaps;

  end;

{$ENDREGION}

function TempColor(const Temp: Single): TColor;

///<summary>
///  Converts a degree angle to a cardinal direction string
///</summary>
function DegreeToDir(const D: Single): String;

///<summary>
///  Converts an epoch integer to local TDateTime
///</summary>
function EpochLocal(const Value: Integer): TDateTime; overload;

///<summary>
///  Converts an epoch string to local TDateTime
///</summary>
function EpochLocal(const Value: String): TDateTime; overload;

function LocalDateTimeFromUTCDateTime(const UTCDateTime: TDateTime): TDateTime;

implementation

uses
  DateUtils, StrUtils, Math,
  JD.Weather.OpenWeatherMaps,
  JD.Weather.WUnderground,
  JD.Weather.AccuWeather,
  JD.Weather.Foreca,
  JD.Weather.NWS,
  JD.Weather.NOAA;

function TempColor(const Temp: Single): TColor;
var
  T: Integer;
begin
  T:= Trunc(Temp);
  case T of
    -99999..32: Result:= clIceBlue;
    33..55:     Result:= clSkyBlue;
    56..73:     Result:= clMoneyGreen;
    74..90:     Result:= clLightRed;
    91..99999:  Result:= clLightOrange;
    else        Result:= clWhite;
  end;
end;

function DegreeToDir(const D: Single): String;
var
  I: Integer;
begin
  I:= Trunc(D);
  case I of
    0..11,348..365: Result:= 'N';
    12..33: Result:= 'NNE';
    34..56: Result:= 'NE';
    57..78: Result:= 'ENE';
    79..101: Result:= 'E';
    102..123: Result:= 'ESE';
    124..146: Result:= 'SE';
    147..168: Result:= 'SSE';
    169..191: Result:= 'S';
    192..213: Result:= 'SSW';
    214..236: Result:= 'SW';
    237..258: Result:= 'WSW';
    259..281: Result:= 'W';
    282..303: Result:= 'WNW';
    304..326: Result:= 'NW';
    327..347: Result:= 'NNW';
  end;
end;

function EpochLocal(const Value: Integer): TDateTime; overload;
begin
  Result:= UnixToDateTime(Value);
  Result:= LocalDateTimeFromUTCDateTime(Result);
end;

function EpochLocal(const Value: String): TDateTime; overload;
begin
  Result:= EpochLocal(StrToIntDef(Value, 0));
end;

function LocalDateTimeFromUTCDateTime(const UTCDateTime: TDateTime): TDateTime;
var
  LocalSystemTime: TSystemTime;
  UTCSystemTime: TSystemTime;
  LocalFileTime: TFileTime;
  UTCFileTime: TFileTime;
begin
  DateTimeToSystemTime(UTCDateTime, UTCSystemTime);
  SystemTimeToFileTime(UTCSystemTime, UTCFileTime);
  if FileTimeToLocalFileTime(UTCFileTime, LocalFileTime)
  and FileTimeToSystemTime(LocalFileTime, LocalSystemTime) then begin
    Result := SystemTimeToDateTime(LocalSystemTime);
  end else begin
    Result := UTCDateTime;  // Default to UTC if any conversion function fails.
  end;
end;

{ TWeatherCode }

class operator TWeatherCode.Implicit(const Value: TWeatherCode): String;
begin
  case Value.DayNight of
    dnDay:    Result:= 'd';
    dnNight:  Result:= 'n';
  end;
  Result:= Result + IntToStr(Integer(Value.Clouds));
  Result:= Result + IntToStr(Integer(Value.Precip));
  Result:= Result + IntToStr(Integer(Value.PrecipType));
end;

class operator TWeatherCode.Implicit(const Value: String): TWeatherCode;
begin
  if Length(Value) <> 4 then raise Exception.Create('Value must be 4 characters.');

  case Value[1] of
    'd','D': Result.DayNight:= TDayNight.dnDay;
    'n','N': Result.DayNight:= TDayNight.dnNight;
    else raise Exception.Create('First value must be either d, D, n, or N.');
  end;

  if CharInSet(Value[2], ['0'..'6']) then
    Result.Clouds:= TCloudCode(StrToIntDef(Value[2], 0))
  else
    raise Exception.Create('Second value must be between 0 and 6.');

  if CharInSet(Value[3], ['0'..'4']) then
    Result.Precip:= TPrecipCode(StrToIntDef(Value[3], 0))
  else
    raise Exception.Create('Third value must be between 0 and 4.');

  if CharInSet(Value[4], ['0'..'2']) then
    Result.PrecipType:= TPrecipTypeCode(StrToIntDef(Value[4], 0))
  else
    raise Exception.Create('Fourth value must be between 0 and 2.');
end;

function TWeatherCode.DayNightStr: String;
begin
  case DayNight of
    dnDay:    Result:= 'Day';
    dnNight:  Result:= 'Night';
  end;
end;

function TWeatherCode.Description: String;
begin
  case Clouds of
    ccClear:        Result:= 'Clear';
    ccAlmostClear:  Result:= 'Mostly Clear';
    ccHalfCloudy:   Result:= 'Partly Cloudy';
    ccBroken:       Result:= 'Cloudy';
    ccOvercast:     Result:= 'Overcast';
    ccThinClouds:   Result:= 'Thin High Clouds';
    ccFog:          Result:= 'Fog';
  end;
  case PrecipType of
    ptRain: begin
      case Precip of
        pcNone:         Result:= Result + '';
        pcSlight:       Result:= Result + ' with Light Rain';
        pcShowers:      Result:= Result + ' with Rain Showers';
        pcPrecip:       Result:= Result + ' with Rain';
        pcThunder:      Result:= Result + ' with Rain and Thunderstorms';
      end;
    end;
    ptSleet: begin
      case Precip of
        pcNone:         Result:= Result + '';
        pcSlight:       Result:= Result + ' with Light Sleet';
        pcShowers:      Result:= Result + ' with Sleet Showers';
        pcPrecip:       Result:= Result + ' with Sleet';
        pcThunder:      Result:= Result + ' with Sleet and Thunderstorms';
      end;
    end;
    ptSnow: begin
      case Precip of
        pcNone:         Result:= Result + '';
        pcSlight:       Result:= Result + ' with Light Snow';
        pcShowers:      Result:= Result + ' with Snow Showers';
        pcPrecip:       Result:= Result + ' with Snow';
        pcThunder:      Result:= Result + ' with Snow and Thunderstorms';
      end;
    end;
  end;
end;

class operator TWeatherCode.Implicit(const Value: TWeatherCode): Integer;
begin
  Result:= Integer(Value.DayNight);
  Result:= Result + (Integer(Value.Clouds) * 10);
  Result:= Result + (Integer(Value.Precip) * 100);
  Result:= Result + (Integer(Value.PrecipType) * 1000);
end;

class operator TWeatherCode.Implicit(const Value: Integer): TWeatherCode;
begin
  //Result.DayNight:= TDayNight();
end;

function TWeatherCode.Name: String;
begin
  //TODO: Return unique standardized name
  case Clouds of
    ccClear:        Result:= 'clear_';
    ccAlmostClear:  Result:= 'almost_clear_';
    ccHalfCloudy:   Result:= 'half_cloudy_';
    ccBroken:       Result:= 'broken_clouds_';
    ccOvercast:     Result:= 'overcast_';
    ccThinClouds:   Result:= 'thin_clouds_';
    ccFog:          Result:= 'fog_';
  end;
  case PrecipType of
    ptRain: begin
      case Precip of
        pcNone:     Result:= Result + '';
        pcSlight:   Result:= Result + 'rain_slight';
        pcShowers:  Result:= Result + 'rain_showers';
        pcPrecip:   Result:= Result + 'rain';
        pcThunder:  Result:= Result + 'rain_and_thunder';
      end;
    end;
    ptSleet: begin
      case Precip of
        pcNone:     Result:= Result + '';
        pcSlight:   Result:= Result + 'sleet_slight';
        pcShowers:  Result:= Result + 'sleet_showers';
        pcPrecip:   Result:= Result + 'sleet';
        pcThunder:  Result:= Result + 'sleet_and_thunder';
      end;
    end;
    ptSnow: begin
      case Precip of
        pcNone:     Result:= Result + '';
        pcSlight:   Result:= Result + 'snow_slight';
        pcShowers:  Result:= Result + 'snow_showers';
        pcPrecip:   Result:= Result + 'snow';
        pcThunder:  Result:= Result + 'snow_and_thunder';
      end;
    end;
  end;
end;

//Common Object Implementation

{$REGION "Common Object Implementation"}

{ TWeatherLocation }

constructor TWeatherLocation.Create;
begin

end;

destructor TWeatherLocation.Destroy;
begin

  inherited;
end;

function TWeatherLocation.GetCity: WideString;
begin
  Result:= FCity;
end;

function TWeatherLocation.GetCountry: WideString;
begin
  Result:= FCountry;
end;

function TWeatherLocation.GetCountryAbbr: WideString;
begin
  Result:= FCountryAbbr;
end;

function TWeatherLocation.GetDisplayName: WideString;
begin
  Result:= FDisplayName;
end;

function TWeatherLocation.GetElevation: Double;
begin
  Result:= FElevation;
end;

function TWeatherLocation.GetLatitude: Double;
begin
  Result:= FLatitude;
end;

function TWeatherLocation.GetLongitude: Double;
begin
  Result:= FLongitude;
end;

function TWeatherLocation.GetState: WideString;
begin
  Result:= FState;
end;

function TWeatherLocation.GetStateAbbr: WideString;
begin
  Result:= FStateAbbr;
end;

function TWeatherLocation.GetZipCode: WideString;
begin
  Result:= FZipCode;
end;

{ TWeatherConditions }

constructor TWeatherConditions.Create(AOwner: TJDWeatherThread);
begin
  FOwner:= AOwner;
  FLocation:= TWeatherLocation.Create;
  FLocation._AddRef;
  FPicture:= TPicture.Create;
end;

destructor TWeatherConditions.Destroy;
begin
  FreeAndNil(FPicture);
  FLocation._Release;
  FLocation:= nil;
  inherited;
end;

function TWeatherConditions.GetCondition: WideString;
begin
  Result:= FCondition;
end;

function TWeatherConditions.GetDateTime: TDateTime;
begin
  Result:= FDateTime;
end;

function TWeatherConditions.GetDescription: WideString;
begin
  Result:= FDescription;
end;

function TWeatherConditions.GetDewPoint: Single;
begin
  Result:= FDewPoint;
end;

function TWeatherConditions.GetHumidity: Single;
begin
  Result:= FHumidity;
end;

function TWeatherConditions.GetLocation: IWeatherLocation;
begin
  Result:= FLocation;
end;

function TWeatherConditions.GetPicture: TPicture;
begin
  Result:= FPicture;
end;

function TWeatherConditions.GetPressure: Single;
begin
  Result:= FPressure;
end;

function TWeatherConditions.GetTemp: Single;
begin
  Result:= FTemp;
end;

function TWeatherConditions.GetVisibility: Single;
begin
  Result:= FVisibility;
end;

function TWeatherConditions.GetWindDir: Single;
begin
  Result:= FWindDir;
end;

function TWeatherConditions.GetWindSpeed: Single;
begin
  Result:= FWindSpeed;
end;

function TWeatherConditions.SupportedProps: TWeatherConditionsProps;
begin
  case FOwner.FOwner.FService of
    wsOpenWeatherMap: Result:= [cpPressureMb, cpWindDir, cpWindSpeed,
      cpVisibility, cpHumidity, cpCaption, cpDescription, cpClouds,
      cpRain, cpSnow, cpSunrise, cpSunset, cpTemp, cpTempMin, cpTempMax];
    wsWUnderground: Result:= [cpPressureMB, cpPressureIn, cpWindDir,
      cpWindSpeed, cpHumidity, cpVisibility, cpDewPoint, cpHeatIndex,
      cpWindGust, cpWindChill, cpFeelsLike, cpSolarRad, cpUV, cpTemp,
      cpTempMin, cpTempMax, cpPrecip, cpIcon, cpCaption, cpDescription,
      cpStation];
    wsAccuWeather:      Result:= [
      ];
    wsNWS:              Result:= [
      ];
    wsNOAA:             Result:= [
      ];
  end;
end;

{ TWeatherForecastItem }

constructor TWeatherForecastItem.Create(AOwner: TWeatherForecast);
begin
  FOwner:= AOwner;
  FPicture:= TPicture.Create;
end;

destructor TWeatherForecastItem.Destroy;
begin
  FreeAndNil(FPicture);
  inherited;
end;

function TWeatherForecastItem.GetCondition: WideString;
begin
  Result:= FCondition;
end;

function TWeatherForecastItem.GetDateTime: TDateTime;
begin
  Result:= FDateTime;
end;

function TWeatherForecastItem.GetDescription: WideString;
begin
  Result:= FDescription;
end;

function TWeatherForecastItem.GetDewPoint: Single;
begin
  Result:= FDewPoint;
end;

function TWeatherForecastItem.GetHumidity: Single;
begin
  Result:= FHumidity;
end;

function TWeatherForecastItem.GetPicture: TPicture;
begin
  Result:= FPicture;
end;

function TWeatherForecastItem.GetPressure: Single;
begin
  Result:= FPressure;
end;

function TWeatherForecastItem.GetTemp: Single;
begin
  Result:= FTemp;
end;

function TWeatherForecastItem.GetTempMax: Single;
begin
  Result:= FTempMax;
end;

function TWeatherForecastItem.GetTempMin: Single;
begin
  Result:= FTempMin;
end;

function TWeatherForecastItem.GetVisibility: Single;
begin
  Result:= FVisibility;
end;

function TWeatherForecastItem.GetWindDir: Single;
begin
  Result:= FWindDir;
end;

function TWeatherForecastItem.GetWindSpeed: Single;
begin
  Result:= FWindSpeed;
end;

function TWeatherForecastItem.SupportedProps: TWeatherForecastProps;
begin
  case FOwner.FOwner.FOwner.FService of
    wsOpenWeatherMap:   Result:= [fpPressureMB, fpWindDir, fpWindSpeed,
      fpHumidity, fpTemp, fpTempMin, fpTempMax, fpCaption, fpDescription,
      fpIcon, fpGroundPressure, fpSeaPressure];
    wsWUnderground: begin
      Result:= [fpWindDir, fpWindSpeed, fpHumidity, fpTemp, fpTempMin,
        fpTempMax, fpCaption, fpDescription, fpIcon];
    end;
    wsAccuWeather:      Result:= [fpIcon, fpCaption, fpTemp, fpPrecip,
      fpURL, fpDaylight];
    wsNWS:              Result:= [
      ];
    wsNOAA:             Result:= [
      ];
  end;
end;

{ TWeatherForecast }

constructor TWeatherForecast.Create(AOwner: TJDWeatherThread);
begin
  FOwner:= AOwner;
  FItems:= TList<IWeatherForecastItem>.Create;
  FLocation:= TWeatherLocation.Create;
  FLocation._AddRef;
end;

procedure TWeatherForecast.Clear;
var
  X: Integer;
begin
  for X := 0 to FItems.Count-1 do begin
    FItems[X]._Release;
  end;
  FLocation._Release;
  FLocation:= nil;
  FItems.Clear;
end;

destructor TWeatherForecast.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited;
end;

function TWeatherForecast.Count: Integer;
begin
  Result:= FItems.Count;
end;

function TWeatherForecast.GetItem(const Index: Integer): IWeatherForecastItem;
begin
  Result:= FItems[Index];
end;

function TWeatherForecast.GetLocation: IWeatherLocation;
begin
  Result:= FLocation;
end;

function TWeatherForecast.MaxTemp: Single;
var
  X: Integer;
begin
  Result:= -9999999;
  for X := 0 to FItems.Count-1 do begin
    if FItems[X].Temp > Result then
      Result:= FItems[X].Temp;
  end;
end;

function TWeatherForecast.MinTemp: Single;
var
  X: Integer;
begin
  Result:= 9999999;
  for X := 0 to FItems.Count-1 do begin
    if FItems[X].Temp < Result then
      Result:= FItems[X].Temp;
  end;
end;

{ TWeatherStormVertex }

function TWeatherStormVertex.GetLatitude: Double;
begin
  Result:= FLatitude;
end;

function TWeatherStormVertex.GetLongitude: Double;
begin
  Result:= FLongitude;
end;

{ TWeatherStormVerticies }

constructor TWeatherStormVerticies.Create;
begin
  FItems:= TList<IWeatherStormVertex>.Create;
end;

destructor TWeatherStormVerticies.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited;
end;

function TWeatherStormVerticies.Count: Integer;
begin
  Result:= FItems.Count;
end;

procedure TWeatherStormVerticies.Clear;
var
  X: Integer;
begin
  for X := 0 to FItems.Count-1 do begin
    FItems[X]._Release;
  end;
  FItems.Clear;
end;

function TWeatherStormVerticies.GetItem(
  const Index: Integer): IWeatherStormVertex;
begin
  Result:= FItems[Index];
end;

{ TWeatherAlertStorm }

constructor TWeatherAlertStorm.Create;
begin
  FVerticies:= TWeatherStormVerticies.Create;
  FVerticies._AddRef;
end;

destructor TWeatherAlertStorm.Destroy;
begin
  FVerticies._Release;
  FVerticies:= nil;
  inherited;
end;

function TWeatherAlertStorm.GetDateTime: TDateTime;
begin
  Result:= FDateTime;
end;

function TWeatherAlertStorm.GetDirection: Single;
begin
  Result:= FDirection;
end;

function TWeatherAlertStorm.GetLatitude: Double;
begin
  Result:= FLatitude;
end;

function TWeatherAlertStorm.GetLongitude: Double;
begin
  Result:= FLongitude;
end;

function TWeatherAlertStorm.GetSpeed: Single;
begin
  Result:= FSpeed;
end;

function TWeatherAlertStorm.GetVerticies: IWeatherStormVerticies;
begin
  Result:= FVerticies;
end;

{ TWeatherAlertZone }

function TWeatherAlertZone.GetState: WideString;
begin
  Result:= FState;
end;

function TWeatherAlertZone.GetZone: WideString;
begin
  Result:= FZone;
end;

{ TWeatherAlertZones }

constructor TWeatherAlertZones.Create;
begin
  FItems:= TList<TWeatherAlertZone>.Create;

end;

destructor TWeatherAlertZones.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited;
end;

procedure TWeatherAlertZones.Clear;
var
  X: Integer;
begin
  for X := 0 to FItems.Count-1 do begin
    FItems[X]._Release;
  end;
  FItems.Clear;
end;

function TWeatherAlertZones.Count: Integer;
begin
  Result:= FItems.Count;
end;

function TWeatherAlertZones.GetItem(const Index: Integer): IWeatherAlertZone;
begin
  Result:= FItems[Index];
end;

{ TWeatherAlert }

constructor TWeatherAlert.Create(AOwner: TJDWeatherThread);
begin
  FOwner:= AOwner;
  FZones:= TWeatherAlertZones.Create;
  FZones._AddRef;
  FStorm:= TWeatherAlertStorm.Create;
  FStorm._AddRef;
end;

destructor TWeatherAlert.Destroy;
begin
  FStorm._Release;
  FStorm:= nil;
  FZones._Release;
  FZones:= nil;
  inherited;
end;

function TWeatherAlert.SupportedFunctions: TWeatherAlertProps;
begin
  case FOwner.FOwner.FService of
    wsOpenWeatherMap: Result:= [];
    wsWUnderground: Result:= [apZones, apVerticies, apStorm, apType, apDescription,
      apExpires, apMessage, apPhenomena, apSignificance];
    wsAccuWeather: Result:= [];
    wsForeca: Result:= [];
    wsNWS: Result:= [];
    wsNOAA: Result:= [];
  end;
end;

function TWeatherAlert.GetAlertType: TWeatherAlertType;
begin
  Result:= FAlertType;
end;

function TWeatherAlert.GetDateTime: TDateTime;
begin
  Result:= FDateTime;
end;

function TWeatherAlert.GetDescription: WideString;
begin
  Result:= FDescription;
end;

function TWeatherAlert.GetExpires: TDateTime;
begin
  Result:= FExpires;
end;

function TWeatherAlert.GetMsg: WideString;
begin
  Result:= FMsg;
end;

function TWeatherAlert.GetPhenomena: WideString;
begin
  Result:= FPhenomena;
end;

function TWeatherAlert.GetSignificance: WideString;
begin
  Result:= FSignificance;
end;

function TWeatherAlert.GetStorm: IWeatherAlertStorm;
begin
  Result:= FStorm;
end;

function TWeatherAlert.GetZones: IWeatherAlertZones;
begin
  Result:= FZones;
end;

{ TWeatherAlerts }

constructor TWeatherAlerts.Create;
begin
  FItems:= TList<IWeatherAlert>.Create;
end;

destructor TWeatherAlerts.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited;
end;

function TWeatherAlerts.Count: Integer;
begin
  Result:= FItems.Count;
end;

procedure TWeatherAlerts.Clear;
var
  X: Integer;
begin
  for X := 0 to FItems.Count-1 do begin
    FItems[X]._Release;
  end;
  FItems.Clear;
end;

function TWeatherAlerts.GetItem(const Index: Integer): IWeatherAlert;
begin
  Result:= FItems[Index];
end;

{ TWeatherMaps }

constructor TWeatherMaps.Create(AOwner: TJDWeatherThread);
var
  X: TWeatherMapType;
begin
  for X := Low(TMapArray) to High(TMapArray) do begin
    FMaps[X]:= TPicture.Create;
  end;
end;

destructor TWeatherMaps.Destroy;
var
  X: TWeatherMapType;
  P: TPicture;
begin
  for X := Low(TMapArray) to High(TMapArray) do begin
    P:= FMaps[X];
    FreeAndNil(P);
  end;
  inherited;
end;

function TWeatherMaps.GetMap(const MapType: TWeatherMapType): TPicture;
begin
  Result:= FMaps[MapType];
end;

function TWeatherMaps.SupportedFunctions: TWeatherMapTypes;
begin
  case Self.FOwner.FOwner.FService of
    wsOpenWeatherMap: Result:= [mpClouds, mpPrecip, mpPressureSea,
      mpWind, mpTemp, mpSnowCover];
    wsWUnderground: Result:= [mpSatellite, mpRadar, mpSatelliteRadar];
    wsAccuWeather: Result:= [];
    wsForeca: Result:= [];
    wsNWS: Result:= [];
    wsNOAA: Result:= [];
  end;
end;

{$ENDREGION}








//Base Weather Thread

{$REGION "Base Weather Thread"}

{ TJDWeatherThread }

constructor TJDWeatherThread.Create(AOwner: TJDWeather);
begin
  inherited Create(True);
  FOwner:= AOwner;
  FWeb:= TIdHTTP.Create(nil);
  FLastAll:= 0;
  FLastConditions:= 0;
  FLastForecast:= 0;
  FLastForecastDaily:= 0;
  FLastForecastHourly:= 0;
  FLastAlerts:= 0;
  FLastMaps:= 0;
end;

destructor TJDWeatherThread.Destroy;
begin
  if Assigned(FConditions) then
    FConditions._Release;
  FConditions:= nil;
  if Assigned(FForecast) then
    FForecast._Release;
  FForecast:= nil;
  if Assigned(FForecastDaily) then
    FForecastDaily._Release;
  FForecastDaily:= nil;
  if Assigned(FForecastHourly) then
    FForecastHourly._Release;
  FForecastHourly:= nil;
  if Assigned(FAlerts) then
    FAlerts._Release;
  FAlerts:= nil;
  if Assigned(FMaps) then
    FMaps._Release;
  FMaps:= nil;
  FreeAndNil(FWeb);
  inherited;
end;

procedure TJDWeatherThread.CheckAll;
var
  R: Boolean;
begin
  FLastAll:= Now;
  try
    if Assigned(FConditions) then
      FConditions._Release;
    if Assigned(FForecast) then
      FForecast._Release;
    if Assigned(FForecastDaily) then
      FForecastDaily._Release;
    if Assigned(FForecastHourly) then
      FForecastHourly._Release;
    if Assigned(FAlerts) then
      FAlerts._Release;
    if Assigned(FMaps) then
      FMaps._Release;
    FConditions:= TWeatherConditions.Create(Self);
    FConditions._AddRef;
    FForecast:= TWeatherForecast.Create(Self);
    FForecast._AddRef;
    FForecastDaily:= TWeatherForecast.Create(Self);
    FForecastDaily._AddRef;
    FForecastHourly:= TWeatherForecast.Create(Self);
    FForecastHourly._AddRef;
    FAlerts:= TWeatherAlerts.Create;
    FAlerts._AddRef;
    FMaps:= TWeatherMaps.Create(Self);
    FMaps._AddRef;
    R:= DoAll(FConditions, FForecast, FForecastDaily, FForecastHourly, FAlerts, FMaps);
    if R then begin
      Synchronize(SYNC_DoOnConditions);
      Synchronize(SYNC_DoOnForecast);
      Synchronize(SYNC_DoOnForecastDaily);
      Synchronize(SYNC_DoOnForecastHourly);
      Synchronize(SYNC_DoOnAlerts);
      Synchronize(SYNC_DoOnMaps);
    end else begin
      FConditions._Release;
      FConditions:= nil;
      FForecast._Release;
      FForecast:= nil;
      FForecastDaily._Release;
      FForecastDaily:= nil;
      FForecastHourly._Release;
      FForecastHourly:= nil;
      FAlerts._Release;
      FAlerts:= nil;
      FMaps._Release;
      FMaps:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckConditions;
var
  R: Boolean;
begin
  FLastConditions:= Now;
  try
    if Assigned(FConditions) then
      FConditions._Release;
    FConditions:= TWeatherConditions.Create(Self);
    FConditions._AddRef;
    R:= DoConditions(FConditions);
    if R then begin
      Synchronize(SYNC_DoOnConditions);
    end else begin
      FConditions._Release;
      FConditions:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckForecast;
var
  R: Boolean;
begin
  FLastForecast:= Now;
  try
    if Assigned(FForecast) then
      FForecast._Release;
    FForecast:= TWeatherForecast.Create(Self);
    FForecast._AddRef;
    R:= DoForecast(FForecast);
    if R then begin
      Synchronize(SYNC_DoOnForecast);
    end else begin
      FForecast._Release;
      FForecast:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckForecastDaily;
var
  R: Boolean;
begin
  FLastForecastDaily:= Now;
  try
    if Assigned(FForecastDaily) then
      FForecastDaily._Release;
    FForecastDaily:= TWeatherForecast.Create(Self);
    FForecastDaily._AddRef;
    R:= DoForecast(FForecastDaily);
    if R then begin
      Synchronize(SYNC_DoOnForecastDaily);
    end else begin
      FForecastDaily._Release;
      FForecastDaily:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckForecastHourly;
var
  R: Boolean;
begin
  FLastForecastHourly:= Now;
  try
    if Assigned(FForecastHourly) then
      FForecastHourly._Release;
    FForecastHourly:= TWeatherForecast.Create(Self);
    FForecastHourly._AddRef;
    R:= DoForecast(FForecastHourly);
    if R then begin
      Synchronize(SYNC_DoOnForecastHourly);
    end else begin
      FForecastHourly._Release;
      FForecastHourly:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckAlerts;
var
  R: Boolean;
begin
  FLastAlerts:= Now;
  try
    if Assigned(FAlerts) then
      FAlerts._Release;
    FAlerts:= TWeatherAlerts.Create;
    FAlerts._AddRef;
    R:= DoAlerts(FAlerts);
    if R then begin
      Synchronize(SYNC_DoOnAlerts);
    end else begin
      FAlerts._Release;
      FAlerts:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.CheckMaps;
var
  R: Boolean;
begin
  FLastMaps:= Now;
  try
    if Assigned(FMaps) then
      FMaps._Release;
    FMaps:= TWeatherMaps.Create(Self);
    FMaps._AddRef;
    R:= DoMaps(FMaps);
    if R then begin
      Synchronize(SYNC_DoOnMaps);
    end else begin
      FMaps._Release;
      FMaps:= nil;
    end;
  except

  end;
end;

procedure TJDWeatherThread.Process;
  function TimePast(const DT: TDateTime; const Freq: Integer): Boolean;
  var
    N: TDateTime;
  begin
    N:= DateUtils.IncSecond(DT, Freq);
    Result:= Now >= N;
  end;
begin
  if FOwner.FAllAtOnce then begin

    if Terminated then Exit;
    if TimePast(FLastAll, FOwner.FAllFreq) then
      CheckAll;

  end else begin

    if Terminated then Exit;
    if TimePast(FLastConditions, FOwner.FConditionFreq) then
      CheckConditions;

    if Terminated then Exit;
    if TimePast(FLastForecast, FOwner.FForecastFreq) then
      CheckForecast;

    if Terminated then Exit;
    if TimePast(FLastForecastDaily, FOwner.FForecastFreq) then
      CheckForecastDaily;

    if Terminated then Exit;
    if TimePast(FLastForecastHourly, FOwner.FForecastFreq) then
      CheckForecastHourly;

    if Terminated then Exit;
    if TimePast(FLastAlerts, FOwner.FAlertsFreq) then
      CheckAlerts;

    if Terminated then Exit;
    if TimePast(FLastMaps, FOwner.FMapsFreq) then
      CheckMaps;

  end;
  if Terminated then Exit;
  Sleep(1);
end;

procedure TJDWeatherThread.Execute;
begin
  while not Terminated do begin
    try
      Process;
    except
      on E: Exception do begin
        //TODO
      end;
    end;
  end;
end;

function TJDWeatherThread.LoadPicture(const U: String; const P: TPicture): Boolean;
var
  S: TMemoryStream;
  I: TGifImage;
begin
  Result:= False;
  try
    S:= TMemoryStream.Create;
    try
      FWeb.Get(U, S);
      S.Position:= 0;
      I:= TGifImage.Create;
      try
        I.LoadFromStream(S);
        P.Assign(I);
        Result:= True;
      finally
        FreeAndNil(I);
      end;
    finally
      FreeAndNil(S);
    end;
  except

  end;
end;

function TJDWeatherThread.Owner: TJDWeather;
begin
  Result:= FOwner;
end;

procedure TJDWeatherThread.SYNC_DoOnConditions;
begin
  if Assigned(FOnConditions) then
    FOnConditions(Self, FConditions);
end;

procedure TJDWeatherThread.SYNC_DoOnForecast;
begin
  if Assigned(FOnForecast) then
    FOnForecast(Self, FForecast);
end;

procedure TJDWeatherThread.SYNC_DoOnForecastDaily;
begin
  if Assigned(FOnForecastDaily) then
    FOnForecastDaily(Self, FForecastDaily);
end;

procedure TJDWeatherThread.SYNC_DoOnForecastHourly;
begin
  if Assigned(FOnForecastHourly) then
    FOnForecastHourly(Self, FForecastHourly);
end;

procedure TJDWeatherThread.SYNC_DoOnAlerts;
begin
  if Assigned(FOnAlerts) then
    FOnAlerts(Self, FAlerts);
end;

procedure TJDWeatherThread.SYNC_DoOnMaps;
begin
  if Assigned(FOnMaps) then
    FOnMaps(Self, FMaps);
end;

function TJDWeatherThread.Web: TIdHTTP;
begin
  Result:= FWeb;
end;

{$ENDREGION}













//Main TJDWeather Component

{$REGION "Main TJDWeather Component"}

{ TJDWeather }

constructor TJDWeather.Create(AOwner: TComponent);
begin
  inherited;
  FLocationType:= wlAutoIP;
  FService:= wsWUnderground;
  EnsureThread;
  FAllFreq:= 300;
  FConditionFreq:= 300;
  FForecastFreq:= 300;
  FAlertsFreq:= 300;
  FMapsFreq:= 300;
  FUnits:= wuImperial;
  FWantedMaps:= [TWeatherMapType.mpAniRadar];
end;

destructor TJDWeather.Destroy;
begin
  DestroyThread;
  inherited;
end;

procedure TJDWeather.EnsureThread;
begin
  if csDesigning in ComponentState then Exit;
  if not FActive then Exit;
  if FThread <> nil then Exit;

  //If thread is not already created, create it now.
  //Depending on the chosen service, it will create the
  //service-specific thread.

  case FService of
    wsOpenWeatherMap:   FThread:= TOWMWeatherThread.Create(Self);
    wsWUnderground:     FThread:= TWUWeatherThread.Create(Self);
    wsNWS:              FThread:= TNWSWeatherThread.Create(Self);
    wsAccuWeather:      FThread:= TAWWeatherThread.Create(Self);
    wsNOAA:             FThread:= TNOAAWeatherThread.Create(Self);
    wsForeca:           FThread:= TForecaWeatherThread.Create(Self);
  end;
  FThread.FreeOnTerminate:= True;
  FThread.OnConditions:= ThreadConditions;
  FThread.OnForecast:= ThreadForecast;
  FThread.OnForecastHourly:= ThreadForecastHourly;
  FThread.OnForecastDaily:= ThreadForecastDaily;
  FThread.OnMaps:= ThreadMaps;
  FThread.OnAlerts:= ThreadAlerts;
  FThread.Start;
end;

procedure TJDWeather.DestroyThread;
begin
  if Assigned(FThread) then begin
    FThread.Terminate;
    //NOTE: DO NOT use WaitFor - thread will free on terminate!
    FThread:= nil;
  end;
end;

procedure TJDWeather.Reload;
begin
  DestroyThread;
  EnsureThread;
end;

procedure TJDWeather.ThreadConditions(Sender: TObject; const Conditions: IWeatherConditions);
begin
  if Assigned(FOnConditions) then
    FOnConditions(Self, Conditions);
end;

procedure TJDWeather.ThreadForecast(Sender: TObject; const Forecast: IWeatherForecast);
begin
  if Assigned(FOnForecast) then
    FOnForecast(Self, Forecast);
end;

procedure TJDWeather.ThreadForecastDaily(Sender: TObject;
  const Forecast: IWeatherForecast);
begin
  if Assigned(FOnForecastDaily) then
    FOnForecastDaily(Self, Forecast);
end;

procedure TJDWeather.ThreadForecastHourly(Sender: TObject;
  const Forecast: IWeatherForecast);
begin
  if Assigned(FOnForecastHourly) then
    FOnForecastHourly(Self, Forecast);
end;

procedure TJDWeather.ThreadMaps(Sender: TObject; const Maps: IWeatherMaps);
begin
  if Assigned(FOnMaps) then
    FOnMaps(Self, Maps);
end;

procedure TJDWeather.ThreadAlerts(Sender: TObject; const Alert: IWeatherAlerts);
begin
  if Assigned(FOnAlerts) then
    FOnAlerts(Self, Alert);
end;

procedure TJDWeather.SetActive(const Value: Boolean);
begin
  if Value then begin
    if not FActive then begin
      FActive:= True;
      EnsureThread;
    end;
  end else begin
    if FActive then begin
      FActive:= False;
      DestroyThread;
    end;
  end;
end;

procedure TJDWeather.SetAlertsFreq(const Value: Integer);
begin
  FAlertsFreq := Value;
end;

procedure TJDWeather.SetAllAtOnce(const Value: Boolean);
begin
  FAllAtOnce := Value;
  //TODO: Invalidate Thread
end;

procedure TJDWeather.SetAllFreq(const Value: Integer);
begin
  FAllFreq := Value;
end;

procedure TJDWeather.SetConditionFreq(const Value: Integer);
begin
  FConditionFreq := Value;
end;

procedure TJDWeather.SetForecastFreq(const Value: Integer);
begin
  FForecastFreq:= Value;
end;

procedure TJDWeather.SetKey(const Value: String);
begin
  FKey := Value;
end;

procedure TJDWeather.SetLocationDetail1(const Value: String);
begin
  FLocationDetail1 := Value;
end;

procedure TJDWeather.SetLocationDetail2(const Value: String);
begin
  FLocationDetail2 := Value;
end;

procedure TJDWeather.SetLocationType(const Value: TJDWeatherLocationType);
begin
  FLocationType := Value;
end;

procedure TJDWeather.SetMapsFreq(const Value: Integer);
begin
  FMapsFreq := Value;
end;

procedure TJDWeather.SetUnits(const Value: TWeatherUnits);
begin
  FUnits := Value;
  //TODO: Invalidate all info
end;

procedure TJDWeather.SetWantedMaps(const Value: TWeatherMapTypes);
begin
  FWantedMaps := Value;
  //TODO: Invalidate maps
end;

procedure TJDWeather.SetService(const Value: TWeatherService);
begin
  //Changing service requires swapping out thread class
  //This switching is the core of multiple services in a single common structure
  //Each inherited thread implementation must be specific to the chosen service
  if Value <> FService then begin
    if FActive then begin
      raise Exception.Create('Cannot change service while active.');
    end else begin
      DestroyThread;
      FService := Value;
      EnsureThread;
    end;
  end;
end;

{$ENDREGION}

end.

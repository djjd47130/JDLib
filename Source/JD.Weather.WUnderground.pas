unit JD.Weather.WUnderground;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.Types, System.UITypes,
  Vcl.Graphics, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Imaging.GifImg,
  JD.Weather, SuperObject;

type
  TWUEndpoint = (weAll, weAlerts, weAlmanac, weAstronomy, weConditions,
    weCurrentHurricane, weForecast, weForecast10Day, weGeoLookup, weHistory,
    weHourly, weHourly10Day, wePlanner, weRawTide, weTide, weWebCams, weYesterday,
    weRadar, weSatellite, weRadarSatellite,
    weAniRadar, weAniSatellite, weAniRadarSatellite);

  TWUWeatherThread = class(TJDWeatherThread)
  public
    procedure FillConditions(const O: ISuperObject; Conditions: TWeatherConditions);
    procedure FillForecast(const O: ISuperObject; Forecast: TWeatherForecast);
    procedure FillForecastHourly(const O: ISuperObject; Forecast: TWeatherForecast);
    procedure FillForecastDaily(const O: ISuperObject; Forecast: TWeatherForecast);
    procedure FillAlerts(const O: ISuperObject; Alerts: TWeatherAlerts);
    procedure FillMaps(const O: ISuperObject; Maps: TWeatherMaps);
    function GetEndpointUrl(const Endpoint: TWUEndpoint): String;
  private
    function StrToAlertType(const S: String): TWeatherAlertType;
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

{ TWUWeatherThread }

function TWUWeatherThread.GetUrl: String;
begin
  Result:= 'http://api.wunderground.com/api/'+Owner.Key+'/';
end;

function TWUWeatherThread.GetEndpointUrl(const Endpoint: TWUEndpoint): String;
var
  S: String;
begin
  case Endpoint of
    weAll:              S:= 'conditions/alerts/hourly/forecast10day';
    weAlerts:           S:= 'alerts';
    weAlmanac:          S:= 'almanac';
    weAstronomy:        S:= 'astronomy';
    weConditions:       S:= 'conditions';
    weCurrentHurricane: S:= 'currenthurricane';
    weForecast:         S:= 'forecast';
    weForecast10Day:    S:= 'forecast10day';
    weGeoLookup:        S:= 'geolookup';
    weHistory:          S:= 'history';
    weHourly:           S:= 'hourly';
    weHourly10Day:      S:= 'hourly10day';
    wePlanner:          S:= 'planner';
    weRawTide:          S:= 'rawtide';
    weTide:             S:= 'tide';
    weWebCams:          S:= 'webcams';
    weYesterday:        S:= 'yesterday';
    weRadar:            S:= 'radar';
    weSatellite:        S:= 'satellite';
    weRadarSatellite:   S:= 'radar/satellite';
    weAniRadar:         S:= 'animatedradar';
    weAniSatellite:     S:= 'animatedsatellite';
    weAniRadarSatellite:  S:= 'animatedradar/animatedsatellite';
  end;
  Result:= GetUrl + S + '/q/';
end;

function TWUWeatherThread.DoAll(Conditions: TWeatherConditions;
  Forecast: TWeatherForecast;
  ForecastDaily: TWeatherForecast; ForecastHourly: TWeatherForecast;
  Alerts: TWeatherAlerts;
  Maps: TWeatherMaps): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weAll);
    case Owner.LocationType of
      wlZip:          U:= U + Owner.LocationDetail1+'.json';
      wlCityState:    U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:       U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:       U:= U + 'autoip.json';
      wlCityCode:     ;
      wlCountryCity:  ;
      wlAirportCode:  ;
      wlPWS:          ;
    end;
    S:= Web.Get(U);
    O:= SO(S);

    FillConditions(O, Conditions);
    FillForecast(O, Forecast);
    FillForecastHourly(O, ForecastHourly);
    FillForecastDaily(O, ForecastDaily);
    FillAlerts(O, Alerts);
    DoMaps(Maps);

    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function TWUWeatherThread.DoConditions(Conditions: TWeatherConditions): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weConditions);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.json';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:     U:= U + 'autoip.json';
    end;
    S:= Web.Get(U);
    O:= SO(S);
    FillConditions(O, Conditions);
    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function TWUWeatherThread.DoForecast(Forecast: TWeatherForecast): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weForecast);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.json';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:     U:= U + 'autoip.json';
    end;
    S:= Web.Get(U);
    O:= SO(S);
    FillForecast(O, Forecast);
    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function TWUWeatherThread.DoForecastDaily(Forecast: TWeatherForecast): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weForecast10Day);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.json';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:     U:= U + 'autoip.json';
    end;
    S:= Web.Get(U);
    O:= SO(S);
    FillForecastDaily(O, Forecast);
    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function TWUWeatherThread.DoForecastHourly(Forecast: TWeatherForecast): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weHourly);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.json';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:     U:= U + 'autoip.json';
    end;
    S:= Web.Get(U);
    O:= SO(S);
    FillForecastHourly(O, Forecast);
    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function TWUWeatherThread.DoAlerts(Alerts: TWeatherAlerts): Boolean;
var
  U: String;
  S: String;
  O: ISuperObject;
begin
  Result:= False;
  try
    U:= GetEndpointUrl(TWUEndpoint.weAlerts);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.json';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.json';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.json';
      wlAutoIP:     U:= U + 'autoip.json';
    end;
    S:= Web.Get(U);
    O:= SO(S);
    FillAlerts(O, Alerts);
    Result:= True;
  except
    on E: Exception do begin

    end;
  end;
end;

function MapOptions(
  const Width: Integer = 400;
  const Height: Integer = 400;
  const NumFrames: Integer = 10;
  const Delay: Integer = 50;
  const FrameIndex: Integer = 0;
  const NoClutter: Boolean = True;
  const SmoothColors: Boolean = True;
  const RainSnow: Boolean = True;
  const TimeLabel: Boolean = True;
  const TimeLabelX: Integer = 10;
  const TimeLabelY: Integer = 20): String;
begin
  Result:= 'newmaps=1';
  Result:= Result + '&width='+IntToStr(Width);
  Result:= Result + '&height='+IntToStr(Height);
  Result:= Result + '&delay='+IntToStr(Delay);
  Result:= Result + '&num='+IntToStr(NumFrames);
  Result:= Result + '&frame='+IntToStr(FrameIndex);
  Result:= Result + '&noclutter='+IfThen(NoClutter, '1','0');
  Result:= Result + '&smooth='+IfThen(SmoothColors, '1','0');
  Result:= Result + '&rainsnow='+IfThen(RainSnow, '1','0');
  if TimeLabel then begin
    Result:= Result + '&timelabel=1';
    Result:= Result + '&timelabel.x='+IntToStr(TimeLabelX);
    Result:= Result + '&timelabel.y='+IntToStr(TimeLabelY);
  end;
end;

function TWUWeatherThread.DoMaps(Maps: TWeatherMaps): Boolean;
var
  S: TMemoryStream;
  U: String;
  I: TGifImage;
  procedure GetMap(const EP: TWUEndpoint; const MT: TWeatherMapType);
  begin
    U:= GetEndpointUrl(EP);
    case Owner.LocationType of
      wlZip:        U:= U + Owner.LocationDetail1+'.gif';
      wlCityState:  U:= U + Owner.LocationDetail2+'/'+Owner.LocationDetail1+'.gif';
      wlCoords:     U:= U + Owner.LocationDetail1+','+Owner.LocationDetail2+'.gif';
      wlAutoIP:     U:= U + 'autoip.gif';
    end;
    U:= U + '?'+MapOptions(700, 700, 15, 60);
    Web.Get(U, S);
    S.Position:= 0;
    I.LoadFromStream(S);
    S.Clear;
    S.Position:= 0;
    {$IFDEF USE_VCL}
    Maps.Maps[MT].Assign(I);
    {$ELSE}

    {$ENDIF}
  end;
begin
  Result:= False;
  try
    S:= TMemoryStream.Create;
    try
      I:= TGifImage.Create;
      try


        if mpRadar in Owner.WantedMaps then
          GetMap(weRadar, mpRadar);
        if mpSatellite in Owner.WantedMaps then
          GetMap(weSatellite, mpSatellite);
        if mpSatelliteRadar in Owner.WantedMaps then
          GetMap(weRadarSatellite, mpSatelliteRadar);
        if mpAniRadar in Owner.WantedMaps then
          GetMap(weAniRadar, mpAniRadar);

        Result:= True;

      finally
        I.Free;
      end;
    finally
      S.Free;
    end;
  except

  end;
end;

procedure TWUWeatherThread.FillConditions(const O: ISuperObject; Conditions: TWeatherConditions);
var
  OB, L: ISuperObject;
  function LD(const O: ISuperObject; const N: String): Double;
  var
    T: String;
  begin
    T:= O.S[N];
    Result:= StrToFloatDef(T, 0);
  end;
begin
  OB:= O.O['current_observation'];
  if not Assigned(OB) then Exit;

  L:= OB.O['display_location'];
  if not Assigned(L) then Exit;

  Conditions.FLocation.FDisplayName:= L.S['full'];
  Conditions.FLocation.FCity:= L.S['city'];
  Conditions.FLocation.FState:= L.S['state_name'];
  Conditions.FLocation.FStateAbbr:= L.S['state'];
  Conditions.FLocation.FCountry:= L.S['country'];
  Conditions.FLocation.FCountryAbbr:= L.S['country_iso3166'];
  Conditions.FLocation.FLongitude:= LD(L, 'longitude');
  Conditions.FLocation.FLatitude:= LD(L, 'latitude');
  Conditions.FLocation.FElevation:= LD(L, 'elevation');
  Conditions.FLocation.FZipCode:= L.S['zip'];

  case Owner.Units of
    wuKelvin: begin
      //Not Supported
    end;
    wuImperial: begin
      Conditions.FTemp:= OB.D['temp_f'];
      Conditions.FVisibility:= LD(OB, 'visibility_mi');
      Conditions.FDewPoint:= OB.D['dewpoint_f'];
    end;
    wuMetric: begin
      Conditions.FTemp:= OB.D['temp_c'];
      Conditions.FVisibility:= LD(OB, 'visibility_km');
      Conditions.FDewPoint:= OB.D['dewpoint_c'];
    end;
  end;

  Conditions.FDateTime:= Now; //TODO
  Conditions.FHumidity:= LD(OB, 'relative_humidity');
  Conditions.FPressure:= LD(OB, 'pressure_mb');
  Conditions.FCondition:= OB.S['weather'];
  Conditions.FDescription:= OB.S['weather'];
  Conditions.FWindSpeed:= OB.D['wind_mph'];
  Conditions.FWindDir:= OB.D['wind_degrees'];

  {$IFDEF USE_VCL}
  LoadPicture(OB.S['icon_url'], Conditions.FPicture);
  {$ENDIF}

end;

procedure TWUWeatherThread.FillForecast(const O: ISuperObject; Forecast: TWeatherForecast);
var
  OB: ISuperObject;
  A: TSuperArray;
  I: TWeatherForecastItem;
  X: Integer;
  function LD(const O: ISuperObject; const N: String): Double;
  var
    T: String;
  begin
    T:= O.S[N];
    Result:= StrToFloatDef(T, 0);
  end;
begin
  A:= O.A['hourly_forecast'];
  if not Assigned(A) then begin
    Exit;
  end;

  for X := 0 to A.Length-1 do begin
    OB:= A.O[X];
    I:= TWeatherForecastItem.Create(Forecast);
    try
      case Owner.Units of
        wuKelvin: begin
          //TODO: NOT SUPPORTED - Calculate?
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['metric'], 0);

          I.FWindSpeed:= OB.O['wspd'].D['metric'];
        end;
        wuImperial: begin
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['english'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['english'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['wspd'].S['english'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['english'], 0);
        end;
        wuMetric: begin
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['wspd'].S['metric'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['metric'], 0);
        end;
      end;
      I.FDateTime:=  EpochLocal(StrToIntDef(OB.O['FCTTIME'].S['epoch'], 0));
      I.FTemp:= I.FTempMax; //TODO
      I.FHumidity:= StrToFloatDef(OB.S['humidity'], 0);
      I.FPressure:= 0;
      I.FCondition:= OB.S['condition'];
      I.FDescription:= OB.S['condition'];
      I.FWindDir:= StrToFloatDef(OB.O['wdir'].S['degrees'], 0);
      I.FVisibility:= 0;
      {$IFDEF USE_VCL}
      LoadPicture(OB.S['icon_url'], I.FPicture);
      {$ENDIF}
    finally
      Forecast.FItems.Add(I);
    end;
  end;
end;

procedure TWUWeatherThread.FillForecastDaily(const O: ISuperObject;
  Forecast: TWeatherForecast);
var
  OB: ISuperObject;
  A: TSuperArray;
  I: TWeatherForecastItem;
  X: Integer;
  function LD(const O: ISuperObject; const N: String): Double;
  var
    T: String;
  begin
    T:= O.S[N];
    Result:= StrToFloatDef(T, 0);
  end;
begin
  OB:= O.O['forecast'];
  if not Assigned(OB) then begin
    Exit;
  end;

  OB:= OB.O['simpleforecast'];
  if not Assigned(OB) then begin
    Exit;
  end;

  A:= OB.A['forecastday'];
  if not Assigned(A) then begin
    Exit;
  end;

  for X := 0 to A.Length-1 do begin
    OB:= A.O[X];
    I:= TWeatherForecastItem.Create(Forecast);
    try
      case Owner.Units of
        wuKelvin: begin
          //TODO: NOT SUPPORTED - Calculate?
          I.FTempMin:= StrToFloatDef(OB.O['low'].S['celsius'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['high'].S['celsius'], 0);
          I.FWindSpeed:= OB.O['avewind'].D['kph'];
          I.FDewPoint:= 0; //Not Supported
        end;
        wuImperial: begin
          I.FTempMin:= StrToFloatDef(OB.O['low'].S['ferenheit'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['high'].S['ferenheit'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['avewind'].S['mph'], 0);
          I.FDewPoint:= 0; //Not Supported
        end;
        wuMetric: begin
          I.FTempMin:= StrToFloatDef(OB.O['low'].S['celsius'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['high'].S['celsius'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['avewind'].S['kph'], 0);
          I.FDewPoint:= 0; //Not Supported
        end;
      end;
      I.FDateTime:=  EpochLocal(StrToIntDef(OB.O['date'].S['epoch'], 0));
      I.FTemp:= I.FTempMax; //TODO
      I.FHumidity:= StrToFloatDef(OB.S['avehumidity'], 0);
      I.FPressure:= 0;
      I.FCondition:= OB.S['conditions'];
      I.FDescription:= OB.S['conditions'];
      I.FWindDir:= StrToFloatDef(OB.O['avewind'].S['degrees'], 0);
      I.FVisibility:= 0; //Not Supported
      {$IFDEF USE_VCL}
      LoadPicture(OB.S['icon_url'], I.FPicture);
      {$ENDIF}
    finally
      Forecast.FItems.Add(I);
    end;
  end;
end;

procedure TWUWeatherThread.FillForecastHourly(const O: ISuperObject;
  Forecast: TWeatherForecast);
var
  OB: ISuperObject;
  A: TSuperArray;
  I: TWeatherForecastItem;
  X: Integer;
  function LD(const O: ISuperObject; const N: String): Double;
  var
    T: String;
  begin
    T:= O.S[N];
    Result:= StrToFloatDef(T, 0);
  end;
begin
  A:= O.A['hourly_forecast'];
  if not Assigned(A) then begin
    Exit;
  end;

  for X := 0 to A.Length-1 do begin
    OB:= A.O[X];
    I:= TWeatherForecastItem.Create(Forecast);
    try
      case Owner.Units of
        wuKelvin: begin
          //TODO: NOT SUPPORTED - Calculate?
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['metric'], 0);

          I.FWindSpeed:= OB.O['wspd'].D['metric'];
        end;
        wuImperial: begin
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['english'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['english'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['wspd'].S['english'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['english'], 0);
        end;
        wuMetric: begin
          I.FTempMin:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FTempMax:= StrToFloatDef(OB.O['temp'].S['metric'], 0);
          I.FWindSpeed:= StrToFloatDef(OB.O['wspd'].S['metric'], 0);
          I.FDewPoint:= StrToFloatDef(OB.O['dewpoint'].S['metric'], 0);
        end;
      end;
      I.FDateTime:=  EpochLocal(StrToIntDef(OB.O['FCTTIME'].S['epoch'], 0));
      I.FTemp:= I.FTempMax; //TODO
      I.FHumidity:= StrToFloatDef(OB.S['humidity'], 0);
      I.FPressure:= 0;
      I.FCondition:= OB.S['condition'];
      I.FDescription:= OB.S['condition'];
      I.FWindDir:= StrToFloatDef(OB.O['wdir'].S['degrees'], 0);
      I.FVisibility:= 0;
      {$IFDEF USE_VCL}
      LoadPicture(OB.S['icon_url'], I.FPicture);
      {$ENDIF}
    finally
      Forecast.FItems.Add(I);
    end;
  end;
end;

function TWUWeatherThread.StrToAlertType(const S: String): TWeatherAlertType;
  procedure Chk(const Val: String; const T: TWeatherAlertType);
  begin
    if SameText(S, Val) then begin
      Result:= T;
    end;
  end;
begin
  Chk('', TWeatherAlertType.waNone);
  Chk('HUR', TWeatherAlertType.waHurricaneStat);
  Chk('TOR', TWeatherAlertType.waTornadoWarn);
  Chk('TOW', TWeatherAlertType.waTornadoWatch);
  Chk('WRN', TWeatherAlertType.waSevThundWarn);
  Chk('SEW', TWeatherAlertType.waSevThundWatch);
  Chk('WIN', TWeatherAlertType.waWinterAdv);
  Chk('FLO', TWeatherAlertType.waFloodWarn);
  Chk('WAT', TWeatherAlertType.waFloodWatch);
  Chk('WND', TWeatherAlertType.waHighWind);
  Chk('SVR', TWeatherAlertType.waSevStat);
  Chk('HEA', TWeatherAlertType.waHeatAdv);
  Chk('FOG', TWeatherAlertType.waFogAdv);
  Chk('SPE', TWeatherAlertType.waSpecialStat);
  Chk('FIR', TWeatherAlertType.waFireAdv);
  Chk('VOL', TWeatherAlertType.waVolcanicStat);
  Chk('HWW', TWeatherAlertType.waHurricaneWarn);
  Chk('REC', TWeatherAlertType.waRecordSet);
  Chk('REP', TWeatherAlertType.waPublicRec);
  Chk('PUB', TWeatherAlertType.waPublicStat);
end;

procedure TWUWeatherThread.FillAlerts(const O: ISuperObject;
  Alerts: TWeatherAlerts);
var
  A: TSuperArray;
  Tmp: Int64;
  I: TWeatherAlert;
  Obj: ISuperObject;
  X: Integer;
  function LD(const O: ISuperObject; const N: String): Double;
  var
    T: String;
  begin
    T:= O.S[N];
    Result:= StrToFloatDef(T, 0);
  end;
begin
  A:= O.A['alerts'];
  if not Assigned(A) then Exit;

  for X := 0 to A.Length-1 do begin
    Obj:= A.O[X];
    I:= TWeatherAlert.Create;
    try
      I.FAlertType:= StrToAlertType(Obj.S['type']);
      I.FDescription:= Obj.S['description'];
      Tmp:= StrToIntDef(Obj.S['date_epoch'], 0);
      I.FDateTime:= EpochLocal(Tmp);
      Tmp:= StrToIntDef(Obj.S['expires_epoch'], 0);
      I.FExpires:= EpochLocal(Tmp);
      I.FMsg:= Obj.S['message'];
      I.FPhenomena:= Obj.S['phenomena'];
      I.FSignificance:= Obj.S['significance'];
      //Zones
      //Storm
    finally
      Alerts.FItems.Add(I);
    end;
  end;
end;

procedure TWUWeatherThread.FillMaps(const O: ISuperObject; Maps: TWeatherMaps);
begin

end;

end.

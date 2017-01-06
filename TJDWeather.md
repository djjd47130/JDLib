# TJDWeather Component

### About
1. Allows you to retrieve weather information from multiple different weather service APIs.
2. Multi-threaded fetching mechanism to space the main-thread activity.
3. Event-triggered when new weather information is available.
4. Different types of weather information for a given location...
  1. Current Conditions
  2. Weather Alerts
  3. Radar and Satellite Maps
  4. Daily and Hourly Forecasts
5. Different ways of specifying location...
  1. City / State
  2. Zip Code
  3. Geographical Coordinates
  4. Auto-detect by IP Address

### Related Units
1. **[JD.Weather.pas](Source/JD.Weather.pas)** - Contains the main TJDWeather component and all necessary common code.
2. **[JD.Weather.WUnderground.pas](Source/JD.Weather.WUnderground.pas)** - Contains implementation specific to Weather Underground API.
3. **[JD.Weather.AccuWeather.pas](Source/JD.Weather.AccuWeather.pas)** - Contains implementation specific to the AccuWeather API.
4. **[JD.Weather.OpenWeatherMaps.pas](Source/JD.Weather.OpenWeatherMaps.pas)** - Contains implementation specific to the Open Weather Maps API.
5. **[JD.Weather.Foreca.pas](Source/JD.Weather.Foreca.pas)** - Contains implementation specific to the Foreca API.
6. **[JD.Weather.NWS.pas](Source/JD.Weather.NWS.pas)** - Contains implementation specific to the National Weather Service API.
7. **[JD.Weather.NOAA.pas](Source/JD.Weather.NOAA.pas)** - Contains implementation specific to the National Oceanic and Atmospheric Administration API.

### How to Use
1. Subscribe to one of the supported services
2. Acquire an API Key which authenticates your account
3. Select the service by assigning TJDWeather.Service
4. Enter your API Key by assigning TJDWeather.Key
  1. Specify the frequency of each different weather information type
    1. **NOTE**: The numbers are seconds between calls
    2. **IMPORTANT**: Depending on which service you choose, your account will be likely
       limited to a certain number of requests in a given day. Therefore, it is
       very important to adjust these frequency properties to correspond with
       your particular account's capabilities. Sometimes, this may mean
       ten to twenty minutes between checks for weather, if your account
       has a low limit, or if you use the app in multiple places.
5. Select your desired location by assigning TJDWeather.LocationType
  1. **wlAutoIP**: Automatically detects your location based on your IP Address
  2. **wlCityState**: Assign City to "LocationDetail1" and State to "LocationDetail2"
  3. **wlZip**: Assign Zip Code to "LocationDetail1"
  4. **wlCoords**: Assign Longitude to "LocationDetail1" and Latitude to "LocationDetail2"
    1. **NOTE**: Format of each property must be with numeric digits such as:
       45.9764
       -15.9724
6. Assign event handlers to the desired weather information
  1. **NOTE**: Weather information is actually provided when these events are fired.
     You are responsible to acquire a copy of the corresponding weather interface
     from the event handler's parameters and store your own reference.
     These interfaces are by default reference-counted.

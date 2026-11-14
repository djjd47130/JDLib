unit JDTests;

{
  Small plain-Delphi test unit for JDLib's pure-logic code - no DUnitX or
  other test framework needed. NOT part of any package: it is a standalone
  unit you pull into a throwaway console app when you want to check the
  color math, rect math, and DataSizeStr still behave.

  HOW TO USE
  ----------
  1. In Delphi, create a new Console Application project.
  2. Add this unit to the project, and add the JDLib Source folder to the
     project's Search Path. (JD.Graphics also uses the XSuperObject and
     GDI+ header units, so those need to be on the Search Path too -
     same as building the JDLib package itself.)
  3. In the .dpr, call RunAllJDTests and print / return the failure count:

       program JDTestApp;
       {$APPTYPE CONSOLE}
       uses
         System.SysUtils,
         JDTests in '..\Tests\JDTests.pas'; // adjust path as needed
       begin
         try
           if RunAllJDTests = 0 then
             WriteLn('ALL TESTS PASSED')
           else
             WriteLn('THERE WERE FAILURES - see above');
         except
           on E: Exception do
             WriteLn('TEST RUN CRASHED: ', E.ClassName, ': ', E.Message);
         end;
         ReadLn; // pause so you can see the output
       end.

  Each TestXxx function returns the number of checks that failed inside it
  (0 = pass). RunAllJDTests runs them all and returns the total failure
  count. Failures are also printed to the console as they happen.

  NOTES
  -----
  - This unit uses WriteLn to report, so it is meant for console apps only.
    Do not use it from a GUI app (WriteLn with no console raises EInOutError).
  - TestDataSizeStr uses JD.SysMon.Utils, which is the heaviest dependency
    here: that unit pulls in Vcl.Dialogs / ActiveX / ComObj, and its
    initialization section calls CoInitialize and primes the CPU-usage cache
    by opening every process once. That is harmless in a throwaway test app,
    but if you would rather not drag it in, just comment out the
    TestDataSizeStr call in RunAllJDTests (and the function itself) and
    remove JD.SysMon.Utils from the uses clause below.
  - DataSizeStr formats numbers with FormatFloat, which uses the Windows
    locale decimal separator - so the DataSizeStr checks below only test the
    unit suffix (" B", " KB", ...) and never the exact digits.
}

interface

/// <summary>
/// RGB -> HSV -> RGB round-trip on several colors, plus the specific
/// regressions from the 2026-11-13 review: S/V in 0..100 (not 0..1),
/// gray reporting hue 0 (not 300), H=72 converting correctly, and the
/// TJDColor hue setter not washing the color out.
/// </summary>
function TestHSVRoundTrip: Integer;

/// <summary>
/// TJDCHue >= and <= operators (they used to be plain > and <).
/// </summary>
function TestHueOperators: Integer;

/// <summary>
/// JDRect(Width, Height, Center) centering, both overloads.
/// </summary>
function TestJDRectCentering: Integer;

/// <summary>
/// DataSizeStr unit suffixes (see the header note about JD.SysMon.Utils).
/// </summary>
function TestDataSizeStr: Integer;

/// <summary>
/// ColorFade clamping: 254 + 10 must give 255, not wrap to 8.
/// </summary>
function TestColorFadeClamp: Integer;

/// <summary>
/// Runs every test above and returns the total failure count (0 = all pass).
/// </summary>
function RunAllJDTests: Integer;

implementation

uses
  System.SysUtils,
  JD.Graphics, JD.Common, JD.SysMon.Utils;

var
  _FailCount: Integer;

procedure Check(const Condition: Boolean; const Msg: String);
begin
  if not Condition then begin
    Inc(_FailCount);
    WriteLn('FAIL: ', Msg);
  end;
end;

procedure CheckClose(const Actual, Expected, Tolerance: Double; const Msg: String);
begin
  Check(Abs(Actual - Expected) <= Tolerance,
    Msg + Format(' (expected %f, got %f)', [Expected, Actual]));
end;

function EndsWithStr(const S, Sub: String): Boolean;
begin
  Result:= (Length(S) >= Length(Sub)) and
    (Copy(S, Length(S) - Length(Sub) + 1, Length(Sub)) = Sub);
end;

procedure CheckRGBRoundTrip(const R, G, B: Byte; const Name: String);
var
  H, S, V: Double;
  R2, G2, B2: Byte;
begin
  Check(RGBToHSV(R, G, B, H, S, V), Name + ': RGBToHSV returned False');
  //S and V must be 0..100 - the old code returned 0..1 (review §3.5).
  Check((S >= 0) and (S <= 100), Name + ': S out of 0..100 range');
  Check((V >= 0) and (V <= 100), Name + ': V out of 0..100 range');
  Check((H >= 0) and (H <= 360), Name + ': H out of 0..360 range');
  HSVToRGB(H, S, V, R2, G2, B2);
  //Allow +/-1 per channel for rounding in the conversions.
  Check(Abs(Integer(R2) - Integer(R)) <= 1,
    Name + ': Red did not round-trip (got ' + IntToStr(R2) +
    ', expected ' + IntToStr(R) + ')');
  Check(Abs(Integer(G2) - Integer(G)) <= 1,
    Name + ': Green did not round-trip (got ' + IntToStr(G2) +
    ', expected ' + IntToStr(G) + ')');
  Check(Abs(Integer(B2) - Integer(B)) <= 1,
    Name + ': Blue did not round-trip (got ' + IntToStr(B2) +
    ', expected ' + IntToStr(B) + ')');
end;

function TestHSVRoundTrip: Integer;
var
  Start: Integer;
  H, S, V: Double;
  R, G, B: Byte;
  C: TJDColor;
begin
  Start:= _FailCount;

  CheckRGBRoundTrip(255, 0, 0, 'Red');
  CheckRGBRoundTrip(0, 255, 0, 'Green');
  CheckRGBRoundTrip(0, 0, 255, 'Blue');
  CheckRGBRoundTrip(255, 255, 255, 'White');
  CheckRGBRoundTrip(0, 0, 0, 'Black');
  CheckRGBRoundTrip(128, 128, 128, 'Gray');
  CheckRGBRoundTrip(255, 128, 0, 'Orange');
  CheckRGBRoundTrip(128, 0, 128, 'Purple');
  CheckRGBRoundTrip(0, 128, 128, 'Teal');
  CheckRGBRoundTrip(123, 45, 67, 'Random');

  //Pure red must be S=100, V=100 (the old 0..1 scale gave 1 and 1).
  RGBToHSV(255, 0, 0, H, S, V);
  CheckClose(S, 100, 0.01, 'Red saturation');
  CheckClose(V, 100, 0.01, 'Red brightness');
  CheckClose(H, 0, 0.01, 'Red hue');

  //Gray has no hue: H must be 0, not 300 (review §3.7).
  RGBToHSV(128, 128, 128, H, S, V);
  CheckClose(H, 0, 0.001, 'Gray hue');
  CheckClose(S, 0, 0.001, 'Gray saturation');
  CheckClose(V, 128 * 100 / 255, 0.01, 'Gray brightness');

  //H=72 is the review's example for the (H' mod 2) fix (§3.6):
  //H'=1.2, so X=0.8*C and the result must be (204, 255, 0).
  //The old Frac(H') formula gave X=0.2*C, i.e. (51, 255, 0).
  HSVToRGB(72, 100, 100, R, G, B);
  Check((R = 204) and (G = 255) and (B = 0),
    'HSV(72,100,100) must be RGB(204,255,0), got (' +
    IntToStr(R) + ',' + IntToStr(G) + ',' + IntToStr(B) + ')');

  //Setting the hue must not destroy the color (review §3.5):
  //red with hue set to 120 must come out green, not nearly black.
  C.Red:= 255;
  C.Green:= 0;
  C.Blue:= 0;
  C.Hue:= 120;
  Check((C.Red <= 1) and (C.Green >= 254) and (C.Blue <= 1),
    'Red with Hue:=120 must be green, got (' +
    IntToStr(C.Red) + ',' + IntToStr(C.Green) + ',' + IntToStr(C.Blue) + ')');

  //DetectColorMode must see real brightness now (review §3.5):
  //white is Light, black is Dark - before the fix everything read Dark.
  C.Red:= 255;
  C.Green:= 255;
  C.Blue:= 255;
  Check(DetectColorMode(C) = cmLight, 'DetectColorMode(white) must be cmLight');
  C.Red:= 0;
  C.Green:= 0;
  C.Blue:= 0;
  Check(DetectColorMode(C) = cmDark, 'DetectColorMode(black) must be cmDark');

  Result:= _FailCount - Start;
end;

function TestHueOperators: Integer;
var
  Start: Integer;
  H90a, H90b, H45: TJDCHue;
begin
  Start:= _FailCount;

  H90a:= 90.0;
  H90b:= 90.0;
  H45:= 45.0;

  //The >= / <= operators used to be plain > / < (review §3.8),
  //so equal hues compared False both ways.
  Check(H90a >= H90b, 'Hue 90 >= 90 must be True');
  Check(H90a <= H90b, 'Hue 90 <= 90 must be True');
  Check(not (H90a > H90b), 'Hue 90 > 90 must be False');
  Check(not (H90a < H90b), 'Hue 90 < 90 must be False');
  Check(H90a = H90b, 'Hue 90 = 90 must be True');
  Check(not (H90a <> H90b), 'Hue 90 <> 90 must be False');

  Check(H45 < H90a, 'Hue 45 < 90 must be True');
  Check(H45 <= H90a, 'Hue 45 <= 90 must be True');
  Check(H90a > H45, 'Hue 90 > 45 must be True');
  Check(H90a >= H45, 'Hue 90 >= 45 must be True');
  Check(not (H45 >= H90a), 'Hue 45 >= 90 must be False');
  Check(not (H45 > H90a), 'Hue 45 > 90 must be False');

  Result:= _FailCount - Start;
end;

function TestJDRectCentering: Integer;
var
  Start: Integer;
  W, H: Single;
  WI, HI: Integer;
  CX, CY: Single;
  R: TJDRect;
begin
  Start:= _FailCount;

  //Single overload: a 100x50 rect centered at (200,200) must span
  //Left=150, Top=175, Right=250, Bottom=225. The old math put it at
  //Left=-100 (review §3.15).
  W:= 100;
  H:= 50;
  CX:= 200;
  CY:= 200;
  R:= JDRect(W, H, JDPoint(CX, CY));
  CheckClose(R.Left, 150, 0.001, 'JDRect(Single) Left');
  CheckClose(R.Top, 175, 0.001, 'JDRect(Single) Top');
  CheckClose(R.Right, 250, 0.001, 'JDRect(Single) Right');
  CheckClose(R.Bottom, 225, 0.001, 'JDRect(Single) Bottom');
  CheckClose(R.Center().X, 200, 0.001, 'JDRect(Single) Center.X');
  CheckClose(R.Center().Y, 200, 0.001, 'JDRect(Single) Center.Y');

  //Odd dimensions must center on the half-pixel, not shift by a whole one.
  W:= 101;
  H:= 51;
  R:= JDRect(W, H, JDPoint(CX, CY));
  CheckClose(R.Left, 149.5, 0.001, 'JDRect(Single, odd width) Left');
  CheckClose(R.Top, 174.5, 0.001, 'JDRect(Single, odd height) Top');

  //Integer overload: same numbers, same expected rect.
  WI:= 100;
  HI:= 50;
  R:= JDRect(WI, HI, JDPoint(CX, CY));
  CheckClose(R.Left, 150, 0.001, 'JDRect(Integer) Left');
  CheckClose(R.Top, 175, 0.001, 'JDRect(Integer) Top');
  CheckClose(R.Right, 250, 0.001, 'JDRect(Integer) Right');
  CheckClose(R.Bottom, 225, 0.001, 'JDRect(Integer) Bottom');

  Result:= _FailCount - Start;
end;

function TestDataSizeStr: Integer;
var
  Start: Integer;
  Big: Int64;
begin
  Start:= _FailCount;

  //Only the suffix is checked: the digits use the locale decimal
  //separator, so an exact string match would fail on some machines.
  Check(EndsWithStr(DataSizeStr(500), ' B'),
    'DataSizeStr(500) must end in " B", got "' + DataSizeStr(500) + '"');
  Check(EndsWithStr(DataSizeStr(2048), ' KB'),
    'DataSizeStr(2048) must end in " KB", got "' + DataSizeStr(2048) + '"');
  Check(EndsWithStr(DataSizeStr(5 * 1024 * 1024), ' MB'),
    'DataSizeStr(5 MB) must end in " MB", got "' +
    DataSizeStr(5 * 1024 * 1024) + '"');
  Big:= 3;
  Big:= Big * 1024 * 1024 * 1024;
  Check(EndsWithStr(DataSizeStr(Big), ' GB'),
    'DataSizeStr(3 GB) must end in " GB", got "' + DataSizeStr(Big) + '"');
  Check(EndsWithStr(DataSizeStr(2048, jdKiloBytes), ' KB'),
    'DataSizeStr(2048, jdKiloBytes) must end in " KB"');
  Check(EndsWithStr(DataSizeStr(500, jdBytes), ' B'),
    'DataSizeStr(500, jdBytes) must end in " B"');

  Result:= _FailCount - Start;
end;

function TestColorFadeClamp: Integer;
var
  Start: Integer;
  Src, Faded: TJDColor;
  Arr: TJDColorArray;
begin
  Start:= _FailCount;

  //254 + 10 must clamp to 255, not wrap to 8 (review §3.27).
  Src.Red:= 254;
  Src.Green:= 0;
  Src.Blue:= 10;
  Faded:= ColorFade(Src, 10);
  Check(Faded.Red = 255, 'ColorFade(254, +10) Red must be 255, got ' +
    IntToStr(Faded.Red));
  Check(Faded.Green = 10, 'ColorFade(0, +10) Green must be 10, got ' +
    IntToStr(Faded.Green));
  Check(Faded.Blue = 20, 'ColorFade(10, +10) Blue must be 20, got ' +
    IntToStr(Faded.Blue));

  //5 - 10 must clamp to 0, not wrap to 251.
  Src.Red:= 5;
  Src.Green:= 200;
  Src.Blue:= 200;
  Faded:= ColorFade(Src, -10);
  Check(Faded.Red = 0, 'ColorFade(5, -10) Red must be 0, got ' +
    IntToStr(Faded.Red));
  Check(Faded.Green = 190, 'ColorFade(200, -10) Green must be 190, got ' +
    IntToStr(Faded.Green));

  //Array overload: each step adds the shift again, clamped every time.
  Src.Red:= 250;
  Src.Green:= 250;
  Src.Blue:= 250;
  Arr:= ColorFade(Src, 3, 10);
  Check(Length(Arr) = 3, 'ColorFade array must have 3 entries');
  if Length(Arr) = 3 then begin
    Check(Arr[0].Red = 250, 'ColorFade array[0] must be 250, got ' +
      IntToStr(Arr[0].Red));
    Check(Arr[1].Red = 255, 'ColorFade array[1] must clamp to 255, got ' +
      IntToStr(Arr[1].Red));
    Check(Arr[2].Red = 255, 'ColorFade array[2] must clamp to 255, got ' +
      IntToStr(Arr[2].Red));
  end;

  Result:= _FailCount - Start;
end;

function RunAllJDTests: Integer;
begin
  _FailCount:= 0;
  WriteLn('JDLib tests...');
  TestHSVRoundTrip;
  TestHueOperators;
  TestJDRectCentering;
  TestDataSizeStr;
  TestColorFadeClamp;
  WriteLn('Done: ', _FailCount, ' failure(s).');
  Result:= _FailCount;
end;

end.

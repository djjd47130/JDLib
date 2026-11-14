unit JD.Ctrls.Toolbar;

{$DEFINE FB_ACTIONS}
{ $DEFINE FB_ACTIONS_IMG}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Forms, Vcl.Styles, Vcl.Themes,
  Vcl.Dialogs
  {$IFDEF FB_ACTIONS}
  , Vcl.ActnList
  {$ENDIF}
  , Vcl.ToolWin
  , JD.Ctrls
  , JD.Common
  , JD.Graphics
  , JD.FontGlyphs
  , JD.Ctrls.FontButton
  ;

type
  TJDToolButton = class(TGraphicControl)

  end;

  TJDToolbar = class(TToolWindow)

  end;

implementation

end.

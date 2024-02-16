unit JD.Ctrls;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls,
  JD.Common;

//TODO: Change all library's custom controls to inherit from these standards...

type
  ///  <summary>
  ///  Base class for all JD custom controls.
  ///  Currently for the sole purpose of automatically adding this unit
  ///  to the uses clause of any form which uses a JD custom control.
  ///  Also applies to TJDCustomControl as defined in JD.Common. This way,
  ///  whenver any JD custom control is implemented on any form, both
  ///  JD.Ctrls and JD.Common are automatically included in the uses clause.
  ///  </summary>
  TJDControl = class(TJDCustomControl)

  end;


implementation

end.

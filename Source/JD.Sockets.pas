unit JD.Sockets;

(*
Raw concept of custom TCP sockets. The idea is to wrap basic TCP communication
and provide several additional options, such as user login and session state,
system settings sync, user settings sync, push-notifications, and more.

The original (very old) idea was to use WinSock, specifically SockCmp,
but those have since proven to be extremely outdated, and only exist for
backwards-compatibility. Instead, following the trend of many of my projects,
it shall make use of Indy's TCP Server and Client components.

*)

interface

uses
  System.Classes, System.SysUtils;

type
  TJDServerSocket = class(TComponent)

  end;

  TJDClientSocket = class(TComponent)

  end;

  TJDServerClientSocket = class(TObject)

  end;

implementation

end.

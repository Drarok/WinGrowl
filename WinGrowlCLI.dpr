program WinGrowlCLI;

{$R *.RES}

  Function CreateRegistrationPacket(AppName, Password : PChar) : Pointer; External 'LibWinGrowl.dll';
  Procedure FreeRegistrationPacket(Packet : Pointer); External 'LibWinGrowl.dll';
  Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean); External 'LibWinGrowl.dll';

  Function CreateNotificationPacket(AppName, Notification, Title, Description, Password : PChar) : Pointer; External 'LibWinGrowl.dll';
  Procedure FreeNotificationPacket(Packet : Pointer); External 'LibWinGrowl.dll';

  Procedure SendPacket(Packet : Pointer; Host : PChar; Port : Integer); External 'LibWinGrowl.dll';

Var
  R : Pointer;
  N : Pointer;
  x : Integer;
  S : String;
begin

  R := CreateRegistrationPacket(PChar(ParamStr(1)), 'password');
  Registration_AddNotification(R, PChar(ParamStr(2)), True);
  SendPacket(R, PChar('127.0.0.1'), 9887);
  FreeRegistrationPacket(R);

  S := '';
  For x := 4 To ParamCount() Do
    S := S + ' '+ParamStr(x);

  N := CreateNotificationPacket(
    PChar(ParamStr(1)),
    PChar(ParamStr(2)),
    PChar(ParamStr(3)),
    PChar(S),
    PChar('password')
  );
  SendPacket(N, PChar('127.0.0.1'), 9887);
  FreeNotificationPacket(N);
end.
